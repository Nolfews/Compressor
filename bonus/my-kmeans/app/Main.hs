{-
-- EPITECH PROJECT, 2025
-- B-FUN-400-NAN-4-1-compressor-carlos.so-buaro
-- File description:
-- boostrap
-}

import Data.Maybe (mapMaybe)
import Data.List (minimumBy, delete, sortOn, lines, foldl')
import Data.Ord (comparing)
import Codec.Picture
import System.IO (writeFile, readFile)
import Text.Read (readMaybe)
import Data.Word (Word8)
import Control.Exception (catch, SomeException)
import Control.Concurrent (threadDelay)
import Text.Parsec
import Text.Parsec.String (Parser)
import qualified Data.Map as Map

distance :: (Double, Double, Double) -> (Double, Double, Double) -> Double
distance (x1, y1, z1) (x2, y2, z2) = sqrt ((x2 - x1) ** 2 + (y2 - y1) ** 2 + (z2 - z1) ** 2)

closest :: [(Double, Double, Double)] -> (Double, Double, Double) -> (Double, Double, Double)
closest list target = minimumBy (comparing (distance target)) list

sumDistances :: [(Double, Double, Double)] -> (Double, Double, Double) -> Double
sumDistances list v = sum [distance v p | p <- list, p /= v]

removeOutliers :: [(Double, Double, Double)] -> [(Double, Double, Double)]
removeOutliers list =
    let sorted = reverse $ sortOn (sumDistances list) list
    in foldl' (\acc v -> delete v acc) list (take 5 sorted)

extractAndSavePixels :: FilePath -> FilePath -> IO ()
extractAndSavePixels inputPath outputPath = do
    img <- readImage inputPath
    case img of
        Left err -> putStrLn ("Erreur : " ++ err)
        Right dynImg -> do
            let imgRGB8 = convertRGB8 dynImg
            let width = imageWidth imgRGB8
            let height = imageHeight imgRGB8
            writeFile outputPath $ unlines $
                [ show (x, y, pixelAt imgRGB8 x y) | x <- [0..width-1], y <- [0..height-1]]
            putStrLn $ "Pixels enregistrés dans " ++ outputPath

sortPixels :: Image PixelRGB8 -> Image PixelRGB8
sortPixels img =
    let pixels = [pixelAt img x y | y <- [0..imageHeight img-1], x <- [0..imageWidth img-1]]
        sortedPixels = sortOn (\(PixelRGB8 r _ _) -> r) pixels
        imgSorted = generateImage (\x y -> sortedPixels !! (y * imageWidth img + x)) (imageWidth img) (imageHeight img)
    in imgSorted

recreateImageOptimized :: FilePath -> FilePath -> IO ()
recreateImageOptimized inputPath outputPath = do
    putStrLn "Début de la lecture du fichier..."
    contents <- readFile inputPath
    let pixels = mapMaybe parsePixel (lines contents)

    let (width, height) = foldl' (\(maxX, maxY) (x, y, _) -> (max maxX x, max maxY y)) (0, 0) pixels
    putStrLn $ "Dimensions de l'image calculées : " ++ show (width + 1, height + 1)
    putStrLn $ "Nombre total de pixels à traiter : " ++ show ((width + 1) * (height + 1))

    let pixelMap = Map.fromList [((x, y), (r, g, b)) | (x, y, (r, g, b)) <- pixels]
    putStrLn "Reconstruction de l'image..."

    let img = generateImage
                (\x y -> case Map.lookup (x, y) pixelMap of
                           Just (r, g, b) -> PixelRGB8 (fromIntegral r) (fromIntegral g) (fromIntegral b)
                           Nothing -> PixelRGB8 0 0 0)
                (width + 1) (height + 1)
    
    putStrLn "Image reconstruite, sauvegarde de l'image..."
    savePngImage outputPath (ImageRGB8 img)
    putStrLn $ "Image sauvegardée sous " ++ outputPath

parsePixel :: String -> Maybe (Int, Int, (Int, Int, Int))
parsePixel str = case parse pixelParser "" str of
    Left _  -> Nothing
    Right p -> Just p

pixelParser :: Parser (Int, Int, (Int, Int, Int))
pixelParser = do
    _ <- char '('
    x <- read <$> many1 digit
    _ <- char ','
    y <- read <$> many1 digit
    _ <- string ",PixelRGB8 "
    r <- read <$> many1 digit
    _ <- char ' '
    g <- read <$> many1 digit
    _ <- char ' '
    b <- read <$> many1 digit
    _ <- char ')'
    return (x, y, (r, g, b))

generateAndSaveImage :: String -> String -> IO ()
generateAndSaveImage inputPath outputPath = do
  let width = 100
      height = 100
      image = generateImage (\x y -> PixelRGB8 (fromIntegral x) (fromIntegral y) 128) width height
  writePng outputPath image

invertColors :: Image PixelRGB8 -> Image PixelRGB8
invertColors img = generateImage invertPixel (imageWidth img) (imageHeight img)
  where
    invertPixel x y =
        let (PixelRGB8 r g b) = pixelAt img x y
        in PixelRGB8 (255 - r) (255 - g) (255 - b)

createPixelsFile :: FilePath -> FilePath -> IO ()
createPixelsFile inputPath outputPath = do
    img <- readImage inputPath
    case img of
        Left err -> putStrLn ("Erreur lors de la lecture de l'image : " ++ err)
        Right dynImg -> do
            let imgRGB8 = convertRGB8 dynImg
            savePngImage outputPath (ImageRGB8 imgRGB8)
            putStrLn $ "Image sauvegardée sous " ++ outputPath

modifyImage :: FilePath -> IO ()
modifyImage inputPath = do
    img <- readImage inputPath
    case img of
        Left err -> putStrLn ("Erreur lors de la lecture de l'image : " ++ err)
        Right dynImg -> do
            let imgRGB8 = convertRGB8 dynImg
            let invertedImg = invertColors imgRGB8
            savePngImage inputPath (ImageRGB8 invertedImg)
            putStrLn $ "Image modifiée et sauvegardée sous " ++ inputPath

duplicateImage :: FilePath -> FilePath -> IO ()
duplicateImage inputPath outputPath = do
    img <- readImage inputPath
    case img of
        Left err -> putStrLn ("Erreur lors de la lecture de l'image : " ++ err)
        Right dynImg -> do
            let imgRGB8 = convertRGB8 dynImg
            savePngImage outputPath (ImageRGB8 imgRGB8)
            putStrLn $ "Image dupliquée sous " ++ outputPath

main :: IO ()
main = do
    let baseImagePath = "chat2.jpg"
    let pixelsFilePath = "chat2_modifier.png"
    let duplicatedImagePath = "chat2_dupliquer.png"

    createPixelsFile baseImagePath pixelsFilePath
    duplicateImage pixelsFilePath duplicatedImagePath
    modifyImage pixelsFilePath
