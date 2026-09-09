(* Print Assumptions on every theorem/example in Compose.v. *)
Require Import Compose.
Import ShellCompose.

Print Assumptions pipe_prim_delivered_extra.
Print Assumptions yredirect_underlying_exec.
Print Assumptions yredirect_open_failure.
Print Assumptions yredirect_relay_gt_out_matches_old.
Print Assumptions piperr_witness.
Print Assumptions pipe_redirect_witness.
Print Assumptions pipe_redirect_observations.
Print Assumptions ycompose_within_seq.
Print Assumptions match_urparen_some.
Print Assumptions parse_pipe_sound.
Print Assumptions parse_redir_sound.
Print Assumptions uparse_sound.
Print Assumptions parse_utokens_sound.
Print Assumptions parse_program3_sound.
Print Assumptions ex_accept_bare_relay.
Print Assumptions ex_accept_bare_mark.
Print Assumptions ex_accept_pipe.
Print Assumptions ex_accept_gt_out.
Print Assumptions ex_accept_gtgt_log.
Print Assumptions ex_accept_pipe_redirect.
Print Assumptions ex_accept_seq_redirect.
Print Assumptions ex_accept_and.
Print Assumptions ex_accept_or.
Print Assumptions ex_accept_paren_and.
Print Assumptions ex_reject_mismatched_pipe.
Print Assumptions ex_reject_three_stage_pipe.
Print Assumptions ex_reject_double_redirect.
Print Assumptions ex_reject_unknown_name.
Print Assumptions ex_reject_paren_redirect.
Print Assumptions ex_accept_pipe_redirect_derivation.
Print Assumptions ex_pipe_redirect_runs_as_checked.
