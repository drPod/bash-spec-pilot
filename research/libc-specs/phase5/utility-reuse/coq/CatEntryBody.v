(* semax_body for simple_cat_entry (cat_fragment.v): the one-call retention
   wrapper CompCert's frontend needed because it drops an unreferenced
   static function (PROVENANCE.md item 3). Not part of the cat.c byte
   fragment; the wrapper's own body is a single call to the verified
   f_simple_cat, so its contract is exactly simple_cat_spec transferred to
   the wrapper's identifier. This turns NEXT.md item 1's "simple_cat_entry
   either verified (trivial one-call body) or left as the sole export gap"
   into the former: verified. *)
Require Import VST.floyd.proofauto.
Require Import IOWorld IOSpecs.
Require Import cat_fragment.
Import IOW.
Local Open Scope Z_scope.

Definition Vprog : varspecs. mk_varspecs prog. Defined.

Definition simple_cat_entry_spec := simple_cat_spec.

Definition Gprog : funspecs :=
  ltac:(with_library prog
    [simple_cat_spec _errno _simple_cat _input_desc _infile;
     simple_cat_entry_spec _errno _simple_cat_entry _input_desc _infile]).

Lemma body_simple_cat_entry :
  semax_body Vprog Gprog f_simple_cat_entry
    (simple_cat_entry_spec _errno _simple_cat_entry _input_desc _infile).
Proof.
  start_function.
  forward_call (gv, s, p, n, e, sh, name).
  Intros ret. destruct ret as [[b t] e']. simpl fst in *; simpl snd in *.
  forward.
  Exists b t e'.
  entailer!.
  destruct b; reflexivity.
Qed.
