{-# LANGUAGE Arrows, NoMonomorphismRestriction, DeriveDataTypeable #-}
--------------------------------------------------------------------
-- |
-- Module    : Codemanic.NikeRuns
-- Copyright : (c) Uwe Hoffmann 2009
-- License   : LGPL
--
-- Maintainer: Uwe Hoffmann <uwe@codemanic.com>
-- Stability : provisional
-- Portability: portable
--
-- Functions to fetch and process Nike+ run data.
--
--------------------------------------------------------------------

module Codemanic.NikeRuns 
(
 chartNikeRun,
 NikeRun(..),
 getNikeRun,
 getMostRecentNikeRunId,
 renderNikeRun
)
where

import Codemanic.NumericLists
import Codemanic.Weather
import Codemanic.Util
import Graphics.Google.Chart
import Data.Time
import Data.Time.LocalTime
import Data.Time.Clock
import Data.Time.Clock.POSIX
import Data.Time.Format
import System.Locale
import System.Time
import Text.Printf
import Text.Regex
import Text.Regex.Posix
import Text.JSON
import Text.JSON.String
import Text.JSON.Types
import Text.XML.HXT.Arrow
import Network.HTTP
import Network.URI
import Text.StringTemplate
import Data.Generics
import Data.Maybe
import System.FilePath

transformAndSmoothRunData :: [Double] -> [Double]
transformAndSmoothRunData  = 
  flipInRange .
  (convolve (gaussianKernel 5)) .
  (correlate (movingAverageKernel 6)) .
  (map (\x -> (1.0 / (6.0 * x)))) . 
  (filter (/=0)) . 
  diff

transformAndAverageRunData :: [Double] -> [Double]
transformAndAverageRunData = 
  flipInRange .
  (correlate (movingAverageKernel 6)) .
  (map (\x -> (1.0 / (6.0 * x)))) . 
  (filter (/=0)) . 
  diff

scaler :: [Double] -> Double -> (Double -> Double)
scaler xs y = (\x -> (x - minV) * y / d)
              where
                minV = minInList xs
                maxV = maxInList xs
                d = maxV - minV

encodeRunData :: [Double] -> ChartData
encodeRunData xs = encodeDataExtended [xs']
                   where
                     sc = scaler xs (fromIntegral 4095)
                     xs' = map (round . sc) xs :: [Int]

sampler :: Int -> Double -> Double -> [Double]
sampler n minV maxV = [(minV + d * (fromIntegral x) / (fromIntegral n)) | x <- [0..n]]
                      where
                        d = maxV - minV

yLabels :: Int -> [Double] -> [String]
yLabels n xs = map (\x -> printf "%.2f" x) (reverse (sampler n (minInList xs) (maxInList xs)))

xLabels :: Int -> [Double] -> [String]
xLabels n xs = map (\x -> printf "%.1f" x)  (sampler n 0.0 duration)
               where
                 duration = (fromIntegral $ length xs) / 6.0

suffix :: String -> (String -> String)
suffix s = (\x -> x ++ s) 

data NikeRun = NikeRun {
  userId :: Int,
  runId :: Int,
  extendedData :: [Double],
  calories :: Double,
  startTime :: UTCTime
} deriving (Eq,Show)

duration :: NikeRun -> Double
duration nr = (10.0 * (fromIntegral (length (extendedData nr)))) / 60.0

distance :: NikeRun -> Double
distance nr = last (extendedData nr)

pace :: NikeRun -> Double
pace nr = (duration nr) / (distance nr) 

chartNikeRun :: Int -> Int -> NikeRun -> String
chartNikeRun w h NikeRun {extendedData = xs, calories = c} = 
  suffix "&chg=25.0,25.0,3,2" $
  chartURL $
  setAxisLabelPositions [[0, 25, 50, 75, 100], [50], [0, 25, 50, 75, 100], [50]] $
  setAxisLabels [(yLabels 4 ylxs), ["pace (min/km)"], (xLabels 4 xs), ["time (min)"]] $
  setAxisTypes [AxisLeft, AxisLeft, AxisBottom, AxisBottom] $
  setSize w h $
  setData (encodeRunData txs) $
  newLineChart
  where
    ylxs = transformAndAverageRunData xs
    txs = transformAndSmoothRunData xs

nikeRunURL :: Int -> Int -> String
nikeRunURL userId runId = 
  "http://nikerunning.nike.com/nikeplus/v1/services/widget/get_public_run.jsp?userID=" ++ (show userId) ++
  "&id=" ++ (show runId)

nikeRunIdsURL :: Int -> String
nikeRunIdsURL userId =
  "http://nikerunning.nike.com/nikeplus/v1/services/app/get_public_user_data.jsp?id=" ++ (show userId)  

retrieveNikeRun :: Int -> Int -> IO String
retrieveNikeRun userId runId = do
  case parseURI (nikeRunURL userId runId) of
    Nothing  -> ioError . userError $ "Invalid URL"
    Just uri -> getHttpResponse uri

retrieveNikeRunIds :: Int -> IO String
retrieveNikeRunIds userId = do
  case parseURI (nikeRunIdsURL userId) of
    Nothing   -> ioError . userError $ "Invalid URL"
    Just uri  -> getHttpResponse uri

readDoubles :: String -> [Double]
readDoubles s = map (\y -> read y::Double) (splitRegex (mkRegex ",") s)

parseNikeRun uId rId = atTag "sportsData" >>>
  proc x -> do
    cs   <- textAtTag "calories" -< x
    exds <- textAtTag "extendedData" -< x
    sts <- textAtTag "startTime" -< x
    returnA -< NikeRun {
        userId = uId,
        runId = rId,
        extendedData = readDoubles exds,
        startTime = readTime defaultTimeLocale "%Y-%m-%dT%H:%M:%S%z" sts,
        calories = read cs }

parseNikeRunId = atTag "mostRecentRun" >>>
  proc x -> do
    runId <- getAttrValue "id" -< x
    returnA -< (read runId)::Int

getNikeRun :: Int -> Int -> IO NikeRun
getNikeRun userId runId = do
  doc <- retrieveNikeRun userId runId
  let xml = parseXML doc
  nikeRuns <- runX (xml >>> (parseNikeRun userId runId))
  case nikeRuns of
    [] -> ioError . userError $ "Failed to parse nike run " ++ show runId
    nr:_ -> return nr

getMostRecentNikeRunId :: Int -> IO Int
getMostRecentNikeRunId userId = do
  doc <- retrieveNikeRunIds userId
  let xml = parseXML doc
  nikeRunIds <- runX (xml >>> parseNikeRunId)
  case nikeRunIds of
    [] -> ioError . userError $ "Failed to parse most recent nike run id " ++ show userId
    id:_ -> return id

parseJSONChartSize :: String -> IO (Int, Int)
parseJSONChartSize jsonOptions =
  case runGetJSON readJSObject jsonOptions of
    Right x -> do
      let jo = fromJSONObject x
      return (getKey "width" jo, getKey "height" jo)
      where
        getKey k j = fromJSONRational $ fromJust $ lookup k j
    Left _ -> return (0, 0)

extractChartSize :: String -> String -> IO (Int, Int)
extractChartSize templates template = do
  let chartOptionsPattern = "\\$\\!chartOptions(\\{.+\\})\\!\\$"
  contents <- readFile (templates </> (addExtension template "st"))
  let (_, _, _, groups) = (contents =~ chartOptionsPattern :: (String, String, String, [String]))
  if ((length groups) > 0) 
    then parseJSONChartSize $ head groups
    else return (0, 0)

renderNikeRun :: String -> String -> NikeRun -> String -> Maybe Weather -> IO String
renderNikeRun templates template nr message weather = do
  dirs <- directoryGroup templates
  (w, h) <- extractChartSize templates template
  let chart = chartNikeRun w h nr
  let tpl = fromJust $ getStringTemplate template dirs
  timeZone <- getCurrentTimeZone
  let localTime = utcToLocalTime timeZone (startTime nr)
  return $ render $ setAttribute "chart" chart $
                    setAttribute "calories" (calories nr) $
                    setAttribute "duration" (renderDouble (duration nr)) $
                    setAttribute "distance" (renderDouble (distance nr)) $
                    setAttribute "pace" (renderDouble (pace nr)) $
                    setAttribute "startTime" (renderTime localTime) $
                    setAttribute "message" message $
                    setAttribute "userId" (userId nr) $
                    setAttribute "runId" (runId nr) $
                    setAttribute "weather" (renderWeather weather) tpl
  where
    renderDouble :: Double -> String
    renderDouble x = (printf "%.2f" x)::String
    renderTime :: LocalTime -> String
    renderTime t = formatTime defaultTimeLocale "%x, %r" t
    renderWeather :: Maybe Weather -> String
    renderWeather (Just weather) = "Temperature " ++ (temperature weather) ++ 
         ", Wind " ++ (wind weather) ++ ", " ++ (humidity weather) ++ " humidity"
    renderWeather Nothing = ""


