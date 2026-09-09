import PointerRelay

/- Explicit declaration manifest across PointerCore and PointerRelay.
   Only propext, Classical.choice, and Quot.sound are permitted. -/

#print axioms PointerRelay.Byte

#print axioms PointerRelay.Memory

#print axioms PointerRelay.Control

#print axioms PointerRelay.State

#print axioms PointerRelay.WellFormed

#print axioms PointerRelay.slice

#print axioms PointerRelay.pending

#print axioms PointerRelay.slice_load

#print axioms PointerRelay.slice_length

#print axioms PointerRelay.pending_length

#print axioms PointerRelay.pending_take

#print axioms PointerRelay.pending_advance

#print axioms PointerRelay.Kind

#print axioms PointerRelay.Event

#print axioms PointerRelay.readEvent

#print axioms PointerRelay.writeEvent

#print axioms PointerRelay.readStop

#print axioms PointerRelay.readNext

#print axioms PointerRelay.drainDone

#print axioms PointerRelay.writeStop

#print axioms PointerRelay.writeNext

#print axioms PointerRelay.Step

#print axioms PointerRelay.Steps

#print axioms PointerRelay.RequestSafe

#print axioms PointerRelay.step_preserves

#print axioms PointerRelay.read_event_safe

#print axioms PointerRelay.write_event_safe

#print axioms PointerRelay.step_request_safe

#print axioms PointerRelay.steps_preserve

#print axioms PointerRelay.Execution

#print axioms PointerRelay.drain

#print axioms PointerRelay.execute

#print axioms PointerRelay.observe

#print axioms PointerRelay.initial

#print axioms PointerRelay.run

#print axioms PointerRelay.drained

#print axioms PointerRelay.drain_refines

#print axioms PointerRelay.drain_pending

#print axioms PointerRelay.drain_reachable

#print axioms PointerRelay.drain_wf

#print axioms PointerRelay.drain_finished

#print axioms PointerRelay.readNext_wf

#print axioms PointerRelay.readNext_pending

#print axioms PointerRelay.drain_failed_iff

#print axioms PointerRelay.observe_drain

#print axioms PointerRelay.accumulate

#print axioms PointerRelay.execute_refines

#print axioms PointerRelay.Steps.trans

#print axioms PointerRelay.drain_input

#print axioms PointerRelay.execute_reachable

#print axioms PointerRelay.run_detailed_eq

#print axioms PointerRelay.observeOutcome

#print axioms PointerRelay.run_outcome_eq

#print axioms PointerRelay.run_reachable

#print axioms PointerRelay.Event.result

#print axioms PointerRelay.Initialized

#print axioms PointerRelay.Ready

#print axioms PointerRelay.Invariant

#print axioms PointerRelay.conserved

#print axioms PointerRelay.readNext_initialized

#print axioms PointerRelay.step_invariant

#print axioms PointerRelay.step_conservation

#print axioms PointerRelay.steps_invariant

#print axioms PointerRelay.steps_conservation

#print axioms PointerRelay.initial_invariant

#print axioms PointerRelay.Reachable

#print axioms PointerRelay.reachable_invariant

#print axioms PointerRelay.reachable_request_safe

#print axioms PointerRelay.initialized_write_bytes

#print axioms PointerRelay.reachable_write_bytes

#print axioms PointerRelay.Stopped

#print axioms PointerRelay.step_deterministic

#print axioms PointerRelay.stopped_no_step

#print axioms PointerRelay.execute_stopped

#print axioms PointerRelay.terminal_unique

#print axioms PointerRelay.complete_execution_refines

#print axioms PointerRelay.terminal_execution_exists

#print axioms PointerRelay.Steps.event_source

#print axioms PointerRelay.run_trace_safe

#print axioms PointerRelay.EventEffect

#print axioms PointerRelay.store_nil

#print axioms PointerRelay.step_event_effect

#print axioms PointerRelay.reachable_event_effect

#print axioms PointerRelay.readNext_primitive

#print axioms PointerRelay.writeNext_primitive

#print axioms PointerRelay.reachable_pointer_view

#print axioms PointerRelay.Examples.short_then_zero

#print axioms PointerRelay.Examples.retry_events

#print axioms PointerRelay.Examples.error_before_eof

#print axioms PointerRelay.Examples.reused_binary_buffer

#print axioms PointerRelay.Examples.first_read_error

#print axioms PointerRelay.Examples.first_write_error
