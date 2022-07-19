--------------------------------------------------------------------------------
-- Semantic proposition
--------------------------------------------------------------------------------

{-# OPTIONS --without-K --sized-types #-}

open import Base.Level using (Level; ^_)
open import Shog.Model.RA using (RA)
-- Parametric over the global RA
module Shog.Model.Prop {ℓ : Level} (GlobRA : RA (^ ℓ) (^ ℓ) (^ ℓ)) where

open import Base.Few using (⊤; ⊥)
open import Base.Func using (_$_; _▷_; flip; _∈_)
open import Base.Prod using (∑-syntax; _×_; _,_)
open import Base.Sum using (_⊎_; inj₀; inj₁)
open import Base.List using (List; _∷_; []; map)

open RA GlobRA renaming (Car to Glob) using (_≈_; _⊑_; ✓_; _∙_; ε; ⌞_⌟; _↝_;
  _↝ˢ_; ◠˜_; _◇˜_; ≈⇒⊑; ⊑-refl; ⊑-trans; ⊑-respˡ; ⊑-respʳ; ✓-resp; ✓-mono;
  ∙-congʳ; ∙-monoˡ; ∙-monoʳ; ∙-mono; ∙-incrˡ; ∙-incrʳ; ∙-comm; ∙-assocˡ;
  ∙-assocʳ; ε-min; ⌞⌟-idem; ⌞⌟-mono; ✓-⌞⌟)

private variable
  ℓF :  Level

--------------------------------------------------------------------------------
-- Propᵒ: Semantic proposition

-- Monoᵒ predᵒ :
--   predᵒ is monotone over the resource, ignoring the validity data
Monoᵒ :  (∀ a → ✓ a → Set (^ ℓ)) →  Set (^ ℓ)
Monoᵒ predᵒ =  ∀ {a b ✓a ✓b} →  a ⊑ b →  predᵒ a ✓a →  predᵒ b ✓b

record  Propᵒ :  Set (^ ^ ℓ)  where
  field
    -- Predicate, parametrized over a resource a that is valid
    predᵒ :  ∀ (a : Glob) →  ✓ a →  Set (^ ℓ)
    -- predᵒ is monotone over the resource, ignoring the validity data
    monoᵒ :  Monoᵒ predᵒ

  abstract
    -- Change the validity of predᵒ
    renewᵒ :  ∀ {a ✓a ✓a'} →  predᵒ a ✓a →  predᵒ a ✓a'
    renewᵒ =  monoᵒ ⊑-refl
    -- Change the resource of predᵒ into an equivalent one
    congᵒ :  ∀ {a b ✓a ✓b} →  a ≈ b →  predᵒ a ✓a →  predᵒ b ✓b
    congᵒ a≈b =  monoᵒ (≈⇒⊑ a≈b)
    -- congᵒ with the validity predicate specified
    congᵒ' :  ∀ {a b ✓b} a≈b →  predᵒ a (✓-resp (◠˜ a≈b) ✓b) →  predᵒ b ✓b
    congᵒ' a≈b =  congᵒ a≈b

open Propᵒ public

private variable
  ℓB :  Level
  X :  Set ℓ
  X^ :  Set (^ ℓ)
  Pᵒ Qᵒ Rᵒ :  Propᵒ
  a b c :  Glob
  B :  Glob → Set ℓB

--------------------------------------------------------------------------------
-- ⊨: Entailment

infix 1 _⊨_
_⊨_ :  Propᵒ →  Propᵒ →  Set (^ ℓ)
Pᵒ ⊨ Qᵒ =  ∀ {a ✓a} →  Pᵒ .predᵒ a ✓a →  Qᵒ .predᵒ a ✓a

abstract

  -- ⊨ is reflexive and transitive

  reflᵒ :  Pᵒ ⊨ Pᵒ
  reflᵒ Pa =  Pa

  infixr -1 _◇ᵒ_
  _◇ᵒ_ :  Pᵒ ⊨ Qᵒ →  Qᵒ ⊨ Rᵒ →  Pᵒ ⊨ Rᵒ
  (P⊨Q ◇ᵒ Q⊨R) Pa =  Pa ▷ P⊨Q ▷ Q⊨R

--------------------------------------------------------------------------------
-- ∀ᵒ˙, ∃ᵒ˙, ∀ᵒ˙', ∃ᵒ˙': Universal/existential quantification

-- For Set ℓ

∀ᵒ˙ ∃ᵒ˙ : (X → Propᵒ) →  Propᵒ
∀ᵒ˙ Pᵒ˙ .predᵒ a ✓a =  ∀ x →  Pᵒ˙ x .predᵒ a ✓a
∀ᵒ˙ Pᵒ˙ .monoᵒ =  proof
 where abstract
  proof :  Monoᵒ $ ∀ᵒ˙ Pᵒ˙ .predᵒ
  proof a⊑b ∀xPxa x =  Pᵒ˙ x .monoᵒ a⊑b (∀xPxa x)
∃ᵒ˙ Pᵒ˙ .predᵒ a ✓a =  ∑ x ,  Pᵒ˙ x .predᵒ a ✓a
∃ᵒ˙ Pᵒ˙ .monoᵒ =  proof
 where abstract
  proof :  Monoᵒ $ ∃ᵒ˙ Pᵒ˙ .predᵒ
  proof a⊑b (x , Pxa) =  x ,  Pᵒ˙ x .monoᵒ a⊑b Pxa

-- For Set (^ ℓ)

∀^˙ ∃^˙ :  (X^ → Propᵒ) →  Propᵒ
∀^˙ Pᵒ˙ .predᵒ a ✓a =  ∀ x →  Pᵒ˙ x .predᵒ a ✓a
∀^˙ Pᵒ˙ .monoᵒ =  proof
 where abstract
  proof :  Monoᵒ $ ∀^˙ Pᵒ˙ .predᵒ
  proof a⊑b ∀xPxa x =  Pᵒ˙ x .monoᵒ a⊑b (∀xPxa x)
∃^˙ Pᵒ˙ .predᵒ a ✓a =  ∑ x ,  Pᵒ˙ x .predᵒ a ✓a
∃^˙ Pᵒ˙ .monoᵒ =  proof
 where abstract
  proof :  Monoᵒ $ ∃^˙ Pᵒ˙ .predᵒ
  proof a⊑b (x , Pxa) =  x ,  Pᵒ˙ x .monoᵒ a⊑b Pxa

∀ᵒ∈-syntax ∃ᵒ∈-syntax ∀ᵒ-syntax ∃ᵒ-syntax :  (X → Propᵒ) →  Propᵒ
∀ᵒ∈-syntax =  ∀ᵒ˙
∃ᵒ∈-syntax =  ∃ᵒ˙
∀ᵒ-syntax =  ∀ᵒ˙
∃ᵒ-syntax =  ∃ᵒ˙
∀^∈-syntax ∃^∈-syntax ∀^-syntax ∃^-syntax :  (X^ → Propᵒ) →  Propᵒ
∀^∈-syntax =  ∀^˙
∃^∈-syntax =  ∃^˙
∀^-syntax =  ∀^˙
∃^-syntax =  ∃^˙

infix 3 ∀ᵒ∈-syntax ∃ᵒ∈-syntax ∀ᵒ-syntax ∃ᵒ-syntax
  ∀^∈-syntax ∃^∈-syntax ∀^-syntax ∃^-syntax
syntax ∀ᵒ∈-syntax {X = X} (λ x → Pᵒ) =  ∀ᵒ x ∈ X , Pᵒ
syntax ∃ᵒ∈-syntax {X = X} (λ x → Pᵒ) =  ∃ᵒ x ∈ X , Pᵒ
syntax ∀ᵒ-syntax (λ x → Pᵒ) =  ∀ᵒ x , Pᵒ
syntax ∃ᵒ-syntax (λ x → Pᵒ) =  ∃ᵒ x , Pᵒ
syntax ∀^∈-syntax {X^ = X^} (λ x → Pᵒ) =  ∀^ x ∈ X^ , Pᵒ
syntax ∃^∈-syntax {X^ = X^} (λ x → Pᵒ) =  ∃^ x ∈ X^ , Pᵒ
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

⌜_⌝^ :  Set (^ ℓ) →  Propᵒ
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

abstract

  ∙⊑-✓ˡ :  b ∙ c ⊑ a →  ✓ a →  ✓ b
  ∙⊑-✓ˡ b∙c⊑a ✓a =  ✓-mono (⊑-trans ∙-incrʳ b∙c⊑a) ✓a

  ∙⊑-✓ʳ :  b ∙ c ⊑ a →  ✓ a →  ✓ c
  ∙⊑-✓ʳ b∙c⊑a ✓a =  ✓-mono (⊑-trans ∙-incrˡ b∙c⊑a) ✓a

infixr 7 _∗ᵒ_
_∗ᵒ_ :  Propᵒ → Propᵒ → Propᵒ
(Pᵒ ∗ᵒ Qᵒ) .predᵒ a ✓a =  ∑ b , ∑ c , ∑ b∙c⊑a ,
  Pᵒ .predᵒ b (∙⊑-✓ˡ b∙c⊑a ✓a)  ×  Qᵒ .predᵒ c (∙⊑-✓ʳ b∙c⊑a ✓a)
(Pᵒ ∗ᵒ Qᵒ) .monoᵒ {✓a = ✓a} {✓b} =  proof {✓a = ✓a} {✓b}
 where abstract
  proof :  Monoᵒ $ (Pᵒ ∗ᵒ Qᵒ) .predᵒ
  proof a⊑a' (b , c , b∙c⊑a , Pd , Qe) =
    b , c , ⊑-trans b∙c⊑a a⊑a' , renewᵒ Pᵒ Pd , renewᵒ Qᵒ Qe

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

abstract

  ✓-remˡ :  ✓ a ∙ b →  ✓ b
  ✓-remˡ ✓a∙b =  ✓-mono ∙-incrˡ ✓a∙b

infix 8 |=>ᵒ_
|=>ᵒ_ :  Propᵒ → Propᵒ
(|=>ᵒ Pᵒ) .predᵒ a _ =  ∀ c →  ✓ c ∙ a →  ∑ b , ∑ ✓c∙b ,
  Pᵒ .predᵒ b (✓-remˡ {c} {b} ✓c∙b)
(|=>ᵒ Pᵒ) .monoᵒ {✓a = ✓a} {✓b} =  proof {✓a = ✓a} {✓b}
 where abstract
  proof :  Monoᵒ $ (|=>ᵒ Pᵒ) .predᵒ
  proof (d , d∙a≈b) |=>Pa e ✓e∙b  with
    |=>Pa (e ∙ d) $ flip ✓-resp ✓e∙b $ ∙-congʳ (◠˜ d∙a≈b) ◇˜ ∙-assocʳ
  ... | (c , ✓ed∙c , Pc) =  c , flip ✓-mono ✓ed∙c (∙-monoˡ ∙-incrʳ) ,
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
-- Own: Owning a resource

Own :  Glob →  Propᵒ
Own a .predᵒ b _ =  a ⊑ b
Own a .monoᵒ {✓a = ✓a} {✓b} =  proof {✓a = ✓a} {✓b}
 where abstract
  proof :  Monoᵒ $ Own a .predᵒ
  proof b⊑c a⊑b =  ⊑-trans a⊑b b⊑c

abstract

  Own-resp :  a ≈ b →  Own a ⊨ Own b
  Own-resp a≈b a⊑c =  ⊑-respˡ a≈b a⊑c

  Own-mono :  a ⊑ b →  Own b ⊨ Own a
  Own-mono a⊑b b⊑c =  ⊑-trans a⊑b b⊑c

  Own-∙⇒∗ :  Own (a ∙ b) ⊨ Own a ∗ᵒ Own b
  Own-∙⇒∗ a∙b⊑c =  _ , _ , a∙b⊑c , ⊑-refl , ⊑-refl

  Own-∗⇒∙ :  Own a ∗ᵒ Own b ⊨ Own (a ∙ b)
  Own-∗⇒∙ (_ , _ , a'∙b'⊑c , a⊑a' , b⊑b') =
    ⊑-trans (∙-mono a⊑a' b⊑b') a'∙b'⊑c

  Own-ε-intro :  Pᵒ ⊨ Own ε
  Own-ε-intro _ =  ε-min

  Own-⌞⌟-□ :  Own ⌞ a ⌟ ⊨ □ᵒ Own ⌞ a ⌟
  Own-⌞⌟-□ ⌞a⌟⊑b =  ⊑-respˡ ⌞⌟-idem $ ⌞⌟-mono ⌞a⌟⊑b

  Own-⌞⌟-□' :  ⌞ a ⌟ ≈ a →  Own a ⊨ □ᵒ Own a
  Own-⌞⌟-□' ⌞a⌟≈a a⊑b =  ⊑-respˡ ⌞a⌟≈a $ ⌞⌟-mono a⊑b

  own⇒✓ :  Own a ⊨ ⌜ ✓ a ⌝^
  own⇒✓ {✓a = ✓b} a⊑b =  ✓-mono a⊑b ✓b

  Own-↝ :  a ↝ b →  Own a ⊨ |=>ᵒ Own b
  Own-↝ {b = b} a↝b (c , c∙a≈a') d ✓d∙a' =  b , ✓d∙b , ⊑-refl
   where
    ✓d∙b :  ✓ d ∙ b
    ✓d∙b =  ✓-mono (∙-monoˡ ∙-incrʳ) $ a↝b (d ∙ c) $ flip ✓-resp ✓d∙a' $
      ∙-congʳ (◠˜ c∙a≈a') ◇˜ ∙-assocʳ

  Own-↝ˢ :  a ↝ˢ B →  Own a ⊨ |=>ᵒ (∃^ b , ⌜ b ∈ B ⌝^ ∧ᵒ Own b)
  Own-↝ˢ a↝B {✓a = ✓a'} (c , c∙a≈a') d ✓d∙a'  with a↝B (d ∙ c) $
    flip ✓-resp ✓d∙a' $ ∙-congʳ (◠˜ c∙a≈a') ◇˜ ∙-assocʳ
  ... | b , b∈B , ✓d∙cb =  b , ✓-mono (∙-monoˡ ∙-incrʳ) ✓d∙cb , b , b∈B , ⊑-refl
