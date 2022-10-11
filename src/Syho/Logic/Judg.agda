--------------------------------------------------------------------------------
-- Judgment in Syho
--------------------------------------------------------------------------------
-- Its contents are re-exported across Syho.Logic.Core, Supd, Ind, and Hor

{-# OPTIONS --without-K --sized-types #-}

module Syho.Logic.Judg where

open import Base.Func using (_∘_; _$_)
open import Base.Eq using (_≡_; _≢_; _≡˙_)
open import Base.Dec using (Inh)
open import Base.Size using (Size; Thunk; ¡_; !)
open import Base.Bool using (Bool; tt; ff)
open import Base.Zoi using (Zoi; ✔ᶻ_; _⊎ᶻ_)
open import Base.Prod using (_×_; _,_; -,_)
open import Base.Sum using (ĩ₀_; ĩ₁_)
open import Base.Nat using (ℕ; ṡ_; _≤_)
open import Base.List using (List; len; rep)
open import Base.Str using ()
open import Base.RatPos using (ℚ⁺; _+ᴿ⁺_; _≤1ᴿ⁺)
open import Base.Sety using (Setʸ; ⸨_⸩ʸ)
open import Syho.Lang.Expr using (Addr; Type; ◸ʸ_; Expr∞; Expr˂∞; ∇_; Val; V⇒E;
  TyVal; ⊤-)
open import Syho.Lang.Ktxred using (Redex; ndᴿ; [_]ᴿ⟨_⟩; [_]ᴿ○; [_]ᴿ●; forkᴿ;
  🞰ᴿ_; _←ᴿ_; fauᴿ; casᴿ; allocᴿ; freeᴿ; Ktx; _ᴷ◁_; Val/Ktxred; val/ktxred)
open import Syho.Lang.Reduce using (_⇒ᴾ_)
open import Syho.Logic.Prop using (WpKind; Name; Lft; par; tot; Prop∞; Prop˂∞;
  ∀˙; ∃˙; ∀-syntax; ∃-syntax; ∃∈-syntax; _∧_; ⊤'; ⊥'; ⌜_⌝∧_; ⌜_⌝; _→'_; _∗_;
  _-∗_; ⤇_; □_; _↦_; _↦ᴸ_; Free; ○_; _↪[_]⇛_; _↦⟨_⟩_; _↪[_]ᵃ⟨_⟩_; _↪⟨_⟩[_]_;
  _↪⟨_⟩ᴾ_; _↪⟨_⟩ᵀ[_]_; _↪[_]⟨_⟩∞; [_]ᴺ; [⊤]ᴺ; [^_]ᴺ; &ⁱ⟨_⟩_; %ⁱ⟨_⟩_; [_]ᴸ⟨_⟩;
  [_]ᴸ; †ᴸ_; Basic)

--------------------------------------------------------------------------------
-- JudgRes :  Result of a judgment

private variable
  ι :  Size
  T U :  Type

infix 3 [_]⇛_ [_]ᵃ⟨_⟩_ ⁺⟨_⟩[_]_

data  JudgRes :  Set₁  where
  -- Just a proposition
  Pure :  Prop∞ →  JudgRes
  -- Under the super update, with a level
  [_]⇛_ :  ℕ →  Prop∞ →  JudgRes
  -- Atomic weakest precondition, with a level
  [_]ᵃ⟨_⟩_ :  ℕ →  Redex T →  (Val T → Prop∞) →  JudgRes
  -- Weakest precondion, over Val/Ktxred
  ⁺⟨_⟩[_]_ :  Val/Ktxred T →  WpKind →  (Val T → Prop∞) →  JudgRes
  -- Infinite weakest precondition, with a level, over Val/Ktxred
  [_]⁺⟨_⟩∞ :  ℕ →  Val/Ktxred T →  JudgRes

--------------------------------------------------------------------------------
-- P ⊢[ ι ]* Jr :  Judgment

infix 2 _⊢[_]*_ _⊢[<_]*_ _⊢[_]_ _⊢[<_]_ _⊢[_][_]⇛_ _⊢[<_][_]⇛_ _⊢[_][_]⇛ᴺ_
  _⊢[<_][_]⇛ᴺ_ _⊢[_][_]ᵃ⟨_⟩_ _⊢[<_][_]ᵃ⟨_⟩_ _⊢[_]⁺⟨_⟩[_]_ _⊢[_]⁺⟨_⟩ᴾ_
  _⊢[_]⁺⟨_⟩ᵀ[_]_ _⊢[<_]⁺⟨_⟩ᵀ[_]_ _⊢[_]⟨_⟩[_]_ _⊢[<_]⟨_⟩[_]_ _⊢[_]⟨_⟩ᴾ_
  _⊢[<_]⟨_⟩ᴾ_ _⊢[_]⟨_⟩ᵀ[_]_ _⊢[<_]⟨_⟩ᵀ[_]_ _⊢[<ᴾ_]⟨_⟩[_]_ _⊢[_][_]⁺⟨_⟩∞
  _⊢[<_][_]⁺⟨_⟩∞ _⊢[_][_]⟨_⟩∞ _⊢[<_][_]⟨_⟩∞

-- Judg ι P Jr :  P ⊢[ ι ]* Jr with the size argument coming first

data  Judg (ι : Size) :  Prop∞ →  JudgRes →  Set₁

-- ⊢[ ]* :  General Judgment
-- ⊢[< ]* :  ⊢[ ]* under thunk

_⊢[_]*_ _⊢[<_]*_ :  Prop∞ →  Size →  JudgRes →  Set₁
P ⊢[ ι ]* Jr =  Judg ι P Jr
P ⊢[< ι ]* Jr =  Thunk (P ⊢[_]* Jr) ι

-- ⊢[ ] etc. :  Pure sequent

_⊢[_]_ _⊢[<_]_ :  Prop∞ →  Size →  Prop∞ →  Set₁
P ⊢[ ι ] Q =  P ⊢[ ι ]* Pure Q
P ⊢[< ι ] Q =  Thunk (P ⊢[_] Q) ι

-- ⊢[ ][ ]⇛ etc. :  Super-update sequent

_⊢[_][_]⇛_ _⊢[<_][_]⇛_ :  Prop∞ →  Size →  ℕ →  Prop∞ →  Set₁
P ⊢[ ι ][ i ]⇛ Q =  P ⊢[ ι ]* [ i ]⇛ Q
P ⊢[< ι ][ i ]⇛ Q =  Thunk (P ⊢[_][ i ]⇛ Q) ι

-- ⊢[ ][ ]⇛ᴺ etc. :  Super-update sequent with the universal name set token [⊤]ᴺ

_⊢[_][_]⇛ᴺ_ _⊢[<_][_]⇛ᴺ_ :  Prop∞ →  Size →  ℕ →  Prop∞ →  Set₁
P ⊢[ ι ][ i ]⇛ᴺ Q =  P ∗ [⊤]ᴺ ⊢[ ι ][ i ]⇛ Q ∗ [⊤]ᴺ
P ⊢[< ι ][ i ]⇛ᴺ Q =  Thunk (P ⊢[_][ i ]⇛ᴺ Q) ι

-- ⊢[ ][ ]ᵃ⟨ ⟩ etc. :  Atomic Hoare triple

_⊢[_][_]ᵃ⟨_⟩_ _⊢[<_][_]ᵃ⟨_⟩_ :
  Prop∞ →  Size →  ℕ →  Redex T →  (Val T → Prop∞) →  Set₁
P ⊢[ ι ][ i ]ᵃ⟨ red ⟩ Q˙ =  P ⊢[ ι ]* [ i ]ᵃ⟨ red ⟩ Q˙
P ⊢[< ι ][ i ]ᵃ⟨ red ⟩ Q˙ =  Thunk (P ⊢[_][ i ]ᵃ⟨ red ⟩ Q˙) ι

-- ⊢[ ]⁺⟨ ⟩[ ] etc. :  Hoare triple over Val/Ktxred

_⊢[_]⁺⟨_⟩[_]_ :
  Prop∞ →  Size →  Val/Ktxred T →  WpKind →  (Val T → Prop∞) →  Set₁
P ⊢[ ι ]⁺⟨ vk ⟩[ κ ] Q˙ =  P ⊢[ ι ]* ⁺⟨ vk ⟩[ κ ] Q˙

_⊢[_]⁺⟨_/_⟩[_]_ :
  Prop∞ →  Size →  ∀ T →  Val/Ktxred T →  WpKind →  (Val T → Prop∞) →  Set₁
P ⊢[ ι ]⁺⟨ _ / vk ⟩[ κ ] Q˙ =  P ⊢[ ι ]⁺⟨ vk ⟩[ κ ] Q˙

_⊢[_]⁺⟨_⟩ᴾ_ :  Prop∞ →  Size →  Val/Ktxred T →  (Val T → Prop∞) →  Set₁
P ⊢[ ι ]⁺⟨ vk ⟩ᴾ Q˙ =  P ⊢[ ι ]⁺⟨ vk ⟩[ par ] Q˙

_⊢[_]⁺⟨_⟩ᵀ[_]_ _⊢[<_]⁺⟨_⟩ᵀ[_]_ :
  Prop∞ →  Size →  Val/Ktxred T →  ℕ →  (Val T → Prop∞) →  Set₁
P ⊢[ ι ]⁺⟨ vk ⟩ᵀ[ i ] Q˙ =  P ⊢[ ι ]⁺⟨ vk ⟩[ tot i ] Q˙
P ⊢[< ι ]⁺⟨ vk ⟩ᵀ[ i ] Q˙ =  Thunk (P ⊢[_]⁺⟨ vk ⟩ᵀ[ i ] Q˙) ι

-- ⊢[ ]⟨ ⟩[ ] etc. :  Hoare triple over Expr

_⊢[_]⟨_⟩[_]_ _⊢[<_]⟨_⟩[_]_ :
  Prop∞ →  Size →  Expr∞ T →  WpKind →  (Val T → Prop∞) →  Set₁
P ⊢[ ι ]⟨ e ⟩[ κ ] Q˙ =  P ⊢[ ι ]⁺⟨ val/ktxred e ⟩[ κ ] Q˙
P ⊢[< ι ]⟨ e ⟩[ κ ] Q˙ =  Thunk (P ⊢[_]⟨ e ⟩[ κ ] Q˙) ι

_⊢[_]⟨_⟩ᴾ_ _⊢[<_]⟨_⟩ᴾ_ :
  Prop∞ →  Size →  Expr∞ T →  (Val T → Prop∞) →  Set₁
P ⊢[ ι ]⟨ e ⟩ᴾ Q˙ =  P ⊢[ ι ]⟨ e ⟩[ par ] Q˙
P ⊢[< ι ]⟨ e ⟩ᴾ Q˙ =  P ⊢[< ι ]⟨ e ⟩[ par ] Q˙

_⊢[_]⟨_⟩ᵀ[_]_ _⊢[<_]⟨_⟩ᵀ[_]_ :
  Prop∞ →  Size →  Expr∞ T →  ℕ →  (Val T → Prop∞) →  Set₁
P ⊢[ ι ]⟨ e ⟩ᵀ[ i ] Q˙ =  P ⊢[ ι ]⟨ e ⟩[ tot i ] Q˙
P ⊢[< ι ]⟨ e ⟩ᵀ[ i ] Q˙ =  P ⊢[< ι ]⟨ e ⟩[ tot i ] Q˙

-- ⊢[<ᴾ ]⟨ ⟩[ ] :  Hoare triple over Expr, under thunk if partial

_⊢[<ᴾ_]⟨_⟩[_]_ :  Prop∞ →  Size →  Expr∞ T →  WpKind →  (Val T → Prop∞) →  Set₁
P ⊢[<ᴾ ι ]⟨ e ⟩[ par ] Q˙ =  P ⊢[< ι ]⟨ e ⟩ᴾ Q˙
P ⊢[<ᴾ ι ]⟨ e ⟩[ tot i ] Q˙ =  P ⊢[ ι ]⟨ e ⟩ᵀ[ i ] Q˙

-- ⊢[ ][ ]⁺⟨ ⟩∞ etc. :  Infinite Hoare triple

-- This means that the event ● should occur an infinite number of times
-- in any execution of the program

_⊢[_][_]⁺⟨_⟩∞ _⊢[<_][_]⁺⟨_⟩∞ :  Prop∞ →  Size →  ℕ →  Val/Ktxred T →  Set₁
P ⊢[ ι ][ i ]⁺⟨ vk ⟩∞ =  P ⊢[ ι ]* [ i ]⁺⟨ vk ⟩∞
P ⊢[< ι ][ i ]⁺⟨ vk ⟩∞ =  Thunk (P ⊢[_][ i ]⁺⟨ vk ⟩∞) ι

_⊢[_][_]⟨_⟩∞ _⊢[<_][_]⟨_⟩∞ :  Prop∞ →  Size →  ℕ →  Expr∞ T →  Set₁
P ⊢[ ι ][ i ]⟨ e ⟩∞ =  P ⊢[ ι ][ i ]⁺⟨ val/ktxred e ⟩∞
P ⊢[< ι ][ i ]⟨ e ⟩∞ =  Thunk (P ⊢[_][ i ]⟨ e ⟩∞) ι

-- Pers :  Persistence of a proposition

record  Pers (P : Prop∞) :  Set₁  where
  inductive
  -- Pers-⇒□ :  P can turn into □ P
  field Pers-⇒□ :  P ⊢[ ι ] □ P
open Pers {{…}} public

private variable
  i j n :  ℕ
  b :  Bool
  Xʸ :  Setʸ
  X :  Set₀
  v x y z :  X
  f :  X → X
  Y˙ :  X → Set₀
  Jr :  JudgRes
  P P' Q R :  Prop∞
  P˙ Q˙ R˙ :  X → Prop∞
  P˂ P'˂ Q˂ Q'˂ R˂ :  Prop˂∞
  Q˂˙ Q'˂˙ :  X → Prop˂∞
  κ :  WpKind
  red :  Redex T
  vk :  Val/Ktxred T
  e e' :  Expr∞ T
  e˙ :  X → Expr∞ T
  K :  Ktx T U
  θ :  Addr
  p q :  ℚ⁺
  ᵗu ᵗv :  TyVal
  ᵗvs :  List TyVal
  nm :  Name
  Nm Nm' :  Name → Zoi
  α :  Lft

infixr -1 _»_ _ᵘ»ᵘ_ _ᵘ»ᵃʰ_ _ᵘᴺ»ʰ_ _ᵘᴺ»ⁱʰ_ _ᵃʰ»ᵘ_ _ʰ»ᵘᴺ_

-- Define Judg

data  Judg ι  where
  ------------------------------------------------------------------------------
  -- General rules

  -- The pure sequent is reflexive

  ⊢-refl :  P ⊢[ ι ] P

  -- Modify the left-hand side of a judgment with a pure sequent

  _»_ :  P ⊢[ ι ] Q →  Q ⊢[ ι ]* Jr →  P ⊢[ ι ]* Jr

  ------------------------------------------------------------------------------
  -- On ∀ / ∃

  -- Introduce ∀ / Eliminate ∃

  ∀-intro :  (∀ x →  P ⊢[ ι ] Q˙ x) →  P ⊢[ ι ] ∀˙ Q˙

  ∃-elim :  (∀ x →  P˙ x ⊢[ ι ]* Jr) →  ∃˙ P˙ ⊢[ ι ]* Jr

  -- Eliminate ∀ / Introduce ∃

  ∀-elim :  ∀ x →  ∀˙ P˙ ⊢[ ι ] P˙ x

  ∃-intro :  ∀ x →  P˙ x ⊢[ ι ] ∃˙ P˙

  -- Choice, which is safe to have thanks to the logic's predicativity

  choice :  ∀{P˙˙ : ∀(x : X) → Y˙ x → Prop∞} →
    ∀' x , ∃ y , P˙˙ x y ⊢[ ι ] ∃ y˙ ∈ (∀ x → Y˙ x) , ∀' x , P˙˙ x (y˙ x)

  ------------------------------------------------------------------------------
  -- On →

  -- → is the right adjoint of ∧

  →-intro :  P ∧ Q ⊢[ ι ] R →  Q ⊢[ ι ] P →' R

  →-elim :  Q ⊢[ ι ] P →' R →  P ∧ Q ⊢[ ι ] R

  ------------------------------------------------------------------------------
  -- On ∗

  -- ∗ is monotone w.r.t. ⊢, unital with the unit ⊤', commutative,
  -- and associative

  ∗-monoˡ :  P ⊢[ ι ] Q →  P ∗ R ⊢[ ι ] Q ∗ R

  ⊤∗-elim :  ⊤' ∗ P ⊢[ ι ] P

  ⊤∗-intro :  P ⊢[ ι ] ⊤' ∗ P

  ∗-comm :  P ∗ Q ⊢[ ι ] Q ∗ P

  ∗-assocˡ :  (P ∗ Q) ∗ R ⊢[ ι ] P ∗ (Q ∗ R)

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

  -- Let ⤇ eat a proposition

  ⤇-eatˡ :  Q ∗ (⤇ P) ⊢[ ι ] ⤇ Q ∗ P

  -- Let ⌜ ⌝∧ go outside ⤇

  ⤇-⌜⌝∧-out :  ⤇ (⌜ X ⌝∧ P) ⊢[ ι ] ⌜ X ⌝∧ ⤇ P

  ------------------------------------------------------------------------------
  -- On □

  -- □ is comonadic :  monotone, decreasing, and idempotent

  □-mono :  P ⊢[ ι ] Q →  □ P ⊢[ ι ] □ Q

  □-elim :  □ P ⊢[ ι ] P

  □-dup :  □ P ⊢[ ι ] □ □ P

  -- Turn ∧ into ∗ when one argument is under □

  □ˡ-∧⇒∗ :  □ P ∧ Q ⊢[ ι ] □ P ∗ Q

  -- Let ∀ go inside □

  □-∀-in :  ∀˙ (□_ ∘ P˙) ⊢[ ι ] □ ∀˙ P˙

  -- Let ∃ go outside □

  □-∃-out :  □ ∃˙ P˙ ⊢[ ι ] ∃˙ (□_ ∘ P˙)

  ------------------------------------------------------------------------------
  -- On ⇛

  -- Increment the level of ⇛ by 1

  ⇛-ṡ :  P ⊢[< ι ][ i ]⇛ Q →  P ⊢[ ι ][ ṡ i ]⇛ Q

  -- ⊢⇛ is reflexive, with removal of ⤇

  ⇛-refl-⤇ :  ⤇ P ⊢[ ι ][ i ]⇛ P

  -- ⊢⇛ is transitive

  _ᵘ»ᵘ_ :  P ⊢[ ι ][ i ]⇛ Q →  Q ⊢[ ι ][ i ]⇛ R →  P ⊢[ ι ][ i ]⇛ R

  -- Frame for ⊢⇛

  ⇛-frameˡ :  P ⊢[ ι ][ i ]⇛ Q →  R ∗ P ⊢[ ι ][ i ]⇛ R ∗ Q

  ------------------------------------------------------------------------------
  -- On the Hoare triples

  -- Weaken a Hoare triple from total to partial

  hor-ᵀ⇒ᴾ :  P  ⊢[ ι ]⁺⟨ vk ⟩ᵀ[ i ]  Q˙  →   P  ⊢[ ι ]⁺⟨ vk ⟩ᴾ  Q˙

  -- Weaken an infinite Hoare triple into a partial Hoare triple

  ihor⇒horᴾ :  P  ⊢[ ι ][ i ]⁺⟨ vk ⟩∞  →   P  ⊢[ ι ]⁺⟨ vk ⟩ᴾ  Q˙

  -- Level increment on the atomic / total / infinite Hoare triple

  ahor-ṡ :  P  ⊢[< ι ][ i ]ᵃ⟨ red ⟩  Q˙  →   P  ⊢[ ι ][ ṡ i ]ᵃ⟨ red ⟩  Q˙

  horᵀ-ṡ :  P  ⊢[< ι ]⁺⟨ vk ⟩ᵀ[ i ]  Q˙  →   P  ⊢[ ι ]⁺⟨ vk ⟩ᵀ[ ṡ i ]  Q˙

  ihor-ṡ :  P  ⊢[< ι ][ i ]⁺⟨ vk ⟩∞  →   P  ⊢[ ι ][ ṡ i ]⁺⟨ vk ⟩∞

  -- Compose with a super update

  _ᵘ»ᵃʰ_ :  P  ⊢[ ι ][ j ]⇛  Q  →   Q  ⊢[ ι ][ i ]ᵃ⟨ red ⟩  R˙  →
            P  ⊢[ ι ][ i ]ᵃ⟨ red ⟩  R˙

  _ᵘᴺ»ʰ_ :  P  ⊢[ ι ][ i ]⇛ᴺ  Q  →   Q  ⊢[ ι ]⁺⟨ vk ⟩[ κ ]  R˙  →
            P  ⊢[ ι ]⁺⟨ vk ⟩[ κ ]  R˙

  _ᵘᴺ»ⁱʰ_ :  P  ⊢[ ι ][ i ]⇛ᴺ  Q  →   Q  ⊢[ ι ][ j ]⁺⟨ vk ⟩∞  →
             P  ⊢[ ι ][ j ]⁺⟨ vk ⟩∞

  _ᵃʰ»ᵘ_ :  P  ⊢[ ι ][ i ]ᵃ⟨ red ⟩  Q˙  →   (∀ v →  Q˙ v  ⊢[ ι ][ j ]⇛  R˙ v)  →
            P  ⊢[ ι ][ i ]ᵃ⟨ red ⟩  R˙

  _ʰ»ᵘᴺ_ :  P  ⊢[ ι ]⁺⟨ vk ⟩[ κ ]  Q˙  →   (∀ v →  Q˙ v  ⊢[ ι ][ j ]⇛ᴺ  R˙ v)  →
            P  ⊢[ ι ]⁺⟨ vk ⟩[ κ ]  R˙

  -- Frame

  ahor-frameˡ :  P  ⊢[ ι ][ i ]ᵃ⟨ red ⟩  Q˙  →
                 R  ∗  P  ⊢[ ι ][ i ]ᵃ⟨ red ⟩ λ v →  R  ∗  Q˙ v

  hor-frameˡ :  P  ⊢[ ι ]⁺⟨ vk ⟩[ κ ]  Q˙  →
                R  ∗  P  ⊢[ ι ]⁺⟨ vk ⟩[ κ ] λ v →  R  ∗  Q˙ v

  -- Compose an atomic Hoare triple with [⊤]ᴺ and a Hoare triple on the context

  -- The premise on the context can be used coinductively for the partial Hoare
  -- triple, and only inductively for the total and infinite Hoare triples

  ahor-hor :  P ∗ [⊤]ᴺ  ⊢[ ι ][ i ]ᵃ⟨ red ⟩ (λ v →  Q˙ v ∗ [⊤]ᴺ)  →
              (∀ v →  Q˙ v  ⊢[<ᴾ ι ]⟨ K ᴷ◁ V⇒E v ⟩[ κ ]  R˙)  →
              P  ⊢[ ι ]⁺⟨ ĩ₁ (-, K , red) ⟩[ κ ]  R˙

  ahor-ihor :  P ∗ [⊤]ᴺ  ⊢[ ι ][ i ]ᵃ⟨ red ⟩ (λ v →  Q˙ v ∗ [⊤]ᴺ)  →
               (∀ v →  Q˙ v  ⊢[ ι ][ j ]⟨ K ᴷ◁ V⇒E v ⟩∞)  →
               P  ⊢[ ι ][ j ]⁺⟨ ĩ₁ (-, K , red) ⟩∞

  -- Bind by a context

  hor-bind :  P  ⊢[ ι ]⟨ e ⟩[ κ ]  Q˙  →
              (∀ v →  Q˙ v  ⊢[ ι ]⟨ K ᴷ◁ V⇒E v ⟩[ κ ]  R˙) →
              P  ⊢[ ι ]⟨ K ᴷ◁ e ⟩[ κ ]  R˙

  ihor-bind :  P  ⊢[ ι ][ i ]⟨ e ⟩∞  →   P  ⊢[ ι ][ i ]⟨ K ᴷ◁ e ⟩∞

  hor-ihor-bind :  P  ⊢[ ι ]⟨ e ⟩ᵀ[ i ] Q˙  →
                   (∀ v →  Q˙ v  ⊢[ ι ][ j ]⟨ K ᴷ◁ V⇒E v ⟩∞)  →
                   P  ⊢[ ι ][ j ]⟨ K ᴷ◁ e ⟩∞

  -- Value

  hor-valᵘᴺ :  P  ⊢[ ι ][ i ]⇛ᴺ  Q˙ v  →   P  ⊢[ ι ]⁺⟨ T / ĩ₀ v ⟩[ κ ]  Q˙

  -- Non-deterministic value

  ahor-nd :  {{ Inh ⸨ Xʸ ⸩ʸ }} →  P  ⊢[ ι ][ i ]ᵃ⟨ ndᴿ {Xʸ} ⟩ λ _ →  P

  -- Pure reduction

  -- The premise can be used coinductively for the partial Hoare triple,
  -- only inductively for the total Hoare triple,
  -- coinductively only with the event for the infinite Hoare triple

  hor-[] :  P  ⊢[<ᴾ ι ]⟨ K ᴷ◁ e ⟩[ κ ]  Q˙  →
            P  ⊢[ ι ]⁺⟨ ĩ₁ (-, K , [ e ]ᴿ⟨ b ⟩) ⟩[ κ ]  Q˙

  ihor-[]○ :  P  ⊢[ ι ][ i ]⟨ K ᴷ◁ e ⟩∞  →
              P  ⊢[ ι ][ i ]⁺⟨ ĩ₁ (-, K , [ e ]ᴿ○) ⟩∞

  ihor-[]● :  P  ⊢[< ι ][ i ]⟨ K ᴷ◁ e ⟩∞  →
              P  ⊢[ ι ][ i ]⁺⟨ ĩ₁ (-, K , [ e ]ᴿ●) ⟩∞

  -- Thread forking

  -- For the infinite Hoare triple, the forked thread should terminate, because
  -- we don't assume fair scheduling of threads

  hor-fork :  P  ⊢[<ᴾ ι ]⟨ K ᴷ◁ ∇ _ ⟩[ κ ]  R˙  →
              Q  ⊢[<ᴾ ι ]⟨ e ⟩[ κ ] (λ _ →  ⊤')  →
              P  ∗  Q  ⊢[ ι ]⁺⟨ ĩ₁ (-, K , forkᴿ e) ⟩[ κ ]  R˙

  ihor-fork :  P  ⊢[ ι ][ i ]⟨ K ᴷ◁ ∇ _ ⟩∞  →
               Q  ⊢[ ι ]⟨ e ⟩ᵀ[ j ] (λ _ →  ⊤')  →
               P  ∗  Q  ⊢[ ι ][ i ]⁺⟨ ĩ₁ (-, K , forkᴿ e) ⟩∞

  ------------------------------------------------------------------------------
  -- On the memory

  -- Merge and split points-to tokens w.r.t. the fraction

  ↦⟨⟩-merge :  θ ↦⟨ p ⟩ ᵗv  ∗  θ ↦⟨ q ⟩ ᵗv  ⊢[ ι ]  θ ↦⟨ p +ᴿ⁺ q ⟩ ᵗv

  ↦⟨⟩-split :  θ ↦⟨ p +ᴿ⁺ q ⟩ ᵗv  ⊢[ ι ]  θ ↦⟨ p ⟩ ᵗv  ∗  θ ↦⟨ q ⟩ ᵗv

  -- The fraction of the points-to token is no more than 1

  ↦⟨⟩-≤1 :  θ ↦⟨ p ⟩ ᵗv  ⊢[ ι ]  ⌜ p ≤1ᴿ⁺ ⌝

  -- Points-to tokens agree with the target value

  ↦⟨⟩-agree :  θ ↦⟨ p ⟩ ᵗu  ∗  θ ↦⟨ q ⟩ ᵗv  ⊢[ ι ]  ⌜ ᵗu ≡ ᵗv ⌝

  -- Memory read

  ahor-🞰 :  θ ↦⟨ p ⟩ (T , v)  ⊢[ ι ][ i ]ᵃ⟨ 🞰ᴿ_ {T} θ ⟩ λ u →
              ⌜ u ≡ v ⌝∧  θ ↦⟨ p ⟩ (T , v)

  -- Memory write

  ahor-← :  θ ↦ ᵗu  ⊢[ ι ][ i ]ᵃ⟨ _←ᴿ_ {T} θ v ⟩ λ _ →  θ ↦ (T , v)

  -- Fetch and update

  ahor-fau :  θ ↦ (◸ʸ Xʸ , x)  ⊢[ ι ][ i ]ᵃ⟨ fauᴿ f θ ⟩ λ y →
                ⌜ y ≡ x ⌝∧  θ ↦ (-, f x)

  -- Compare and swap, the success and failure cases

  ahor-cas-tt :  θ ↦ (◸ʸ Xʸ , x)  ⊢[ ι ][ i ]ᵃ⟨ casᴿ θ x y ⟩ λ b →
                   ⌜ b ≡ tt ⌝∧  θ ↦ (-, y)

  ahor-cas-ff :  z ≢ x  →
    θ ↦⟨ p ⟩ (◸ʸ Xʸ , z)  ⊢[ ι ][ i ]ᵃ⟨ casᴿ θ x y ⟩ λ b →
      ⌜ b ≡ ff ⌝∧  θ ↦⟨ p ⟩ (-, z)

  -- Memory allocation

  ahor-alloc :  ⊤'  ⊢[ ι ][ i ]ᵃ⟨ allocᴿ n ⟩ λ θ →
                  θ ↦ᴸ rep n ⊤-  ∗  Free n θ

  -- Memory freeing

  ahor-free :  len ᵗvs ≡ n  →
    θ ↦ᴸ ᵗvs  ∗  Free n θ  ⊢[ ι ][ i ]ᵃ⟨ freeᴿ θ ⟩ λ _ →  ⊤'

  ------------------------------------------------------------------------------
  -- On ○

  -- ○ is monotone

  ○-mono :  P˂ .! ⊢[< ι ] Q˂ .! →  ○ P˂ ⊢[ ι ] ○ Q˂

  -- Let ○ eat a basic proposition

  ○-eatˡ :  {{Basic Q}} →  Q ∗ ○ P˂ ⊢[ ι ] ○ ¡ (Q ∗ P˂ .!)

  -- Obtain ○ P by allocating P

  ○-alloc :  P˂ .! ⊢[ ι ][ i ]⇛ ○ P˂

  -- Obtain □ ○ P recursively, i.e., by allocating □ P minus the target □ ○ P

  -- This can be seen as an analog of Löb induction in step-indexed logics

  □○-alloc-rec :  □ ○ P˂ -∗ □ P˂ .! ⊢[ ι ][ i ]⇛ □ ○ P˂

  -- Use ○ P

  ○-use :  ○ P˂ ⊢[ ι ][ i ]⇛ P˂ .!

  ------------------------------------------------------------------------------
  -- On ↪⇛

  -- Modify ⇛ proof

  ↪⇛-≤ :  i ≤ j  →   P˂ ↪[ i ]⇛ Q˂  ⊢[ ι ]  P˂ ↪[ j ]⇛ Q˂

  ↪⇛-eatˡ⁻ˡᵘ :  {{Basic R}}  →   R  ∗  P'˂ .!  ⊢[< ι ][ i ]⇛  P˂ .! →
                R  ∗  (P˂ ↪[ i ]⇛ Q˂)  ⊢[ ι ]  P'˂ ↪[ i ]⇛ Q˂

  ↪⇛-monoʳᵘ :  Q˂ .!  ⊢[< ι ][ i ]⇛  Q'˂ .! →
               P˂ ↪[ i ]⇛ Q˂  ⊢[ ι ]  P˂ ↪[ i ]⇛ Q'˂

  ↪⇛-eatˡ⁻ʳ :  {{Basic R}}  →
    R  ∗  (P˂ ↪[ i ]⇛ Q˂)  ⊢[ ι ]  P˂ ↪[ i ]⇛ ¡ (R ∗ Q˂ .!)

  ↪⇛-frameˡ :  P˂ ↪[ i ]⇛ Q˂  ⊢[ ι ]  ¡ (R ∗ P˂ .!) ↪[ i ]⇛ ¡ (R ∗ Q˂ .!)

  -- Make ↪⇛ out of ○

  ○⇒↪⇛ :  P˂ .!  ∗  R˂ .! ⊢[< ι ][ i ]⇛  Q˂ .!  →   ○ R˂  ⊢[ ι ]  P˂ ↪[ i ]⇛ Q˂

  -- Use ↪⇛, with level increment
  -- Without that level increment, we could do any super update (⇛/↪⇛-use' in
  -- Syho.Logic.Paradox)

  ↪⇛-use :  P˂ .!  ∗  (P˂ ↪[ i ]⇛ Q˂)  ⊢[ ι ][ ṡ i ]⇛  Q˂ .!

  ------------------------------------------------------------------------------
  -- On ↪ᵃ⟨ ⟩

  -- Modify ᵃ⟨ ⟩ proof

  ↪ᵃ⟨⟩-≤ :  i ≤ j  →   P˂ ↪[ i ]ᵃ⟨ red ⟩ Q˂˙  ⊢[ ι ]  P˂ ↪[ j ]ᵃ⟨ red ⟩ Q˂˙

  ↪ᵃ⟨⟩-eatˡ⁻ˡᵘ :  {{Basic R}}  →   R  ∗  P'˂ .!  ⊢[< ι ][ i ]⇛  P˂ .!  →
                  R  ∗  (P˂ ↪[ j ]ᵃ⟨ red ⟩ Q˂˙)  ⊢[ ι ]  P'˂ ↪[ j ]ᵃ⟨ red ⟩ Q˂˙

  ↪ᵃ⟨⟩-monoʳᵘ :  (∀ v →  Q˂˙ v .!  ⊢[< ι ][ i ]⇛  Q'˂˙ v .!)  →
                 P˂ ↪[ j ]ᵃ⟨ red ⟩ Q˂˙  ⊢[ ι ]  P˂ ↪[ j ]ᵃ⟨ red ⟩ Q'˂˙

  ↪ᵃ⟨⟩-eatˡ⁻ʳ :  {{Basic R}}  →
    R  ∗  (P˂ ↪[ i ]ᵃ⟨ red ⟩ Q˂˙)  ⊢[ ι ]
      P˂ ↪[ i ]ᵃ⟨ red ⟩ λ v → ¡ (R ∗ Q˂˙ v .!)

  ↪ᵃ⟨⟩-frameˡ :  P˂ ↪[ i ]ᵃ⟨ red ⟩ Q˂˙  ⊢[ ι ]
                   ¡ (R ∗ P˂ .!) ↪[ i ]ᵃ⟨ red ⟩ λ v → ¡ (R ∗ Q˂˙ v .!)

  -- Make ↪⟨ ⟩ᵀ out of ○

  ○⇒↪ᵃ⟨⟩ :  P˂ .!  ∗  R˂ .! ⊢[< ι ][ i ]ᵃ⟨ red ⟩ (λ v →  Q˂˙ v .!)  →
            ○ R˂  ⊢[ ι ]  P˂ ↪[ i ]ᵃ⟨ red ⟩ Q˂˙

  -- Use ↪ᵃ⟨⟩, with level increment
  -- Without that level increment, we could have any atomic Hoare triple
  -- (ahor/↪ᵃ⟨⟩-use' in Syho.Logic.Paradox)

  ↪ᵃ⟨⟩-use :  P˂ .!  ∗  (P˂ ↪[ i ]ᵃ⟨ red ⟩ Q˂˙)
                ⊢[ ι ][ ṡ i ]ᵃ⟨ red ⟩ λ v →  Q˂˙ v .!

  ------------------------------------------------------------------------------
  -- On ↪⟨ ⟩[ ]

  -- Modify ⟨ ⟩ proof

  ↪⟨⟩ᵀ⇒↪⟨⟩ᴾ :  P˂ ↪⟨ e ⟩ᵀ[ i ] Q˂˙  ⊢[ ι ]  P˂ ↪⟨ e ⟩ᴾ Q˂˙

  ↪⟨⟩ᵀ-≤ :  i ≤ j  →   P˂ ↪⟨ e ⟩ᵀ[ i ] Q˂˙  ⊢[ ι ]  P˂ ↪⟨ e ⟩ᵀ[ j ] Q˂˙

  ↪⟨⟩-eatˡ⁻ˡᵘᴺ :  {{Basic R}}  →   R  ∗  P'˂ .!  ⊢[< ι ][ i ]⇛ᴺ  P˂ .!  →
                  R  ∗  (P˂ ↪⟨ e ⟩[ κ ] Q˂˙)  ⊢[ ι ]  P'˂ ↪⟨ e ⟩[ κ ] Q˂˙

  ↪⟨⟩-monoʳᵘᴺ :  (∀ v →  Q˂˙ v .!  ⊢[< ι ][ i ]⇛ᴺ  Q'˂˙ v .!)  →
                 P˂ ↪⟨ e ⟩[ κ ] Q˂˙  ⊢[ ι ]  P˂ ↪⟨ e ⟩[ κ ] Q'˂˙

  ↪⟨⟩-eatˡ⁻ʳ :  {{Basic R}}  →
    R  ∗  (P˂ ↪⟨ e ⟩[ κ ] Q˂˙)  ⊢[ ι ]  P˂ ↪⟨ e ⟩[ κ ] λ v → ¡ (R ∗ Q˂˙ v .!)

  ↪⟨⟩-frameˡ :  P˂ ↪⟨ e ⟩[ κ ] Q˂˙  ⊢[ ι ]
                  ¡ (R ∗ P˂ .!) ↪⟨ e ⟩[ κ ] λ v → ¡ (R ∗ Q˂˙ v .!)

  -- Make ↪⟨ ⟩ out of ○

  ○⇒↪⟨⟩ :  P˂ .!  ∗  R˂ .!  ⊢[< ι ]⟨ e ⟩[ κ ] (λ v →  Q˂˙ v .!)  →
           ○ R˂  ⊢[ ι ]  P˂ ↪⟨ e ⟩[ κ ] Q˂˙

  -- Use ↪⟨⟩ᴾ, with pure reduction
  -- Without pure reduction, we could have any partial Hoare triple
  -- (horᴾ/↪⟨⟩ᴾ-use' in Syho.Logic.Paradox)

  ↪⟨⟩ᴾ-use :  e ⇒ᴾ e'  →
    P˂ .!  ∗  (P˂ ↪⟨ e' ⟩ᴾ Q˂˙)  ⊢[ ι ]⟨ e ⟩ᴾ λ v →  Q˂˙ v .!

  -- Use ↪⟨⟩ᵀ, with level increment

  -- Without that level increment, we could have any total Hoare triple
  -- (horᵀ/↪⟨⟩ᵀ-use' in Syho.Logic.Paradox)
  -- If we use pure reduction (just like ↪⟨⟩ᴾ-use) instead of level increment
  -- for this rule, the total Hoare triple does not ensure termination
  -- (horᵀ-loop/↪⟨⟩ᵀ-use⇒ᴾ in Syho.Logic.Paradox)

  ↪⟨⟩ᵀ-use :  P˂ .!  ∗  (P˂ ↪⟨ e ⟩ᵀ[ i ] Q˂˙)
                ⊢[ ι ]⟨ e ⟩ᵀ[ ṡ i ] λ v →  Q˂˙ v .!

  ------------------------------------------------------------------------------
  -- On ↪⟨ ⟩∞

  -- Modify ⟨ ⟩∞ proof

  ↪⟨⟩∞-≤ :  i ≤ j  →   P˂ ↪[ i ]⟨ e ⟩∞  ⊢[ ι ]  P˂ ↪[ j ]⟨ e ⟩∞

  ↪⟨⟩∞-eatˡ⁻ᵘᴺ :  {{Basic R}}  →   R  ∗  Q˂ .!  ⊢[< ι ][ i ]⇛ᴺ  P˂ .!  →
                  R  ∗  (P˂ ↪[ j ]⟨ e ⟩∞)  ⊢[ ι ]  Q˂ ↪[ j ]⟨ e ⟩∞

  -- Make ↪⟨ ⟩∞ out of ○

  ○⇒↪⟨⟩∞ :  P˂ .!  ∗  Q˂ .!  ⊢[< ι ][ i ]⟨ e ⟩∞   →
            ○ Q˂  ⊢[ ι ]  P˂ ↪[ i ]⟨ e ⟩∞

  -- Use ↪⟨⟩∞, with level increment
  -- Without that level increment, we could have any infinite Hoare triple
  -- (ihor/↪⟨⟩∞-use' in Syho.Logic.Paradox)

  ↪⟨⟩∞-use :  P˂ .!  ∗  (P˂ ↪[ i ]⟨ e ⟩∞)  ⊢[ ι ][ ṡ i ]⟨ e ⟩∞

  ------------------------------------------------------------------------------
  -- On the impredicative invariant

  -- Update the set part of an name set token

  []ᴺ-resp :  Nm ≡˙ Nm' →  [ Nm ]ᴺ ⊢[ ι ] [ Nm' ]ᴺ

  -- Merge and split name set tokens w.r.t. the set sum

  []ᴺ-merge :  [ Nm ]ᴺ  ∗  [ Nm' ]ᴺ  ⊢[ ι ]  [ Nm ⊎ᶻ Nm' ]ᴺ

  []ᴺ-split :  [ Nm ⊎ᶻ Nm' ]ᴺ  ⊢[ ι ]  [ Nm ]ᴺ  ∗  [ Nm' ]ᴺ

  -- The set of an name set token is valid

  []ᴺ-✔ :  [ Nm ]ᴺ  ⊢[ ι ]  ⌜ ✔ᶻ Nm ⌝

  -- An invariant token is persistent

  &ⁱ-⇒□ :  &ⁱ⟨ nm ⟩ P˂  ⊢[ ι ]  □ &ⁱ⟨ nm ⟩ P˂

  -- Modify an invariant token using a persistent basic proposition

  &ⁱ-resp-□∧ :  {{Basic R}}  →
    R  ∧  P˂ .!  ⊢[< ι ]  Q˂ .!  →   R  ∧  Q˂ .!  ⊢[< ι ]  P˂ .!  →
    □ R  ∧  &ⁱ⟨ nm ⟩ P˂  ⊢[ ι ]  &ⁱ⟨ nm ⟩ Q˂

  -- Monotonicity of the open invariant token

  %ⁱ-mono :  P˂ .!  ⊢[< ι ]  Q˂ .!  →   %ⁱ⟨ nm ⟩ Q˂  ⊢[ ι ]  %ⁱ⟨ nm ⟩ P˂

  -- Let an open invariant token eat a basic proposition

  %ⁱ-eatˡ :  {{Basic Q}} →  Q  ∗  %ⁱ⟨ nm ⟩ P˂  ⊢[ ι ]  %ⁱ⟨ nm ⟩ ¡ (Q -∗ P˂ .!)

  -- Get &ⁱ⟨ nm ⟩ P˂ by storing P˂ minus &ⁱ⟨ nm ⟩ P˂

  &ⁱ-alloc-rec :  &ⁱ⟨ nm ⟩ P˂ -∗ P˂ .!  ⊢[ ι ][ i ]⇛  &ⁱ⟨ nm ⟩ P˂

  -- Open an invariant with a name token, getting an open invariant token

  -- Notably, the proposition P˂ .! is directly obtained, without any guard like
  -- the later modality as in Iris

  &ⁱ-open :  &ⁱ⟨ nm ⟩ P˂  ∗  [^ nm ]ᴺ  ⊢[ ι ][ i ]⇛  P˂ .!  ∗  %ⁱ⟨ nm ⟩ P˂

  -- Retrieve a name token out of an open invariant token and its proposition

  %ⁱ-close :  P˂ .!  ∗  %ⁱ⟨ nm ⟩ P˂  ⊢[ ι ][ i ]⇛  [^ nm ]ᴺ

  ------------------------------------------------------------------------------
  -- On lifetimes

  -- Merge and split lifetime tokens w.r.t. the fraction

  []ᴸ⟨⟩-merge :  [ α ]ᴸ⟨ p ⟩  ∗  [ α ]ᴸ⟨ q ⟩  ⊢[ ι ]  [ α ]ᴸ⟨ p +ᴿ⁺ q ⟩

  []ᴸ⟨⟩-split :  [ α ]ᴸ⟨ p +ᴿ⁺ q ⟩  ⊢[ ι ]  [ α ]ᴸ⟨ p ⟩  ∗  [ α ]ᴸ⟨ q ⟩

  -- The fraction of the lifetime token is no more than 1

  []ᴸ⟨⟩-≤1 :  [ α ]ᴸ⟨ p ⟩  ⊢[ ι ]  ⌜ p ≤1ᴿ⁺ ⌝

  -- The dead lifetime token is persistent

  †ᴸ-⇒□ :  †ᴸ α  ⊢[ ι ]  □ †ᴸ α

  -- The lifetime and dead lifetime tokens for a lifetime cannot coexist

  []ᴸ⟨⟩-†ᴸ-no :  [ α ]ᴸ⟨ p ⟩  ∗  †ᴸ α  ⊢[ ι ]  ⊥'

  -- Allocate a new lifetime

  []ᴸ-alloc :  ⊤'  ⊢[ ι ] ⤇  ∃ α , [ α ]ᴸ
