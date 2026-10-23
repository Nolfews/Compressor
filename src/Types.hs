{-
-- EPITECH PROJECT, 2025
-- image_compressor
-- File description:
-- Types
-}

module Types (Point, Color, Pixel, Centroid, Cluster) where

type Point = (Int, Int)
type Color = (Int, Int, Int)
type Pixel = (Point, Color)
type Centroid = Color
type Cluster = [Color]
