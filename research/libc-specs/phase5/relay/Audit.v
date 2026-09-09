Require Import Protocol Reach ReachExamples Specs Conservation Progress Body Main Determinism Evaluator Distinguish.
Print Assumptions RelayProtocol.min_bounds.
Print Assumptions RelayProtocol.max_one_positive.
Print Assumptions RelayProtocol.read_amount_bounds.
Print Assumptions RelayProtocol.read_amount_positive.
Print Assumptions RelayProtocol.prefix_length.
Print Assumptions RelayProtocol.prefix_suffix.
Print Assumptions RelayProtocol.read_ret_bounds.
Print Assumptions RelayProtocol.read_conservation.
Print Assumptions RelayProtocol.read_preserves_output.
Print Assumptions RelayProtocol.read_schedule_effect.
Print Assumptions RelayProtocol.read_counter_effect.
Print Assumptions RelayProtocol.read_success_length.
Print Assumptions RelayProtocol.read_error_first.
Print Assumptions RelayProtocol.read_zero_only_empty.
Print Assumptions RelayProtocol.write_ret_bounds.
Print Assumptions RelayProtocol.write_effect.
Print Assumptions RelayProtocol.write_schedule_effect.
Print Assumptions RelayProtocol.write_counter_effect.
Print Assumptions RelayProtocol.write_success_prefix.
Print Assumptions RelayProtocol.write_nonpositive_no_bytes.
Print Assumptions RelayProtocol.write_success_partition.
Print Assumptions RelayProtocol.write_nonpositive_preserves_channels.
Print Assumptions RelayProtocol.valid_tail.
Print Assumptions RelayProtocol.read_valid_world.
Print Assumptions RelayProtocol.write_valid_world.
Print Assumptions RelayProtocol.read_total.
Print Assumptions RelayProtocol.write_total.
Print Assumptions RelayProtocol.delivered_then_read_error.
Print Assumptions RelayProtocol.short_write_then_zero.
Print Assumptions RelayReach.reaches_valid.
Print Assumptions RelayReach.outcome_status.
Print Assumptions empty_eof_outcome.
Print Assumptions empty_error_outcome.
Print Assumptions read_a_reachable.
Print Assumptions written_a_reachable.
Print Assumptions read_error_outcome.
Print Assumptions read_error_observations.
Print Assumptions read_b_reachable.
Print Assumptions written_b_reachable.
Print Assumptions zero_write_outcome.
Print Assumptions zero_write_observations.
Print Assumptions Specs.CompSpecs.
Print Assumptions Specs.Gprog.
(* Conservation.v (abstract-contract consequences) *)
Print Assumptions RelayConservation.reaches_phase_bounds.
Print Assumptions RelayConservation.reaches_drain_bounds.
Print Assumptions RelayConservation.read_nonpositive_no_bytes.
Print Assumptions RelayConservation.read_eof_final_empty.
Print Assumptions RelayConservation.reaches_conservation.
Print Assumptions RelayConservation.reaches_delivered_extension.
Print Assumptions RelayConservation.reaches_new_output_partition.
Print Assumptions RelayConservation.outcome_conservation.
Print Assumptions RelayConservation.outcome_eof_pending.
Print Assumptions RelayConservation.outcome_read_error_pending.
Print Assumptions RelayConservation.outcome_write_error_pending.
Print Assumptions RelayConservation.outcome_success_exact.
(* Progress.v (abstract progress/termination, not C termination) *)
Print Assumptions RelayProgress.reaches_progress.
Print Assumptions RelayProgress.reaches_halts_within.
Print Assumptions RelayProgress.outcome_exists.
(* Body.v: VST semax_body for the generated f_relay under Specs.v contracts *)
Check Body.body_relay.
Print Assumptions Body.tuchar_subarray_offset.
Print Assumptions Body.buffer_prefix_forget.
Print Assumptions Body.buffer_prefix_empty.
Print Assumptions Body.byte_array_split.
Print Assumptions Body.buffer_prefix_rejoin.
Print Assumptions Body.sem_add_ptr_long_tuchar.
Print Assumptions Body.body_relay.
(* Main.v: wrapper program relay_main (relay.c unchanged + main) *)
Check Main.body_relay.
Check Main.body_main.
Check Main.prog_correct.
Print Assumptions Main.body_relay.
Print Assumptions Main.body_main.
Print Assumptions Main.prog_correct.
(* Determinism.v: outcome = iterated executable step; Halt outcomes unique *)
Print Assumptions RelayDeterminism.reaches_run.
Print Assumptions RelayDeterminism.run_reaches.
Print Assumptions RelayDeterminism.outcome_run.
Print Assumptions RelayDeterminism.outcome_unique.
(* Evaluator.v: fuel-bounded executable evaluator, sound and total *)
Print Assumptions RelayEvaluator.step_measure.
Print Assumptions RelayEvaluator.run_halts_within.
Print Assumptions RelayEvaluator.eval_sound.
Print Assumptions RelayEvaluator.eval_total.
Print Assumptions RelayEvaluator.eval_a.
Print Assumptions RelayEvaluator.eval_b.
(* Distinguish.v: the contract admits exactly one status on each witness *)
Print Assumptions RelayDistinguish.no_false_success_a.
Print Assumptions RelayDistinguish.no_write_error_a.
Print Assumptions RelayDistinguish.no_false_success_b.
Print Assumptions RelayDistinguish.no_read_error_b.
Print Assumptions RelayDistinguish.pending_forced_b.
