{-# LANGUAGE LambdaCase #-}
module AppIdPath (main) where

import Vdf.Parser
import System.Environment
import Data.Foldable
import qualified Data.Set as Set
import qualified Data.Map.Strict as Map
import Data.Set (Set)
import Data.Map.Strict (Map)
import Data.List (lookup)

libraryfoldersPath :: FilePath
libraryfoldersPath = "~/.var/app/com.valvesoftware.Steam/data/Steam/steamapps/libraryfolders.vdf"

main :: IO ()
main = do
  appIds <- getArgs
  (KeyValue _ x) <- either (fail . ((libraryfoldersPath ++ ": Parse fail: ") ++) . show) pure 
                  . readVdf 
                =<< readFile libraryfoldersPath
  libraryfolders <- either (fail . ((libraryfoldersPath ++ ": unexpected format") ++) . show) pure x
  let libraries = Map.fromList $ do
        (KeyValue k v) <- libraryfolders
        attrs <- either mempty pure v
        let attrs' = Set.fromList . flip map attrs $ \case
        path <- maybe mempty pure $ undefined
        undefined
  for_ appIds $ putStrLn . undefined
