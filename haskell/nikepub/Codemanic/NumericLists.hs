--------------------------------------------------------------------
-- |
-- Module    : Codemanic.NumericLists
-- Copyright : (c) Uwe Hoffmann 2009
-- License   : LGPL
--
-- Maintainer: Uwe Hoffmann <uwe@codemanic.com>
-- Stability : provisional
-- Portability: portable
--
-- Provides useful functions for processing numeric lists.
--
--------------------------------------------------------------------

module Codemanic.NumericLists
(
 correlate,
 convolve,
 gaussianKernel,
 movingAverageKernel,
 scale,
 diff,
 minInList,
 maxInList,
 pad,
 padPeriodic,
 flipInRange
) 
where

kernelOp :: (Num a) => [(a, a)] -> a
kernelOp = (foldr (+) 0) . (map (uncurry (*)))

correlate :: (Num a) => [a] -> [a] -> [a]
correlate ks xs | length xs < length ks  = []
correlate ks xs = kernelOp (zip ks xs) : correlate ks (tail xs)

convolve :: (Num a) => [a] -> [a] -> [a]
convolve ks xs = correlate (reverse ks) xs

gaussianKernel :: (Floating a) => Int -> [a]
gaussianKernel n = 
  map (g . fromIntegral) [(-n)..n]
  where
     y = fromIntegral n
     g x = (exp (-(x^2) / (2 * y^2))) / ((y * sqrt (2 * pi)))

movingAverageKernel :: (Floating a) => Int -> [a]
movingAverageKernel n = take n (repeat (1.0 / (fromIntegral n)))

scale :: (Num a) => a -> [a] -> [a]
scale s xs = map (\x -> x * s) xs

diff :: (Num a) => [a] -> [a]
diff [] = []
diff xs = zipWith (-) (tail xs) xs

minInList :: (Ord a) => [a] -> a
minInList = foldr1 min

maxInList :: (Ord a) => [a] -> a
maxInList = foldr1 max

pad :: (Num a) => Int -> a -> [a] -> [a]
pad n p [] = take n (repeat p)
pad n p xs = xs ++ (take k (repeat p))
             where 
               l = length xs
               k = (n - (l `mod` n)) `mod` n

padPeriodic :: (Num a) => Int -> [a] -> [a]
padPeriodic _ [] = []
padPeriodic n xs = xs ++ (take k (foldr (++) [] (take m (repeat xs))))
                   where
                     l = length xs
                     k = (n - (l `mod` n)) `mod` n
                     m = (k `div` l) + 1 

flipInRange :: (Ord a, Num a) => [a] -> [a]
flipInRange [] = []
flipInRange xs = map (\x -> minV + maxV - x) xs
                 where
                   minV = minInList xs
                   maxV = maxInList xs
