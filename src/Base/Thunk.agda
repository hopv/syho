--------------------------------------------------------------------------------
-- Thunk for sized coinductive(-inductive) data types
--------------------------------------------------------------------------------

{-# OPTIONS --without-K --sized-types #-}

module Base.Thunk where

open import Base.Level using (Level)
open import Base.Size using (Size; Size<)

--------------------------------------------------------------------------------
-- Thunk, for coinductive or coinductive-inductive data types

record  Thunk {ℓ : Level} (F : Size → Set ℓ) (ι : Size) :  Set ℓ  where
  coinductive
  constructor thunk
  field  ! :  {ι' : Size< ι} →  F ι'
open Thunk public
