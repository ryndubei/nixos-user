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

type AppId = String

getLibraryfoldersPath :: IO FilePath
getLibraryfoldersPath =
  (</>) <$> getHomeDirectory <*> pure ".var/app/com.valvesoftware.Steam/data/Steam/steamapps/libraryfolders.vdf"

unkv :: KeyValue -> (String, Either String [KeyValue])
unkv (KeyValue k v) = (k, v)

main :: IO ()
main = do
  appIds <- getArgs
  libraryfoldersPath <- getLibraryfoldersPath
  appIdLibraries <-
    maybe (fail $ libraryfoldersPath ++ ": unexpected structure") pure . readLibraryfolders =<< tryParseVdf libraryfoldersPath
  paths <- fmap catMaybes . for appIds $ \a ->
    handle (\(e :: IOError) -> hPutStrLn stderr (displayException e) >> pure Nothing) $ do
      library <- maybe (fail $ "no library for " ++ a) pure $ Map.lookup a appIdLibraries
      let path_compatdata = library </> "steamapps/compatdata" </> a
      path_common <- obtainInstalldir library a
      doesDirectoryExist path_compatdata >>= \b ->
        unless b $
          fail $
            "Failed to find compatdata for appid " ++ a ++ ": directory DNE " ++ path_compatdata
      doesDirectoryExist path_common >>= \b ->
        unless b $
          fail $
            "Failed to find common for appid " ++ a ++ ": directory DNE " ++ path_common
      pure $ Just (path_compatdata, path_common)
  mapM_ (putStrLn . escapeString) $ concatMap (\(a, b) -> [a, b]) paths

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
  appManifest = library </> "steamapps/appmanifest_" ++ appid ++ ".acf"

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
    appIds <- fmap (map (fst . unkv)) (lookup "apps" l' >>= unRight)
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
