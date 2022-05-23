--------------------------------------------------------------------------------
-- Semantic proposition
--------------------------------------------------------------------------------

{-# OPTIONS --without-K --sized-types #-}

open import Base.Level using (Level; ^ˡ_)
open import Shog.Model.RA using (RA)
-- Parametric over the global RA
module Shog.Model.Prop {ℓ : Level} (Globᴿᴬ : RA (^ˡ ℓ) (^ˡ ℓ) (^ˡ ℓ))
  where

open import Base.Few using (⊤; ⊥)
open import Base.Func using (_$_; _▷_; flip; _∈_)
open import Base.Prod using (Σ-syntax; _×_; _,_)
open import Base.Sum using (_⊎_; inj₀; inj₁)
open import Base.List using (List; _∷_; []; map)

open RA Globᴿᴬ renaming (Car to Glob) using (_≈_; _⊑_; ✓_; _∙_; ε; ⌞_⌟; _↝_;
  _↝ˢ_; sym˜; _»˜_; ⊑-refl; ⊑-trans; ⊑-respˡ; ⊑-respʳ; ✓-resp; ✓-mono; ∙-congʳ;
  ∙-monoˡ; ∙-monoʳ; ∙-mono; ∙-incrˡ; ∙-incrʳ; ∙-comm; ∙-assocˡ; ∙-assocʳ;
  ∙≈-✓ˡ; ∙≈-✓ʳ; ✓-remˡ; ε-min; ⌞⌟-idem; ⌞⌟-mono; ✓-⌞⌟)

private variable
  ℓF :  Level

--------------------------------------------------------------------------------
-- Propᵒ: Semantic proposition

Monoᵒ :  ∀ (predᵒ : ∀ (a : Glob) →  ✓ a →  Set (^ˡ ℓ)) →  Set (^ˡ ℓ)
Monoᵒ predᵒ =  ∀ {a b ✓a ✓b} →  a ⊑ b →  predᵒ a ✓a →  predᵒ b ✓b

record  Propᵒ :  Set (^ˡ ^ˡ ℓ)  where
  field
    predᵒ :  ∀ (a : Glob) →  ✓ a →  Set (^ˡ ℓ)
    monoᵒ :  Monoᵒ predᵒ
  renewᵒ :  ∀ {a ✓a ✓a'} →  predᵒ a ✓a →  predᵒ a ✓a'
  renewᵒ =  monoᵒ ⊑-refl
open Propᵒ public

private variable
  ℓB :  Level
  X :  Set ℓ
  X^ :  Set (^ˡ ℓ)
  Pᵒ Qᵒ Rᵒ :  Propᵒ
  a b :  Glob
  B :  Glob → Set ℓB

--------------------------------------------------------------------------------
-- ⊨: Entailment

infix 1 _⊨_
_⊨_ :  Propᵒ →  Propᵒ →  Set (^ˡ ℓ)
Pᵒ ⊨ Qᵒ =  ∀ {a ✓a} →  Pᵒ .predᵒ a ✓a →  Qᵒ .predᵒ a ✓a

abstract

  -- ⊨ is reflexive and transitive

  reflᵒ :  Pᵒ ⊨ Pᵒ
  reflᵒ Pa =  Pa

  infixr -1 _»ᵒ_
  _»ᵒ_ :  Pᵒ ⊨ Qᵒ →  Qᵒ ⊨ Rᵒ →  Pᵒ ⊨ Rᵒ
  (P⊨Q »ᵒ Q⊨R) Pa =  Pa ▷ P⊨Q ▷ Q⊨R

--------------------------------------------------------------------------------
-- ∀ᵒ˙, ∃ᵒ˙, ∀ᵒ˙', ∃ᵒ˙': Universal/existential quantification

-- For Set ℓ

∀ᵒ˙ ∃ᵒ˙ :  (X : Set ℓ) →  (X → Propᵒ) →  Propᵒ
∀ᵒ˙ _ Pᵒ˙ .predᵒ a ✓a =  ∀ x →  Pᵒ˙ x .predᵒ a ✓a
∀ᵒ˙ _ Pᵒ˙ .monoᵒ =  proof
 where abstract
  proof :  Monoᵒ $ ∀ᵒ˙ _ Pᵒ˙ .predᵒ
  proof a⊑b ∀xPxa x =  Pᵒ˙ x .monoᵒ a⊑b (∀xPxa x)
∃ᵒ˙ _ Pᵒ˙ .predᵒ a ✓a =  Σ x ,  Pᵒ˙ x .predᵒ a ✓a
∃ᵒ˙ _ Pᵒ˙ .monoᵒ =  proof
 where abstract
  proof :  Monoᵒ $ ∃ᵒ˙ _ Pᵒ˙ .predᵒ
  proof a⊑b (x , Pxa) =  x ,  Pᵒ˙ x .monoᵒ a⊑b Pxa

-- For Set (^ˡ ℓ)

∀^˙ ∃^˙ :  (X^ : Set (^ˡ ℓ)) →  (X^ → Propᵒ) →  Propᵒ
∀^˙ _ Pᵒ˙ .predᵒ a ✓a =  ∀ x →  Pᵒ˙ x .predᵒ a ✓a
∀^˙ _ Pᵒ˙ .monoᵒ =  proof
 where abstract
  proof :  Monoᵒ $ ∀^˙ _ Pᵒ˙ .predᵒ
  proof a⊑b ∀xPxa x =  Pᵒ˙ x .monoᵒ a⊑b (∀xPxa x)
∃^˙ _ Pᵒ˙ .predᵒ a ✓a =  Σ x ,  Pᵒ˙ x .predᵒ a ✓a
∃^˙ _ Pᵒ˙ .monoᵒ =  proof
 where abstract
  proof :  Monoᵒ $ ∃^˙ _ Pᵒ˙ .predᵒ
  proof a⊑b (x , Pxa) =  x ,  Pᵒ˙ x .monoᵒ a⊑b Pxa

∀ᵒ∈-syntax ∃ᵒ∈-syntax :  (X : Set ℓ) →  (X → Propᵒ) →  Propᵒ
∀^∈-syntax ∃^∈-syntax :  (X^ : Set (^ˡ ℓ)) →  (X^ → Propᵒ) →  Propᵒ
∀ᵒ∈-syntax =  ∀ᵒ˙
∃ᵒ∈-syntax =  ∃ᵒ˙
∀^∈-syntax =  ∀^˙
∃^∈-syntax =  ∃^˙

∀ᵒ-syntax ∃ᵒ-syntax :  (X → Propᵒ) →  Propᵒ
∀^-syntax ∃^-syntax :  (X^ → Propᵒ) →  Propᵒ
∀ᵒ-syntax =  ∀ᵒ˙ _
∃ᵒ-syntax =  ∃ᵒ˙ _
∀^-syntax =  ∀^˙ _
∃^-syntax =  ∃^˙ _

infix 3 ∀ᵒ∈-syntax ∃ᵒ∈-syntax ∀^∈-syntax ∃^∈-syntax
  ∀ᵒ-syntax ∃ᵒ-syntax ∀^-syntax ∃^-syntax
syntax ∀ᵒ∈-syntax X (λ x → Pᵒ) =  ∀ᵒ x ∈ X , Pᵒ
syntax ∃ᵒ∈-syntax X (λ x → Pᵒ) =  ∃ᵒ x ∈ X , Pᵒ
syntax ∀^∈-syntax X (λ x → Pᵒ) =  ∀^ x ∈ X , Pᵒ
syntax ∃^∈-syntax X (λ x → Pᵒ) =  ∃^ x ∈ X , Pᵒ
syntax ∀ᵒ-syntax (λ x → Pᵒ) =  ∀ᵒ x , Pᵒ
syntax ∃ᵒ-syntax (λ x → Pᵒ) =  ∃ᵒ x , Pᵒ
syntax ∀^-syntax (λ x → Pᵒ) =  ∀^ x , Pᵒ
syntax ∃^-syntax (λ x → Pᵒ) =  ∃^ x , Pᵒ

--------------------------------------------------------------------------------
-- ∧ᵒ: Conjunction
-- ∨ᵒ: Disjunction

infixr 7 _∧ᵒ_
infixr 6 _∨ᵒ_

_∧ᵒ_ _∨ᵒ_ :  Propᵒ →  Propᵒ →  Propᵒ
(Pᵒ ∧ᵒ Qᵒ) .predᵒ a ✓a =  Pᵒ .predᵒ a ✓a  ×  Qᵒ .predᵒ a ✓a
(Pᵒ ∧ᵒ Qᵒ) .monoᵒ =  proof
 where abstract
  proof :  Monoᵒ $ (Pᵒ ∧ᵒ Qᵒ) .predᵒ
  proof a⊑b (Pa , Qa) =  Pᵒ .monoᵒ a⊑b Pa , Qᵒ .monoᵒ a⊑b Qa
(Pᵒ ∨ᵒ Qᵒ) .predᵒ a ✓a =  Pᵒ .predᵒ a ✓a  ⊎  Qᵒ .predᵒ a ✓a
(Pᵒ ∨ᵒ Qᵒ) .monoᵒ =  proof
 where abstract
  proof :  Monoᵒ $ (Pᵒ ∨ᵒ Qᵒ) .predᵒ
  proof a⊑b (inj₀ Pa) =  inj₀ $ Pᵒ .monoᵒ a⊑b Pa
  proof a⊑b (inj₁ Qa) =  inj₁ $ Qᵒ .monoᵒ a⊑b Qa

--------------------------------------------------------------------------------
-- ⊤ᵒ: Truth
-- ⊥ᵒ: Falsehood

⊤ᵒ ⊥ᵒ :  Propᵒ
⊤ᵒ .predᵒ _ _ =  ⊤
⊤ᵒ .monoᵒ _ _ =  _
⊥ᵒ .predᵒ _ _ =  ⊥
⊥ᵒ .monoᵒ _ ()

--------------------------------------------------------------------------------
-- ⌜ ⌝^: Set embedding

⌜_⌝^ :  Set (^ˡ ℓ) →  Propᵒ
⌜ X ⌝^ .predᵒ _ _ =  X
⌜ _ ⌝^ .monoᵒ _ x =  x

--------------------------------------------------------------------------------
-- →ᵒ: Implication

infixr 5 _→ᵒ_
_→ᵒ_ :  Propᵒ → Propᵒ → Propᵒ
(Pᵒ →ᵒ Qᵒ) .predᵒ a _ =  ∀ {b ✓b} →  a ⊑ b →  Pᵒ .predᵒ b ✓b →  Qᵒ .predᵒ b ✓b
(Pᵒ →ᵒ Qᵒ) .monoᵒ {✓a = ✓a} {✓b} =  proof {✓a = ✓a} {✓b}
 where abstract
  proof :  Monoᵒ $ (Pᵒ →ᵒ Qᵒ) .predᵒ
  proof a⊑b P→Qa b⊑c =  P→Qa (⊑-trans a⊑b b⊑c)

--------------------------------------------------------------------------------
-- ∗ᵒ: Separating conjunction

infixr 7 _∗ᵒ_
_∗ᵒ_ :  Propᵒ → Propᵒ → Propᵒ
(Pᵒ ∗ᵒ Qᵒ) .predᵒ a ✓a =  Σ b , Σ c , Σ b∙c≈a ,
  Pᵒ .predᵒ b (∙≈-✓ˡ b∙c≈a ✓a)  ×  Qᵒ .predᵒ c (∙≈-✓ʳ b∙c≈a ✓a)
(Pᵒ ∗ᵒ Qᵒ) .monoᵒ {✓a = ✓a} {✓b} =  proof {✓a = ✓a} {✓b}
 where abstract
  proof :  Monoᵒ $ (Pᵒ ∗ᵒ Qᵒ) .predᵒ
  proof (c , c∙a≈b) (d , e , d∙e≈a , Pd , Qe) =
    c ∙ d , e , (∙-assocˡ »˜ ∙-congʳ d∙e≈a »˜ c∙a≈b) ,
    Pᵒ .monoᵒ ∙-incrˡ Pd , renewᵒ Qᵒ Qe

--------------------------------------------------------------------------------
-- -∗ᵒ: Magic wand

infixr 5 _-∗ᵒ_
_-∗ᵒ_ :  Propᵒ → Propᵒ → Propᵒ
(Pᵒ -∗ᵒ Qᵒ) .predᵒ a _ =  ∀ {b c ✓c ✓c∙b} →  a ⊑ b →
  Pᵒ .predᵒ c ✓c → Qᵒ .predᵒ (c ∙ b) ✓c∙b
(Pᵒ -∗ᵒ Qᵒ) .monoᵒ {✓a = ✓a} {✓b} =  proof {✓a = ✓a} {✓b}
 where abstract
  proof :  Monoᵒ $ (Pᵒ -∗ᵒ Qᵒ) .predᵒ
  proof a⊑b P-∗Qa b⊑c Pc =  P-∗Qa (⊑-trans a⊑b b⊑c) Pc

--------------------------------------------------------------------------------
-- |=>ᵒ: Update modality

infix 8 |=>ᵒ_
|=>ᵒ_ :  Propᵒ → Propᵒ
(|=>ᵒ Pᵒ) .predᵒ a _ =  ∀ c →  ✓ c ∙ a →  Σ b , Σ ✓c∙b ,
  Pᵒ .predᵒ b (✓-remˡ {c} {b} ✓c∙b)
(|=>ᵒ Pᵒ) .monoᵒ {✓a = ✓a} {✓b} =  proof {✓a = ✓a} {✓b}
 where abstract
  proof :  Monoᵒ $ (|=>ᵒ Pᵒ) .predᵒ
  proof (d , d∙a≈b) |=>Pa e ✓e∙b with
    |=>Pa (e ∙ d) $ flip ✓-resp ✓e∙b $ ∙-congʳ (sym˜ d∙a≈b) »˜ ∙-assocʳ
  ... | (c , ✓ed∙c , Pc) =  c , (flip ✓-mono ✓ed∙c $ ∙-monoˡ ∙-incrʳ) ,
    renewᵒ Pᵒ Pc

--------------------------------------------------------------------------------
-- □ᵒ: Persistence modality

infix 8 □ᵒ_
□ᵒ_ :  Propᵒ → Propᵒ
(□ᵒ Pᵒ) .predᵒ a ✓a =  Pᵒ .predᵒ ⌞ a ⌟ (✓-⌞⌟ ✓a)
(□ᵒ Pᵒ) .monoᵒ {✓a = ✓a} {✓b} =  proof {✓a = ✓a} {✓b}
 where abstract
  proof :  Monoᵒ $ (□ᵒ Pᵒ) .predᵒ
  proof a⊑b P⌞a⌟ =  Pᵒ .monoᵒ (⌞⌟-mono a⊑b) P⌞a⌟

--------------------------------------------------------------------------------
-- own: Owning a resource

own :  Glob →  Propᵒ
own a .predᵒ b _ =  a ⊑ b
own a .monoᵒ {✓a = ✓a} {✓b} =  proof {✓a = ✓a} {✓b}
 where abstract
  proof :  Monoᵒ $ own a .predᵒ
  proof b⊑c a⊑b =  ⊑-trans a⊑b b⊑c

abstract

  own-resp :  a ≈ b →  own a ⊨ own b
  own-resp a≈b a⊑c =  ⊑-respˡ a≈b a⊑c

  own-mono :  a ⊑ b →  own b ⊨ own a
  own-mono a⊑b b⊑c =  ⊑-trans a⊑b b⊑c

  own-∙⇒∗ :  own (a ∙ b) ⊨ own a ∗ᵒ own b
  own-∙⇒∗ {a = a} {b} {c} (d , d∙ab≈c) =  d ∙ a , b , (∙-assocˡ »˜ d∙ab≈c) ,
    ∙-incrˡ , ⊑-refl

  own-∗⇒∙ :  own a ∗ᵒ own b ⊨ own (a ∙ b)
  own-∗⇒∙ {a = a} {b} (a' , b' , a'∙b'≈c , a⊑a' , b⊑b') =
    ⊑-respʳ a'∙b'≈c (∙-mono a⊑a' b⊑b')

  own-ε-intro :  Pᵒ ⊨ own ε
  own-ε-intro _ =  ε-min

  own-⌞⌟-□ :  own ⌞ a ⌟ ⊨ □ᵒ own ⌞ a ⌟
  own-⌞⌟-□ ⌞a⌟⊑b =  ⊑-respˡ ⌞⌟-idem $ ⌞⌟-mono ⌞a⌟⊑b

  own-⌞⌟-□' :  ⌞ a ⌟ ≈ a →  own a ⊨ □ᵒ own a
  own-⌞⌟-□' ⌞a⌟≈a a⊑b =  ⊑-respˡ ⌞a⌟≈a $ ⌞⌟-mono a⊑b

  own⇒✓ :  own a ⊨ ⌜ ✓ a ⌝^
  own⇒✓ {✓a = ✓b} a⊑b =  ✓-mono a⊑b ✓b

  own-↝ :  a ↝ b →  own a ⊨ |=>ᵒ own b
  own-↝ {b = b} a↝b (c , c∙a≈a') d ✓d∙a' =  b , ✓d∙b , ⊑-refl
   where
    ✓d∙b :  ✓ d ∙ b
    ✓d∙b =  ✓-mono (∙-monoˡ ∙-incrʳ) $ a↝b (d ∙ c) $ flip ✓-resp ✓d∙a' $
      ∙-congʳ (sym˜ c∙a≈a') »˜ ∙-assocʳ

  own-↝ˢ :  a ↝ˢ B →  own a ⊨ |=>ᵒ (∃^ b , ⌜ b ∈ B ⌝^ ∧ᵒ own b)
  own-↝ˢ a↝B {✓a = ✓a'} (c , c∙a≈a') d ✓d∙a' with a↝B (d ∙ c) $
    flip ✓-resp ✓d∙a' $ ∙-congʳ (sym˜ c∙a≈a') »˜ ∙-assocʳ
  ... | b , b∈B , ✓d∙cb =  b , ✓-mono (∙-monoˡ ∙-incrʳ) ✓d∙cb , b , b∈B , ⊑-refl
