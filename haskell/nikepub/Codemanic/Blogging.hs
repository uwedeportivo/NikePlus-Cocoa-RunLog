--------------------------------------------------------------------
-- |
-- Module    : Codemanic.Blogging
-- Copyright : (c) Uwe Hoffmann 2009
-- License   : LGPL
--
-- Maintainer: Uwe Hoffmann <uwe@codemanic.com>
-- Stability : provisional
-- Portability: portable
--
-- Publishing to a blog supporting XML-RPC metaWeblog.newPost.
--
--------------------------------------------------------------------

module Codemanic.Blogging
(
 Blog(..),
 BlogEntry(..),
 publish
)
where

import Data.Time
import Data.Time.LocalTime
import Data.Time.Clock
import Data.Time.Clock.POSIX
import Data.Time.Format
import System.Locale
import System.Time
import Text.Printf
import Text.Regex
import Data.Maybe
import Data.Map (Map)
import qualified Data.Map as Map
import Network.XmlRpc.Client
import Network.XmlRpc.Internals

data Blog = Blog {
  url :: String,
  user :: String,
  password :: String,
  blogId :: Int
} deriving (Eq,Show)

data BlogEntry = BlogEntry {
  title :: String,
  body :: String,
  keywords :: [String],
  publishTime :: UTCTime,
  draft :: Bool
} deriving (Eq,Show)

publishMT :: String -> Int -> String -> String -> [(String, Value)] -> Bool -> IO Value
publishMT url = remote url "metaWeblog.newPost"

blogPost :: BlogEntry -> TimeZone -> [(String, Value)]
blogPost blogEntry timeZone =
  ("title", ValueString $ title blogEntry) :
  ("description", ValueString $ body blogEntry) :
  ("dateCreated", ValueDateTime (utcToLocalTime timeZone (publishTime blogEntry))) :
  ("mt_allow_comments", ValueBool False) :
  ("mt_allow_pings", ValueBool False) :
  ("mt_convert_breaks", ValueBool True) :
  ("mt_keywords", ValueString (foldl1 (\x y -> x ++ "," ++ y) (keywords blogEntry))) :
  ("categories", ValueArray (map ValueString (keywords blogEntry))) : []   

publish :: Blog -> BlogEntry -> IO ()
publish blog blogEntry = do
  timeZone <- getCurrentTimeZone
  putStrLn $ "publishing blog entry " ++ (show blogEntry)
  rv <- publishMT (url blog) (blogId blog) (user blog) 
            (password blog) (blogPost blogEntry timeZone) (not $ draft blogEntry)
  putStrLn "done publishing to blog" 
  return ()
  

