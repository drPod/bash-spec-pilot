/- Axiom audit for `CalculusGuards` (calculus-correspondence-75). -/
import CalculusGuards

#print axioms CalculusGuards.range_guard_int
#print axioms CalculusGuards.range_guard_some
#print axioms CalculusGuards.range_guard_fail
#print axioms CalculusGuards.rangeList_guard_some
#print axioms CalculusGuards.assign_range_cases
#print axioms CalculusGuards.assert_guard
#print axioms CalculusGuards.assert_guard_continue
#print axioms CalculusGuards.assert_le_continue
#print axioms CalculusGuards.writeBlockBody_eq_prefix
#print axioms CalculusGuards.write_block_guard_gate
#print axioms CalculusGuards.write_block_guarded

-- the guard prefix really is a prefix of the exported body: `wbRest` is not the fallback `.pass`
#eval (CalculusGuards.wbRest != .pass)
