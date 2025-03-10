--------------------------------------------------------------------------------
-- Prove the semantic soundness and adequacy of the atomic, partial, total and
-- infinite Hoare triples
--------------------------------------------------------------------------------

{-# OPTIONS --without-K --sized-types #-}

module Syng.Model.Hor.Sound where

open import Base.Size using (𝕊; ∞; !)
open import Base.Func using (_$_; _▷_; _∘_; _›_)
open import Base.Few using (⊤; absurd)
open import Base.Eq using (_≡_)
open import Base.Prod using (∑-syntax; _×_; π₀; _,_; -,_; ∑-case)
open import Base.Sum using (ĩ₁_)
open import Base.Nat using (ℕ)
open import Base.List using (List; []; _∷_; rep; _∈ᴸ_)
open import Base.Sety using ()
open import Syng.Lang.Expr using (Addr; _ₒ_; Type; ◸_; Expr∞; Val; V⇒E; TyVal;
  Heap; ✓ᴴ_)
open import Syng.Lang.Ktxred using (Redex; Ktxred; Val/Ktxred; val/ktxred)
open import Syng.Lang.Reduce using (redᴾ; _⇒ᴷᴿ∑; _⇒ᵀ*_; SNᵀ; Infᵀ)
open import Syng.Logic.Prop using (SProp∞; ⊤'; ⌜_⌝; _↦_; [∗∈ⁱ⟨⟩]-syntax)
open import Syng.Logic.Core using (_»_; ∃-elim)
open import Syng.Logic.Hor using (_⊢[_][_]ᵃ⟨_⟩_; _⊢[_]⁺⟨_⟩ᴾ_; _⊢[_]⟨_⟩ᴾ_;
  _⊢[_]⁺⟨_⟩ᵀ[_]_; _⊢[_]⟨_⟩ᵀ[_]_; _⊢[_][_]⁺⟨_⟩∞; _⊢[_][_]⟨_⟩∞; hor-ᵀ⇒ᴾ;
  ihor⇒horᴾ; ahor-ṡ; horᵀ-ṡ; ihor-ṡ; _ᵘ»ᵃʰ_; _ᵘᴺ»ʰ_; _ᵘᴺ»ⁱʰ_; _ᵃʰ»ᵘ_; _ʰ»ᵘᴺ_;
  ahor-frameʳ; hor-frameʳ; ahorᴺ-hor; ahorᴺ-ihor; hor-bind; ihor-bind;
  hor-ihor-bind; hor-valᵘᴺ; ahor-nd; hor-[]; ihor-[]○; ihor-[]●; hor-fork;
  ihor-fork)
open import Syng.Logic.Heap using (ahor-🞰; ahor-←; ahor-fau; ahor-cas-tt;
  ahor-cas-ff; ahor-alloc; ahor-free)
open import Syng.Logic.Ind using (⊸ᵃ⟨⟩-use; ⊸⟨⟩ᴾ-use; ⊸⟨⟩ᵀ-use; ⊸⟨⟩∞-use)
open import Syng.Model.Prop.Base using (_⊨_; [∗ᵒ∈ⁱ⟨⟩]-syntax; ∗ᵒ-mono; ∗ᵒ-monoˡ;
  ∗ᵒ-monoʳ; ∗ᵒ∃ᵒ-out; -∗ᵒ-introˡ)
open import Syng.Model.Prop.Heap using (_↦ᵒ_)
open import Syng.Model.Prop.Interp using (⸨_⸩)
open import Syng.Model.Prop.Sound using (⊢-sem)
open import Syng.Model.Fupd.Ind using (⊸ᵃ⟨⟩ᵒ-use; ⊸⟨⟩ᵒ-use; ⊸⟨⟩∞ᵒ-use)
open import Syng.Model.Fupd.Interp using (⇛ᴵⁿᵈ⇒⇛ᵒ; ⇛ᵒ-mono; ⇛ᵒ-eatˡ; ⇛ᴺᵒ-mono)
open import Syng.Model.Fupd.Sound using (⊢⇛-sem; ⊢⇛ᴺ-sem)
open import Syng.Model.Hor.Wp using (ᵃ⟨_⟩ᵒ; ⁺⟨_⟩ᴾᵒ; ⁺⟨_⟩ᵀᵒ; ⁺⟨_⟩∞ᵒ; ⁺⟨⟩ᴾᵒ-val;
  ⁺⟨⟩ᵀᵒ-val; ⁺⟨⟩ᴾᵒ⇒⁺⟨⟩ᴾᵒ⊤; ⁺⟨⟩ᵀᵒ⇒⁺⟨⟩ᵀᵒ⊤; ᵃ⟨⟩ᵒ-mono; ⁺⟨⟩ᴾᵒ-mono; ⁺⟨⟩ᵀᵒ-mono;
  ⊨✓⇒⊨-ᵃ⟨⟩ᵒ; ⊨✓⇒⊨-⁺⟨⟩ᴾᵒ; ⊨✓⇒⊨-⁺⟨⟩ᵀᵒ; ⊨✓⇒⊨-⁺⟨⟩∞ᵒ; ⁺⟨⟩ᵀᵒ⇒⁺⟨⟩ᴾᵒ; ⁺⟨⟩∞ᵒ⇒⁺⟨⟩ᴾᵒ;
  ⇛ᵒ-ᵃ⟨⟩ᵒ; ⇛ᴺᵒ-⁺⟨⟩ᴾᵒ; ⇛ᵒ-⁺⟨⟩ᴾᵒ; ⇛ᴺᵒ-⁺⟨⟩ᵀᵒ; ⇛ᵒ-⁺⟨⟩ᵀᵒ; ⇛ᴺᵒ-⁺⟨⟩∞ᵒ; ⇛ᵒ-⁺⟨⟩∞ᵒ;
  ᵃ⟨⟩ᵒ-⇛ᵒ; ⁺⟨⟩ᴾᵒ-⇛ᴺᵒ; ⁺⟨⟩ᵀᵒ-⇛ᴺᵒ; ᵃ⟨⟩ᵒ-eatˡ; ⁺⟨⟩ᴾᵒ-eatˡ; ⁺⟨⟩ᵀᵒ-eatˡ)
open import Syng.Model.Hor.Lang using (ᵃ⟨⟩ᴺᵒ-⟨⟩ᴾᵒ; ᵃ⟨⟩ᴺᵒ-⟨⟩ᵀᵒ; ᵃ⟨⟩ᴺᵒ-⟨⟩∞ᵒ;
  ⟨⟩ᴾᵒ-bind; ⟨⟩ᵀᵒ-bind; ⟨⟩∞ᵒ-bind; ⟨⟩ᵀᵒ-⟨⟩∞ᵒ-bind; ᵃ⟨⟩ᵒ-nd; ⁺⟨⟩ᴾᵒ-[]; ⁺⟨⟩ᵀᵒ-[];
  ⁺⟨⟩∞ᵒ-[]○; ⁺⟨⟩∞ᵒ-[]●; ⁺⟨⟩ᴾᵒ-fork; ⁺⟨⟩ᵀᵒ-fork; ⁺⟨⟩∞ᵒ-fork)
open import Syng.Model.Hor.Heap using (ᵃ⟨⟩ᵒ-🞰; ᵃ⟨⟩ᵒ-←; ᵃ⟨⟩ᵒ-fau; ᵃ⟨⟩ᵒ-cas-tt;
  ᵃ⟨⟩ᵒ-cas-ff; ᵃ⟨⟩ᵒ-alloc; ᵃ⟨⟩ᵒ-free)
open import Syng.Model.Hor.Adeq using (⟨⟩ᴾᵒ-post; ⟨⟩ᴾᵒ-progress-main;
  ⟨⟩ᴾᵒ-progress-forked; ⟨⟩ᵀᵒ⇒SN; ⟨⟩∞ᵒ-progress-main; ⟨⟩∞ᵒ⇒Inf)

private variable
  ι :  𝕊
  X :  Set₀
  T :  Type
  P :  SProp∞
  P˙ Q˙ :  X →  SProp∞
  red :  Redex T
  vk :  Val/Ktxred T
  i k :  ℕ
  θ :  Addr
  ᵗvs :  List TyVal
  v :  X
  e e' e⁺ :  Expr∞ T
  es :  List (Expr∞ (◸ ⊤))
  kr :  Ktxred T
  H H' :  Heap
  X˙ :  X → Set₀

--------------------------------------------------------------------------------
-- Lemmas on ↦ᴸ

abstract

  -- ⸨ θ ↦ᴸ ᵗvs ⸩ agrees with θ ↦ᴸᵒ ᵗvs
  -- For induction we use the unfolded versions with ∈ⁱ⟨ k ⟩

  ↦ᴸ⇒↦ᴸᵒ :  ⸨ [∗ (i , ᵗv) ∈ⁱ⟨ k ⟩ ᵗvs ] θ ₒ i ↦ ᵗv ⸩  ⊨
            [∗ᵒ (i , ᵗv) ∈ⁱ⟨ k ⟩ ᵗvs ] θ ₒ i ↦ᵒ ᵗv
  ↦ᴸ⇒↦ᴸᵒ {ᵗvs = []} =  _
  ↦ᴸ⇒↦ᴸᵒ {ᵗvs = _ ∷ ᵗvs'} =  ∗ᵒ-monoʳ $ ↦ᴸ⇒↦ᴸᵒ {ᵗvs = ᵗvs'}

  ↦ᴸᵒ⇒↦ᴸ :  [∗ᵒ (i , ᵗv) ∈ⁱ⟨ k ⟩ ᵗvs ] θ ₒ i ↦ᵒ ᵗv  ⊨
            ⸨ [∗ (i , ᵗv) ∈ⁱ⟨ k ⟩ ᵗvs ] θ ₒ i ↦ ᵗv ⸩
  ↦ᴸᵒ⇒↦ᴸ {ᵗvs = []} _ =  absurd
  ↦ᴸᵒ⇒↦ᴸ {ᵗvs = _ ∷ ᵗvs'} =  ∗ᵒ-monoʳ $ ↦ᴸᵒ⇒↦ᴸ {ᵗvs = ᵗvs'}

--------------------------------------------------------------------------------
-- ⊢ᵃ⟨⟩-sem :  Semantic soundness of the atomic Hoare triple

abstract

  ⊢ᵃ⟨⟩-sem :  P  ⊢[ ∞ ][ i ]ᵃ⟨ red ⟩  Q˙  →   ⸨ P ⸩  ⊨ ᵃ⟨ red ⟩ᵒ λ v →  ⸨ Q˙ v ⸩

  -- _»_ :  P ⊢[ ∞ ] Q →  Q ⊢[ ∞ ][ i ]ᵃ⟨ red ⟩ R˙ →  P ⊢[ ∞ ][ i ]ᵃ⟨ red ⟩ R˙

  ⊢ᵃ⟨⟩-sem (P⊢Q » Q⊢⟨red⟩R) =  ⊨✓⇒⊨-ᵃ⟨⟩ᵒ λ ✓∙ → ⊢-sem P⊢Q ✓∙ › ⊢ᵃ⟨⟩-sem Q⊢⟨red⟩R

  -- ∃-elim :  (∀ x →  P˙ x ⊢[ ∞ ][ i ]ᵃ⟨ red ⟩ Q˙) →
  --           ∃˙ P˙ ⊢[ ∞ ][ i ]ᵃ⟨ red ⟩ Q˙

  ⊢ᵃ⟨⟩-sem (∃-elim Px⊢⟨vk⟩Q) =   ∑-case λ x → ⊢ᵃ⟨⟩-sem (Px⊢⟨vk⟩Q x)

  -- ahor-ṡ :  P  ⊢[< ∞ ][ i ]ᵃ⟨ red ⟩  Q˙  →   P  ⊢[ ∞ ][ ṡ i ]ᵃ⟨ red ⟩  Q˙

  ⊢ᵃ⟨⟩-sem (ahor-ṡ P⊢⟨red⟩Q) =  ⊢ᵃ⟨⟩-sem (P⊢⟨red⟩Q .!)

  -- _ᵘ»ᵃʰ_ :  P  ⊢[ ∞ ][ j ]⇛  Q  →   Q  ⊢[ ∞ ][ i ]ᵃ⟨ red ⟩  R˙  →
  --           P  ⊢[ ∞ ][ i ]ᵃ⟨ red ⟩  R˙

  ⊢ᵃ⟨⟩-sem (P⊢⇛Q ᵘ»ᵃʰ Q⊢⟨red⟩R) =  ⊢⇛-sem P⊢⇛Q ›
    ⇛ᵒ-mono (⊢ᵃ⟨⟩-sem Q⊢⟨red⟩R) › ⇛ᵒ-ᵃ⟨⟩ᵒ

  -- _ᵃʰ»ᵘ_ :  P  ⊢[ ∞ ][ i ]ᵃ⟨ red ⟩  Q˙  →
  --           (∀ v →  Q˙ v  ⊢[ ∞ ][ j ]⇛  R˙ v)  →
  --           P  ⊢[ ∞ ][ i ]ᵃ⟨ red ⟩  R˙

  ⊢ᵃ⟨⟩-sem (P⊢⟨red⟩Q ᵃʰ»ᵘ Qv⊢⇛Rv) =  ⊢ᵃ⟨⟩-sem P⊢⟨red⟩Q ›
    ᵃ⟨⟩ᵒ-mono (λ v Qva → ⊢⇛-sem (Qv⊢⇛Rv v) Qva) › ᵃ⟨⟩ᵒ-⇛ᵒ

  -- ahor-frameʳ :  P  ⊢[ ∞ ][ i ]ᵃ⟨ red ⟩  Q˙  →
  --                R  ∗  P  ⊢[ ∞ ][ i ]ᵃ⟨ red ⟩ λ v →  R  ∗  Q˙ v

  ⊢ᵃ⟨⟩-sem (ahor-frameʳ P⊢⟨red⟩Q) =  ∗ᵒ-monoʳ (⊢ᵃ⟨⟩-sem P⊢⟨red⟩Q) › ᵃ⟨⟩ᵒ-eatˡ

  -- ahor-nd :  {{ Inh ⸨ Xʸ ⸩ʸ }} →  P  ⊢[ ∞ ][ i ]ᵃ⟨ ndᴿ {Xʸ} ⟩ λ _ →  P

  ⊢ᵃ⟨⟩-sem ahor-nd =  ᵃ⟨⟩ᵒ-nd

  -- ahor-🞰 :  θ ↦⟨ p ⟩ (T , v)  ⊢[ ∞ ][ i ]ᵃ⟨ 🞰ᴿ_ {T} θ ⟩ λ u →
  --             ⌜ u ≡ v ⌝∧  θ ↦⟨ p ⟩ (T , v)

  ⊢ᵃ⟨⟩-sem ahor-🞰 =  ᵃ⟨⟩ᵒ-🞰

  -- ahor-← :  θ ↦ ᵗu  ⊢[ ∞ ][ i ]ᵃ⟨ _←ᴿ_ {T} θ v ⟩ λ _ →  θ ↦ (T , v)

  ⊢ᵃ⟨⟩-sem ahor-← =  ᵃ⟨⟩ᵒ-←

  -- ahor-fau :  θ ↦ (◸ʸ Xʸ , x)  ⊢[ ∞ ][ i ]ᵃ⟨ fauᴿ f θ ⟩ λ y →
  --               ⌜ y ≡ x ⌝∧  θ ↦ (-, f x)

  ⊢ᵃ⟨⟩-sem ahor-fau =  ᵃ⟨⟩ᵒ-fau

  -- ahor-cas-tt :  θ ↦ (◸ʸ Xʸ , x)  ⊢[ ∞ ][ i ]ᵃ⟨ casᴿ θ x y ⟩ λ b →
  --                  ⌜ b ≡ tt ⌝∧  θ ↦ (-, y)

  ⊢ᵃ⟨⟩-sem ahor-cas-tt =  ᵃ⟨⟩ᵒ-cas-tt

  -- ahor-cas-ff :  z ≢ x  →
  --   θ ↦⟨ p ⟩ (◸ʸ Xʸ , z)  ⊢[ ∞ ][ i ]ᵃ⟨ casᴿ θ x y ⟩ λ b →
  --     ⌜ b ≡ ff ⌝∧  θ ↦⟨ p ⟩ (-, z)

  ⊢ᵃ⟨⟩-sem (ahor-cas-ff z≢x) =  ᵃ⟨⟩ᵒ-cas-ff z≢x

  -- ahor-alloc :  ⊤'  ⊢[ ∞ ][ i ]ᵃ⟨ allocᴿ n ⟩ λ θ →
  --                 θ ↦ᴸ rep n ⊤-  ∗  Free n θ

  ⊢ᵃ⟨⟩-sem (ahor-alloc {n = n}) _ =  ᵃ⟨⟩ᵒ-alloc ▷
    ᵃ⟨⟩ᵒ-mono λ _ → ∗ᵒ-monoˡ $ ↦ᴸᵒ⇒↦ᴸ {ᵗvs = rep n _}

  -- ahor-free :  len ᵗvs ≡ n  →
  --   θ ↦ᴸ ᵗvs  ∗  Free n θ  ⊢[ ∞ ][ i ]ᵃ⟨ freeᴿ θ ⟩ λ _ →  ⊤'

  ⊢ᵃ⟨⟩-sem (ahor-free {ᵗvs} lenvs≡n) =  ∗ᵒ-monoˡ (↦ᴸ⇒↦ᴸᵒ {ᵗvs = ᵗvs}) ›
    ᵃ⟨⟩ᵒ-free lenvs≡n › ᵃ⟨⟩ᵒ-mono λ _ _ → absurd

  -- ⊸ᵃ⟨⟩-use :  P˂ .!  ∗  (P˂ ⊸[ i ]ᵃ⟨ red ⟩ Q˂˙)
  --               ⊢[ ∞ ][ ṡ i ]ᵃ⟨ red ⟩ λ v →  Q˂˙ v .!
  -- The level increment ṡ i makes the recursive call of ⊢ᵃ⟨⟩-sem inductive

  ⊢ᵃ⟨⟩-sem ⊸ᵃ⟨⟩-use =  ∗ᵒ-monoʳ (⊸ᵃ⟨⟩ᵒ-use › ⇛ᴵⁿᵈ⇒⇛ᵒ) › ⇛ᵒ-eatˡ ›
    ⇛ᵒ-mono (∗ᵒ∃ᵒ-out › λ (-, big) → ∗ᵒ∃ᵒ-out big ▷
    λ (P∗R⊢⟨red⟩Q , P∗Ra) → ⊢ᵃ⟨⟩-sem P∗R⊢⟨red⟩Q P∗Ra) › ⇛ᵒ-ᵃ⟨⟩ᵒ

--------------------------------------------------------------------------------
-- ⊢⁺⟨⟩ᵀ-sem :  Semantic soundness of the total Hoare triple

abstract

  ⊢⁺⟨⟩ᵀ-sem :  P  ⊢[ ∞ ]⁺⟨ vk ⟩ᵀ[ i ]  Q˙  →
               ⸨ P ⸩  ⊨ ⁺⟨ vk ⟩ᵀᵒ ∞ λ v →  ⸨ Q˙ v ⸩

  -- _»_ :  P ⊢[ ∞ ] Q →  Q ⊢[ ∞ ]⁺⟨ vk ⟩ᵀ[ i ] R˙ →  P ⊢[ ∞ ]⁺⟨ vk ⟩ᵀ[ i ] R˙

  ⊢⁺⟨⟩ᵀ-sem (P⊢Q » Q⊢⟨vk⟩R) =
    ⊨✓⇒⊨-⁺⟨⟩ᵀᵒ λ ✓∙ → ⊢-sem P⊢Q ✓∙ › ⊢⁺⟨⟩ᵀ-sem Q⊢⟨vk⟩R

  -- ∃-elim :  (∀ x →  P˙ x ⊢[ ∞ ]⟨ vk ⟩ᵀ[ i ] Q˙) →
  --           ∃˙ P˙ ⊢[ ∞ ]⁺⟨ vk ⟩ᵀ[ i ] Q˙

  ⊢⁺⟨⟩ᵀ-sem (∃-elim Px⊢⟨vk⟩Q) =   ∑-case λ x → ⊢⁺⟨⟩ᵀ-sem (Px⊢⟨vk⟩Q x)

  -- horᵀ-ṡ :  P  ⊢[< ∞ ]⁺⟨ vk ⟩ᵀ[ i ]  Q˙  →   P  ⊢[ ∞ ]⁺⟨ vk ⟩ᵀ[ ṡ i ]  Q˙

  ⊢⁺⟨⟩ᵀ-sem (horᵀ-ṡ P⊢⟨vk⟩Q) =  ⊢⁺⟨⟩ᵀ-sem (P⊢⟨vk⟩Q .!)

  -- _ᵘᴺ»ʰ_ :  P  ⊢[ ∞ ][ i ]⇛ᴺ  Q  →   Q  ⊢[ ∞ ]⁺⟨ vk ⟩ᵀ[ i ]  R˙  →
  --           P  ⊢[ ∞ ]⁺⟨ vk ⟩[ κ ]  R˙

  ⊢⁺⟨⟩ᵀ-sem (P⊢⇛Q ᵘᴺ»ʰ Q⊢⟨vk⟩R) =
    ⊢⇛ᴺ-sem P⊢⇛Q › ⇛ᴺᵒ-mono (⊢⁺⟨⟩ᵀ-sem Q⊢⟨vk⟩R) › ⇛ᴺᵒ-⁺⟨⟩ᵀᵒ

  -- _ʰ»ᵘᴺ_ :  P  ⊢[ ∞ ]⁺⟨ vk ⟩ᵀ[ i ]  Q˙  →
  --           (∀ v →  Q˙ v  ⊢[ ∞ ][ j ]⇛ᴺ  R˙ v)  →
  --           P  ⊢[ ∞ ]⁺⟨ vk ⟩ᵀ[ i ]  R˙

  ⊢⁺⟨⟩ᵀ-sem (P⊢⟨vk⟩Q ʰ»ᵘᴺ Qv⊢⇛Rv) =
    ⊢⁺⟨⟩ᵀ-sem P⊢⟨vk⟩Q › ⁺⟨⟩ᵀᵒ-mono (λ v → ⊢⇛ᴺ-sem (Qv⊢⇛Rv v)) › ⁺⟨⟩ᵀᵒ-⇛ᴺᵒ

  -- hor-frameʳ :  P  ⊢[ ∞ ]⁺⟨ vk ⟩ᵀ[ i ]  Q˙  →
  --               R  ∗  P  ⊢[ ∞ ]⁺⟨ vk ⟩ᵀ[ i ] λ v →  R  ∗  Q˙ v

  ⊢⁺⟨⟩ᵀ-sem (hor-frameʳ P⊢⟨vk⟩Q) =  ∗ᵒ-monoʳ (⊢⁺⟨⟩ᵀ-sem P⊢⟨vk⟩Q) › ⁺⟨⟩ᵀᵒ-eatˡ

  -- hor-valᵘᴺ :  P  ⊢[ ∞ ][ i ]⇛ᴺ  Q˙ v  →   P  ⊢[ ∞ ]⁺⟨ T / ĩ₀ v ⟩ᵀ[ i ]  Q˙

  ⊢⁺⟨⟩ᵀ-sem (hor-valᵘᴺ P⊢⇛Qv) =  ⊢⇛ᴺ-sem P⊢⇛Qv › ⁺⟨⟩ᵀᵒ-val

  -- ahorᴺ-hor :  [⊤]ᴺ ∗ P  ⊢[ ∞ ][ i ]ᵃ⟨ red ⟩ (λ v →  [⊤]ᴺ ∗ Q˙ v)  →
  --              (∀ v →  Q˙ v  ⊢[ ∞ ]⟨ K ᴷ◁ V⇒E v ⟩ᵀ[ j ]  R˙)  →
  --              P  ⊢[ ∞ ]⁺⟨ ĩ₁ (-, K , red) ⟩ᵀ[ j ]  R˙

  ⊢⁺⟨⟩ᵀ-sem (ahorᴺ-hor P⊢⟨red⟩ᴺQ Qv⊢⟨Kv⟩R) =  -∗ᵒ-introˡ (λ _ →
    ⊢ᵃ⟨⟩-sem P⊢⟨red⟩ᴺQ › ᵃ⟨⟩ᵒ-mono λ v → ∗ᵒ-monoʳ $ ⊢⁺⟨⟩ᵀ-sem (Qv⊢⟨Kv⟩R v)) ›
    ᵃ⟨⟩ᴺᵒ-⟨⟩ᵀᵒ

  -- hor-bind :  P  ⊢[ ∞ ]⟨ e ⟩ᵀ[ i ]  Q˙  →
  --             (∀ v →  Q˙ v  ⊢[ ∞ ]⟨ K ᴷ◁ V⇒E v ⟩ᵀ[ i ]  R˙)  →
  --             P  ⊢[ ∞ ]⟨ K ᴷ◁ e ⟩ᵀ[ i ]  R˙

  ⊢⁺⟨⟩ᵀ-sem (hor-bind P⊢⟨e⟩Q Qv⊢⟨Kv⟩R) =  ⊢⁺⟨⟩ᵀ-sem P⊢⟨e⟩Q ›
    ⁺⟨⟩ᵀᵒ-mono (λ v → ⊢⁺⟨⟩ᵀ-sem (Qv⊢⟨Kv⟩R v)) › ⟨⟩ᵀᵒ-bind

  -- hor-[] :  P  ⊢[ ∞ ]⟨ K ᴷ◁ e ⟩[ κ ]  Q˙  →
  --           P  ⊢[ ∞ ]⁺⟨ ĩ₁ (-, K , [ e ]ᴿ⟨ b ⟩) ⟩[ κ ]  Q˙

  ⊢⁺⟨⟩ᵀ-sem (hor-[] P⊢⟨Ke⟩Q) =  ⊢⁺⟨⟩ᵀ-sem P⊢⟨Ke⟩Q › ⁺⟨⟩ᵀᵒ-[]

  -- hor-fork :  P  ⊢[ ∞ ]⟨ e ⟩ᵀ[ i ] (λ _ →  ⊤')  →
  --             Q  ⊢[ ∞ ]⟨ K ᴷ◁ ∇ _ ⟩ᵀ[ i ]  R˙  →
  --             P  ∗  Q  ⊢[ ∞ ]⁺⟨ ĩ₁ (-, K , forkᴿ e) ⟩ᵀ[ i ]  R˙

  ⊢⁺⟨⟩ᵀ-sem (hor-fork P⊢⟨e⟩ Q⊢⟨K⟩R) =
    ∗ᵒ-mono (⊢⁺⟨⟩ᵀ-sem P⊢⟨e⟩ › ⁺⟨⟩ᵀᵒ⇒⁺⟨⟩ᵀᵒ⊤) (⊢⁺⟨⟩ᵀ-sem Q⊢⟨K⟩R) › ⁺⟨⟩ᵀᵒ-fork

  -- ⊸⟨⟩ᵀ-use :  P˂ .! ∗ (P˂ ⊸⟨ e ⟩ᵀ[ i ] Q˂˙)
  --               ⊢[ ∞ ]⟨ e ⟩ᵀ[ ṡ i ] λ v →  Q˂˙ v .!
  -- The level increment ṡ i makes the recursive call of ⊢⁺⟨⟩ᵀ-sem inductive

  ⊢⁺⟨⟩ᵀ-sem ⊸⟨⟩ᵀ-use =  ∗ᵒ-monoʳ (⊸⟨⟩ᵒ-use › ⇛ᴵⁿᵈ⇒⇛ᵒ) › ⇛ᵒ-eatˡ ›
    (⇛ᵒ-mono $ ∗ᵒ∃ᵒ-out › λ (-, big) → ∗ᵒ∃ᵒ-out big ▷
    λ (P∗R⊢⟨e⟩Q , P∗Ra) → ⊢⁺⟨⟩ᵀ-sem P∗R⊢⟨e⟩Q P∗Ra) › ⇛ᵒ-⁺⟨⟩ᵀᵒ

--------------------------------------------------------------------------------
-- ⊢⁺⟨⟩∞-sem :  Semantic soundness of the infinite Hoare triple

abstract

  ⊢⁺⟨⟩∞-sem :  P  ⊢[ ∞ ][ i ]⁺⟨ vk ⟩∞  →   ⸨ P ⸩  ⊨ ⁺⟨ vk ⟩∞ᵒ ∞ ι

  -- The metric of termination is the triple of the level i, the size ι, and the
  -- structure of the proof ⊢[ ][ ]⁺⟨ ⟩∞
  -- For the rule ihor-[]●, the proof structure does not decrease but the size ι
  -- does, which is the key trick (see also ⊢⁺⟨⟩ᴾ-sem)

  -- _»_ :  P ⊢[ ∞ ] Q →  Q ⊢[ ∞ ]⁺⟨ vk ⟩∞ →  P ⊢[ ∞ ][ i ]⁺⟨ vk ⟩∞

  ⊢⁺⟨⟩∞-sem (P⊢Q » Q⊢⟨vk⟩∞) =
    ⊨✓⇒⊨-⁺⟨⟩∞ᵒ λ ✓∙ → ⊢-sem P⊢Q ✓∙ › ⊢⁺⟨⟩∞-sem Q⊢⟨vk⟩∞

  -- ∃-elim :  (∀ x →  P˙ x ⊢[ ∞ ][ i ]⁺⟨ vk ⟩∞) →  ∃˙ P˙ ⊢[ ∞ ][ i ]⁺⟨ vk ⟩∞

  ⊢⁺⟨⟩∞-sem (∃-elim Px⊢⟨vk⟩∞) =   ∑-case λ x → ⊢⁺⟨⟩∞-sem (Px⊢⟨vk⟩∞ x)

  -- ihor-ṡ :  P  ⊢[< ∞ ][ i ]⁺⟨ vk ⟩∞  →   P  ⊢[ ∞ ][ ṡ i ]⁺⟨ vk ⟩∞

  ⊢⁺⟨⟩∞-sem (ihor-ṡ P⊢⟨vk⟩∞) =  ⊢⁺⟨⟩∞-sem (P⊢⟨vk⟩∞ .!)

  -- _ᵘᴺ»ⁱʰ_ :  P  ⊢[ ∞ ][ i ]⇛ᴺ  Q  →   Q  ⊢[ ∞ ][ j ]⁺⟨ vk ⟩∞  →
  --            P  ⊢[ ∞ ][ j ]⁺⟨ vk ⟩∞

  ⊢⁺⟨⟩∞-sem (P⊢⇛Q ᵘᴺ»ⁱʰ Q⊢⟨vk⟩∞) =
    ⊢⇛ᴺ-sem P⊢⇛Q › ⇛ᴺᵒ-mono (⊢⁺⟨⟩∞-sem Q⊢⟨vk⟩∞) › ⇛ᴺᵒ-⁺⟨⟩∞ᵒ

  -- ahorᴺ-ihor :  [⊤]ᴺ ∗ P  ⊢[ ∞ ][ i ]ᵃ⟨ red ⟩ (λ v →  [⊤]ᴺ ∗ Q˙ v)  →
  --               (∀ v →  Q˙ v  ⊢[ ∞ ][ j ]⟨ K ᴷ◁ V⇒E v ⟩∞)  →
  --               P  ⊢[ ∞ ][ j ]⁺⟨ ĩ₁ (-, K , red) ⟩∞

  ⊢⁺⟨⟩∞-sem (ahorᴺ-ihor P⊢⟨red⟩ᴺQ Qv⊢⟨Kv⟩∞) =  -∗ᵒ-introˡ (λ _ →
    ⊢ᵃ⟨⟩-sem P⊢⟨red⟩ᴺQ › ᵃ⟨⟩ᵒ-mono λ v → ∗ᵒ-monoʳ $ ⊢⁺⟨⟩∞-sem (Qv⊢⟨Kv⟩∞ v)) ›
    ᵃ⟨⟩ᴺᵒ-⟨⟩∞ᵒ

  -- ihor-bind :  P  ⊢[ ∞ ][ i ]⟨ e ⟩∞  →   P  ⊢[ ∞ ][ i ]⟨ K ᴷ◁ e ⟩∞

  ⊢⁺⟨⟩∞-sem (ihor-bind P⊢⟨e⟩∞) =  ⊢⁺⟨⟩∞-sem P⊢⟨e⟩∞ › ⟨⟩∞ᵒ-bind

  -- hor-ihor-bind :  P  ⊢[ ∞ ]⟨ e ⟩ᵀ[ i ] Q˙  →
  --                  (∀ v →  Q˙ v  ⊢[ ∞ ][ j ]⟨ K ᴷ◁ V⇒E v ⟩∞)  →
  --                  P  ⊢[ ∞ ][ j ]⟨ K ᴷ◁ e ⟩∞

  ⊢⁺⟨⟩∞-sem (hor-ihor-bind P⊢⟨e⟩Q Qv⊢⟨Kv⟩∞) =  ⊢⁺⟨⟩ᵀ-sem P⊢⟨e⟩Q ›
    ⁺⟨⟩ᵀᵒ-mono (λ v → ⊢⁺⟨⟩∞-sem (Qv⊢⟨Kv⟩∞ v)) › ⟨⟩ᵀᵒ-⟨⟩∞ᵒ-bind

  -- ihor-[]○ :  P  ⊢[ ∞ ][ i ]⟨ K ᴷ◁ e ⟩∞  →
  --             P  ⊢[ ∞ ][ i ]⁺⟨ ĩ₁ (-, K , [ e ]ᴿ○) ⟩∞

  ⊢⁺⟨⟩∞-sem (ihor-[]○ P⊢⟨Ke⟩∞) =  ⊢⁺⟨⟩∞-sem P⊢⟨Ke⟩∞ › ⁺⟨⟩∞ᵒ-[]○

  -- ihor-[]● :  P  ⊢[< ∞ ][ i ]⟨ K ᴷ◁ e ⟩∞  →
  --             P  ⊢[ ∞ ][ i ]⁺⟨ ĩ₁ (-, K , [ e ]ᴿ●) ⟩∞

  ⊢⁺⟨⟩∞-sem (ihor-[]● P⊢⟨Ke⟩∞) Pa =
    ⁺⟨⟩∞ᵒ-[]● λ{ .! → ⊢⁺⟨⟩∞-sem (P⊢⟨Ke⟩∞ .!) Pa }

  -- ihor-fork :  P  ⊢[ ∞ ]⟨ e ⟩ᵀ[ j ] (λ _ →  ⊤')  →
  --              Q  ⊢[ ∞ ][ i ]⟨ K ᴷ◁ ∇ _ ⟩∞  →
  --              P  ∗  Q  ⊢[ ∞ ][ i ]⁺⟨ ĩ₁ (-, K , forkᴿ e) ⟩∞

  ⊢⁺⟨⟩∞-sem (ihor-fork P⊢⟨e⟩ Q⊢⟨K⟩∞) =
    ∗ᵒ-mono (⊢⁺⟨⟩ᵀ-sem P⊢⟨e⟩ › ⁺⟨⟩ᵀᵒ⇒⁺⟨⟩ᵀᵒ⊤) (⊢⁺⟨⟩∞-sem Q⊢⟨K⟩∞) › ⁺⟨⟩∞ᵒ-fork

  -- ⊸⟨⟩∞-use :  P˂ .!  ∗  (P˂ ⊸[ i ]⟨ e ⟩∞)  ⊢[ ∞ ][ ṡ i ]⟨ e ⟩∞
  -- The level increment ṡ i makes the recursive call of ⊢⁺⟨⟩∞-sem inductive
  -- (just like ⊸⟨⟩ᵀ-use)

  ⊢⁺⟨⟩∞-sem ⊸⟨⟩∞-use =  ∗ᵒ-monoʳ (⊸⟨⟩∞ᵒ-use › ⇛ᴵⁿᵈ⇒⇛ᵒ) › ⇛ᵒ-eatˡ ›
    (⇛ᵒ-mono $ ∗ᵒ∃ᵒ-out › λ (-, big) → ∗ᵒ∃ᵒ-out big ▷
    λ (P∗R⊢⟨e⟩Q , P∗Ra) → ⊢⁺⟨⟩∞-sem P∗R⊢⟨e⟩Q P∗Ra) › ⇛ᵒ-⁺⟨⟩∞ᵒ

--------------------------------------------------------------------------------
-- ⊢⁺⟨⟩ᴾ-sem :  Semantic soundness of the partial Hoare triple

abstract

  ⊢⁺⟨⟩ᴾ-sem : P  ⊢[ ∞ ]⁺⟨ vk ⟩ᴾ  Q˙  →   ⸨ P ⸩  ⊨ ⁺⟨ vk ⟩ᴾᵒ ι λ v →  ⸨ Q˙ v ⸩

  -- The metric of termination is the pair of the size ι and the structure of
  -- the proof ⊢[ ]⁺⟨ ⟩ᴾ
  -- For rules like ⊸⟨⟩ᴾ-use and horᴾ-[], the proof structure does not decrease
  -- but the size ι does, which is the key trick

  -- _»_ :  P ⊢[ ∞ ] Q →  Q ⊢[ ∞ ]⁺⟨ vk ⟩ᴾ R˙ →  P ⊢[ ∞ ]⁺⟨ vk ⟩ᴾ R˙

  ⊢⁺⟨⟩ᴾ-sem (P⊢Q » Q⊢⟨vk⟩R) =
    ⊨✓⇒⊨-⁺⟨⟩ᴾᵒ λ ✓∙ → ⊢-sem P⊢Q ✓∙ › ⊢⁺⟨⟩ᴾ-sem Q⊢⟨vk⟩R

  -- ∃-elim :  (∀ x →  P˙ x ⊢[ ∞ ]⁺⟨ vk ⟩ᴾ Q˙) →  ∃˙ P˙ ⊢[ ∞ ]⁺⟨ vk ⟩ᴾ Q˙

  ⊢⁺⟨⟩ᴾ-sem (∃-elim Px⊢⟨vk⟩Q) =   ∑-case λ x → ⊢⁺⟨⟩ᴾ-sem (Px⊢⟨vk⟩Q x)

  -- _ᵘᴺ»ʰ_ :  P  ⊢[ ∞ ][ i ]⇛ᴺ  Q  →   Q  ⊢[ ∞ ]⁺⟨ vk ⟩ᴾ  R˙  →
  --           P  ⊢[ ∞ ]⁺⟨ vk ⟩ᴾ  R˙

  ⊢⁺⟨⟩ᴾ-sem (P⊢⇛Q ᵘᴺ»ʰ Q⊢⟨vk⟩R) =
    ⊢⇛ᴺ-sem P⊢⇛Q › ⇛ᴺᵒ-mono (⊢⁺⟨⟩ᴾ-sem Q⊢⟨vk⟩R) › ⇛ᴺᵒ-⁺⟨⟩ᴾᵒ

  -- _ʰ»ᵘᴺ_ :  P  ⊢[ ∞ ]⁺⟨ vk ⟩ᴾ  Q˙  →   (∀ v →  Q˙ v  ⊢[ ∞ ][ j ]⇛ᴺ  R˙ v)  →
  --           P  ⊢[ ∞ ]⁺⟨ vk ⟩ᴾ  R˙

  ⊢⁺⟨⟩ᴾ-sem (P⊢⟨vk⟩Q ʰ»ᵘᴺ Qv⊢⇛Rv) =
    ⊢⁺⟨⟩ᴾ-sem P⊢⟨vk⟩Q › ⁺⟨⟩ᴾᵒ-mono (λ v → ⊢⇛ᴺ-sem (Qv⊢⇛Rv v)) › ⁺⟨⟩ᴾᵒ-⇛ᴺᵒ

  -- hor-ᵀ⇒ᴾ :  P  ⊢[ ∞ ]⁺⟨ vk ⟩ᵀ  Q˙  →   P  ⊢[ ∞ ]⁺⟨ vk ⟩ᴾ  Q˙

  ⊢⁺⟨⟩ᴾ-sem (hor-ᵀ⇒ᴾ P⊢⟨vk⟩Q) =  ⊢⁺⟨⟩ᵀ-sem P⊢⟨vk⟩Q › ⁺⟨⟩ᵀᵒ⇒⁺⟨⟩ᴾᵒ

  -- ihor⇒horᴾ :  P  ⊢[ ∞ ][ i ]⁺⟨ vk ⟩∞  →   P  ⊢[ ∞ ]⁺⟨ vk ⟩ᴾ  Q˙

  ⊢⁺⟨⟩ᴾ-sem (ihor⇒horᴾ P⊢⟨vk⟩∞) =  ⊢⁺⟨⟩∞-sem P⊢⟨vk⟩∞ › ⁺⟨⟩∞ᵒ⇒⁺⟨⟩ᴾᵒ

  -- hor-frameʳ :  P  ⊢[ ∞ ]⁺⟨ vk ⟩ᴾ  Q˙  →
  --               R  ∗  P  ⊢[ ∞ ]⁺⟨ vk ⟩ᴾ λ v →  R  ∗  Q˙ v

  ⊢⁺⟨⟩ᴾ-sem (hor-frameʳ P⊢⟨vk⟩Q) =  ∗ᵒ-monoʳ (⊢⁺⟨⟩ᴾ-sem P⊢⟨vk⟩Q) › ⁺⟨⟩ᴾᵒ-eatˡ

  -- hor-valᵘᴺ :  P  ⊢[ ∞ ][ i ]⇛ᴺ  Q˙ v  →   P  ⊢[ ∞ ]⁺⟨ T / ĩ₀ v ⟩ᴾ  Q˙

  ⊢⁺⟨⟩ᴾ-sem (hor-valᵘᴺ P⊢⇛Qv) =  ⊢⇛ᴺ-sem P⊢⇛Qv › ⁺⟨⟩ᴾᵒ-val

  -- ahorᴺ-hor :  [⊤]ᴺ ∗ P  ⊢[ ∞ ][ i ]ᵃ⟨ red ⟩ (λ v →  [⊤]ᴺ ∗  v)  →
  --              (∀ v →  Q˙ v  ⊢[< ∞ ]⟨ K ᴷ◁ V⇒E v ⟩ᴾ  R˙)  →
  --              P  ⊢[ ∞ ]⁺⟨ ĩ₁ (-, K , red) ⟩ᴾ  R˙

  ⊢⁺⟨⟩ᴾ-sem (ahorᴺ-hor P⊢⟨red⟩ᴺQ Qv⊢⟨Kv⟩R) =  -∗ᵒ-introˡ (λ _ →
    ⊢ᵃ⟨⟩-sem P⊢⟨red⟩ᴺQ › ᵃ⟨⟩ᵒ-mono λ v → ∗ᵒ-monoʳ λ big →
    λ{ .! → big ▷ ⊢⁺⟨⟩ᴾ-sem (Qv⊢⟨Kv⟩R v .!) }) › ᵃ⟨⟩ᴺᵒ-⟨⟩ᴾᵒ

  -- hor-bind :  P  ⊢[ ∞ ]⟨ e ⟩ᴾ  Q˙  →
  --             (∀ v →  Q˙ v  ⊢[ ∞ ]⟨ K ᴷ◁ V⇒E v ⟩ᴾ  R˙)  →
  --             P  ⊢[ ∞ ]⟨ K ᴷ◁ e ⟩ᴾ  R˙

  ⊢⁺⟨⟩ᴾ-sem (hor-bind P⊢⟨e⟩Q Qv⊢⟨Kv⟩R) =  ⊢⁺⟨⟩ᴾ-sem P⊢⟨e⟩Q ›
    ⁺⟨⟩ᴾᵒ-mono (λ v → ⊢⁺⟨⟩ᴾ-sem (Qv⊢⟨Kv⟩R v)) › ⟨⟩ᴾᵒ-bind

  -- hor-[] :  P  ⊢[< ∞ ]⟨ K ᴷ◁ e ⟩ᴾ  Q˙  →
  --           P  ⊢[ ∞ ]⁺⟨ ĩ₁ (-, K , [ e ]ᴿ⟨ b ⟩) ⟩ᴾ  Q˙

  ⊢⁺⟨⟩ᴾ-sem (hor-[] P⊢⟨Ke⟩Q) Pa =  ⁺⟨⟩ᴾᵒ-[] λ{ .! → ⊢⁺⟨⟩ᴾ-sem (P⊢⟨Ke⟩Q .!) Pa }

  -- hor-fork :  P  ⊢[< ∞ ]⟨ e ⟩ᴾ (λ _ →  ⊤')  →
  --             Q  ⊢[< ∞ ]⟨ K ᴷ◁ ∇ _ ⟩ᴾ  R˙  →
  --             P  ∗  Q  ⊢[ ∞ ]⁺⟨ ĩ₁ (-, K , forkᴿ e) ⟩ᴾ  R˙

  ⊢⁺⟨⟩ᴾ-sem (hor-fork P⊢⟨e⟩ Q⊢⟨K⟩R) =  ∗ᵒ-mono
    (λ Pb → λ{ .! → Pb ▷ ⊢⁺⟨⟩ᴾ-sem (P⊢⟨e⟩ .!) ▷ ⁺⟨⟩ᴾᵒ⇒⁺⟨⟩ᴾᵒ⊤ })
    (λ Qc → λ{ .! → Qc ▷ ⊢⁺⟨⟩ᴾ-sem (Q⊢⟨K⟩R .!) }) › ⁺⟨⟩ᴾᵒ-fork

  -- ⊸⟨⟩ᴾ-use :  e ⇒ᴾ e'  →
  --   P˂ .!  ∗  (P˂ ⊸⟨ e' ⟩ᴾ Q˂˙)  ⊢[ ∞ ]⟨ e ⟩ᴾ λ v →  Q˂˙ v .!

  ⊢⁺⟨⟩ᴾ-sem (⊸⟨⟩ᴾ-use (-, redᴾ e⇒K[e₀])) big  rewrite e⇒K[e₀] =
    ⁺⟨⟩ᴾᵒ-[] λ{ .! → big ▷ ∗ᵒ-monoʳ (⊸⟨⟩ᵒ-use › ⇛ᴵⁿᵈ⇒⇛ᵒ) ▷ ⇛ᵒ-eatˡ ▷
    (⇛ᵒ-mono $ ∗ᵒ∃ᵒ-out › λ (-, big) → ∗ᵒ∃ᵒ-out big ▷
    λ (P∗R⊢⟨e⟩Q , P∗Ra) → ⊢⁺⟨⟩ᴾ-sem P∗R⊢⟨e⟩Q P∗Ra) ▷ ⇛ᵒ-⁺⟨⟩ᴾᵒ }

--------------------------------------------------------------------------------
-- Adequacy theorems for the partial Hoare triple

abstract

  -- Postcondition: ⊤' ⊢[ ∞ ]⟨ e ⟩ᵀ[ i ] λ u → ⌜ X˙ u ⌝ ensures that the X˙ v
  -- holds for the result value v of any execution of (e , [] , H) for valid H

  ⟨⟩ᴾ-post :  ⊤' ⊢[ ∞ ]⟨ e ⟩ᴾ (λ u → ⌜ X˙ u ⌝) →  ✓ᴴ H →
              (e , [] , H) ⇒ᵀ* (V⇒E {T} v , es , H') →  X˙ v
  ⟨⟩ᴾ-post ⊢⟨e⟩Xu =  ⟨⟩ᴾᵒ-post $ ⁺⟨⟩ᴾᵒ-mono (λ _ → π₀) $ ⊢⁺⟨⟩ᴾ-sem ⊢⟨e⟩Xu absurd

  -- Progress: If ⟨ e ⟩ᴾᵒ ∞ Pᵒ˙ is a tautology, then any reduction sequence
  -- starting with (e , [] , H) never gets stuck for valid H

  ⟨⟩ᴾ-progress-main :  ⊤' ⊢[ ∞ ]⟨ e ⟩ᴾ P˙ →  ✓ᴴ H →
    (e , [] , H) ⇒ᵀ* (e' , es , H') →  val/ktxred e' ≡ ĩ₁ kr →  (kr , H') ⇒ᴷᴿ∑
  ⟨⟩ᴾ-progress-main ⊢⟨e⟩P =  ⟨⟩ᴾᵒ-progress-main $ ⊢⁺⟨⟩ᴾ-sem ⊢⟨e⟩P absurd

  ⟨⟩ᴾ-progress-forked :
    ⊤' ⊢[ ∞ ]⟨ e ⟩ᴾ P˙ →  ✓ᴴ H →  (e , [] , H) ⇒ᵀ* (e' , es , H') →  e⁺ ∈ᴸ es →
    val/ktxred e⁺ ≡ ĩ₁ kr →  (kr , H') ⇒ᴷᴿ∑
  ⟨⟩ᴾ-progress-forked ⊢⟨e⟩P =  ⟨⟩ᴾᵒ-progress-forked $ ⊢⁺⟨⟩ᴾ-sem ⊢⟨e⟩P absurd

--------------------------------------------------------------------------------
-- Adequacy theorems for the total Hoare triple

abstract

  -- Postcondition

  ⟨⟩ᵀ-post :  ⊤' ⊢[ ∞ ]⟨ e ⟩ᵀ[ i ] (λ u → ⌜ X˙ u ⌝) →  ✓ᴴ H →
              (e , [] , H) ⇒ᵀ* (V⇒E {T} v , es , H') →  X˙ v
  ⟨⟩ᵀ-post =  ⟨⟩ᴾ-post ∘ hor-ᵀ⇒ᴾ

  -- Progress

  ⟨⟩ᵀ-progress-main :  ⊤' ⊢[ ∞ ]⟨ e ⟩ᵀ[ i ] P˙ →  ✓ᴴ H →
    (e , [] , H) ⇒ᵀ* (e' , es , H') →  val/ktxred e' ≡ ĩ₁ kr →  (kr , H') ⇒ᴷᴿ∑
  ⟨⟩ᵀ-progress-main =  ⟨⟩ᴾ-progress-main ∘ hor-ᵀ⇒ᴾ

  ⟨⟩ᵀ-progress-forked :
    ⊤' ⊢[ ∞ ]⟨ e ⟩ᵀ[ i ] P˙ →  ✓ᴴ H →  (e , [] , H) ⇒ᵀ* (e' , es , H') →
    e⁺ ∈ᴸ es →  val/ktxred e⁺ ≡ ĩ₁ kr →  (kr , H') ⇒ᴷᴿ∑
  ⟨⟩ᵀ-progress-forked =  ⟨⟩ᴾ-progress-forked ∘ hor-ᵀ⇒ᴾ

  -- Termination: ⊤' ⊢[ ∞ ]⟨ e ⟩ᵀ[ i ] P˙ ensures that (e , [] , H) is strongly
  -- normalizing, i.e., any execution of (e , [] , H) terminates, for valid H

  ⟨⟩ᵀ⇒SN :  ⊤' ⊢[ ∞ ]⟨ e ⟩ᵀ[ i ] P˙ →  ✓ᴴ H →  SNᵀ (e , [] , H)
  ⟨⟩ᵀ⇒SN ⊢⟨e⟩P =  ⟨⟩ᵀᵒ⇒SN $ ⊢⁺⟨⟩ᵀ-sem ⊢⟨e⟩P absurd

--------------------------------------------------------------------------------
-- Adequacy theorems for the infinite Hoare triple

abstract

  -- Progress

  ⟨⟩∞-progress-main :
    ⊤' ⊢[ ∞ ][ i ]⟨ e ⟩∞ →  ✓ᴴ H →  (e , [] , H) ⇒ᵀ* (e' , es , H') →
    ∑ kr ,  val/ktxred e' ≡ ĩ₁ kr  ×  (kr , H') ⇒ᴷᴿ∑
  ⟨⟩∞-progress-main ⊢⟨e⟩∞ =  ⟨⟩∞ᵒ-progress-main $ ⊢⁺⟨⟩∞-sem ⊢⟨e⟩∞ absurd

  ⟨⟩∞-progress-forked :
    ⊤' ⊢[ ∞ ][ i ]⟨ e ⟩∞ →  ✓ᴴ H →  (e , [] , H) ⇒ᵀ* (e' , es , H') →
    e⁺ ∈ᴸ es →  val/ktxred e⁺ ≡ ĩ₁ kr →  (kr , H') ⇒ᴷᴿ∑
  ⟨⟩∞-progress-forked =  ⟨⟩ᴾ-progress-forked ∘ ihor⇒horᴾ {Q˙ = λ _ → ⊤'}

  -- Infiniteness: ⊤' ⊢[ ∞ ][ i ]⟨ e ⟩∞ ensures that any execution of
  -- (e , [] , H) triggers the event an infinite number of times for valid H

  ⟨⟩∞⇒Inf :  ⊤' ⊢[ ∞ ][ i ]⟨ e ⟩∞ →  ✓ᴴ H →  Infᵀ ∞ (e , [] , H)
  ⟨⟩∞⇒Inf ⊢⟨e⟩∞ =  ⟨⟩∞ᵒ⇒Inf $ ⊢⁺⟨⟩∞-sem ⊢⟨e⟩∞ absurd
