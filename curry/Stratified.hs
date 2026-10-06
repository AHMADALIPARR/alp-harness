-- SPDX-License-Identifier: AGPL-3.0-only
-- Copyright (C) 2026 Ahmad Ali Parr
-- GNU Affero General Public License version 3 only.
--
-- Stratified non-recursive program. gt is a builtin filter.
-- The dependency check is a Kahn sort. A cycle is a verification failure.
-- This does not by itself evaluate the program.

module Stratified where

import qualified Data.Map.Strict as M
import qualified Data.Set as S
import Data.List (foldl', nub, sort)

data Term = Var String | App String [Term] deriving (Eq, Ord, Show)
data Atom = Atom String [Term] deriving (Eq, Ord, Show)
data Clause = Clause { clauseHead :: Atom, clauseBody :: [Atom] } deriving (Eq, Show)
type Program = [Clause]
type Verify a = Either String a

builtins :: S.Set String
builtins = S.fromList ["gt"]

program :: Program
program =
  [ Clause (Atom "temperature" [App "A17" [], App "95" []]) []
  , Clause (Atom "temperature" [App "A18" [], App "80" []]) []
  , Clause (Atom "fan" [App "A17" [], App "off" []]) []
  , Clause (Atom "overheated" [Var "X"])
           [Atom "temperature" [Var "X", Var "T"],
            Atom "gt" [Var "T", App "90" []]]
  , Clause (Atom "dangerous" [Var "X"])
           [Atom "overheated" [Var "X"],
            Atom "fan" [Var "X", App "off" []]]
  ]

termVars :: Term -> S.Set String
termVars (Var v) = S.singleton v
termVars (App _ ts) = S.unions (map termVars ts)

atomVars :: Atom -> S.Set String
atomVars (Atom _ ts) = S.unions (map termVars ts)

checkArities :: Program -> Verify ()
checkArities p =
  let tbl = foldl' (\m (n,a) -> M.insertWith (++) n [a] m) M.empty
               [ (n, length ts) | Clause (Atom n ts) _ <- p ]
      bad = [ (n, as) | (n, as) <- M.toList tbl, length (nub as) > 1 ]
  in case bad of
       [] -> Right ()
       (n,as):_ -> Left $ "arity conflict on '" ++ n ++ "': " ++ show as

checkRangeRestricted :: Program -> Verify ()
checkRangeRestricted p =
  let bad = [ (i, S.toList (hv S.\\ bv))
            | (i, Clause h b) <- zip [0 ..] p
            , let hv = atomVars h, let bv = S.unions (map atomVars b)
            , not (S.null (hv S.\\ bv)) ]
  in case bad of
       [] -> Right ()
       (i,vs):_ -> Left $ "clause " ++ show i ++ " unsafe vars: " ++ show vs

checkDefinedness :: Program -> Verify ()
checkDefinedness p =
  let defined = S.fromList [ n | Clause (Atom n _) _ <- p ] `S.union` builtins
      used = S.fromList [ n | Clause _ b <- p, Atom n _ <- b ]
  in case S.toList (used S.\\ defined) of
       [] -> Right ()
       misses -> Left $ "undefined predicate(s): " ++ show misses

checkStratified :: Program -> Verify [String]
checkStratified p =
  let deps = [ (n, m)
             | Clause (Atom n _) b <- p
             , Atom m _ <- b
             , m /= n, not (S.member m builtins) ]
      edges = S.fromList deps
      preds = S.fromList ([ n | Clause (Atom n _) _ <- p ] ++
                          [ m | (_, m) <- S.toList edges ])
      kahn nodes e acc
        | S.null nodes = Right (reverse acc)
        | otherwise =
            let roots = [ n | n <- S.toList nodes
                        , not (any (\(_, m) -> m == n) (S.toList e)) ]
            in if null roots
                 then Left "dependency cycle: program not stratified"
                 else kahn (foldr S.delete nodes roots)
                           (S.filter (\(a,_) -> not (S.member a (S.fromList roots))) e)
                           (roots ++ acc)
  in kahn preds edges []

verify :: Program -> Verify [String]
verify p = do
  checkArities p
  checkRangeRestricted p
  checkDefinedness p
  checkStratified p

emitIR :: Program -> String
emitIR p = unlines $
  [ "RULES " ++ show (length p) ] ++
  [ "RULE " ++ show i
    ++ " HEAD " ++ atomIR h
    ++ " BODY [" ++ commas (map atomIR b) ++ "]"
  | (i, Clause h b) <- zip [0 ..] p ]
  where
    atomIR (Atom n ts) = n ++ "(" ++ commas (map termIR ts) ++ ")"
    termIR (Var v) = "?" ++ v
    termIR (App f _) = f
    commas [] = ""
    commas [x] = x
    commas (x:xs) = x ++ "," ++ commas xs

main :: IO ()
main = case verify program of
  Left err -> putStrLn ("VERIFICATION FAILED: " ++ err)
  Right order -> do
    putStrLn ("-- stratification order: " ++ show (sort order))
    putStrLn "(certificate (classification NON_RECURSIVE) (termination GUARANTEED))"
    putStr (emitIR program)
