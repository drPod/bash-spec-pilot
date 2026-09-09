(* Assumption audit for the concrete execution witness (adequacy-resume-3).
   Check prints the exact statements; Print Assumptions lists every axiom.
   Expected: only Coq standard classical axioms and the two CompCert
   parameters Events.external_functions_sem / Events.inline_assembly_sem
   (they enter through the type of Clight_core.step, which mentions
   external_call).  No Jsub premise, no VST axiom, no project axiom, no
   Admitted.  The AST identity of the exit wrapper is re-checked. *)
Require relay relay_main.
Require Import relay_exit Terminate.

Check (eq_refl : relay_exit.f_relay = relay_main.f_relay).
Check (eq_refl : relay_exit.f_relay = relay.f_relay).

Check relay_body_eq.
Print Assumptions relay_body_eq.
Check main_body_eq.
Print Assumptions main_body_eq.
Check read_ext_step.
Print Assumptions read_ext_step.
Check write_ext_step.
Print Assumptions write_ext_step.
Check seg_init.
Print Assumptions seg_init.
Check sim_step.
Print Assumptions sim_step.
Check sim_run.
Print Assumptions sim_run.
Check relay_exit_termination.
Print Assumptions relay_exit_termination.
Check relay_exit_termination_dry.
Print Assumptions relay_exit_termination_dry.
