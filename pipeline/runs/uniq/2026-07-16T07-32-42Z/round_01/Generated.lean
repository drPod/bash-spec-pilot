namespace Pipeline.Generated

def skipEqual (x : String) : List String → List String
  | [] => []
  | y :: ys => if y = x then skipEqual x ys else y :: skipEqual x ys

def uniq : List String → List String
  | [] => []
  | x :: xs => x :: skipEqual x xs

def run (args stdin : List String) : List String × UInt32 :=
  (uniq stdin, 0)

theorem skipEqual_mem (x a : String) (xs : List String) :
    a ∈ skipEqual x xs → a ∈ xs := by
  induction xs with
  | nil => simp [skipEqual]
  | cons y ys ih =>
    by_cases h : y = x
    · simp [skipEqual, h, ih]
    · simp [skipEqual, h, ih]

theorem uniq_mem (a : String) (xs : List String) :
    a ∈ uniq xs → a ∈ xs := by
  induction xs with
  | nil => simp [uniq]
  | cons x xs ih =>
    intro h
    have hh : a = x ∨ a ∈ skipEqual x xs := by
      simpa [uniq] using h
    cases hh with
    | inl hx =>
      subst a
      simp
    | inr hrest =>
      exact List.mem_cons_of_mem x (skipEqual_mem x a xs hrest)

theorem skipEqual_length_le (x : String) (xs : List String) :
    (skipEqual x xs).length ≤ xs.length := by
  induction xs with
  | nil => simp [skipEqual]
  | cons y ys ih =>
    by_cases h : y = x
    · simpa [skipEqual, h] using
        (Nat.le_trans ih (Nat.le_succ ys.length))
    · simpa [skipEqual, h] using (Nat.succ_le_succ ih)

theorem uniq_length_le (xs : List String) :
    (uniq xs).length ≤ xs.length := by
  induction xs with
  | nil => simp [uniq]
  | cons x xs ih =>
    simpa [uniq] using (Nat.succ_le_succ (skipEqual_length_le x xs))

theorem skipEqual_idempotent (x : String) (xs : List String) :
    skipEqual x (skipEqual x xs) = skipEqual x xs := by
  induction xs with
  | nil => simp [skipEqual]
  | cons y ys ih =>
    by_cases h : y = x
    · simp [skipEqual, h, ih]
    · simp [skipEqual, h, ih]

theorem uniq_idempotent (xs : List String) :
    uniq (uniq xs) = uniq xs := by
  induction xs with
  | nil => simp [uniq]
  | cons x xs ih =>
    simp only [uniq]
    rw [skipEqual_idempotent x xs]

theorem run_output (args stdin : List String) :
    (run args stdin).1 = uniq stdin := by
  rfl

theorem run_exit_success (args stdin : List String) :
    (run args stdin).2 = 0 := by
  rfl

theorem run_output_membership (args stdin : List String) (a : String) :
    a ∈ (run args stdin).1 → a ∈ stdin := by
  intro h
  exact uniq_mem a stdin (by simpa [run] using h)

theorem run_output_length_bound (args stdin : List String) :
    (run args stdin).1.length ≤ stdin.length := by
  simpa [run] using uniq_length_le stdin

theorem run_idempotent (args stdin : List String) :
    (run args (run args stdin).1).1 = (run args stdin).1 := by
  simp [run, uniq_idempotent]

end Pipeline.Generated