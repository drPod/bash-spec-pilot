(* Assumption audit for the shell-bridge layer. Run AFTER Shell, Parse and
   Fixtures compiled in this order; the receipt/log of this file is the only
   admissible evidence that the theorems below are closed. *)
Require Import Shell Parse Fixtures Bridge.
Import ShellComposition ShellText.

(* Shell.v: generic layer *)
Check @command_refines.
Check @query_transfer.
Print Assumptions command_refines.
Print Assumptions query_transfer.
(* Shell.v: relay instantiation (relay_prim = relay_spec POST predicate) *)
Print relay_prim.
Print Assumptions relay_status.
Print Assumptions relay_step_shape.
Print Assumptions relay_step_total.
Print Assumptions exec_ledgers.
Print Assumptions exec_relay_only_conservation.
Check relay_then_mark_query.
Print Assumptions relay_then_mark_query.
(* Shell.v: nonvacuity *)
Print Assumptions success_outcome.
Print Assumptions late_error_exec.
Print Assumptions success_exec.
Print Assumptions same_relay_bytes.
Print Assumptions different_composed_bytes.
Print Assumptions no_stdout_only_context.
Print Assumptions second_relay_outcome.
Print Assumptions pending_lost_then_fresh_relay.
Print Assumptions pending_lost_observations.
Print Assumptions nul255_outcome.
Print Assumptions nul255_exec.
Print Assumptions nul255_observations.
Print Assumptions late_error_query_instance.
(* Parse.v: token-level soundness and validation evaluator *)
Check parse_program_sound.
Print Assumptions parse_sound.
Print Assumptions parse_tokens_sound.
Print Assumptions parse_program_sound.
Print Assumptions run_reachable.
(* Fixtures.v: generated text -> AST -> run examples *)
Print Assumptions accept_0_parse.
Print Assumptions accept_0_run.
Print Assumptions accept_0_derivation.
Print Assumptions reject_0.
(* Bridge.v: text -> AST -> relay query *)
Require Import Bridge.
Import ShellBridge.
Print Assumptions relay_and_mark_text.
Print Assumptions relay_seq_text.
Print Assumptions relay_paren_text.
Print Assumptions unsupported_pipe_text.
Print Assumptions unknown_name_text.
Check relay_and_mark_text_query.
Print Assumptions relay_and_mark_text_query.
Print Assumptions relay_and_mark_text_witnesses.
Print Assumptions relay_seq_text_witness.
Print Assumptions relay_command_derives.
(* RandomFixtures.v: 200 random texts, bash is the oracle *)
Require Import RandomFixtures.
Print Assumptions random_0.
Print Assumptions random_199.
(* Lex.v: lexer soundness (characters -> tokens) *)
Require Import Lex.
Import ShellLex.
Check parse_program_sound_chars.
Print Assumptions take_ident_spec.
Print Assumptions lex_sound.
Print Assumptions lex_string_sound.
Print Assumptions parse_program_sound_chars.
