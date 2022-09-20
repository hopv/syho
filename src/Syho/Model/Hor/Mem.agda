--------------------------------------------------------------------------------
-- Semantic super update and weakest precondition lemmas for the memory
--------------------------------------------------------------------------------

{-# OPTIONS --sized-types #-}

module Syho.Model.Hor.Mem where

open import Base.Level using (Level)
open import Base.Func using (_$_; _▷_; _›_)
open import Base.Eq using (_≡_; refl; ◠_; _◇_; cong)
open import Base.Size using (Size; ∞; !; §_)
open import Base.Prod using (∑-syntax; π₁; _,_; -,_)
open import Base.Sum using (ĩ₁_)
open import Base.Option using (š_; ň)
open import Base.Dec using (upd˙)
open import Base.Nat using (ℕ)
open import Base.List using (List; len; rep)
open import Base.RatPos using (ℚ⁺)
open import Syho.Lang.Expr using (Addr; ad; Type; ∇_; Val; V⇒E; TyVal; ⊤ṽ)
open import Syho.Lang.Ktxred using (Ktx; _ᴷ◁_; 🞰ᴿ_; _←ᴿ_; allocᴿ; freeᴿ; _ᴷ|_)
open import Syho.Lang.Reduce using (Mem; _‼ᴹ_; updᴹ; 🞰⇒; ←⇒; alloc⇒; free⇒;
  redᴷᴿ; ✓ᴹ-∑ň)
open import Syho.Model.ERA.Glob using (upd˙-mem-envᴳ)
open import Syho.Model.ERA.Mem using (εᴹᵉᵐ; ↦⟨⟩ʳ-read; ↦ʳ-write; ↦ᴸʳ-alloc;
  freeʳ-š; ↦ᴸʳ-free)
open import Syho.Model.Prop.Base using (Propᵒ; _⊨_; ⊨_; ⌜_⌝ᵒ×_; ⊤ᵒ₀; _∗ᵒ_;
  _⤇ᴱ_; ∗ᵒ-mono; ∗ᵒ-monoˡ; ∗ᵒ-monoʳ; ∗ᵒ-assocˡ; ∗ᵒ-assocʳ; ?∗ᵒ-comm; ?∗ᵒ-intro;
  ∗ᵒ-elimʳ; ∃ᵒ∗ᵒ-out; ⤇ᴱ-mono; ⤇ᴱ-respᴱʳ; ⤇ᴱ-param; ◎⟨⟩-∗ᵒ⇒∙; ◎⟨⟩-∙⇒∗ᵒ;
  ↝-◎⟨⟩-⤇ᴱ; ε↝-◎⟨⟩-⤇ᴱ)
open import Syho.Model.Prop.Mem using (_↦⟨_⟩ᵒ_; _↦ᵒ_; Freeᵒ'; Freeᵒ; _↦ᴸᵒ_;
  _↦ᴸᵒ'_; ↦ᴸᵒ⇒↦ᴸᵒ'; ↦ᴸᵒ'⇒↦ᴸᵒ)
open import Syho.Model.Supd.Interp using (⟨_⟩⇛ᵒ⟨_⟩_; ⇛ᵒ-mono; ?⊨⤇ᴱᴹᵉᵐ⇒?⊨⇛ᵒ;
  ⊨⤇ᴱᴹᵉᵐ⇒⊨⇛ᵒ; ⇛ᵒ-intro; ⇛ᵒ-intro-✓ᴹ; ⇛ᵒ-eatʳ)
open import Syho.Model.Hor.Wp using (⁺⟨_⟩ᴾᵒ[_]_; ⁺⟨_⟩ᵀᵒ[_]_; ⟨_⟩ᴾᵒ[_]_;
  ⟨_⟩ᵀᵒ[_]_; ⁺⟨⟩ᴾᵒ-kr; ⁺⟨⟩ᵀᵒ-kr; ⁺⟨⟩ᴾᵒ-Mono; ⁺⟨⟩ᵀᵒ-Mono)

private variable
  ł :  Level
  ι :  Size
  T U :  Type
  Pᵒ Qᵒ :  Propᵒ ł
  Qᵒ˙ :  Val T → Propᵒ ł
  M M' :  Mem
  θ :  Addr
  p :  ℚ⁺
  o n :  ℕ
  ᵗu ᵗv :  TyVal
  ᵗvs :  List TyVal
  K :  Ktx T U
  u v :  Val T

--------------------------------------------------------------------------------
-- Semantic super update for the memory

abstract

  -- Read using ↦⟨⟩ᵒ

  ↦⟨⟩ᵒ-read :  θ ↦⟨ p ⟩ᵒ ᵗv  ⊨  ⟨ M ⟩⇛ᵒ⟨ M ⟩
                ⌜ M ‼ᴹ θ ≡ š ᵗv ⌝ᵒ×  θ ↦⟨ p ⟩ᵒ ᵗv
  ↦⟨⟩ᵒ-read =  ?⊨⤇ᴱᴹᵉᵐ⇒?⊨⇛ᵒ $ ↝-◎⟨⟩-⤇ᴱ ↦⟨⟩ʳ-read › ⤇ᴱ-respᴱʳ upd˙-mem-envᴳ ›
    ⤇ᴱ-mono (λ M‼θ≡v →  M‼θ≡v ,_) › ⤇ᴱ-param

  -- Write using ↦ᵒ

  ↦ᵒ-write :  θ ↦ᵒ ᵗu  ⊨  ⟨ M ⟩⇛ᵒ⟨ updᴹ θ ᵗv M ⟩  θ ↦ᵒ ᵗv
  ↦ᵒ-write =  ?⊨⤇ᴱᴹᵉᵐ⇒?⊨⇛ᵒ $ ↝-◎⟨⟩-⤇ᴱ ↦ʳ-write › ⤇ᴱ-respᴱʳ upd˙-mem-envᴳ

  -- Allocate getting ↦ᴸᵒ' and Freeᵒ'

  ↦ᴸᵒ'-alloc :  M o ≡ ň  →
    ⊨  ⟨ M ⟩⇛ᵒ⟨ upd˙ o (š rep n ⊤ṽ) M ⟩  o ↦ᴸᵒ' rep n ⊤ṽ  ∗ᵒ  Freeᵒ' n o
  ↦ᴸᵒ'-alloc Mo≡ň =  ⊨⤇ᴱᴹᵉᵐ⇒⊨⇛ᵒ (ε↝-◎⟨⟩-⤇ᴱ (↦ᴸʳ-alloc Mo≡ň) ▷
    ⤇ᴱ-respᴱʳ upd˙-mem-envᴳ ▷ ⤇ᴱ-mono λ _ → ◎⟨⟩-∙⇒∗ᵒ)

  -- Bounds check using Freeᵒ'

  Freeᵒ'-š :  Freeᵒ' n o  ⊨  ⟨ M ⟩⇛ᵒ⟨ M ⟩  ⌜ ∑ ᵗvs , M o ≡ š ᵗvs ⌝ᵒ×  Freeᵒ' n o
  Freeᵒ'-š =  ?⊨⤇ᴱᴹᵉᵐ⇒?⊨⇛ᵒ $ ↝-◎⟨⟩-⤇ᴱ freeʳ-š › ⤇ᴱ-respᴱʳ upd˙-mem-envᴳ ›
    ⤇ᴱ-mono (λ Mo≡vs →  Mo≡vs ,_) › ⤇ᴱ-param

  -- Free using ↦ᴸᵒ' and Freeᵒ'

  ↦ᴸᵒ'-free :  len ᵗvs ≡ n  →
    o ↦ᴸᵒ' ᵗvs  ∗ᵒ  Freeᵒ' n o  ⊨  ⟨ M ⟩⇛ᵒ⟨ upd˙ o ň M ⟩  ⊤ᵒ₀
  ↦ᴸᵒ'-free lenvs≡n =  ?⊨⤇ᴱᴹᵉᵐ⇒?⊨⇛ᵒ $ ◎⟨⟩-∗ᵒ⇒∙ ›
    ↝-◎⟨⟩-⤇ᴱ {bⁱ˙ = λ _ → εᴹᵉᵐ} (↦ᴸʳ-free lenvs≡n) › ⤇ᴱ-respᴱʳ upd˙-mem-envᴳ ›
    ⤇ᴱ-mono _

--------------------------------------------------------------------------------
-- Weakest precondition lemmas for the memory

abstract

  -- 🞰 and ⁺⟨⟩ᴾᵒ / ⁺⟨⟩ᵀᵒ
  ---- We need the axiom K to get v ≡ v' out of M‼θ≡v and M‼θ≡v', or more
  ---- specifically, out of the equality (T , v) ≡ (T , v') over TyVal

  ⁺⟨⟩ᴾᵒ-🞰 :  θ ↦⟨ p ⟩ᵒ (-, v)  ∗ᵒ  Pᵒ  ⊨  ⟨ K ᴷ◁ V⇒E v ⟩ᴾᵒ[ ι ]  Qᵒ˙ →
             θ ↦⟨ p ⟩ᵒ (-, v)  ∗ᵒ  Pᵒ  ⊨  ⁺⟨ ĩ₁ (K ᴷ| 🞰ᴿ θ) ⟩ᴾᵒ[ ι ]  Qᵒ˙
  ⁺⟨⟩ᴾᵒ-🞰 θ↦v∗P⊨⟨Kv⟩Q θ↦v∗Pa =  ⁺⟨⟩ᴾᵒ-kr λ M → θ↦v∗Pa ▷ ∗ᵒ-monoˡ ↦⟨⟩ᵒ-read ▷
    ⇛ᵒ-eatʳ ▷ ⇛ᵒ-mono $ ∃ᵒ∗ᵒ-out › λ (M‼θ≡v , θ↦v∗Pb) → (-, redᴷᴿ $ 🞰⇒ M‼θ≡v) ,
    λ{ _ _ (redᴷᴿ (🞰⇒ M‼θ≡v')) → ◠ M‼θ≡v ◇ M‼θ≡v' ▷
    λ{ refl → ⇛ᵒ-intro λ{ .! → θ↦v∗P⊨⟨Kv⟩Q θ↦v∗Pb }}}

  ⁺⟨⟩ᵀᵒ-🞰 :  θ ↦⟨ p ⟩ᵒ (-, v)  ∗ᵒ  Pᵒ  ⊨  ⟨ K ᴷ◁ V⇒E v ⟩ᵀᵒ[ ι ]  Qᵒ˙ →
             θ ↦⟨ p ⟩ᵒ (-, v)  ∗ᵒ  Pᵒ  ⊨  ⁺⟨ ĩ₁ (K ᴷ| 🞰ᴿ θ) ⟩ᵀᵒ[ ∞ ]  Qᵒ˙
  ⁺⟨⟩ᵀᵒ-🞰 θ↦v∗P⊨⟨Kv⟩Q θ↦v∗Pa =  ⁺⟨⟩ᵀᵒ-kr λ M → θ↦v∗Pa ▷ ∗ᵒ-monoˡ ↦⟨⟩ᵒ-read ▷
    ⇛ᵒ-eatʳ ▷ ⇛ᵒ-mono $ ∃ᵒ∗ᵒ-out › λ (M‼θ≡v , θ↦v∗Pb) → (-, redᴷᴿ $ 🞰⇒ M‼θ≡v) ,
    λ{ _ _ (redᴷᴿ (🞰⇒ M‼θ≡v')) → ◠ M‼θ≡v ◇ M‼θ≡v' ▷
    λ{ refl → ⇛ᵒ-intro $ § θ↦v∗P⊨⟨Kv⟩Q θ↦v∗Pb }}

  -- ← and ⁺⟨⟩ᴾᵒ / ⁺⟨⟩ᵀᵒ

  ⁺⟨⟩ᴾᵒ-← :  θ ↦ᵒ (-, v)  ∗ᵒ  Pᵒ  ⊨  ⟨ K ᴷ◁ ∇ _ ⟩ᴾᵒ[ ι ]  Qᵒ˙ →
             θ ↦ᵒ (-, u)  ∗ᵒ  Pᵒ  ⊨  ⁺⟨ ĩ₁ (K ᴷ| θ ←ᴿ v) ⟩ᴾᵒ[ ι ]  Qᵒ˙
  ⁺⟨⟩ᴾᵒ-← θ↦v∗P⊨⟨K∇⟩Q θ↦u∗Pa =  ⁺⟨⟩ᴾᵒ-kr λ M → θ↦u∗Pa ▷ ∗ᵒ-monoˡ ↦⟨⟩ᵒ-read ▷
    ⇛ᵒ-eatʳ ▷ ⇛ᵒ-mono $ ∃ᵒ∗ᵒ-out › λ (M‼θ≡u , θ↦u∗Pb) →
    (-, redᴷᴿ $ ←⇒ (-, M‼θ≡u)) , λ{ _ _ (redᴷᴿ (←⇒ _)) → θ↦u∗Pb ▷
    ∗ᵒ-monoˡ ↦ᵒ-write ▷ ⇛ᵒ-eatʳ ▷
    ⇛ᵒ-mono λ θ↦u∗Pb → λ{ .! → θ↦v∗P⊨⟨K∇⟩Q θ↦u∗Pb }}

  ⁺⟨⟩ᵀᵒ-← :  θ ↦ᵒ (-, v)  ∗ᵒ  Pᵒ  ⊨  ⟨ K ᴷ◁ ∇ _ ⟩ᵀᵒ[ ι ]  Qᵒ˙ →
             θ ↦ᵒ (-, u)  ∗ᵒ  Pᵒ  ⊨  ⁺⟨ ĩ₁ (K ᴷ| θ ←ᴿ v) ⟩ᵀᵒ[ ∞ ]  Qᵒ˙
  ⁺⟨⟩ᵀᵒ-← θ↦v∗P⊨⟨K∇⟩Q θ↦u∗Pa =  ⁺⟨⟩ᵀᵒ-kr λ M → θ↦u∗Pa ▷ ∗ᵒ-monoˡ ↦⟨⟩ᵒ-read ▷
    ⇛ᵒ-eatʳ ▷ ⇛ᵒ-mono $ ∃ᵒ∗ᵒ-out › λ (M‼θ≡u , θ↦u∗Pb) →
    (-, redᴷᴿ $ ←⇒ (-, M‼θ≡u)) , λ{ _ _ (redᴷᴿ (←⇒ _)) → θ↦u∗Pb ▷
    ∗ᵒ-monoˡ ↦ᵒ-write ▷ ⇛ᵒ-eatʳ ▷ ⇛ᵒ-mono λ θ↦u∗Pb → § θ↦v∗P⊨⟨K∇⟩Q θ↦u∗Pb }

  -- alloc and ⁺⟨⟩ᴾᵒ / ⁺⟨⟩ᵀᵒ

  ⁺⟨⟩ᴾᵒ-alloc :
    (∀ θ →
      θ ↦ᴸᵒ rep n ⊤ṽ  ∗ᵒ  Freeᵒ n θ  ∗ᵒ  Pᵒ  ⊨  ⟨ K ᴷ◁ ∇ θ ⟩ᴾᵒ[ ι ]  Qᵒ˙)  →
    Pᵒ  ⊨  ⁺⟨ ĩ₁ (K ᴷ| allocᴿ n) ⟩ᴾᵒ[ ι ]  Qᵒ˙
  ⁺⟨⟩ᴾᵒ-alloc {n = n} θ↦∗Free∗P⊨⟨Kθ⟩Q Pa =  ⁺⟨⟩ᴾᵒ-kr λ M →
    ⇛ᵒ-mono (λ (✓M , big) → (-, redᴷᴿ (alloc⇒ _ $ ✓ᴹ-∑ň ✓M .π₁)) , big) $
    ⇛ᵒ-intro-✓ᴹ λ{ _ _ (redᴷᴿ (alloc⇒ o Mo≡ň)) → Pa ▷
    ?∗ᵒ-intro (↦ᴸᵒ'-alloc Mo≡ň) ▷ ⇛ᵒ-eatʳ ▷ ⇛ᵒ-mono $
    ∗ᵒ-monoˡ (∗ᵒ-mono (↦ᴸᵒ'⇒↦ᴸᵒ {ᵗvs = rep n _}) (λ Fr'b → -, refl , Fr'b)) ›
    ∗ᵒ-assocˡ › θ↦∗Free∗P⊨⟨Kθ⟩Q _ › λ big → λ{ .! → big }}

  ⁺⟨⟩ᵀᵒ-alloc :
    (∀ θ →
      θ ↦ᴸᵒ rep n ⊤ṽ  ∗ᵒ  Freeᵒ n θ  ∗ᵒ  Pᵒ  ⊨  ⟨ K ᴷ◁ ∇ θ ⟩ᵀᵒ[ ι ]  Qᵒ˙)  →
    Pᵒ  ⊨  ⁺⟨ ĩ₁ (K ᴷ| allocᴿ n) ⟩ᵀᵒ[ ∞ ] Qᵒ˙
  ⁺⟨⟩ᵀᵒ-alloc {n} θ↦∗Free∗P⊨⟨Kθ⟩Q Pa =  ⁺⟨⟩ᵀᵒ-kr λ M →
    ⇛ᵒ-mono (λ (✓M , big) → (-, redᴷᴿ (alloc⇒ _ $ ✓ᴹ-∑ň ✓M .π₁)) , big) $
    ⇛ᵒ-intro-✓ᴹ λ{ _ _ (redᴷᴿ (alloc⇒ o Mo≡ň)) → Pa ▷
    ?∗ᵒ-intro (↦ᴸᵒ'-alloc Mo≡ň) ▷ ⇛ᵒ-eatʳ ▷ ⇛ᵒ-mono $
    ∗ᵒ-monoˡ (∗ᵒ-mono (↦ᴸᵒ'⇒↦ᴸᵒ {ᵗvs = rep n _}) (λ Fr'b → -, refl , Fr'b)) ›
    ∗ᵒ-assocˡ › θ↦∗Free∗P⊨⟨Kθ⟩Q _ › §_}

  -- free and ⁺⟨⟩ᴾᵒ / ⁺⟨⟩ᵀᵒ

  ⁺⟨⟩ᴾᵒ-free :  len ᵗvs ≡ n  →   Pᵒ  ⊨  ⟨ K ᴷ◁ ∇ _ ⟩ᴾᵒ[ ι ] Qᵒ˙  →
    θ ↦ᴸᵒ ᵗvs  ∗ᵒ  Freeᵒ n θ  ∗ᵒ  Pᵒ  ⊨  ⁺⟨ ĩ₁ (K ᴷ| freeᴿ θ) ⟩ᴾᵒ[ ι ] Qᵒ˙
  ⁺⟨⟩ᴾᵒ-free {ᵗvs} lenvs≡n P⊨⟨K⟩Q θ↦vs∗Free∗Pa
    with θ↦vs∗Free∗Pa ▷ ?∗ᵒ-comm ▷ ∃ᵒ∗ᵒ-out ▷ (λ (o , big) → o , ∃ᵒ∗ᵒ-out big)
  … | o , refl , Free'∗θ↦vs∗Pa =  ⁺⟨⟩ᴾᵒ-kr λ M → Free'∗θ↦vs∗Pa ▷
    ∗ᵒ-monoˡ Freeᵒ'-š ▷ ⇛ᵒ-eatʳ ▷ ⇛ᵒ-mono $ ∃ᵒ∗ᵒ-out › λ(Mo≡š , Free'∗θ↦vs∗Pb) →
    (-, redᴷᴿ $ free⇒ Mo≡š) , λ{ _ _ (redᴷᴿ (free⇒ _)) → Free'∗θ↦vs∗Pb ▷
    ?∗ᵒ-comm ▷ ∗ᵒ-monoˡ (↦ᴸᵒ⇒↦ᴸᵒ' {ᵗvs = ᵗvs}) ▷ ∗ᵒ-assocʳ ▷
    ∗ᵒ-monoˡ (↦ᴸᵒ'-free lenvs≡n) ▷ ⇛ᵒ-eatʳ ▷ ⇛ᵒ-mono $ ∗ᵒ-monoʳ P⊨⟨K⟩Q ›
    ∗ᵒ-elimʳ ⁺⟨⟩ᴾᵒ-Mono › λ big → λ{ .! → big }}

  ⁺⟨⟩ᵀᵒ-free :  len ᵗvs ≡ n  →   Pᵒ  ⊨  ⟨ K ᴷ◁ ∇ _ ⟩ᵀᵒ[ ι ] Qᵒ˙  →
    θ ↦ᴸᵒ ᵗvs  ∗ᵒ  Freeᵒ n θ  ∗ᵒ  Pᵒ  ⊨  ⁺⟨ ĩ₁ (K ᴷ| freeᴿ θ) ⟩ᵀᵒ[ ∞ ] Qᵒ˙
  ⁺⟨⟩ᵀᵒ-free {ᵗvs} lenvs≡n P⊨⟨K⟩Q θ↦vs∗Free∗Pa
    with θ↦vs∗Free∗Pa ▷ ?∗ᵒ-comm ▷ ∃ᵒ∗ᵒ-out ▷ (λ (o , big) → o , ∃ᵒ∗ᵒ-out big)
  … | o , refl , Free'∗θ↦vs∗Pa =  ⁺⟨⟩ᵀᵒ-kr λ M → Free'∗θ↦vs∗Pa ▷
    ∗ᵒ-monoˡ Freeᵒ'-š ▷ ⇛ᵒ-eatʳ ▷ ⇛ᵒ-mono $ ∃ᵒ∗ᵒ-out › λ(Mo≡š , Free'∗θ↦vs∗Pb) →
    (-, redᴷᴿ $ free⇒ Mo≡š) , λ{ _ _ (redᴷᴿ (free⇒ _)) → Free'∗θ↦vs∗Pb ▷
    ?∗ᵒ-comm ▷ ∗ᵒ-monoˡ (↦ᴸᵒ⇒↦ᴸᵒ' {ᵗvs = ᵗvs}) ▷ ∗ᵒ-assocʳ ▷
    ∗ᵒ-monoˡ (↦ᴸᵒ'-free lenvs≡n) ▷ ⇛ᵒ-eatʳ ▷ ⇛ᵒ-mono $ ∗ᵒ-monoʳ P⊨⟨K⟩Q ›
    ∗ᵒ-elimʳ ⁺⟨⟩ᵀᵒ-Mono › §_}
