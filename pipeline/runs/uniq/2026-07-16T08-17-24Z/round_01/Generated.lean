namespace Pipeline.Generated

/-- Collapse adjacent equal lines, keeping the first line of each adjacent run. -/
def uniqLines : List String -> List String
  | [] => []
  | x :: xs =>
      match xs with
      | [] => [x]
      | y :: ys =>
          if x = y then uniqLines (y :: ys) else x :: uniqLines (y :: ys)

/-- Predicate saying that a list contains no equal neighboring lines. -/
def NoAdjacentDup : List String -> Prop
  | [] => True
  | _ :: [] => True
  | x :: y :: xs => x ≠ y ∧ NoAdjacentDup (y :: xs)

/-- Model of `uniq` in the requested scope: stdin to stdout, no options. -/
def run (args stdin : List String) : List String × UInt32 :=
  (uniqLines stdin, (0 : UInt32))

private theorem uniqLines_cons_exists :
    ∀ (x : String) (xs : List String), ∃ ys, uniqLines (x :: xs) = x :: ys
  | x, [] => ⟨[], rfl⟩
  | x, y :: ys => by
      by_cases hxy : x = y
      · subst y
        obtain ⟨zs, hz⟩ := uniqLines_cons_exists x ys
        exact ⟨zs, by simpa [uniqLines, hz]⟩
      · exact ⟨uniqLines (y :: ys), by simp [uniqLines, hxy]⟩

private theorem uniqLines_noAdjacent :
    ∀ xs : List String, NoAdjacentDup (uniqLines xs)
  | [] => by simp [uniqLines, NoAdjacentDup]
  | x :: [] => by simp [uniqLines, NoAdjacentDup]
  | x :: y :: ys => by
      by_cases hxy : x = y
      · subst y
        simpa [uniqLines] using uniqLines_noAdjacent (x :: ys)
      · obtain ⟨zs, hz⟩ := uniqLines_cons_exists y ys
        have ih : NoAdjacentDup (y :: zs) := by
          simpa [hz] using uniqLines_noAdjacent (y :: ys)
        rw [show uniqLines (x :: y :: ys) = x :: uniqLines (y :: ys) by simp [uniqLines, hxy]]
        rw [hz]
        exact And.intro hxy ih

private theorem uniqLines_length_le :
    ∀ xs : List String, (uniqLines xs).length ≤ xs.length
  | [] => by simp [uniqLines]
  | x :: [] => by simp [uniqLines]
  | x :: y :: ys => by
      by_cases hxy : x = y
      · simpa [uniqLines, hxy] using
          Nat.le_trans (uniqLines_length_le (y :: ys)) (Nat.le_succ ((y :: ys).length))
      · simpa [uniqLines, hxy] using
          Nat.succ_le_succ (uniqLines_length_le (y :: ys))

private theorem uniqLines_mem_input (s : String) :
    ∀ xs : List String, s ∈ uniqLines xs -> s ∈ xs
  | [] => by
      intro h
      exact h
  | x :: [] => by
      intro h
      simpa [uniqLines] using h
  | x :: y :: ys => by
      intro hmem
      by_cases hxy : x = y
      · have ht : s ∈ y :: ys :=
          uniqLines_mem_input s (y :: ys) (by simpa [uniqLines, hxy] using hmem)
        exact Or.inr ht
      · have hsplit : s = x ∨ s ∈ uniqLines (y :: ys) := by
          simpa [uniqLines, hxy] using hmem
        cases hsplit with
        | inl hx =>
            exact Or.inl hx
        | inr ht =>
            exact Or.inr (uniqLines_mem_input s (y :: ys) ht)

private theorem uniqLines_eq_self_of_noAdjacent :
    ∀ xs : List String, NoAdjacentDup xs -> uniqLines xs = xs
  | [] => by
      intro _
      rfl
  | x :: [] => by
      intro _
      rfl
  | x :: y :: ys => by
      intro h
      have hxy : x ≠ y := h.1
      have htail : NoAdjacentDup (y :: ys) := h.2
      have ih := uniqLines_eq_self_of_noAdjacent (y :: ys) htail
      simp [uniqLines, hxy, ih]

private theorem uniqLines_idempotent (xs : List String) :
    uniqLines (uniqLines xs) = uniqLines xs :=
  uniqLines_eq_self_of_noAdjacent (uniqLines xs) (uniqLines_noAdjacent xs)

/-- Successful completion returns exit status 0. -/
theorem run_exit_success (args stdin : List String) :
    (run args stdin).2 = (0 : UInt32) := by
  rfl

/-- The output has no adjacent duplicate lines. -/
theorem run_stdout_noAdjacent (args stdin : List String) :
    NoAdjacentDup (run args stdin).1 := by
  simpa [run] using uniqLines_noAdjacent stdin

/-- Collapsing adjacent duplicates never increases the number of output lines. -/
theorem run_output_length_le_input (args stdin : List String) :
    (run args stdin).1.length ≤ stdin.length := by
  simpa [run] using uniqLines_length_le stdin

/-- Every output line is a line that occurred in the input. -/
theorem run_output_lines_from_input (args stdin : List String) (s : String) :
    s ∈ (run args stdin).1 -> s ∈ stdin := by
  intro h
  exact uniqLines_mem_input s stdin (by simpa [run] using h)

/-- Running the adjacent-duplicate collapse on its own output changes nothing. -/
theorem run_output_idempotent (args stdin : List String) :
    uniqLines (run args stdin).1 = (run args stdin).1 := by
  simpa [run] using uniqLines_idempotent stdin

end Pipeline.Generated
