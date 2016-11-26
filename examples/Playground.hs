-- | Testing module to play with logging.

module Main where

import           Control.Exception (bracket_)

import           Data.Monoid       ((<>))
import qualified Data.Text         as T (pack)
import           System.Log.Logger (removeAllHandlers)

import           System.Wlog       (CanLog, dispatchEvents, initLoggingFromYaml, logDebug,
                                    logError, logInfo, logNotice, logWarning,
                                    modifyLoggerName, runPureLog, usingLoggerName)

testLogging :: CanLog m => m ()
testLogging = usingLoggerName "node" $ do
    logDebug   "skovoroda"
    logInfo    "patak"
    logNotice  "boroda"
    logWarning "haha"

    modifyLoggerName (<> "server") $ do
        logDebug  "provoda"
        logNotice "Ggurda"

    logError   "BARDAQ"

showPureLog :: IO ()
showPureLog = do
    (res, pureLog) <- runPureLog testLogging
    putStrLn "Pure log:"
    usingLoggerName "naked" $ do
        logWarning $ "Pure log for result = " <> (T.pack $ show res) <> ":"
        dispatchEvents pureLog

main :: IO ()
main = bracket_
           (initLoggingFromYaml "logger-config-example.yaml" $ Just "logs")
           removeAllHandlers
           (testLogging >> showPureLog)