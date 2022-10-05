--------------------------------------------------------------------------------
-- Semantic super update and weakest precondition lemmas for the memory
--------------------------------------------------------------------------------

{-# OPTIONS --without-K --sized-types #-}

module Syho.Model.Hor.Mem where

open import Base.Level using (Level)
open import Base.Func using (_$_; _▷_; _›_)
open import Base.Eq using (_≡_; refl; ◠_; _◇_; cong)
open import Base.Dec using (upd˙)
open import Base.Size using (Size; ∞; !; §_)
open import Base.Option using (š_; ň; š-inj)
open import Base.Prod using (∑-syntax; π₁; _,_; -,_; ≡∑⇒π₁≡)
open import Base.Nat using (ℕ)
open import Base.List using (List; len; rep)
open import Base.RatPos using (ℚ⁺)
open import Syho.Lang.Expr using (Addr; Type; ∇_; Val; TyVal; ⊤-)
open import Syho.Lang.Ktxred using (🞰ᴿ_; _←ᴿ_; allocᴿ; freeᴿ)
open import Syho.Lang.Reduce using (Mem; _‼ᴹ_; updᴹ; 🞰⇒; ←⇒; alloc⇒; free⇒;
  ✓ᴹ-∑ň)
open import Syho.Model.ERA.Glob using (upd˙-mem-envᴳ)
open import Syho.Model.ERA.Mem using (εᴹᵉᵐ; ↦⟨⟩ʳ-read; ↦ʳ-write; ↦ᴸʳ-alloc;
  freeʳ-š; ↦ᴸʳ-free)
open import Syho.Model.Prop.Base using (Propᵒ; _⊨_; ⊨_; ⌜_⌝ᵒ×_; ⊤ᵒ₀; _∗ᵒ_;
  _⤇ᴱ_; ∗ᵒ-mono; ∗ᵒ-monoˡ; ∗ᵒ-monoʳ; ∗ᵒ-assocˡ; ∗ᵒ-assocʳ; ?∗ᵒ-comm; ?∗ᵒ-intro;
  ∗ᵒ?-intro; ∗ᵒ-elimʳ; ∃ᵒ∗ᵒ-out; ⤇ᴱ-mono; ⤇ᴱ-respᴱʳ; ⤇ᴱ-param; ◎⟨⟩-∗ᵒ⇒∙;
  ◎⟨⟩-∙⇒∗ᵒ; ↝-◎⟨⟩-⤇ᴱ; ε↝-◎⟨⟩-⤇ᴱ)
open import Syho.Model.Prop.Mem using (_↦⟨_⟩ᵒ_; _↦ᵒ_; Freeᵒ'; Freeᵒ; _↦ᴸᵒ_;
  _↦ᴸᵒ'_; ↦ᴸᵒ⇒↦ᴸᵒ'; ↦ᴸᵒ'⇒↦ᴸᵒ)
open import Syho.Model.Supd.Interp using (⟨_⟩⇛ᵒ⟨_⟩_; ⇛ᵒ-mono; ?⊨⤇ᴱᴹᵉᵐ⇒?⊨⇛ᵒ;
  ⊨⤇ᴱᴹᵉᵐ⇒⊨⇛ᵒ; ⇛ᵒ-intro; ⇛ᵒ-intro-✓ᴹ)
open import Syho.Model.Hor.Wp using (ᵃ⟨_⟩ᵒ_)

private variable
  ł :  Level
  ι :  Size
  X :  Set₀
  T U :  Type
  Pᵒ Qᵒ :  Propᵒ ł
  Qᵒ˙ :  X → Propᵒ ł
  M M' :  Mem
  θ :  Addr
  p :  ℚ⁺
  o n :  ℕ
  ᵗu ᵗv :  TyVal
  ᵗvs :  List TyVal
  u v :  X

--------------------------------------------------------------------------------
-- Semantic super update for the memory

abstract

  -- Read using ↦⟨⟩ᵒ

  ↦⟨⟩ᵒ-read :  θ ↦⟨ p ⟩ᵒ ᵗv  ⊨ ⟨ M ⟩⇛ᵒ⟨ M ⟩
                 ⌜ M ‼ᴹ θ ≡ š ᵗv ⌝ᵒ×  θ ↦⟨ p ⟩ᵒ ᵗv
  ↦⟨⟩ᵒ-read =  ?⊨⤇ᴱᴹᵉᵐ⇒?⊨⇛ᵒ $ ↝-◎⟨⟩-⤇ᴱ ↦⟨⟩ʳ-read › ⤇ᴱ-respᴱʳ upd˙-mem-envᴳ ›
    ⤇ᴱ-mono (λ M‼θ≡v →  M‼θ≡v ,_) › ⤇ᴱ-param

  -- Write using ↦ᵒ

  ↦ᵒ-write :  θ ↦ᵒ ᵗu  ⊨ ⟨ M ⟩⇛ᵒ⟨ updᴹ θ ᵗv M ⟩  θ ↦ᵒ ᵗv
  ↦ᵒ-write =  ?⊨⤇ᴱᴹᵉᵐ⇒?⊨⇛ᵒ $ ↝-◎⟨⟩-⤇ᴱ ↦ʳ-write › ⤇ᴱ-respᴱʳ upd˙-mem-envᴳ

  -- Allocate to get ↦ᴸᵒ' and Freeᵒ'

  ↦ᴸᵒ'-alloc :  M o ≡ ň  →
    ⊨ ⟨ M ⟩⇛ᵒ⟨ upd˙ o (š rep n ⊤-) M ⟩  o ↦ᴸᵒ' rep n ⊤-  ∗ᵒ  Freeᵒ' n o
  ↦ᴸᵒ'-alloc Mo≡ň =  ⊨⤇ᴱᴹᵉᵐ⇒⊨⇛ᵒ (ε↝-◎⟨⟩-⤇ᴱ (↦ᴸʳ-alloc Mo≡ň) ▷
    ⤇ᴱ-respᴱʳ upd˙-mem-envᴳ ▷ ⤇ᴱ-mono λ _ → ◎⟨⟩-∙⇒∗ᵒ)

  -- Bounds check using Freeᵒ'

  Freeᵒ'-š :  Freeᵒ' n o  ⊨ ⟨ M ⟩⇛ᵒ⟨ M ⟩  ⌜ ∑ ᵗvs , M o ≡ š ᵗvs ⌝ᵒ×  Freeᵒ' n o
  Freeᵒ'-š =  ?⊨⤇ᴱᴹᵉᵐ⇒?⊨⇛ᵒ $ ↝-◎⟨⟩-⤇ᴱ freeʳ-š › ⤇ᴱ-respᴱʳ upd˙-mem-envᴳ ›
    ⤇ᴱ-mono (λ Mo≡vs →  Mo≡vs ,_) › ⤇ᴱ-param

  -- Free using ↦ᴸᵒ' and Freeᵒ'

  ↦ᴸᵒ'-free :  len ᵗvs ≡ n  →
    o ↦ᴸᵒ' ᵗvs  ∗ᵒ  Freeᵒ' n o  ⊨ ⟨ M ⟩⇛ᵒ⟨ upd˙ o ň M ⟩  ⊤ᵒ₀
  ↦ᴸᵒ'-free lenvs≡n =  ?⊨⤇ᴱᴹᵉᵐ⇒?⊨⇛ᵒ $ ◎⟨⟩-∗ᵒ⇒∙ ›
    ↝-◎⟨⟩-⤇ᴱ {bⁱ˙ = λ _ → εᴹᵉᵐ} (↦ᴸʳ-free lenvs≡n) › ⤇ᴱ-respᴱʳ upd˙-mem-envᴳ ›
    ⤇ᴱ-mono _

--------------------------------------------------------------------------------
-- Atomic weakest precondition lemmas for the memory

abstract

  -- 🞰 and ᵃ⟨⟩ᵒ

  ᵃ⟨⟩ᵒ-🞰 :  θ ↦⟨ p ⟩ᵒ (T , v)  ⊨ ᵃ⟨ 🞰ᴿ_ {T} θ ⟩ᵒ λ u →
              ⌜ u ≡ v ⌝ᵒ×  θ ↦⟨ p ⟩ᵒ (T , v)
  ᵃ⟨⟩ᵒ-🞰 θ↦v _ =  ↦⟨⟩ᵒ-read θ↦v ▷ ⇛ᵒ-mono λ (M‼θ≡v , θ↦v) → (-, 🞰⇒ M‼θ≡v) ,
    λ{ _ _ _ (🞰⇒ M‼θ≡v') → -, (refl , refl) ,(◠ M‼θ≡v ◇ M‼θ≡v') ▷ š-inj ▷
    ≡∑⇒π₁≡ ▷ λ{ refl → ⇛ᵒ-intro (refl , θ↦v) }}

  -- ← and ᵃ⟨⟩ᵒ

  ᵃ⟨⟩ᵒ-← :  θ ↦ᵒ ᵗu  ⊨ ᵃ⟨ _←ᴿ_ {T} θ v ⟩ᵒ λ _ →  θ ↦ᵒ (T , v)
  ᵃ⟨⟩ᵒ-← θ↦ _ =  ↦⟨⟩ᵒ-read θ↦ ▷ ⇛ᵒ-mono λ (M‼θ≡ , θ↦) → (-, ←⇒ (-, M‼θ≡)) ,
    λ{ _ _ _ (←⇒ _) → -, (refl , refl) , ↦ᵒ-write θ↦ }

{-
  -- alloc and ⁺⟨⟩ᴾ/ᵀᵒ

  ⁺⟨⟩ᴾᵒ-alloc :
    (∀ θ →
      θ ↦ᴸᵒ rep n ⊤-  ∗ᵒ  Freeᵒ n θ  ∗ᵒ  Pᵒ  ⊨  ⟨ K ᴷ◁ ∇ θ ⟩ᴾᵒ[ ι ]  Qᵒ˙)  →
    Pᵒ  ⊨  ⁺⟨ ĩ₁ (-, K , allocᴿ n) ⟩ᴾᵒ[ ι ]  Qᵒ˙
  ⁺⟨⟩ᴾᵒ-alloc {n = n} θ↦∗Free∗P⊨⟨Kθ⟩Q Pa =  ⁺⟨⟩ᴾᵒ-kr λ M →
    ⇛ᵒ-mono (λ (✓M , big) → (-, redᴷᴿ (alloc⇒ _ $ ✓ᴹ-∑ň ✓M .π₁)) , big) $
    ⇛ᵒ-intro-✓ᴹ λ{ _ _ _ (redᴷᴿ (alloc⇒ o Mo≡ň)) → Pa ▷
    ?∗ᵒ-intro (↦ᴸᵒ'-alloc Mo≡ň) ▷ ⇛ᵒ-eatʳ ▷ ⇛ᵒ-mono $
    ∗ᵒ-monoˡ (∗ᵒ-mono (↦ᴸᵒ'⇒↦ᴸᵒ {ᵗvs = rep n _}) (λ Fr'b → -, refl , Fr'b)) ›
    ∗ᵒ-assocˡ › θ↦∗Free∗P⊨⟨Kθ⟩Q _ › λ big → ∗ᵒ?-intro _ $ λ{ .! → big }}

  ⁺⟨⟩ᵀᵒ-alloc :
    (∀ θ →
      θ ↦ᴸᵒ rep n ⊤-  ∗ᵒ  Freeᵒ n θ  ∗ᵒ  Pᵒ  ⊨  ⟨ K ᴷ◁ ∇ θ ⟩ᵀᵒ[ ι ]  Qᵒ˙)  →
    Pᵒ  ⊨  ⁺⟨ ĩ₁ (-, K , allocᴿ n) ⟩ᵀᵒ[ ∞ ] Qᵒ˙
  ⁺⟨⟩ᵀᵒ-alloc {n} θ↦∗Free∗P⊨⟨Kθ⟩Q Pa =  ⁺⟨⟩ᵀᵒ-kr λ M →
    ⇛ᵒ-mono (λ (✓M , big) → (-, redᴷᴿ (alloc⇒ _ $ ✓ᴹ-∑ň ✓M .π₁)) , big) $
    ⇛ᵒ-intro-✓ᴹ λ{ _ _ _ (redᴷᴿ (alloc⇒ o Mo≡ň)) → Pa ▷
    ?∗ᵒ-intro (↦ᴸᵒ'-alloc Mo≡ň) ▷ ⇛ᵒ-eatʳ ▷ ⇛ᵒ-mono $
    ∗ᵒ-monoˡ (∗ᵒ-mono (↦ᴸᵒ'⇒↦ᴸᵒ {ᵗvs = rep n _}) (λ Fr'b → -, refl , Fr'b)) ›
    ∗ᵒ-assocˡ › θ↦∗Free∗P⊨⟨Kθ⟩Q _ › §_ › ∗ᵒ?-intro _ }

  -- free and ⁺⟨⟩ᴾ/ᵀᵒ

  ⁺⟨⟩ᴾᵒ-free :  len ᵗvs ≡ n  →   Pᵒ  ⊨  ⟨ K ᴷ◁ ∇ _ ⟩ᴾᵒ[ ι ] Qᵒ˙  →
    θ ↦ᴸᵒ ᵗvs  ∗ᵒ  Freeᵒ n θ  ∗ᵒ  Pᵒ  ⊨  ⁺⟨ ĩ₁ (-, K , freeᴿ θ) ⟩ᴾᵒ[ ι ] Qᵒ˙
  ⁺⟨⟩ᴾᵒ-free {ᵗvs} lenvs≡n P⊨⟨K⟩Q θ↦vs∗Free∗Pa
    with θ↦vs∗Free∗Pa ▷ ?∗ᵒ-comm ▷ ∃ᵒ∗ᵒ-out ▷ (λ (o , big) → o , ∃ᵒ∗ᵒ-out big)
  … | o , refl , Free'∗θ↦vs∗Pa =  ⁺⟨⟩ᴾᵒ-kr λ M → Free'∗θ↦vs∗Pa ▷
    ∗ᵒ-monoˡ Freeᵒ'-š ▷ ⇛ᵒ-eatʳ ▷ ⇛ᵒ-mono $ ∃ᵒ∗ᵒ-out › λ (Mo≡š , Free'∗θ↦vs∗Pb) →
    (-, redᴷᴿ $ free⇒ Mo≡š) , λ{ _ _ _ (redᴷᴿ (free⇒ _)) → Free'∗θ↦vs∗Pb ▷
    ?∗ᵒ-comm ▷ ∗ᵒ-monoˡ (↦ᴸᵒ⇒↦ᴸᵒ' {ᵗvs = ᵗvs}) ▷ ∗ᵒ-assocʳ ▷
    ∗ᵒ-monoˡ (↦ᴸᵒ'-free lenvs≡n) ▷ ⇛ᵒ-eatʳ ▷ ⇛ᵒ-mono $ ∗ᵒ-monoʳ P⊨⟨K⟩Q ›
    ∗ᵒ-elimʳ ⁺⟨⟩ᴾᵒ-Mono › λ big → ∗ᵒ?-intro _ λ{ .! → big }}

  ⁺⟨⟩ᵀᵒ-free :  len ᵗvs ≡ n  →   Pᵒ  ⊨  ⟨ K ᴷ◁ ∇ _ ⟩ᵀᵒ[ ι ] Qᵒ˙  →
    θ ↦ᴸᵒ ᵗvs  ∗ᵒ  Freeᵒ n θ  ∗ᵒ  Pᵒ  ⊨  ⁺⟨ ĩ₁ (-, K , freeᴿ θ) ⟩ᵀᵒ[ ∞ ] Qᵒ˙
  ⁺⟨⟩ᵀᵒ-free {ᵗvs} lenvs≡n P⊨⟨K⟩Q θ↦vs∗Free∗Pa
    with θ↦vs∗Free∗Pa ▷ ?∗ᵒ-comm ▷ ∃ᵒ∗ᵒ-out ▷ (λ (o , big) → o , ∃ᵒ∗ᵒ-out big)
  … | o , refl , Free'∗θ↦vs∗Pa =  ⁺⟨⟩ᵀᵒ-kr λ M → Free'∗θ↦vs∗Pa ▷
    ∗ᵒ-monoˡ Freeᵒ'-š ▷ ⇛ᵒ-eatʳ ▷ ⇛ᵒ-mono $ ∃ᵒ∗ᵒ-out › λ (Mo≡š , Free'∗θ↦vs∗Pb) →
    (-, redᴷᴿ $ free⇒ Mo≡š) , λ{ _ _ _ (redᴷᴿ (free⇒ _)) → Free'∗θ↦vs∗Pb ▷
    ?∗ᵒ-comm ▷ ∗ᵒ-monoˡ (↦ᴸᵒ⇒↦ᴸᵒ' {ᵗvs = ᵗvs}) ▷ ∗ᵒ-assocʳ ▷
    ∗ᵒ-monoˡ (↦ᴸᵒ'-free lenvs≡n) ▷ ⇛ᵒ-eatʳ ▷ ⇛ᵒ-mono $ ∗ᵒ-monoʳ P⊨⟨K⟩Q ›
    ∗ᵒ-elimʳ ⁺⟨⟩ᵀᵒ-Mono › §_ › ∗ᵒ?-intro _ }
-}