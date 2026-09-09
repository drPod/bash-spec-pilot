(* `Print Assumptions` of every theorem/example in this directory. Expected:
   every line reads "Closed under the global context": no axiom, no
   `Admitted`, no project-local hypothesis. *)
Require Import Pipeline.
Require Import Redirect.
Require Import Bridge2.
Require Import ParseExpansion.
Import ShellPipeline ShellRedirect ShellPipeBridge ShellExpansionText.

Print Assumptions pstep_fn_capacity.
Print Assumptions prun_capacity.
Print Assumptions demo_backpressure_after_two_steps.
Print Assumptions demo_pipeline_success.
Print Assumptions demo_sigpipe.
Print Assumptions pipeline_status_examples.

Print Assumptions relay_prim_delivered_extra.
Print Assumptions redirect_underlying_exec.
Print Assumptions redirect_open_failure.
Print Assumptions redirect_truncate_witness.
Print Assumptions redirect_truncate_observations.
Print Assumptions redirect_append_witness.
Print Assumptions redirect_truncate_witness_over_existing.
Print Assumptions redirect_append_vs_truncate.
Print Assumptions redirect_then_direct_sees_restored_stream.
Print Assumptions redirect_empty_path_rejected.
Print Assumptions redirect_within_seq.

Print Assumptions pipe_then_mark_exec.

Print Assumptions parse_relay_pipe_relay.
Print Assumptions parse_relay_gt_out.
Print Assumptions parse_relay_gtgt_log.
Print Assumptions parse_mark_bare.
Print Assumptions parse_rejects_oror.
Print Assumptions parse_rejects_unknown_name.
Print Assumptions parse_rejects_three_pipe.
Print Assumptions parse_rejects_double_redirect.
Print Assumptions parse_relay_gt_out_runs_as_checked.
