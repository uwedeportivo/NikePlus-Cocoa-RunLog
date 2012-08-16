module Codemanic.StringLists
(
 scorrelate,
 sconvolve,
) 
where

kernelOp :: [(String, String)] -> String
kernelOp = (foldr1 splus) . (map smul)
           where
             smul :: (String, String) -> String
             smul (a, b) = b ++ " * " ++ a
             splus :: String -> String -> String
             splus a b = b ++ " + " ++ a

scorrelate :: [String] -> [String] -> [String]
scorrelate ks xs | length xs < length ks  = []
scorrelate ks xs = kernelOp (zip ks xs) : scorrelate ks (tail xs)

sconvolve :: [String] -> [String] -> [String]
sconvolve ks xs = scorrelate (reverse ks) xs


