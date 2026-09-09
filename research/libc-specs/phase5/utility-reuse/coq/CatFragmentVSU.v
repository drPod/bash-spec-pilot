(* VSU component for the byte-extracted simple_cat fragment (cat_fragment.v):
   imports safe_read_spec, full_write_spec (from SafeReadVSU.v/FullWriteVSU.v)
   and the unverified coreutils externals (quotearg_n_style_colon, error,
   write_error); exports the simple_cat contract proved in CatBody.v and the
   simple_cat_entry retention-wrapper contract proved in CatEntryBody.v (both
   internal functions of this TU; see PROVENANCE.md item 3). GP convention as
   in SafeReadVSU.v: this TU's globals are _errno, _input_desc, _infile and
   a string-literal Gvar (___stringlit_1, cat_fragment.v has 4 Gvars against
   1 for the leaf wrapper TUs), all with real Init_space initializers, so
   InitGPred (Vardefs p) is a nontrivial (not emp) resource, still discharged
   uniformly by taking GP to be exactly that predicate.

   Bullet 10 of VST's own `mkComponent` (floyd/VSU.v, the Comp_MkInitPred
   obligation `InitGPred (Vardefs p) gv |-- GP gv`) cannot be dispatched by
   its own automation here: `mkVSU prog CatFragment_ASI.` (i.e. running all
   10 of mkComponent's bullets, including its own
   `first [derives_refl | reflexivity | simpl;cancel | idtac]` for this
   bullet) hung past a 180s wall limit (receipt linking3-CatFragmentVSU-2,
   exit 124) and past a 90s limit rerunning the identical script
   (linking4-diag-2, exit 124) for the four single-Gvar leaf TUs (SafeRead/
   SafeWrite/FullWriteVSU) this same automation, unchanged, closes in ~1.2s
   each. Isolated bisection (linking4-diag-2, linking4-gpderives-1) pinned
   the hang to bullet 10's first candidate, `intros; apply derives_refl`,
   alone (>40s, linking4-gpderives-1); `unfold p` first did not help
   (linking4-gpunfoldp-1, still >40s) so it is not local-variable opacity.
   Forcing the whole entailment through `vm_compute` does terminate (~35s)
   but exhausts the container's 3GiB cap trying to fully unfold the
   `InitGPred`/mpred *semantic* value (linking4-gpvmeq-1, exit 134, OOM,
   peak RSS 2.87GiB) — `apply`'s general unifier and `vm_compute` both try
   to compare the two sides by expanding the separation-logic model itself,
   which does not scale with the extra Gvars/string literal here the way it
   did for the leaf TUs' single `_errno` Gvar.

   The fix used below (`CatFragment_gp_obligation`) never asks Coq to
   compare or unfold the two `InitGPred (...) gv` *mpred values* at all: it
   proves the cheap, first-order fact `Vardefs p = Vardefs CatFragment_p`
   (plain data, a `list (ident * globvar type)`, decidable by `vm_compute;
   reflexivity`, no separation-logic model involved) and then `rewrite`s
   that equality so the two sides of the entailment become the *same
   syntactic term*, closed by `apply derives_refl` doing zero further
   unfolding. Isolated, this closes bullet 10 in 1.36s total wall time
   (linking4-gpvardefseq-1, exit 1 only because that isolated file
   deliberately left bullet 8's two internal-body goals as `Qed`-incomplete;
   see STATUS.md). Everything else here is VST's own unmodified mkComponent
   script (bullets 1-9), copied verbatim from floyd/VSU.v so the proof
   obligations discharged are identical to what `mkVSU`/`mkComponent` would
   produce; only bullet 10's tactic differs, and the VSU statement itself
   (imports/exports/GP) is unchanged from the file mkVSU could not finish. *)
Require Import VST.floyd.proofauto.
Require Import VST.floyd.VSU.
Require Import VST.veric.NullExtension.
Require Import IOWorld IOSpecs.
Require Import cat_fragment.
Require Import CatBody.
Require Import CatEntryBody.
Import IOW.

Definition CatFragment_imported_specs : funspecs :=
  [safe_read_spec _errno _safe_read; full_write_spec _errno _full_write;
   quotearg_spec _quotearg_n_style_colon; error_spec _error;
   write_error_spec _write_error].
(* Source order in cat_fragment.v: simple_cat (the extracted fragment),
   then simple_cat_entry (appended after, PROVENANCE.md item 3). Both are
   exported: the fragment's own contract, and the retention wrapper's
   (verified in CatEntryBody.v, not left as a gap). *)
Definition CatFragment_ASI : funspecs :=
  [simple_cat_spec _errno _simple_cat _input_desc _infile;
   CatEntryBody.simple_cat_entry_spec _errno _simple_cat_entry _input_desc _infile].

Definition CatFragment_p := ltac:(QPprog prog).
Definition CatFragment_GP (gv : globals) : mpred := InitGPred (Vardefs CatFragment_p) gv.

(* The VSU's internal Gprog is `Imports ++ CatFragment_ASI` (7 entries: the
   5 imports, then both exports), because bullet 8 (prove_G_justified)
   checks every internal function's SF against that one shared Gprog. But
   CatBody.v's body_simple_cat was proved (and accepted, RESULTS.md) against
   a narrower Gprog with only 6 entries (no simple_cat_entry_spec, which did
   not exist yet when CatBody.v was written), and CatEntryBody.v's
   body_simple_cat_entry was proved against an even narrower 2-entry Gprog
   ([simple_cat_spec; simple_cat_entry_spec], no imports). Neither matches
   the VSU's Gprog syntactically, so solve_SF_internal's exact-match
   `apply_semax_body` cannot take the accepted lemmas directly (a real gap,
   not a proof-search difficulty). Reusing them literally (no edits to
   CatBody.v/CatEntryBody.v, no re-proof of the underlying semax_body) means
   lifting each along VST's own Gprog-weakening lemmas
   (floyd/forward.v: semax_body_subsumption, tycontext_sub_Gprog_app1/app2 —
   sound because `simple_cat`'s code never calls `simple_cat_entry` and
   neither body's proof used any spec beyond its own narrower Gprog, so
   adding unused entries changes nothing observable). *)
Definition body_simple_cat_lifted :
  semax_body CatBody.Vprog
    (CatBody.Gprog ++ [CatEntryBody.simple_cat_entry_spec _errno _simple_cat_entry _input_desc _infile])
    f_simple_cat (simple_cat_spec _errno _simple_cat _input_desc _infile).
Proof.
  eapply semax_body_subsumption; [ exact CatBody.body_simple_cat | ].
  apply tycontext_sub_Gprog_app1.
  + apply compute_list_norepet_e; reflexivity.
  + apply compute_list_norepet_e; reflexivity.
Qed.

Definition body_simple_cat_entry_lifted :
  semax_body CatEntryBody.Vprog (CatFragment_imported_specs ++ CatFragment_ASI)
    f_simple_cat_entry
    (CatEntryBody.simple_cat_entry_spec _errno _simple_cat_entry _input_desc _infile).
Proof.
  eapply semax_body_subsumption; [ exact CatEntryBody.body_simple_cat_entry | ].
  apply tycontext_sub_Gprog_app2.
  + apply compute_list_norepet_e; reflexivity.
  + apply compute_list_norepet_e; reflexivity.
Qed.

Definition CatFragmentVSU : @VSU NullExtension.Espec
      nil CatFragment_imported_specs CatFragment_p CatFragment_ASI CatFragment_GP.
Proof.
  exists CatFragment_ASI.
  hnf.
  match goal with |- Component _ _ ?IMPORTS _ _ _ _ =>
     let i := compute_list IMPORTS in
     let IMP := fresh "IMPORTS" in
     pose (IMP := @abbreviate funspecs i);
     change_no_check IMPORTS with IMP
  end.
  test_Component_prog_computed.
  let p := fresh "p" in
  match goal with |- @Component _ _ _ _ ?pp _ _ _ => set (p:=pp) end.
  assert (HA: PTree_samedom cenv_cs ha_env_cs) by repeat constructor.
  assert (LA: PTree_samedom cenv_cs la_env_cs) by repeat constructor.
  assert (OK: QPprogram_OK p)
   by (split; [apply compute_list_norepet_e; reflexivity
           |  apply (QPcompspecs_OK_i HA LA) ]).
  pose (myenv:= (QP.prog_comp_env (QPprogram_of_program prog ha_env_cs la_env_cs))).
  assert (CSeq: _ = compspecs_of_QPcomposite_env myenv (proj2 OK))
   by (apply compspecs_eq_of_QPcomposite_env; reflexivity).
  subst myenv.
  change (QPprogram_of_program prog ha_env_cs la_env_cs) with p in CSeq.
  clear HA LA.
  exists OK;
  [ check_Comp_Imports_Exports
  | (apply compute_list_norepet_e; reflexivity || fail "dup Externs++Imports")
  | (apply compute_list_norepet_e; reflexivity || fail "dup Exports")
  | (apply compute_list_norepet_e; reflexivity)
  | (apply forallb_isSomeGfunExternal_e; reflexivity)
  | prove_Comp_G_dom
  | (let i := fresh in let H := fresh in
     intros i H; first [ solve contradiction | simpl in H];
     repeat (destruct H; [ subst; reflexivity |]); try contradiction)
  | (apply prove_G_justified;
     repeat apply Forall_cons; [ .. | apply Forall_nil];
     try SF_vacuous)
  | finishComponent
  | (intros gv _;
     assert (Heq : Vardefs p = Vardefs CatFragment_p) by (vm_compute; reflexivity);
     unfold CatFragment_GP; rewrite Heq; apply derives_refl)
  ].
  + solve_SF_internal body_simple_cat_lifted.
  + solve_SF_internal body_simple_cat_entry_lifted.
Qed.
