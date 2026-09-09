(* Diagnostic-only, single-candidate isolation for CatFragmentVSU bullet 10
   (Comp_MkInitPred GP entailment). Not evidence. *)
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
Definition CatFragment_ASI : funspecs :=
  [simple_cat_spec _errno _simple_cat _input_desc _infile;
   CatEntryBody.simple_cat_entry_spec _errno _simple_cat_entry _input_desc _infile].

Definition CatFragment_p := ltac:(QPprog prog).
Definition CatFragment_GP (gv : globals) : mpred := InitGPred (Vardefs CatFragment_p) gv.

Lemma CatFrag_gp_unfoldp : @VSU NullExtension.Espec
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
  idtac "reached bullets".
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
  | (
     idtac "trying: intros; unfold p; apply derives_refl"; intros; unfold p; apply derives_refl; idtac "succeeded: intros; unfold p; apply derives_refl")
  ].
  idtac "bullet10 fully closed for: intros; unfold p; apply derives_refl".
Qed.
