--------------------------------------------------------------------------------
-- Proposition
--------------------------------------------------------------------------------

{-# OPTIONS --without-K --sized-types #-}

module Syho.Logic.Prop where

open import Base.Level using (Level; Up; ↓)
open import Base.Func using (_$_; _∘_; it)
open import Base.Few using (binary; absurd)
open import Base.Size using (Size; ∞; Thunk)
open import Base.Prod using (_×_; _,_; curry)
open import Base.Nat using (ℕ)
open import Base.List using (List; []; _∷_; _$ᴸ_; _$ⁱᴸ_; _$ⁱᴸ⟨_⟩_)
open import Base.RatPos using (ℚ⁺; 1ᴿ⁺)
open import Syho.Lang.Expr using (Addr; _ₒ_; Type; Expr; Val; TyVal)

--------------------------------------------------------------------------------
-- Prop' :  Proposition

data  Prop' (ι : Size) :  Set₂

-- Prop˂ :  Prop' under Thunk
Prop˂ :  Size →  Set₂
Prop˂ ι =  Thunk Prop' ι

private variable
  ι :  Size
  ł :  Level
  X :  Set ł
  P˙ :  X → Prop' ∞
  P Q :  Prop' ∞
  n :  ℕ
  θ :  Addr
  q⁺ :  ℚ⁺
  ᵗv :  TyVal
  T :  Type

infixr 5 _→'_ _-∗_ _↪[_]⇛_ _↪⟨_⟩ᴾ_ _↪⟨_⟩ᵀ[_]_
infixr 7 _∗_
infix 8 ⤇_ □_ ○_
infix 9 _↦⟨_⟩_

data  Prop' ι  where

  -- ∀₁˙, ∃₁˙ :  Universal/existential quantification over any type X in Set₁,
  --             which does not include Prop' ι itself (predicativity)
  ∀₁˙ ∃₁˙ :  ∀{X : Set₁} →  (X → Prop' ι) →  Prop' ι

  -- →' :  Implication
  _→'_ :  Prop' ι →  Prop' ι →  Prop' ι

  -- ∗ :  Separating conjunction
  _∗_ :  Prop' ι →  Prop' ι →  Prop' ι

  -- -∗ :  Magic wand
  _-∗_ :  Prop' ι →  Prop' ι →  Prop' ι

  -- ⤇ :  Update modality
  ⤇_ :  Prop' ι →  Prop' ι

  -- □ :  Persistence modality
  □_ :  Prop' ι →  Prop' ι

  -- ○ :  Indirection modality
  ○_ :  Prop˂ ι →  Prop' ι

  -- ↪[ ]⇛ :  Super-update precursor
  _↪[_]⇛_ :  Prop˂ ι →  ℕ →  Prop˂ ι →  Prop' ι

  -- ↪⟨ ⟩ᴾ, ↪⟨ ⟩ᵀ[ ] :  Partial/total Hoare-triple precursor
  _↪⟨_⟩ᴾ_ :  Prop˂ ι →  Expr ∞ T →  (Val T → Prop˂ ∞) →  Prop' ι
  _↪⟨_⟩ᵀ[_]_ :  Prop˂ ι →  Expr ∞ T →  ℕ →  (Val T → Prop˂ ∞) →  Prop' ι

  -- ↦⟨ ⟩ :  Points-to token
  _↦⟨_⟩_ :  Addr →  ℚ⁺ →  TyVal →  Prop' ι

  -- Free :  Freeing token
  Free :  ℕ →  Addr →  Prop' ι

--------------------------------------------------------------------------------
-- Utility for ∀/∃

∀₁∈-syntax ∃₁∈-syntax ∀₁-syntax ∃₁-syntax :
  ∀{X : Set₁} →  (X → Prop' ι) →  Prop' ι
∀₁∈-syntax =  ∀₁˙
∃₁∈-syntax =  ∃₁˙
∀₁-syntax =  ∀₁˙
∃₁-syntax =  ∃₁˙

∀₀˙ ∃₀˙ ∀₀∈-syntax ∃₀∈-syntax ∀₀-syntax ∃₀-syntax :
  ∀{X : Set₀} →  (X → Prop' ι) →  Prop' ι
∀₀˙ P˙ =  ∀₁˙ $ P˙ ∘ ↓
∃₀˙ P˙ =  ∃₁˙ $ P˙ ∘ ↓
∀₀∈-syntax =  ∀₀˙
∃₀∈-syntax =  ∃₀˙
∀₀-syntax =  ∀₀˙
∃₀-syntax =  ∃₀˙
infix 3 ∀₁∈-syntax ∃₁∈-syntax ∀₁-syntax ∃₁-syntax
  ∀₀∈-syntax ∃₀∈-syntax ∀₀-syntax ∃₀-syntax
syntax ∀₁∈-syntax {X = X} (λ x → P) =  ∀₁ x ∈ X , P
syntax ∃₁∈-syntax {X = X} (λ x → P) =  ∃₁ x ∈ X , P
syntax ∀₁-syntax (λ x → P) =  ∀₁ x , P
syntax ∃₁-syntax (λ x → P) =  ∃₁ x , P
syntax ∀₀∈-syntax {X = X} (λ x → P) =  ∀₀ x ∈ X , P
syntax ∃₀∈-syntax {X = X} (λ x → P) =  ∃₀ x ∈ X , P
syntax ∀₀-syntax (λ x → P) =  ∀₀ x , P
syntax ∃₀-syntax (λ x → P) =  ∃₀ x , P

--------------------------------------------------------------------------------
-- ∧ :  Conjunction
-- ∨ :  Disjunction

infixr 7 _∧_
infixr 6 _∨_

_∧_ _∨_ :  Prop' ι →  Prop' ι →  Prop' ι
P ∧ Q =  ∀₁˙ (binary P Q)
P ∨ Q =  ∃₁˙ (binary P Q)

--------------------------------------------------------------------------------
-- ⊤' :  Truth
-- ⊥' :  Falsehood

⊤' ⊥' :  Prop' ι
⊤' =  ∀₁˙ absurd
⊥' =  ∃₁˙ absurd

--------------------------------------------------------------------------------
-- ⌜ ⌝ :  Set embedding

⌜_⌝₁ :  Set₁ →  Prop' ι
⌜ X ⌝₁ =  ∃₁ _ ∈ X , ⊤'
⌜_⌝₀ :  Set₀ →  Prop' ι
⌜ X ⌝₀ =  ⌜ Up X ⌝₁

--------------------------------------------------------------------------------
-- [∗] :  Iterated separating conjunction

[∗] :  List (Prop' ι) →  Prop' ι
[∗] [] =  ⊤'
[∗] (P ∷ Ps) =  P ∗ [∗] Ps

-- Syntax for [∗] $ᴸ / $ⁱᴸ

infix 8 [∗∈]-syntax [∗∈ⁱ]-syntax [∗∈ⁱ⟨⟩]-syntax
[∗∈] [∗∈]-syntax :  (X → Prop' ι) →  List X →  Prop' ι
[∗∈] P˙ xs =  [∗] (P˙ $ᴸ xs)
[∗∈]-syntax =  [∗∈]
[∗∈ⁱ] [∗∈ⁱ]-syntax :  (ℕ × X → Prop' ι) →  List X →  Prop' ι
[∗∈ⁱ] P˙ xs =  [∗] (curry P˙ $ⁱᴸ xs)
[∗∈ⁱ]-syntax =  [∗∈ⁱ]
[∗∈ⁱ⟨⟩] [∗∈ⁱ⟨⟩]-syntax :  (ℕ × X → Prop' ι) →  ℕ →  List X →  Prop' ι
[∗∈ⁱ⟨⟩] P˙ k xs =  [∗] (curry P˙ $ⁱᴸ⟨ k ⟩ xs)
[∗∈ⁱ⟨⟩]-syntax =  [∗∈ⁱ⟨⟩]
syntax [∗∈]-syntax (λ x → P) xs =  [∗ x ∈ xs ] P
syntax [∗∈ⁱ]-syntax (λ ix → P) xs =  [∗ ix ∈ⁱ xs ] P
syntax [∗∈ⁱ⟨⟩]-syntax (λ ix → P) k xs =  [∗ ix ∈ⁱ⟨ k ⟩ xs ] P

--------------------------------------------------------------------------------
-- Extending _↦⟨_⟩_

infix 9 _↦_ _↦ᴸ⟨_⟩_ _↦ᴸ_

-- Full points-to token
_↦_ :  Addr →  TyVal →  Prop' ι
θ ↦ ᵗv =  θ ↦⟨ 1ᴿ⁺ ⟩ ᵗv

-- Iterated points-to token
_↦ᴸ⟨_⟩_ :  Addr →  ℚ⁺ →  List TyVal →  Prop' ι
θ ↦ᴸ⟨ p ⟩ ᵗvs =  [∗ (i , ᵗv) ∈ⁱ ᵗvs ] θ ₒ i ↦⟨ p ⟩ ᵗv
_↦ᴸ_ :  Addr →  List TyVal →  Prop' ι
θ ↦ᴸ ᵗvs =  θ ↦ᴸ⟨ 1ᴿ⁺ ⟩ ᵗvs

--------------------------------------------------------------------------------
-- Basic P :  P doesn't contain impredicate connectives

data  Basic :  Prop' ∞ →  Set₂  where

  -- They are not instances, because unfortunately Agda can't search a
  -- universally quantified instance (∀ x → …)

  ∀₁-Basic :  (∀ x → Basic (P˙ x)) →  Basic (∀₁˙ P˙)
  ∃₁-Basic :  (∀ x → Basic (P˙ x)) →  Basic (∃₁˙ P˙)

  -- Instance data constructors
  instance

    →-Basic :  {{Basic P}} →  {{Basic Q}} →  Basic (P →' Q)
    ∗-Basic :  {{Basic P}} →  {{Basic Q}} →  Basic (P ∗ Q)
    -∗-Basic :  {{Basic P}} →  {{Basic Q}} →  Basic (P -∗ Q)
    ⤇-Basic :  {{Basic P}} →  Basic (⤇ P)
    □-Basic :  {{Basic P}} →  Basic (□ P)
    ↦⟨⟩-Basic :  Basic (θ ↦⟨ q⁺ ⟩ ᵗv)
    Free-Basic :  Basic (Free n θ)


-- For ∀/∃₀

∀₀-Basic :  (∀ x → Basic (P˙ x)) →  Basic (∀₀˙ P˙)
∀₀-Basic =  ∀₁-Basic ∘ _∘ ↓

∃₀-Basic :  (∀ x → Basic (P˙ x)) →  Basic (∃₀˙ P˙)
∃₀-Basic =  ∃₁-Basic ∘ _∘ ↓

instance

  -- For ∧/∨/⊤'/⊥'

  ∧-Basic :  {{Basic P}} →  {{Basic Q}} →  Basic (P ∧ Q)
  ∧-Basic =  ∀₁-Basic $ binary it it

  ∨-Basic :  {{Basic P}} →  {{Basic Q}} →  Basic (P ∨ Q)
  ∨-Basic =  ∃₁-Basic $ binary it it

  ⊤-Basic :  Basic ⊤'
  ⊤-Basic =  ∀₁-Basic absurd

  ⊥-Basic :  Basic ⊥'
  ⊥-Basic =  ∃₁-Basic absurd

  -- For ⌜ ⌝

  ---- This can work also for ⌜⌝₀

  ⌜⌝-Basic :  Basic ⌜ X ⌝₁
  ⌜⌝-Basic =  ∃₁-Basic λ _ → ⊤-Basic
