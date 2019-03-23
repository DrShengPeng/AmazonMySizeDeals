{-# LANGUAGE OverloadedStrings #-}

import Control.Applicative
import Control.Concurrent
import Control.Monad
import qualified Data.ByteString.Lazy.Char8 as Char8
import           Data.Either.Utils
import           Data.List                  as L
import           Data.Maybe
import           Data.Map                   as M
import           Data.Ord
import           Data.Text                  as T
import           Network.HTTP.Conduit
import           System.Environment

import           Amazon
import           Amazon.Item
import           Amazon.Types.Item

main :: IO ()
main = do
    conf <- getSandbox
    putStrLn "Size:"
    sz <- T.pack <$> getLine
    putStrLn "Child ASIN:"
    ca <- T.pack <$> getLine
    cres  <- runAmazonT conf $ itemLookup ca IdASIN [ItemAttributes] CAll
    let pasin = fromJust $ itemParentASIN $ snd $ fromRight cres
    res  <- runAmazonT conf $ itemLookup pasin IdASIN [VariationMatrix] CAll
    let asins = fmap itemASIN $ getMySize sz $ vrItems $ fromJust $ itemVariations $ snd $ fromRight res
    lp <- forM asins (getASINPrice conf)
    print $ sortBy (comparing snd) lp


getASINPrice :: AmazonConf -> ItemID -> IO (ItemID, Int)
getASINPrice cf asin = do
    threadDelay 1000000
    r <- runAmazonT cf $ itemLookup asin IdASIN [Offers] CAll
    let i = pAmount $ olPrice $ fromJust $ ofListing $ L.head $ fromJust $ itemOffers $ snd $ fromRight r
    return ((asin, i))


getSandbox :: IO AmazonConf
getSandbox = do
    accessId     <- getEnv "AWS_ACCESS_ID"
    accessSecret <- getEnv "AWS_ACCESS_SECRET"
    associateTag <- getEnv "AWS_ASSOCIATE_TAG"
    manager      <- newManager conduitManagerSettings
    return $ liveConf manager (T.pack accessId) (Char8.pack accessSecret) (T.pack associateTag)


getMySize :: Text -> [Item] -> [Item]
getMySize s l= do
    item <- l
    case M.lookup "Size" (vaMap $ fromJust $ itemVariationAttributes item) of
        Nothing -> []
        Just size -> case s `T.isInfixOf` size of
            False -> []
            True -> return item


