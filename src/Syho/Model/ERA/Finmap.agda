--------------------------------------------------------------------------------
-- Finite-map resource algebra
--------------------------------------------------------------------------------

{-# OPTIONS --without-K --safe #-}

open import Syho.Model.ERA using (ERA)
module Syho.Model.ERA.Finmap {ℓ ℓ≈ ℓ✓} (Ra : ERA ℓ ℓ≈ ℓ✓) where

open ERA using (Car; _≈_; ✓_; _∙_; ε; ⌞_⌟; refl˜; ◠˜_; _◇˜_; ∙-congˡ; ∙-unitˡ;
  ∙-comm; ∙-assocˡ; ✓-resp; ✓-rem; ✓-ε; ⌞⌟-cong; ⌞⌟-add; ⌞⌟-unitˡ; ⌞⌟-idem;
  ∙-cong; ⌞⌟-ε; ∙-unitʳ; ∙-congʳ)
open ERA Ra using () renaming (Car to A; _≈_ to _≈'_; ✓_ to ✓'_; _∙_ to _∙'_;
  ε to ε'; ⌞_⌟ to ⌞_⌟'; _↝_ to _↝'_; refl˜ to refl'; ◠˜_ to ◠'_; _◇˜_ to _◇'_)

open import Base.Level using (_⊔ᴸ_)
open import Base.Bool using (tt; ff)
open import Base.Eq using (_≡_; refl; ◠_)
open import Base.Setoid using (≡-setoid)
open import Base.Func using (_$_; flip)
open import Base.Few using (absurd)
open import Base.Prod using (∑-syntax; _,_; proj₀; proj₁)
open import Base.Nat using (ℕ; _≡ᵇ_; _⊔_; ≤-refl; ≡⇒ᵇ; ᵇ⇒≡; ⊔≤-introʳ)

import Base.Finmap
module ModFinmap =  Base.Finmap A (_≈' ε')
open ModFinmap using (Finᶠᵐ; _|ᶠᵐ_; !ᶠᵐ; finᶠᵐ; mergeᶠᵐ; updᶠᵐ; updaᶠᵐ;
  updaᶠᵐ-eq)
open ModFinmap public using (Finmap)

--------------------------------------------------------------------------------
-- Finmap : FinmapRA's carrier

private variable
  a b : A
  M N O : Finmap

--------------------------------------------------------------------------------
-- Internal definitions

private

  -- Equivalence
  infix 4 _≈ᶠᵐ_
  _≈ᶠᵐ_ :  Finmap →  Finmap →  Set ℓ≈
  f |ᶠᵐ _ ≈ᶠᵐ g |ᶠᵐ _ =  ∀ i →  f i ≈' g i

  -- Validity
  infix 3 ✓ᶠᵐ_
  ✓ᶠᵐ_ :  Finmap →  Set ℓ✓
  ✓ᶠᵐ (f |ᶠᵐ _) =  ∀ i →  ✓' f i

  -- Product
  infixl 7 _∙ᶠᵐ_
  _∙ᶠᵐ_ :  Finmap →  Finmap →  Finmap
  M ∙ᶠᵐ M' =  mergeᶠᵐ _∙'_ (λ a≈ε b≈ε → ∙-cong Ra a≈ε b≈ε ◇' ∙-unitˡ Ra) M M'

  -- Unit
  εᶠᵐ :  Finmap
  εᶠᵐ .!ᶠᵐ _ =  ε'
  εᶠᵐ .finᶠᵐ =  0 , λ _ → refl'

  -- Core
  ⌞_⌟ᶠᵐ :  Finmap →  Finmap
  ⌞ f |ᶠᵐ _ ⌟ᶠᵐ .!ᶠᵐ i =  ⌞ f i ⌟'
  ⌞ _ |ᶠᵐ (n , fi) ⌟ᶠᵐ .finᶠᵐ =  n , λ n≤j → ⌞⌟-cong Ra (fi n≤j) ◇' ⌞⌟-ε Ra

--------------------------------------------------------------------------------
-- Internal lemma

private abstract

  ⌞⌟ᶠᵐ-add :  ∀ M N →  ∑ N' ,  N' ∙ᶠᵐ ⌞ M ⌟ᶠᵐ ≈ᶠᵐ ⌞ N ∙ᶠᵐ M ⌟ᶠᵐ
  ⌞⌟ᶠᵐ-add (f |ᶠᵐ _) (g |ᶠᵐ _) .proj₀ .!ᶠᵐ i =  Ra .⌞⌟-add {f i} {g i} .proj₀
  ⌞⌟ᶠᵐ-add M@(f |ᶠᵐ (m , fi)) N@(g |ᶠᵐ (n , _)) .proj₀ .finᶠᵐ =  n ⊔ m , proof
   where abstract
    proof :  Finᶠᵐ (λ i → Ra .⌞⌟-add {f i} {g i} .proj₀) (n ⊔ m)
    proof {i} n⊔m≤i =  ◠' ∙-unitʳ Ra ◇'
      ∙-congʳ Ra (◠'_ $ (Ra .⌞⌟-cong $ fi $ ⊔≤-introʳ {n} n⊔m≤i) ◇' ⌞⌟-ε Ra) ◇'
      Ra .⌞⌟-add {f i} {g i} .proj₁ ◇'
      Ra .⌞⌟-cong ((N ∙ᶠᵐ M) .finᶠᵐ .proj₁ n⊔m≤i) ◇' ⌞⌟-ε Ra
  ⌞⌟ᶠᵐ-add (f |ᶠᵐ _) (g |ᶠᵐ _) .proj₁ i =  Ra .⌞⌟-add {f i} {g i} .proj₁

--------------------------------------------------------------------------------
-- FinmapRA : Finite-map resource algebra

FinmapRA : ERA (ℓ ⊔ᴸ ℓ≈) ℓ≈ ℓ✓
FinmapRA .Car =  Finmap
FinmapRA ._≈_ =  _≈ᶠᵐ_
FinmapRA .✓_ =  ✓ᶠᵐ_
FinmapRA ._∙_ =  _∙ᶠᵐ_
FinmapRA .ε =  εᶠᵐ
FinmapRA .⌞_⌟ =  ⌞_⌟ᶠᵐ
FinmapRA .refl˜ _ =  refl'
FinmapRA .◠˜_ M≈N i =  ◠' M≈N i
FinmapRA ._◇˜_ M≈N N≈O i =  M≈N i ◇' N≈O i
FinmapRA .∙-congˡ M≈N i =  Ra .∙-congˡ (M≈N i)
FinmapRA .∙-unitˡ i =  Ra .∙-unitˡ
FinmapRA .∙-comm i =  Ra .∙-comm
FinmapRA .∙-assocˡ i =  Ra .∙-assocˡ
FinmapRA .✓-resp M≈N ✓M i =  Ra .✓-resp (M≈N i) (✓M i)
FinmapRA .✓-rem ✓M∙N i =  Ra .✓-rem (✓M∙N i)
FinmapRA .✓-ε i =  Ra .✓-ε
FinmapRA .⌞⌟-cong M≈N i =  Ra .⌞⌟-cong (M≈N i)
FinmapRA .⌞⌟-add {M} {N} =  ⌞⌟ᶠᵐ-add M N
FinmapRA .⌞⌟-unitˡ i =  Ra .⌞⌟-unitˡ
FinmapRA .⌞⌟-idem i =  Ra .⌞⌟-idem

open ERA FinmapRA using () renaming (_≈_ to _≈⁺_; ✓_ to ✓⁺_; _∙_ to _∙⁺_;
  ⌞_⌟ to ⌞_⌟⁺; ε to ε⁺; _↝_ to _↝⁺_; _↝ˢ_ to _↝ˢ⁺_; refl˜ to refl⁺;
  _◇˜_ to _◇⁺_)

-- injᶠᵐ/injaᶠ$1 :  Injecting an element at an index

injᶠᵐ injaᶠᵐ :  ℕ → A → Finmap
injᶠᵐ i a =  updᶠᵐ i a ε⁺
injaᶠᵐ i a =  updaᶠᵐ i a ε⁺

module _ {i : ℕ} where abstract

  ------------------------------------------------------------------------------
  -- On updaᶠᵐ

  -- updaᶠᵐ preserves ≈/✓/∙/⌞⌟/↝

  updaᶠᵐ-cong :  a ≈' b →  M ≈⁺ N →  updaᶠᵐ i a M ≈⁺ updaᶠᵐ i b N
  updaᶠᵐ-cong a≈b M≈N j  rewrite updaᶠᵐ-eq  with i ≡ᵇ j
  ... | tt =  a≈b
  ... | ff =  M≈N j

  updaᶠᵐ-✓ :  ✓' a →  ✓⁺ M →  ✓⁺ updaᶠᵐ i a M
  updaᶠᵐ-✓ ✓a ✓M j  rewrite updaᶠᵐ-eq  with i ≡ᵇ j
  ... | tt =  ✓a
  ... | ff =  ✓M j

  updaᶠᵐ-∙ :  updaᶠᵐ i a M ∙⁺ updaᶠᵐ i b N  ≈⁺  updaᶠᵐ i (a ∙' b) (M ∙⁺ N)
  updaᶠᵐ-∙ j  rewrite updaᶠᵐ-eq  with i ≡ᵇ j
  ... | tt =  refl'
  ... | ff =  refl'

  updaᶠᵐ-⌞⌟ :  ⌞ updaᶠᵐ i a M ⌟⁺  ≈⁺  updaᶠᵐ i ⌞ a ⌟' ⌞ M ⌟⁺
  updaᶠᵐ-⌞⌟ j  rewrite updaᶠᵐ-eq  with i ≡ᵇ j
  ... | tt =  refl'
  ... | ff =  refl'

  updaᶠᵐ-↝ :  a ↝' b →  updaᶠᵐ i a M ↝⁺ updaᶠᵐ i b M
  updaᶠᵐ-↝ a↝b N ✓N∙iaM j  rewrite updaᶠᵐ-eq  with i ≡ᵇ j | ✓N∙iaM j
  ... | tt | ✓Ni∙a =  a↝b (N .!ᶠᵐ j) ✓Ni∙a
  ... | ff | ✓Nj∙Mj =  ✓Nj∙Mj

  -- Double update

  updaᶠᵐ-2 :  updaᶠᵐ i a (updaᶠᵐ i b M) ≈⁺ updaᶠᵐ i a M
  updaᶠᵐ-2 j  rewrite updaᶠᵐ-eq  with i ≡ᵇ j | ≡⇒ᵇ {i} {j}
  ... | tt | _ =  refl'
  ... | ff | i≢j  with i ≡ᵇ j | ᵇ⇒≡ {i} {j}
    -- We need with i ≡ᵇ j to simplify updaᶠᵐ i b M j
  ...   | tt | ⇒i≡j =  absurd $ i≢j $ ⇒i≡j _
  ...   | ff | _ =  refl'

  ------------------------------------------------------------------------------
  -- On injaᶠᵐ

  -- injaᶠᵐ preserves ≈/✓/∙/ε/⌞⌟/↝

  injaᶠᵐ-cong :  a ≈' b →  injaᶠᵐ i a  ≈⁺  injaᶠᵐ i b
  injaᶠᵐ-cong a≈b =  updaᶠᵐ-cong a≈b $ refl⁺ {a = ε⁺}

  injaᶠᵐ-✓ :  ✓' a →  ✓⁺ injaᶠᵐ i a
  injaᶠᵐ-✓ ✓a =  updaᶠᵐ-✓ ✓a (✓-ε FinmapRA)

  injaᶠᵐ-∙ :  injaᶠᵐ i a ∙⁺ injaᶠᵐ i b  ≈⁺  injaᶠᵐ i (a ∙' b)
  injaᶠᵐ-∙ =  _◇⁺_ {injaᶠᵐ i _ ∙⁺ injaᶠᵐ i _} {updaᶠᵐ i _ _} {injaᶠᵐ i _}
    updaᶠᵐ-∙ $ updaᶠᵐ-cong refl' (∙-unitˡ FinmapRA {a = ε⁺})

  injaᶠᵐ-ε :  injaᶠᵐ i ε' ≈⁺ ε⁺
  injaᶠᵐ-ε j  rewrite updaᶠᵐ-eq  with i ≡ᵇ j
  ... | tt =  refl'
  ... | ff =  refl'

  injaᶠᵐ-⌞⌟ :  ⌞ injaᶠᵐ i a ⌟⁺  ≈⁺  injaᶠᵐ i ⌞ a ⌟'
  injaᶠᵐ-⌞⌟ =  _◇⁺_ {⌞ injaᶠᵐ i _ ⌟⁺} {updaᶠᵐ i ⌞ _ ⌟' ⌞ _ ⌟⁺} {injaᶠᵐ i ⌞ _ ⌟'}
    updaᶠᵐ-⌞⌟ $ updaᶠᵐ-cong refl' (⌞⌟-ε FinmapRA)

  injaᶠᵐ-↝ :  a ↝' b →  injaᶠᵐ i a ↝⁺ injaᶠᵐ i b
  injaᶠᵐ-↝ =  updaᶠᵐ-↝

  -- Allocate at a fresh index

  allocᶠᵐ :  ✓' a →  ε⁺ ↝ˢ⁺ λ M → ∑ i , M ≡ injaᶠᵐ i a
  allocᶠᵐ {a} ✓a N@(f |ᶠᵐ (n , fi)) ✓N∙ε =  injaᶠᵐ n a , (_ , refl) , proof
   where
    proof :  ✓⁺ N ∙⁺ injaᶠᵐ n a
    proof i  rewrite updaᶠᵐ-eq  with n ≡ᵇ i | ᵇ⇒≡ {n} {i}
    ... | ff | _ =  ✓N∙ε i
    ... | tt | ⇒n≡i with ⇒n≡i _
    ...   | refl =
      flip (✓-resp Ra) ✓a $ ◠'_ $ ∙-congˡ Ra (fi ≤-refl) ◇' ∙-unitˡ Ra
