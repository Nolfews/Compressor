{-
-- EPITECH PROJECT, 2025
-- image_compressor
-- File description:
-- Output
-}

module Output (formatClusters) where

import Types (Pixel, Color, Centroid)
import Data.List (intercalate)

formatCluster :: [(Pixel, Color)] -> Centroid -> String
formatCluster [] _ = ""
formatCluster cluster centroid =
    let header = "--\n" ++ formatColor centroid ++ "\n-"
        body = concatMap (\(pixel, color) -> "\n"
            ++ formatPoint (fst pixel) ++ " " ++ formatColor color) cluster
    in header ++ body

formatClusters :: [[(Pixel, Color)]] -> [Centroid] -> String
formatClusters clusters centroids =
    intercalate "\n" $ filter (not . null)
    $ zipWith formatCluster clusters centroids

formatPoint :: (Int, Int) -> String
formatPoint (x, y) = "(" ++ show x ++ "," ++ show y ++ ")"

formatColor :: (Int, Int, Int) -> String
formatColor (r, g, b) = "(" ++ show r ++ "," ++ show g ++ "," ++ show b ++ ")"