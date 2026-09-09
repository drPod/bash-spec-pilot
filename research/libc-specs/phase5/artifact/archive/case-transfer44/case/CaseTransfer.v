(* Wrapper-ident link for head_bytes_entry (scope-audit-correction-23 NEXT.md
   item W: "wrapper-ident link analogous to body_simple_cat_entry +
   semax_body_subsumption"). `head_bytes_entry` is the one-call export wrapper
   CompCert's frontend needed because `head_bytes` is `static` (PROVENANCE.md).
   Same technique as CatEntryBody.v plus CatFragmentVSU.v lifting.

   Does not re-prove HeadBytesBody.v. This file imports the accepted
   `semax_body` and lifts it (semax_body_subsumption, tycontext_sub_Gprog_app1)
   onto a Gprog that also contains the wrapper ident, then proves the wrapper
   body against that *same* Gprog. A wrapper-only Gprog that merely assumes
   the callee funspec would compile `forward_call` without connecting the
   checked body.

   The wc_lines twin lives in CaseTransferWc.v (separate Clight TU / CompSpecs;
   Require-in-module of both fragments in one file leaks CompSpecs).

   Not a VSU, not GNU main, not wc_lines_null_spec. *)
Require Import VST.floyd.proofauto.
Require Import IOWorld CaseWorld.
Require Import IOSpecs CaseSpecs.
Require Import head_bytes_fragment.
Require Import HeadBytesBody.
Import IOW.
Local Open Scope Z_scope.

Definition Vprog := HeadBytesBody.Vprog.

Definition head_bytes_entry_spec := head_bytes_spec.

Definition Gprog : funspecs :=
  HeadBytesBody.Gprog ++
    [head_bytes_entry_spec _errno _head_bytes_entry].

Definition body_head_bytes_lifted :
  semax_body Vprog Gprog f_head_bytes
    (head_bytes_spec _errno _head_bytes).
Proof.
  eapply semax_body_subsumption; [ exact HeadBytesBody.body_head_bytes | ].
  apply tycontext_sub_Gprog_app1.
  + apply compute_list_norepet_e; reflexivity.
  + apply compute_list_norepet_e; reflexivity.
Qed.

Lemma body_head_bytes_entry :
  semax_body Vprog Gprog f_head_bytes_entry
    (head_bytes_entry_spec _errno _head_bytes_entry).
Proof.
  start_function.
  forward_call (gv, s, fname, N, e).
  Intros vret. destruct vret as [[t e'] b]. simpl fst in *; simpl snd in *.
  forward.
  Exists t e' b.
  entailer!.
  destruct b; reflexivity.
Qed.
