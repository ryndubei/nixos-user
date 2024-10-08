{-# LANGUAGE RecordWildCards #-}

-- base
import Control.Exception
import Control.Monad
import Data.List (intercalate)
import Data.Maybe
import Data.Traversable
import System.Environment
import System.IO
import Text.ParserCombinators.ReadP

-- containers
import Data.Map.Strict (Map)
import Data.Map.Strict qualified as Map

-- directory
import System.Directory

-- filepath
import System.FilePath

newtype AppId = AppId { appIdString :: String }
  deriving (Eq, Ord)

unkv :: KeyValue -> (String, Either String [KeyValue])
unkv (KeyValue k v) = (k, v)

data App = App
  { appid :: AppId,
    appname :: String
  }

displayApp :: App -> String
displayApp App {..} = appIdString appid ++ " (" ++ appname ++ ")"

{- | Given the path to libraryfolders.vdf and the Steam appids to search for,
prints a list of compatdata (Proton prefixes) and install directories to stdout
for the app ids that have them.

These directories are where we expect to find steam_api.dll and steam_api64.dll.
-}
main :: IO ()
main = do
  (libraryfoldersPath:otherArgs) <- getArgs
  apps <- either fail pure $ parseOtherArgs otherArgs
  appIdLibraries <-
    maybe (fail $ libraryfoldersPath ++ ": unexpected structure") pure . readLibraryfolders =<< tryParseVdf libraryfoldersPath
  paths <- fmap catMaybes . for apps $ \a@App{appid, appname} ->
    handle (\(e :: IOError) -> hPutStrLn stderr (displayException e) >> pure Nothing) $ do
      library <- maybe (fail $ "no library for " ++ displayApp a) pure $ Map.lookup appid appIdLibraries
      let path_compatdata = library </> "steamapps/compatdata" </> appIdString appid
      path_common <- obtainInstalldir library appid
      doesDirectoryExist path_compatdata >>= \b ->
        unless b $
          fail $
            "Failed to find compatdata for app " ++ displayApp a ++ ": directory DNE " ++ path_compatdata
      doesDirectoryExist path_common >>= \b ->
        unless b $
          fail $
            "Failed to find common for app " ++ displayApp a ++ ": directory DNE " ++ path_common
      hPutStrLn stderr $ "Found compatdata and common for app " ++ displayApp a
      pure $ Just (path_compatdata, path_common)
  mapM_ (putStrLn . escapeString) $ concatMap (\(a, b) -> [a, b]) paths
  where
    parseOtherArgs [] = pure []
    parseOtherArgs (appid1:appname:rest) = do
      let appid = AppId appid1
      rest' <- parseOtherArgs rest
      pure $ App { appid, appname } : rest'
    parseOtherArgs _ = Left "odd number of other args"

escapeString :: String -> String
escapeString = init . tail . show

-- | Given the library root path, find the install directory of an app id
obtainInstalldir :: FilePath -> AppId -> IO FilePath
obtainInstalldir library appid = do
  (KeyValue _ am) <- tryParseVdf appManifest
  let r = do
        kvs <- map unkv <$> unRight am
        installdir <- lookup "installdir" kvs >>= unLeft
        pure $ library </> "steamapps/common" </> installdir
  maybe (fail $ "bad appmanifest " ++ appManifest) pure r
 where
  appManifest = library </> "steamapps/appmanifest_" ++ appIdString appid ++ ".acf"

unRight :: Either a b -> Maybe b
unRight = either (const Nothing) Just

unLeft :: Either a b -> Maybe a
unLeft = either Just (const Nothing)

tryParseVdf :: FilePath -> IO KeyValue
tryParseVdf p = readFile' p >>= either (fail . ((p ++ ": Parse fail: ") ++) . show) pure . readVdf

readLibraryfolders :: KeyValue -> Maybe (Map AppId FilePath)
readLibraryfolders (KeyValue _ v) = do
  libraries <- unRight v
  appIdLibraries <- fmap concat . for libraries $ \(KeyValue _ l) -> do
    l' <- map unkv <$> unRight l
    path <- lookup "path" l' >>= unLeft
    appIds <- fmap (map (AppId . fst . unkv)) (lookup "apps" l' >>= unRight)
    pure $ map (,path) appIds
  pure $ Map.fromList appIdLibraries

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
