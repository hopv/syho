--------------------------------------------------------------------------------
-- Proof rules on the lifetime
--------------------------------------------------------------------------------

{-# OPTIONS --without-K --sized-types #-}

module Syho.Logic.Lft where

open import Base.Func using (_$_)
open import Base.Size using (𝕊)
open import Base.Ratp using (ℚ⁺; _/2⁺; /2⁺-merge; /2⁺-split)
open import Syho.Logic.Prop using (Lft; _∗_; [_]ᴸ⟨_⟩; †ᴸ_)
open import Syho.Logic.Core using (_⊢[_]_; Pers; _»_; Pers-⇒□)

-- Import and re-export
open import Syho.Logic.Judg public using ([]ᴸ⟨⟩-resp; []ᴸ⟨⟩-merge; []ᴸ⟨⟩-split;
  []ᴸ⟨⟩-≤1; †ᴸ-⇒□; []ᴸ⟨⟩-†ᴸ-no; []ᴸ-new; []ᴸ-kill)

private variable
  ι :  𝕊
  α :  Lft
  p :  ℚ⁺

abstract

  ------------------------------------------------------------------------------
  -- On the lifetime

  -->  []ᴸ⟨⟩-≤1 :  [ α ]ᴸ⟨ p ⟩  ⊢[ ι ]  ⌜ p ≤1ᴿ⁺ ⌝

  -->  []ᴸ⟨⟩-†ᴸ-no :  [ α ]ᴸ⟨ p ⟩  ∗  †ᴸ α  ⊢[ ι ]  ⊥'

  -->  []ᴸ-new :  ⊤'  ⊢[ ι ] ⤇  ∃ α , [ α ]ᴸ

  -->  []ᴸ-kill :  [ α ]ᴸ  ⊢[ ι ] ⤇  †ᴸ α

  instance

    -- The dead lifetime token is persistent

    -->  †ᴸ-⇒□ :  †ᴸ α  ⊢[ ι ]  □ †ᴸ α

    †ᴸ-Pers :  Pers $ †ᴸ α
    †ᴸ-Pers .Pers-⇒□ =  †ᴸ-⇒□

  -- On the fraction

  -->  []ᴸ⟨⟩-resp :  p ≈ᴿ⁺ q  →   [ α ]ᴸ⟨ p ⟩  ⊢[ ι ]  [ α ]ᴸ⟨ q ⟩

  -->  []ᴸ⟨⟩-merge :  [ α ]ᴸ⟨ p ⟩  ∗  [ α ]ᴸ⟨ q ⟩  ⊢[ ι ]  [ α ]ᴸ⟨ p +ᴿ⁺ q ⟩

  -->  []ᴸ⟨⟩-split :  [ α ]ᴸ⟨ p +ᴿ⁺ q ⟩  ⊢[ ι ]  [ α ]ᴸ⟨ p ⟩  ∗  [ α ]ᴸ⟨ q ⟩

  []ᴸ⟨⟩-merge-/2 :  [ α ]ᴸ⟨ p /2⁺ ⟩  ∗  [ α ]ᴸ⟨ p /2⁺ ⟩  ⊢[ ι ]  [ α ]ᴸ⟨ p ⟩
  []ᴸ⟨⟩-merge-/2 {p = p} =  []ᴸ⟨⟩-merge » []ᴸ⟨⟩-resp $ /2⁺-merge {p}

  []ᴸ⟨⟩-split-/2 :  [ α ]ᴸ⟨ p ⟩  ⊢[ ι ]  [ α ]ᴸ⟨ p /2⁺ ⟩  ∗  [ α ]ᴸ⟨ p /2⁺ ⟩
  []ᴸ⟨⟩-split-/2 {p = p} =  []ᴸ⟨⟩-resp (/2⁺-split {p}) » []ᴸ⟨⟩-split
