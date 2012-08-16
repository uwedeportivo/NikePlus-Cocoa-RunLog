--------------------------------------------------------------------
-- |
-- Module    : Main
-- Copyright : (c) Uwe Hoffmann 2009
-- License   : LGPL
--
-- Maintainer: Uwe Hoffmann <uwe@codemanic.com>
-- Stability : provisional
-- Portability: portable
--
-- Main module for nikepub executable.
--
--------------------------------------------------------------------

module Main (main)
where

import Codemanic.NikeRuns
import Codemanic.Blogging
import Codemanic.Weather
import System.Console.GetOpt
import System
import IO
import Control.Monad
import Data.Maybe
import Data.Time.Clock
import Data.Time.Calendar
import Web.Twitter.Fetch
import Web.Twitter.Monad
import System.Environment

data Options = Options {
  nikeId :: Int,
  templateDir :: String,
  mtUser :: Maybe String,
  mtPassword :: Maybe FilePath,
  mtUrl :: Maybe String,
  mtBlogId :: Int,
  twitterUser :: Maybe String,
  twitterPassword :: Maybe FilePath,
  message :: Maybe String,
  airport :: Maybe String,
  draft :: Bool
} deriving (Eq, Show)

defaultOptions :: Options
defaultOptions = Options {
  nikeId = 0,
  templateDir = "",
  mtUser = Nothing,
  mtPassword = Nothing,
  mtUrl = Nothing,
  mtBlogId = 1,
  twitterUser = Nothing,
  twitterPassword = Nothing,
  message = Nothing,
  airport = Nothing,
  Main.draft = False
}

options :: [ OptDescr (Options -> IO Options) ]
options = 
  [ Option "" ["templates"]
        (ReqArg
            (\arg opt -> return opt { templateDir = arg })
            "DIR")
        "template directory"
 
    , Option "u" ["id"]
        (ReqArg
            (\arg opt -> return opt { nikeId = (read arg) })
            "INT")
        "nike+ user id"

    , Option "" ["mtUser"]
        (ReqArg
            (\arg opt -> return opt { mtUser = Just arg })
            "STRING")
        "mt user"

    , Option "" ["mtPassword"]
        (ReqArg
            (\arg opt -> return opt { mtPassword = Just arg })
            "FILEPATH")
        "mt password file"

    , Option "" ["mtUrl"]
        (ReqArg
            (\arg opt -> return opt { mtUrl = Just arg })
            "STRING")
        "mt url"

    , Option "" ["mtBlogId"]
        (ReqArg
            (\arg opt -> return opt { mtBlogId = (read arg) })
            "INT")
        "mt blog id"

    , Option "" ["twitterUser"]
        (ReqArg
            (\arg opt -> return opt { twitterUser = Just arg })
            "STRING")
        "twitter user"

    , Option "" ["twitterPassword"]
        (ReqArg
            (\arg opt -> return opt { twitterPassword = Just arg })
            "FILEPATH")
        "twitter password file"

    , Option "m" ["message"]
        (ReqArg
            (\arg opt -> return opt { message = Just arg })
            "STRING")
        "message"
 
    , Option "" ["draft"]
        (NoArg
            (\opt -> return opt { Main.draft = True }))
        "Send as draft to blog"

    , Option "" ["airport"]
        (ReqArg
            (\arg opt -> return opt { airport = Just arg })
            "STRING")
        "airport code of most nearest airport to fetch weather at run time, \
         \current weather is fetched iff nikepub is executed within 30 min of run end time"

    , Option "v" ["version"]
        (NoArg
            (\_ -> do
                hPutStrLn stderr "Version 1.1"
                exitWith ExitSuccess))
        "Print version"
 
    , Option "h" ["help"]
        (NoArg
            (\_ -> do
    	        prg <- getProgName
                hPutStrLn stderr (usageInfo prg options)
                exitWith ExitSuccess))
        "Show help"
    ]

nikepubOpts :: [String] -> IO Options
nikepubOpts args = do
    case getOpt RequireOrder options args of
      (o,n,[]  ) -> foldl (>>=) (return defaultOptions) o
      (_,_,errs) -> ioError (userError (concat errs ++ usageInfo header options))
  where header = "Usage: nikepub [OPTION...]"

getWeather :: NikeRun -> Options -> IO (Maybe Weather)
getWeather nr opts = do
  case (airport opts) of
    Just airportCode -> do
      currentTime <- getCurrentTime
      let runStartTime = (startTime nr)
      if (((utctDay currentTime) == (utctDay runStartTime)) &&
            ((utctDayTime currentTime) < ((utctDayTime runStartTime) + (secondsToDiffTime 5400))))
        then (getCurrentWeather airportCode) else (return Nothing)
    Nothing -> return Nothing

tweet :: NikeRun -> Options -> IO ()
tweet nr opts = do
  case ((twitterUser opts), (Main.draft opts)) of
    (Just twu, False) -> do
      let msg = fromMaybe "" (message opts)
      wtr <- getWeather nr opts
      twitterMsg <- renderNikeRun (templateDir opts) "twitter_status" nr msg wtr
      twitterPswd <- readFile (fromJust $ twitterPassword opts)
      putStrLn $ "tweeting update " ++ twitterMsg
      runTM (AuthUser twu twitterPswd)
        $ postMethod
        $ restCall "update.json" (arg "status" twitterMsg [])
      putStrLn "done tweeting"
      return ()
    (Nothing, _) -> return ()
    (_, True) -> return ()
 
blog :: NikeRun -> Options -> IO ()
blog nr opts = do
  case (mtUrl opts) of 
    Just u -> do
      let msg = fromMaybe "" (message opts)
      wtr <- getWeather nr opts
      mtTitle <- renderNikeRun (templateDir opts) "mt_title" nr msg wtr
      mtBody  <- renderNikeRun (templateDir opts) "mt_body" nr msg wtr
      mtPswd <- readFile (fromJust $ mtPassword opts)
      let blogEntry = BlogEntry {
         title = mtTitle,
         body = mtBody,
         keywords = ["running"],
         Codemanic.Blogging.draft = (Main.draft opts),
         publishTime = (startTime nr) }
      let blog = Blog {
         url = u,
         user = (fromJust $ mtUser opts),
         password = mtPswd,         
         blogId = (mtBlogId opts)}
      publish blog blogEntry
    Nothing  -> return ()
  
main :: IO ()
main = do
  args <- getArgs
  opts <- nikepubOpts args
  let userId = (nikeId opts)
  putStrLn $ "fetching most recent run for nike user " ++ (show userId)
  runId <- getMostRecentNikeRunId userId
  putStrLn $ "fetching run " ++ (show runId)
  nr <- getNikeRun userId runId
  blog nr opts
  tweet nr opts
