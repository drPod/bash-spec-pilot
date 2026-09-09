 by
  intro p
  induction p with
  | here =>
    intro st st' a x h q b hne
    simp only [setAttrAt, Option.some.injEq] at h
    subst h
    cases q with
    | here =>
      have hb : b ≠ a := by
        rcases hne with h1 | h1
        · exact absurd rfl h1
        · exact h1
      simp [getAttrAt, St.attrs, lookup_assocSet_other _ _ _ _ hb]
    | nested m w rest => simp [getAttrAt, St.elems]
  | nested n v rest ih =>
    intro st st' a x h q b hne
    simp only [setAttrAt] at h
    split at h
    · cases h
    · rename_i sub hsub
      split at h
      · cases h
      · rename_i sub' hsub'
        simp only [Option.some.injEq] at h
        subst h
        cases q with
        | here => simp [getAttrAt, St.attrs]
        | nested m w rest' =>
          by_cases hk : (m, w) = (n, v)
          · obtain ⟨rfl, rfl⟩ := Prod.mk.inj hk
            have hr : rest' ≠ rest ∨ b ≠ a := by
              rcases hne with h1 | h1
              · left; intro he; exact h1 (by rw [he])
              · right; exact h1
            simp [getAttrAt, lookup_assocSet_same, hsub, ih sub sub' a x hsub' rest' b hr]
          · simp [getAttrAt, St.elems, lookup_assocSet_other _ _ _ _ hk]
