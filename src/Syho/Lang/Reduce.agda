--------------------------------------------------------------------------------
-- Reduction
--------------------------------------------------------------------------------

{-# OPTIONS --without-K --sized-types #-}

module Syho.Lang.Reduce where

open import Base.Level using (↑_)
open import Base.Size using (∞)
open import Base.Func using (_$_)
open import Base.Eq using (_≡_; refl; ◠_)
open import Base.Thunk using (!)
open import Base.Prod using (∑-syntax; _×_; _,_; -,_)
open import Base.Sum using (ĩ₁_)
open import Base.Option using (¿_; š_; ň; _$¿_; _»-¿_)
open import Base.Nat using (ℕ)
open import Base.List using (List)
open import Base.List.Nat using (_‼_; upd; rep)
open import Base.Natmap using (updᴺᴹ; Cofin; ∀⇒Cofin; Cofin-updᴺᴹ)
open import Syho.Lang.Expr using (Type; ◸_; Addr; addr; Expr; Expr˂; ∇_; Val;
  V⇒E; AnyVal; ⊤ṽ)
open import Syho.Lang.Ktxred using (Redex; ▶ᴿ_; ndᴿ; _◁ᴿ_; _⁏ᴿ_; 🞰ᴿ_; _←ᴿ_;
  allocᴿ; freeᴿ; Ktx; _ᴷ◁_; ᴷ∘ᴷ-ᴷ◁; Ktxred; _ᴷ|_; val/ktxred; nonval;
  val/ktxred-ktx; val/ktxred-ktx-inv)

--------------------------------------------------------------------------------
-- Memory

Mem :  Set₁
Mem =  ℕ →  ¿ List AnyVal

private variable
  M M' :  Mem
  l :  ℕ
  av :  AnyVal
  avs¿ :  ¿ List AnyVal
  θ :  Addr

-- Memory read

infix 5 _‼ᴹ_
_‼ᴹ_ :  Mem →  Addr →  ¿ AnyVal
M ‼ᴹ addr l i =  M l »-¿ _‼ i

-- Empty memory

empᴹ :  Mem
empᴹ _ =  ň

-- Memory update

updᴹ :  Addr →  AnyVal →  Mem →  Mem
updᴹ (addr l i) av M =  updᴺᴹ l (upd i av $¿ M l) M

-- Memory validity

infix 3 ✓ᴹ_
✓ᴹ_ :  Mem →  Set₁
✓ᴹ M =  Cofin (λ _ → _≡ ň) M

abstract

  -- ✓ᴹ holds for empᴹ

  ✓ᴹ-empᴹ :  ✓ᴹ empᴹ
  ✓ᴹ-empᴹ =  ∀⇒Cofin {F = λ _ → _≡ ň} λ _ → refl

  -- ✓ᴹ is preserved by updᴺᴹ and updᴹ

  ✓ᴹ-updᴺᴹ :  ✓ᴹ M →  ✓ᴹ (updᴺᴹ l avs¿ M)
  ✓ᴹ-updᴺᴹ =  Cofin-updᴺᴹ {F = λ _ → _≡ ň}

  ✓ᴹ-updᴹ :  ✓ᴹ M →  ✓ᴹ (updᴹ θ av M)
  ✓ᴹ-updᴹ =  ✓ᴹ-updᴺᴹ

--------------------------------------------------------------------------------
-- Reduction

private variable
  T U V :  Type
  X :  Set₀
  e e' e'' :  Expr ∞ T
  e˂ :  Expr˂ ∞ T
  e˙ :  X → Expr ∞ T
  K :  Ktx U T
  red : Redex T
  x :  X
  v :  Val V
  n :  ℕ
  kr :  Ktxred T

infix 4 _⇒ᴿ_ _⇒ᴷᴿ_

-- Reduction on a redex

data  _⇒ᴿ_ :  ∀{T} →  (Redex T × Mem) →  (Expr ∞ T × Mem) →  Set₁  where
  ▶-red :  (▶ᴿ e˂ , M) ⇒ᴿ (e˂ .! , M)
  nd-red :  ∀(x : X) →  (ndᴿ , M) ⇒ᴿ (∇ x , M)
  ◁-red :  (e˙ ◁ᴿ x , M) ⇒ᴿ (e˙ x , M)
  ⁏-red :  (v ⁏ᴿ e , M) ⇒ᴿ (e , M)
  🞰-red :  M ‼ᴹ θ ≡ š (V , v) →  (🞰ᴿ θ , M) ⇒ᴿ (V⇒E v , M)
  ←-red :  (θ ←ᴿ v , M) ⇒ᴿ (∇ _ , updᴹ θ (V , v) M)
  alloc-red :  ∀ l →  M l ≡ ň →
    (allocᴿ n , M) ⇒ᴿ (∇ addr l 0 , updᴺᴹ l (š rep n ⊤ṽ) M)
  free-red :  (freeᴿ (addr l 0) , M) ⇒ᴿ (∇ _ , updᴺᴹ l ň M)

-- Reduction on a context-redex pair

data  _⇒ᴷᴿ_ {T} :  (Ktxred T × Mem) →  (Expr ∞ T × Mem) →  Set₁  where
  redᴷᴿ :  (red , M) ⇒ᴿ (e' , M') →  (K ᴷ| red , M) ⇒ᴷᴿ (K ᴷ◁ e' , M')

-- Reduction on an expression

data  _⇒ᴱ_ :  (Expr ∞ T × Mem) →  (Expr ∞ T × Mem) →  Set₁  where
  redᴱ :  val/ktxred e ≡ ĩ₁ kr →  (kr , M) ⇒ᴷᴿ (e' , M') →
          (e , M) ⇒ᴱ (e' , M')

abstract

  -- Enrich a reduction with an evaluation context

  red-ktx :  (e , M) ⇒ᴱ (e' , M') →  (K ᴷ◁ e , M) ⇒ᴱ (K ᴷ◁ e' , M')
  red-ktx {K = K} (redᴱ eq (redᴷᴿ {e' = e'} {K = K'} r⇒))
    rewrite ◠ ᴷ∘ᴷ-ᴷ◁ {K = K} {K' = K'} {e'}
    =  redᴱ (val/ktxred-ktx eq) (redᴷᴿ r⇒)

  -- Unwrap an evaluation context from a reduction

  red-ktx-inv :  nonval e →  (K ᴷ◁ e , M) ⇒ᴱ (e'' , M') →
                 ∑ e' ,  e'' ≡ K ᴷ◁ e'  ×  (e , M) ⇒ᴱ (e' , M')
  red-ktx-inv {K = K} nv'e (redᴱ eq (redᴷᴿ r⇒))  with val/ktxred-ktx-inv nv'e eq
  … | -, refl , eq' =  -, ᴷ∘ᴷ-ᴷ◁ {K = K} , redᴱ eq' $ redᴷᴿ r⇒
