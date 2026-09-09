import LeanFinal

/- `#print axioms` over every theorem in `LeanFinal.lean`. Expected: the three
   abstract composition theorems depend on no axioms; Concrete facts may
   inherit `propext`/`Classical.choice`/`Quot.sound` through BufferRelay.
   No `axiom`/`sorryAx`. Hypotheses are theorem parameters, not axioms. -/
#print axioms LeanFinal.redirect_then_mark_success
#print axioms LeanFinal.redirect_then_mark_error
#print axioms LeanFinal.redirect_then_direct_restored
#print axioms LeanFinal.Concrete.concreteBase_H_direct
#print axioms LeanFinal.Concrete.concreteBase_H_mark
#print axioms LeanFinal.Concrete.concreteBase_H_redirect
#print axioms LeanFinal.Concrete.concreteBase_satisfiable
#print axioms LeanFinal.Concrete.abc_status_zero
#print axioms LeanFinal.Concrete.truncate_over_existing_witness
#print axioms LeanFinal.Concrete.append_over_existing_witness
#print axioms LeanFinal.Concrete.empty_path_open_failure_witness
#print axioms LeanFinal.Concrete.relay_error_nonempty_path_witness
#print axioms LeanFinal.Concrete.parameterized_success_applied
#print axioms LeanFinal.Concrete.parameterized_empty_path_error_applied
