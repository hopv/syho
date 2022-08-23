--------------------------------------------------------------------------------
-- Booleans
--------------------------------------------------------------------------------

{-# OPTIONS --without-K --safe #-}

module Base.Bool where

open import Base.Level using (Level)
open import Base.Few using (⊤; ⊥)
open import Base.Eq using (_≡_; refl)

--------------------------------------------------------------------------------
-- Bool :  Boolean

open import Agda.Builtin.Bool public using (Bool)
  renaming (true to tt; false to ff)

private variable
  ł :  Level
  A :  Set ł
  b c d :  Bool

-- Negation

not :  Bool → Bool
not tt =  ff
not ff =  tt

-- Conjunction

infixr 6 _&&_
_&&_ :  Bool → Bool → Bool
tt && b =  b
ff && b =  ff

-- Disjunction

infixr 5 _||_
_||_ :  Bool → Bool → Bool
tt || b =  tt
ff || b =  b

-- Exclusive Or

infixr 5 _xor_
_xor_ :  Bool → Bool → Bool
tt xor b =  not b
ff xor b =  b

-- If then else

infix 0 if_then_else_
if_then_else_ :  Bool → A → A → A
if tt then aᵗ else aᶠ =  aᵗ
if ff then aᵗ else aᶠ =  aᶠ

-- Bool to Set

Tt :  Bool → Set₀
Tt tt =  ⊤
Tt ff =  ⊥

abstract

  Tt⇒≡tt :  Tt b →  b ≡ tt
  Tt⇒≡tt {b = tt} _ =  refl

--------------------------------------------------------------------------------
-- ≤ᴮ :  Order over Bool

infix 4 _≤ᴮ_
data  _≤ᴮ_ :  Bool → Bool → Set₀  where
  ff≤tt :  ff ≤ᴮ tt
  ≤ᴮ-refl :  ∀{b} →  b ≤ᴮ b
open _≤ᴮ_ public

abstract

  -- ≤ᴮ is transitive

  ≤ᴮ-trans :  b ≤ᴮ c →  c ≤ᴮ d →  b ≤ᴮ d
  ≤ᴮ-trans ≤ᴮ-refl c≤d =  c≤d
  ≤ᴮ-trans ff≤tt ≤ᴮ-refl =  ff≤tt
