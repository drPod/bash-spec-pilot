 by
  intro p
  induction p with
  | here =>
    intro st st' n v h q b
    cases hlk : lookup st.elems (n, v) with
    | some existing =>
      simp only [addElemAt, hlk, Option.some.injEq] at h
      subst h
      cases q with
      | here => simp [getAttrAt, St.attrs]
      | nested m w rest => simp [getAttrAt, St.elems]
    | none =>
      simp only [addElemAt, hlk, Option.some.injEq] at h
      subst h
      cases q with
      | here => simp [getAttrAt, St.attrs]
      | nested m w rest =>
        by_cases hk : (m, w) = (n, v)
        · obtain ⟨rfl, rfl⟩ := Prod.mk.inj hk
          simp [getAttrAt, lookup_assocSet_same, hlk, getAttrAt_empty]
        · simp [getAttrAt, St.elems, lookup_assocSet_other _ _ _ _ hk]
  | nested m0 w0 rest ih =>
    intro st st' n v h q b
    simp only [addElemAt] at h
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
          by_cases hk : (m, w) = (m0, w0)
          · obtain ⟨rfl, rfl⟩ := Prod.mk.inj hk
            simp [getAttrAt, lookup_assocSet_same, hsub, ih sub sub' n v hsub' rest' b]
          · simp [getAttrAt, St.elems, lookup_assocSet_other _ _ _ _ hk]
