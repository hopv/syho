--------------------------------------------------------------------------------
-- Interpreting exclusive save tokens
--------------------------------------------------------------------------------

{-# OPTIONS --without-K --sized-types #-}

module Syho.Model.Save.Exc where

open import Base.Size using (∞)
open import Base.Func using (_$_)
open import Base.Nat using (ℕ)
open import Syho.Logic.Prop using (Prop'; _∧_; Basic)
open import Syho.Logic.Judg using (_⊢[_]_)
open import Syho.Model.RA using (RA)
open import Syho.Model.RA.Glob using (GlobRA; Glob; module ModGlobI;
  module ModSaveˣ; module ModExcᴾ)
open ModGlobI using (injaᴬ)
open ModSaveˣ using (injaᶠᵐ)
open ModExcᴾ using (#ˣ_)
open import Syho.Model.Prop GlobRA using (Propᵒ; _⊨_; ∃₂ᵒ-syntax; ∃₀ᵒ-syntax;
  _∧ᵒ_; ⌜_⌝₂ᵒ; Own)
open import Syho.Model.Basic using (⸨_⸩ᴮ)

--------------------------------------------------------------------------------
-- Interpreting exclusive save tokens

lineˢˣ :  ℕ →  Prop' ∞ →  Glob
lineˢˣ i P =  injaᴬ 0 $ injaᶠᵐ i $ #ˣ P

Saveˣᵒ :  Prop' ∞ →  Propᵒ
Saveˣᵒ P =  ∃₂ᵒ P' , ∃₂ᵒ Q , ∃₂ᵒ BaQ , ∃₀ᵒ i ,
  ⌜ Q ∧ P' ⊢[ ∞ ] P ⌝₂ᵒ  ∧ᵒ  ⸨ Q ⸩ᴮ {{ BaQ }}  ∧ᵒ  Own (lineˢˣ i P')
