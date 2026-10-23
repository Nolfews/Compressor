{-
-- EPITECH PROJECT, 2025
-- image_compressor
-- File description:
-- KMeans
-}

module KMeans (kMeans, calculateCentroid) where

import Data.List (minimumBy)
import Data.Function (on)
import Types (Color, Centroid, Cluster)

kMeans :: Int -> Double -> [Color] -> Either String [Cluster]
kMeans k convergenceLimit points
    | k <= 0 = Left "Number of clusters must be greater than 0."
    | otherwise = Right $ runKMeans initialCentroids points convergenceLimit
  where
    initialCentroids = take k (cycle points)

runKMeans :: [Centroid] -> [Color] -> Double -> [Cluster]
runKMeans centroids points convergenceLimit =
    kMeansIter centroids points convergenceLimit

kMeansIter :: [Centroid] -> [Color] -> Double -> [Cluster]
kMeansIter centroids points convergenceLimit =
    let clusters = assignPointsToClusters centroids points
        newCentroids = map calculateCentroid clusters
        centroidShift =
            maximum $ zipWith computeDistance centroids newCentroids
    in if centroidShift < convergenceLimit
       then clusters
       else kMeansIter newCentroids points convergenceLimit

assignPointsToClusters :: [Centroid] -> [Color] -> [Cluster]
assignPointsToClusters centroids points =
    [[point | point <- points, assign point == centroid]
        | centroid <- centroids]
  where
    assign point = minimumBy (compare `on` (computeDistance point)) centroids

calculateCentroid :: Cluster -> Centroid
calculateCentroid cluster =
    let (rSum, gSum, bSum, count) = foldr (\(r, g, b) (rAcc, gAcc, bAcc, n) ->
            (rAcc + r, gAcc + g, bAcc + b, n + 1)) (0, 0, 0, 0) cluster
    in if count == 0
       then (0, 0, 0)
       else (rSum `div` count, gSum `div` count, bSum `div` count)

computeDistance :: Color -> Color -> Double
computeDistance (r1, g1, b1) (r2, g2, b2) =
    sqrt $ ((fromIntegral (r2 - r1) ** 2)
    + (fromIntegral (g2 - g1) ** 2) + (fromIntegral (b2 - b1) ** 2))