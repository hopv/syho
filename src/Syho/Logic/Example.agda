--------------------------------------------------------------------------------
-- Example
--------------------------------------------------------------------------------

{-# OPTIONS --without-K --sized-types #-}

module Syho.Logic.Example where

open import Base.Func using (_$_; it)
open import Base.Eq using (_≡_; refl)
open import Base.Dec using ()
open import Base.Acc using (Acc; acc)
open import Base.Size using (𝕊; !)
open import Base.Prod using (_×_; _,_; -,_)
open import Base.Nat using (ℕ; ṡ_; _≤_; _<_; ṗ_; _+_; _⊔_; ≤-refl; ≤-trans;
  <-wf; ṗ-decr; ⊔-introˡ; ⊔-comm)
open import Base.List using (List; []; _∷_)
open import Base.Seq using (Seq∞; _∷ˢ_; hdˢ; tlˢ; repˢ; rep²ˢ; takeˢ)
open import Base.Sety using ()
open import Syho.Lang.Expr using (Addr; ◸_; _↷_; Expr˂∞; ∇_; 🞰_; Type; TyVal;
  loop)
open import Syho.Lang.Example using (plus◁3,4; decrep; decrep'; ndecrep;
  ndecrep●∞; fadᴿ; fad; fadrep; fadrep'; forksfadrep; nforksfadrep; cntr←)
open import Syho.Logic.Prop using (Name; strnm; Prop'; Prop∞; ¡ᴾ_; ∀-syntax;
  ∃-syntax; ⊤'; ⊥'; ⌜_⌝∧_; ⌜_⌝; _∗_; □_; ○_; _↦_; _↪⟨_⟩ᵀ[_]_; [^_]ᴺ; &ⁱ⟨_⟩_;
  static; _↦ⁱ_; #ᵁᵇ⟨_⟩_; ≤ᵁᵇ⟨_⟩_; ^ᶻᴺ-✔)
open import Syho.Logic.Core using (_⊢[_]_; Pers; ⊢-refl; _»_; ∀-intro; ∃-elim;
  ∀-elim; ∃-intro; ⊤-intro; ⌜⌝-intro; retain-⌜⌝; ∗-mono; ∗-monoˡ; ∗-monoʳ;
  ∗-comm; ∗-assocˡ; ∗-assocʳ; ?∗-comm; ∗-elimˡ; ∗-elimʳ; ⊤∗-intro; ∗⊤-intro;
  ∃∗-elim; dup-Pers-∗; -∗-introˡ; -∗-introʳ; ⤇-eatʳ; □-mono; □-dup; ∃-Pers;
  □-elim; □-intro-Pers; dup-Pers)
open import Syho.Logic.Supd using (_⊢[_][_]⇛_; ⤇⇒⇛; ⇒⇛; _ᵘ»ᵘ_; _ᵘ»_; ⇛-frameˡ;
  ⇛-frameʳ)
open import Syho.Logic.Hor using (_⊢[_][_]ᵃ⟨_⟩_; _⊢[_]⟨_⟩ᴾ_; _⊢[_]⟨_⟩ᵀ[_]_;
  _⊢[_][_]⟨_⟩∞; _ᵘ»ᵃʰ_; _ᵘ»ʰ_; _ᵃʰ»ᵘ_; ahor-frameʳ; ahor✔-hor; hor-valᵘ;
  hor-val; hor-nd; hor-[]; ihor-[]●; hor-ihor-⁏-bind; hor-fork)
open import Syho.Logic.Mem using (ahor-fau; hor-🞰; hor-←)
open import Syho.Logic.Ind using (○-mono; ○-new; □○-new-rec; ○-use; ○⇒↪⟨⟩;
  ↪⟨⟩ᵀ-use)
open import Syho.Logic.Inv using (&ⁱ-new; &ⁱ-open; %ⁱ-close; hor-↦ⁱ-🞰)
open import Syho.Logic.Ub using (≤ᵁᵇ-#ᵁᵇ; #ᵁᵇ-new; #ᵁᵇ-upd)

private variable
  ι :  𝕊
  i j k l m n :  ℕ
  θ θ' θᶜ :  Addr
  ᵗv :  TyVal
  X :  Set₀
  P :  Prop∞
  Q˙ :  X → Prop∞
  T :  Type
  e˂˙ :  X → Expr˂∞ T
  ns : List ℕ
  nsˢ :  Seq∞ ℕ

-- □ ○ □ ○ □ ○ …

□○∞ :  Prop' ι
□○∞ =  □ ○ λ{ .! → □○∞ }

abstract

  ------------------------------------------------------------------------------
  -- Get □○∞ for free

  □○∞-new :  ⊤' ⊢[ ι ][ i ]⇛ □○∞
  □○∞-new =  -∗-introˡ (∗-elimˡ » □-dup) » □○-new-rec

  ------------------------------------------------------------------------------
  -- Get any partial Hoare triple for loop
  -- This uses coinduction by thunk for the infinite execution of loop

  horᴾ-loop :  P ⊢[ ι ]⟨ loop ⟩ᴾ Q˙
  horᴾ-loop =  hor-[] λ{ .! → horᴾ-loop }

  ------------------------------------------------------------------------------
  -- Total Hoare triple for plus ◁ ∇ (3 , 4)

  horᵀ-plus◁3,4 :  ⊤'  ⊢[ ι ]⟨ plus◁3,4 ⟩ᵀ[ i ] λ n →  ⌜ n ≡ 7 ⌝
  horᵀ-plus◁3,4 =  hor-[] $ hor-val $ ⌜⌝-intro refl

  ------------------------------------------------------------------------------
  -- Sequential decrement loop: Example for the total Hoare triple

  -- Total Hoare triple for decrep

  -- The proof guarantees termination by induction over n
  -- Notably, we take advantage Agda's termination checker here

  horᵀ-decrep :  θ ↦ (-, n)  ⊢[ ι ]⟨ decrep θ ⟩ᵀ[ i ] λ _ →  θ ↦ (-, 0)
  horᵀ-decrep' :  θ ↦ (-, n)  ⊢[ ι ]⟨ decrep' θ n ⟩ᵀ[ i ] λ _ →  θ ↦ (-, 0)

  horᵀ-decrep =  ∗⊤-intro » hor-🞰 $ hor-[] $ ∗-elimˡ » horᵀ-decrep'

  horᵀ-decrep' {n = 0} =  hor-val ⊢-refl
  horᵀ-decrep' {n = ṡ _} =  ∗⊤-intro » hor-← $ hor-[] $ ∗-elimˡ » horᵀ-decrep

  -- Total Hoare triple for ndecrep, ensuring termination

  -- Notably, the number of reduction steps is dynamically determined
  -- Still, the proof here is totally natural; in particular, we don't need to
  -- craft a bound by an ordinal number, unlike Transfinite Iris

  horᵀ-ndecrep :  θ ↦ ᵗv  ⊢[ ι ]⟨ ndecrep θ ⟩ᵀ[ i ] λ _ →  θ ↦ (-, 0)
  horᵀ-ndecrep =  hor-nd λ _ → ∗⊤-intro » hor-← $ ∗-elimˡ » hor-[] horᵀ-decrep

  ------------------------------------------------------------------------------
  -- Infinite Hoare triple, for ndecrep●∞

  ihor-ndecrep●∞ :  θ ↦ ᵗv  ⊢[ ι ][ i ]⟨ ndecrep●∞ θ ⟩∞
  ihor-ndecrep●∞ =  hor-ihor-⁏-bind {e = ndecrep _} {i = 0}
    horᵀ-ndecrep λ _ → ihor-[]● λ{ .! → ihor-ndecrep●∞ }

  ------------------------------------------------------------------------------
  -- Concurrent decrement loop: Example for the total Hoare triple, the
  --                            impredicative invariant, and the upper bound

  -- &ub↦ :  Invariant that contains a full points-to token θ ↦ (-, n) for some
  --         number n under an upper-boundee token #ᵁᵇ⟨ i ⟩ n
  --         When we have &ub↦ θ i, any threads can freely decrease the value at
  --         θ, but never increase it

  ub : Name
  ub =  strnm "ub"

  &ub↦ :  Addr →  ℕ →  Prop∞
  &ub↦ θ i =  &ⁱ⟨ ub ⟩ ¡ᴾ (∃ n , #ᵁᵇ⟨ i ⟩ n ∗ θ ↦ (-, n))

  -- Create ≤ᵁᵇ⟨ i ⟩ n and &ub↦ θ i out of θ ↦ (-, n)

  &ub↦-new :  θ ↦ (-, n)  ⊢[ ι ][ j ]⇛  ∃ i ,  ≤ᵁᵇ⟨ i ⟩ n  ∗  &ub↦ θ i
  &ub↦-new =  ⊤∗-intro » ∗-monoˡ #ᵁᵇ-new » ⤇-eatʳ » ⤇⇒⇛ ᵘ»ᵘ ∃∗-elim λ i →
    ∗-assocˡ » ∗-monoʳ (∃-intro _) » ⇛-frameˡ &ⁱ-new ᵘ» ∃-intro i

  -- Atomic Hoare triple for fad under &ub↦, updating ≤ᵁᵇ

  ahor-fad-&ub↦ :
    [^ ub ]ᴺ  ∗  ≤ᵁᵇ⟨ i ⟩ n  ∗  &ub↦ θ i  ⊢[ ι ][ j ]ᵃ⟨ fadᴿ θ ⟩ λ m →
      [^ ub ]ᴺ  ∗  (⌜ m ≤ n ⌝∧  ≤ᵁᵇ⟨ i ⟩ ṗ m  ∗  &ub↦ θ i)
  ahor-fad-&ub↦ =  ?∗-comm » ∗-monoʳ (∗-monoʳ dup-Pers » ?∗-comm » ∗-assocʳ) »
    ⇛-frameˡ {i = 0} (⇛-frameʳ &ⁱ-open) ᵘ»ᵃʰ ∗-monoʳ ∗-assocˡ » ?∗-comm »
    ∃∗-elim λ m → ?∗-comm » ∗-monoʳ ∗-assocˡ » ∗-assocʳ »
    ∗-monoˡ (retain-⌜⌝ ≤ᵁᵇ-#ᵁᵇ) » ∃∗-elim λ m≤n → ∗-monoˡ ∗-elimʳ » ?∗-comm »
    ahor-frameʳ ahor-fau ᵃʰ»ᵘ λ m' → ∃∗-elim λ{ refl → ?∗-comm »
    ∗-monoˡ (#ᵁᵇ-upd ṗ-decr) » ⤇-eatʳ » ⤇⇒⇛ {i = 0} ᵘ»ᵘ ∗-assocˡ »
    ∗-monoʳ (∗-assocʳ » ∗-monoˡ (∃-intro _) » ∗-assocʳ) »
    ⇛-frameˡ (⇛-frameʳ %ⁱ-close) ᵘ» ?∗-comm » ∗-monoʳ $ ∃-intro m≤n }

  -- Total Hoare triple for fadrep under ≤ᵁᵇ and &ub↦
  -- The proof goes by well-founded induction over the upper bound n

  horᵀ-fadrep-&ub↦-Acc :  Acc _<_ n  →
    ≤ᵁᵇ⟨ i ⟩ n  ∗  &ub↦ θ i  ⊢[ ι ]⟨ fadrep θ ⟩ᵀ[ j ] λ _ →  ⊤'
  horᵀ-fadrep'-&ub↦-Acc :  Acc _<_ n  →   m ≤ n  →
    ≤ᵁᵇ⟨ i ⟩ ṗ m  ∗  &ub↦ θ i  ⊢[ ι ]⟨ fadrep' θ m ⟩ᵀ[ j ] λ _ →  ⊤'

  horᵀ-fadrep-&ub↦-Acc Accn =  ahor✔-hor {i = 0} ^ᶻᴺ-✔ ahor-fad-&ub↦ λ m →
    ∃-elim λ m≤n → hor-[] $ horᵀ-fadrep'-&ub↦-Acc Accn m≤n
  horᵀ-fadrep'-&ub↦-Acc {m = 0} _ _ =  hor-val ⊤-intro
  horᵀ-fadrep'-&ub↦-Acc {m = ṡ _} (acc <n⇒acc) m'<n =
    horᵀ-fadrep-&ub↦-Acc (<n⇒acc m'<n)

  horᵀ-fadrep-&ub↦ :
    ≤ᵁᵇ⟨ i ⟩ n  ∗  &ub↦ θ i  ⊢[ ι ]⟨ fadrep θ ⟩ᵀ[ j ] λ _ →  ⊤'
  horᵀ-fadrep-&ub↦ =  horᵀ-fadrep-&ub↦-Acc <-wf

  -- Total Hoare triple for forksfadrep θ k, which forks k threads that perform
  -- fadrep θ

  horᵀ-forksfadrep-&ub↦ :
    ≤ᵁᵇ⟨ i ⟩ n  ∗  &ub↦ θ i  ⊢[ ι ]⟨ forksfadrep θ k ⟩ᵀ[ j ] λ _ →  ⊤'
  horᵀ-forksfadrep-&ub↦ {k = 0} =  hor-val ⊤-intro
  horᵀ-forksfadrep-&ub↦ {k = ṡ _} =  dup-Pers »
    hor-fork horᵀ-fadrep-&ub↦ $ hor-[] horᵀ-forksfadrep-&ub↦

  horᵀ-forksfadrep :  θ ↦ (-, n)  ⊢[ ι ]⟨ forksfadrep θ k ⟩ᵀ[ j ] λ _ →  ⊤'
  horᵀ-forksfadrep =  &ub↦-new {j = 0} ᵘ»ʰ ∃-elim λ _ → horᵀ-forksfadrep-&ub↦

  -- Total Hoare triple for nforksfadrep

  horᵀ-nforksfadrep :  θ ↦ ᵗv  ⊢[ ι ]⟨ nforksfadrep θ ⟩ᵀ[ j ] λ _ →  ⊤'
  horᵀ-nforksfadrep =  hor-nd λ _ → ∗⊤-intro » hor-← $ hor-[] $ ∗-elimˡ »
    hor-nd λ _ → hor-[] horᵀ-forksfadrep

  ------------------------------------------------------------------------------
  -- Counter: Example for the total Hoare-triple precursor

  -- Specification for a counter e˂˙

  -- Thanks to the coinductivity of the total Hoare-triple precursor ↪⟨ ⟩ᵀ, we
  -- can construct the infinite proposition Cntr, which returns Cntr itself with
  -- an updated parameter k + n after executing the counter

  -- This amounts to construction of a recursive type over a function type
  -- Notably, this spec just states about the observable behaviors and abstracts
  -- the internal state of the function

  Cntr :  (ℕ → Expr˂∞ (◸ ℕ)) →  ℕ →  Prop' ι
  Cntr e˂˙ n =  ∀' k ,
    ¡ᴾ ⊤' ↪⟨ e˂˙ k .! ⟩ᵀ[ 0 ] λ{ m .! → ⌜ m ≡ n ⌝∧ Cntr e˂˙ (k + n) }

  -- Use Cntr e˂˙ to get a total Hoare triple for e˂˙
  -- The level of the total Hoare triple is 1, not 0

  Cntr-use :  Cntr e˂˙ n  ⊢[ ι ]⟨ e˂˙ k .! ⟩ᵀ[ 1 ] λ m →
                ⌜ m ≡ n ⌝∧ Cntr e˂˙ (k + n)
  Cntr-use =  ∀-elim _ » ⊤∗-intro » ↪⟨⟩ᵀ-use

  -- Get Cntr (cntr← θ) n from a full points-to token θ ↦ (-, n)
  -- Thanks to the coinductivity of ○⇒↪⟨⟩, we can successfully perform the
  -- infinite construction of Cntr

  cntr←-Cntr :  θ ↦ (-, n)  ⊢[ ι ][ i ]⇛  Cntr (cntr← θ) n
  cntr←-Cntr =  ○-new {P˂ = ¡ᴾ _} ᵘ» ∀-intro λ _ → ○⇒↪⟨⟩ λ{ .! →
    ∗-comm » hor-🞰 $ hor-[] $ hor-← $ hor-[] $ hor-valᵘ {i = 0} $
    ∗-elimˡ » cntr←-Cntr ᵘ» ∃-intro refl }

  ------------------------------------------------------------------------------
  -- Static singly-linked list: Example for the indirection modality ○

  -- Static singly-linked list over a list

  Slist :  List ℕ →  Addr →  Prop∞
  Slist (n ∷ ns) θ =  ∃ θ' , θ ↦ⁱ (-, n , θ') ∗ Slist ns θ'
  Slist [] _ =  ⊤'

  -- Static singly-linked list over a sequence
  -- We leverage here the coinductivity of the indirection modality ○,
  -- just like Iris's guarded recursion using the later modality ▷

  Slist∞ :  Seq∞ ℕ →  Addr →  Prop' ι
  Slist∞ (n ∷ˢ nsˢ˂) θ =
    ∃ θ' , θ ↦ⁱ (-, n , θ') ∗ □ ○ λ{ .! → Slist∞ (nsˢ˂ .!) θ' }

  -- Static singly-linked infinite list with a bound
  -- Again, we leverage here the coinductivity of the indirection modality ○

  Slist∞≤ :  ℕ →  Addr →  Prop' ι
  Slist∞≤ k θ =  ∃ n , ∃ θ' , ⌜ n ≤ k ⌝∧
    θ ↦ⁱ (-, n , θ') ∗ □ ○ λ{ .! → Slist∞≤ k θ' }

  -- Slist is persistent

  Slist-Pers :  Pers $ Slist ns θ
  Slist-Pers {[]} =  it
  Slist-Pers {_ ∷ ns'} =  let instance _ = Slist-Pers {ns'} in ∃-Pers λ _ → it

  instance

    -- Slist∞ is persistent

    Slist∞-Pers :  Pers $ Slist∞ nsˢ θ
    Slist∞-Pers {_ ∷ˢ _} =  ∃-Pers λ _ → it

    -- Slist∞≤ is persistent

    Slist∞≤-Pers :  Pers $ Slist∞≤ n θ
    Slist∞≤-Pers =  ∃-Pers λ _ → ∃-Pers λ _ → ∃-Pers λ _ → it

  -- Monotonicity of Slist∞≤
  -- Thanks to the coinductivity of ○-mono, we can get a pure sequent for the
  -- infinite proposition Slist∞≤

  Slist∞≤-mono :  k ≤ l  →   Slist∞≤ k θ  ⊢[ ι ]  Slist∞≤ l θ
  Slist∞≤-mono k≤l =  ∃-elim λ _ → ∃-elim λ _ → ∃-elim λ n≤k →
    ∗-monoʳ (□-mono $ ○-mono λ{ .! → Slist∞≤-mono k≤l }) »
    ∃-intro (≤-trans n≤k k≤l) » ∃-intro _ » ∃-intro _

  -- Slist∞ (repˢ n) into Slist∞≤ n
  -- Thanks to the coinductivity of ○-mono, we can get a pure sequent for the
  -- infinite propositions Slist∞ and Slist∞≤

  Slist∞-repˢ⇒Slist∞≤ :  Slist∞ (repˢ n) θ  ⊢[ ι ]  Slist∞≤ n θ
  Slist∞-repˢ⇒Slist∞≤ =  ∃-elim λ _ →
    ∗-monoʳ (□-mono $ ○-mono λ{ .! → Slist∞-repˢ⇒Slist∞≤ }) »
    ∃-intro ≤-refl » ∃-intro _ » ∃-intro _

  -- Slist∞ (rep²ˢ m n) into Slist∞≤ (m ⊔ n)
  -- Again, the coinductivity of ○-mono is the key

  Slist∞-rep²ˢ⇒Slist∞≤ :  Slist∞ (rep²ˢ m n) θ  ⊢[ ι ]  Slist∞≤ (m ⊔ n) θ
  Slist∞-rep²ˢ⇒Slist∞≤ =  ∃-elim λ _ → ∗-monoʳ (□-mono $ ○-mono λ{ .! → go }) »
    ∃-intro ⊔-introˡ » ∃-intro _ » ∃-intro _
   where
    go :  Slist∞ (rep²ˢ n m) θ  ⊢[ ι ]  Slist∞≤ (m ⊔ n) θ
    go {n} {m}  rewrite ⊔-comm {m} {n} =  Slist∞-rep²ˢ⇒Slist∞≤

  -- Turn Slist∞ nsˢ into Slist (takeˢ k nsˢ)
  -- This is under the super update ⇛, which is transitive,
  -- unlike the later modality ▷ in Iris

  Slist∞⇒Slist :  Slist∞ nsˢ θ  ⊢[ ι ][ i ]⇛  Slist (takeˢ k nsˢ) θ
  Slist∞⇒Slist {k = 0} =  ⇒⇛ ⊤-intro
  Slist∞⇒Slist {_ ∷ˢ _} {k = ṡ k'} =  ∃-elim λ θ' → ∗-monoʳ □-elim »
    ⇛-frameˡ (○-use ᵘ»ᵘ Slist∞⇒Slist {k = k'}) ᵘ» ∃-intro θ'

  -- Use Slist∞

  Slist∞-use :  Slist∞ nsˢ θ  ⊢[ ι ]⟨ 🞰_ {T = ◸ _} (∇ θ) ⟩ᵀ[ i ] λ (m , θ') →
                  ⌜ m ≡ hdˢ nsˢ ⌝∧ Slist∞ (tlˢ nsˢ .!) θ'
  Slist∞-use {_ ∷ˢ _} =  ∃-elim λ _ → hor-↦ⁱ-🞰 $ hor-valᵘ {i = 0} $
    □-elim » ○-use ᵘ» ∃-intro refl

  -- Turn a self-pointing pointer into Slist∞ (repˢ n)
  -- The key to this seemingly infinite construction is □○-new-rec

  Slist∞-repˢ-new :  θ ↦ⁱ (-, n , θ)  ⊢[ ι ][ i ]⇛  Slist∞ (repˢ n) θ
  Slist∞-repˢ-new =  -∗-introʳ (□-intro-Pers $
    ∗-monoʳ (□-mono $ ○-mono λ{ .! → ⊢-refl }) » ∃-intro _) »
    □○-new-rec {P˂ = ¡ᴾ _} ᵘ»ᵘ □-elim » ○-use

  -- Turn two mutually pointing pointers into Slist∞ (rep²ˢ - -) for both sides
  -- using □○-new-rec

  Slist∞-rep²ˢ-new :  θ ↦ⁱ (-, m , θ')  ∗  θ' ↦ⁱ (-, n , θ)  ⊢[ ι ][ i ]⇛
                        Slist∞ (rep²ˢ m n) θ  ∗  Slist∞ (rep²ˢ n m) θ'
  Slist∞-rep²ˢ-new =  -∗-introˡ (□-intro-Pers $ dup-Pers-∗ »
    ∗-monoʳ ?∗-comm » ∗-assocʳ » ∗-mono
    (∗-comm » ∗-monoʳ (□-mono $ ○-mono λ{ .! → ∗-elimʳ }) » ∃-intro _)
    (∗-comm » ∗-monoʳ (□-mono $ ○-mono λ{ .! → ∗-elimˡ }) » ∃-intro _)) »
    □○-new-rec {P˂ = ¡ᴾ _} ᵘ»ᵘ □-elim » ○-use
