--------------------------------------------------------------------------------
-- Reduction
--------------------------------------------------------------------------------

{-# OPTIONS --without-K --sized-types #-}

open import Base.Level using (Level)
module Shog.Lang.Reduce (ℓ : Level) where

open import Base.Level using (Up; ^_; ↑_)
open import Base.Size using (Size; ∞)
open import Base.Thunk using (!)
open import Base.Func using (_$_; id)
open import Base.Few using (⊤)
open import Base.Prod using (∑-syntax; _×_; _,_)
open import Base.Sum using (_⊎_; inj₀; inj₁)
open import Base.Option using (??_)
open import Base.Bool using (tt; ff)
open import Base.Nat using (ℕ; _≡ᵇ_)
open import Base.List using (List; [])
open import Base.List.Nat using (_!!_; upd; repeat)
open import Base.Option using (some)
open import Base.Eq using (_≡_)
open import Shog.Lang.Expr ℓ using (Type; ◸_; _→*_; Addr; addr; Expr; ▶_; ∇_;
  λ˙; _◁_; ★_; _←_; alloc; free; Val; Val⇒Expr)

private variable
  A :  Set ℓ
  T U V :  Type

-------------------------------------------------------------------------------
-- Redex

infix 6 ▶ᴿ_
infixl 5 _◁ᴿ_
infix 6 ★ᴿ_ _←ᴿ_

data  Redex :  Type →  Set (^ ℓ)  where
  ▶ᴿ_ :  Expr ∞ T →  Redex T
  _◁ᴿ_ :  (A → Expr ∞ T) →  A →  Redex T
  ★ᴿ_ :  Addr →  Redex T
  _←ᴿ_ :  Addr →  Val T →  Redex (◸ ⊤)
  allocᴿ :  ℕ →  Redex (◸ Up Addr)
  freeᴿ :  Addr →  Redex (◸ ⊤)

--------------------------------------------------------------------------------
-- Memory

-- Memory cell, containing a value of any type T, parametrized over

MemCell :  Set (^ ℓ)
MemCell =  ∑ T , Val T

-- Memory, consisting of memory blocks, which are a list of memory cells

Mem :  Set (^ ℓ)
Mem =  ℕ →  List MemCell

-- Memory read

_!!ᴹ_ :  Mem →  Addr →  ?? MemCell
M !!ᴹ addr b i =  M b !! i

-- Memory block update

updᴹᴮ :  ℕ →  List MemCell →  Mem →  Mem
updᴹᴮ b cs M b'  with b' ≡ᵇ b
... | tt =  cs
... | ff =  M b'

-- Memory update

updᴹ :  Addr →  MemCell →  Mem →  Mem
updᴹ (addr b i) c M =  updᴹᴮ b (upd i c $ M b) M

--------------------------------------------------------------------------------
-- Value & Context-Redex Pair

-- Type for a context-redex pair

Ctxred :  Type →  Set (^ ℓ)
Ctxred T =  ∑ U , (Expr ∞ U → Expr ∞ T) × Redex U

-- Type for either a value or a context-redex pair

Val/Ctxred :  Type →  Set (^ ℓ)
Val/Ctxred T =  Val T ⊎ Ctxred T

-- Calculate the value or context-redex pair of the expression

val/ctxred :  Expr ∞ T →  Val/Ctxred T
val/ctxred (∇ a) =  inj₀ $ ↑ a
val/ctxred (λ˙ e˙) =  inj₀ $ e˙
val/ctxred (▶ e˂) =  inj₁ $ _ , id , ▶ᴿ (e˂ .!)
val/ctxred (e ◁ e')  with val/ctxred e'
... | inj₁ (_ , ctx , red) =  inj₁ $ _ , (λ • → e ◁ ctx •) , red
... | inj₀ (↑ a)  with val/ctxred e
...   | inj₁ (_ , ctx , red) =  inj₁ $ _ , (λ • → ctx • ◁ e') , red
...   | inj₀ v =  inj₁ $ _ , id , v ◁ᴿ a
val/ctxred (★ e)  with val/ctxred e
... | inj₁ (_ , ctx , red) =  inj₁ $ _ , (λ • → ★ ctx •) , red
... | inj₀ (↑ ↑ x) =  inj₁ $ _ , id , ★ᴿ x
val/ctxred (e ← e')  with  val/ctxred e'
... | inj₁ (_ , ctx , red) =  inj₁ $ _ , (λ • → e ← ctx •) , red
... | inj₀ v  with val/ctxred e
...   | inj₁ (_ , ctx , red) =  inj₁ $ _ , (λ • → ctx • ← e') , red
...   | inj₀ (↑ ↑ x) =  inj₁ $ _ , id , x ←ᴿ v
val/ctxred (alloc e)  with val/ctxred e
... | inj₁ (_ , ctx , red) =  inj₁ $ _ , (λ • → alloc $ ctx •) , red
... | inj₀ (↑ ↑ n) =  inj₁ $ _ , id , allocᴿ n
val/ctxred (free e)  with val/ctxred e
... | inj₁ (_ , ctx , red) =  inj₁ $ _ , (λ • → free $ ctx •) , red
... | inj₀ (↑ ↑ x) =  inj₁ $ _ , id , freeᴿ x

--------------------------------------------------------------------------------
-- Reduction

private variable
  M :  Mem
  ctx :  Expr ∞ U → Expr ∞ T
  e :  Expr ∞ U
  e˙ :  A → Expr ∞ U
  a :  A
  x :  Addr
  u :  Val U
  b n :  ℕ

-- Red' vc M e M' :  vc & M reduces to e & M',
-- where vc is supposed to be obtained by val/ctxred

data  Red' {T} :  Val/Ctxred T →  Mem →  Expr ∞ T →  Mem →  Set (^ ^ ℓ)  where
  ▶-red :  Red' (inj₁ $ _ , ctx , ▶ᴿ e) M (ctx e) M
  ◁-red :  Red' (inj₁ $ _ , ctx , e˙ ◁ᴿ a) M (ctx $ e˙ a) M
  ★-red :  M !!ᴹ x ≡ some (U , u) →
    Red' (inj₁ $ _ , ctx , ★ᴿ x) M (ctx $ Val⇒Expr u) M
  ←-red :  ∀ {v : Val V} →
    Red' (inj₁ $ _ , ctx , x ←ᴿ v) M (ctx $ ∇ _) (updᴹ x (_ , v) M)
  alloc-red :  ∀ b →  M b ≡ [] →
    Red' (inj₁ $ _ , ctx , allocᴿ n) M
         (ctx $ ∇ ↑ addr b 0) (updᴹᴮ b (repeat n (◸ ⊤ , _)) M)
  free-red :  Red' (inj₁ $ _ , ctx , freeᴿ $ addr b 0) M
                   (ctx $ ∇ _) (updᴹᴮ b [] M)

-- Red e M e' M' :  e & M reduces to e' & M'

Red :  Expr ∞ T →  Mem →  Expr ∞ T →  Mem →  Set (^ ^ ℓ)
Red e M e' M' =  Red' (val/ctxred e) M e' M'
