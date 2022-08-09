--------------------------------------------------------------------------------
-- Resource Algebra
--------------------------------------------------------------------------------

{-# OPTIONS --without-K --safe #-}

module Syho.Model.RA where

open import Base.Level using (Level; _⊔ᴸ_; sucᴸ)
open import Base.Eq using (_≡_; refl)
open import Base.Func using (_$_; id; _▷_; flip; _∈_)
open import Base.Prod using (_×_; _,_; ∑-syntax)
open import Base.Setoid using (Setoid)

--------------------------------------------------------------------------------
-- Resource algebra (Unital)
record  RA ℓ ℓ≈ ℓ✓ : Set (sucᴸ (ℓ ⊔ᴸ ℓ≈ ⊔ᴸ ℓ✓))  where
  ------------------------------------------------------------------------------
  -- Fields
  infix 4 _≈_
  infix 3 ✓_
  infixr 7 _∙_
  infix 0 ◠˜_
  infixr -1 _◇˜_
  field
    -- Carrier set
    Car :  Set ℓ
    ----------------------------------------------------------------------------
    -- Equivalence
    _≈_ :  Car → Car → Set ℓ≈
    -- Validity
    ✓_ :  Car → Set ℓ✓
    -- Product
    _∙_ :  Car → Car → Car
    -- Unit
    ε :  Car
    -- Core
    ⌞_⌟ :  Car → Car
    ----------------------------------------------------------------------------
    -- ≈ is reflexive, symmetric and transitive
    refl˜ :  ∀ {a} →  a ≈ a
    ◠˜_ :  ∀ {a b} →  a ≈ b →  b ≈ a
    _◇˜_ :  ∀ {a b c} →  a ≈ b →  b ≈ c →  a ≈ c
    ----------------------------------------------------------------------------
    -- ∙ is congruent, unital with ε, commutative, and associative
    ∙-congˡ :  ∀ {a b c} →  a ≈ b →  a ∙ c ≈ b ∙ c
    ∙-unitˡ :  ∀ {a} →  ε ∙ a ≈ a
    ∙-comm :  ∀ {a b} →  a ∙ b ≈ b ∙ a
    ∙-assocˡ :  ∀ {a b c} →  (a ∙ b) ∙ c ≈ a ∙ (b ∙ c)
    ----------------------------------------------------------------------------
    -- ✓ respects ≈
    ✓-resp :  ∀ {a b} →  a ≈ b →  ✓ a →  ✓ b
    -- ✓ is kept after a resource is removed
    ✓-rem :  ∀ {a b} →  ✓ a ∙ b →  ✓ b
    -- ε satisfies ✓
    ✓-ε :  ✓ ε
    ----------------------------------------------------------------------------
    -- ⌞⌟ preserves ≈
    ⌞⌟-cong :  ∀ {a b} →  a ≈ b →  ⌞ a ⌟ ≈ ⌞ b ⌟
    -- When ⌞⌟'s argument gets added, ⌞⌟'s result gets added
    ⌞⌟-add :  ∀ {a b} →  ∑ b' ,  b' ∙ ⌞ a ⌟ ≈ ⌞ b ∙ a ⌟
    -- ⌞ a ⌟ is absorbed by a
    ⌞⌟-unitˡ :  ∀ {a} →  ⌞ a ⌟ ∙ a  ≈  a
    -- ⌞⌟ is idempotent
    ⌞⌟-idem :  ∀ {a} →  ⌞ ⌞ a ⌟ ⌟ ≈ ⌞ a ⌟

  -- Setoid structure
  setoid :  Setoid ℓ ℓ≈
  setoid =  record{ Car = Car; _≈_ = _≈_; refl˜ = refl˜; ◠˜_ = ◠˜_;
    _◇˜_ = _◇˜_ }
  open Setoid setoid public hiding (Car; _≈_; refl˜; ◠˜_; _◇˜_)

  private variable
    a a' b b' c d :  Car
    ℓA ℓB ℓB' ℓC ℓD ℓE :  Level
    A :  Car → Set ℓA
    B :  Car → Set ℓB
    B' :  Car → Set ℓB'
    C :  Car → Set ℓC
    D :  Car → Set ℓD
    E :  Car → Set ℓE

  ------------------------------------------------------------------------------
  -- Utility lemmas
  abstract

    -- Congruence, unitality and associativity

    ∙-congʳ :  a ≈ b →  c ∙ a ≈ c ∙ b
    ∙-congʳ a≈b =  ∙-comm ◇˜ ∙-congˡ a≈b ◇˜ ∙-comm

    ∙-cong :  a ≈ b →  c ≈ d →  a ∙ c ≈ b ∙ d
    ∙-cong a≈b c≈d =  ∙-congˡ a≈b ◇˜ ∙-congʳ c≈d

    ∙-unitʳ :  a ∙ ε ≈ a
    ∙-unitʳ =  ∙-comm ◇˜ ∙-unitˡ

    ∙-assocʳ :  a ∙ (b ∙ c) ≈ (a ∙ b) ∙ c
    ∙-assocʳ =  ◠˜ ∙-assocˡ

    -- Variant of ⌞⌟-unitˡ

    ⌞⌟-unitʳ :  a ∙ ⌞ a ⌟ ≈ a
    ⌞⌟-unitʳ =  ∙-comm ◇˜ ⌞⌟-unitˡ

    -- ⌞ ⌟ can be duplicated

    ⌞⌟-dup :  ⌞ a ⌟ ∙ ⌞ a ⌟ ≈ ⌞ a ⌟
    ⌞⌟-dup =  ∙-congˡ (◠˜ ⌞⌟-idem) ◇˜ ⌞⌟-unitˡ

    -- ⌞ ε ⌟ is ε

    ⌞⌟-ε :  ⌞ ε ⌟ ≈ ε
    ⌞⌟-ε =  ◠˜ ∙-unitʳ ◇˜ ⌞⌟-unitˡ

  ------------------------------------------------------------------------------
  -- ⊑: Derived pre-order

  infix 4 _⊑_
  _⊑_ :  Car → Car → Set (ℓ ⊔ᴸ ℓ≈)
  a ⊑ b =  ∑ c ,  c ∙ a  ≈  b

  abstract

    -- ⊑ is reflexive

    ≈⇒⊑ :  a ≈ b →  a ⊑ b
    ≈⇒⊑ a≈b =  ε , ∙-unitˡ ◇˜ a≈b

    ⊑-refl :  a ⊑ a
    ⊑-refl =  ≈⇒⊑ refl˜

    -- ⊑ is transitive

    ⊑-trans :  a ⊑ b →  b ⊑ c →  a ⊑ c
    ⊑-trans (d , d∙a≈b) (e , e∙b≈c) =  d ∙ e ,
      ∙-congˡ ∙-comm ◇˜ ∙-assocˡ ◇˜ ∙-congʳ d∙a≈b ◇˜ e∙b≈c

    -- ⊑ respects ≈

    ⊑-resp :  a ≈ b →  c ≈ d →  a ⊑ c →  b ⊑ d
    ⊑-resp a≈b c≈d (e , e∙a≈c) =  e , ∙-congʳ (◠˜ a≈b) ◇˜ e∙a≈c ◇˜ c≈d

    ⊑-respˡ :  a ≈ b →  a ⊑ c →  b ⊑ c
    ⊑-respˡ a≈b a⊑c =  ⊑-resp a≈b refl˜ a⊑c

    ⊑-respʳ :  ∀ {a b c} →  b ≈ c →  a ⊑ b →  a ⊑ c
    ⊑-respʳ b≈c a⊑b =  ⊑-resp refl˜ b≈c a⊑b

    -- ε is the minimum

    ε-min :  ε ⊑ a
    ε-min =  _ , ∙-unitʳ

    -- ∙ is increasing

    ∙-incrˡ :  a  ⊑  b ∙ a
    ∙-incrˡ =  _ , refl˜

    ∙-incrʳ :  a  ⊑  a ∙ b
    ∙-incrʳ =  ⊑-respʳ ∙-comm ∙-incrˡ

    -- Monotonicity of ✓, ∙ and ⌞⌟

    ✓-mono :  a ⊑ b →  ✓ b →  ✓ a
    ✓-mono (c , c∙a≈b) ✓b =  ✓b ▷ ✓-resp (◠˜ c∙a≈b) ▷ ✓-rem

    ∙-monoˡ :  a ⊑ b →  a ∙ c  ⊑  b ∙ c
    ∙-monoˡ (d , d∙a≈b) =  d , ∙-assocʳ ◇˜ ∙-congˡ d∙a≈b

    ∙-monoʳ :  a ⊑ b →  c ∙ a  ⊑  c ∙ b
    ∙-monoʳ a⊑b =  ⊑-resp ∙-comm ∙-comm $ ∙-monoˡ a⊑b

    ∙-mono :  a ⊑ b →  c ⊑ d →  a ∙ c  ⊑  b ∙ d
    ∙-mono a⊑b c⊑d =  ⊑-trans (∙-monoˡ a⊑b) (∙-monoʳ c⊑d)

    ⌞⌟-mono :  a ⊑ b →  ⌞ a ⌟ ⊑ ⌞ b ⌟
    ⌞⌟-mono (c , c∙a≈b)  with ⌞⌟-add {_} {c}
    ... | c' , c'∙⌞a⌟≈⌞c∙a⌟ =  c' , c'∙⌞a⌟≈⌞c∙a⌟ ◇˜ ⌞⌟-cong c∙a≈b

    -- ⌞ ⌟ is decreasing

    ⌞⌟-decr :  ⌞ a ⌟ ⊑ a
    ⌞⌟-decr =  ⊑-respʳ ⌞⌟-unitˡ ∙-incrʳ

    -- ⌞ ⌟ and ∙ commute weakly

    ⌞⌟-∙ :  ⌞ a ⌟ ∙ ⌞ b ⌟ ⊑ ⌞ a ∙ b ⌟
    ⌞⌟-∙ =  ⊑-respʳ ⌞⌟-dup $ ∙-mono (⌞⌟-mono ∙-incrʳ) (⌞⌟-mono ∙-incrˡ)

    -- ✓ a implies ✓ ⌞ a ⌟

    ✓-⌞⌟ :  ✓ a →  ✓ ⌞ a ⌟
    ✓-⌞⌟ ✓a =  ✓-mono ⌞⌟-decr ✓a

  ------------------------------------------------------------------------------
  -- ↝/↝ˢ : Resource update

  infix 2 _↝_ _↝ˢ_

  -- a ↝ b : a can be updated into b, regardless of the frame c
  _↝_ :  Car → Car → Set (ℓ ⊔ᴸ ℓ✓)
  a ↝ b =  ∀ c →  ✓ c ∙ a →  ✓ c ∙ b

  -- a ↝ˢ B : a can be updated into b, regardless of the frame c
  _↝ˢ_ :  Car →  (Car → Set ℓB) →  Set (ℓ ⊔ᴸ ℓ✓ ⊔ᴸ ℓB)
  a ↝ˢ B =  ∀ c →  ✓ c ∙ a →  ∑ b ,  b ∈ B  ×  ✓ c ∙ b

  abstract

    -- ↝ into ↝ˢ
    ↝⇒↝ˢ :  a ↝ b →  a ↝ˢ (b ≡_)
    ↝⇒↝ˢ {b = b} a↝b c ✓c∙a =  b , refl , a↝b c ✓c∙a

    -- ↝ respects ≈

    ↝-resp :  a ≈ a' →  b ≈ b' →  a ↝ b →  a' ↝ b'
    ↝-resp a≈a' b≈b' a↝b c ✓c∙a' =  ✓c∙a' ▷
      ✓-resp (∙-congʳ $ ◠˜ a≈a') ▷ a↝b c ▷ ✓-resp (∙-congʳ b≈b')

    ↝-respˡ :  a ≈ a' →  a ↝ b →  a' ↝ b
    ↝-respˡ a≈a' =  ↝-resp a≈a' refl˜

    ↝-respʳ :  b ≈ b' →  a ↝ b →  a ↝ b'
    ↝-respʳ b≈b' =  ↝-resp refl˜ b≈b'

    -- ↝ˢ respects ≈ and ⊆≈

    ↝ˢ-resp :  a ≈ a' →  B ⊆≈ B' →  a ↝ˢ B →  a' ↝ˢ B'
    ↝ˢ-resp a≈a' B⊆≈B' a↝ˢB c ✓c∙a'
      with  ✓c∙a' ▷ ✓-resp (∙-congʳ $ ◠˜ a≈a') ▷ a↝ˢB c
    ... | b , b∈B , ✓c∙b  with  B⊆≈B' b∈B
    ...   | b' , b≈b' , b'∈B' =  b' , b'∈B' , ✓-resp (∙-congʳ b≈b') ✓c∙b

    ↝ˢ-respˡ :  a ≈ a' →  a ↝ˢ B →  a' ↝ˢ B
    ↝ˢ-respˡ a≈a' =  ↝ˢ-resp a≈a' ⊆≈-refl

    ↝ˢ-respʳ :  B ⊆≈ B' →  a ↝ˢ B →  a ↝ˢ B'
    ↝ˢ-respʳ =  ↝ˢ-resp refl˜

    -- ↝ is reflexive and transitive

    ↝-refl :  a ↝ a
    ↝-refl _ =  id

    ↝-trans :  a ↝ b →  b ↝ c →  a ↝ c
    ↝-trans a↝b b↝c d ✓d∙a =  ✓d∙a ▷ a↝b d ▷ b↝c d

    -- ↝ and ↝ˢ can be composed

    ↝-↝ˢ :  a ↝ b →  b ↝ˢ C →  a ↝ˢ C
    ↝-↝ˢ a↝b b↝ˢC d ✓d∙a =  ✓d∙a ▷ a↝b d ▷ b↝ˢC d

    -- ↝/↝ˢ can be merged with respect to ∙

    ∙-mono-↝ :  a ↝ b →  c ↝ d →  a ∙ c  ↝  b ∙ d
    ∙-mono-↝ a↝b c↝d e ✓e∙a∙c =  ✓e∙a∙c ▷ ✓-resp ∙-assocʳ ▷
      c↝d _ ▷ ✓-resp (∙-assocˡ ◇˜ ∙-congʳ ∙-comm ◇˜ ∙-assocʳ) ▷
      a↝b _ ▷ ✓-resp (∙-assocˡ ◇˜ ∙-congʳ ∙-comm)

    ∙-mono-↝ˢ :  a ↝ˢ B →  c ↝ˢ D  →
      (∀ {b d} →  b ∈ B →  d ∈ D →  ∑ e ,  e ≈ b ∙ d  ×  e ∈ E) →  a ∙ c ↝ˢ E
    ∙-mono-↝ˢ a↝ˢB c↝ˢD BDE f ✓f∙a∙c  with ✓f∙a∙c ▷ ✓-resp ∙-assocʳ ▷ c↝ˢD _
    ... | d , d∈D , ✓f∙a∙d  with  ✓f∙a∙d ▷
      ✓-resp (∙-assocˡ ◇˜ ∙-congʳ ∙-comm ◇˜ ∙-assocʳ) ▷ a↝ˢB _
    ...   | b , b∈B , ✓f∙d∙b  with  BDE b∈B d∈D
    ...     | e , e≈b∙d , e∈E =  e , e∈E , flip ✓-resp ✓f∙d∙b $
      ∙-assocˡ ◇˜ ∙-congʳ $ ∙-comm ◇˜ ◠˜ e≈b∙d
