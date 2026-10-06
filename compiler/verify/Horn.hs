-- SPDX-License-Identifier: AGPL-3.0-only
-- Copyright (C) 2026 Ahmad Ali Parr
-- GNU Affero General Public License version 3 only.
--
-- Stage 1: Horn clause verification. Haskell 2018, pure.
-- Checks arity, head shape, range restriction, and defined body predicates.

module Horn where

import qualified Data.Map.Strict as M
import qualified Data.Set as S
import Data.List (foldl', nub)

data Term = Var String | App String [Term]
  deriving (Eq, Ord, Show)

data Atom = Atom String [Term]
  deriving (Eq, Ord, Show)

data Clause = Clause { clauseHead :: Atom, clauseBody :: [Atom] }
  deriving (Eq, Show)

type Program = [Clause]

type Verify a = Either String a

termVars :: Term -> S.Set String
termVars (Var v) = S.singleton v
termVars (App _ ts) = S.unions (map termVars ts)

atomVars :: Atom -> S.Set String
atomVars (Atom _ ts) = S.unions (map termVars ts)

checkArities :: Program -> Verify ()
checkArities p =
  let sigs = [ (n, length ts) | Clause (Atom n ts) _ <- p ]
      tbl = foldl' (\m (n,a) -> M.insertWith (++) n [a] m) M.empty sigs
      bad = [ (n, as) | (n, as) <- M.toList tbl, length (nub as) > 1 ]
  in case bad of
       [] -> Right ()
       (n,as):_ -> Left $ "arity conflict on predicate '" ++ n
                      ++ "': arities " ++ show as

checkHeadShape :: Program -> Verify ()
checkHeadShape p =
  case [ () | Clause (Atom n _) _ <- p, null n ] of
    [] -> Right ()
    _ -> Left "empty predicate symbol in clause head"

checkRangeRestricted :: Program -> Verify ()
checkRangeRestricted p =
  let violations =
        [ (i, S.toList (headVars S.\\ bodyVars))
        | (i, Clause h b) <- zip [0::Int ..] p
        , let headVars = atomVars h
        , let bodyVars = S.unions (map atomVars b)
        , not (S.null (headVars S.\\ bodyVars))
        ]
  in case violations of
       [] -> Right ()
       (i,vs):_ -> Left $ "clause " ++ show i
                        ++ " is not range-restricted; unsafe vars: "
                        ++ show vs

checkDefinedness :: Program -> Verify ()
checkDefinedness p =
  let defined = S.fromList [ n | Clause (Atom n _) _ <- p ]
      used = S.fromList [ n | Clause _ b <- p, Atom n _ <- b ]
      missing = S.toList (used S.\\ defined)
  in if null missing
       then Right ()
       else Left $ "undefined predicate(s) in body: " ++ show missing

verify :: Program -> Verify Program
verify p = do
  checkArities p
  checkHeadShape p
  checkRangeRestricted p
  checkDefinedness p
  return p

emitIR :: Program -> String
emitIR p = unlines $
  ["RULES " ++ show (length p)] ++
  [ "RULE " ++ show i
    ++ " HEAD " ++ atomIR h
    ++ " BODY [" ++ commaSep (map atomIR b) ++ "]"
  | (i, Clause h b) <- zip [0::Int ..] p ]
  where
    atomIR (Atom n ts) = n ++ "(" ++ commaSep (map termIR ts) ++ ")"
    termIR (Var v) = "?" ++ v
    termIR (App f ts) = f ++ "(" ++ commaSep (map termIR ts) ++ ")"
    commaSep [] = ""
    commaSep [x] = x
    commaSep (x:xs) = x ++ "," ++ commaSep xs

demo :: Verify String
demo = emitIR <$> verify example
  where
    example =
      [ Clause (Atom "edge" [App "a" [], App "b" []]) []
      , Clause (Atom "edge" [App "b" [], App "c" []]) []
      , Clause (Atom "path" [Var "X", Var "Y"])
               [Atom "edge" [Var "X", Var "Y"]]
      , Clause (Atom "path" [Var "X", Var "Z"])
               [Atom "path" [Var "X", Var "Y"], Atom "edge" [Var "Y", Var "Z"]]
      ]
