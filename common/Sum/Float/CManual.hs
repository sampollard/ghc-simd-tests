{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE ForeignFunctionInterface #-}

module Sum.Float.CManual (
    sum
  ) where

import Prelude hiding (sum)

import Data.Primitive.Addr
import Data.Primitive.ByteArray
import Data.Primitive (sizeOf)
import Foreign.C
import Foreign.ForeignPtr (ForeignPtr)
import Foreign.ForeignPtr.Unsafe (unsafeForeignPtrToPtr)
import Foreign.Ptr
import GHC.Ptr
import System.IO.Unsafe (unsafePerformIO)

import qualified Vector as V

foreign import ccall unsafe "cvecsum" c_vecsum :: Ptr Float -> CInt -> CFloat

sum :: V.Vector Float -> Float
{-# INLINE sum #-}
sum u =
    realToFrac (c_vecsum up ul)
  where
    up :: Ptr Float
    ul :: CInt
    (up, ul) = V.unsafeToPtrLen u
