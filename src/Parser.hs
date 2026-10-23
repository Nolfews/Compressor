{-
-- EPITECH PROJECT, 2025
-- image_compressor
-- File description:
-- Parser
-}

module Parser (
    parseFile
) where

import Types (Point, Color, Pixel)

parseFile :: FilePath -> IO (Either String [Pixel])
parseFile path = do
    content <- readFile path
    return $ parsePixels content

parsePixels :: String -> Either String [Pixel]
parsePixels str =
    let fileLines = filter (not . null) $ lines str
        results = map parseLine fileLines
        errors = [err | Left err <- results]
        pixels = [pixel | Right pixel <- results]
    in if null errors
       then Right pixels
       else Left $ "Errors encountered: " ++ unlines errors

parseLine :: String -> Either String Pixel
parseLine line =
    case words line of
        (pointStr:colorStr:_) -> (,)
            <$> parsePoint pointStr
            <*> parseColor colorStr
        _ -> Left $ "Invalid line format: " ++ line

parsePoint :: String -> Either String Point
parsePoint str =
    case reads str :: [(Point, String)] of
        [(point, "")] -> Right point
        _ -> Left $ "Invalid point format: " ++
            str ++ ". Expected format: (x,y)"

parseColor :: String -> Either String Color
parseColor str =
    case reads str :: [(Color, String)] of
        [(color, "")] -> validateColor color
        _ -> Left $ "Invalid color format: " ++
            str ++ ". Expected format: (r,g,b)"

validateColor :: Color -> Either String Color
validateColor c@(r, g, b)
    | all (\x -> x >= 0 && x <= 255) [r, g, b] = Right c
    | otherwise = Left $ "Color components must be between 0 and 255: " ++
        show c
