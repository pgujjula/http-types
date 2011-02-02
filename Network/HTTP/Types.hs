module Network.HTTP.Types
(
  Method(GET, POST, HEAD, PUT, DELETE, TRACE, CONNECT, OPTIONS)
, byteStringToMethod
, methodToByteString
, HttpVersion(httpMajor, httpMinor)
, http09
, http10
, http11
)
where

import           Data.Char
import           Data.Maybe
import qualified Data.ByteString.Char8 as Ascii

localError :: String -> String -> a
localError f s = error $ "Network.HTTP.Types." ++ f ++ ": " ++ s

-- | HTTP method.
-- 
-- Note that the Show instance is only for debugging and should NOT be used to generate HTTP method strings; use 'methodToByteString' instead.
-- 
-- The constructor 'OtherMethod' is not exported for forwards compatibility reasons.
data Method
    = GET
    | POST
    | HEAD  
    | PUT
    | DELETE
    | TRACE
    | CONNECT
    | OPTIONS
    | OtherMethod Ascii.ByteString
    deriving (Show, Eq, Ord)

-- These are ordered by suspected frequency. More popular methods should go first.
-- The reason is that methodListA and methodListB are used with lookup.
-- lookup is probably faster for these few cases than setting up an elaborate data structure.
methodListA :: [(Ascii.ByteString, Method)]
methodListA 
    = [ (Ascii.pack "GET", GET)
      , (Ascii.pack "POST", POST)
      , (Ascii.pack "HEAD", HEAD)
      , (Ascii.pack "PUT", PUT)
      , (Ascii.pack "DELETE", DELETE)
      , (Ascii.pack "TRACE", TRACE)
      , (Ascii.pack "CONNECT", CONNECT)
      , (Ascii.pack "OPTIONS", OPTIONS)
      ]

methodListB :: [(Method, Ascii.ByteString)]
methodListB = map (\(a, b) -> (b, a)) methodListA

-- | Convert a method 'ByteString' to a 'Method'.
byteStringToMethod :: Ascii.ByteString -> Method
byteStringToMethod bs' = fromMaybe (OtherMethod bs) $ lookup bs methodListA
    where bs = Ascii.map toUpper bs'

-- | Convert a 'Method' to a 'ByteString'.
methodToByteString :: Method -> Ascii.ByteString
methodToByteString m
    = case m of
        OtherMethod bs -> bs
        _ -> fromMaybe (localError "methodToByteString" "This should not happen (methodListB is incomplete)") $
             lookup m methodListB

-- | HTTP Version.
-- 
-- Note that the Show instance is intended merely for debugging.
data HttpVersion 
    = HttpVersion {
        httpMajor :: !Int 
      , httpMinor :: !Int
      }
    deriving (Eq, Ord)

instance Show HttpVersion where
    show (HttpVersion major minor) = "HTTP/" ++ show major ++ "." ++ show minor

-- | HTTP 0.9
http09 :: HttpVersion
http09 = HttpVersion 0 9

-- | HTTP 1.0
http10 :: HttpVersion
http10 = HttpVersion 1 0

-- | HTTP 1.1
http11 :: HttpVersion
http11 = HttpVersion 1 1