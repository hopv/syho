--------------------------------------------------------------------------------
-- Reduction
--------------------------------------------------------------------------------

{-# OPTIONS --without-K --sized-types #-}

module Syho.Lang.Reduce where

open import Base.Func using (_$_; flip)
open import Base.Few using (⊤)
open import Base.Eq using (_≡_; _≢_; refl; ◠_)
open import Base.Dec using (upd˙)
open import Base.Size using (Size; ∞; Thunk; !)
open import Base.Bool using (tt; ff)
open import Base.Option using (¿_; š_; ň; ¿-case; _$¿_; _»-¿_)
open import Base.Prod using (∑-syntax; _×_; _,_; -,_)
open import Base.Sum using (ĩ₁_)
open import Base.Nat using (ℕ; Cofin˙; ∀⇒Cofin˙; Cofin˙-upd˙; Cofin˙-∑)
open import Base.List using (List; _∷_; _‼_; upd; rep)
open import Base.Sety using (Setʸ; ⸨_⸩ʸ)
open import Syho.Lang.Expr using (Type; ◸ʸ_; ◸_; Addr; Expr; Expr˂; ∇_; Val;
  V⇒E; TyVal; ⊤-)
open import Syho.Lang.Ktxred using (Redex; ▶ᴿ_; ndᴿ; _◁ᴿ_; _⁏ᴿ_; forkᴿ; 🞰ᴿ_;
  _←ᴿ_; fauᴿ; casᴿ; allocᴿ; freeᴿ; Ktx; _ᴷ◁_; Ktxred; val/ktxred)

--------------------------------------------------------------------------------
-- Memory

-- Mblo :  Memory block state
-- Mem :  Memory state
Mblo Mem :  Set₀
Mblo =  ¿ List TyVal
Mem =  ℕ →  Mblo

private variable
  M M' M'' :  Mem
  Mb :  Mblo
  o :  ℕ
  θ :  Addr
  ᵗv :  TyVal

-- Memory read

infix 5 _‼ᴹ_
_‼ᴹ_ :  Mem →  Addr →  ¿ TyVal
M ‼ᴹ (o , i) =  M o »-¿ _‼ i

-- Empty memory

empᴹ :  Mem
empᴹ _ =  ň

-- Memory update

updᴹ :  Addr →  TyVal →  Mem →  Mem
updᴹ (o , i) ᵗv M =  upd˙ o (upd i ᵗv $¿ M o) M

-- Memory validity

infix 3 ✓ᴹ_
✓ᴹ_ :  Mem →  Set₀
✓ᴹ M =  Cofin˙ (λ _ → _≡ ň) M

abstract

  -- ✓ᴹ holds for empᴹ

  ✓ᴹ-empᴹ :  ✓ᴹ empᴹ
  ✓ᴹ-empᴹ =  ∀⇒Cofin˙ {F = λ _ → _≡ ň} λ _ → refl

  -- ✓ᴹ is preserved by upd˙ and updᴹ

  ✓ᴹ-upd˙ :  ✓ᴹ M →  ✓ᴹ (upd˙ o Mb M)
  ✓ᴹ-upd˙ =  Cofin˙-upd˙ {F = λ _ → _≡ ň}

  -- If ✓ᴹ M holds, then M o ≡ ň for some o

  ✓ᴹ-∑ň :  ✓ᴹ M →  ∑ o , M o ≡ ň
  ✓ᴹ-∑ň =  Cofin˙-∑ {F = λ _ → _≡ ň}

--------------------------------------------------------------------------------
-- Reduction

private variable
  T U :  Type
  Xʸ :  Setʸ
  X :  Set₀
  e₀ e e' e'' :  Expr ∞ T
  e˂ :  Expr˂ ∞ T
  e˙ :  ⸨ Xʸ ⸩ʸ → Expr ∞ T
  eˇ :  ¿ Expr ∞ (◸ ⊤)
  es es' es'' :  List (Expr ∞ (◸ ⊤))
  K :  Ktx T U
  red : Redex T
  v x y :  X
  f :  X → X
  n :  ℕ
  kr :  Ktxred T
  ι :  Size

infix 4 _⇒ᴿ_ _⇒ᴷᴿ_ _⇒ᴱ_ _⇒ᵀ_ _⇐ᴷᴿ_ _⇐ᴱ_ _⇐ᵀ_

-- ⇒ᴿ :  Reduction of a redex
--       The ¿ Expr ∞ (◸ ⊤) part is a possibly forked thread

data  _⇒ᴿ_ :  Redex T × Mem →  Expr ∞ T × ¿ Expr ∞ (◸ ⊤) × Mem →  Set₀  where

  -- For ▶
  ▶⇒ :  (▶ᴿ e˂ , M) ⇒ᴿ (e˂ .! , ň , M)

  -- For nd
  nd⇒ :  ∀(x : ⸨ Xʸ ⸩ʸ) →  (ndᴿ , M) ⇒ᴿ (∇ x , ň , M)

  -- For ◁
  ◁⇒ :  ∀{x : ⸨ Xʸ ⸩ʸ} →  (e˙ ◁ᴿ x , M) ⇒ᴿ (e˙ x , ň , M)

  -- For ⁏
  ⁏⇒ :  (_⁏ᴿ_ {T} v e , M) ⇒ᴿ (e , ň , M)

  -- For fork
  fork⇒ :  (forkᴿ e , M) ⇒ᴿ (∇ _ , š e , M)

  -- For 🞰
  🞰⇒ :  M ‼ᴹ θ ≡ š (T , v) →  (🞰ᴿ θ , M) ⇒ᴿ (V⇒E {T} v , ň , M)

  -- For ←, with a check that θ is in the domain of M
  ←⇒ :  ∑ ᵗu , M ‼ᴹ θ ≡ š ᵗu →
        (_←ᴿ_ {T} θ v , M) ⇒ᴿ (∇ _ , ň , updᴹ θ (T , v) M)

  -- For fau
  fau⇒ :  M ‼ᴹ θ ≡ š (◸ʸ Xʸ , x) →
          (fauᴿ f θ , M) ⇒ᴿ (∇ x , ň , updᴹ θ (-, f x) M)

  -- For cas, the success and failure cases
  cas⇒-tt :  M ‼ᴹ θ ≡ š (◸ʸ Xʸ , x) →
             (casᴿ θ x y , M) ⇒ᴿ (∇ tt , ň , updᴹ θ (-, y) M)
  cas⇒-ff :  ∑ z , M ‼ᴹ θ ≡ š (◸ʸ Xʸ , z) × z ≢ x →
             (casᴿ θ x y , M) ⇒ᴿ (∇ ff , ň , M)

  -- For alloc, for any o out of the domain of M
  alloc⇒ :  ∀ o →  M o ≡ ň →
    (allocᴿ n , M) ⇒ᴿ (∇ (o , 0) , ň , upd˙ o (š rep n ⊤-) M)

  -- For free, with a check that o is in the domain of M
  free⇒ :  ∑ ᵗvs , M o ≡ š ᵗvs →  (freeᴿ (o , 0) , M) ⇒ᴿ (∇ _ , ň , upd˙ o ň M)

-- ⇒ᴷᴿ :  Reduction of a context-redex pair

data  _⇒ᴷᴿ_ :  Ktxred T × Mem →  Expr ∞ T × ¿ Expr ∞ (◸ ⊤) × Mem →  Set₀  where
  redᴷᴿ :  (red , M) ⇒ᴿ (e' , eˇ , M') →
           ((-, K , red) , M) ⇒ᴷᴿ (K ᴷ◁ e' , eˇ , M')

-- ⇒ᴱ :  Reduction of an expression

data  _⇒ᴱ_ :  Expr ∞ T × Mem →  Expr ∞ T × ¿ Expr ∞ (◸ ⊤) × Mem →  Set₀  where
  redᴱ :  val/ktxred e ≡ ĩ₁ kr →  (kr , M) ⇒ᴷᴿ (e' , eˇ , M') →
          (e , M) ⇒ᴱ (e' , eˇ , M')

-- ⇒ᵀ :  Reduction of a thread list

data  _⇒ᵀ_ :  Expr ∞ T × List (Expr ∞ (◸ ⊤)) × Mem →
              Expr ∞ T × List (Expr ∞ (◸ ⊤)) × Mem →  Set₀  where
  -- Reduce the head thread
  redᵀ-hd :  (e , M) ⇒ᴱ (e' , eˇ , M') →
             (e , es , M) ⇒ᵀ (e' , ¿-case (_∷ es) es eˇ , M')

  -- Continue to the tail threads
  redᵀ-tl :  (e , es , M) ⇒ᵀ (e' , es' , M') →
             (e₀ , e ∷ es , M) ⇒ᵀ (e₀ , e' ∷ es' , M')

-- ⇐ᴷᴿ, ⇐ᴱ, ⇐ᵀ :  Flipped ⇒ᴷᴿ, ⇒ᴱ, ⇒ᵀ

_⇐ᴷᴿ_ :  Expr ∞ T × ¿ Expr ∞ (◸ ⊤) × Mem →  Ktxred T × Mem →  Set₀
_⇐ᴷᴿ_ =  flip _⇒ᴷᴿ_

_⇐ᴱ_ :  Expr ∞ T × ¿ Expr ∞ (◸ ⊤) × Mem →  Expr ∞ T × Mem →  Set₀
_⇐ᴱ_ =  flip _⇒ᴱ_

_⇐ᵀ_ :  Expr ∞ T × List (Expr ∞ (◸ ⊤)) × Mem →
        Expr ∞ T × List (Expr ∞ (◸ ⊤)) × Mem →  Set₀
_⇐ᵀ_ =  flip _⇒ᵀ_

-- ⇒ᴷᴿ∑ :  A contex-redex pair is reducible

infix 4 _⇒ᴷᴿ∑
_⇒ᴷᴿ∑ :  ∀{T} →  Ktxred T × Mem →  Set₀
redM ⇒ᴷᴿ∑ =  ∑ e'M' , redM ⇒ᴷᴿ e'M'

--------------------------------------------------------------------------------
-- ⇒ᵀ* :  Finite reduction sequence

infix 4 _⇒ᵀ*_

data  _⇒ᵀ*_ :  Expr ∞ T × List (Expr ∞ (◸ ⊤)) × Mem →
               Expr ∞ T × List (Expr ∞ (◸ ⊤)) × Mem →  Set₀  where

  -- End reduction
  ⇒ᵀ*-refl :  (e , es , M) ⇒ᵀ* (e , es , M)

  -- Continue reduction
  ⇒ᵀ*-step :  (e , es , M) ⇒ᵀ (e' , es' , M') →
              (e' , es' , M') ⇒ᵀ* (e'' , es'' , M'') →
              (e , es , M) ⇒ᵀ* (e'' , es'' , M'')
