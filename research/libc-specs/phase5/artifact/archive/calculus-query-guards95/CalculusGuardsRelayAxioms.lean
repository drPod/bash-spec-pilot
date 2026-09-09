/- Axiom audit for `CalculusGuardsRelay` and `CalculusGuardsRead` (calculus-guards-79). -/
import CalculusGuardsRelay
import CalculusGuardsRead

#print axioms CalculusGuardsRelay.InnerInvW.ofInv
#print axioms CalculusGuardsRelay.InnerInv.ofW
#print axioms CalculusGuardsRelay.relay_inner_call_failure
#print axioms CalculusGuardsRelay.relay_inner_call_raise
#print axioms CalculusGuardsRelay.relay_inner_step_guarded
#print axioms CalculusGuardsRelay.relay_inner_loop_run_guarded

#print axioms CalculusGuardsRead.rbK_nonneg_iff
#print axioms CalculusGuardsRead.rbK_le_rangeMax
#print axioms CalculusGuardsRead.read_block_guard_fail
#print axioms CalculusGuardsRead.read_block_guard_gate

-- the theorems these build on, for the record
#print axioms CalculusRelayLoop.relay_inner_step_inv
#print axioms CalculusRelayLoop.relay_inner_loop_run
#print axioms CalculusRelayOuter.read_block_body_ret
#print axioms CalculusGuards.write_block_guard_gate
