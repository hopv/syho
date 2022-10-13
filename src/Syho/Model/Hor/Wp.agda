--------------------------------------------------------------------------------
-- Semantic atomic, partial and total weakest preconditions
--------------------------------------------------------------------------------

{-# OPTIONS --without-K --sized-types #-}

module Syho.Model.Hor.Wp where

open import Base.Level using (Level; _⊔ᴸ_; 1ᴸ)
open import Base.Func using (_$_; _▷_; _∘_; _›_; id)
open import Base.Few using (⊤; absurd)
open import Base.Eq using (_≡_)
open import Base.Size using (Size; Size<; ∞; !; §_)
open import Base.Bool using (𝔹; tt; ff)
open import Base.Option using (¿_; ň; š_)
open import Base.Prod using (_×_; _,_; -,_)
open import Base.Sum using (ĩ₀_; ĩ₁_)
open import Base.Sety using ()
open import Syho.Lang.Expr using (Type; ◸_; Expr∞; Val; V⇒E; Mem)
open import Syho.Lang.Ktxred using (Redex; Ktxred; Val/Ktxred; val/ktxred)
open import Syho.Lang.Reduce using (_⇐ᴿ_; _⇐ᴷᴿ⟨_⟩_; _⇐ᴷᴿ_; _⇒ᴿ∑; _⇒ᴷᴿ∑)
open import Syho.Model.Prop.Base using (Propᵒ; Monoᵒ; _⊨✓_; _⊨_; ⊨_; ∀ᵒ-syntax;
  ∃ᵒ-syntax; ⊤ᵒ; ⊤ᵒ₀; ⊥ᵒ₀; ⌜_⌝ᵒ×_; ⌜_⌝ᵒ→_; _∗ᵒ'_; _∗ᵒ_; _-∗ᵒ'_; _-∗ᵒ_; Thunkᵒ;
  Shrunkᵒ; ⊨⇒⊨✓; ∀ᵒ-Mono; ∗ᵒ⇒∗ᵒ'; ∗ᵒ'⇒∗ᵒ; ∗ᵒ-Mono; ∗ᵒ-mono; ∗ᵒ-mono✓ˡ; ∗ᵒ-monoˡ;
  ∗ᵒ-monoʳ; ∗ᵒ-assocʳ; ?∗ᵒ-comm; ?∗ᵒ-intro; ∗ᵒ∃ᵒ-out; -∗ᵒ⇒-∗ᵒ'; -∗ᵒ'⇒-∗ᵒ;
  -∗ᵒ-Mono; -∗ᵒ-monoʳ; ⊨✓⇒⊨--∗ᵒ; -∗ᵒ-applyˡ; -∗ᵒ-eatˡ; ◎-Mono; ∗ᵒThunkᵒ-out;
  ∗ᵒShrunkᵒ-out)
open import Syho.Model.Prop.Names using ([⊤]ᴺᵒ)
open import Syho.Model.Supd.Interp using (⟨_⟩⇛ᴹ'⟨_⟩_; ⟨_⟩⇛ᴹ⟨_⟩_; ⇛ᵒ_; ⇛ᴺᵒ_;
  ⇛ᴹ⇒⇛ᴹ'; ⇛ᴹ'⇒⇛ᴹ; ⇛ᴹ-Mono; ⇛ᵒ-Mono; ⇛ᴹ-mono✓; ⇛ᴹ-mono; ⇛ᵒ-mono✓; ⇛ᵒ-mono;
  ⇛ᴺᵒ-mono✓; ⇛ᴺᵒ-mono; ⊨✓⇒⊨-⇛ᴹ; ⇛ᴺᵒ-intro; ⇛ᴹ-join; ⇛ᴺᵒ-join; ⇛ᴹ-eatˡ; ⇛ᴺᵒ-eatˡ;
  ⇛ᵒ⇒⇛ᴺᵒ)

private variable
  ł :  Level
  ι ι' :  Size
  b :  𝔹
  X :  Set₀
  T :  Type
  Pᵒ Qᵒ :  Propᵒ ł
  Pᵒ˙ Qᵒ˙ :  X → Propᵒ ł
  v :  X
  red :  Redex T
  kr :  Ktxred T
  vk :  Val/Ktxred T
  e :  Expr∞ T
  eˇ :  ¿ Expr∞ T

--------------------------------------------------------------------------------
-- ᵃ⟨ ⟩ᵒ :  Semantic atomic weakest precondition

ᵃ⟨_⟩ᵒ :  Redex T →  (Val T → Propᵒ ł) →  Propᵒ (1ᴸ ⊔ᴸ ł)
ᵃ⟨ red ⟩ᵒ Pᵒ˙ =  ∀ᵒ M , ⟨ M ⟩⇛ᴹ⟨ M ⟩ ⌜ (red , M) ⇒ᴿ∑ ⌝ᵒ×
                   ∀ᵒ e , ∀ᵒ eˇ , ∀ᵒ M' , ⌜ (e , eˇ , M') ⇐ᴿ (red , M) ⌝ᵒ→
                     ∃ᵒ v , ⌜ e ≡ V⇒E v × eˇ ≡ ň ⌝ᵒ×  ⟨ M ⟩⇛ᴹ⟨ M' ⟩  Pᵒ˙ v

--------------------------------------------------------------------------------
-- ⁺⟨ ⟩ᴾᵒ etc. :  Semantic partial weakest precondition

-- Wpᴾ :  ⁺⟨ ⟩ᴾᵒ with the arguments re-ordered

data  Wpᴾ (Pᵒ˙ : Val T → Propᵒ ł) (ι : Size) :  Val/Ktxred T →  Propᵒ (1ᴸ ⊔ᴸ ł)

-- ⁺⟨ ⟩ᴾᵒ :  Semantic partial weakest precondition on Val/Ktxred
-- ⟨ ⟩ᴾᵒ :  ⁺⟨ ⟩ᴾᵒ on Expr
-- ⟨ ⟩ᴾᵒ˂ :  ⟨ ⟩ᴾᵒ˂ under Thunk

⁺⟨_⟩ᴾᵒ :  Val/Ktxred T →  Size →  (Val T → Propᵒ ł) →  Propᵒ (1ᴸ ⊔ᴸ ł)
⁺⟨ kr ⟩ᴾᵒ ι Pᵒ˙ =  Wpᴾ Pᵒ˙ ι kr

⟨_⟩ᴾᵒ ⟨_⟩ᴾᵒ˂ :  Expr∞ T →  Size →  (Val T → Propᵒ ł) →  Propᵒ (1ᴸ ⊔ᴸ ł)
⟨ e ⟩ᴾᵒ ι Pᵒ˙ =  ⁺⟨ val/ktxred e ⟩ᴾᵒ ι Pᵒ˙
⟨ e ⟩ᴾᵒ˂ ι Pᵒ˙ =  Thunkᵒ (λ ι' → ⟨ e ⟩ᴾᵒ ι' Pᵒ˙) ι

-- ⁺⟨ ⟩ᴾᵒ⊤ :  Semantic partial weakest precondition on Val/Ktxred,
--               without the postcondition, used for forked threads

-- Wpᴾ⊤ :  ⁺⟨ ⟩ᴾᵒ⊤ with the arguments re-ordered

data  Wpᴾ⊤ (ι : Size) :  Val/Ktxred (◸ ⊤) →  Propᵒ 1ᴸ

⁺⟨_⟩ᴾᵒ⊤ :  Val/Ktxred (◸ ⊤) →  Size →  Propᵒ 1ᴸ
⁺⟨ vk ⟩ᴾᵒ⊤ ι =  Wpᴾ⊤ ι vk

-- ⟨ ⟩ᴾᵒ⊤ :  ⁺⟨ ⟩ᴾᵒ⊤ on Expr
-- ⟨ ⟩ᴾᵒ⊤˂ :  ⟨ ⟩ᴾᵒ⊤ under Thunk
-- ⟨¿ ⟩ᴾᵒ⊤˂ :  ⟨ ⟩ᴾᵒ⊤˂ for ¿ Expr

⟨_⟩ᴾᵒ⊤ ⟨_⟩ᴾᵒ⊤˂ :  Expr∞ (◸ ⊤) →  Size →  Propᵒ 1ᴸ
⟨ e ⟩ᴾᵒ⊤ ι =  ⁺⟨ val/ktxred e ⟩ᴾᵒ⊤ ι
⟨ e ⟩ᴾᵒ⊤˂ ι =  Thunkᵒ ⟨ e ⟩ᴾᵒ⊤ ι

⟨¿_⟩ᴾᵒ⊤˂ :  ¿ Expr∞ (◸ ⊤) →  Size →  Propᵒ 1ᴸ
⟨¿ ň ⟩ᴾᵒ⊤˂ _ =  ⊤ᵒ
⟨¿ š e ⟩ᴾᵒ⊤˂ ι =  ⟨ e ⟩ᴾᵒ⊤˂ ι

data  Wpᴾ⊤ ι  where

  -- For a value

  ⁺⟨⟩ᴾᵒ⊤-val :  ⊨  ⁺⟨ ĩ₀ v ⟩ᴾᵒ⊤ ι

  -- For a context-redex pair (c.f. ⁺⟨⟩ᴾᵒ-kr')

  ⁺⟨⟩ᴾᵒ⊤-kr' :  [⊤]ᴺᵒ -∗ᵒ' ∀ᵒ M , ⟨ M ⟩⇛ᴹ'⟨ M ⟩ ⌜ (kr , M) ⇒ᴷᴿ∑ ⌝ᵒ×
                  ∀ᵒ e , ∀ᵒ eˇ , ∀ᵒ M' , ⌜ (e , eˇ , M') ⇐ᴷᴿ (kr , M) ⌝ᵒ→
                    ⟨ M ⟩⇛ᴹ'⟨ M' ⟩ [⊤]ᴺᵒ ∗ᵒ' ⟨ e ⟩ᴾᵒ⊤˂ ι ∗ᵒ' ⟨¿ eˇ ⟩ᴾᵒ⊤˂ ι  ⊨
                ⁺⟨ ĩ₁ kr ⟩ᴾᵒ⊤ ι

-- Define Wpᴾ

data  Wpᴾ Pᵒ˙ ι  where

  -- For a value, having the postcondition under ⇛ᴹ

  ⁺⟨⟩ᴾᵒ-val :  ⇛ᴺᵒ Pᵒ˙ v  ⊨  ⁺⟨ ĩ₀ v ⟩ᴾᵒ ι Pᵒ˙

  -- For a context-redex pair, stating that the reduction is not stuck
  -- and for every next state the weakest precondition coinductively holds

  -- We should use ⇛ᴹ' (the concrete version) instead of ⇛ᴹ (the abstract
  -- version) here to pass the strict positivity check

  ⁺⟨⟩ᴾᵒ-kr' :  [⊤]ᴺᵒ -∗ᵒ' ∀ᵒ M , ⟨ M ⟩⇛ᴹ'⟨ M ⟩ ⌜ (kr , M) ⇒ᴷᴿ∑ ⌝ᵒ×
                 ∀ᵒ e , ∀ᵒ eˇ , ∀ᵒ M' , ⌜ (e , eˇ , M') ⇐ᴷᴿ (kr , M) ⌝ᵒ→
                   ⟨ M ⟩⇛ᴹ'⟨ M' ⟩ [⊤]ᴺᵒ ∗ᵒ' ⟨ e ⟩ᴾᵒ˂ ι Pᵒ˙ ∗ᵒ' ⟨¿ eˇ ⟩ᴾᵒ⊤˂ ι  ⊨
               ⁺⟨ ĩ₁ kr ⟩ᴾᵒ ι Pᵒ˙

--------------------------------------------------------------------------------
-- ⁺⟨ ⟩ᵀᵒ etc. :  Semantic total weakest precondition

-- Wpᵀ :  ⁺⟨ ⟩ᵀᵒ with the arguments re-ordered

data  Wpᵀ (Pᵒ˙ : Val T → Propᵒ ł) (ι : Size) :  Val/Ktxred T →  Propᵒ (1ᴸ ⊔ᴸ ł)

-- ⁺⟨ ⟩ᵀᵒ :  Semantic total weakest precondition on Val/Ktxred
-- ⟨ ⟩ᵀᵒ :  ⁺⟨ ⟩ᵀᵒ on Expr
-- ⟨ ⟩˂ᵀᵒ :  ⟨ ⟩ᵀᵒ under Shrunk

-- We use Shrunk here for induction based semantically on the size, rather than
-- only on the syntactic structure.

⁺⟨_⟩ᵀᵒ :  Val/Ktxred T →  Size →  (Val T → Propᵒ ł) →  Propᵒ (1ᴸ ⊔ᴸ ł)
⁺⟨ kr ⟩ᵀᵒ ι Pᵒ˙ =  Wpᵀ Pᵒ˙ ι kr

⟨_⟩ᵀᵒ ⟨_⟩ᵀᵒ˂ :  Expr∞ T →  Size →  (Val T → Propᵒ ł) →  Propᵒ (1ᴸ ⊔ᴸ ł)
⟨ e ⟩ᵀᵒ ι Pᵒ˙ =  ⁺⟨ val/ktxred e ⟩ᵀᵒ ι Pᵒ˙
⟨ e ⟩ᵀᵒ˂ ι Pᵒ˙ =  Shrunkᵒ (λ ι' → ⟨ e ⟩ᵀᵒ ι' Pᵒ˙) ι

-- ⁺⟨ ⟩ᵀᵒ⊤ :  Semantic total total precondition on Val/Ktxred,
--               without the postcondition, used for forked threads

-- Wpᵀ⊤ :  ⁺⟨ ⟩ᵀᵒ⊤ with the arguments re-ordered

data  Wpᵀ⊤ (ι : Size) :  Val/Ktxred (◸ ⊤) →  Propᵒ 1ᴸ

⁺⟨_⟩ᵀᵒ⊤ :  Val/Ktxred (◸ ⊤) →  Size →  Propᵒ 1ᴸ
⁺⟨ vk ⟩ᵀᵒ⊤ ι =  Wpᵀ⊤ ι vk

-- ⟨ ⟩ᵀᵒ⊤ :  ⁺⟨ ⟩ᵀᵒ⊤ on Expr
-- ⟨ ⟩ᵀᵒ⊤˂ :  ⟨ ⟩ᵀᵒ⊤ under Shrunk
-- ⟨¿ ⟩ᴾᵒ⊤˂ :  ⟨ ⟩ᴾᵒ⊤˂ for ¿ Expr

⟨_⟩ᵀᵒ⊤ ⟨_⟩ᵀᵒ⊤˂ :  Expr∞ (◸ ⊤) →  Size →  Propᵒ 1ᴸ
⟨ e ⟩ᵀᵒ⊤ ι =  ⁺⟨ val/ktxred e ⟩ᵀᵒ⊤ ι
⟨ e ⟩ᵀᵒ⊤˂ ι =  Shrunkᵒ ⟨ e ⟩ᵀᵒ⊤ ι

⟨¿_⟩ᵀᵒ⊤˂ :  ¿ Expr∞ (◸ ⊤) →  Size →  Propᵒ 1ᴸ
⟨¿ ň ⟩ᵀᵒ⊤˂ _ =  ⊤ᵒ
⟨¿ š e ⟩ᵀᵒ⊤˂ ι =  ⟨ e ⟩ᵀᵒ⊤˂ ι

data  Wpᵀ⊤ ι  where

  -- For a value

  ⁺⟨⟩ᵀᵒ⊤-val :  ⊨  ⁺⟨ ĩ₀ v ⟩ᵀᵒ⊤ ι

  -- For a context-redex pair (c.f. ⁺⟨⟩ᵀᵒ-kr')

  ⁺⟨⟩ᵀᵒ⊤-kr' :  [⊤]ᴺᵒ -∗ᵒ' ∀ᵒ M , ⟨ M ⟩⇛ᴹ'⟨ M ⟩ ⌜ (kr , M) ⇒ᴷᴿ∑ ⌝ᵒ×
                  ∀ᵒ e , ∀ᵒ eˇ , ∀ᵒ M' , ⌜ (e , eˇ , M') ⇐ᴷᴿ (kr , M) ⌝ᵒ→
                    ⟨ M ⟩⇛ᴹ'⟨ M' ⟩ [⊤]ᴺᵒ ∗ᵒ' ⟨ e ⟩ᵀᵒ⊤˂ ι ∗ᵒ' ⟨¿ eˇ ⟩ᵀᵒ⊤˂ ι  ⊨
                ⁺⟨ ĩ₁ kr ⟩ᵀᵒ⊤ ι

-- Define Wpᵀ

data  Wpᵀ Pᵒ˙ ι  where

  -- For a value, having the postcondition under ⇛ᴹ

  ⁺⟨⟩ᵀᵒ-val :  ⇛ᴺᵒ Pᵒ˙ v  ⊨  ⁺⟨ ĩ₀ v ⟩ᵀᵒ ι Pᵒ˙

  -- For a context-redex pair, stating that the reduction is not stuck
  -- and for every next state the weakest precondition inductively holds

  ⁺⟨⟩ᵀᵒ-kr' :  [⊤]ᴺᵒ -∗ᵒ' ∀ᵒ M , ⟨ M ⟩⇛ᴹ'⟨ M ⟩ ⌜ (kr , M) ⇒ᴷᴿ∑ ⌝ᵒ×
                 ∀ᵒ e , ∀ᵒ eˇ , ∀ᵒ M' , ⌜ (e , eˇ , M') ⇐ᴷᴿ (kr , M) ⌝ᵒ→
                   ⟨ M ⟩⇛ᴹ'⟨ M' ⟩ [⊤]ᴺᵒ ∗ᵒ' ⟨ e ⟩ᵀᵒ˂ ι Pᵒ˙ ∗ᵒ' ⟨¿ eˇ ⟩ᵀᵒ⊤˂ ι  ⊨
               ⁺⟨ ĩ₁ kr ⟩ᵀᵒ ι Pᵒ˙

--------------------------------------------------------------------------------
-- ⁺⟨ ⟩∞ᵒ etc. :  Semantic infinite weakest precondition

-- Wp∞ :  ⁺⟨ ⟩∞ᵒ with the arguments re-ordered

data  Wp∞ {T} (ι ι' : Size) :  Val/Ktxred T →  Propᵒ 1ᴸ

-- ⁺⟨ ⟩∞ᵒ :  Semantic total weakest precondition on Val/Ktxred
-- ⟨ ⟩∞ᵒ :  ⁺⟨ ⟩∞ᵒ on Expr
-- ⟨ ⟩∞ᵒ˂ˡ :  ⟨ ⟩∞ᵒ under Shrunk for the left-hand size
-- ⟨ ⟩∞ᵒ˂ʳ :  ⟨ ⟩∞ᵒ under Thunk for the right-hand size,
--            resetting the right-hand size to ∞
-- ⟨ ⟩∞ᵒ˂⟨ ⟩ :  ⟨ ⟩∞ᵒ˂ˡ or ⟨ ⟩∞ᵒ˂ʳ, depending on the boolean argument

⁺⟨_⟩∞ᵒ :  Val/Ktxred T →  Size →  Size →  Propᵒ 1ᴸ
⁺⟨ kr ⟩∞ᵒ ι ι' =  Wp∞ ι ι' kr

⟨_⟩∞ᵒ ⟨_⟩∞ᵒ˂ˡ :  Expr∞ T →  Size →  Size →  Propᵒ 1ᴸ
⟨ e ⟩∞ᵒ ι ι' =  ⁺⟨ val/ktxred e ⟩∞ᵒ ι ι'
⟨ e ⟩∞ᵒ˂ˡ ι ι' =  Shrunkᵒ (λ ι⁻ → ⟨ e ⟩∞ᵒ ι⁻ ι') ι

⟨_⟩∞ᵒ˂ʳ :  Expr∞ T →  Size →  Propᵒ 1ᴸ
⟨ e ⟩∞ᵒ˂ʳ ι' =  Thunkᵒ (⟨ e ⟩∞ᵒ ∞) ι'

⟨_⟩∞ᵒ˂⟨_⟩ :  Expr∞ T →  𝔹 →  Size →  Size →  Propᵒ 1ᴸ
⟨ e ⟩∞ᵒ˂⟨ ff ⟩ ι ι' =  ⟨ e ⟩∞ᵒ˂ˡ ι ι'
⟨ e ⟩∞ᵒ˂⟨ tt ⟩ _ ι' =  ⟨ e ⟩∞ᵒ˂ʳ ι'

-- Define Wp∞

data  Wp∞ ι ι'  where

  -- For a value, having ⊥ᵒ₀ under ⇛ᴹ

  ⁺⟨⟩∞ᵒ-val :  ⇛ᴺᵒ ⊥ᵒ₀  ⊨  ⁺⟨ ĩ₀ v ⟩∞ᵒ ι ι'

  -- For a context-redex pair, stating that the reduction is not stuck and,
  -- for every next state without or with the event, the weakest precondition
  -- holds inductively or coinductively, respectively

  ⁺⟨⟩∞ᵒ-kr' :  [⊤]ᴺᵒ -∗ᵒ' ∀ᵒ M , ⟨ M ⟩⇛ᴹ'⟨ M ⟩ ⌜ (kr , M) ⇒ᴷᴿ∑ ⌝ᵒ×
                 ∀ᵒ e , ∀ᵒ eˇ , ∀ᵒ M' , ∀ᵒ b ,
                   ⌜ (e , eˇ , M') ⇐ᴷᴿ⟨ b ⟩ (kr , M) ⌝ᵒ→ ⟨ M ⟩⇛ᴹ'⟨ M' ⟩
                     [⊤]ᴺᵒ ∗ᵒ' ⟨ e ⟩∞ᵒ˂⟨ b ⟩ ι ι' ∗ᵒ' ⟨¿ eˇ ⟩ᵀᵒ⊤˂ ι  ⊨
               ⁺⟨ ĩ₁ kr ⟩∞ᵒ ι ι'

--------------------------------------------------------------------------------
-- Lemmas on the atomic, partial, total, and infinite weakest preconditions

abstract

  -- Invert ⁺⟨⟩ᴾ/ᵀᵒ-val and ⁺⟨⟩∞ᵒ-val

  ⁺⟨⟩ᴾᵒ-val⁻¹ :  ⁺⟨ ĩ₀ v ⟩ᴾᵒ ι Pᵒ˙  ⊨ ⇛ᴺᵒ  Pᵒ˙ v
  ⁺⟨⟩ᴾᵒ-val⁻¹ (⁺⟨⟩ᴾᵒ-val ⇛Pv) =  ⇛Pv

  ⁺⟨⟩ᵀᵒ-val⁻¹ :  ⁺⟨ ĩ₀ v ⟩ᵀᵒ ι Pᵒ˙  ⊨ ⇛ᴺᵒ  Pᵒ˙ v
  ⁺⟨⟩ᵀᵒ-val⁻¹ (⁺⟨⟩ᵀᵒ-val ⇛Pv) =  ⇛Pv

  ⁺⟨⟩∞ᵒ-val⁻¹ :  ⁺⟨ ĩ₀ v ⟩∞ᵒ ι ι'  ⊨ ⇛ᴺᵒ  ⊥ᵒ₀
  ⁺⟨⟩∞ᵒ-val⁻¹ (⁺⟨⟩∞ᵒ-val ⇛⊥) =  ⇛⊥

  -- Modified ⁺⟨⟩ᴾ/ᵀᵒ-kr' and ⁺⟨⟩∞ᵒ-kr'

  ⁺⟨⟩ᴾᵒ-kr :  [⊤]ᴺᵒ -∗ᵒ ∀ᵒ M , ⟨ M ⟩⇛ᴹ⟨ M ⟩ ⌜ (kr , M) ⇒ᴷᴿ∑ ⌝ᵒ×
                ∀ᵒ e , ∀ᵒ eˇ , ∀ᵒ M' , ⌜ (e , eˇ , M') ⇐ᴷᴿ (kr , M) ⌝ᵒ→
                  ⟨ M ⟩⇛ᴹ⟨ M' ⟩ [⊤]ᴺᵒ ∗ᵒ ⟨ e ⟩ᴾᵒ˂ ι Pᵒ˙ ∗ᵒ ⟨¿ eˇ ⟩ᴾᵒ⊤˂ ι  ⊨
              ⁺⟨ ĩ₁ kr ⟩ᴾᵒ ι Pᵒ˙
  ⁺⟨⟩ᴾᵒ-kr big =  ⁺⟨⟩ᴾᵒ-kr' $ big ▷ -∗ᵒ-monoʳ (λ big M → big M ▷ (⇛ᴹ-mono
    λ (krM⇒ , big) → krM⇒ , λ e eˇ M' eeˇM'⇐ → big e eˇ M' eeˇM'⇐ ▷
    ⇛ᴹ-mono (∗ᵒ-monoʳ ∗ᵒ⇒∗ᵒ' › ∗ᵒ⇒∗ᵒ') ▷ ⇛ᴹ⇒⇛ᴹ') ▷ ⇛ᴹ⇒⇛ᴹ') ▷ -∗ᵒ⇒-∗ᵒ'

  ⁺⟨⟩ᵀᵒ-kr :  [⊤]ᴺᵒ -∗ᵒ ∀ᵒ M , ⟨ M ⟩⇛ᴹ⟨ M ⟩ ⌜ (kr , M) ⇒ᴷᴿ∑ ⌝ᵒ×
                ∀ᵒ e , ∀ᵒ eˇ , ∀ᵒ M' , ⌜ (e , eˇ , M') ⇐ᴷᴿ (kr , M) ⌝ᵒ→
                  ⟨ M ⟩⇛ᴹ⟨ M' ⟩ [⊤]ᴺᵒ ∗ᵒ ⟨ e ⟩ᵀᵒ˂ ι Pᵒ˙ ∗ᵒ ⟨¿ eˇ ⟩ᵀᵒ⊤˂ ι  ⊨
              ⁺⟨ ĩ₁ kr ⟩ᵀᵒ ι Pᵒ˙
  ⁺⟨⟩ᵀᵒ-kr big =  ⁺⟨⟩ᵀᵒ-kr' $ big ▷ -∗ᵒ-monoʳ (λ big M → big M ▷ (⇛ᴹ-mono
    λ (krM⇒ , big) → krM⇒ , λ e eˇ M' eeˇM'⇐ → big e eˇ M' eeˇM'⇐ ▷
    ⇛ᴹ-mono (∗ᵒ-monoʳ ∗ᵒ⇒∗ᵒ' › ∗ᵒ⇒∗ᵒ') ▷ ⇛ᴹ⇒⇛ᴹ') ▷ ⇛ᴹ⇒⇛ᴹ') ▷ -∗ᵒ⇒-∗ᵒ'

  ⁺⟨⟩∞ᵒ-kr :  [⊤]ᴺᵒ -∗ᵒ ∀ᵒ M , ⟨ M ⟩⇛ᴹ⟨ M ⟩ ⌜ (kr , M) ⇒ᴷᴿ∑ ⌝ᵒ×
                ∀ᵒ e , ∀ᵒ eˇ , ∀ᵒ M' , ∀ᵒ b ,
                  ⌜ (e , eˇ , M') ⇐ᴷᴿ⟨ b ⟩ (kr , M) ⌝ᵒ→ ⟨ M ⟩⇛ᴹ⟨ M' ⟩
                    [⊤]ᴺᵒ ∗ᵒ ⟨ e ⟩∞ᵒ˂⟨ b ⟩ ι ι' ∗ᵒ ⟨¿ eˇ ⟩ᵀᵒ⊤˂ ι  ⊨
              ⁺⟨ ĩ₁ kr ⟩∞ᵒ ι ι'
  ⁺⟨⟩∞ᵒ-kr big =  ⁺⟨⟩∞ᵒ-kr' $ big ▷ -∗ᵒ-monoʳ (λ big M → big M ▷ (⇛ᴹ-mono
    λ (krM⇒ , big) → krM⇒ , λ e eˇ M' b eeˇM'⇐⟨b⟩ → big e eˇ M' b eeˇM'⇐⟨b⟩ ▷
    ⇛ᴹ-mono (∗ᵒ-monoʳ ∗ᵒ⇒∗ᵒ' › ∗ᵒ⇒∗ᵒ') ▷ ⇛ᴹ⇒⇛ᴹ') ▷ ⇛ᴹ⇒⇛ᴹ') ▷ -∗ᵒ⇒-∗ᵒ'

  -- Invert ⁺⟨⟩ᴾ/ᵀᵒ-kr

  ⁺⟨⟩ᴾᵒ-kr⁻¹ :  ⁺⟨ ĩ₁ kr ⟩ᴾᵒ ι Pᵒ˙  ⊨
                [⊤]ᴺᵒ -∗ᵒ ∀ᵒ M , ⟨ M ⟩⇛ᴹ⟨ M ⟩ ⌜ (kr , M) ⇒ᴷᴿ∑ ⌝ᵒ×
                  ∀ᵒ e , ∀ᵒ eˇ , ∀ᵒ M' , ⌜ (e , eˇ , M') ⇐ᴷᴿ (kr , M) ⌝ᵒ→
                    ⟨ M ⟩⇛ᴹ⟨ M' ⟩ [⊤]ᴺᵒ ∗ᵒ ⟨ e ⟩ᴾᵒ˂ ι Pᵒ˙ ∗ᵒ ⟨¿ eˇ ⟩ᴾᵒ⊤˂ ι
  ⁺⟨⟩ᴾᵒ-kr⁻¹ (⁺⟨⟩ᴾᵒ-kr' big) =  big ▷ -∗ᵒ'⇒-∗ᵒ {Qᵒ = ∀ᵒ M , ⟨ M ⟩⇛ᴹ'⟨ M ⟩ _} ▷
    -∗ᵒ-monoʳ λ big M → big M ▷ ⇛ᴹ'⇒⇛ᴹ ▷ ⇛ᴹ-mono λ (krM⇒ , big) → krM⇒ ,
    λ e eˇ M' eeˇM'⇐ → big e eˇ M' eeˇM'⇐ ▷ ⇛ᴹ'⇒⇛ᴹ ▷
    ⇛ᴹ-mono (∗ᵒ'⇒∗ᵒ › ∗ᵒ-monoʳ ∗ᵒ'⇒∗ᵒ)

  ⁺⟨⟩ᵀᵒ-kr⁻¹ :  ⁺⟨ ĩ₁ kr ⟩ᵀᵒ ι Pᵒ˙  ⊨
                [⊤]ᴺᵒ -∗ᵒ ∀ᵒ M , ⟨ M ⟩⇛ᴹ⟨ M ⟩ ⌜ (kr , M) ⇒ᴷᴿ∑ ⌝ᵒ×
                  ∀ᵒ e , ∀ᵒ eˇ , ∀ᵒ M' , ⌜ (e , eˇ , M') ⇐ᴷᴿ (kr , M) ⌝ᵒ→
                    ⟨ M ⟩⇛ᴹ⟨ M' ⟩ [⊤]ᴺᵒ ∗ᵒ ⟨ e ⟩ᵀᵒ˂ ι Pᵒ˙ ∗ᵒ ⟨¿ eˇ ⟩ᵀᵒ⊤˂ ι
  ⁺⟨⟩ᵀᵒ-kr⁻¹ (⁺⟨⟩ᵀᵒ-kr' big) =  big ▷ -∗ᵒ'⇒-∗ᵒ {Qᵒ = ∀ᵒ M , ⟨ M ⟩⇛ᴹ'⟨ M ⟩ _} ▷
    -∗ᵒ-monoʳ λ big M → big M ▷ ⇛ᴹ'⇒⇛ᴹ ▷ ⇛ᴹ-mono λ (krM⇒ , big) → krM⇒ ,
    λ e eˇ M' eeˇM'⇐ → big e eˇ M' eeˇM'⇐ ▷ ⇛ᴹ'⇒⇛ᴹ ▷
    ⇛ᴹ-mono (∗ᵒ'⇒∗ᵒ › ∗ᵒ-monoʳ ∗ᵒ'⇒∗ᵒ)

  ⁺⟨⟩∞ᵒ-kr⁻¹ :  ⁺⟨ ĩ₁ kr ⟩∞ᵒ ι ι'  ⊨
                [⊤]ᴺᵒ -∗ᵒ ∀ᵒ M , ⟨ M ⟩⇛ᴹ⟨ M ⟩ ⌜ (kr , M) ⇒ᴷᴿ∑ ⌝ᵒ×
                  ∀ᵒ e , ∀ᵒ eˇ , ∀ᵒ M' , ∀ᵒ b ,
                    ⌜ (e , eˇ , M') ⇐ᴷᴿ⟨ b ⟩ (kr , M) ⌝ᵒ→ ⟨ M ⟩⇛ᴹ⟨ M' ⟩
                      [⊤]ᴺᵒ ∗ᵒ ⟨ e ⟩∞ᵒ˂⟨ b ⟩ ι ι' ∗ᵒ ⟨¿ eˇ ⟩ᵀᵒ⊤˂ ι
  ⁺⟨⟩∞ᵒ-kr⁻¹ (⁺⟨⟩∞ᵒ-kr' big) =  big ▷ -∗ᵒ'⇒-∗ᵒ {Qᵒ = ∀ᵒ M , ⟨ M ⟩⇛ᴹ'⟨ M ⟩ _} ▷
    -∗ᵒ-monoʳ λ big M → big M ▷ ⇛ᴹ'⇒⇛ᴹ ▷ ⇛ᴹ-mono λ (krM⇒ , big) → krM⇒ ,
    λ e eˇ M' b eeˇM'⇐⟨b⟩ → big e eˇ M' b eeˇM'⇐⟨b⟩ ▷ ⇛ᴹ'⇒⇛ᴹ ▷
    ⇛ᴹ-mono (∗ᵒ'⇒∗ᵒ › ∗ᵒ-monoʳ ∗ᵒ'⇒∗ᵒ)

  -- Conversion between ⁺⟨⟩ᴾ/ᵀᵒ⊤ and ⁺⟨⟩ᴾ/ᵀᵒ λ _ → ⊤ᵒ₀

  ⁺⟨⟩ᴾᵒ⊤⇒⁺⟨⟩ᴾᵒ :  ⁺⟨ vk ⟩ᴾᵒ⊤ ι  ⊨  ⁺⟨ vk ⟩ᴾᵒ ι λ _ → ⊤ᵒ₀
  ⁺⟨⟩ᴾᵒ⊤⇒⁺⟨⟩ᴾᵒ ⁺⟨⟩ᴾᵒ⊤-val =  ⁺⟨⟩ᴾᵒ-val $ ⇛ᴺᵒ-intro _
  ⁺⟨⟩ᴾᵒ⊤⇒⁺⟨⟩ᴾᵒ (⁺⟨⟩ᴾᵒ⊤-kr' big) =  ⁺⟨⟩ᴾᵒ-kr $ big ▷
    -∗ᵒ'⇒-∗ᵒ {Qᵒ = ∀ᵒ M , ⟨ M ⟩⇛ᴹ'⟨ M ⟩ _} ▷ -∗ᵒ-monoʳ λ big M → big M ▷
    ⇛ᴹ'⇒⇛ᴹ ▷ ⇛ᴹ-mono λ (krM⇒ , big) → krM⇒ , λ e eˇ M' eeˇM'⇐ →
    big e eˇ M' eeˇM'⇐ ▷ ⇛ᴹ'⇒⇛ᴹ ▷ ⇛ᴹ-mono (∗ᵒ'⇒∗ᵒ › ∗ᵒ-monoʳ $ ∗ᵒ'⇒∗ᵒ ›
    ∗ᵒ-monoˡ λ big → λ{ .! → ⁺⟨⟩ᴾᵒ⊤⇒⁺⟨⟩ᴾᵒ (big .!) })

  ⁺⟨⟩ᵀᵒ⊤⇒⁺⟨⟩ᵀᵒ :  ⁺⟨ vk ⟩ᵀᵒ⊤ ι  ⊨  ⁺⟨ vk ⟩ᵀᵒ ι λ _ → ⊤ᵒ₀
  ⁺⟨⟩ᵀᵒ⊤⇒⁺⟨⟩ᵀᵒ ⁺⟨⟩ᵀᵒ⊤-val =  ⁺⟨⟩ᵀᵒ-val $ ⇛ᴺᵒ-intro _
  ⁺⟨⟩ᵀᵒ⊤⇒⁺⟨⟩ᵀᵒ (⁺⟨⟩ᵀᵒ⊤-kr' big) =  ⁺⟨⟩ᵀᵒ-kr $ big ▷
    -∗ᵒ'⇒-∗ᵒ {Qᵒ = ∀ᵒ M , ⟨ M ⟩⇛ᴹ'⟨ M ⟩ _} ▷ -∗ᵒ-monoʳ λ big M → big M ▷
    ⇛ᴹ'⇒⇛ᴹ ▷ ⇛ᴹ-mono λ (krM⇒ , big) → krM⇒ , λ e eˇ M' eeˇM'⇐ →
    big e eˇ M' eeˇM'⇐ ▷ ⇛ᴹ'⇒⇛ᴹ ▷ ⇛ᴹ-mono (∗ᵒ'⇒∗ᵒ › ∗ᵒ-monoʳ $ ∗ᵒ'⇒∗ᵒ ›
    ∗ᵒ-monoˡ λ{ (§ big) → § ⁺⟨⟩ᵀᵒ⊤⇒⁺⟨⟩ᵀᵒ big })

  ⁺⟨⟩ᴾᵒ⇒⁺⟨⟩ᴾᵒ⊤ :  ⁺⟨ vk ⟩ᴾᵒ ι Pᵒ˙  ⊨  ⁺⟨ vk ⟩ᴾᵒ⊤ ι
  ⁺⟨⟩ᴾᵒ⇒⁺⟨⟩ᴾᵒ⊤ {vk = ĩ₀ _} _ =  ⁺⟨⟩ᴾᵒ⊤-val
  ⁺⟨⟩ᴾᵒ⇒⁺⟨⟩ᴾᵒ⊤ {vk = ĩ₁ _} ⟨kr⟩P =  ⁺⟨⟩ᴾᵒ⊤-kr' $ ⁺⟨⟩ᴾᵒ-kr⁻¹ ⟨kr⟩P ▷ -∗ᵒ-monoʳ
    (λ big M → big M ▷ ⇛ᴹ-mono (λ (krM⇒ , big) → krM⇒ , λ e eˇ M' eeˇM'⇐ →
    big e eˇ M' eeˇM'⇐ ▷ ⇛ᴹ-mono (∗ᵒ-monoʳ (∗ᵒ-monoˡ {Qᵒ = ⟨ _ ⟩ᴾᵒ⊤˂ _} (λ big →
    λ{ .! {ι'} → ⁺⟨⟩ᴾᵒ⇒⁺⟨⟩ᴾᵒ⊤ (big .! {ι'}) }) › ∗ᵒ⇒∗ᵒ') › ∗ᵒ⇒∗ᵒ') ▷ ⇛ᴹ⇒⇛ᴹ') ▷
    ⇛ᴹ⇒⇛ᴹ') ▷ -∗ᵒ⇒-∗ᵒ'

  ⁺⟨⟩ᵀᵒ⇒⁺⟨⟩ᵀᵒ⊤ :  ⁺⟨ vk ⟩ᵀᵒ ι Pᵒ˙  ⊨  ⁺⟨ vk ⟩ᵀᵒ⊤ ι
  ⁺⟨⟩ᵀᵒ⇒⁺⟨⟩ᵀᵒ⊤ {vk = ĩ₀ _} _ =  ⁺⟨⟩ᵀᵒ⊤-val
  ⁺⟨⟩ᵀᵒ⇒⁺⟨⟩ᵀᵒ⊤ {vk = ĩ₁ _} {ι} ⟨kr⟩P =  ⁺⟨⟩ᵀᵒ⊤-kr' $ ⁺⟨⟩ᵀᵒ-kr⁻¹ ⟨kr⟩P ▷
    -∗ᵒ-monoʳ (λ big M → big M ▷ ⇛ᴹ-mono (λ (krM⇒ , big) → krM⇒ ,
    λ e eˇ M' eeˇM'⇐ → big e eˇ M' eeˇM'⇐ ▷ ⇛ᴹ-mono (∗ᵒ-monoʳ (∗ᵒ-monoˡ
    {Qᵒ = ⟨ _ ⟩ᵀᵒ⊤˂ _} (λ{ (§ big) → §_ {ι = ι} $ ⁺⟨⟩ᵀᵒ⇒⁺⟨⟩ᵀᵒ⊤ big }) ›
    ∗ᵒ⇒∗ᵒ') › ∗ᵒ⇒∗ᵒ') ▷ ⇛ᴹ⇒⇛ᴹ') ▷ ⇛ᴹ⇒⇛ᴹ') ▷ -∗ᵒ⇒-∗ᵒ'

  -- Monoᵒ for ᵃ⟨⟩ᵒ, ⁺⟨⟩ᴾ/ᵀᵒ, ⁺⟨⟩∞ᵒ and ⁺⟨⟩ᴾ/ᵀᵒ⊤

  ᵃ⟨⟩ᵒ-Mono :  Monoᵒ $ ᵃ⟨ red ⟩ᵒ Pᵒ˙
  ᵃ⟨⟩ᵒ-Mono a⊑b ⟨red⟩P M =  ⟨red⟩P M ▷ ⇛ᴹ-Mono a⊑b

  ⁺⟨⟩ᴾᵒ-Mono :  Monoᵒ $ ⁺⟨ vk ⟩ᴾᵒ ι Pᵒ˙
  ⁺⟨⟩ᴾᵒ-Mono {vk = ĩ₀ _} a⊑b =  ⁺⟨⟩ᴾᵒ-val⁻¹ › -∗ᵒ-Mono a⊑b › ⁺⟨⟩ᴾᵒ-val
  ⁺⟨⟩ᴾᵒ-Mono {vk = ĩ₁ _} a⊑b =  ⁺⟨⟩ᴾᵒ-kr⁻¹ › -∗ᵒ-Mono a⊑b › ⁺⟨⟩ᴾᵒ-kr

  ⁺⟨⟩ᵀᵒ-Mono :  Monoᵒ $ ⁺⟨ vk ⟩ᵀᵒ ι Pᵒ˙
  ⁺⟨⟩ᵀᵒ-Mono {vk = ĩ₀ _} a⊑b =  ⁺⟨⟩ᵀᵒ-val⁻¹ › -∗ᵒ-Mono a⊑b › ⁺⟨⟩ᵀᵒ-val
  ⁺⟨⟩ᵀᵒ-Mono {vk = ĩ₁ _} a⊑b =  ⁺⟨⟩ᵀᵒ-kr⁻¹ › -∗ᵒ-Mono a⊑b › ⁺⟨⟩ᵀᵒ-kr

  ⁺⟨⟩∞ᵒ-Mono :  Monoᵒ $ ⁺⟨ vk ⟩∞ᵒ ι ι'
  ⁺⟨⟩∞ᵒ-Mono {vk = ĩ₀ _} a⊑b =  ⁺⟨⟩∞ᵒ-val⁻¹ › -∗ᵒ-Mono a⊑b › ⁺⟨⟩∞ᵒ-val
  ⁺⟨⟩∞ᵒ-Mono {vk = ĩ₁ _} a⊑b =  ⁺⟨⟩∞ᵒ-kr⁻¹ › -∗ᵒ-Mono a⊑b › ⁺⟨⟩∞ᵒ-kr

  ⁺⟨⟩ᴾᵒ⊤-Mono :  Monoᵒ $ ⁺⟨ vk ⟩ᴾᵒ⊤ ι
  ⁺⟨⟩ᴾᵒ⊤-Mono a⊑b =  ⁺⟨⟩ᴾᵒ⊤⇒⁺⟨⟩ᴾᵒ › ⁺⟨⟩ᴾᵒ-Mono a⊑b › ⁺⟨⟩ᴾᵒ⇒⁺⟨⟩ᴾᵒ⊤

  ⁺⟨⟩ᵀᵒ⊤-Mono :  Monoᵒ $ ⁺⟨ vk ⟩ᵀᵒ⊤ ι
  ⁺⟨⟩ᵀᵒ⊤-Mono a⊑b =  ⁺⟨⟩ᵀᵒ⊤⇒⁺⟨⟩ᵀᵒ › ⁺⟨⟩ᵀᵒ-Mono a⊑b › ⁺⟨⟩ᵀᵒ⇒⁺⟨⟩ᵀᵒ⊤

  -- Utility :  Monoᵒ for ∀ᵒ ⇛ᴹ

  ∀ᵒ⇛ᴹ-Mono :  Monoᵒ $ ∀ᵒ M , ⟨ M ⟩⇛ᴹ⟨ M ⟩ Pᵒ˙ M
  ∀ᵒ⇛ᴹ-Mono =  ∀ᵒ-Mono λ _ → ⇛ᴹ-Mono

  -- Monotonicity of ᵃ⟨⟩ᵒ and ⁺⟨⟩ᴾ/ᵀᵒ

  ᵃ⟨⟩ᵒ-mono✓ :  (∀ v → Pᵒ˙ v ⊨✓ Qᵒ˙ v) →  ᵃ⟨ red ⟩ᵒ Pᵒ˙ ⊨ ᵃ⟨ red ⟩ᵒ Qᵒ˙
  ᵃ⟨⟩ᵒ-mono✓ Pv⊨✓Qv big M =  big M ▷ ⇛ᴹ-mono λ (redM⇒ , big) → redM⇒ ,
    λ e eˇ M' eeˇM'⇐ → big e eˇ M' eeˇM'⇐ ▷ λ (-, ≡vň , big) → -, ≡vň ,
    big ▷ ⇛ᴹ-mono✓ (Pv⊨✓Qv _)

  ᵃ⟨⟩ᵒ-mono :  (∀ v → Pᵒ˙ v ⊨ Qᵒ˙ v) →  ᵃ⟨ red ⟩ᵒ Pᵒ˙ ⊨ ᵃ⟨ red ⟩ᵒ Qᵒ˙
  ᵃ⟨⟩ᵒ-mono =  (⊨⇒⊨✓ ∘_) › ᵃ⟨⟩ᵒ-mono✓

  ⁺⟨⟩ᴾᵒ-mono✓ :  (∀ v → Pᵒ˙ v ⊨✓ Qᵒ˙ v) →  ⁺⟨ vk ⟩ᴾᵒ ι Pᵒ˙ ⊨ ⁺⟨ vk ⟩ᴾᵒ ι Qᵒ˙
  ⁺⟨⟩ᴾᵒ-mono✓ {vk = ĩ₀ _} Pv⊨✓Qv =  ⁺⟨⟩ᴾᵒ-val⁻¹ › ⇛ᴺᵒ-mono✓ (Pv⊨✓Qv _) ›
    ⁺⟨⟩ᴾᵒ-val
  ⁺⟨⟩ᴾᵒ-mono✓ {vk = ĩ₁ _} Pv⊨✓Qv =  ⁺⟨⟩ᴾᵒ-kr⁻¹ › -∗ᵒ-monoʳ (λ big M → big M ▷
    ⇛ᴹ-mono λ (krM⇒ , big) → krM⇒ , λ e eˇ M' eeˇM'⇐ → big e eˇ M' eeˇM'⇐ ▷
    ⇛ᴹ-mono (∗ᵒ-monoʳ $ ∗ᵒ-monoˡ λ big →
    λ{ .! → ⁺⟨⟩ᴾᵒ-mono✓ Pv⊨✓Qv $ big .! })) › ⁺⟨⟩ᴾᵒ-kr

  ⁺⟨⟩ᴾᵒ-mono :  (∀ v → Pᵒ˙ v ⊨ Qᵒ˙ v) →  ⁺⟨ vk ⟩ᴾᵒ ι Pᵒ˙ ⊨ ⁺⟨ vk ⟩ᴾᵒ ι Qᵒ˙
  ⁺⟨⟩ᴾᵒ-mono =  (⊨⇒⊨✓ ∘_) › ⁺⟨⟩ᴾᵒ-mono✓

  ⁺⟨⟩ᵀᵒ-mono✓ :  (∀ v → Pᵒ˙ v ⊨✓ Qᵒ˙ v) →  ⁺⟨ vk ⟩ᵀᵒ ι Pᵒ˙ ⊨ ⁺⟨ vk ⟩ᵀᵒ ι Qᵒ˙
  ⁺⟨⟩ᵀᵒ-mono✓ {vk = ĩ₀ _} Pv⊨✓Qv =  ⁺⟨⟩ᵀᵒ-val⁻¹ › ⇛ᴺᵒ-mono✓ (Pv⊨✓Qv _) ›
    ⁺⟨⟩ᵀᵒ-val
  ⁺⟨⟩ᵀᵒ-mono✓ {vk = ĩ₁ _} Pv⊨✓Qv =  ⁺⟨⟩ᵀᵒ-kr⁻¹ › -∗ᵒ-monoʳ (λ big M → big M ▷
    ⇛ᴹ-mono λ (krM⇒ , big) → krM⇒ , λ e eˇ M' eeˇM'⇐ → big e eˇ M' eeˇM'⇐ ▷
    ⇛ᴹ-mono (∗ᵒ-monoʳ $ ∗ᵒ-monoˡ λ{ (§ big) → § ⁺⟨⟩ᵀᵒ-mono✓ Pv⊨✓Qv big })) ›
    ⁺⟨⟩ᵀᵒ-kr

  ⁺⟨⟩ᵀᵒ-mono :  (∀ v → Pᵒ˙ v ⊨ Qᵒ˙ v) →  ⁺⟨ vk ⟩ᵀᵒ ι Pᵒ˙ ⊨ ⁺⟨ vk ⟩ᵀᵒ ι Qᵒ˙
  ⁺⟨⟩ᵀᵒ-mono =  (⊨⇒⊨✓ ∘_) › ⁺⟨⟩ᵀᵒ-mono✓

  -- ⊨✓ into ⊨ when the right-hand side is ᵃ⟨⟩ᵒ / ⁺⟨⟩ᴾ/ᵀᵒ / ⁺⟨⟩∞ᵒ

  ⊨✓⇒⊨-ᵃ⟨⟩ᵒ :  Pᵒ ⊨✓ ᵃ⟨ red ⟩ᵒ Qᵒ˙ →  Pᵒ ⊨ ᵃ⟨ red ⟩ᵒ Qᵒ˙
  ⊨✓⇒⊨-ᵃ⟨⟩ᵒ P⊨✓⟨red⟩Q Pa M =  Pa ▷ ⊨✓⇒⊨-⇛ᴹ (λ ✓∙ Pb → P⊨✓⟨red⟩Q ✓∙ Pb M)

  ⊨✓⇒⊨-⁺⟨⟩ᴾᵒ :  Pᵒ ⊨✓ ⁺⟨ vk ⟩ᴾᵒ ι Qᵒ˙ →  Pᵒ ⊨ ⁺⟨ vk ⟩ᴾᵒ ι Qᵒ˙
  ⊨✓⇒⊨-⁺⟨⟩ᴾᵒ {vk = ĩ₀ _} P⊨✓⟨v⟩Q Pa =  Pa ▷
    ⊨✓⇒⊨--∗ᵒ (λ ✓∙ Pb → P⊨✓⟨v⟩Q ✓∙ Pb ▷ ⁺⟨⟩ᴾᵒ-val⁻¹) ▷ ⁺⟨⟩ᴾᵒ-val
  ⊨✓⇒⊨-⁺⟨⟩ᴾᵒ {vk = ĩ₁ _} P⊨✓⟨kr⟩Q Pa =  Pa ▷
    ⊨✓⇒⊨--∗ᵒ (λ ✓∙ Pb → P⊨✓⟨kr⟩Q ✓∙ Pb ▷ ⁺⟨⟩ᴾᵒ-kr⁻¹) ▷ ⁺⟨⟩ᴾᵒ-kr

  ⊨✓⇒⊨-⁺⟨⟩ᵀᵒ :  Pᵒ ⊨✓ ⁺⟨ vk ⟩ᵀᵒ ι Qᵒ˙ →  Pᵒ ⊨ ⁺⟨ vk ⟩ᵀᵒ ι Qᵒ˙
  ⊨✓⇒⊨-⁺⟨⟩ᵀᵒ {vk = ĩ₀ _} P⊨✓⟨v⟩Q Pa =  Pa ▷
    ⊨✓⇒⊨--∗ᵒ (λ ✓∙ Pb → P⊨✓⟨v⟩Q ✓∙ Pb ▷ ⁺⟨⟩ᵀᵒ-val⁻¹) ▷ ⁺⟨⟩ᵀᵒ-val
  ⊨✓⇒⊨-⁺⟨⟩ᵀᵒ {vk = ĩ₁ _} P⊨✓⟨kr⟩Q Pa =  Pa ▷
    ⊨✓⇒⊨--∗ᵒ (λ ✓∙ Pb → P⊨✓⟨kr⟩Q ✓∙ Pb ▷ ⁺⟨⟩ᵀᵒ-kr⁻¹) ▷ ⁺⟨⟩ᵀᵒ-kr

  ⊨✓⇒⊨-⁺⟨⟩∞ᵒ :  Pᵒ ⊨✓ ⁺⟨ vk ⟩∞ᵒ ι ι' →  Pᵒ ⊨ ⁺⟨ vk ⟩∞ᵒ ι ι'
  ⊨✓⇒⊨-⁺⟨⟩∞ᵒ {vk = ĩ₀ _} P⊨✓⟨v⟩Q Pa =  Pa ▷
    ⊨✓⇒⊨--∗ᵒ (λ ✓∙ Pb → P⊨✓⟨v⟩Q ✓∙ Pb ▷ ⁺⟨⟩∞ᵒ-val⁻¹) ▷ ⁺⟨⟩∞ᵒ-val
  ⊨✓⇒⊨-⁺⟨⟩∞ᵒ {vk = ĩ₁ _} P⊨✓⟨kr⟩Q Pa =  Pa ▷
    ⊨✓⇒⊨--∗ᵒ (λ ✓∙ Pb → P⊨✓⟨kr⟩Q ✓∙ Pb ▷ ⁺⟨⟩∞ᵒ-kr⁻¹) ▷ ⁺⟨⟩∞ᵒ-kr

  -- Modify the size of ⁺⟨⟩ᴾ/ᵀᵒ / ⁺⟨⟩∞ᵒ / ⟨¿ ⟩ᵀᵒ⊤˂

  ⁺⟨⟩ᴾᵒ-size :  ∀{ι' : Size< ι} →  ⁺⟨ vk ⟩ᴾᵒ ι Pᵒ˙  ⊨  ⁺⟨ vk ⟩ᴾᵒ ι' Pᵒ˙
  ⁺⟨⟩ᴾᵒ-size ⟨vk⟩P =  ⟨vk⟩P

  ⁺⟨⟩ᵀᵒ-size :  ∀{ι' : Size< ι} →  ⁺⟨ vk ⟩ᵀᵒ ι' Pᵒ˙  ⊨  ⁺⟨ vk ⟩ᵀᵒ ι Pᵒ˙
  ⁺⟨⟩ᵀᵒ-size ⟨vk⟩P =  ⟨vk⟩P

  ⁺⟨⟩∞ᵒ-size :  ∀{ι⁻ : Size< ι} {ι'⁻ : Size< ι'} →
    ⁺⟨ vk ⟩∞ᵒ ι⁻ ι'  ⊨  ⁺⟨ vk ⟩∞ᵒ ι ι'⁻
  ⁺⟨⟩∞ᵒ-size ⟨vk⟩P =  ⟨vk⟩P

  ⟨¿⟩ᵀᵒ⊤˂-size :  ∀{ι' : Size< ι} → ⟨¿ eˇ ⟩ᵀᵒ⊤˂ ι'  ⊨  ⟨¿ eˇ ⟩ᵀᵒ⊤˂ ι
  ⟨¿⟩ᵀᵒ⊤˂-size ⟨vk⟩P =  ⟨vk⟩P

  -- Convert ⁺⟨⟩ᵀᵒ into ⁺⟨⟩ᴾᵒ

  ⁺⟨⟩ᵀᵒ⇒⁺⟨⟩ᴾᵒ :  ⁺⟨ vk ⟩ᵀᵒ ι Pᵒ˙  ⊨  ⁺⟨ vk ⟩ᴾᵒ ι' Pᵒ˙
  ⟨¿⟩ᵀᵒ⊤˂⇒⟨¿⟩ᴾᵒ⊤˂ :  ⟨¿ eˇ ⟩ᵀᵒ⊤˂ ι  ⊨  ⟨¿ eˇ ⟩ᴾᵒ⊤˂ ι'

  ⁺⟨⟩ᵀᵒ⇒⁺⟨⟩ᴾᵒ {vk = ĩ₀ _} =  ⁺⟨⟩ᵀᵒ-val⁻¹ › ⁺⟨⟩ᴾᵒ-val
  ⁺⟨⟩ᵀᵒ⇒⁺⟨⟩ᴾᵒ {vk = ĩ₁ _} =  ⁺⟨⟩ᵀᵒ-kr⁻¹ › (-∗ᵒ-monoʳ λ big M → big M ▷ ⇛ᴹ-mono
    λ (krM⇒ , big) → krM⇒ , λ e eˇ M' eeˇM'⇐ → big e eˇ M' eeˇM'⇐ ▷
    ⇛ᴹ-mono (∗ᵒ-monoʳ $ ∗ᵒ-mono (λ{ (§ big) → λ{ .! → ⁺⟨⟩ᵀᵒ⇒⁺⟨⟩ᴾᵒ big }}) $
    ⟨¿⟩ᵀᵒ⊤˂⇒⟨¿⟩ᴾᵒ⊤˂ {eˇ = eˇ})) › ⁺⟨⟩ᴾᵒ-kr

  ⟨¿⟩ᵀᵒ⊤˂⇒⟨¿⟩ᴾᵒ⊤˂ {eˇ = ň} _ =  _
  ⟨¿⟩ᵀᵒ⊤˂⇒⟨¿⟩ᴾᵒ⊤˂ {eˇ = š _} (§ big) .! =
    big ▷ ⁺⟨⟩ᵀᵒ⊤⇒⁺⟨⟩ᵀᵒ ▷ ⁺⟨⟩ᵀᵒ⇒⁺⟨⟩ᴾᵒ ▷ ⁺⟨⟩ᴾᵒ⇒⁺⟨⟩ᴾᵒ⊤

  -- Convert ⁺⟨⟩∞ᵒ into ⁺⟨⟩ᴾᵒ

  ⁺⟨⟩∞ᵒ⇒⁺⟨⟩ᴾᵒ :  ⁺⟨ vk ⟩∞ᵒ ι ι'  ⊨  ⁺⟨ vk ⟩ᴾᵒ ι' Pᵒ˙
  ⁺⟨⟩∞ᵒ⇒⁺⟨⟩ᴾᵒ {vk = ĩ₀ _} =  ⁺⟨⟩∞ᵒ-val⁻¹ › ⇛ᴺᵒ-mono absurd › ⁺⟨⟩ᴾᵒ-val
  ⁺⟨⟩∞ᵒ⇒⁺⟨⟩ᴾᵒ {vk = ĩ₁ _} =  ⁺⟨⟩∞ᵒ-kr⁻¹ › (-∗ᵒ-monoʳ λ big M →
    big M ▷ ⇛ᴹ-mono λ (krM⇒ , big) → krM⇒ , λ e eˇ M' → λ{
    (ff , eeˇM'⇐○) → big e eˇ M' ff eeˇM'⇐○ ▷ ⇛ᴹ-mono (∗ᵒ-monoʳ $
      ∗ᵒ-mono (λ{ (§ big) → λ{ .! → ⁺⟨⟩∞ᵒ⇒⁺⟨⟩ᴾᵒ big }}) $
      ⟨¿⟩ᵀᵒ⊤˂⇒⟨¿⟩ᴾᵒ⊤˂ {eˇ = eˇ});
    (tt , eeˇM'⇐●) → big e eˇ M' tt eeˇM'⇐● ▷ ⇛ᴹ-mono (∗ᵒ-monoʳ $
      ∗ᵒ-mono (λ big → λ{ .! → ⁺⟨⟩∞ᵒ⇒⁺⟨⟩ᴾᵒ $ big .! }) $
      ⟨¿⟩ᵀᵒ⊤˂⇒⟨¿⟩ᴾᵒ⊤˂ {eˇ = eˇ})}) › ⁺⟨⟩ᴾᵒ-kr

  -- ᵃ⟨⟩ᵒ absorbs ⇛ᵒ outside

  ⇛ᵒ-ᵃ⟨⟩ᵒ :  ⇛ᵒ ᵃ⟨ red ⟩ᵒ Pᵒ˙  ⊨  ᵃ⟨ red ⟩ᵒ Pᵒ˙
  ⇛ᵒ-ᵃ⟨⟩ᵒ big M =  big M ▷ ⇛ᴹ-mono (_$ M) ▷ ⇛ᴹ-join

  -- ⁺⟨⟩ᴾ/ᵀᵒ / ⁺⟨⟩∞ᵒ absorbs ⇛ᴺᵒ/⇛ᵒ outside

  ⇛ᴺᵒ-⁺⟨⟩ᴾᵒ :  ⇛ᴺᵒ ⁺⟨ vk ⟩ᴾᵒ ι Pᵒ˙  ⊨  ⁺⟨ vk ⟩ᴾᵒ ι Pᵒ˙
  ⇛ᴺᵒ-⁺⟨⟩ᴾᵒ {vk = ĩ₀ _} =  ⇛ᴺᵒ-mono ⁺⟨⟩ᴾᵒ-val⁻¹ › ⇛ᴺᵒ-join › ⁺⟨⟩ᴾᵒ-val
  ⇛ᴺᵒ-⁺⟨⟩ᴾᵒ {vk = ĩ₁ _} =  (-∗ᵒ-monoʳ λ big M → big M ▷ ⇛ᴹ-mono✓ (λ ✓∙ →
    ∗ᵒ-monoʳ ⁺⟨⟩ᴾᵒ-kr⁻¹ › -∗ᵒ-applyˡ ∀ᵒ⇛ᴹ-Mono ✓∙ › _$ M) ▷ ⇛ᴹ-join) › ⁺⟨⟩ᴾᵒ-kr

  ⇛ᵒ-⁺⟨⟩ᴾᵒ :  ⇛ᵒ ⁺⟨ vk ⟩ᴾᵒ ι Pᵒ˙  ⊨  ⁺⟨ vk ⟩ᴾᵒ ι Pᵒ˙
  ⇛ᵒ-⁺⟨⟩ᴾᵒ =  ⇛ᵒ⇒⇛ᴺᵒ › ⇛ᴺᵒ-⁺⟨⟩ᴾᵒ

  ⇛ᴺᵒ-⁺⟨⟩ᵀᵒ :  ⇛ᴺᵒ ⁺⟨ vk ⟩ᵀᵒ ι Pᵒ˙  ⊨  ⁺⟨ vk ⟩ᵀᵒ ι Pᵒ˙
  ⇛ᴺᵒ-⁺⟨⟩ᵀᵒ {vk = ĩ₀ _} =  ⇛ᴺᵒ-mono ⁺⟨⟩ᵀᵒ-val⁻¹ › ⇛ᴺᵒ-join › ⁺⟨⟩ᵀᵒ-val
  ⇛ᴺᵒ-⁺⟨⟩ᵀᵒ {vk = ĩ₁ _} =  (-∗ᵒ-monoʳ λ big M → big M ▷ ⇛ᴹ-mono✓ (λ ✓∙ →
    ∗ᵒ-monoʳ ⁺⟨⟩ᵀᵒ-kr⁻¹ › -∗ᵒ-applyˡ ∀ᵒ⇛ᴹ-Mono ✓∙ › _$ M) ▷ ⇛ᴹ-join) › ⁺⟨⟩ᵀᵒ-kr

  ⇛ᵒ-⁺⟨⟩ᵀᵒ :  ⇛ᵒ ⁺⟨ vk ⟩ᵀᵒ ι Pᵒ˙  ⊨  ⁺⟨ vk ⟩ᵀᵒ ι Pᵒ˙
  ⇛ᵒ-⁺⟨⟩ᵀᵒ =  ⇛ᵒ⇒⇛ᴺᵒ › ⇛ᴺᵒ-⁺⟨⟩ᵀᵒ

  ⇛ᴺᵒ-⁺⟨⟩∞ᵒ :  ⇛ᴺᵒ ⁺⟨ vk ⟩∞ᵒ ι ι'  ⊨  ⁺⟨ vk ⟩∞ᵒ ι ι'
  ⇛ᴺᵒ-⁺⟨⟩∞ᵒ {vk = ĩ₀ _} =  ⇛ᴺᵒ-mono ⁺⟨⟩∞ᵒ-val⁻¹ › ⇛ᴺᵒ-join › ⁺⟨⟩∞ᵒ-val
  ⇛ᴺᵒ-⁺⟨⟩∞ᵒ {vk = ĩ₁ _} =  (-∗ᵒ-monoʳ λ big M → big M ▷ ⇛ᴹ-mono✓ (λ ✓∙ →
    ∗ᵒ-monoʳ ⁺⟨⟩∞ᵒ-kr⁻¹ › -∗ᵒ-applyˡ ∀ᵒ⇛ᴹ-Mono ✓∙ › _$ M) ▷ ⇛ᴹ-join) › ⁺⟨⟩∞ᵒ-kr

  ⇛ᵒ-⁺⟨⟩∞ᵒ :  ⇛ᵒ ⁺⟨ vk ⟩∞ᵒ ι ι'  ⊨  ⁺⟨ vk ⟩∞ᵒ ι ι'
  ⇛ᵒ-⁺⟨⟩∞ᵒ =  ⇛ᵒ⇒⇛ᴺᵒ › ⇛ᴺᵒ-⁺⟨⟩∞ᵒ

  -- ᵃ⟨⟩ᵒ absorbs ⇛ᵒ inside

  ᵃ⟨⟩ᵒ-⇛ᵒ :  ᵃ⟨ red ⟩ᵒ (λ v → ⇛ᵒ Pᵒ˙ v)  ⊨  ᵃ⟨ red ⟩ᵒ Pᵒ˙
  ᵃ⟨⟩ᵒ-⇛ᵒ big M =  big M ▷ ⇛ᴹ-mono λ (redM⇒ , big) → redM⇒ , λ e eˇ M' eeˇM'⇐ →
    big e eˇ M' eeˇM'⇐ ▷ λ (-, ≡vň , big) → -, ≡vň ,
    big ▷ ⇛ᴹ-mono (_$ M') ▷ ⇛ᴹ-join

  -- ⁺⟨⟩ᴾ/ᵀᵒ absorbs ⇛ᴺᵒ/⇛ᵒ inside

  ⁺⟨⟩ᴾᵒ-⇛ᴺᵒ :  ⁺⟨ vk ⟩ᴾᵒ ι (λ v → ⇛ᴺᵒ Pᵒ˙ v)  ⊨  ⁺⟨ vk ⟩ᴾᵒ ι Pᵒ˙
  ⁺⟨⟩ᴾᵒ-⇛ᴺᵒ {vk = ĩ₀ _} =  ⁺⟨⟩ᴾᵒ-val⁻¹ › ⇛ᴺᵒ-join › ⁺⟨⟩ᴾᵒ-val
  ⁺⟨⟩ᴾᵒ-⇛ᴺᵒ {vk = ĩ₁ _} =  ⁺⟨⟩ᴾᵒ-kr⁻¹ › (-∗ᵒ-monoʳ λ big M → big M ▷
    ⇛ᴹ-mono λ (krM⇒ , big) → krM⇒ , λ e eˇ M' eeˇM'⇐ → big e eˇ M' eeˇM'⇐ ▷
    ⇛ᴹ-mono (∗ᵒ-monoʳ $ ∗ᵒ-monoˡ λ big → λ{ .! → ⁺⟨⟩ᴾᵒ-⇛ᴺᵒ $ big .! })) ›
    ⁺⟨⟩ᴾᵒ-kr

  ⁺⟨⟩ᴾᵒ-⇛ᵒ :  ⁺⟨ vk ⟩ᴾᵒ ι (λ v → ⇛ᵒ Pᵒ˙ v)  ⊨  ⁺⟨ vk ⟩ᴾᵒ ι Pᵒ˙
  ⁺⟨⟩ᴾᵒ-⇛ᵒ =  ⁺⟨⟩ᴾᵒ-mono (λ _ → ⇛ᵒ⇒⇛ᴺᵒ) › ⁺⟨⟩ᴾᵒ-⇛ᴺᵒ

  ⁺⟨⟩ᵀᵒ-⇛ᴺᵒ :  ⁺⟨ vk ⟩ᵀᵒ ι (λ v → ⇛ᴺᵒ Pᵒ˙ v)  ⊨  ⁺⟨ vk ⟩ᵀᵒ ι Pᵒ˙
  ⁺⟨⟩ᵀᵒ-⇛ᴺᵒ {vk = ĩ₀ _} =  ⁺⟨⟩ᵀᵒ-val⁻¹ › ⇛ᴺᵒ-join › ⁺⟨⟩ᵀᵒ-val
  ⁺⟨⟩ᵀᵒ-⇛ᴺᵒ {vk = ĩ₁ _} =  ⁺⟨⟩ᵀᵒ-kr⁻¹ › (-∗ᵒ-monoʳ λ big M → big M ▷
    ⇛ᴹ-mono λ (krM⇒ , big) → krM⇒ , λ e eˇ M' eeˇM'⇐ → big e eˇ M' eeˇM'⇐ ▷
    ⇛ᴹ-mono (∗ᵒ-monoʳ $ ∗ᵒ-monoˡ λ{ (§ big) → § ⁺⟨⟩ᵀᵒ-⇛ᴺᵒ big })) › ⁺⟨⟩ᵀᵒ-kr

  ⁺⟨⟩ᵀᵒ-⇛ᵒ :  ⁺⟨ vk ⟩ᵀᵒ ι (λ v → ⇛ᵒ Pᵒ˙ v)  ⊨  ⁺⟨ vk ⟩ᵀᵒ ι Pᵒ˙
  ⁺⟨⟩ᵀᵒ-⇛ᵒ =  ⁺⟨⟩ᵀᵒ-mono (λ _ → ⇛ᵒ⇒⇛ᴺᵒ) › ⁺⟨⟩ᵀᵒ-⇛ᴺᵒ

  -- Let ᵃ⟨⟩ᵒ and ⁺⟨⟩ᴾ/ᵀᵒ eat a proposition

  ᵃ⟨⟩ᵒ-eatˡ :  Qᵒ ∗ᵒ (ᵃ⟨ red ⟩ᵒ Pᵒ˙)  ⊨  ᵃ⟨ red ⟩ᵒ λ v → Qᵒ ∗ᵒ Pᵒ˙ v
  ᵃ⟨⟩ᵒ-eatˡ big M =  big ▷ ∗ᵒ-monoʳ (_$ M) ▷ ⇛ᴹ-eatˡ ▷ ⇛ᴹ-mono (∗ᵒ∃ᵒ-out ›
    λ (redM⇒ , big) → redM⇒ , λ e eˇ M' eeˇM'⇐ → big ▷
    ∗ᵒ-monoʳ (λ big → big e eˇ M' eeˇM'⇐) ▷ ∗ᵒ∃ᵒ-out ▷ λ (-, big) → -,
    big ▷ ∗ᵒ∃ᵒ-out ▷ λ (≡vň , big) → ≡vň , big ▷ ⇛ᴹ-eatˡ)

  ⁺⟨⟩ᴾᵒ-eatˡ :  Qᵒ ∗ᵒ (⁺⟨ vk ⟩ᴾᵒ ι Pᵒ˙)  ⊨  ⁺⟨ vk ⟩ᴾᵒ ι λ v → Qᵒ ∗ᵒ Pᵒ˙ v
  ⁺⟨⟩ᴾᵒ-eatˡ {vk = ĩ₀ _} =  ∗ᵒ-monoʳ ⁺⟨⟩ᴾᵒ-val⁻¹ › ⇛ᴺᵒ-eatˡ › ⁺⟨⟩ᴾᵒ-val
  ⁺⟨⟩ᴾᵒ-eatˡ {vk = ĩ₁ _} =  ∗ᵒ-monoʳ ⁺⟨⟩ᴾᵒ-kr⁻¹ › -∗ᵒ-eatˡ ∀ᵒ⇛ᴹ-Mono ›
    -∗ᵒ-monoʳ (λ big M → big ▷ ∗ᵒ-monoʳ (_$ M) ▷ ⇛ᴹ-eatˡ ▷ ⇛ᴹ-mono (∗ᵒ∃ᵒ-out ›
    λ (krM⇒ , big) → krM⇒ , λ e eˇ M' eeˇM'⇐ → big ▷
    ∗ᵒ-monoʳ (λ big → big e eˇ M' eeˇM'⇐) ▷ ⇛ᴹ-eatˡ ▷ ⇛ᴹ-mono (?∗ᵒ-comm ›
    ∗ᵒ-monoʳ $ ∗ᵒ-assocʳ › ∗ᵒ-monoˡ $ ∗ᵒThunkᵒ-out ›
    λ big → λ{ .! → ⁺⟨⟩ᴾᵒ-eatˡ $ big .! }))) › ⁺⟨⟩ᴾᵒ-kr

  ⁺⟨⟩ᵀᵒ-eatˡ :  Qᵒ ∗ᵒ (⁺⟨ vk ⟩ᵀᵒ ι Pᵒ˙)  ⊨  ⁺⟨ vk ⟩ᵀᵒ ι λ v → Qᵒ ∗ᵒ Pᵒ˙ v
  ⁺⟨⟩ᵀᵒ-eatˡ {vk = ĩ₀ _} =  ∗ᵒ-monoʳ ⁺⟨⟩ᵀᵒ-val⁻¹ › ⇛ᴺᵒ-eatˡ › ⁺⟨⟩ᵀᵒ-val
  ⁺⟨⟩ᵀᵒ-eatˡ {vk = ĩ₁ _} =  ∗ᵒ-monoʳ ⁺⟨⟩ᵀᵒ-kr⁻¹ › -∗ᵒ-eatˡ ∀ᵒ⇛ᴹ-Mono ›
    -∗ᵒ-monoʳ (λ big M → big ▷ ∗ᵒ-monoʳ (_$ M) ▷ ⇛ᴹ-eatˡ ▷ ⇛ᴹ-mono (∗ᵒ∃ᵒ-out ›
    λ (krM⇒ , big) → krM⇒ , λ e eˇ M' eeˇM'⇐ → big ▷
    ∗ᵒ-monoʳ (λ big → big e eˇ M' eeˇM'⇐) ▷ ⇛ᴹ-eatˡ ▷ ⇛ᴹ-mono (?∗ᵒ-comm ›
    ∗ᵒ-monoʳ $ ∗ᵒ-assocʳ › ∗ᵒ-monoˡ $ ∗ᵒShrunkᵒ-out ›
    λ{ (§ big) → § ⁺⟨⟩ᵀᵒ-eatˡ big }))) › ⁺⟨⟩ᵀᵒ-kr
