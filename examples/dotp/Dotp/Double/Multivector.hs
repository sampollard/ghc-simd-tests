{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE MagicHash #-}
{-# LANGUAGE PackageImports #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE UnboxedTuples #-}

module Dotp.Double.Multivector (
    dotp
  ) where

import "multivector" Data.Primitive.Multi
import "multivector" Data.Vector.Generic.MultiStream as MS

import qualified Data.Vector.Generic as G
import qualified Data.Vector.Unboxed as U

dotp :: U.Vector Double -> U.Vector Double -> Double
dotp v w =
    MS.foldl (+) (+) (multifold (+) 0) 0 $ MS.zipWith (*) (*) v w
