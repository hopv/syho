--------------------------------------------------------------------------------
-- Reduction
--------------------------------------------------------------------------------

{-# OPTIONS --without-K --sized-types #-}

module Syho.Lang.Reduce where

open import Base.Func using (_$_; flip)
open import Base.Few using (⊤)
open import Base.Eq using (_≡_; _≢_; refl; ◠_)
open import Base.Dec using (upd˙)
open import Base.Bool using (Bool; tt; ff)
open import Base.Option using (¿_; š_; ň; ¿-case; _$¿_; _»-¿_)
open import Base.Prod using (∑-syntax; _×_; _,_; -,_)
open import Base.Sum using (ĩ₁_)
open import Base.Nat using (ℕ; Cofin˙; ∀⇒Cofin˙; Cofin˙-upd˙; Cofin˙-∑)
open import Base.List using (List; _∷_; ¿⇒ᴸ; _⧺_; _‼_; upd; rep)
open import Base.Sety using (Setʸ; ⸨_⸩ʸ)
open import Syho.Lang.Expr using (Type; ◸ʸ_; ◸_; Addr; Expr∞; Expr˂∞; ∇_; V⇒E;
  TyVal; ⊤-)
open import Syho.Lang.Ktxred using (Redex; ndᴿ; [_]ᴿ⟨_⟩; forkᴿ; 🞰ᴿ_; _←ᴿ_; fauᴿ;
  casᴿ; allocᴿ; freeᴿ; Ktx; _ᴷ◁_; Ktxred; val/ktxred)

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

-- Memory validity, saying that the domain of the memory is a finite set

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
  b :  Bool
  e₀ e e' e'' :  Expr∞ T
  e˂ :  Expr˂∞ T
  e˙ :  ⸨ Xʸ ⸩ʸ → Expr∞ T
  eˇ :  ¿ Expr∞ (◸ ⊤)
  es es' es'' :  List (Expr∞ (◸ ⊤))
  K :  Ktx T U
  red : Redex T
  v x y z :  X
  ᵗu :  TyVal
  f :  X → X
  n :  ℕ
  kr :  Ktxred T

infix 4 _⇒ᴾ_ _⇒ᴿ⟨_⟩_ _⇒ᴿ○_ _⇒ᴿ_ _⇒ᴷᴿ⟨_⟩_ _⇒ᴷᴿ_ _⇒ᴱ⟨_⟩_ _⇒ᴱ_ _⇒ᵀ⟨_⟩_ _⇒ᵀ_ _⇐ᴿ_
  _⇐ᴷᴿ_ _⇐ᴱ_ _⇐ᵀ_ _⇒ᴿ∑ _⇒ᴷᴿ∑

-- ⇒ᴾ :  Pure reduction of an expression

data  _⇒ᴾ_ :  Expr∞ T →  Expr∞ T →  Set₀  where
  redᴾ :  val/ktxred e ≡ ĩ₁ (-, K , [ e₀ ]ᴿ⟨ b ⟩) →  e ⇒ᴾ K ᴷ◁ e₀

-- ⇒ᴿ :  Reduction of a redex
--       The Bool part is the event flag
--       The ¿ Expr∞ (◸ ⊤) part is a possibly forked thread

data  _⇒ᴿ⟨_⟩_ :  Redex T × Mem →  Bool →  Expr∞ T × ¿ Expr∞ (◸ ⊤) × Mem →  Set₀

_⇒ᴿ○_ :  Redex T × Mem →  Expr∞ T × ¿ Expr∞ (◸ ⊤) × Mem →  Set₀
red ⇒ᴿ○ eeˇM =  red ⇒ᴿ⟨ ff ⟩ eeˇM

data _⇒ᴿ⟨_⟩_ where

  -- For nd
  nd⇒ :  ∀(x : ⸨ Xʸ ⸩ʸ) →  (ndᴿ , M) ⇒ᴿ○ (∇ x , ň , M)

  -- Pure reduction
  []⇒ :  ([ e ]ᴿ⟨ b ⟩ , M) ⇒ᴿ⟨ b ⟩ (e , ň , M)

  -- For fork
  fork⇒ :  (forkᴿ e , M) ⇒ᴿ○ (∇ _ , š e , M)

  -- For 🞰
  🞰⇒ :  M ‼ᴹ θ ≡ š (T , v) →  (🞰ᴿ θ , M) ⇒ᴿ○ (V⇒E {T} v , ň , M)

  -- For ←, with a check that θ is in the domain of M
  ←⇒ :  M ‼ᴹ θ ≡ š ᵗu →  (_←ᴿ_ {T} θ v , M) ⇒ᴿ○ (∇ _ , ň , updᴹ θ (T , v) M)

  -- For fau
  fau⇒ :  M ‼ᴹ θ ≡ š (◸ʸ Xʸ , x) →
          (fauᴿ f θ , M) ⇒ᴿ○ (∇ x , ň , updᴹ θ (-, f x) M)

  -- For cas, the success and failure cases
  cas⇒-tt :  M ‼ᴹ θ ≡ š (◸ʸ Xʸ , x) →
             (casᴿ θ x y , M) ⇒ᴿ○ (∇ tt , ň , updᴹ θ (-, y) M)
  cas⇒-ff :  M ‼ᴹ θ ≡ š (◸ʸ Xʸ , z) →  z ≢ x →
             (casᴿ θ x y , M) ⇒ᴿ○ (∇ ff , ň , M)

  -- For alloc, for any o out of the domain of M
  alloc⇒ :  ∀ o →  M o ≡ ň →
    (allocᴿ n , M) ⇒ᴿ○ (∇ (o , 0) , ň , upd˙ o (š rep n ⊤-) M)

  -- For free, with a check that o is in the domain of M
  free⇒ :  ∑ ᵗvs , M o ≡ š ᵗvs →
    (freeᴿ (o , 0) , M) ⇒ᴿ○ (∇ _ , ň , upd˙ o ň M)

_⇒ᴿ_ :  Redex T × Mem →  Expr∞ T × ¿ Expr∞ (◸ ⊤) × Mem →  Set₀
redM ⇒ᴿ eeˇM' =  ∑ b , redM ⇒ᴿ⟨ b ⟩ eeˇM'

-- ⇒ᴷᴿ :  Reduction of a context-redex pair

data  _⇒ᴷᴿ⟨_⟩_ :  Ktxred T × Mem →  Bool →  Expr∞ T × ¿ Expr∞ (◸ ⊤) × Mem →
                  Set₀  where
  redᴷᴿ :  (red , M) ⇒ᴿ⟨ b ⟩ (e , eˇ , M') →
           ((-, K , red) , M) ⇒ᴷᴿ⟨ b ⟩ (K ᴷ◁ e , eˇ , M')

_⇒ᴷᴿ_ :  Ktxred T × Mem →  Expr∞ T × ¿ Expr∞ (◸ ⊤) × Mem →  Set₀
krM ⇒ᴷᴿ eeˇM' =  ∑ b , krM ⇒ᴷᴿ⟨ b ⟩ eeˇM'

-- ⇒ᴱ :  Reduction of an expression

data  _⇒ᴱ⟨_⟩_ :  Expr∞ T × Mem →  Bool →  Expr∞ T × ¿ Expr∞ (◸ ⊤) × Mem →
                 Set₀  where
  redᴱ :  val/ktxred e ≡ ĩ₁ kr →  (kr , M) ⇒ᴷᴿ⟨ b ⟩ (e' , eˇ , M') →
          (e , M) ⇒ᴱ⟨ b ⟩ (e' , eˇ , M')

_⇒ᴱ_ :  Expr∞ T × Mem →  Expr∞ T × ¿ Expr∞ (◸ ⊤) × Mem →  Set₀
eM ⇒ᴱ e'eˇM' =  ∑ b , eM ⇒ᴱ⟨ b ⟩ e'eˇM'

-- ⇒ᵀ :  Reduction of a thread list
-- The Bool part is the event flag for the head thread only

data  _⇒ᵀ⟨_⟩_ :  Expr∞ T × List (Expr∞ (◸ ⊤)) × Mem →
                 Bool →  Expr∞ T × List (Expr∞ (◸ ⊤)) × Mem →  Set₀  where
  -- Reduce the head thread
  redᵀ-hd :  (e , M) ⇒ᴱ⟨ b ⟩ (e' , eˇ , M') →
             (e , es , M) ⇒ᵀ⟨ b ⟩ (e' , ¿⇒ᴸ eˇ ⧺ es , M')

  -- Continue to the tail threads
  redᵀ-tl :  (e , es , M) ⇒ᵀ⟨ b ⟩ (e' , es' , M') →
             (e₀ , e ∷ es , M) ⇒ᵀ⟨ b ⟩ (e₀ , e' ∷ es' , M')

_⇒ᵀ_ :  Expr∞ T × List (Expr∞ (◸ ⊤)) × Mem →
        Expr∞ T × List (Expr∞ (◸ ⊤)) × Mem →  Set₀
eesM ⇒ᵀ e'es'M' =  ∑ b , eesM ⇒ᵀ⟨ b ⟩ e'es'M'

-- ⇐ᴿ, ⇐ᴷᴿ, ⇐ᴱ, ⇐ᵀ :  Flipped ⇒ᴿ, ⇒ᴷᴿ, ⇒ᴱ, ⇒ᵀ

_⇐ᴿ_ :  Expr∞ T × ¿ Expr∞ (◸ ⊤) × Mem →  Redex T × Mem →  Set₀
_⇐ᴿ_ =  flip _⇒ᴿ_

_⇐ᴷᴿ_ :  Expr∞ T × ¿ Expr∞ (◸ ⊤) × Mem →  Ktxred T × Mem →  Set₀
_⇐ᴷᴿ_ =  flip _⇒ᴷᴿ_

_⇐ᴱ_ :  Expr∞ T × ¿ Expr∞ (◸ ⊤) × Mem →  Expr∞ T × Mem →  Set₀
_⇐ᴱ_ =  flip _⇒ᴱ_

_⇐ᵀ_ :  Expr∞ T × List (Expr∞ (◸ ⊤)) × Mem →
        Expr∞ T × List (Expr∞ (◸ ⊤)) × Mem →  Set₀
_⇐ᵀ_ =  flip _⇒ᵀ_

-- ⇒ᴿ∑, ⇒ᴷᴿ∑ :  A redex / contex-redex pair is reducible

_⇒ᴿ∑ :   Redex T × Mem →  Set₀
redM ⇒ᴿ∑ =  ∑ beeˇM' , redM ⇒ᴿ beeˇM'

_⇒ᴷᴿ∑ :  Ktxred T × Mem →  Set₀
krM ⇒ᴷᴿ∑ =  ∑ beeˇM' , krM ⇒ᴷᴿ beeˇM'

abstract

  -- ⇒ᴾ implies ⇒ᴱ

  ⇒ᴾ⇒⇒ᴱ :  e ⇒ᴾ e' →  (e , M) ⇒ᴱ (e' , ň , M)
  ⇒ᴾ⇒⇒ᴱ (redᴾ e⇒K[e₀]) =  -, redᴱ e⇒K[e₀] $ redᴷᴿ []⇒

--------------------------------------------------------------------------------
-- ⇒ᵀ* :  Finite reduction sequence

infix 4 _⇒ᵀ*_

data  _⇒ᵀ*_ :  Expr∞ T × List (Expr∞ (◸ ⊤)) × Mem →
               Expr∞ T × List (Expr∞ (◸ ⊤)) × Mem →  Set₀  where

  -- End reduction
  ⇒ᵀ*-refl :  (e , es , M) ⇒ᵀ* (e , es , M)

  -- Continue reduction
  ⇒ᵀ*-step :  (e , es , M) ⇒ᵀ (e' , es' , M') →
              (e' , es' , M') ⇒ᵀ* (e'' , es'' , M'') →
              (e , es , M) ⇒ᵀ* (e'' , es'' , M'')
