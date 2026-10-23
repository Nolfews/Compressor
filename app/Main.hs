{-
-- EPITECH PROJECT, 2025
-- image_compressor
-- File description:
-- Main
-}

module Main (main) where

import CLI (Options(..), getOptions, processPixels)
import Parser (parseFile)
import System.Exit (exitWith, ExitCode(..))

main :: IO ()
main = do
    options <- getOptions
    result <- parseFile (optInputFile options)
    case result of
        Left err -> 
            putStrLn ("Failed to load pixels: " ++ err)
            >> exitWith (ExitFailure 84)
        Right pixels -> processPixels options pixels
