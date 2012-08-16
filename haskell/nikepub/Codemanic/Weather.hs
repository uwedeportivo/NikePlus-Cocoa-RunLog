{-# LANGUAGE Arrows, NoMonomorphismRestriction, DeriveDataTypeable #-}
--------------------------------------------------------------------
-- |
-- Module    : Codemanic.Weather
-- Copyright : (c) Uwe Hoffmann 2009
-- License   : LGPL
--
-- Maintainer: Uwe Hoffmann <uwe@codemanic.com>
-- Stability : provisional
-- Portability: portable
--
-- Function to fetch current weather given an airport code.
--
--------------------------------------------------------------------

module Codemanic.Weather
(
 Weather(..),
 getCurrentWeather
)
where

import Codemanic.Util
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
import Network.HTTP
import Network.URI
import Data.Generics
import Data.Maybe

data Weather = Weather {
  temperature :: String,
  wind :: String,
  humidity :: String
} deriving (Eq,Show)

weatherURL :: String -> String
weatherURL airportCode = 
  "http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml?query=" ++ airportCode

retrieveWeather :: String -> IO String
retrieveWeather airportCode = do
  case parseURI (weatherURL airportCode) of
    Nothing  -> ioError . userError $ "Invalid URL"
    Just uri -> getHttpResponse uri

parseWeather = atTag "current_observation" >>>
  proc x -> do
    temp   <- textAtTag "temperature_string" -< x
    wnd <- textAtTag "wind_string" -< x
    hum <- textAtTag "relative_humidity" -< x
    returnA -< Weather {
        temperature = temp,
        wind = wnd,
        humidity = hum }

getCurrentWeather :: String -> IO (Maybe Weather)
getCurrentWeather airportCode = do
  doc <- retrieveWeather airportCode 
  let xml = parseXML doc
  ws <- runX (xml >>> parseWeather)
  case ws of
    [] -> return Nothing
    w:_ -> return (Just w)
