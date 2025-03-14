--------------------------------------------------------------------------------
-- Bounded-map ERA
--------------------------------------------------------------------------------

{-# OPTIONS --without-K --safe #-}

open import Base.Level using (Level)
open import Base.Nat using (ℕ)
open import Syng.Model.ERA.Base using (ERA)
module Syng.Model.ERA.Bnd {łᴿ ł≈ łᴱ ł✓ : Level} (Era : ERA łᴿ ł≈ łᴱ ł✓)
  (∅ : Era .ERA.Env)
  (∅✓⇒≈ε :  ∀{a} →  Era .ERA._✓_ ∅ a →  Era .ERA._≈_ a (Era .ERA.ε)) where

open import Base.Level using (_⊔ᴸ_)
open import Base.Func using (_$_; flip)
open import Base.Few using (⊤₀; absurd; ¬_)
open import Base.Eq using (_≡_; refl)
open import Base.Dec using (yes; no; _≟_; ≟-refl; upd˙)
open import Base.Prod using (∑-syntax; _×_; π₀; π₁; _,_; -,_; _,-)
open import Base.Sum using (ĩ₀_; ĩ₁_)
open import Base.Nat using (ṡ_; _<_; ∀≥; ≤-refl; <-irrefl; <⇒≤; <⇒¬≥; _<≥_)
open import Syng.Model.ERA.Base using (Envmᴱᴿᴬ; Envvᴱᴿᴬ)
import Syng.Model.ERA.All

open ERA Era using (Res; _≈_; _∙_; ε; Env; _✓_; _↝_; ◠˜_; _◇˜_; ∙-congʳ;
  ∙-unitˡ; ∙-unitʳ; ∙-incrʳ; ✓-resp; ✓-mono)

--------------------------------------------------------------------------------
-- Bndᴱᴿᴬ :  Bounded-map ERA

module AllBnd =  Syng.Model.ERA.All ℕ (λ _ → Era)
-- Re-export all
open AllBnd public

private variable
  ł :  Level
  X :  Set ł
  i n :  ℕ
  a b :  Res
  bˣ :  X → Res
  E :  Env
  Fˣ :  X → Env
  a˙ :  Res˙
  E˙ F˙ : Env˙

-- Bndᴱᴿᴬ :  Bounded-map ERA

Bndᴱᴿᴬ :  ERA łᴿ ł≈ łᴱ (łᴱ ⊔ᴸ ł✓)
Bndᴱᴿᴬ =  Envvᴱᴿᴬ (Envmᴱᴿᴬ ∀ᴱᴿᴬ ((ℕ → Env) × ℕ) π₀)
  λ (E˙ , n) → ∀≥ n (λ _ → _≡ ∅) E˙

open ERA Bndᴱᴿᴬ using () renaming (_✓_ to _✓ᴮⁿᵈ_; _↝_ to _↝ᴮⁿᵈ_;
  ↝-param to ↝ᴮⁿᵈ-param)

abstract

  -- Allocate a valid resource to a fresh index

  ↝ᴮⁿᵈ-new :  E ✓ a  →
    ((F˙ , n) , ε˙)  ↝ᴮⁿᵈ λ (_ : ⊤₀) →  (upd˙ n E F˙ , ṡ n) , inj˙ n a
  ↝ᴮⁿᵈ-new _ _ _ .π₀ =  _
  ↝ᴮⁿᵈ-new {n = n} _ _ (i≥n⇒Fi≡∅ ,-) .π₁ .π₀ i i>n  with i ≟ n
  … | no _ =  i≥n⇒Fi≡∅ i (<⇒≤ i>n)
  … | yes refl =  absurd $ <-irrefl i>n
  ↝ᴮⁿᵈ-new {n = n} E✓a b˙ (i≥n⇒Fi≡∅ , F✓b) .π₁ .π₁ i  with i ≟ n
  … | no _ =  F✓b i
  … | yes refl  with F✓b n
  …   | ∅✓bn  rewrite ≟-refl {a = n} | i≥n⇒Fi≡∅ n ≤-refl =
    flip ✓-resp E✓a $ ◠˜_ $ ∙-congʳ (◠˜ ∙-unitˡ ◇˜ ∅✓⇒≈ε ∅✓bn) ◇˜ ∙-unitʳ

  -- Use agreement at an index

  ↝ᴮⁿᵈ-agree :  ¬ a ≈ ε  →   (E˙ i ✓ a → X)  →
    ((E˙ , n) , inj˙ i a)  ↝ᴮⁿᵈ λ (_ : i < n × X) →  (E˙ , n) , inj˙ i a
  ↝ᴮⁿᵈ-agree {i = i} {n = n} ¬a≈ε Ei✓a⇒X b˙ (j≥n⇒Ej≡∅ , E✓ia∙b) .π₀
    with ✓-mono ∙-incrʳ (E✓ia∙b i)
  … | Ei✓a  rewrite ≟-refl {a = i}  with i <≥ n
  …   | ĩ₀ i<n =  i<n , Ei✓a⇒X Ei✓a
  …   | ĩ₁ i≥n  rewrite j≥n⇒Ej≡∅ i i≥n =  absurd $ ¬a≈ε $ ∅✓⇒≈ε Ei✓a
  ↝ᴮⁿᵈ-agree _ _ b˙ (✓E✓ia∙b) .π₁ =  ✓E✓ia∙b

  -- Remove an element at an index

  ↝ᴮⁿᵈ-rem :  ¬ a ≈ ε  →   (E˙ i ✓ a → X)  →   (∀{b} → E˙ i ✓ a ∙ b → ∅ ✓ b)  →
    ((E˙ , n) , inj˙ i a)  ↝ᴮⁿᵈ λ (_ : i < n × X) →  (upd˙ i ∅ E˙ , n) , ε˙
  ↝ᴮⁿᵈ-rem ¬a≈ε Ei✓a⇒X _ b˙ ✓E✓ia∙b .π₀ =  ↝ᴮⁿᵈ-agree ¬a≈ε Ei✓a⇒X b˙ ✓E✓ia∙b .π₀
  ↝ᴮⁿᵈ-rem {i = i} _ _ _ _ (j≥n⇒Ej≡∅ ,-) .π₁ .π₀ j j≥n  with j ≟ i
  … | no _ =  j≥n⇒Ej≡∅ j j≥n
  … | yes refl =  refl
  ↝ᴮⁿᵈ-rem {i = i} _ _ Ei✓a∙⇒∅✓ b˙ (j≥n⇒Ej≡∅ , E✓ia∙b) .π₁ .π₁ j
    with j ≟ i | E✓ia∙b j
  … | no _ | Ej✓ε∙bj =  Ej✓ε∙bj
  … | yes refl | Ei✓a∙bi =  ✓-resp (◠˜ ∙-unitˡ) $ Ei✓a∙⇒∅✓ Ei✓a∙bi

  -- Lift a resource update of the element ERA

  inj˙-↝ᴮⁿᵈ :  ¬ a ≈ ε  →   (E˙ i , a)  ↝ (λ x →  Fˣ x , bˣ x)  →
    ((E˙ , n) , inj˙ i a)  ↝ᴮⁿᵈ
      λ ((-, x) : i < n × X) →  (upd˙ i (Fˣ x) E˙ , n) , inj˙ i (bˣ x)
  inj˙-↝ᴮⁿᵈ {E˙ = E˙} {i = i} {X = X} {Fˣ} {bˣ} {n}
    ¬a≈ε Eia↝Fxbx c˙ ✓E✓ia∙c@(j≥n⇒Ej≡∅ , ✓ia∙c)  with ✓ia∙c i
  … | ✓a∙ci  rewrite ≟-refl {a = i}  =  (i<n , x) , body
   where
    i<n :  i < n
    i<n =  ↝ᴮⁿᵈ-agree {X = ⊤₀} ¬a≈ε _ c˙ ✓E✓ia∙c .π₀ .π₀
    x :  X
    x =  Eia↝Fxbx (c˙ i) ✓a∙ci .π₀
    body :  (upd˙ i (Fˣ x) E˙ , n) ✓ᴮⁿᵈ inj˙ i (bˣ x) ∙˙ c˙
    body .π₀ j j≥n  with j ≟ i | j≥n⇒Ej≡∅ j j≥n
    … | no _ | Ej≡∅ =  Ej≡∅
    … | yes refl | _ =  absurd $ <⇒¬≥ i<n j≥n
    body .π₁ j  with j ≟ i | ✓ia∙c j
    … | no _ | ✓ε∙cj =  ✓ε∙cj
    … | yes refl | _ =  Eia↝Fxbx (c˙ i) ✓a∙ci .π₁
