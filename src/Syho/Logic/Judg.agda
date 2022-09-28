--------------------------------------------------------------------------------
-- Judgment in Syho
--------------------------------------------------------------------------------
-- Its contents are re-exported across Syho.Logic.Core, Supd, Ind, and Hor

{-# OPTIONS --without-K --sized-types #-}

module Syho.Logic.Judg where

open import Base.Level using (Level; ↑_)
open import Base.Func using (_∘_; _$_)
open import Base.Few using (⊤)
open import Base.Eq using (_≡_)
open import Base.Size using (Size; ∞; Thunk; ¡_; !)
open import Base.Prod using (_×_; _,_; -,_)
open import Base.Sum using (ĩ₀_; ĩ₁_)
open import Base.Dec using ()
open import Base.Zoi using (Zoi; ⊤ᶻ; _⊎ᶻ_; ✔ᶻ_; ^ᶻ_)
open import Base.Nat using (ℕ; ṡ_)
open import Base.List using (List; len; rep)
open import Base.Str using ()
open import Base.RatPos using (ℚ⁺; _+ᴿ⁺_; _≤1ᴿ⁺)
open import Base.Sety using (Setʸ; ⸨_⸩ʸ; Inhʸ)
open import Syho.Lang.Expr using (Addr; Type; Expr; Expr˂; ▶_; ∇_; Val; ṽ_;
  λᵛ-syntax; V⇒E; TyVal; ⊤ṽ)
open import Syho.Lang.Ktxred using (Redex; ▶ᴿ_; ndᴿ; _◁ᴿ_; _⁏ᴿ_; forkᴿ; 🞰ᴿ_;
  _←ᴿ_; allocᴿ; freeᴿ; Ktx; _ᴷ◁_; Val/Ktxred; val/ktxred)
open import Syho.Logic.Prop using (InvName; Prop'; Prop˂; ∀˙; ∃˙; ∀-syntax;
  ∃-syntax; ∃∈-syntax; _∧_; ⊤'; ⌜_⌝∧_; ⌜_⌝; _→'_; _∗_; _-∗_; ⤇_; □_; _↪[_]⇛_;
  ○_; _↦⟨_⟩_; _↪[_]ᵃ⟨_⟩_; _↪⟨_⟩ᴾ_; _↪⟨_⟩ᵀ[_]_; [_]ᴵ; Inv; OInv; _↦_; _↦ᴸ_; Free;
  Basic)

--------------------------------------------------------------------------------
-- WpKind :  Weakest precondion kind

data  WpKind :  Set₀  where
  -- Partial
  par :  WpKind
  -- Total, with a counter
  tot :  ℕ →  WpKind

--------------------------------------------------------------------------------
-- JudgRes :  Result of a judgment

private variable
  ι :  Size
  T U :  Type

infix 3 [_]⇛_ [_]ᵃ⟨_⟩_ ⁺⟨_⟩[_]_

data  JudgRes :  Set₁  where
  -- Just a proposition
  Pure :  Prop' ∞ →  JudgRes
  -- Under the super update
  [_]⇛_ :  ℕ →  Prop' ∞ →  JudgRes
  -- Atomic weakest precondition
  [_]ᵃ⟨_⟩_ :  ℕ →  Redex T →  (Val T → Prop' ∞) →  JudgRes
  -- Weakest precondion, over Val/Ktxred
  ⁺⟨_⟩[_]_ :  Val/Ktxred T →  WpKind →  (Val T → Prop' ∞) →  JudgRes

--------------------------------------------------------------------------------
-- P ⊢[ ι ]* Jr :  Judgment

infix 2 _⊢[_]*_ _⊢[_]_ _⊢[<_]_ _⊢[_][_]⇛_ _⊢[<_][_]⇛_ _⊢[_][_]ᵃ⟨_⟩_
  _⊢[<_][_]ᵃ⟨_⟩_ _⊢[_]⁺⟨_⟩[_]_ _⊢[_]⁺⟨_⟩ᴾ_ _⊢[_]⁺⟨_⟩ᵀ[_]_ _⊢[_]⟨_⟩[_]_
  _⊢[_]⟨_⟩ᴾ_ _⊢[<_]⟨_⟩ᴾ_ _⊢[_]⟨_⟩ᵀ[_]_ _⊢[<_]⟨_⟩ᵀ[_]_

-- Declare _⊢[_]*_

data  _⊢[_]*_ :  Prop' ∞ →  Size →  JudgRes →  Set₁

-- ⊢[ ] :  Pure sequent

_⊢[_]_ :  Prop' ∞ →  Size →  Prop' ∞ →  Set₁
P ⊢[ ι ] Q =  P ⊢[ ι ]* Pure Q

-- ⊢[< ] :  Pure sequent under thunk

_⊢[<_]_ :  Prop' ∞ →  Size →  Prop' ∞ →  Set₁
P ⊢[< ι ] Q =  Thunk (P ⊢[_] Q) ι

-- ⊢[ ][ ]⇛ etc. :  Super update

_⊢[_][_]⇛_ _⊢[<_][_]⇛_ :  Prop' ∞ →  Size →  ℕ →  Prop' ∞ →  Set₁
P ⊢[ ι ][ i ]⇛ Q =  P ⊢[ ι ]* [ i ]⇛ Q
P ⊢[< ι ][ i ]⇛ Q =  Thunk (P ⊢[_][ i ]⇛ Q) ι

-- ⊢[ ][ ]ᵃ⟨ ⟩ etc. :  Atomic Hoare triple

_⊢[_][_]ᵃ⟨_⟩_ _⊢[<_][_]ᵃ⟨_⟩_ :
  Prop' ∞ →  Size →  ℕ →  Redex T →  (Val T → Prop' ∞) →  Set₁
P ⊢[ ι ][ i ]ᵃ⟨ red ⟩ Q˙ =  P ⊢[ ι ]* [ i ]ᵃ⟨ red ⟩ Q˙
P ⊢[< ι ][ i ]ᵃ⟨ red ⟩ Q˙ =  Thunk (P ⊢[_][ i ]ᵃ⟨ red ⟩ Q˙) ι

-- ⊢[ ]⁺⟨ ⟩[ ] etc. :  Hoare triple over Val/Ktxred

_⊢[_]⁺⟨_⟩[_]_ :
  Prop' ∞ →  Size →  Val/Ktxred T →  WpKind →  (Val T → Prop' ∞) →  Set₁
P ⊢[ ι ]⁺⟨ vk ⟩[ wκ ] Q˙ =  P ⊢[ ι ]* ⁺⟨ vk ⟩[ wκ ] Q˙

_⊢[_]⁺⟨_⟩ᴾ_ :  Prop' ∞ →  Size →  Val/Ktxred T →  (Val T → Prop' ∞) →  Set₁
P ⊢[ ι ]⁺⟨ vk ⟩ᴾ Q˙ =  P ⊢[ ι ]⁺⟨ vk ⟩[ par ] Q˙

_⊢[_]⁺⟨_⟩ᵀ[_]_ :
  Prop' ∞ →  Size →  Val/Ktxred T →  ℕ →  (Val T → Prop' ∞) →  Set₁
P ⊢[ ι ]⁺⟨ vk ⟩ᵀ[ i ] Q˙ =  P ⊢[ ι ]⁺⟨ vk ⟩[ tot i ] Q˙

-- ⊢[ ]⟨ ⟩[ ] etc. :  Hoare triple over Expr

_⊢[_]⟨_⟩[_]_ :
  Prop' ∞ →  Size →  Expr ∞ T →  WpKind →  (Val T → Prop' ∞) →  Set₁
P ⊢[ ι ]⟨ e ⟩[ wκ ] Q˙ =  P ⊢[ ι ]⁺⟨ val/ktxred e ⟩[ wκ ] Q˙

_⊢[_]⟨_⟩ᴾ_ _⊢[<_]⟨_⟩ᴾ_ :
  Prop' ∞ →  Size →  Expr ∞ T →  (Val T → Prop' ∞) →  Set₁
P ⊢[ ι ]⟨ e ⟩ᴾ Q˙ =  P ⊢[ ι ]⟨ e ⟩[ par ] Q˙
P ⊢[< ι ]⟨ e ⟩ᴾ Q˙ =  Thunk (P ⊢[_]⟨ e ⟩[ par ] Q˙) ι

_⊢[_]⟨_⟩ᵀ[_]_ _⊢[<_]⟨_⟩ᵀ[_]_ :
  Prop' ∞ →  Size →  Expr ∞ T →  ℕ →  (Val T → Prop' ∞) →  Set₁
P ⊢[ ι ]⟨ e ⟩ᵀ[ i ] Q˙ =  P ⊢[ ι ]⟨ e ⟩[ tot i ] Q˙
P ⊢[< ι ]⟨ e ⟩ᵀ[ i ] Q˙ =  Thunk (P ⊢[_]⟨ e ⟩ᵀ[ i ] Q˙) ι

-- Pers :  Persistence of a proposition

record  Pers (P : Prop' ∞) :  Set₁  where
  inductive
  -- Pers-⇒□ :  P can turn into □ P
  field Pers-⇒□ :  P ⊢[ ι ] □ P
open Pers {{…}} public

private variable
  ł :  Level
  i j n :  ℕ
  Xʸ :  Setʸ
  X :  Set ł
  x :  X
  Y˙ :  X → Set ł
  Jr :  JudgRes
  P P' Q R :  Prop' ∞
  P˙ Q˙ R˙ :  X → Prop' ∞
  P˂ P'˂ Q˂ Q'˂ R˂ :  Prop˂ ∞
  Q˂˙ Q'˂˙ :  X → Prop˂ ∞
  P˂s :  List (Prop˂ ∞)
  wκ :  WpKind
  red :  Redex T
  vk :  Val/Ktxred T
  e :  Expr ∞ T
  e˂ :  Expr˂ ∞ T
  e˙ :  X → Expr ∞ T
  K :  Ktx T U
  v :  Val T
  θ :  Addr
  p q :  ℚ⁺
  ᵗu ᵗv :  TyVal
  ᵗvs :  List TyVal
  nm :  InvName
  Nm Nm' :  InvName → Zoi

infixr -1 _»_ _ᵘ»ᵘ_ _ᵘ»ᵃʰ_ _ᵘ»ʰ_ _ᵃʰ»ᵘ_ _ʰ»ᵘ_

-- Define _⊢[_]*_

data  _⊢[_]*_  where
  ------------------------------------------------------------------------------
  -- General rules

  -- The sequent is reflexive

  ⊢-refl :  P ⊢[ ι ] P

  -- The left-hand side of a judgment can be modified with a sequent

  _»_ :  P ⊢[ ι ] Q →  Q ⊢[ ι ]* Jr →  P ⊢[ ι ]* Jr

  ------------------------------------------------------------------------------
  -- On ∀ / ∃

  -- Introducing ∀ / Eliminating ∃

  ∀-intro :  (∀ x →  P ⊢[ ι ] Q˙ x) →  P ⊢[ ι ] ∀˙ Q˙

  ∃-elim :  (∀ x →  P˙ x ⊢[ ι ]* Jr) →  ∃˙ P˙ ⊢[ ι ]* Jr

  -- Eliminating ∀ / Introducing ∃

  ∀-elim :  ∀ x →  ∀˙ P˙ ⊢[ ι ] P˙ x

  ∃-intro :  ∀ x →  P˙ x ⊢[ ι ] ∃˙ P˙

  -- Choice, which is safe to have thanks to the logic's predicativity

  choice :  ∀{P˙˙ : ∀(x : X) → Y˙ x → Prop' ∞} →
    ∀' x , ∃ y , P˙˙ x y ⊢[ ι ] ∃ y˙ ∈ (∀ x → Y˙ x) , ∀' x , P˙˙ x (y˙ x)

  ------------------------------------------------------------------------------
  -- On →

  -- → is the right adjoint of ∧

  →-intro :  P ∧ Q ⊢[ ι ] R →  Q ⊢[ ι ] P →' R

  →-elim :  Q ⊢[ ι ] P →' R →  P ∧ Q ⊢[ ι ] R

  ------------------------------------------------------------------------------
  -- On ∗

  -- ∗ is unital with the unit ⊤', commutative, associative, and monotone with
  -- respect to ⊢

  ⊤∗-elim :  ⊤' ∗ P ⊢[ ι ] P

  ⊤∗-intro :  P ⊢[ ι ] ⊤' ∗ P

  ∗-comm :  P ∗ Q ⊢[ ι ] Q ∗ P

  ∗-assocˡ :  (P ∗ Q) ∗ R ⊢[ ι ] P ∗ (Q ∗ R)

  ∗-monoˡ :  P ⊢[ ι ] Q →  P ∗ R ⊢[ ι ] Q ∗ R

  ------------------------------------------------------------------------------
  -- On -∗

  -- -∗ is the right adjoint of ∗

  -∗-intro :  P ∗ Q ⊢[ ι ] R →  Q ⊢[ ι ] P -∗ R

  -∗-elim :  Q ⊢[ ι ] P -∗ R →  P ∗ Q ⊢[ ι ] R

  ------------------------------------------------------------------------------
  -- On ⤇

  -- ⤇ is monadic :  monotone, increasing, and idempotent

  ⤇-mono :  P ⊢[ ι ] Q →  ⤇ P ⊢[ ι ] ⤇ Q

  ⤇-intro :  P ⊢[ ι ] ⤇ P

  ⤇-join :  ⤇ ⤇ P ⊢[ ι ] ⤇ P

  -- ∗ can get inside ⤇

  ⤇-eatˡ :  Q ∗ (⤇ P) ⊢[ ι ] ⤇ Q ∗ P

  -- ⌜ ⌝∧ can get outside ⤇

  ⤇-⌜⌝∧-out :  ⤇ (⌜ X ⌝∧ P) ⊢[ ι ] ⌜ X ⌝∧ ⤇ P

  ------------------------------------------------------------------------------
  -- On □

  -- □ is comonadic :  monotone, decreasing, and idempotent

  □-mono :  P ⊢[ ι ] Q →  □ P ⊢[ ι ] □ Q

  □-elim :  □ P ⊢[ ι ] P

  □-dup :  □ P ⊢[ ι ] □ □ P

  -- ∧ can turn into ∗ when one argument is under □

  □ˡ-∧⇒∗ :  □ P ∧ Q ⊢[ ι ] □ P ∗ Q

  -- ∀ can get inside □

  □-∀-in :  ∀˙ (□_ ∘ P˙) ⊢[ ι ] □ ∀˙ P˙

  -- ∃ can get outside □

  □-∃-out :  □ ∃˙ P˙ ⊢[ ι ] ∃˙ (□_ ∘ P˙)

  ------------------------------------------------------------------------------
  -- On ⇛

  -- Increment the counter of ⇛ by 1

  ⇛-ṡ :  P ⊢[ ι ][ i ]⇛ Q →  P ⊢[ ι ][ ṡ i ]⇛ Q

  -- ⊢⇛ is reflexive, with removal of ⤇

  ⇛-refl-⤇ :  ⤇ P ⊢[ ι ][ i ]⇛ P

  -- ⊢⇛ is transitive

  _ᵘ»ᵘ_ :  P ⊢[ ι ][ i ]⇛ Q →  Q ⊢[ ι ][ i ]⇛ R →  P ⊢[ ι ][ i ]⇛ R

  -- ⊢⇛ can frame

  ⇛-frameˡ :  P ⊢[ ι ][ i ]⇛ Q →  R ∗ P ⊢[ ι ][ i ]⇛ R ∗ Q

  ------------------------------------------------------------------------------
  -- On ○

  -- ○ is monotone

  ○-mono :  P˂ .! ⊢[< ι ] Q˂ .! →  ○ P˂ ⊢[ ι ] ○ Q˂

  -- ○ can eat a basic proposition

  ○-eatˡ :  {{Basic Q}} →  Q ∗ ○ P˂ ⊢[ ι ] ○ ¡ (Q ∗ P˂ .!)

  -- ○ P can be obtained by allocating P

  ○-alloc :  P˂ .! ⊢[ ι ][ i ]⇛ ○ P˂

  -- When P is persistent, □ ○ P_i can be obtained recursively, i.e.,
  -- by allocating P minus the target □ ○ P

  -- This can be seen as an analog of Löb induction in step-indexed logics

  □○-alloc-rec :  □ ○ P˂ -∗ □ P˂ .! ⊢[ ι ][ i ]⇛ □ ○ P˂

  -- Use ○ P

  ○-use :  ○ P˂ ⊢[ ι ][ i ]⇛ P˂ .!

  ------------------------------------------------------------------------------
  -- On ↪⇛

  -- Modify ⇛ proof

  ↪⇛-ṡ :  P˂ ↪[ i ]⇛ Q˂  ⊢[ ι ]  P˂ ↪[ ṡ i ]⇛ Q˂

  ↪⇛-eatˡ⁻ˡᵘ :  {{Basic R}} →   R  ∗  P'˂ .!  ⊢[< ι ][ i ]⇛  P˂ .! →
                R  ∗  (P˂ ↪[ i ]⇛ Q˂)  ⊢[ ι ]  P'˂ ↪[ i ]⇛ Q˂

  ↪⇛-eatˡ⁻ʳ :  {{Basic R}} →
    R  ∗  (P˂ ↪[ i ]⇛ Q˂)  ⊢[ ι ]  P˂ ↪[ i ]⇛ ¡ (R ∗ Q˂ .!)

  ↪⇛-monoʳᵘ :  Q˂ .!  ⊢[< ι ][ i ]⇛  Q'˂ .! →
               P˂ ↪[ i ]⇛ Q˂  ⊢[ ι ]  P˂ ↪[ i ]⇛ Q'˂

  ↪⇛-frameˡ :  P˂ ↪[ i ]⇛ Q˂  ⊢[ ι ]  ¡ (R ∗ P˂ .!) ↪[ i ]⇛ ¡ (R ∗ Q˂ .!)

  -- Make ↪⇛ out of ○

  ○⇒↪⇛ :  P˂ .!  ∗  R˂ .! ⊢[< ι ][ i ]⇛  Q˂ .!  →   ○ R˂  ⊢[ ι ]  P˂ ↪[ i ]⇛ Q˂

  -- Use ↪⇛, with counter increment
  -- Without that counter increment, we could do any super update (⇛/↪⇛-use' in
  -- Syho.Logic.Paradox)

  ↪⇛-use :  P˂ .!  ∗  (P˂ ↪[ i ]⇛ Q˂)  ⊢[ ι ][ ṡ i ]⇛  Q˂ .!

  ------------------------------------------------------------------------------
  -- On ↪ᵃ⟨ ⟩

  -- Modify ᵃ⟨ ⟩ proof

  ↪ᵃ⟨⟩-ṡ :  P˂ ↪[ i ]ᵃ⟨ red ⟩ Q˂˙  ⊢[ ι ]  P˂ ↪[ ṡ i ]ᵃ⟨ red ⟩ Q˂˙

  ↪ᵃ⟨⟩-eatˡ⁻ˡᵘ :  {{Basic R}} →  R ∗ P'˂ .! ⊢[< ι ][ j ]⇛ P˂ .! →
                  R ∗ (P˂ ↪[ i ]ᵃ⟨ red ⟩ Q˂˙)  ⊢[ ι ]  P'˂ ↪[ i ]ᵃ⟨ red ⟩ Q˂˙

  ↪ᵃ⟨⟩-eatˡ⁻ʳ :  {{Basic R}} →
    R  ∗  (P˂ ↪[ i ]ᵃ⟨ red ⟩ Q˂˙)  ⊢[ ι ]
      P˂ ↪[ i ]ᵃ⟨ red ⟩ λ v → ¡ (R ∗ Q˂˙ v .!)

  ↪ᵃ⟨⟩-monoʳᵘ :  (∀ v →  Q˂˙ v .!  ⊢[< ι ][ j ]⇛  Q'˂˙ v .!)  →
                 P˂ ↪[ i ]ᵃ⟨ red ⟩ Q˂˙  ⊢[ ι ]  P˂ ↪[ i ]ᵃ⟨ red ⟩ Q'˂˙

  ↪ᵃ⟨⟩-frameˡ :  P˂ ↪[ i ]ᵃ⟨ red ⟩ Q˂˙  ⊢[ ι ]
                   ¡ (R ∗ P˂ .!) ↪[ i ]ᵃ⟨ red ⟩ λ v → ¡ (R ∗ Q˂˙ v .!)

  -- Make ↪⟨ ⟩ᵀ out of ○

  ○⇒↪ᵃ⟨⟩ :  (P˂ .!  ∗  R˂ .! ⊢[< ι ][ i ]ᵃ⟨ red ⟩ λ v →  Q˂˙ v .!)  →
            ○ R˂  ⊢[ ι ]  P˂ ↪[ i ]ᵃ⟨ red ⟩ Q˂˙

  -- Use ↪ᵃ⟨⟩, with counter increment
  -- Without that counter increment, we could have any atomic Hoare triple
  -- (ahor/↪ᵃ⟨⟩-use' in Syho.Logic.Paradox)

  ↪ᵃ⟨⟩-use :  P˂ .!  ∗  (P˂ ↪[ i ]ᵃ⟨ red ⟩ Q˂˙)
                ⊢[ ι ]⟨ e ⟩ᵀ[ ṡ i ] λ v →  Q˂˙ v .!

  ------------------------------------------------------------------------------
  -- On ↪⟨ ⟩ᴾ

  -- Modify ⟨ ⟩ᴾ proof

  ↪⟨⟩ᴾ-eatˡ⁻ˡᵘ :  {{Basic R}} →   R  ∗  P'˂ .!  ⊢[< ι ][ i ]⇛  P˂ .!  →
                  R ∗ (P˂ ↪⟨ e ⟩ᴾ Q˂˙)  ⊢[ ι ]  P'˂ ↪⟨ e ⟩ᴾ Q˂˙

  ↪⟨⟩ᴾ-eatˡ⁻ʳ :  {{Basic R}} →
    R  ∗  (P˂ ↪⟨ e ⟩ᴾ Q˂˙)  ⊢[ ι ]  P˂ ↪⟨ e ⟩ᴾ λ v → ¡ (R ∗ Q˂˙ v .!)

  ↪⟨⟩ᴾ-monoʳᵘ :  (∀ v →  Q˂˙ v .!  ⊢[< ι ][ i ]⇛  Q'˂˙ v .!)  →
                 P˂ ↪⟨ e ⟩ᴾ Q˂˙  ⊢[ ι ]  P˂ ↪⟨ e ⟩ᴾ Q'˂˙

  ↪⟨⟩ᴾ-frameˡ :  P˂ ↪⟨ e ⟩ᴾ Q˂˙  ⊢[ ι ]
                   ¡ (R ∗ P˂ .!) ↪⟨ e ⟩ᴾ λ v → ¡ (R ∗ Q˂˙ v .!)

  -- Make ↪⟨ ⟩ᴾ out of ○

  ○⇒↪⟨⟩ᴾ :  (P˂ .!  ∗  R˂ .! ⊢[< ι ]⟨ e ⟩ᴾ λ v →  Q˂˙ v .!)  →
            ○ R˂  ⊢[ ι ]  P˂ ↪⟨ e ⟩ᴾ Q˂˙

  -- Use ↪⟨⟩ᴾ, with ▶ on the expression
  -- Without that ▶, we could have any partial Hoare triple (horᴾ/↪⟨⟩ᴾ-use' in
  -- Syho.Logic.Paradox)

  ↪⟨⟩ᴾ-use :  P˂ .!  ∗  (P˂ ↪⟨ e˂ .! ⟩ᴾ Q˂˙)  ⊢[ ι ]⟨ ▶ e˂ ⟩ᴾ λ v →  Q˂˙ v .!

  ------------------------------------------------------------------------------
  -- On ↪⟨ ⟩ᵀ

  -- Modify ⟨ ⟩ᵀ proof

  ↪⟨⟩ᵀ-ṡ :  P˂ ↪⟨ e ⟩ᵀ[ i ] Q˂˙  ⊢[ ι ]  P˂ ↪⟨ e ⟩ᵀ[ ṡ i ] Q˂˙

  ↪⟨⟩ᵀ-eatˡ⁻ˡᵘ :  {{Basic R}} →  R ∗ P'˂ .! ⊢[< ι ][ j ]⇛ P˂ .! →
                  R ∗ (P˂ ↪⟨ e ⟩ᵀ[ i ] Q˂˙)  ⊢[ ι ]  P'˂ ↪⟨ e ⟩ᵀ[ i ] Q˂˙

  ↪⟨⟩ᵀ-eatˡ⁻ʳ :  {{Basic R}} →
    R  ∗  (P˂ ↪⟨ e ⟩ᵀ[ i ] Q˂˙)  ⊢[ ι ]  P˂ ↪⟨ e ⟩ᵀ[ i ] λ v → ¡ (R ∗ Q˂˙ v .!)

  ↪⟨⟩ᵀ-monoʳᵘ :  (∀ v →  Q˂˙ v .!  ⊢[< ι ][ j ]⇛  Q'˂˙ v .!)  →
                 P˂ ↪⟨ e ⟩ᵀ[ i ] Q˂˙  ⊢[ ι ]  P˂ ↪⟨ e ⟩ᵀ[ i ] Q'˂˙

  ↪⟨⟩ᵀ-frameˡ :  P˂ ↪⟨ e ⟩ᵀ[ i ] Q˂˙  ⊢[ ι ]
                   ¡ (R ∗ P˂ .!) ↪⟨ e ⟩ᵀ[ i ] λ v → ¡ (R ∗ Q˂˙ v .!)

  -- Make ↪⟨ ⟩ᵀ out of ○

  ○⇒↪⟨⟩ᵀ :  (P˂ .!  ∗  R˂ .! ⊢[< ι ]⟨ e ⟩ᵀ[ i ] λ v →  Q˂˙ v .!)  →
            ○ R˂  ⊢[ ι ]  P˂ ↪⟨ e ⟩ᵀ[ i ] Q˂˙

  -- Turn ↪⟨ ⟩ᵀ into ↪⟨ ⟩ᴾ

  ↪⟨⟩ᵀ⇒↪⟨⟩ᴾ :  P˂ ↪⟨ e ⟩ᵀ[ i ] Q˂˙  ⊢[ ι ]  P˂ ↪⟨ e ⟩ᴾ Q˂˙

  -- Use ↪⟨⟩ᵀ, with counter increment

  -- Without that counter increment, we could have any total Hoare triple
  -- (horᵀ/↪⟨⟩ᵀ-use' in Syho.Logic.Paradox)
  -- If we use ▶ (just like ↪⟨⟩ᴾ-use) instead of counter increment, the total
  -- Hoare triple does not ensure termination (horᵀ-loop/↪⟨⟩ᵀ-use▶ in
  -- Syho.Logic.Paradox)

  ↪⟨⟩ᵀ-use :  P˂ .!  ∗  (P˂ ↪⟨ e ⟩ᵀ[ i ] Q˂˙)
                ⊢[ ι ]⟨ e ⟩ᵀ[ ṡ i ] λ v →  Q˂˙ v .!

  ------------------------------------------------------------------------------
  -- On the impredicative invariant

  -- Invariant name set tokens can be merged and split w.r.t. the set sum

  []ᴵ-merge :  [ Nm ]ᴵ  ∗  [ Nm' ]ᴵ  ⊢[ ι ]  [ Nm ⊎ᶻ Nm' ]ᴵ

  []ᴵ-split :  [ Nm ⊎ᶻ Nm' ]ᴵ  ⊢[ ι ]  [ Nm ]ᴵ  ∗  [ Nm' ]ᴵ

  -- The set of an invariant name set token is valid

  []ᴵ-✔ :  [ Nm ]ᴵ  ⊢[ ι ]  ⌜ ✔ᶻ Nm ⌝

  -- An invariant token is persistent

  Inv-⇒□ :  Inv nm P˂  ⊢[ ι ]  □ Inv nm P˂

  -- Change the proposition of an invariant token assuming a persistent basic
  -- proposition

  Inv-resp-∗ :  {{Pers R}} →  {{Basic R}} →
    R  ∗  P˂ .!  ⊢[< ι ]  Q˂ .!  →   R  ∗  Q˂ .!  ⊢[< ι ]  P˂ .!  →
    R  ∗  Inv nm P˂  ⊢[ ι ]  Inv nm Q˂

  -- Monotonicity of an open invariant token

  OInv-mono :  P˂ .!  ⊢[< ι ]  Q˂ .!  →   OInv nm P˂  ⊢[ ι ]  OInv nm Q˂

  -- Let an open invariant token eat a basic proposition

  OInv-eatˡ :  {{Basic Q}} →  Q  ∗  OInv nm P˂  ⊢[ ι ]  OInv nm (¡ (Q -∗ P˂ .!))

  -- Allocate a proposition minus the invariant token itself to get an
  -- invariant token

  Inv-alloc-rec :  Inv nm P˂ -∗ P  ⊢[ ι ][ i ]⇛  Inv nm P˂

  -- Open an invariant with a token for the invariant name, getting an open
  -- invariant token

  -- Notably, the proposition P˂ .! is directly obtained, without any guard like
  -- the later modality as in Iris

  Inv-open :  Inv nm P˂  ∗  [ ^ᶻ nm ]ᴵ  ⊢[ ι ][ i ]⇛  P˂ .!  ∗  OInv nm P˂

  -- Retrieve a token for the invariant name out of an open invariant token and
  -- its proposition

  OInv-close :  P˂ .!  ∗  OInv nm P˂  ⊢[ ι ][ i ]⇛  [ ^ᶻ nm ]ᴵ

  ------------------------------------------------------------------------------
  -- On the Hoare triples

  -- Weaken a Hoare triple from total to partial

  hor-ᵀ⇒ᴾ :  P  ⊢[ ι ]⁺⟨ vk ⟩ᵀ[ i ]  Q˙  →   P  ⊢[ ι ]⁺⟨ vk ⟩ᴾ  Q˙

  -- Counter increment on the atomic / total Hoare triple

  ahor-ṡ :  P  ⊢[ ι ][ i ]ᵃ⟨ red ⟩  Q˙  →   P  ⊢[ ι ][ ṡ i ]ᵃ⟨ red ⟩  Q˙

  horᵀ-ṡ :  P  ⊢[ ι ]⁺⟨ vk ⟩ᵀ[ i ]  Q˙  →   P  ⊢[ ι ]⁺⟨ vk ⟩ᵀ[ ṡ i ]  Q˙

  -- Compose with a super update

  _ᵘ»ᵃʰ_ :  P  ⊢[ ι ][ j ]⇛  Q  →   Q  ⊢[ ι ][ i ]ᵃ⟨ red ⟩  R˙  →
            P  ⊢[ ι ][ i ]ᵃ⟨ red ⟩  R˙

  _ᵘ»ʰ_ :  P  ⊢[ ι ][ i ]⇛  Q  →   Q  ⊢[ ι ]⁺⟨ vk ⟩[ wκ ]  R˙  →
           P  ⊢[ ι ]⁺⟨ vk ⟩[ wκ ]  R˙

  _ᵃʰ»ᵘ_ :  P  ⊢[ ι ][ i ]ᵃ⟨ red ⟩  Q˙  →   (∀ v →  Q˙ v  ⊢[ ι ][ j ]⇛  R˙ v)  →
            P  ⊢[ ι ][ i ]ᵃ⟨ red ⟩  R˙

  _ʰ»ᵘ_ :  P  ⊢[ ι ]⁺⟨ vk ⟩[ wκ ]  Q˙  →   (∀ v →  Q˙ v  ⊢[ ι ][ i ]⇛  R˙ v)  →
           P  ⊢[ ι ]⁺⟨ vk ⟩[ wκ ]  R˙

  -- Frame

  ahor-frameˡ :  P  ⊢[ ι ][ i ]ᵃ⟨ red ⟩  Q˙  →
                 R  ∗  P  ⊢[ ι ][ i ]ᵃ⟨ red ⟩ λ v →  R  ∗  Q˙ v

  hor-frameˡ :  P  ⊢[ ι ]⁺⟨ vk ⟩[ wκ ]  Q˙  →
                R  ∗  P  ⊢[ ι ]⁺⟨ vk ⟩[ wκ ] λ v →  R  ∗  Q˙ v

  -- Get a Hoare triple out of an atomic Hoare triple and a Hoare triple on
  -- the context

  ahor-hor :  (P  ∗  [ ⊤ᶻ ]ᴵ  ⊢[ ι ][ i ]ᵃ⟨ red ⟩ λ v →  Q˙ v  ∗  [ ⊤ᶻ ]ᴵ)  →
              (∀ v →  Q˙ v  ⊢[ ι ]⟨ K ᴷ◁ V⇒E v ⟩[ wκ ]  R˙)  →
              P  ⊢[ ι ]⁺⟨ ĩ₁ (-, K , red) ⟩[ wκ ]  R˙

  -- Bind by a context

  hor-bind :  P  ⊢[ ι ]⟨ e ⟩[ wκ ]  Q˙  →
              (∀ v →  Q˙ v  ⊢[ ι ]⟨ K ᴷ◁ V⇒E v ⟩[ wκ ]  R˙) →
              P  ⊢[ ι ]⟨ K ᴷ◁ e ⟩[ wκ ]  R˙

  -- Value

  hor-valᵘ :  P  ⊢[ ι ][ i ]⇛  Q˙ v  →   P  ⊢[ ι ]⁺⟨ ĩ₀ v ⟩[ wκ ]  Q˙

  -- Non-deterministic value

  hor-nd :  Inhʸ Xʸ →  (∀(x : ⸨ Xʸ ⸩ʸ) →  P  ⊢[ ι ]⟨ K ᴷ◁ ∇ x ⟩[ wκ ]  Q˙)  →
            P  ⊢[ ι ]⁺⟨ ĩ₁ (-, K , ndᴿ) ⟩[ wκ ]  Q˙

  -- ▶, for partial and total Hoare triples

  horᴾ-▶ :  P  ⊢[< ι ]⟨ K ᴷ◁ e˂ .! ⟩ᴾ  Q˙  →
            P  ⊢[ ι ]⁺⟨ ĩ₁ (-, K , ▶ᴿ e˂) ⟩ᴾ  Q˙

  horᵀ-▶ :  P  ⊢[ ι ]⟨ K ᴷ◁ e˂ .! ⟩ᵀ[ i ]  Q˙  →
            P  ⊢[ ι ]⁺⟨ ĩ₁ (-, K , ▶ᴿ e˂) ⟩ᵀ[ i ]  Q˙

  -- Application

  hor-◁ :  ∀{x : ⸨ Xʸ ⸩ʸ} →  P  ⊢[ ι ]⟨ K ᴷ◁ e˙ x ⟩[ wκ ]  Q˙  →
           P  ⊢[ ι ]⁺⟨ ĩ₁ (-, K , e˙ ◁ᴿ x) ⟩[ wκ ]  Q˙

  -- Sequential execution

  hor-⁏ :  P  ⊢[ ι ]⟨ K ᴷ◁ e ⟩[ wκ ]  Q˙  →
           P  ⊢[ ι ]⁺⟨ ĩ₁ (-, K , v ⁏ᴿ e) ⟩[ wκ ]  Q˙

  -- Thread forking

  hor-fork :  P  ⊢[ ι ]⟨ K ᴷ◁ ∇ _ ⟩[ wκ ]  R˙  →
              Q  ⊢[ ι ]⟨ e ⟩[ wκ ]  (λ _ → ⊤')  →
              P  ∗  Q  ⊢[ ι ]⁺⟨ ĩ₁ (-, K , forkᴿ e) ⟩[ wκ ]  R˙

  ------------------------------------------------------------------------------
  -- On the memory

  -- Points-to tokens agree with the target value

  ↦⟨⟩-agree :  θ ↦⟨ p ⟩ ᵗu  ∗  θ ↦⟨ q ⟩ ᵗv  ⊢[ ι ]  ⌜ ᵗu ≡ ᵗv ⌝

  -- The fraction of the points-to token is no more than 1

  ↦⟨⟩-≤1 :  θ ↦⟨ p ⟩ ᵗv  ⊢[ ι ]  ⌜ p ≤1ᴿ⁺ ⌝

  -- Points-to tokens can be merged and split with respect to the fraction

  ↦⟨⟩-merge :  θ ↦⟨ p ⟩ ᵗv  ∗  θ ↦⟨ q ⟩ ᵗv  ⊢[ ι ]  θ ↦⟨ p +ᴿ⁺ q ⟩ ᵗv

  ↦⟨⟩-split :  θ ↦⟨ p +ᴿ⁺ q ⟩ ᵗv  ⊢[ ι ]  θ ↦⟨ p ⟩ ᵗv  ∗  θ ↦⟨ q ⟩ ᵗv

  -- Memory read

  ahor-🞰 :  θ ↦⟨ p ⟩ (-, v)  ⊢[ ι ][ i ]ᵃ⟨ 🞰ᴿ θ ⟩ λ w →
              ⌜ w ≡ v ⌝∧  θ ↦⟨ p ⟩ (-, v)

  -- Memory write

  ahor-← :  θ ↦ ᵗu  ⊢[ ι ][ i ]ᵃ⟨ θ ←ᴿ v ⟩ λ _ →  θ ↦ (-, v)

  -- Memory allocation

  ahor-alloc :  ⊤'  ⊢[ ι ][ i ]ᵃ⟨ allocᴿ n ⟩ λᵛ θ ,
                  θ ↦ᴸ rep n ⊤ṽ  ∗  Free n θ

  -- Memory freeing

  ahor-free :  len ᵗvs ≡ n  →
    θ ↦ᴸ ᵗvs  ∗  Free n θ  ⊢[ ι ][ i ]ᵃ⟨ freeᴿ θ ⟩ λ _ →  ⊤'
