(* Wrapper-ident link for wc_lines_entry. Twin of CaseTransfer.v; separate
   file because wc_lines_fragment.v and head_bytes_fragment.v are distinct
   Clight TUs (distinct CompSpecs / idents). Same lifting pattern as
   CatFragmentVSU.v: import WcLinesBody.body_wc_lines, subsume onto a Gprog
   that also names wc_lines_entry, prove the one-call wrapper in that Gprog.

   Does not re-prove WcLinesBody.v. Not a VSU, not GNU main, not
   wc_lines_null_spec. *)
Require Import VST.floyd.proofauto.
Require Import IOWorld CaseWorld.
Require Import IOSpecs CaseSpecs.
Require Import wc_lines_fragment.
Require Import WcLinesBody.
Import IOW.
Local Open Scope Z_scope.

Definition Vprog := WcLinesBody.Vprog.

Definition wc_lines_entry_spec := wc_lines_spec.

Definition Gprog : funspecs :=
  WcLinesBody.Gprog ++
    [wc_lines_entry_spec _errno _wc_lines_entry].

Definition body_wc_lines_lifted :
  semax_body Vprog Gprog f_wc_lines
    (wc_lines_spec _errno _wc_lines).
Proof.
  eapply semax_body_subsumption; [ exact WcLinesBody.body_wc_lines | ].
  apply tycontext_sub_Gprog_app1.
  + apply compute_list_norepet_e; reflexivity.
  + apply compute_list_norepet_e; reflexivity.
Qed.

Lemma body_wc_lines_entry :
  semax_body Vprog Gprog f_wc_lines_entry
    (wc_lines_entry_spec _errno _wc_lines_entry).
Proof.
  start_function.
  forward_call (gv, s, fname, lp, bp, shl, shb, e).
  Intros vret. destruct vret as [[[[t e'] b] lines] bytes]. simpl fst in *; simpl snd in *.
  forward.
  Exists t e' b lines bytes.
  entailer!.
  destruct b; reflexivity.
Qed.
