 by
  simp only [removeElemAt, Option.some.injEq] at h
  subst h
  refine ⟨rfl, ?_⟩
  intro m w hk
  simp [St.elems, lookup_assocRemove_other _ _ _ hk]
