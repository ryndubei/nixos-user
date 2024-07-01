module Vdf.Parser (readVdf, KeyValue (..), ParseFailReason (..)) where

import Text.ParserCombinators.ReadP

data ParseFailReason = NoParse | AmbiguousParse deriving (Eq, Show)

parse :: ReadP a -> String -> Either ParseFailReason a
parse m s = getOnlyParse [result | (result, remainder) <- readP_to_S m s, remainder == ""]
 where
  getOnlyParse [] = Left NoParse
  getOnlyParse [x] = Right x
  getOnlyParse _ = Left AmbiguousParse

-- | Entry of a Steam .acf or .vdf file
data KeyValue = KeyValue String (Either String [KeyValue])
  deriving (Eq, Show)

{- | Convert a String representing a Steam .acf or .vdf file into
a KeyValue. Returns Left on parse fail.

Note: does not handle comments, which IIRC KeyValues supports.
-}
readVdf :: String -> Either ParseFailReason KeyValue
readVdf = parse parseEntry

parseEntry :: ReadP KeyValue
parseEntry = do
  skipSpaces
  k <- parseString
  v <- fmap Right parseRecord +++ fmap Left parseString
  skipSpaces
  pure (KeyValue k v)

parseRecord :: ReadP [KeyValue]
parseRecord = between (char '{') (char '}') (skipSpaces >> many parseEntry)

parseString :: ReadP String
parseString = between skipSpaces skipSpaces (readS_to_P readList)
