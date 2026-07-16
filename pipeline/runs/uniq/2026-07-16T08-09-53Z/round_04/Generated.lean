namespace Pipeline.Generated

def uniq : List String → List String
  | [] => []
  | [x] => [x]
  | x :: y :: xs =>
      if x = y then uniq (y :: xs) else x :: uniq (y :: xs)

def Good : List String → Prop
  | [] => True
  | [_] => True
  | x :: y :: xs => x ≠ y ∧ Good (y :: xs)

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
      exact Nat.le_refl _
  | cons x xs ih =>
      cases xs with
      | nil =>
          exact Nat.le_refl _
      | cons y ys =>
          by_cases h : x = y
          · simpa [uniq, h] using (Nat.le_trans ih (Nat.le_succ _))
          · simpa [uniq, h] using (Nat.succ_le_succ ih)

theorem uniq_content_preservation (xs : List String) (a : String) :
    a ∈ uniq xs → a ∈ xs := by
  induction xs with
  | nil =>
      intro h
      exact h
  | cons x xs ih =>
      cases xs with
      | nil =>
          intro h
          exact h
      | cons y ys =>
          by_cases hxy : x = y
          · intro ha
            have ha' : a ∈ uniq (y :: ys) := by
              simpa [uniq, hxy] using ha
            exact List.Mem.tail x (ih ha')
          · intro ha
            have ha' : a = x ∨ a ∈ uniq (y :: ys) := by
              simpa [uniq, hxy] using ha
            cases ha' with
            | inl hax =>
                subst a
                exact List.Mem.head (y :: ys)
            | inr hrest =>
                exact List.Mem.tail x (ih hrest)

theorem uniq_nonempty (xs : List String) :
    xs ≠ [] → uniq xs ≠ [] := by
  intro hxs hu
  cases xs with
  | nil =>
      exact hxs rfl
  | cons x xs =>
      cases xs with
      | nil =>
          simp [uniq] at hu
      | cons y ys =>
          by_cases hxy : x = y
          · have hu' : uniq (y :: ys) = [] := by
              simpa [uniq, hxy] using hu
            exact uniq_nonempty (y :: ys) (by simp) hu'
          · simp [uniq, hxy] at hu

theorem good_uniq (xs : List String) :
    Good xs → uniq xs = xs := by
  induction xs with
  | nil =>
      intro h
      rfl
  | cons x xs ih =>
      cases xs with
      | nil =>
          intro h
          rfl
      | cons y ys =>
          intro hgood
          by_cases hxy : x = y
          · exact False.elim (hgood.1 hxy)
          · simpa [uniq, hxy] using ih hgood.2

theorem uniq_starts (x : String) (xs : List String) :
    ∃ ys, uniq (x :: xs) = x :: ys := by
  induction xs generalizing x with
  | nil =>
      exact ⟨[], rfl⟩
  | cons y ys ih =>
      by_cases h : x = y
      · subst x
        rcases ih y with ⟨r, hr⟩
        refine ⟨r, ?_⟩
        rw [show uniq (y :: y :: ys) = uniq (y :: ys) by simp [uniq]]
        exact hr
      · exact ⟨uniq (y :: ys), by simp [uniq, h]⟩

theorem good_uniq_output (xs : List String) :
    Good (uniq xs) := by
  induction xs with
  | nil =>
      trivial
  | cons x xs ih =>
      cases xs with
      | nil =>
          trivial
      | cons y ys =>
          by_cases hxy : x = y
          · simpa [uniq, hxy] using ih
          ·
            have hg : Good (uniq (y :: ys)) := ih
            rcases uniq_starts y ys with ⟨r, hr⟩
            have hg' : Good (y :: r) := by
              rw [← hr]
              exact hg
            have hout : Good (x :: uniq (y :: ys)) := by
              rw [hr]
              exact ⟨hxy, hg'⟩
            simpa [uniq, hxy] using hout

theorem uniq_idempotent (xs : List String) :
    uniq (uniq xs) = uniq xs := by
  exact good_uniq (uniq xs) (good_uniq_output xs)

end Pipeline.Generated