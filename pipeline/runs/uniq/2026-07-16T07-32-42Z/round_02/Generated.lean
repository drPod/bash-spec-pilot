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
  | nil =>
      simp [skipEqual]
  | cons y ys ih =>
      by_cases h : y = x
      · simp only [skipEqual, h, if_pos]
        intro ha
        simp only [List.mem_cons]
        exact Or.inr (ih ha)
      · simp only [skipEqual, h, if_false]
        intro ha
        simp only [List.mem_cons] at ha ⊢
        cases ha with
        | inl hy =>
            subst a
            exact Or.inl rfl
        | inr hr =>
            exact Or.inr (ih hr)

theorem uniq_mem (a : String) (xs : List String) :
    a ∈ uniq xs → a ∈ xs := by
  cases xs with
  | nil =>
      simp [uniq]
  | cons x xs =>
      simp only [uniq, List.mem_cons]
      intro h
      cases h with
      | inl hx =>
          exact Or.inl hx
      | inr hr =>
          exact Or.inr (skipEqual_mem x a xs hr)

theorem uniq_length_le (xs : List String) :
    (uniq xs).length ≤ xs.length := by
  induction xs with
  | nil =>
      simp [uniq]
  | cons x xs ih =>
      have hs : (skipEqual x xs).length ≤ xs.length := by
        induction xs with
        | nil =>
            simp [skipEqual]
        | cons y ys ihs =>
            by_cases h : y = x
            · simpa [skipEqual, h] using
                (Nat.le_trans ihs (Nat.le_succ ys.length))
            · simpa [skipEqual, h] using (Nat.succ_le_succ ihs)
      simpa [uniq] using (Nat.succ_le_succ hs)

theorem skipEqual_idempotent (x : String) (xs : List String) :
    skipEqual x (skipEqual x xs) = skipEqual x xs := by
  induction xs with
  | nil =>
      simp [skipEqual]
  | cons y ys ih =>
      by_cases h : y = x
      · simp [skipEqual, h, ih]
      · simp [skipEqual, h, ih]

theorem uniq_idempotent (xs : List String) :
    uniq (uniq xs) = uniq xs := by
  cases xs with
  | nil =>
      rfl
  | cons x xs =>
      simp only [uniq]
      rw [skipEqual_idempotent]

theorem run_output (args stdin : List String) :
    (run args stdin).1 = uniq stdin := by
  rfl

theorem run_exit_success (args stdin : List String) :
    (run args stdin).2 = 0 := by
  rfl

theorem run_output_membership (args stdin : List String) (a : String) :
    a ∈ (run args stdin).1 → a ∈ stdin := by
  change a ∈ uniq stdin → a ∈ stdin
  exact uniq_mem a stdin

theorem run_output_length_bound (args stdin : List String) :
    (run args stdin).1.length ≤ stdin.length := by
  change (uniq stdin).length ≤ stdin.length
  exact uniq_length_le stdin

theorem run_idempotent (args stdin : List String) :
    (run args (run args stdin).1).1 = (run args stdin).1 := by
  change uniq (uniq stdin) = uniq stdin
  exact uniq_idempotent stdin

end Pipeline.Generated