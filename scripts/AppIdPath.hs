{-# LANGUAGE LambdaCase #-}

import Text.ParserCombinators.ReadP
import System.Environment
import Data.Foldable
import qualified Data.Map.Strict as Map
import Data.Map.Strict (Map)
import Control.Monad.Trans.State.Strict
import System.IO
import System.FilePath
import System.Directory
import Data.List (intercalate)
import Data.Traversable
import Data.Maybe
import Control.Monad

getLibraryfoldersPath :: IO FilePath
getLibraryfoldersPath =
  (</>) <$> getHomeDirectory <*> pure ".var/app/com.valvesoftware.Steam/data/Steam/steamapps/libraryfolders.vdf"

unkv :: KeyValue -> (String, Either String [KeyValue])
unkv (KeyValue k v) = (k, v)

main :: IO ()
main = do
  appIds <- getArgs
  libraryfoldersPath <- getLibraryfoldersPath
  (KeyValue _ x) <- either (fail . ((libraryfoldersPath ++ ": Parse fail: ") ++) . show) pure 
                  . readVdf 
                =<< readFile' libraryfoldersPath
  libraryfolders <- either (fail . ((libraryfoldersPath ++ ": unexpected format") ++) . show) pure x
  let -- TODO: refactor without state monad (wrote this on 3.5 hrs sleep)
      appidPaths :: Map String FilePath
      appidPaths = flip execState mempty . for_ libraryfolders $ \case
        KeyValue k (Right vs) ->
          let vs' = Map.fromList $ map unkv vs
              lk s = Map.lookup s vs'
           in case (,) <$> lk "path" <*> lk "apps" of
            Just (Left path, Right apps) -> mapM_ (\(KeyValue a _) ->
              modify' (Map.insert a path)) apps
            _ -> pure ()
        _ -> pure ()
  paths <- fmap catMaybes . for appIds $ \a ->
    let p = Map.lookup a appidPaths
     in do
      let p' = (</> "compatdata" </> a) <$> p
      b <- maybe (pure False) doesDirectoryExist p'
      unless b $ hPutStrLn stderr ("no directory for appid " ++ a)
      pure $ if b then p' else Nothing
  putStr $ unwords (map show paths)

--------------------------------------------------------------------------------
-- VDF parser
--------------------------------------------------------------------------------

-- | Entry of a Steam .acf or .vdf file
data KeyValue = KeyValue String (Either String [KeyValue])
  deriving (Eq, Show)

data ParseFailReason = NoParse | AmbiguousParse deriving (Eq, Show)

{- | Convert a String representing a Steam .acf or .vdf file into
a KeyValue. Returns Left on parse fail.

Note: does not handle comments, which IIRC KeyValues supports.
-}
readVdf :: String -> Either ParseFailReason KeyValue
readVdf = parse parseEntry

parse :: ReadP a -> String -> Either ParseFailReason a
parse m s = getOnlyParse [result | (result, remainder) <- readP_to_S m s, remainder == ""]
 where
  getOnlyParse [] = Left NoParse
  getOnlyParse [x] = Right x
  getOnlyParse _ = Left AmbiguousParse

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
