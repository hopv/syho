--------------------------------------------------------------------------------
-- Adequacy of the semantic partial and total weakest preconditions
--------------------------------------------------------------------------------

{-# OPTIONS --without-K --sized-types #-}

module Symp.Model.Hor.Adeq where

open import Base.Level using (Level; 1ᴸ; 3ᴸ)
open import Base.Func using (_$_; _▷_; _›_)
open import Base.Few using (⊤; ⊥₀; absurd)
open import Base.Eq using (_≡_; refl)
open import Base.Acc using (Acc; acc)
open import Base.Size using (𝕊; ∞; 𝕊'; sz; sz⁻¹; _<ˢ_; size<; !; §_;
  <ˢ-wf)
open import Base.Bool using (tt; ff)
open import Base.Prod using (∑-syntax; _×_; π₀; π₁; _,_; -,_)
open import Base.Sum using (ĩ₀_; ĩ₁_)
open import Base.Option using (¿_; ň; š_)
open import Base.List using (List; []; _∷_; ¿⇒ᴸ; _⧺_; _$ᴸ_; _∈ᴸ_; ∈ʰᵈ; ∈ᵗˡ_;
  aug-refl; aug-∷; _≺ᴰᴹ⟨_⟩_; Rᴰᴹ; ≺ᴰᴹ-hd; ≺ᴰᴹ-tl; ≺ᴰᴹ-wf)
open import Base.Sety using ()
open import Symp.Lang.Expr using (Type; ◸_; Expr∞; Val; V⇒E; Heap; ✓ᴴ_)
open import Symp.Lang.Ktxred using (Ktxred; val/ktxred; val/ktxred-ĩ₀;
  val/ktxred-V⇒E)
open import Symp.Lang.Reduce using ([]⇒; redᴷᴿ; _⇒ᴷᴿ∑; redᴱ; _⇒ᵀ_; _⇒ᵀ○_; _⇒ᵀ●_;
  redᵀ-hd; redᵀ-tl; _⇒ᵀ*_; ⇒ᵀ*-refl; ⇒ᵀ*-step; SNᵀ; Infᵀ; infᵀ)
open import Symp.Model.ERA.Glob using (Resᴳ; _✓ᴳ_; Envᴵⁿᴳ; envᴳ; ∅ᴵⁿᴳ-✓ᴺ)
open import Symp.Model.Prop.Base using (SPropᵒ; Monoᵒ; _⊨_; ⊨_; ∃ᵒ-syntax;
  ⌜_⌝ᵒ; ⌜_⌝ᵒ×_; ⊥ᵒ₀; _∗ᵒ_; [∗ᵒ∈]-syntax; [∗ᵒ∈²]-syntax; Thunkᵒ; substᵒ;
  ⌜⌝ᵒ-Mono; ∗ᵒ⇒∗ᵒ'; ∗ᵒ'⇒∗ᵒ; ∗ᵒ-mono; ∗ᵒ-monoˡ; ∗ᵒ-monoʳ; ∗ᵒ-assocˡ; ∗ᵒ-assocʳ;
  ?∗ᵒ-comm; ∗ᵒ?-intro; ∗ᵒ-elimˡ; ∗ᵒ-elimʳ; [∗ᵒ]-Mono; [∗ᵒ∈²]-Mono; -∗ᵒ-applyˡ;
  ◎-just; Shrunkᵒ∗ᵒ-out)
open import Symp.Model.Prop.Names using ([⊤]ᴺᵒ)
open import Symp.Model.Fupd.Interp using (⟨_⟩⇛ˢ⟨_⟩_; Invᴳ; Invᴳ-∅; ⇛ˢ-Mono;
  ⇛ˢ-mono✓; ⇛ˢ-mono; ⊨✓⇒⊨-⇛ˢ; ⇛ˢ-intro; ⇛ˢ-join; ⇛ˢ-eatˡ; ⇛ˢ-eatʳ; ⇛ˢ-adeq;
  ⇛ˢ-step)
open import Symp.Model.Hor.Wp using (⁺⟨_⟩ᴾᵒ; ⟨_⟩ᴾᵒ; ⟨_⟩ᵀᵒ; ⟨_⟩∞ᵒ; ⟨_⟩ᵀᵒ˂;
  ⟨_⟩∞ᵒ˂ˡ; ⟨_⟩∞ᵒ˂ʳ; ⟨_⟩ᴾᵒ⊤; ⟨_⟩ᵀᵒ⊤; ⟨¿_⟩ᴾᵒ⊤˂; ⟨¿_⟩ᵀᵒ⊤˂; ⁺⟨⟩ᴾᵒ-val⁻¹; ⁺⟨⟩ᴾᵒ-kr⁻¹;
  ⁺⟨⟩ᵀᵒ-kr⁻¹; ⁺⟨⟩∞ᵒ-kr⁻¹; ⁺⟨⟩ᴾᵒ-Mono; ⁺⟨⟩ᴾᵒ⊤-Mono; ⁺⟨⟩ᵀᵒ-Mono; ⁺⟨⟩∞ᵒ-Mono;
  ∀ᵒ⇛ˢ-Mono; ⁺⟨⟩ᴾᵒ⊤⇒⁺⟨⟩ᴾᵒ; ⁺⟨⟩ᵀᵒ⊤⇒⁺⟨⟩ᵀᵒ; ⁺⟨⟩ᴾᵒ⇒⁺⟨⟩ᴾᵒ⊤; ⁺⟨⟩ᵀᵒ⇒⁺⟨⟩ᵀᵒ⊤;
  ⁺⟨⟩ᵀᵒ⇒⁺⟨⟩ᴾᵒ; ⁺⟨⟩∞ᵒ⇒⁺⟨⟩ᴾᵒ)

private variable
  ł :  Level
  ι ι₀ ι' :  𝕊
  ιs :  List (𝕊' 3ᴸ)
  H H' :  Heap
  X :  Set₀
  T :  Type
  e⁺ e e' :  Expr∞ T
  eˇ eˇ' :  ¿ Expr∞ (◸ ⊤)
  es es' :  List (Expr∞ (◸ ⊤))
  v :  X
  kr :  Ktxred T
  Pᵒ˙ :  X → SPropᵒ ł
  X˙ :  X → Set ł
  Eᴵⁿ :  Envᴵⁿᴳ
  a :  Resᴳ

--------------------------------------------------------------------------------
-- Adequacy of the semantic partial weakest precondition

-- Separating conjunction of ⟨ ⟩ᴾᵒ⊤ ∞ over expressions of type ◸ ⊤

[∗ᵒ]⟨_⟩ᴾᵒ⊤∞ :  List (Expr∞ (◸ ⊤)) →  SPropᵒ 1ᴸ
[∗ᵒ]⟨ es ⟩ᴾᵒ⊤∞ =  [∗ᵒ e ∈ es ] ⟨ e ⟩ᴾᵒ⊤ ∞

abstract

  -- Monoᵒ for [∗ᵒ]⟨ ⟩ᴾᵒ⊤∞

  [∗ᵒ]⟨⟩ᴾᵒ⊤∞-Mono :  Monoᵒ [∗ᵒ]⟨ es ⟩ᴾᵒ⊤∞
  [∗ᵒ]⟨⟩ᴾᵒ⊤∞-Mono {es = es} =  [∗ᵒ]-Mono {Pᵒs = (λ e → ⟨ e ⟩ᴾᵒ⊤ ∞) $ᴸ es}

  -- Eliminate [∗ᵒ]⟨⟩ᴾᵒ⊤∞ with ∈ᴸ

  [∗ᵒ]⟨⟩ᴾᵒ⊤∞-elim :  e ∈ᴸ es →  [∗ᵒ]⟨ es ⟩ᴾᵒ⊤∞  ⊨  ⟨ e ⟩ᴾᵒ⊤ ∞
  [∗ᵒ]⟨⟩ᴾᵒ⊤∞-elim ∈ʰᵈ =  ∗ᵒ-elimˡ ⁺⟨⟩ᴾᵒ⊤-Mono
  [∗ᵒ]⟨⟩ᴾᵒ⊤∞-elim {es = _ ∷ es'} (∈ᵗˡ ∈es') =
    ∗ᵒ-elimʳ ([∗ᵒ]⟨⟩ᴾᵒ⊤∞-Mono {es = es'}) › [∗ᵒ]⟨⟩ᴾᵒ⊤∞-elim ∈es'

  -- Lemma: If (e , es , H) ⇒ᵀ (e' , es' , H'),
  -- then ⟨ e ⟩ᴾᵒ ∞ Pᵒ˙ ∗ᵒ [∗ᵒ]⟨ es ⟩ᴾᵒ⊤∞ entails
  -- ⟨ e' ⟩ᴾᵒ ∞ Pᵒ˙ ∗ᵒ [∗ᵒ]⟨ es' ⟩ᴾᵒ⊤∞ under ⟨ H ⟩⇛ˢ⟨ H' ⟩ with [⊤]ᴺᵒ

  ⟨⟩ᴾᵒ-[∗ᵒ]⟨⟩ᴾᵒ⊤∞-⇒ᵀ :  (e , es , H) ⇒ᵀ (e' , es' , H') →
    [⊤]ᴺᵒ ∗ᵒ ⟨ e ⟩ᴾᵒ ∞ Pᵒ˙ ∗ᵒ [∗ᵒ]⟨ es ⟩ᴾᵒ⊤∞  ⊨ ⟨ H ⟩⇛ˢ⟨ H' ⟩
      [⊤]ᴺᵒ ∗ᵒ ⟨ e' ⟩ᴾᵒ ∞ Pᵒ˙ ∗ᵒ [∗ᵒ]⟨ es' ⟩ᴾᵒ⊤∞
  ⟨⟩ᴾᵒ-[∗ᵒ]⟨⟩ᴾᵒ⊤∞-⇒ᵀ (-, redᵀ-hd {es = es} (redᴱ {eˇ = eˇ} e⇒kr e'eˇH'⇐))
    rewrite e⇒kr =  ∗ᵒ-assocˡ › ∗ᵒ-monoˡ (⊨✓⇒⊨-⇛ˢ λ ✓∙ → ∗ᵒ-monoʳ ⁺⟨⟩ᴾᵒ-kr⁻¹ ›
    -∗ᵒ-applyˡ ∀ᵒ⇛ˢ-Mono ✓∙ › (_$ _) › ⇛ˢ-mono (λ (-, big) →
    big _ _ _ _ e'eˇH'⇐ ▷ ⇛ˢ-mono (∗ᵒ-monoʳ $ ∗ᵒ-monoˡ λ big → big .!)) ›
    ⇛ˢ-join) › ⇛ˢ-eatʳ › ⇛ˢ-mono $ ∗ᵒ-assocʳ › ∗ᵒ-monoʳ $ ∗ᵒ-assocʳ ›
    ∗ᵒ-monoʳ $ go {eˇ}
   where
    go :  ⟨¿ eˇ' ⟩ᴾᵒ⊤˂ ∞ ∗ᵒ [∗ᵒ]⟨ es ⟩ᴾᵒ⊤∞  ⊨  [∗ᵒ]⟨ ¿⇒ᴸ eˇ' ⧺ es ⟩ᴾᵒ⊤∞
    go {ň} =  ∗ᵒ-elimʳ $ [∗ᵒ]⟨⟩ᴾᵒ⊤∞-Mono {es = es}
    go {š _} =  ∗ᵒ-monoˡ λ big → big .!
  ⟨⟩ᴾᵒ-[∗ᵒ]⟨⟩ᴾᵒ⊤∞-⇒ᵀ (-, redᵀ-tl es'H'⇐esH) =  ?∗ᵒ-comm › ∗ᵒ-monoʳ
    (∗ᵒ-monoʳ (∗ᵒ-monoˡ ⁺⟨⟩ᴾᵒ⊤⇒⁺⟨⟩ᴾᵒ) › ⟨⟩ᴾᵒ-[∗ᵒ]⟨⟩ᴾᵒ⊤∞-⇒ᵀ (-, es'H'⇐esH)) ›
    ⇛ˢ-eatˡ › ⇛ˢ-mono $ ?∗ᵒ-comm › ∗ᵒ-monoʳ $ ∗ᵒ-monoʳ $ ∗ᵒ-monoˡ ⁺⟨⟩ᴾᵒ⇒⁺⟨⟩ᴾᵒ⊤

  -- Lemma: If (e , es , H) ⇒ᵀ* (e' , es' , H'),
  -- then ⟨ e ⟩ᴾᵒ ∞ Pᵒ˙ ∗ᵒ [∗ᵒ]⟨ es ⟩ᴾᵒ⊤∞ entails
  -- ⟨ e' ⟩ᴾᵒ ∞ Pᵒ˙ ∗ᵒ [∗ᵒ]⟨ es' ⟩ᴾᵒ⊤∞ under ⟨ H ⟩⇛ˢ⟨ H' ⟩ with [⊤]ᴺᵒ

  ⟨⟩ᴾᵒ-[∗ᵒ]⟨⟩ᴾᵒ⊤∞-⇒ᵀ* :  (e , es , H) ⇒ᵀ* (e' , es' , H') →
    [⊤]ᴺᵒ ∗ᵒ ⟨ e ⟩ᴾᵒ ∞ Pᵒ˙ ∗ᵒ [∗ᵒ]⟨ es ⟩ᴾᵒ⊤∞  ⊨ ⟨ H ⟩⇛ˢ⟨ H' ⟩
      [⊤]ᴺᵒ ∗ᵒ ⟨ e' ⟩ᴾᵒ ∞ Pᵒ˙ ∗ᵒ [∗ᵒ]⟨ es' ⟩ᴾᵒ⊤∞
  ⟨⟩ᴾᵒ-[∗ᵒ]⟨⟩ᴾᵒ⊤∞-⇒ᵀ* ⇒ᵀ*-refl =  ⇛ˢ-intro
  ⟨⟩ᴾᵒ-[∗ᵒ]⟨⟩ᴾᵒ⊤∞-⇒ᵀ* (⇒ᵀ*-step H⇒ᵀM'' H''⇒ᵀ*H') =  ⟨⟩ᴾᵒ-[∗ᵒ]⟨⟩ᴾᵒ⊤∞-⇒ᵀ H⇒ᵀM'' ›
    ⇛ˢ-mono (⟨⟩ᴾᵒ-[∗ᵒ]⟨⟩ᴾᵒ⊤∞-⇒ᵀ* H''⇒ᵀ*H') › ⇛ˢ-join

  -- Postcondition: ⊨ ⟨ e ⟩ᴾᵒ ∞ λ u → ⌜ X˙ u ⌝ᵒ ensures that the X˙ v holds for
  -- the result value v of any execution of (e , [] , H) for valid H

  ⟨⟩ᴾᵒ-post :  ⊨ ⟨ e ⟩ᴾᵒ ∞ (λ u → ⌜ X˙ u ⌝ᵒ) →  ✓ᴴ H →
               (e , [] , H) ⇒ᵀ* (V⇒E {T} v , es , H') →  X˙ v
  ⟨⟩ᴾᵒ-post ⊨⟨e⟩X ✓H eH⇒*vesH' =  ⇛ˢ-adeq ✓H $ ∗ᵒ?-intro (⊨⟨e⟩X ▷ ∗ᵒ?-intro _) ›
    ⟨⟩ᴾᵒ-[∗ᵒ]⟨⟩ᴾᵒ⊤∞-⇒ᵀ* eH⇒*vesH' › ⇛ˢ-mono✓ (λ ✓∙ →
    ∗ᵒ-monoʳ (∗ᵒ-elimˡ ⁺⟨⟩ᴾᵒ-Mono ›
    substᵒ (λ kr → ⁺⟨ kr ⟩ᴾᵒ ∞ _) (val/ktxred-V⇒E) › ⁺⟨⟩ᴾᵒ-val⁻¹) ›
    -∗ᵒ-applyˡ ∀ᵒ⇛ˢ-Mono ✓∙ › (_$ _) › ⇛ˢ-mono $ ∗ᵒ-elimʳ ⌜⌝ᵒ-Mono) › ⇛ˢ-join

  -- Progress: If ⟨ e ⟩ᴾᵒ ∞ Pᵒ˙ is a tautology, then any execution of
  -- (e , [] , H) never gets stuck for valid H

  -- For the main thread

  ⟨⟩ᴾᵒ-progress-main :  ⊨ ⟨ e ⟩ᴾᵒ ∞ Pᵒ˙ →  ✓ᴴ H →
    (e , [] , H) ⇒ᵀ* (e' , es , H') →  val/ktxred e' ≡ ĩ₁ kr →  (kr , H') ⇒ᴷᴿ∑
  ⟨⟩ᴾᵒ-progress-main ⊨⟨e⟩P ✓H eH⇒*e'esH' e'≡kr =  ⇛ˢ-adeq ✓H $
    ∗ᵒ?-intro (⊨⟨e⟩P ▷ ∗ᵒ?-intro _) › ⟨⟩ᴾᵒ-[∗ᵒ]⟨⟩ᴾᵒ⊤∞-⇒ᵀ* eH⇒*e'esH' ›
    ⇛ˢ-mono✓ (λ ✓∙ → ∗ᵒ-monoʳ (∗ᵒ-elimˡ ⁺⟨⟩ᴾᵒ-Mono ›
    substᵒ (λ kr → ⁺⟨ kr ⟩ᴾᵒ ∞ _) e'≡kr › ⁺⟨⟩ᴾᵒ-kr⁻¹) ›
    -∗ᵒ-applyˡ ∀ᵒ⇛ˢ-Mono ✓∙ › (_$ _) › ⇛ˢ-mono π₀) › ⇛ˢ-join

  -- For forked threads

  ⟨⟩ᴾᵒ-progress-forked :
    ⊨ ⟨ e ⟩ᴾᵒ ∞ Pᵒ˙ →  ✓ᴴ H →  (e , [] , H) ⇒ᵀ* (e' , es , H') →  e⁺ ∈ᴸ es →
    val/ktxred e⁺ ≡ ĩ₁ kr →  (kr , H') ⇒ᴷᴿ∑
  ⟨⟩ᴾᵒ-progress-forked {es = es} ⊨⟨e⟩P ✓H eH⇒*e'esH' e⁺∈es e⁺≡kr =  ⇛ˢ-adeq ✓H $
    ∗ᵒ?-intro (⊨⟨e⟩P ▷ ∗ᵒ?-intro _) › ⟨⟩ᴾᵒ-[∗ᵒ]⟨⟩ᴾᵒ⊤∞-⇒ᵀ* eH⇒*e'esH' ›
    ⇛ˢ-mono✓ (λ ✓∙ → ∗ᵒ-monoʳ (∗ᵒ-elimʳ ([∗ᵒ]⟨⟩ᴾᵒ⊤∞-Mono {es = es}) ›
    [∗ᵒ]⟨⟩ᴾᵒ⊤∞-elim e⁺∈es › ⁺⟨⟩ᴾᵒ⊤⇒⁺⟨⟩ᴾᵒ ›
    substᵒ (λ kr → ⁺⟨ kr ⟩ᴾᵒ ∞ _) e⁺≡kr › ⁺⟨⟩ᴾᵒ-kr⁻¹) ›
    -∗ᵒ-applyˡ ∀ᵒ⇛ˢ-Mono ✓∙ › (_$ _) › ⇛ˢ-mono π₀) › ⇛ˢ-join

--------------------------------------------------------------------------------
-- Adequacy of the semantic total weakest precondition

-- Separating conjunction of ⟨ ⟩ᵀᵒ⊤ over expressions of type ◸ ⊤ and sizes

[∗ᵒ]⟨_⟩ᵀᵒ⊤ :  List (Expr∞ (◸ ⊤)) →  List (𝕊' 3ᴸ) →  SPropᵒ 1ᴸ
[∗ᵒ]⟨ es ⟩ᵀᵒ⊤ ιs =  [∗ᵒ (e , sz ι) ∈² es , ιs ] ⟨ e ⟩ᵀᵒ⊤ ι

abstract

  -- Monoᵒ for [∗ᵒ]⟨ ⟩ᵀᵒ⊤

  [∗ᵒ]⟨⟩ᵀᵒ⊤-Mono :  Monoᵒ $ [∗ᵒ]⟨ es ⟩ᵀᵒ⊤ ιs
  [∗ᵒ]⟨⟩ᵀᵒ⊤-Mono {es} =  [∗ᵒ∈²]-Mono {xs = es}

  -- Postcondition

  ⟨⟩ᵀᵒ-post :  ⊨ ⟨ e ⟩ᵀᵒ ∞ (λ u → ⌜ X˙ u ⌝ᵒ) →  ✓ᴴ H →
               (e , [] , H) ⇒ᵀ* (V⇒E v , es , H') →  X˙ v
  ⟨⟩ᵀᵒ-post ⊨⟨e⟩X =  ⟨⟩ᴾᵒ-post $ λ{a} → ⊨⟨e⟩X {a} ▷ ⁺⟨⟩ᵀᵒ⇒⁺⟨⟩ᴾᵒ

  -- Progress

  ⟨⟩ᵀᵒ-progress-main :  ⊨ ⟨ e ⟩ᵀᵒ ∞ Pᵒ˙ →  ✓ᴴ H →
    (e , [] , H) ⇒ᵀ* (e' , es , H') →  val/ktxred e' ≡ ĩ₁ kr →  (kr , H') ⇒ᴷᴿ∑
  ⟨⟩ᵀᵒ-progress-main ⊨⟨e⟩P =  ⟨⟩ᴾᵒ-progress-main $ ⊨⟨e⟩P ▷ ⁺⟨⟩ᵀᵒ⇒⁺⟨⟩ᴾᵒ

  ⟨⟩ᵀᵒ-progress-forked :
    ⊨ ⟨ e ⟩ᵀᵒ ∞ Pᵒ˙ →  ✓ᴴ H →  (e , [] , H) ⇒ᵀ* (e' , es , H') →  e⁺ ∈ᴸ es →
    val/ktxred e⁺ ≡ ĩ₁ kr →  (kr , H') ⇒ᴷᴿ∑
  ⟨⟩ᵀᵒ-progress-forked ⊨⟨e⟩P =  ⟨⟩ᴾᵒ-progress-forked $ ⊨⟨e⟩P ▷ ⁺⟨⟩ᵀᵒ⇒⁺⟨⟩ᴾᵒ

  -- Lemma: If (e , es , H) ⇒ᵀ (e' , es' , H'),
  -- then ⟨ e ⟩ᵀᵒ ι Pᵒ˙ ∗ᵒ [∗ᵒ]⟨ es ⟩ᵀᵒ⊤ ιs entails
  -- ⟨ e' ⟩ᵀᵒ ι' Pᵒ˙ ∗ᵒ [∗ᵒ]⟨ es' ⟩ᵀᵒ⊤ ιs' under ⟨ H ⟩⇛ˢ⟨ H' ⟩ with [⊤]ᴺᵒ
  -- for some ι', ιs' satisfying sz ι' ∷ ιs' ≺ᴰᴹ⟨ _<ˢ_ ⟩ sz ι ∷ ιs

  ⟨⟩ᵀᵒ-[∗ᵒ]⟨⟩ᵀᵒ⊤-⇒ᵀ :  (e , es , H) ⇒ᵀ (e' , es' , H') →
    [⊤]ᴺᵒ ∗ᵒ ⟨ e ⟩ᵀᵒ ι Pᵒ˙ ∗ᵒ [∗ᵒ]⟨ es ⟩ᵀᵒ⊤ ιs  ⊨ ⟨ H ⟩⇛ˢ⟨ H' ⟩
      ∃ᵒ ι'⁺ , ∃ᵒ ιs' , ⌜ ι'⁺ ∷ ιs' ≺ᴰᴹ⟨ _<ˢ_ ⟩ sz ι ∷ ιs ⌝ᵒ×
        [⊤]ᴺᵒ ∗ᵒ ⟨ e' ⟩ᵀᵒ (sz⁻¹ ι'⁺) Pᵒ˙ ∗ᵒ [∗ᵒ]⟨ es' ⟩ᵀᵒ⊤ ιs'
  ⟨⟩ᵀᵒ-[∗ᵒ]⟨⟩ᵀᵒ⊤-⇒ᵀ (-, redᵀ-hd {es = es} (redᴱ {eˇ = eˇ} e⇒kr e'eˇH'⇐))
    rewrite e⇒kr =  ∗ᵒ-assocˡ › ∗ᵒ-monoˡ (⊨✓⇒⊨-⇛ˢ λ ✓∙ → ∗ᵒ-monoʳ ⁺⟨⟩ᵀᵒ-kr⁻¹ ›
    -∗ᵒ-applyˡ ∀ᵒ⇛ˢ-Mono ✓∙ › (_$ _) ›
    ⇛ˢ-mono (λ (-, big) → big _ _ _ _ e'eˇH'⇐) › ⇛ˢ-join) › ⇛ˢ-eatʳ ›
    ⇛ˢ-mono $ ∗ᵒ-assocʳ › ∗ᵒ-monoʳ (∗ᵒ-assocʳ › go {eˇ' = eˇ}) › ∗ᵒ⇒∗ᵒ' ›
    λ{ (-, -, b∙c⊑a , [⊤]b , -, -, ι'∷ιs'≺ι∷ιs , big) →
    -, -, ι'∷ιs'≺ι∷ιs , ∗ᵒ'⇒∗ᵒ (-, -, b∙c⊑a , [⊤]b , big) }
   where
    go :  ⟨ e ⟩ᵀᵒ˂ ι Pᵒ˙ ∗ᵒ ⟨¿ eˇ' ⟩ᵀᵒ⊤˂ ι ∗ᵒ [∗ᵒ]⟨ es ⟩ᵀᵒ⊤ ιs ⊨
            ∃ᵒ ι'⁺ , ∃ᵒ ιs' , ⌜ ι'⁺ ∷ ιs' ≺ᴰᴹ⟨ _<ˢ_ ⟩ sz ι ∷ ιs ⌝ᵒ×
              ⟨ e ⟩ᵀᵒ (sz⁻¹ ι'⁺) Pᵒ˙ ∗ᵒ [∗ᵒ]⟨ ¿⇒ᴸ eˇ' ⧺ es ⟩ᵀᵒ⊤ ιs'
    go {eˇ' = ň} =  Shrunkᵒ∗ᵒ-out › λ{ (§ big) → -, -,
      ≺ᴰᴹ-hd $ aug-∷ size< aug-refl ,
      big ▷ ∗ᵒ-monoʳ (∗ᵒ-elimʳ $ [∗ᵒ]⟨⟩ᵀᵒ⊤-Mono {es}) }
    go {eˇ' = š _} =  Shrunkᵒ∗ᵒ-out › λ{ (§ big) → big ▷ ?∗ᵒ-comm ▷
      Shrunkᵒ∗ᵒ-out ▷ λ{ (§ big) → -, -,
      ≺ᴰᴹ-hd $ aug-∷ size< $ aug-∷ size< aug-refl , big ▷ ?∗ᵒ-comm }}
  ⟨⟩ᵀᵒ-[∗ᵒ]⟨⟩ᵀᵒ⊤-⇒ᵀ {ιs = []} (-, redᵀ-tl _) =  ∗ᵒ-assocˡ › ∗ᵒ⇒∗ᵒ' › λ ()
  ⟨⟩ᵀᵒ-[∗ᵒ]⟨⟩ᵀᵒ⊤-⇒ᵀ {ιs = _ ∷ _} (-, redᵀ-tl esH⇒) =  ?∗ᵒ-comm ›
    ∗ᵒ-monoʳ (∗ᵒ-monoʳ (∗ᵒ-monoˡ ⁺⟨⟩ᵀᵒ⊤⇒⁺⟨⟩ᵀᵒ) › ⟨⟩ᵀᵒ-[∗ᵒ]⟨⟩ᵀᵒ⊤-⇒ᵀ (-, esH⇒)) ›
    ⇛ˢ-eatˡ › ⇛ˢ-mono $ ∗ᵒ⇒∗ᵒ' › λ (-, -, ∙⊑ , ⟨e⟩P , -, -, ι'∷ιs'≺ , big) →
    -, -, ≺ᴰᴹ-tl ι'∷ιs'≺ ,
    ∗ᵒ'⇒∗ᵒ (-, -, ∙⊑ , ⟨e⟩P , big ▷ ∗ᵒ-monoʳ (∗ᵒ-monoˡ ⁺⟨⟩ᵀᵒ⇒⁺⟨⟩ᵀᵒ⊤)) ▷ ?∗ᵒ-comm

  -- Termination: ⊨ ⟨ e ⟩ᵀᵒ ι Pᵒ˙ ensures that (e , [] , H) is strongly
  -- normalizing, i.e., any execution of (e , [] , H) terminates, for valid H

  ⟨⟩ᵀᵒ⇒SN :  ⊨ ⟨ e ⟩ᵀᵒ ι Pᵒ˙ →  ✓ᴴ H →  SNᵀ (e , [] , H)
  ⟨⟩ᵀᵒ⇒SN ⊨⟨e⟩P ✓H =  go {ιs = []} (≺ᴰᴹ-wf <ˢ-wf) (∅ᴵⁿᴳ-✓ᴺ ✓H) $
    ◎-just ▷ ∗ᵒ?-intro (∗ᵒ?-intro _ ⊨⟨e⟩P) ▷ ∗ᵒ?-intro Invᴳ-∅
   where
    -- Well-founded induction on sz ι ∷ ιs
    go :  Acc (Rᴰᴹ _<ˢ_) (sz ι ∷ ιs) →  envᴳ H Eᴵⁿ ✓ᴳ a →
      (([⊤]ᴺᵒ ∗ᵒ ⟨ e ⟩ᵀᵒ ι Pᵒ˙ ∗ᵒ [∗ᵒ]⟨ es ⟩ᵀᵒ⊤ ιs) ∗ᵒ Invᴳ Eᴵⁿ) a  →
      SNᵀ (e , es , H)
    go (acc ≺ι∷ιs⇒acc) HE✓a big =  acc λ eesH⇒ → big ▷
      ∗ᵒ-monoˡ (⟨⟩ᵀᵒ-[∗ᵒ]⟨⟩ᵀᵒ⊤-⇒ᵀ eesH⇒) ▷ ⇛ˢ-step HE✓a ▷
      λ (-, -, H'E'✓b , big) → ∗ᵒ⇒∗ᵒ' big ▷
      λ (-, -, ∙⊑ , (-, -, ≺ι∷ιs , big) , InvE') →
      go (≺ι∷ιs⇒acc ≺ι∷ιs) H'E'✓b $ ∗ᵒ'⇒∗ᵒ (-, -, ∙⊑ , big , InvE')

--------------------------------------------------------------------------------
-- Adequacy of the semantic infinite weakest precondition

abstract

  -- Progress
  -- The main thread never becomes a value

  ⟨⟩∞ᵒ-progress-main :
    ⊨ ⟨ e ⟩∞ᵒ ι ∞ →  ✓ᴴ H →  (e , [] , H) ⇒ᵀ* (e' , es , H') →
    ∑ kr ,  val/ktxred e' ≡ ĩ₁ kr  ×  (kr , H') ⇒ᴷᴿ∑
  ⟨⟩∞ᵒ-progress-main {e' = e'} ⊨⟨e⟩P ✓H eH⇒* with val/ktxred e' |
    (λ{v} → val/ktxred-ĩ₀ {e = e'} {v}) | (λ{kr} → ⟨⟩ᴾᵒ-progress-main
    {Pᵒ˙ = λ _ → ⊥ᵒ₀} {kr = kr} (⁺⟨⟩∞ᵒ⇒⁺⟨⟩ᴾᵒ ⊨⟨e⟩P) ✓H eH⇒*)
  … | ĩ₀ v | ⇒e'⇒v | _  rewrite ⇒e'⇒v refl =  absurd $
    ⟨⟩ᴾᵒ-post {X˙ = λ _ → ⊥₀} (⁺⟨⟩∞ᵒ⇒⁺⟨⟩ᴾᵒ ⊨⟨e⟩P) ✓H eH⇒*
  … | ĩ₁ kr | _ | ⇒krH'⇒ =  -, refl , ⇒krH'⇒ refl

  ⟨⟩∞ᵒ-progress-forked :
    ⊨ ⟨ e ⟩∞ᵒ ι ∞ →  ✓ᴴ H →  (e , [] , H) ⇒ᵀ* (e' , es , H') →  e⁺ ∈ᴸ es →
    val/ktxred e⁺ ≡ ĩ₁ kr →  (kr , H') ⇒ᴷᴿ∑
  ⟨⟩∞ᵒ-progress-forked ⊨⟨e⟩P =
    ⟨⟩ᴾᵒ-progress-forked $ ⊨⟨e⟩P ▷ ⁺⟨⟩∞ᵒ⇒⁺⟨⟩ᴾᵒ {Pᵒ˙ = λ _ → ⊥ᵒ₀}

  -- Lemma: If (e , es , H) ⇒ᵀ○ (e' , es' , H'),
  -- then ⟨ e ⟩∞ᵒ ι ι₀ ∗ᵒ [∗ᵒ]⟨ es ⟩ᵀᵒ⊤ ιs entails
  -- ⟨ e' ⟩∞ᵒ ι' ι₀ ∗ᵒ [∗ᵒ]⟨ es' ⟩ᵀᵒ⊤ ιs' under ⟨ H ⟩⇛ˢ⟨ H' ⟩ with [⊤]ᴺᵒ
  -- for some ι', ιs' satisfying sz ι' ∷ ιs' ≺ᴰᴹ⟨ _<ˢ_ ⟩ sz ι ∷ ιs

  ⟨⟩∞ᵒ-[∗ᵒ]⟨⟩ᵀᵒ⊤-⇒ᵀ○ :  (e , es , H) ⇒ᵀ○ (e' , es' , H') →
    [⊤]ᴺᵒ ∗ᵒ ⟨ e ⟩∞ᵒ ι ι₀ ∗ᵒ [∗ᵒ]⟨ es ⟩ᵀᵒ⊤ ιs  ⊨ ⟨ H ⟩⇛ˢ⟨ H' ⟩
      ∃ᵒ ι'⁺ , ∃ᵒ ιs' , ⌜ ι'⁺ ∷ ιs' ≺ᴰᴹ⟨ _<ˢ_ ⟩ sz ι ∷ ιs ⌝ᵒ×
        [⊤]ᴺᵒ ∗ᵒ ⟨ e' ⟩∞ᵒ (sz⁻¹ ι'⁺) ι₀ ∗ᵒ [∗ᵒ]⟨ es' ⟩ᵀᵒ⊤ ιs'
  ⟨⟩∞ᵒ-[∗ᵒ]⟨⟩ᵀᵒ⊤-⇒ᵀ○ (redᵀ-hd {es = es} (redᴱ {eˇ = eˇ} e⇒kr e'eˇH'⇐○))
    rewrite e⇒kr =  ∗ᵒ-assocˡ › ∗ᵒ-monoˡ (⊨✓⇒⊨-⇛ˢ λ ✓∙ → ∗ᵒ-monoʳ ⁺⟨⟩∞ᵒ-kr⁻¹ ›
    -∗ᵒ-applyˡ ∀ᵒ⇛ˢ-Mono ✓∙ › (_$ _) ›
    ⇛ˢ-mono (λ (-, big) → big _ _ _ _ e'eˇH'⇐○) › ⇛ˢ-join) › ⇛ˢ-eatʳ ›
    ⇛ˢ-mono $ ∗ᵒ-assocʳ › ∗ᵒ-monoʳ (∗ᵒ-assocʳ › go {eˇ' = eˇ}) › ∗ᵒ⇒∗ᵒ' ›
    λ{ (-, -, b∙c⊑a , [⊤]b , -, -, ι'∷ιs'≺ι∷ιs , big) →
    -, -, ι'∷ιs'≺ι∷ιs , ∗ᵒ'⇒∗ᵒ (-, -, b∙c⊑a , [⊤]b , big) }
   where
    go :  ⟨ e ⟩∞ᵒ˂ˡ ι ι₀ ∗ᵒ ⟨¿ eˇ' ⟩ᵀᵒ⊤˂ ι ∗ᵒ [∗ᵒ]⟨ es ⟩ᵀᵒ⊤ ιs ⊨
            ∃ᵒ ι'⁺ , ∃ᵒ ιs' , ⌜ ι'⁺ ∷ ιs' ≺ᴰᴹ⟨ _<ˢ_ ⟩ sz ι ∷ ιs ⌝ᵒ×
              ⟨ e ⟩∞ᵒ (sz⁻¹ ι'⁺) ι₀ ∗ᵒ [∗ᵒ]⟨ ¿⇒ᴸ eˇ' ⧺ es ⟩ᵀᵒ⊤ ιs'
    go {eˇ' = ň} =  Shrunkᵒ∗ᵒ-out › λ{ (§ big) → -, -,
      ≺ᴰᴹ-hd $ aug-∷ size< aug-refl ,
      big ▷ ∗ᵒ-monoʳ (∗ᵒ-elimʳ $ [∗ᵒ]⟨⟩ᵀᵒ⊤-Mono {es}) }
    go {eˇ' = š _} =  Shrunkᵒ∗ᵒ-out › λ{ (§ big) → big ▷ ?∗ᵒ-comm ▷
      Shrunkᵒ∗ᵒ-out ▷ λ{ (§ big) → -, -,
      ≺ᴰᴹ-hd $ aug-∷ size< $ aug-∷ size< aug-refl , big ▷ ?∗ᵒ-comm }}
  ⟨⟩∞ᵒ-[∗ᵒ]⟨⟩ᵀᵒ⊤-⇒ᵀ○ {ιs = []} (redᵀ-tl _) =  ∗ᵒ-assocˡ › ∗ᵒ⇒∗ᵒ' › λ ()
  ⟨⟩∞ᵒ-[∗ᵒ]⟨⟩ᵀᵒ⊤-⇒ᵀ○ {ιs = _ ∷ _} (redᵀ-tl esH⇒) =  ?∗ᵒ-comm ›
    ∗ᵒ-monoʳ (∗ᵒ-monoʳ (∗ᵒ-monoˡ ⁺⟨⟩ᵀᵒ⊤⇒⁺⟨⟩ᵀᵒ) › ⟨⟩ᵀᵒ-[∗ᵒ]⟨⟩ᵀᵒ⊤-⇒ᵀ (-, esH⇒)) ›
    ⇛ˢ-eatˡ › ⇛ˢ-mono $ ∗ᵒ⇒∗ᵒ' › λ (-, -, ∙⊑ , ⟨e⟩P , -, -, ι'∷ιs'≺ , big) →
    -, -, ≺ᴰᴹ-tl ι'∷ιs'≺ ,
    ∗ᵒ'⇒∗ᵒ (-, -, ∙⊑ , ⟨e⟩P , big ▷ ∗ᵒ-monoʳ (∗ᵒ-monoˡ ⁺⟨⟩ᵀᵒ⇒⁺⟨⟩ᵀᵒ⊤)) ▷ ?∗ᵒ-comm

  -- Lemma: If (e , es , H) ⇒ᵀ● (e' , es' , H'),
  -- then ⟨ e ⟩∞ᵒ ι ι₀ ∗ᵒ [∗ᵒ]⟨ es ⟩ᵀᵒ⊤ ιs entails
  -- ⟨ e' ⟩∞ᵒ ∞ - ∗ᵒ [∗ᵒ]⟨ es' ⟩ᵀᵒ⊤ ιs under ⟨ H ⟩⇛ˢ⟨ H' ⟩ with [⊤]ᴺᵒ and Thunkᵒ

  ⟨⟩∞ᵒ-[∗ᵒ]⟨⟩ᵀᵒ⊤-⇒ᵀ● :  (e , es , H) ⇒ᵀ● (e' , es' , H') →
    [⊤]ᴺᵒ ∗ᵒ ⟨ e ⟩∞ᵒ ι ι₀ ∗ᵒ [∗ᵒ]⟨ es ⟩ᵀᵒ⊤ ιs  ⊨ ⟨ H ⟩⇛ˢ⟨ H' ⟩
      Thunkᵒ (λ ι₀' → [⊤]ᴺᵒ ∗ᵒ ⟨ e' ⟩∞ᵒ ∞ ι₀' ∗ᵒ [∗ᵒ]⟨ es' ⟩ᵀᵒ⊤ ιs) ι₀
  ⟨⟩∞ᵒ-[∗ᵒ]⟨⟩ᵀᵒ⊤-⇒ᵀ● (redᵀ-hd (redᴱ e⇒kr (redᴷᴿ []⇒)))  rewrite e⇒kr =
    ∗ᵒ-assocˡ › ∗ᵒ-monoˡ (⊨✓⇒⊨-⇛ˢ λ ✓∙ → ∗ᵒ-monoʳ ⁺⟨⟩∞ᵒ-kr⁻¹ ›
    -∗ᵒ-applyˡ ∀ᵒ⇛ˢ-Mono ✓∙ › (_$ _) ›
    ⇛ˢ-mono (λ (-, big) → big _ _ _ _ (redᴷᴿ []⇒)) › ⇛ˢ-join) › ⇛ˢ-eatʳ ›
    ⇛ˢ-mono $ ∗ᵒ-assocʳ › λ big → λ{ .! → big ▷ ∗ᵒ-monoʳ
    (∗ᵒ-monoˡ $ ∗ᵒ-monoˡ (λ big → big .!) › ∗ᵒ-elimˡ ⁺⟨⟩∞ᵒ-Mono) }

  -- Infiniteness: ⊨ ⟨ e ⟩∞ᵒ ι ∞ ensures that any execution of (e , [] , H)
  -- triggers the event an infinite number of times for valid H

  ⟨⟩∞ᵒ⇒Inf :  ⊨ ⟨ e ⟩∞ᵒ ι ι' →  ✓ᴴ H →  Infᵀ ι' (e , [] , H)
  ⟨⟩∞ᵒ⇒Inf ⊨⟨e⟩∞ ✓H =  go {ιs = []} (≺ᴰᴹ-wf <ˢ-wf) (∅ᴵⁿᴳ-✓ᴺ ✓H) $
    ◎-just ▷ ∗ᵒ?-intro (∗ᵒ?-intro _ ⊨⟨e⟩∞) ▷ ∗ᵒ?-intro Invᴳ-∅
   where
    -- Well-founded induction on (ι' , sz ι ∷ ιs)
    go :  Acc (Rᴰᴹ _<ˢ_) (sz ι ∷ ιs) →  envᴳ H Eᴵⁿ ✓ᴳ a →
      (([⊤]ᴺᵒ ∗ᵒ ⟨ e ⟩∞ᵒ ι ι' ∗ᵒ [∗ᵒ]⟨ es ⟩ᵀᵒ⊤ ιs) ∗ᵒ Invᴳ Eᴵⁿ) a  →
      Infᵀ ι' (e , es , H)
    go (acc ≺ι∷ιs⇒acc) HE✓a big =  infᵀ λ{
      {b = ff} eesH⇒○ → big ▷ ∗ᵒ-monoˡ (⟨⟩∞ᵒ-[∗ᵒ]⟨⟩ᵀᵒ⊤-⇒ᵀ○ eesH⇒○) ▷
        ⇛ˢ-step HE✓a ▷ λ (-, -, H'E'✓b , big) → ∗ᵒ⇒∗ᵒ' big ▷
        λ (-, -, ∙⊑ , (-, -, ≺ι∷ιs , big) , InvE') →
        go (≺ι∷ιs⇒acc ≺ι∷ιs) H'E'✓b $ ∗ᵒ'⇒∗ᵒ (-, -, ∙⊑ , big , InvE');
      {b = tt} eesH⇒● .! → big ▷ ∗ᵒ-monoˡ (⟨⟩∞ᵒ-[∗ᵒ]⟨⟩ᵀᵒ⊤-⇒ᵀ● eesH⇒●) ▷
        ⇛ˢ-step HE✓a ▷ λ (-, -, H'E'✓b , big) →
        go (≺ᴰᴹ-wf <ˢ-wf) H'E'✓b $ big ▷ ∗ᵒ-monoˡ λ big → big .! }
