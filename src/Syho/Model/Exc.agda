--------------------------------------------------------------------------------
-- Exclusivity box
--------------------------------------------------------------------------------

module Syho.Model.Exc where

open import Base.Level using (Level)
open import Base.Few using (⊥; ⊤)
open import Base.Eq using (_≡_; refl)
open import Base.Func using (id)

private variable
  ℓ :  Level
  A :  Set ℓ
  a b :  A

--------------------------------------------------------------------------------
-- Exc A :  Exclusivity box

infix 8 #ˣ_

data  Exc (A : Set ℓ) :  Set ℓ  where

  -- Pending
  ?ˣ :  Exc A

  -- Exclusively set
  #ˣ_ :  A →  Exc A

  -- Invalid
  ↯ˣ :  Exc A

private variable
  x y z :  Exc A

--------------------------------------------------------------------------------
-- Validity

infix 3 ✓ˣ_
✓ˣ_ :  Exc A →  Set₀
✓ˣ ↯ˣ =  ⊥
✓ˣ _ =  ⊤

--------------------------------------------------------------------------------
-- Product

infixl 7 _∙ˣ_
_∙ˣ_ :  Exc A →  Exc A →  Exc A
?ˣ ∙ˣ x =  x
↯ˣ ∙ˣ x =  ↯ˣ
x ∙ˣ ?ˣ =  x
_ ∙ˣ _ =  ↯ˣ

abstract

  -- ∙ˣ is commutative

  ∙ˣ-comm :  x ∙ˣ y  ≡  y ∙ˣ x
  ∙ˣ-comm {x = ?ˣ} {?ˣ} =  refl
  ∙ˣ-comm {x = ?ˣ} {↯ˣ} =  refl
  ∙ˣ-comm {x = ?ˣ} {#ˣ _} =  refl
  ∙ˣ-comm {x = ↯ˣ} {?ˣ} =  refl
  ∙ˣ-comm {x = ↯ˣ} {↯ˣ} =  refl
  ∙ˣ-comm {x = ↯ˣ} {#ˣ _} =  refl
  ∙ˣ-comm {x = #ˣ _} {?ˣ} =  refl
  ∙ˣ-comm {x = #ˣ _} {↯ˣ} =  refl
  ∙ˣ-comm {x = #ˣ _} {#ˣ _} =  refl

  -- ∙ˣ is commutative

  ∙ˣ-assocˡ :  (x ∙ˣ y) ∙ˣ z  ≡  x ∙ˣ (y ∙ˣ z)
  ∙ˣ-assocˡ {x = ?ˣ} =  refl
  ∙ˣ-assocˡ {x = ↯ˣ} =  refl
  ∙ˣ-assocˡ {x = #ˣ _} {?ˣ} =  refl
  ∙ˣ-assocˡ {x = #ˣ _} {↯ˣ} =  refl
  ∙ˣ-assocˡ {x = #ˣ _} {#ˣ _} {?ˣ} =  refl
  ∙ˣ-assocˡ {x = #ˣ _} {#ˣ _} {↯ˣ} =  refl
  ∙ˣ-assocˡ {x = #ˣ _} {#ˣ _} {#ˣ _} =  refl

  -- ✓ˣ holds after removing an element with respect to ∙ˣ

  ✓ˣ-rem :  ✓ˣ x ∙ˣ y →  ✓ˣ y
  ✓ˣ-rem {x = ?ˣ} =  id
  ✓ˣ-rem {x = #ˣ _} {y = ?ˣ} =  _
