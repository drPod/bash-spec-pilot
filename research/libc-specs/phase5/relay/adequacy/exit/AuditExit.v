(* Assumption audit for the exit-wrapper chain (adequacy-resume-2).
   Check prints the exact statements (with the implicit Espec of prog_correct);
   Print Assumptions lists every axiom each theorem depends on.  No project
   axiom, no Admitted: everything printed must be a Coq standard-library
   classical axiom, a VST axiom (lib.Axioms.proof_irr,
   Clight_core.inline_external_call_mem_events, ef_deterministic_fun) or a
   CompCert parameter (Events.external_functions_sem, Events.inline_assembly_sem).
   Jsub appears as the first quantified premise of relay_exit_dry_safety and
   relay_exit_outcome, not as an axiom.

   AST preservation: relay_exit.f_relay is definitionally equal to
   relay_main.f_relay and relay.f_relay (checked by eq_refl below). *)
Require relay relay_main.
Require Import relay_exit MainExit DryExit SafetyExit ExitOutcome.

Check (eq_refl : relay_exit.f_relay = relay_main.f_relay).
Check (eq_refl : relay_exit.f_relay = relay.f_relay).

Set Printing Implicit.
Check @prog_correct.
Unset Printing Implicit.
Print Assumptions prog_correct.

Check exit_juicy_dry_specs.
Print Assumptions exit_juicy_dry_specs.
Check exit_dry_spec_mem.
Print Assumptions exit_dry_spec_mem.

Check init_mem_exists.
Print Assumptions init_mem_exists.
Check relay_exit_dry_safety.
Print Assumptions relay_exit_dry_safety.

Check exit_ef_in_prog.
Print Assumptions exit_ef_in_prog.
Check exit_dry_pre_inv.
Print Assumptions exit_dry_pre_inv.
Check exit_dry_post_False.
Print Assumptions exit_dry_post_False.
Check relay_exit_outcome.
Print Assumptions relay_exit_outcome.
