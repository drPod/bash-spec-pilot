namespace Demo

def trueModel : Nat := 0

def falseModel : Nat := 1

def echoModel (args : List String) : List String := [" ".intercalate args]

def headModel (k : Nat) (input : List String) : List String := input.take k

theorem true_succeeds : trueModel = 0 := rfl
theorem false_fails   : falseModel = 1 := rfl

theorem echo_one_line (args : List String) : (echoModel args).length = 1 := rfl

theorem head_length_le_k (k : Nat) (input : List String) :
    (headModel k input).length ≤ k := by
  unfold headModel
  exact List.length_take_le k input

theorem head_length_le_input (k : Nat) (input : List String) :
    (headModel k input).length ≤ input.length := by
  unfold headModel
  exact List.length_take_le' k input

theorem head_is_prefix (k : Nat) (input : List String) :
    headModel k input <+: input :=
  ⟨input.drop k, by simp [headModel, List.take_append_drop]⟩

theorem head_saturates (k : Nat) (input : List String) (h : input.length ≤ k) :
    headModel k input = input := by
  unfold headModel
  exact List.take_of_length_le h

theorem head_zero (input : List String) : headModel 0 input = [] := rfl

theorem head_succ (k : Nat) (x : String) (xs : List String) :
    headModel (k + 1) (x :: xs) = x :: headModel k xs := rfl

end Demo
