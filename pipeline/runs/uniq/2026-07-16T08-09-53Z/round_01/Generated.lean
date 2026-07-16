namespace Pipeline.Generated

def uniq : List String → List String
  | [] => []
  | [x] => [x]
  | x :: y :: xs =>
      if x = y then uniq (y :: xs) else x :: uniq (y :: xs)

def run (args stdin : List String) : List String × UInt32 :=
  (uniq stdin, 0)

theorem run_output_shape (args stdin : List String) :
    (run args stdin).1 = uniq stdin := by
  rfl

theorem run_exit_success (args stdin : List String) :
    (run args stdin).2 = 0 := by
  rfl

theorem uniq_length_bound (xs : List String) :
    (uniq xs).length ≤ xs.length := by
  induction xs with
  | nil =>
      rfl
  | cons x xs ih =>
      cases xs with
      | nil =>
          rfl
      | cons y ys =>
          by_cases h : x = y
          · simpa [uniq, h] using (Nat.le_trans ih (Nat.le_succ _))
          · simpa [uniq, h] using (Nat.succ_le_succ ih)

theorem uniq_content_preservation (xs : List String) (a : String) :
    a ∈ uniq xs → a ∈ xs := by
  induction xs with
  | nil =>
      simp [uniq]
  | cons x xs ih =>
      cases xs with
      | nil =>
          simp [uniq]
      | cons y ys =>
          by_cases h : x = y
          · simp [uniq, h, ih]
          · simp [uniq, h, ih]

theorem uniq_idempotent (xs : List String) :
    uniq (uniq xs) = uniq xs := by
  induction xs with
  | nil =>
      rfl
  | cons x xs ih =>
      cases xs with
      | nil =>
          rfl
      | cons y ys =>
          by_cases hxy : x = y
          · simp [uniq, hxy, ih]
          · cases ys with
            | nil =>
                simp [uniq, hxy]
            | cons z zs =>
                by_cases hyz : y = z
                · subst z
                  simp [uniq, hxy]
                · simp [uniq, hxy, hyz]

end Pipeline.Generated
