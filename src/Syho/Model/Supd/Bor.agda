--------------------------------------------------------------------------------
-- Super update on the bprrpw
--------------------------------------------------------------------------------

{-# OPTIONS --without-K --sized-types #-}

module Syho.Model.Supd.Bor where

open import Base.Level using (Level; _⊔ᴸ_; 1ᴸ)
open import Base.Func using (_$_; _▷_; _›_)
open import Base.Eq using (_≡_; refl)
open import Base.Bool using (𝔹; tt; ff)
open import Base.Option using (¿_; š_; ň)
open import Base.Prod using (_×_; _,_; -,_; _,-; -ᴵ,_; ∑-case)
open import Base.Nat using (ℕ)
open import Base.Ratp using (ℚ⁺; _/2⁺; ≈ᴿ⁺-refl; ≈ᴿ⁺-sym)
open import Syho.Logic.Prop using (Lft; Prop∞)
open import Syho.Model.ERA.Bor using (Envᴮᵒʳ; εᴮᵒʳ; borᵐ-lend-new; borᵐ-open;
  oborᵐ-close; lend-back)
open import Syho.Model.ERA.Glob using (jᴮᵒʳ; ∅ᴵⁿᴳ)
open import Syho.Model.Prop.Base using (Propᵒ; _⊨✓_; _⊨_; ⊨_; ⌜_⌝ᵒ×_; _∗ᵒ_;
  ∗ᵒ⇒∗ᵒ'; ∗ᵒ'⇒∗ᵒ; ∗ᵒ-Mono; ∗ᵒ-mono; ∗ᵒ-mono✓ˡ; ∗ᵒ-monoˡ; ∗ᵒ-mono✓ʳ; ∗ᵒ-monoʳ;
  ∗ᵒ-comm; ∗ᵒ-assocˡ; ∗ᵒ-assocʳ; ?∗ᵒ-comm; ∗ᵒ-pullʳ²; ∗ᵒ-pushʳ²ˡ; ?∗ᵒ-intro;
  ∗ᵒ-elimˡ; ∗ᵒ-elimʳ; ∃ᵒ∗ᵒ-out; □ᵒ-elim; dup-□ᵒ; ⤇ᴱ-mono✓; ⤇ᴱ-mono; ⤇ᴱ-param;
  ⤇ᴱ-eatʳ; ↝-◎⟨⟩-⤇ᴱ; ε↝-◎⟨⟩-⤇ᴱ)
open import Syho.Model.Prop.Basic using (⸨_⸩ᴮ; ⸨⸩ᴮ-Mono)
open import Syho.Model.Prop.Smry using (Smry; Smry-0; Smry-add-š; Smry-rem-<;
  Smry-upd)
open import Syho.Model.Prop.Lft using ([_]ᴸ⟨_⟩ᵒ; †ᴸᵒ_; []ᴸ⟨⟩ᵒ-resp;
  []ᴸ⟨⟩ᵒ-merge-/2; []ᴸ⟨⟩ᵒ-split-/2; dup-†ᴸᵒ; []ᴸ⟨⟩ᵒ-†ᴸᵒ-no)
open import Syho.Model.Prop.Bor using (Borᵐ; &ᵐ⟨_⟩ᵒ_; Oborᵐ; %ᵐ⟨_⟩ᵒ_; Lend;
  ⟨†_⟩ᵒ_; &ᵐᵒ-⟨†⟩ᵒ-make)
open import Syho.Model.Prop.Basic using (⸨⸩ᴮ-Mono)
open import Syho.Model.Prop.Interp using (⸨_⸩; ⸨⸩-ᴮ⇒; ⸨⸩-Mono)
open import Syho.Model.Prop.Sound using (⊢-sem)
open import Syho.Model.Supd.Base using ([_]⇛ᵍ¹_; ⇛ᵍ-mono✓; ⇛ᵍ-mono; ⊨✓⇒⊨-⇛ᵍ;
  ⇛ᵍ¹-make; ⇛ᵍ¹-intro; ⇛ᵍ-eatˡ)

private variable
  ł :  Level
  i :  ℕ
  p :  ℚ⁺
  pˇ :  ¿ ℚ⁺
  b :  𝔹
  α :  Lft
  P :  Prop∞
  Pᵒ :  Propᵒ ł

--------------------------------------------------------------------------------
-- Super update on Borᴱᴿᴬ

-- Lineᴮᵒʳ :  Line for Invᴮᵒʳ

Lineᴮᵒʳ :  ¿ ℚ⁺ × 𝔹 × Lft × Prop∞ →  Propᵒ 1ᴸ
Lineᴮᵒʳ (-, ff , α , _) =  †ᴸᵒ α
Lineᴮᵒʳ (ň , tt , -, P) =  ⸨ P ⸩
Lineᴮᵒʳ (š p , tt , α , _) =  [ α ]ᴸ⟨ p /2⁺ ⟩ᵒ

-- Invᴮᵒʳ :  Invariant for Borᴱᴿᴬ

Invᴮᵒʳ :  Envᴮᵒʳ →  Propᵒ 1ᴸ
Invᴮᵒʳ (E˙ , n) =  Smry (λ _ → Lineᴮᵒʳ) E˙ n

-- Super update on InvᴱᴿᴬBorᴱᴿᴬ

infix 3 ⇛ᴮᵒʳ_
⇛ᴮᵒʳ_ :  Propᵒ ł →  Propᵒ (1ᴸ ⊔ᴸ ł)
⇛ᴮᵒʳ Pᵒ =  [ jᴮᵒʳ , Invᴮᵒʳ ]⇛ᵍ¹ Pᵒ

abstract

  -- Get Invᴮᵒʳ (∅ᴵⁿᴳ jᴮᵒʳ) for free

  Invᴮᵒʳ-∅ :  ⊨ Invᴮᵒʳ (∅ᴵⁿᴳ jᴮᵒʳ)
  Invᴮᵒʳ-∅ =  Smry-0

  -- Introduce ⇛ᴮᵒʳ

  ⇛ᴮᵒʳ-intro :  Pᵒ  ⊨ ⇛ᴮᵒʳ  Pᵒ
  ⇛ᴮᵒʳ-intro =  ⇛ᵍ¹-intro

  -- Get &ᵐ⟨ α ⟩ᵒ P and ⟨† α ⟩ᵒ P by storing P

  &ᵐᵒ-new :  ⸨ P ⸩  ⊨ ⇛ᴮᵒʳ  &ᵐ⟨ α ⟩ᵒ P  ∗ᵒ  ⟨† α ⟩ᵒ P
  &ᵐᵒ-new =  ⇛ᵍ¹-make $ ?∗ᵒ-intro (ε↝-◎⟨⟩-⤇ᴱ borᵐ-lend-new) › ⤇ᴱ-eatʳ ›
    ⤇ᴱ-mono (λ _ → ∗ᵒ-mono &ᵐᵒ-⟨†⟩ᵒ-make Smry-add-š) › ⤇ᴱ-param

  -- Get ⸨ P ⸩ out of Lineᴮᵒʳ with ň using []ᴸ⟨⟩ᵒ

  []ᴸ⟨⟩ᵒ-open :  [ α ]ᴸ⟨ p ⟩ᵒ  ∗ᵒ  Lineᴮᵒʳ (ň , b , α , P)  ⊨✓
                   ⌜ b ≡ tt ⌝ᵒ×  [ α ]ᴸ⟨ p ⟩ᵒ  ∗ᵒ  ⸨ P ⸩
  []ᴸ⟨⟩ᵒ-open {b = tt} _ =  refl ,_
  []ᴸ⟨⟩ᵒ-open {b = ff} ✓∙ =  []ᴸ⟨⟩ᵒ-†ᴸᵒ-no ✓∙ › λ ()

  -- Take ⸨ P ⸩ out using Borᵐ and [ α ]ᴸ⟨ p ⟩ᵒ,
  -- getting [ α ]ᴸ⟨ p /2⁺ ⟩ᵒ and Oborᵐ i α p P in return

  Borᵐ-open :  [ α ]ᴸ⟨ p ⟩ᵒ  ∗ᵒ  Borᵐ i α P  ⊨ ⇛ᴮᵒʳ
                 ⸨ P ⸩  ∗ᵒ  [ α ]ᴸ⟨ p /2⁺ ⟩ᵒ  ∗ᵒ  Oborᵐ i α p P
  Borᵐ-open =  ⇛ᵍ¹-make $ ∗ᵒ-assocʳ › ?∗ᵒ-comm › ∗ᵒ-monoˡ (↝-◎⟨⟩-⤇ᴱ borᵐ-open) ›
    -- Obor∗[α]⟨p⟩∗Inv → Obor∗[α]⟨p⟩∗Line∗Inv → → → Obor∗[α]⟨p⟩∗P∗Inv → →
    -- Obor∗[α]⟨p/2⟩∗[α]⟨p/2⟩∗P∗Inv → Obor∗[α]⟨p/2⟩∗P∗[α]⟨p/2⟩∗Inv →
    -- Obor∗[α]⟨p/2⟩∗P∗Inv → → (Obor∗[α]⟨p/2⟩∗P)∗Inv → → (P∗[α]⟨p/2⟩∗Obor)∗Inv
    ⤇ᴱ-eatʳ › ⤇ᴱ-mono✓ (λ (i<n , b , Ei≡) ✓∙ → ∗ᵒ-mono✓ʳ (λ ✓∙ →
      ∗ᵒ-monoʳ (Smry-rem-< i<n Ei≡) › ∗ᵒ-assocˡ ›
      ∗ᵒ-mono✓ˡ ([]ᴸ⟨⟩ᵒ-open {b = b}) ✓∙ › ∃ᵒ∗ᵒ-out › ∑-case λ{ refl →
      ∗ᵒ-assocʳ › ∗ᵒ-monoˡ []ᴸ⟨⟩ᵒ-split-/2 › ∗ᵒ-assocʳ ›
      ∗ᵒ-monoʳ (?∗ᵒ-comm › ∗ᵒ-monoʳ Smry-upd) › ∗ᵒ-assocˡ }) ✓∙ ›
      ∗ᵒ-assocˡ › ∗ᵒ-monoˡ $ ?∗ᵒ-comm › ∗ᵒ-pullʳ²) › ⤇ᴱ-param

  -- Take ⸨ P ⸩ out using &ᵐ and []ᴸ⟨⟩ᵒ, getting %ᵐ in return

  &ᵐᵒ-open :  [ α ]ᴸ⟨ p ⟩ᵒ  ∗ᵒ  &ᵐ⟨ α ⟩ᵒ P  ⊨ ⇛ᴮᵒʳ  ⸨ P ⸩  ∗ᵒ  %ᵐ⟨ α , p ⟩ᵒ P
  &ᵐᵒ-open {p = p} =  ∗ᵒ⇒∗ᵒ' ›
    λ{ (-, -, ∙⊑ , [α]b , -, Q , -ᴵ, -, Q|R⊢⊣P@(Q∗R⊢P ,-) , □Q∗BorRc) →
    let MonoQ = ⸨⸩ᴮ-Mono {Q} in ∗ᵒ'⇒∗ᵒ (-, -, ∙⊑ , [α]b , □Q∗BorRc) ▷
    -- [α]⟨p⟩∗□Q∗Bor → □Q∗[α]⟨p⟩∗Bor → □Q∗R∗[α]⟨p/2⟩∗Obor → →
    -- □Q∗□Q∗R∗[α]⟨p/2⟩∗Obor → → Q∗□Q∗R∗[α]⟨p/2⟩∗Obor → Q∗R∗□Q∗[α]⟨p/2⟩∗Obor →
    -- (Q∗R)∗□Q∗[α]⟨p/2⟩∗Obor → P∗□Q∗[α]⟨p/2⟩∗Obor → P∗%
    ?∗ᵒ-comm ▷ ∗ᵒ-monoʳ Borᵐ-open ▷ ⇛ᵍ-eatˡ ▷ ⇛ᵍ-mono✓ (λ ✓∙ →
    ∗ᵒ-monoˡ (dup-□ᵒ MonoQ) › ∗ᵒ-assocʳ › ∗ᵒ-monoˡ (□ᵒ-elim MonoQ › ⸨⸩-ᴮ⇒ {Q}) ›
    ∗ᵒ-monoʳ ?∗ᵒ-comm › ∗ᵒ-assocˡ › ∗ᵒ-mono✓ˡ (⊢-sem Q∗R⊢P) ✓∙ ›
    ∗ᵒ-monoʳ λ big → -, p , Q , -ᴵ, -, (≈ᴿ⁺-refl {p} , Q|R⊢⊣P) , big) }

  -- Get [ α ]ᴸ⟨ p ⟩ᵒ out of Lineᴮᵒʳ with š p using [ α ]ᴸ⟨ p /2⁺ ⟩ᵒ

  []ᴸ⟨/2⟩ᵒ-close :  [ α ]ᴸ⟨ p /2⁺ ⟩ᵒ  ∗ᵒ  Lineᴮᵒʳ (š p , b , α , P)  ⊨✓
                      ⌜ b ≡ tt ⌝ᵒ×  [ α ]ᴸ⟨ p ⟩ᵒ
  []ᴸ⟨/2⟩ᵒ-close {b = tt} _ big =  refl , []ᴸ⟨⟩ᵒ-merge-/2 big
  []ᴸ⟨/2⟩ᵒ-close {b = ff} ✓∙ =  []ᴸ⟨⟩ᵒ-†ᴸᵒ-no ✓∙ › λ ()

  -- Retrieve [ α ]ᴸ⟨ p ⟩ᵒ and Borᵐ using ⸨ P ⸩, [ α ]ᴸ⟨ p /2⁺ ⟩ᵒ and Oborᵐ

  Oborᵐ-close :  ⸨ P ⸩  ∗ᵒ  [ α ]ᴸ⟨ p /2⁺ ⟩ᵒ  ∗ᵒ  Oborᵐ i α p P  ⊨ ⇛ᴮᵒʳ
                   [ α ]ᴸ⟨ p ⟩ᵒ  ∗ᵒ  Borᵐ i α P
  Oborᵐ-close =  ∗ᵒ-assocˡ › ⇛ᵍ¹-make $ ∗ᵒ-assocʳ › ?∗ᵒ-comm ›
    ∗ᵒ-monoˡ (↝-◎⟨⟩-⤇ᴱ oborᵐ-close) › ⤇ᴱ-eatʳ › ⤇ᴱ-mono✓ (λ (i<n , b , Ei≡) ✓∙ →
    -- Bor∗(P∗[α]⟨p/2⟩)∗Inv → Bor∗(P∗[α]⟨p/2⟩)∗Line∗Inv → → →
    -- Bor∗([α]⟨p/2⟩∗Line)∗P∗Inv → → Bor∗[α]⟨p⟩∗P∗Inv → Bor∗[α]⟨p⟩∗Inv → →
    -- ([α]⟨p⟩∗Bor)∗Inv
      ∗ᵒ-mono✓ʳ (λ ✓∙ → ∗ᵒ-monoʳ (Smry-rem-< i<n Ei≡) › ∗ᵒ-assocʳ › ∗ᵒ-pushʳ²ˡ ›
      ∗ᵒ-assocˡ › ∗ᵒ-mono✓ˡ ([]ᴸ⟨/2⟩ᵒ-close {b = b}) ✓∙ › ∃ᵒ∗ᵒ-out › ∑-case
      λ{ refl → ∗ᵒ-monoʳ Smry-upd }) ✓∙ › ∗ᵒ-assocˡ › ∗ᵒ-monoˡ ∗ᵒ-comm) ›
    ⤇ᴱ-param

  -- Retrieve [ α ]ᴸ⟨ p ⟩ᵒ and &ᵐᵒ using ⸨ P ⸩ and %ᵐᵒ

  %ᵐᵒ-close :  ⸨ P ⸩  ∗ᵒ  %ᵐ⟨ α , p ⟩ᵒ P  ⊨ ⇛ᴮᵒʳ  [ α ]ᴸ⟨ p ⟩ᵒ  ∗ᵒ  &ᵐ⟨ α ⟩ᵒ P
  %ᵐᵒ-close {p = p} =  ∗ᵒ⇒∗ᵒ' › λ{ (-, -, ∙⊑ , Pb ,
    -, q , Q , -ᴵ, -, (p≈q , Q|R⊢⊣P@(-, Q∗P⊢R)) , □Q∗[α]∗OborRc) →
    let MonoQ = ⸨⸩ᴮ-Mono {Q} in ∗ᵒ'⇒∗ᵒ (-, -, ∙⊑ , Pb , □Q∗[α]∗OborRc) ▷
    -- P∗□Q∗[α]⟨q/2⟩∗Obor → □Q∗P∗[α]⟨q/2⟩∗Obor → → □Q∗□Q∗P∗[α]⟨q/2⟩∗Obor → → →
    -- Q∗P∗□Q∗[α]⟨q/2⟩∗Obor → → R∗□Q∗[α]⟨q/2⟩∗Obor → □Q∗R∗[α]⟨q/2⟩∗Obor →
    -- □Q∗[α]⟨q⟩∗Bor → [α]⟨q⟩∗□Q∗Bor → [α]⟨p⟩∗&
    ⊨✓⇒⊨-⇛ᵍ λ ✓∙ → ?∗ᵒ-comm › ∗ᵒ-monoˡ (dup-□ᵒ MonoQ) › ∗ᵒ-assocʳ ›
    ∗ᵒ-monoˡ (□ᵒ-elim MonoQ › ⸨⸩-ᴮ⇒ {Q}) › ∗ᵒ-monoʳ ?∗ᵒ-comm › ∗ᵒ-assocˡ ›
    ∗ᵒ-mono✓ˡ (⊢-sem Q∗P⊢R) ✓∙ › ?∗ᵒ-comm › ∗ᵒ-monoʳ Oborᵐ-close › ⇛ᵍ-eatˡ ›
    ⇛ᵍ-mono $ ?∗ᵒ-comm › ∗ᵒ-mono ([]ᴸ⟨⟩ᵒ-resp $ ≈ᴿ⁺-sym {p} {q} p≈q)
      λ big → -, Q , -ᴵ, -, Q|R⊢⊣P , big }

  -- Get ⸨ P ⸩ out of Lineᴮᵒʳ with tt using †ᴸᵒ

  †ᴸᵒ-back :  †ᴸᵒ α  ∗ᵒ  Lineᴮᵒʳ (pˇ , tt , α , P)  ⊨✓  ⸨ P ⸩
  †ᴸᵒ-back {pˇ = ň} {P} _ =  ∗ᵒ-elimʳ $ ⸨⸩-Mono {P = P}
  †ᴸᵒ-back {pˇ = š _} ✓∙ =  ∗ᵒ-comm › []ᴸ⟨⟩ᵒ-†ᴸᵒ-no ✓∙ › λ ()

  -- Get ⸨ P ⸩ back from Lend using †ᴸᵒ

  Lend-back :  †ᴸᵒ α  ∗ᵒ  Lend i α P  ⊨ ⇛ᴮᵒʳ  ⸨ P ⸩
  Lend-back =  ⇛ᵍ¹-make $ ∗ᵒ-assocʳ › ?∗ᵒ-comm ›
    ∗ᵒ-monoˡ (↝-◎⟨⟩-⤇ᴱ {bⁱ˙ = λ _ → εᴮᵒʳ} lend-back) › ⤇ᴱ-eatʳ ›
    -- -∗†∗Inv → → †∗Inv → (†∗†)∗Line∗Inv → †∗†∗Line∗Inv → →
    -- (†∗Line)∗†∗Inv → P∗†∗Inv → P∗†∗Inv → P∗Inv
    ⤇ᴱ-mono✓ (λ (i<n , pˇ , Ei≡) ✓∙ → ∗ᵒ-elimʳ ∗ᵒ-Mono ›
      ∗ᵒ-mono dup-†ᴸᵒ (Smry-rem-< i<n Ei≡) › ∗ᵒ-assocʳ › ∗ᵒ-monoʳ ?∗ᵒ-comm ›
      ∗ᵒ-assocˡ › ∗ᵒ-mono✓ˡ (†ᴸᵒ-back {pˇ = pˇ}) ✓∙ › ∗ᵒ-monoʳ Smry-upd) ›
    ⤇ᴱ-param

  -- Get ⸨ P ⸩ back from ⟨†⟩ᵒ using †ᴸᵒ

  ⟨†⟩ᵒ-back :  †ᴸᵒ α  ∗ᵒ  ⟨† α ⟩ᵒ P  ⊨ ⇛ᴮᵒʳ  ⸨ P ⸩
  ⟨†⟩ᵒ-back =  ∗ᵒ⇒∗ᵒ' › λ{ (-, -, ∙⊑ , †αb , -, Q , -ᴵ, -, Q∗R⊢P , Q∗LendRc) →
    ∗ᵒ'⇒∗ᵒ (-, -, ∙⊑ , †αb , Q∗LendRc) ▷ ?∗ᵒ-comm ▷ ∗ᵒ-monoʳ Lend-back ▷
    ⇛ᵍ-eatˡ ▷ ⇛ᵍ-mono✓ (λ ✓∙ → ∗ᵒ-monoˡ (⸨⸩-ᴮ⇒ {Q}) › ⊢-sem Q∗R⊢P ✓∙) }
