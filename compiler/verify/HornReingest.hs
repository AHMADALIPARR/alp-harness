-- SPDX-License-Identifier: AGPL-3.0-only
-- Copyright (C) 2026 Ahmad Ali Parr
-- GNU Affero General Public License version 3 only.
--
-- Stage 1, reingest. Parent, father, and ancestor, with an explicit
-- ancestor base clause. Node identifiers must be non-empty and not NULL.
-- This is Haskell 2018 source. It has not been loaded in a Curry system.

module HornReingest where

import qualified Data.Set as S
import qualified Data.Map.Strict as M
import Data.List (nub, foldl')

data Term = Var String | App String [Term] deriving (Eq, Ord, Show)
data Atom = Atom String [Term] deriving (Eq, Ord, Show)
data Clause = Clause { clauseHead :: Atom, clauseBody :: [Atom] } deriving (Eq, Show)
type Program = [Clause]
type Verify a = Either String a

validNodeId :: String -> Bool
validNodeId v = not (null v) && v /= "NULL"

maxModelSize :: Int
maxModelSize = 512

program :: Program
program =
  [ Clause (Atom "parent" [App "NodeA" [], App "NodeB" []]) []
  , Clause (Atom "parent" [App "NodeB" [], App "NodeC" []]) []
  , Clause (Atom "father" [Var "X", Var "Y"])
           [Atom "parent" [Var "X", Var "Y"]]
  , Clause (Atom "ancestor" [Var "X", Var "Y"])
           [Atom "parent" [Var "X", Var "Y"]]
  , Clause (Atom "ancestor" [Var "X", Var "Z"])
           [Atom "parent" [Var "X", Var "Y"],
            Atom "ancestor" [Var "Y", Var "Z"]]
  ]

termVars :: Term -> S.Set String
termVars (Var v) = S.singleton v
termVars (App _ ts) = S.unions (map termVars ts)

atomVars :: Atom -> S.Set String
atomVars (Atom _ ts) = S.unions (map termVars ts)

checkNodeIds :: Program -> Verify ()
checkNodeIds p =
  case [ n | Clause h b <- p, Atom _ ts <- h : b
       , App n _ <- ts, not (validNodeId n) ] of
       [] -> Right ()
       ns -> Left $ "NodeID refinement violated: " ++ show ns

checkArities :: Program -> Verify ()
checkArities p =
  let sigs = [ (n, length ts) | Clause (Atom n ts) _ <- p ]
      tbl = foldl' (\m (n,a) -> M.insertWith (++) n [a] m) M.empty sigs
      bad = [ (n, as) | (n, as) <- M.toList tbl, length (nub as) > 1 ]
  in case bad of
       [] -> Right ()
       (n,as):_ -> Left $ "arity conflict on '" ++ n ++ "': " ++ show as

checkRangeRestricted :: Program -> Verify ()
checkRangeRestricted p =
  let violations =
        [ (i, S.toList (hv S.\\ bv))
        | (i, Clause h b) <- zip [0 ..] p
        , let hv = atomVars h, let bv = S.unions (map atomVars b)
        , not (S.null (hv S.\\ bv)) ]
  in case violations of
       [] -> Right ()
       (i,vs):_ -> Left $ "clause " ++ show i ++ " unsafe vars: " ++ show vs

checkDefinedness :: Program -> Verify ()
checkDefinedness p =
  let defined = S.fromList [ n | Clause (Atom n _) _ <- p ]
      used = S.fromList [ n | Clause _ b <- p, Atom n _ <- b ]
      missing = S.toList (used S.\\ defined)
  in if null missing then Right ()
     else Left $ "undefined predicate(s): " ++ show missing

checkDuplicates :: Program -> Verify ()
checkDuplicates p =
  case [ c | (c, n) <- M.toList (foldl' (\m c -> M.insertWith (++) c [0::Int] m)
                                      M.empty p), length n > 1 ] of
    [] -> Right ()
    c:_ -> Left $ "duplicate clause: " ++ show c

verify :: Program -> Verify Program
verify p = do
  checkNodeIds p
  checkArities p
  checkRangeRestricted p
  checkDefinedness p
  checkDuplicates p
  return p

emitIR :: Program -> String
emitIR p = unlines $
  [ "RULES " ++ show (length p) ] ++
  [ "RULE " ++ show i
    ++ " HEAD " ++ atomIR h
    ++ " BODY [" ++ commaSep (map atomIR b) ++ "]"
  | (i, Clause h b) <- zip [0 ..] p ]
  where
    atomIR (Atom n ts) = n ++ "(" ++ commaSep (map termIR ts) ++ ")"
    termIR (Var v) = "?" ++ v
    termIR (App f _) = f
    commaSep [] = ""
    commaSep [x] = x
    commaSep (x:xs) = x ++ "," ++ commaSep xs

main :: IO ()
main = case verify program of
  Left err -> putStrLn ("VERIFICATION FAILED: " ++ err)
  Right prog -> putStr (emitIR prog)
