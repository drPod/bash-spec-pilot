import StatefulFinal

/- `#print axioms` for StatefulFinal. Expected: BufferRelay's standard
   propext/Classical.choice/Quot.sound only. No project axioms, no sorryAx. -/
#print axioms StatefulFinal.advanceUnread_reads_structural
#print axioms StatefulFinal.advanceUnread_writes_structural
#print axioms StatefulFinal.redirect_then_direct_uses_residual
#print axioms StatefulFinal.redirect_then_mark_success
#print axioms StatefulFinal.empty_path_andThen_preserves
#print axioms StatefulFinal.consumed_two_directs
#print axioms StatefulFinal.reset_two_directs
#print axioms StatefulFinal.reset_and_consumed_differ
#print axioms StatefulFinal.general_redirect_then_direct
#print axioms StatefulFinal.stepPrim_empty_path
#print axioms StatefulFinal.read_error_then_recovers
#print axioms StatefulFinal.reset_repeats_error

#print axioms ScheduleConsumption.executeI_proj
#print axioms ScheduleConsumption.executeI_reads_drop
#print axioms ScheduleConsumption.executeI_writes_drop
#print axioms ScheduleConsumption.runDetailed_reads_drop
#print axioms ScheduleConsumption.runDetailed_writes_drop
#print axioms StatefulFinal.abc_readCalls
