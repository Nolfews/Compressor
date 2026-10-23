{-
-- EPITECH PROJECT, 2025
-- image_compressor
-- File description:
-- CLI
-}

module CLI (Options(..), getOptions, loadPixels, processPixels) where

import Options.Applicative
import System.Exit (exitWith, ExitCode(ExitFailure))
import System.IO (hPutStrLn, stderr)
import Parser (parseFile)
import KMeans (kMeans, calculateCentroid)
import Types (Pixel, Color, Centroid)
import Output (formatClusters)
import System.Environment (getArgs)

data Options = Options
    { optNumColors :: Int
    , optConvergenceLimit :: Double
    , optInputFile :: FilePath
    }

parseOptions :: Parser Options
parseOptions = Options
    <$> option auto
        ( short 'n' <> metavar "N"
        <> help "number of colors in the final image" )
    <*> option auto
        ( short 'l' <> metavar "L"
        <> help "convergence limit" )
    <*> strOption
        ( short 'f' <> metavar "F"
        <> help "path to the file containing the colors of the pixels" )

getOptions :: IO Options
getOptions = do
    args <- getArgs
    parseArgs args >>= processParseResult

parseArgs :: [String] -> IO (ParserResult Options)
parseArgs args = return $ execParserPure defaultPrefs opts args
  where
    opts = info (parseOptions <**> helper)
        ( fullDesc
        <> progDesc "Compress images by reducing the number of colors"
        <> header "imageCompressor - a pixel color clustering tool" )

processParseResult :: ParserResult Options -> IO Options
processParseResult (Success options) = return options
processParseResult (Failure failure) =
    let (msg, _) = renderFailure failure "imageCompressor"
    in hPutStrLn stderr msg >> exitWith (ExitFailure 84)
processParseResult CompletionInvoked{} = exitWith (ExitFailure 84)

loadPixels :: FilePath -> IO [Pixel]
loadPixels filePath = do
    result <- parseFile filePath
    case result of
        Left err ->
            hPutStrLn stderr ("Error: " ++ err) >> exitWith (ExitFailure 84)
        Right pixels -> return pixels

processPixels :: Options -> [Pixel] -> IO ()
processPixels options pixels =
    let colors = map snd pixels in
    case kMeans (optNumColors options) (optConvergenceLimit options) colors of
        Left err -> handleClusteringError err
        Right clusters -> handleClusteringSuccess pixels clusters

handleClusteringError :: String -> IO ()
handleClusteringError err =
    hPutStrLn stderr ("Error: " ++ err) >> exitWith (ExitFailure 84)

handleClusteringSuccess :: [Pixel] -> [[Color]] -> IO ()
handleClusteringSuccess pixels clusters =
    let centroids = map calculateCentroid clusters
        zippedClusters = zipClusters pixels clusters
    in printFormattedOutput zippedClusters centroids

printFormattedOutput :: [[(Pixel, Color)]] -> [Centroid] -> IO ()
printFormattedOutput zippedClusters centroids =
    let formattedOutput = formatClusters zippedClusters centroids
    in putStrLn formattedOutput

zipClusters :: [Pixel] -> [[Color]] -> [[(Pixel, Color)]]
zipClusters pixels clusters =
    let pixelGroups = groupByCluster pixels clusters
    in zipWith (\pixelsInCluster cluster ->
        zip pixelsInCluster cluster) pixelGroups clusters

groupByCluster :: [Pixel] -> [[Color]] -> [[Pixel]]
groupByCluster pixels clusters =
    map (\cluster -> [p | p@(_, color)
    <- pixels, color `elem` cluster]) clusters
