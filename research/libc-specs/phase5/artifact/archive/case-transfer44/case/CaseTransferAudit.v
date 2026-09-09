(* Assumption audit for the four wrapper-ident / Gprog-lift lemmas
   in CaseTransfer.v and CaseTransferWc.v.

   Print Assumptions of ALL FOUR is required (not optional).
   The two Clight TUs have distinct CompSpecs; requiring both
   fragments in one compilation unit leaks CompSpecs. This file
   therefore audits the head_bytes TU. The wc_lines twin is the
   same commands against CaseTransferWc (separate coqc).

   Expected: only standard VST / CompCert axioms; no Admitted;
   no project axioms. Wrapper and callee share one Gprog. *)
Require Import CaseTransfer.

Print Assumptions body_head_bytes_lifted.
Print Assumptions body_head_bytes_entry.
Check body_head_bytes_lifted.
Check body_head_bytes_entry.
Check Gprog.
Check Vprog.
