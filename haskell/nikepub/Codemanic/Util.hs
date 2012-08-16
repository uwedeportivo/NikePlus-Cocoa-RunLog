{-# LANGUAGE Arrows, NoMonomorphismRestriction, DeriveDataTypeable #-}
--------------------------------------------------------------------
-- |
-- Module    : Codemanic.Util
-- Copyright : (c) Uwe Hoffmann 2009
-- License   : LGPL
--
-- Maintainer: Uwe Hoffmann <uwe@codemanic.com>
-- Stability : provisional
-- Portability: portable
--
-- Small utility functions shared between other modules of nikepub.
--
--------------------------------------------------------------------

module Codemanic.Util
(
 getHttpResponse,
 atTag,
 text,
 textAtTag,
 parseXML,
 fromJSONRational,
 fromJSONObject
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
import Text.XML.HXT.Arrow
import Text.JSON
import Text.JSON.String
import Text.JSON.Types
import Network.URI
import Network.HTTP
import Data.Generics
import Data.Maybe

getHttpResponse :: URI -> IO String
getHttpResponse uri = do
  eresp <- simpleHTTP (Request uri GET [] "")
  case eresp of
    Left _    -> ioError . userError $ "Failed to get " ++ show uri
    Right res -> return $ rspBody res

atTag tag = deep (isElem >>> hasName tag)
text = getChildren >>> getText
textAtTag tag = atTag tag >>> text

parseXML doc = readString [(a_validate,v_0)] doc

fromJSONRational :: JSValue -> Int
fromJSONRational (JSRational _ n) = fromInteger . round $ n

fromJSONObject :: JSValue -> [(String,JSValue)]
fromJSONObject (JSObject o) = fromJSObject o

