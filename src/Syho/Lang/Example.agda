--------------------------------------------------------------------------------
-- Example
--------------------------------------------------------------------------------

{-# OPTIONS --without-K --sized-types #-}

module Syho.Lang.Example where

open import Base.Func using (_$_; _▷_)
open import Base.Few using (⊤; ¬_)
open import Base.Eq using (_≡_; refl)
open import Base.Size using (𝕊; !)
open import Base.Bool using (𝔹; tt; ff)
open import Base.Option using (¿_; ň)
open import Base.Prod using (∑-syntax; _×_; _,_; -,_)
open import Base.Nat using (ℕ; ṡ_; _+_)
open import Base.Sety using ()
open import Syho.Lang.Expr using (Addr; Type; ◸_; _↷_; Expr; Expr∞; Expr˂∞; ∇_;
  λ¡-syntax; nd; _◁_; _⁏¡_; let-syntax; let¡-syntax; ●_; 🞰_; _←_; free; loop;
  Mem)
open import Syho.Lang.Reduce using (nd⇒; []⇒; redᴷᴿ; _⇒ᴱ⟨_⟩_; redᴱ)

private variable
  ι :  𝕊
  b :  𝔹
  T :  Type
  e e' :  Expr∞ T
  eˇ :  ¿ Expr∞ T
  e˂ :  Expr˂∞ T
  M M' :  Mem
  n :  ℕ

--------------------------------------------------------------------------------
-- Various expressions

-- Some stuck expression

stuck :  Expr∞ (◸ ⊤)
stuck =  free $ ∇ (0 , 42)

-- Just add two natural-number arguments

plus :  Expr∞ $ (ℕ × ℕ) ↷ ◸ ℕ
plus =  λ' (m , n) ,¡ ∇ (m + n)

-- plus on 3 & 4

plus◁3,4 :  Expr∞ $ ◸ ℕ
plus◁3,4 =  plus ◁ ∇ (3 , 4)

-- Non-deterministic natural number

ndnat :  Expr∞ $ ◸ ℕ
ndnat =  nd

-- Repeat decrementing the natural number at the address until it becomes zero

decrep :  Addr →  Expr ι $ ◸ ⊤
decrep' :  Addr →  ℕ →  Expr ι $ ◸ ⊤

decrep θ =  let' n := 🞰 ∇ θ in' λ{ .! → decrep' θ n }

decrep' _ 0 =  ∇ _
decrep' θ (ṡ n) =  ∇ θ ← ∇ n ⁏¡ decrep θ

-- decrep after initialization by a non-deterministic natural number

ndecrep :  Addr →  Expr∞ $ ◸ ⊤
ndecrep θ =  ∇ θ ← ndnat ⁏¡ decrep θ

-- Loop ndecrep with an event

ndecrep●∞ :  Addr →  Expr ι $ ◸ ⊤
ndecrep●∞ θ =  ndecrep θ ⁏¡ ● λ{ .! → ndecrep●∞ θ }

-- Counter using memory, which increments the natural number at the address θ
-- and returns the original value n

cntr← :  Addr →  ℕ →  Expr˂∞ $ ◸ ℕ
cntr← θ k .! =  let' n := 🞰 ∇ θ in¡ ∇ θ ← ∇ (k + n) ⁏¡ ∇ n

--------------------------------------------------------------------------------
-- Construct reduction

abstract

  -- Reduce loop

  loop⇒ :  (loop {T = T} , M) ⇒ᴱ⟨ ff ⟩ (loop , ň , M)
  loop⇒ =  redᴱ refl $ redᴷᴿ []⇒

  -- Reduce plus◁3,4

  plus◁3,4⇒ :  (plus◁3,4 , M) ⇒ᴱ⟨ ff ⟩ (∇ 7 , ň , M)
  plus◁3,4⇒ =  redᴱ refl $ redᴷᴿ []⇒

  -- Reduce ndnat

  ndnat⇒ :  (ndnat , M) ⇒ᴱ⟨ ff ⟩ (∇ n , ň , M)
  ndnat⇒ =  redᴱ refl $ redᴷᴿ $ nd⇒ _

  -- Reduce ●

  ●⇒ :  (● e˂ , M) ⇒ᴱ⟨ tt ⟩ (e˂ .! , ň , M)
  ●⇒ =  redᴱ refl $ redᴷᴿ []⇒

--------------------------------------------------------------------------------
-- Destruct reduction

abstract

  -- Invert reduction on loop

  loop⇒-inv :  (loop {T = T} , M) ⇒ᴱ⟨ b ⟩ (e , eˇ , M') →
               (b , e , eˇ , M') ≡ (ff , loop , ň , M)
  loop⇒-inv (redᴱ refl (redᴷᴿ []⇒)) =  refl

  -- stuck can't be reduced (it's stuck!)

  stuck-no⇒ :  ¬ (stuck , M) ⇒ᴱ⟨ b ⟩ (e , eˇ , M')
  stuck-no⇒ (redᴱ refl (redᴷᴿ r⇒)) =  r⇒ ▷ λ ()

  -- Invert reduction on plus◁3,4

  plus◁3,4⇒-inv :  (plus◁3,4 , M) ⇒ᴱ⟨ b ⟩ (e , eˇ , M') →
                   (b , e , eˇ , M') ≡ (ff , ∇ 7 , ň , M)
  plus◁3,4⇒-inv (redᴱ refl (redᴷᴿ []⇒)) =  refl

  -- Invert reduction on ndnat

  ndnat⇒-inv :  (ndnat , M) ⇒ᴱ⟨ b ⟩ (e , eˇ , M') →
                ∑ n , (b , e , eˇ , M') ≡ (ff , ∇ n , ň , M)
  ndnat⇒-inv (redᴱ refl (redᴷᴿ (nd⇒ _))) =  -, refl

  -- Invert reduction on ●

  ●⇒-inv :  (●_ {T = T} e˂ , M) ⇒ᴱ⟨ b ⟩ (e' , eˇ , M') →
            (b , e' , eˇ , M') ≡ (tt , e˂ .! , ň , M)
  ●⇒-inv (redᴱ refl (redᴷᴿ []⇒)) =  refl
