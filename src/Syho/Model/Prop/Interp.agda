--------------------------------------------------------------------------------
-- Interpret all syntactic propositions
--------------------------------------------------------------------------------

{-# OPTIONS --without-K --sized-types #-}

module Syho.Model.Prop.Interp where

open import Base.Level using (1ᴸ)
open import Base.Func using (id)
open import Base.Size using (!)
open import Syho.Logic.Prop using (Prop∞; ∀˙; ∃˙; _→'_; _∗_; _-∗_; ⤇_; □_;
  _↦⟨_⟩_; Free; ○_; [_]ᴺ; &ⁱ⟨_⟩_; %ⁱ⟨_⟩_; _↪[_]⇛_; _↪[_]ᵃ⟨_⟩_; _↪⟨_⟩[_]_;
  _↪[_]⟨_⟩∞; [_]ᴸ⟨_⟩; †ᴸ_; ⟨†_⟩_; &ˢ⟨_⟩_; %ˢ⟨_⟩_; Basic; ∀-Basic; ∃-Basic;
  →-Basic; ∗-Basic; -∗-Basic; ⤇-Basic; □-Basic; ↦⟨⟩-Basic; Free-Basic;
  []ᴺ-Basic; []ᴸ⟨⟩-Basic; †ᴸ-Basic)
open import Syho.Model.ERA.Glob using (Globᴱᴿᴬ)
open import Syho.Model.Prop.Base using (Propᵒ; Monoᵒ; _⊨_; ∀ᵒ-syntax; ∃ᵒ-syntax;
  _→ᵒ_; _∗ᵒ_; _-∗ᵒ_; ⤇ᵒ_; □ᵒ_; ∀ᵒ-Mono; ∀ᵒ-mono; ∃ᵒ-Mono; ∃ᵒ-mono; →ᵒ-Mono;
  →ᵒ-mono; ∗ᵒ-Mono; ∗ᵒ-mono; -∗ᵒ-Mono; -∗ᵒ-mono; ⤇ᵒ-Mono; ⤇ᵒ-mono; □ᵒ-Mono;
  □ᵒ-mono; ◎-Mono)
open import Syho.Model.Prop.Mem using (_↦⟨_⟩ᵒ_; Freeᵒ; Freeᵒ-Mono)
open import Syho.Model.Prop.Names using ([_]ᴺᵒ)
open import Syho.Model.Prop.Lft using ([_]ᴸ⟨_⟩ᵒ; †ᴸᵒ_)
open import Syho.Model.Prop.Basic using (⸨_⸩ᴮ)
open import Syho.Model.Prop.Ind using (○ᵒ_; _↪[_]⇛ᴹ_; _↪[_]ᵃ⟨_⟩ᵒ_; _↪⟨_⟩[_]ᵒ_;
  _↪[_]⟨_⟩∞ᵒ; ○ᵒ-Mono; ↪⇛ᵒ-Mono; ↪ᵃ⟨⟩ᵒ-Mono; ↪⟨⟩ᵒ-Mono; ↪⟨⟩∞ᵒ-Mono)
open import Syho.Model.Prop.Inv using (&ⁱ⟨_⟩ᵒ_; %ⁱ⟨_⟩ᵒ_; &ⁱᵒ-Mono; %ⁱᵒ-Mono)

private variable
  P :  Prop∞

postulate
  WIP :  ∀{ł} {A : Set ł} →  A  -- Just for now

--------------------------------------------------------------------------------
-- ⸨ ⸩ :  Interpret syntactic propositions

⸨_⸩ :  Prop∞ →  Propᵒ 1ᴸ
⸨ ∀˙ P˙ ⸩ =  ∀ᵒ x , ⸨ P˙ x ⸩
⸨ ∃˙ P˙ ⸩ =  ∃ᵒ x , ⸨ P˙ x ⸩
⸨ P →' Q ⸩ =  ⸨ P ⸩ →ᵒ ⸨ Q ⸩
⸨ P ∗ Q ⸩ =  ⸨ P ⸩ ∗ᵒ ⸨ Q ⸩
⸨ P -∗ Q ⸩ =  ⸨ P ⸩ -∗ᵒ ⸨ Q ⸩
⸨ ⤇ P ⸩ =  ⤇ᵒ ⸨ P ⸩
⸨ □ P ⸩ =  □ᵒ ⸨ P ⸩
⸨ θ ↦⟨ p ⟩ ᵗv ⸩ =  θ ↦⟨ p ⟩ᵒ ᵗv
⸨ Free n θ ⸩ =  Freeᵒ n θ
⸨ ○ P˂ ⸩ =  ○ᵒ P˂ .!
⸨ P˂ ↪[ i ]⇛ Q˂ ⸩ =  P˂ .! ↪[ i ]⇛ᴹ Q˂ .!
⸨ P˂ ↪[ i ]ᵃ⟨ red ⟩ Q˂˙ ⸩ =  P˂ .! ↪[ i ]ᵃ⟨ red ⟩ᵒ λ v → Q˂˙ v .!
⸨ P˂ ↪⟨ e ⟩[ κ ] Q˂˙ ⸩ =  P˂ .! ↪⟨ e ⟩[ κ ]ᵒ λ v → Q˂˙ v .!
⸨ P˂ ↪[ i ]⟨ e ⟩∞ ⸩ =  P˂ .! ↪[ i ]⟨ e ⟩∞ᵒ
⸨ [ Nm ]ᴺ ⸩ =  [ Nm ]ᴺᵒ
⸨ &ⁱ⟨ nm ⟩ P˂ ⸩ =  &ⁱ⟨ nm ⟩ᵒ P˂ .!
⸨ %ⁱ⟨ nm ⟩ P˂ ⸩ =  %ⁱ⟨ nm ⟩ᵒ P˂ .!
⸨ [ α ]ᴸ⟨ p ⟩ ⸩ =  [ α ]ᴸ⟨ p ⟩ᵒ
⸨ †ᴸ α ⸩ =  †ᴸᵒ α
⸨ ⟨† α ⟩ P˂ ⸩ =  WIP
⸨ &ˢ⟨ α ⟩ P˂˙ ⸩ =  WIP
⸨ %ˢ⟨ αp ⟩ P˂ ⸩ =  WIP

abstract

  --  ⸨ P ⸩ satisfies monotonicity

  ⸨⸩-Mono :  Monoᵒ ⸨ P ⸩
  ⸨⸩-Mono {∀˙ P˙} =  ∀ᵒ-Mono λ x → ⸨⸩-Mono {P˙ x}
  ⸨⸩-Mono {∃˙ P˙} =  ∃ᵒ-Mono λ x → ⸨⸩-Mono {P˙ x}
  ⸨⸩-Mono {_ →' _} =  →ᵒ-Mono
  ⸨⸩-Mono {_ ∗ _} =  ∗ᵒ-Mono
  ⸨⸩-Mono {_ -∗ _} =  -∗ᵒ-Mono
  ⸨⸩-Mono {⤇ _} =  ⤇ᵒ-Mono
  ⸨⸩-Mono {□ P} =  □ᵒ-Mono (⸨⸩-Mono {P})
  ⸨⸩-Mono {_ ↦⟨ _ ⟩ _} =  ◎-Mono
  ⸨⸩-Mono {Free _ _} =  Freeᵒ-Mono
  ⸨⸩-Mono {○ _} =  ○ᵒ-Mono
  ⸨⸩-Mono {_ ↪[ _ ]⇛ _} =  ↪⇛ᵒ-Mono
  ⸨⸩-Mono {_ ↪[ _ ]ᵃ⟨ _ ⟩ _} =  ↪ᵃ⟨⟩ᵒ-Mono
  ⸨⸩-Mono {_ ↪⟨ _ ⟩[ _ ] _} =  ↪⟨⟩ᵒ-Mono
  ⸨⸩-Mono {_ ↪[ _ ]⟨ _ ⟩∞} =  ↪⟨⟩∞ᵒ-Mono
  ⸨⸩-Mono {&ⁱ⟨ _ ⟩ _} =  &ⁱᵒ-Mono
  ⸨⸩-Mono {%ⁱ⟨ _ ⟩ _} =  %ⁱᵒ-Mono
  ⸨⸩-Mono {[ _ ]ᴺ} =  ◎-Mono
  ⸨⸩-Mono {[ _ ]ᴸ⟨ _ ⟩} =  ◎-Mono
  ⸨⸩-Mono {†ᴸ _} =  ◎-Mono
  ⸨⸩-Mono {⟨† _ ⟩ _} =  WIP
  ⸨⸩-Mono {&ˢ⟨ _ ⟩ _} =  WIP
  ⸨⸩-Mono {%ˢ⟨ _ ⟩ _} =  WIP

  -- ⸨ ⸩ᴮ agrees with ⸨ ⸩
  -- ⸨⸩-ᴮ⇒ and ⸨⸩-⇒ᴮ are mutually recursive

  ⸨⸩-ᴮ⇒ :  {{_ : Basic P}} →  ⸨ P ⸩ᴮ ⊨ ⸨ P ⸩
  ⸨⸩-⇒ᴮ :  {{_ : Basic P}} →  ⸨ P ⸩ ⊨ ⸨ P ⸩ᴮ

  ⸨⸩-ᴮ⇒ {{∀-Basic BasicP˙}} {a} =  ∀ᵒ-mono (λ x → ⸨⸩-ᴮ⇒ {{BasicP˙ x}} {a}) {a}
  ⸨⸩-ᴮ⇒ {{∃-Basic BasicP˙}} {a} =  ∃ᵒ-mono (λ x → ⸨⸩-ᴮ⇒ {{BasicP˙ x}} {a}) {a}
  ⸨⸩-ᴮ⇒ {{→-Basic {P} {Q}}} =  →ᵒ-mono (⸨⸩-⇒ᴮ {P}) (⸨⸩-ᴮ⇒ {Q})
  ⸨⸩-ᴮ⇒ {{∗-Basic {P} {Q}}} =  ∗ᵒ-mono (⸨⸩-ᴮ⇒ {P}) (⸨⸩-ᴮ⇒ {Q})
  ⸨⸩-ᴮ⇒ {{ -∗-Basic {P} {Q}}} =  -∗ᵒ-mono (⸨⸩-⇒ᴮ {P}) (⸨⸩-ᴮ⇒ {Q})
  ⸨⸩-ᴮ⇒ {{⤇-Basic {P}}} =  ⤇ᵒ-mono (⸨⸩-ᴮ⇒ {P})
  ⸨⸩-ᴮ⇒ {{□-Basic {P}}} =  □ᵒ-mono λ{a} → ⸨⸩-ᴮ⇒ {P} {a}
  ⸨⸩-ᴮ⇒ {{↦⟨⟩-Basic}} =  id
  ⸨⸩-ᴮ⇒ {{Free-Basic}} =  id
  ⸨⸩-ᴮ⇒ {{[]ᴺ-Basic}} =  id
  ⸨⸩-ᴮ⇒ {{[]ᴸ⟨⟩-Basic}} =  id
  ⸨⸩-ᴮ⇒ {{†ᴸ-Basic}} =  id

  ⸨⸩-⇒ᴮ {{∀-Basic BasicP˙}} =  ∀ᵒ-mono λ x {a} → ⸨⸩-⇒ᴮ {{BasicP˙ x}} {a}
  ⸨⸩-⇒ᴮ {{∃-Basic BasicP˙}} =  ∃ᵒ-mono λ x {a} → ⸨⸩-⇒ᴮ {{BasicP˙ x}} {a}
  ⸨⸩-⇒ᴮ {{→-Basic {P} {Q}}} =  →ᵒ-mono (⸨⸩-ᴮ⇒ {P}) (⸨⸩-⇒ᴮ {Q})
  ⸨⸩-⇒ᴮ {{∗-Basic {P} {Q}}} =  ∗ᵒ-mono (⸨⸩-⇒ᴮ {P}) (⸨⸩-⇒ᴮ {Q})
  ⸨⸩-⇒ᴮ {{ -∗-Basic {P} {Q}}} =  -∗ᵒ-mono (⸨⸩-ᴮ⇒ {P}) (⸨⸩-⇒ᴮ {Q})
  ⸨⸩-⇒ᴮ {{⤇-Basic {P}}} =  ⤇ᵒ-mono (⸨⸩-⇒ᴮ {P})
  ⸨⸩-⇒ᴮ {{□-Basic {P}}} =  □ᵒ-mono λ{a} → ⸨⸩-⇒ᴮ {P} {a}
  ⸨⸩-⇒ᴮ {{↦⟨⟩-Basic}} =  id
  ⸨⸩-⇒ᴮ {{Free-Basic}} =  id
  ⸨⸩-⇒ᴮ {{[]ᴺ-Basic}} =  id
  ⸨⸩-⇒ᴮ {{[]ᴸ⟨⟩-Basic}} =  id
  ⸨⸩-⇒ᴮ {{†ᴸ-Basic}} =  id
