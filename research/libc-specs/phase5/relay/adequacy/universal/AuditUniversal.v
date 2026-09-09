(* Assumption audit for the universal execution theorems (universal-relay-4).
   Check prints the exact statements; Print Assumptions lists every axiom.
   Expected: only Coq's standard classical axioms (classic, prop_ext,
   functional_extensionality_dep, sig_not_dec, sig_forall_dec) and the two
   CompCert parameters Events.external_functions_sem / inline_assembly_sem
   (they enter through the type of Clight_core.step).  NOT expected: Jsub,
   ef_deterministic_fun, inline_external_call_mem_events, proof_irr, or any
   project axiom or Admitted.  The AST identities are re-checked. *)
Require relay relay_main relay_exit.
Require MemEquivStep UniversalMain UniversalExit.

Check (eq_refl : relay_exit.f_relay = relay_main.f_relay).
Check (eq_refl : relay_exit.f_relay = relay.f_relay).

Check MemEquivStep.step_equiv_transfer.
Print Assumptions MemEquivStep.step_equiv_transfer.
Check MemEquivStep.step_fun_nb.
Print Assumptions MemEquivStep.step_fun_nb.
Check MemEquivStep.equiv_storebytes.
Print Assumptions MemEquivStep.equiv_storebytes.

Check UniversalMain.pre_transfer.
Check UniversalMain.post_pins.
Check UniversalMain.ext_transfer.
Print Assumptions UniversalMain.ext_transfer.
Check UniversalMain.dstep_det.
Print Assumptions UniversalMain.dstep_det.
Check UniversalMain.canon_universal.
Print Assumptions UniversalMain.canon_universal.
Check UniversalMain.relay_main_universal.
Print Assumptions UniversalMain.relay_main_universal.

Check UniversalExit.ext_transfer.
Print Assumptions UniversalExit.ext_transfer.
Check UniversalExit.exit_terminal.
Print Assumptions UniversalExit.exit_terminal.
Check UniversalExit.canon_universal.
Print Assumptions UniversalExit.canon_universal.
Check UniversalExit.relay_exit_universal.
Print Assumptions UniversalExit.relay_exit_universal.
