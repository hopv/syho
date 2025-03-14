--------------------------------------------------------------------------------
-- Positive natural number
--------------------------------------------------------------------------------

{-# OPTIONS --without-K --safe #-}

module Base.Natp where

open import Base.Func using (_$_; _∘_)
open import Base.Few using (¬_; absurd)
open import Base.Eq using (_≡_; refl; ◠_; _◇_; cong; cong₂; subst; subst₂)
open import Base.Dec using (Dec; yes; no; ≡Dec; _≟_)
open import Base.Sum using (_⨿_; ĩ₀_; ĩ₁_)
open import Base.Nat using (ℕ; ṡ_; _≤_; _<_; _+_; _*_; ṡ≤ṡ; ṡ<ṡ; ≤-refl;
  ≤-trans; ≤-antisym; <-irrefl; <-trans; <-asym; <⇒≤; ≤-<-trans; <-≤-trans;
  ≤⇒¬>; ṡ≤ṡ⁻¹; ṡ<ṡ⁻¹; ṡ-sincr; _<≡>_; _≤>_; +-comm; +-assocʳ; +-injˡ; +-0;
  +-incrˡ; +-monoˡ; +-smonoʳ; *-comm; *-assocʳ; *-injˡ; *-+-distrˡ; *-monoˡ;
  *-smonoˡ)

--------------------------------------------------------------------------------
-- ℕ⁺ :  Positive natural number

infix 10 ṡ⁺_
record  ℕ⁺ :  Set₀  where
  constructor ṡ⁺_
  infix 10 ṡ⁺⁻¹_
  field  ṡ⁺⁻¹_ :  ℕ

private variable
  k l m n :  ℕ⁺

--------------------------------------------------------------------------------
-- 1⁺, 2⁺, 3⁺, 4⁺, 5⁺ :  Numbers in ℕ⁺

1⁺ 2⁺ 3⁺ 4⁺ 5⁺ :  ℕ⁺
1⁺ =  ṡ⁺ 0
2⁺ =  ṡ⁺ 1
3⁺ =  ṡ⁺ 2
4⁺ =  ṡ⁺ 3
5⁺ =  ṡ⁺ 4

instance

  -- ℕ⁺ is inhabited

  ℕ⁺-Dec :  Dec ℕ⁺
  ℕ⁺-Dec =  yes 1⁺

--------------------------------------------------------------------------------
-- ℕ⁺⇒ℕ :  Back to ℕ

ℕ⁺⇒ℕ :  ℕ⁺ →  ℕ
ℕ⁺⇒ℕ (ṡ⁺ n⁰) =  ṡ n⁰

abstract

  -- ℕ⁺⇒ℕ is injective

  ℕ⁺⇒ℕ-inj :  ℕ⁺⇒ℕ m ≡ ℕ⁺⇒ℕ n →  m ≡ n
  ℕ⁺⇒ℕ-inj refl =  refl

--------------------------------------------------------------------------------
-- ≤⁺, <⁺, ≥⁺, >⁺ :  Order

infix 4 _≤⁺_ _<⁺_ _≥⁺_ _>⁺_
_≤⁺_ _<⁺_ _≥⁺_ _>⁺_ :  ℕ⁺ → ℕ⁺ → Set₀
ṡ⁺ m⁰ ≤⁺ ṡ⁺ n⁰ =  m⁰ ≤ n⁰
ṡ⁺ m⁰ <⁺ ṡ⁺ n⁰ =  m⁰ < n⁰
p ≥⁺ q =  q ≤⁺ p
p >⁺ q =  q <⁺ p

abstract

  -- ≤⁺ is reflexive

  ≤⁺-refl :  n ≤⁺ n
  ≤⁺-refl =  ≤-refl

  ≡⇒≤⁺ :  m ≡ n →  m ≤⁺ n
  ≡⇒≤⁺ refl =  ≤⁺-refl

  -- ≤⁺ is transitive

  ≤⁺-trans :  l ≤⁺ m →  m ≤⁺ n →  l ≤⁺ n
  ≤⁺-trans =  ≤-trans

  -- ≤⁺ is antisymmetric

  ≤⁺-antisym :  m ≤⁺ n →  n ≤⁺ m →  m ≡ n
  ≤⁺-antisym mᵒ≤nᵒ nᵒ≤mᵒ =  cong ṡ⁺_ $ ≤-antisym mᵒ≤nᵒ nᵒ≤mᵒ

  -- <⁺ is irreflexive

  <⁺-irrefl :  ¬ n <⁺ n
  <⁺-irrefl =  <-irrefl

  ≡⇒¬<⁺ :  m ≡ n →  ¬ m <⁺ n
  ≡⇒¬<⁺ refl =  <⁺-irrefl

  -- <⁺ is transitive

  <⁺-trans :  l <⁺ m →  m <⁺ n →  l <⁺ n
  <⁺-trans =  <-trans

  -- <⁺ is asymmetric

  <⁺-asym :  m <⁺ n →  ¬ m >⁺ n
  <⁺-asym =  <-asym

  -- <⁺ into ≤⁺

  <⁺⇒≤⁺ :  m <⁺ n →  m ≤⁺ n
  <⁺⇒≤⁺ =  <⇒≤

  -- Compose ≤⁺ and <⁺

  ≤⁺-<⁺-trans :  l ≤⁺ m →  m <⁺ n →  l <⁺ n
  ≤⁺-<⁺-trans =   ≤-<-trans

  <⁺-≤⁺-trans :  l <⁺ m →  m ≤⁺ n →  l <⁺ n
  <⁺-≤⁺-trans =  <-≤-trans

  -- ≤⁺ and >⁺ do not hold at the same time

  ≤⁺⇒¬>⁺ :  m ≤⁺ n →  ¬ m >⁺ n
  ≤⁺⇒¬>⁺ =  ≤⇒¬>

  <⁺⇒¬≥⁺ :  m <⁺ n →  ¬ m ≥⁺ n
  <⁺⇒¬≥⁺ m<n m≥n =  ≤⁺⇒¬>⁺ m≥n m<n

  infix 4 _<≡>⁺_ _≤>⁺_ _<≥⁺_

  -- Get <⁺, ≡ or >⁺

  _<≡>⁺_ :  ∀ m n →  m <⁺ n  ⨿  m ≡ n  ⨿  m >⁺ n
  ṡ⁺ m⁰ <≡>⁺ ṡ⁺ n⁰  with m⁰ <≡> n⁰
  … | ĩ₀ m⁰<n⁰ =  ĩ₀ m⁰<n⁰
  … | ĩ₁ ĩ₀ refl =  ĩ₁ ĩ₀ refl
  … | ĩ₁ ĩ₁ m⁰>n⁰ =  ĩ₁ ĩ₁ m⁰>n⁰

  -- Get ≤⁺ or >⁺

  _≤>⁺_ :  ∀ m n →  m ≤⁺ n  ⨿  m >⁺ n
  ṡ⁺ m⁰ ≤>⁺ ṡ⁺ n⁰  with m⁰ ≤> n⁰
  … | ĩ₀ m⁰≤n⁰ =  ĩ₀ m⁰≤n⁰
  … | ĩ₁ m⁰>n⁰ =  ĩ₁ m⁰>n⁰

  -- Get <⁺ or ≥⁺

  _<≥⁺_ :  ∀ m n →  m <⁺ n  ⨿  m ≥⁺ n
  m <≥⁺ n  with n ≤>⁺ m
  … | ĩ₀ n≤m =  ĩ₁ n≤m
  … | ĩ₁ n>m =  ĩ₀ n>m

--------------------------------------------------------------------------------
-- Equality decision for ℕ⁺

instance

  ℕ⁺-≡Dec : ≡Dec ℕ⁺
  ℕ⁺-≡Dec ._≟_ (ṡ⁺ m⁰) (ṡ⁺ n⁰)  with m⁰ ≟ n⁰
  … | yes refl =  yes refl
  … | no m⁰≢n⁰ =  no λ{ refl → m⁰≢n⁰ refl }

--------------------------------------------------------------------------------
-- +⁺ :  Addition

infixl 6 _+⁺_
_+⁺_ :  ℕ⁺ → ℕ⁺ → ℕ⁺
ṡ⁺ m⁰ +⁺ ṡ⁺ n⁰ =  ṡ⁺ (m⁰ + ṡ n⁰)
-- Defined so because ṡ m⁰ + ṡ n⁰ reduces to ṡ (m⁰ + ṡ n⁰)

abstract

  -- +⁺ is commutative

  +⁺-comm :  m +⁺ n ≡ n +⁺ m
  +⁺-comm {ṡ⁺ m⁰} =  ℕ⁺⇒ℕ-inj $ +-comm {ṡ m⁰}

  -- +⁺ is associative

  +⁺-assocʳ :  (l +⁺ m) +⁺ n ≡ l +⁺ (m +⁺ n)
  +⁺-assocʳ {ṡ⁺ l⁰} =  ℕ⁺⇒ℕ-inj $ +-assocʳ {ṡ l⁰}

  +⁺-assocˡ :  l +⁺ (m +⁺ n) ≡ (l +⁺ m) +⁺ n
  +⁺-assocˡ =  ◠ +⁺-assocʳ

  -- +⁺ is injective

  +⁺-injˡ :  ∀{l m n} →  m +⁺ l ≡ n +⁺ l →  m ≡ n
  +⁺-injˡ {ṡ⁺ l⁰} m+l≡n+l =  ℕ⁺⇒ℕ-inj $ +-injˡ $ cong ℕ⁺⇒ℕ m+l≡n+l

  +⁺-injʳ :  l +⁺ m ≡ l +⁺ n →  m ≡ n
  +⁺-injʳ {l} {m} {n}  rewrite +⁺-comm {l} {m} | +⁺-comm {l} {n} =  +⁺-injˡ

  -- +⁺ strictly increases

  +⁺-sincrˡ :  ∀{m n} →  n <⁺ m +⁺ n
  +⁺-sincrˡ =  ≤-<-trans +-incrˡ (+-smonoʳ ṡ-sincr)

  +⁺-sincrʳ :  m <⁺ m +⁺ n
  +⁺-sincrʳ {m} =  subst (m <⁺_) +⁺-comm +⁺-sincrˡ

  +⁺-incrˡ :  ∀{m n} →  n ≤⁺ m +⁺ n
  +⁺-incrˡ =  <⁺⇒≤⁺ +⁺-sincrˡ

  +⁺-incrʳ :  m ≤⁺ m +⁺ n
  +⁺-incrʳ =  <⁺⇒≤⁺ +⁺-sincrʳ

  -- +⁺ is monotone

  +⁺-monoˡ :  l ≤⁺ m →  l +⁺ n ≤⁺ m +⁺ n
  +⁺-monoˡ =  +-monoˡ

  +⁺-monoʳ :  ∀{l m n} →  m ≤⁺ n →  l +⁺ m ≤⁺ l +⁺ n
  +⁺-monoʳ {l} {m} {n} m≤n =  subst₂ _≤⁺_ +⁺-comm +⁺-comm $ +⁺-monoˡ m≤n

  +⁺-mono :  k ≤⁺ l →  m ≤⁺ n →  k +⁺ m ≤⁺ l +⁺ n
  +⁺-mono k≤l m≤n =  ≤⁺-trans (+⁺-monoˡ k≤l) (+⁺-monoʳ m≤n)

  -- + is strictly monotone

  +⁺-smonoˡ :  l <⁺ m →  l +⁺ n <⁺ m +⁺ n
  +⁺-smonoˡ =  +-monoˡ

  +⁺-smonoʳ :  ∀{l m n} →  m <⁺ n →  l +⁺ m <⁺ l +⁺ n
  +⁺-smonoʳ {l} {m} {n} m<n =  subst₂ _<⁺_ +⁺-comm +⁺-comm $ +⁺-smonoˡ m<n

  +⁺-smono :  k <⁺ l →  m <⁺ n →  k +⁺ m <⁺ l +⁺ n
  +⁺-smono k<l m<n =  <⁺-trans (+⁺-smonoˡ k<l) (+⁺-smonoʳ m<n)

--------------------------------------------------------------------------------
-- *⁺ :  Multiplication

infixl 7 _*⁺_
_*⁺_ :  ℕ⁺ → ℕ⁺ → ℕ⁺
ṡ⁺ m⁰ *⁺ ṡ⁺ n⁰ =  ṡ⁺ (n⁰ + m⁰ * ṡ n⁰)
-- Defined so because ṡ m⁰ * ṡ n⁰ reduces to ṡ (n⁰ + m⁰ * ṡ n⁰)

abstract

  -- *⁺ is commutative

  *⁺-comm :  m *⁺ n ≡ n *⁺ m
  *⁺-comm {ṡ⁺ m⁰} =  ℕ⁺⇒ℕ-inj $ *-comm {ṡ m⁰}

  -- *⁺ is associative

  *⁺-assocʳ :  (l *⁺ m) *⁺ n ≡ l *⁺ (m *⁺ n)
  *⁺-assocʳ {ṡ⁺ l⁰} {ṡ⁺ m⁰} =  ℕ⁺⇒ℕ-inj $ *-assocʳ {ṡ l⁰} {ṡ m⁰}

  *⁺-assocˡ :  l *⁺ (m *⁺ n) ≡ (l *⁺ m) *⁺ n
  *⁺-assocˡ {l} {m} =  ◠ *⁺-assocʳ {l} {m}

  -- Commutativity of *⁺ as an action

  ?*⁺-comm :  l *⁺ (m *⁺ n) ≡ m *⁺ (l *⁺ n)
  ?*⁺-comm {l} {m} {n} =  *⁺-assocˡ {l} {m} {n} ◇
      cong (_*⁺ n) (*⁺-comm {l} {m}) ◇ *⁺-assocʳ {m} {l} {n}

  *⁺?-comm :  (l *⁺ m) *⁺ n ≡ (l *⁺ n) *⁺ m
  *⁺?-comm {l} {m} {n} =  *⁺-assocʳ {l} {m} {n} ◇
      cong (l *⁺_) (*⁺-comm {m} {n}) ◇ *⁺-assocˡ {l} {n} {m}

  -- *⁺ is injective

  *⁺-injˡ :  ∀{l m n} →  m *⁺ l ≡ n *⁺ l →  m ≡ n
  *⁺-injˡ m*l≡n*l =  ℕ⁺⇒ℕ-inj $ *-injˡ _ $ cong ℕ⁺⇒ℕ m*l≡n*l

  *⁺-injʳ :  l *⁺ m ≡ l *⁺ n →  m ≡ n
  *⁺-injʳ {l} {m} {n}  rewrite *⁺-comm {l} {m} | *⁺-comm {l} {n} =  *⁺-injˡ

  -- *⁺ is distributive over +⁺

  *⁺-+⁺-distrˡ :  (l +⁺ m) *⁺ n ≡ l *⁺ n +⁺ m *⁺ n
  *⁺-+⁺-distrˡ {ṡ⁺ l⁰} =  ℕ⁺⇒ℕ-inj $ *-+-distrˡ {ṡ l⁰}

  *⁺-+⁺-distrʳ :  l *⁺ (m +⁺ n) ≡ l *⁺ m +⁺ l *⁺ n
  *⁺-+⁺-distrʳ {l} {m} {n} =  *⁺-comm {l} ◇ *⁺-+⁺-distrˡ {m} ◇
    cong₂ _+⁺_ (*⁺-comm {m}) (*⁺-comm {n})

  -- *⁺ is unital with the unit 1⁺

  *⁺-1ˡ :  1⁺ *⁺ n ≡ n
  *⁺-1ˡ =  cong ṡ⁺_ +-0

  *⁺-1ʳ :  n *⁺ 1⁺ ≡ n
  *⁺-1ʳ {n}  rewrite *⁺-comm {n} {1⁺} =  *⁺-1ˡ {n}

  -- Simplify *⁺ with 2

  *⁺-2ˡ :  2⁺ *⁺ n ≡ n +⁺ n
  *⁺-2ˡ {ṡ⁺ n⁰} =  cong (ṡ⁺_ ∘ (n⁰ +_)) +-0

  *⁺-2ʳ :  n *⁺ 2⁺ ≡ n +⁺ n
  *⁺-2ʳ {n}  rewrite *⁺-comm {n} {2⁺} =  *⁺-2ˡ {n}

  -- *⁺ is monotone

  *⁺-monoˡ :  l ≤⁺ m →  l *⁺ n ≤⁺ m *⁺ n
  *⁺-monoˡ {ṡ⁺ l⁰} {ṡ⁺ m⁰} {ṡ⁺ n⁰} l⁰≤m⁰ =
    ṡ≤ṡ⁻¹ $ *-monoˡ {ṡ l⁰} {ṡ m⁰} {ṡ n⁰} $ ṡ≤ṡ l⁰≤m⁰

  *⁺-monoʳ :  ∀{l m n} →  m ≤⁺ n →  l *⁺ m ≤⁺ l *⁺ n
  *⁺-monoʳ {l} {m} {n} m≤n =  subst₂ _≤⁺_ (*⁺-comm {m} {l}) (*⁺-comm {n} {l})
    (*⁺-monoˡ m≤n)

  *⁺-mono :  k ≤⁺ l →  m ≤⁺ n →  k *⁺ m ≤⁺ l *⁺ n
  *⁺-mono {l = l} k≤l m≤n =  ≤⁺-trans (*⁺-monoˡ k≤l) (*⁺-monoʳ {l} m≤n)

  -- *⁺ is strictly monotone

  *⁺-smonoˡ :  l <⁺ m →  l *⁺ n <⁺ m *⁺ n
  *⁺-smonoˡ {ṡ⁺ l⁰} {ṡ⁺ m⁰} {ṡ⁺ n⁰} l⁰<m⁰ =
    ṡ<ṡ⁻¹ $ *-smonoˡ {ṡ n⁰} {ṡ l⁰} {ṡ m⁰} _ $ ṡ<ṡ l⁰<m⁰

  *⁺-smonoʳ :  ∀{l m n} →  m <⁺ n →  l *⁺ m <⁺ l *⁺ n
  *⁺-smonoʳ {l} {m} {n} m<n =  subst₂ _<⁺_ (*⁺-comm {m} {l}) (*⁺-comm {n} {l})
    (*⁺-smonoˡ m<n)

  *⁺-smono :  k <⁺ l →  m <⁺ n →  k *⁺ m <⁺ l *⁺ n
  *⁺-smono {l = l} k<l m<n =  <⁺-trans (*⁺-smonoˡ k<l) (*⁺-smonoʳ {l} m<n)

  -- Divide both sides of ≤

  *⁺-monoˡ-inv :  ∀{l m n} →  m *⁺ l ≤⁺ n *⁺ l →  m ≤⁺ n
  *⁺-monoˡ-inv {_} {m} {n} ml≤nl  with m ≤>⁺ n
  … | ĩ₀ m≤n =  m≤n
  … | ĩ₁ m>n =  absurd $ ≤⁺⇒¬>⁺ ml≤nl $ *⁺-smonoˡ m>n

  *⁺-monoʳ-inv :  l *⁺ m ≤⁺ l *⁺ n →  m ≤⁺ n
  *⁺-monoʳ-inv {l} {m} {n} lm≤ln =
    *⁺-monoˡ-inv $ subst₂ _≤⁺_ (*⁺-comm {l} {m}) (*⁺-comm {l} {n}) lm≤ln

  -- Divide both sides of <

  *⁺-smonoˡ-inv :  ∀{l m n} →  m *⁺ l <⁺ n *⁺ l →  m <⁺ n
  *⁺-smonoˡ-inv {_} {m} {n} ml<nl  with m <≥⁺ n
  … | ĩ₀ m<n =  m<n
  … | ĩ₁ m≥n =  absurd $ <⁺⇒¬≥⁺ ml<nl $ *⁺-monoˡ m≥n

  *⁺-smonoʳ-inv :  l *⁺ m <⁺ l *⁺ n →  m <⁺ n
  *⁺-smonoʳ-inv {l} {m} {n} lm<ln =
    *⁺-smonoˡ-inv $ subst₂ _<⁺_ (*⁺-comm {l} {m}) (*⁺-comm {l} {n}) lm<ln
