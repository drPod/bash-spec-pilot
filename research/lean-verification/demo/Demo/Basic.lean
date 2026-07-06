/-
Demo: verify LLM-generatable *models* of Unix utilities against a spec, in Lean.

`model ⊨ spec` is proved here and checked by Lean's kernel for ALL inputs.
`model ≈ real GNU binary` is checked empirically by `validate.py` against `ghead`.
Neither layer alone is the guarantee; together they are the two-layer story
(see ../README.md).

Design notes that are load-bearing, not decoration:
* Every model is a *total* function, never `partial def`: the kernel can only
  reason inside total definitions. These four utilities terminate, so no fuel or
  coinduction is needed. A non-terminating utility would instead be an inductive `Prop`.
* Core-only: proofs use `List` lemmas that ship with Lean (`Init.Data.List.TakeDrop`,
  `Init.Data.List.Nat.TakeDrop`). No Mathlib, so the build is small and fast.
-/

namespace Demo

/- --------------------  Models (the LLM's output)  -------------------- -/

/-- `true`: succeed, no output, ignore arguments. -/
def trueModel : Nat := 0

/-- `false`: fail, no output, ignore arguments. -/
def falseModel : Nat := 1

/-- `echo`: join arguments with single spaces onto one output line. -/
def echoModel (args : List String) : List String := [" ".intercalate args]

/-- `head -n k`: the first `k` input lines. -/
def headModel (k : Nat) (input : List String) : List String := input.take k

/- --------------------  Specs, proved for ALL inputs  -------------------- -/

theorem true_succeeds : trueModel = 0 := rfl
theorem false_fails   : falseModel = 1 := rfl

/-- `echo` emits exactly one line. -/
theorem echo_one_line (args : List String) : (echoModel args).length = 1 := rfl

/-- `head` never emits more than `k` lines. -/
theorem head_length_le_k (k : Nat) (input : List String) :
    (headModel k input).length ≤ k := by
  unfold headModel
  exact List.length_take_le k input

/-- `head` never emits more lines than it read. -/
theorem head_length_le_input (k : Nat) (input : List String) :
    (headModel k input).length ≤ input.length := by
  unfold headModel
  exact List.length_take_le' k input

/-- `head`'s output is a genuine prefix of the input: content and order preserved,
    nothing invented. Witness: the dropped tail, since `take k ++ drop k = input`. -/
theorem head_is_prefix (k : Nat) (input : List String) :
    headModel k input <+: input :=
  ⟨input.drop k, by simp [headModel, List.take_append_drop]⟩

/-- When the input is no longer than `k`, `head` returns it unchanged. -/
theorem head_saturates (k : Nat) (input : List String) (h : input.length ≤ k) :
    headModel k input = input := by
  unfold headModel
  exact List.take_of_length_le h

/-- `head -n 0` is empty. -/
theorem head_zero (input : List String) : headModel 0 input = [] := rfl

/-- Consuming one more line prepends exactly the next line (streaming shape). -/
theorem head_succ (k : Nat) (x : String) (xs : List String) :
    headModel (k + 1) (x :: xs) = x :: headModel k xs := rfl

end Demo
