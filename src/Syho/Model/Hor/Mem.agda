--------------------------------------------------------------------------------
-- Semantic super update and weakest precondition lemmas for the memory
--------------------------------------------------------------------------------

{-# OPTIONS --sized-types #-}

module Syho.Model.Hor.Mem where

open import Base.Level using (Level)
open import Base.Func using (_$_; _▷_; _›_)
open import Base.Eq using (_≡_; refl; ◠_; _◇_; cong)
open import Base.Size using (Size; ∞; !; §_)
open import Base.Prod using (π₁; _,_; -,_)
open import Base.Sum using (ĩ₁_)
open import Base.Option using (š_; ň)
open import Base.Dec using (upd˙)
open import Base.Nat using (ℕ)
open import Base.List using (List; len; rep)
open import Base.RatPos using (ℚ⁺)
open import Syho.Lang.Expr using (Addr; addr; Type; ∇_; Val; V⇒E; TyVal; ⊤ṽ)
open import Syho.Lang.Ktxred using (Ktx; _ᴷ◁_; 🞰ᴿ_; _←ᴿ_; allocᴿ; freeᴿ; _ᴷ|_)
open import Syho.Lang.Reduce using (Mem; _‼ᴹ_; updᴹ; 🞰⇒; ←⇒; alloc⇒; free⇒;
  redᴷᴿ)
open import Syho.Model.ERA.Glob using (upd˙-mem-envᴳ)
open import Syho.Model.ERA.Mem using (εᴹᵉᵐ; ↦⟨⟩ʳ-read; ↦ʳ-write; ↦ᴸʳ-alloc;
  ↦ᴸʳ-free)
open import Syho.Model.Prop.Base using (Propᵒ; _⊨_; ⊨_; ⌜_⌝ᵒ×_; ⊤ᵒ₀; _∗ᵒ_;
  _⤇ᴱ_; ∗ᵒ-monoˡ; ∃ᵒ∗ᵒ-out; ⤇ᴱ-mono; ⤇ᴱ-respᴱʳ; ⤇ᴱ-param; ◎⟨⟩-∗ᵒ⇒∙; ◎⟨⟩-∙⇒∗ᵒ;
  ↝-◎⟨⟩-⤇ᴱ; ε↝-◎⟨⟩-⤇ᴱ)
open import Syho.Model.Prop.Mem using (_↦⟨_⟩ᵒ_; _↦ᵒ_; Freeᵒ'; Freeᵒ; _↦ᴸᵒ_;
  _↦ᴸᵒ'_; ↦ᴸᵒ⇒↦ᴸᵒ'; ↦ᴸᵒ'⇒↦ᴸᵒ)
open import Syho.Model.Supd.Interp using (⟨_⟩⇛ᵒ⟨_⟩_; ⇛ᵒ-mono; ?⊨⤇ᴱᴹᵉᵐ⇒?⊨⇛ᵒ;
  ⊨⤇ᴱᴹᵉᵐ⇒⊨⇛ᵒ; ⇛ᵒ-intro; ⇛ᵒ-eatʳ)
open import Syho.Model.Hor.Wp using (⁺⟨_⟩ᴾᵒ[_]_; ⁺⟨_⟩ᵀᵒ[_]_; ⟨_⟩ᴾᵒ[_]_;
  ⟨_⟩ᵀᵒ[_]_; ⁺⟨⟩ᴾᵒ-kr; ⁺⟨⟩ᵀᵒ-kr)

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
  ⁺⟨⟩ᴾᵒ-← θ↦v∗P⊨⟨K∇⟩Q θ↦u∗Pa =  ⁺⟨⟩ᴾᵒ-kr λ M → ⇛ᵒ-intro ((-, redᴷᴿ ←⇒) ,
    λ{ _ _ (redᴷᴿ ←⇒) → θ↦u∗Pa ▷ ∗ᵒ-monoˡ ↦ᵒ-write ▷ ⇛ᵒ-eatʳ ▷ ⇛ᵒ-mono
    λ θ↦u∗Pb → λ{ .! → θ↦v∗P⊨⟨K∇⟩Q θ↦u∗Pb }})

  ⁺⟨⟩ᵀᵒ-← :  θ ↦ᵒ (-, v)  ∗ᵒ  Pᵒ  ⊨  ⟨ K ᴷ◁ ∇ _ ⟩ᵀᵒ[ ι ]  Qᵒ˙ →
             θ ↦ᵒ (-, u)  ∗ᵒ  Pᵒ  ⊨  ⁺⟨ ĩ₁ (K ᴷ| θ ←ᴿ v) ⟩ᵀᵒ[ ∞ ]  Qᵒ˙
  ⁺⟨⟩ᵀᵒ-← θ↦v∗P⊨⟨K⟩Q θ↦u∗Pa =  ⁺⟨⟩ᵀᵒ-kr λ M → ⇛ᵒ-intro ((-, redᴷᴿ ←⇒) ,
    λ{ _ _ (redᴷᴿ ←⇒) → θ↦u∗Pa ▷ ∗ᵒ-monoˡ ↦ᵒ-write ▷ ⇛ᵒ-eatʳ ▷ ⇛ᵒ-mono
    λ θ↦u∗Pb → § θ↦v∗P⊨⟨K⟩Q θ↦u∗Pb })
