(* Diagnostic-only: bisects which mkComponent obligation is slow for
   CatFragmentVSU (real CatFragmentVSU.v timed out at 180s, receipt
   linking3-CatFragmentVSU-2, exit 124). Inlines VST.floyd.VSU's own
   mkComponent tactic script verbatim (container source, VSU.v lines
   580-615) with an idtac marker before/after each of its 10 bulleted
   obligations, so a kill mid-run still shows the last marker printed
   before the interrupt. Not a proof of any accepted theorem: ends in
   Admitted, never Qed, and is not cited as evidence in RESULTS.md. *)
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

Lemma CatFragmentVSU_diag : @VSU NullExtension.Espec
      nil CatFragment_imported_specs CatFragment_p CatFragment_ASI CatFragment_GP.
Proof.
  exists CatFragment_ASI.
  idtac "SETUP0(exists) done".
  hnf.
  match goal with |- Component _ _ ?IMPORTS _ _ _ _ =>
     let i := compute_list IMPORTS in
     let IMP := fresh "IMPORTS" in
     pose (IMP := @abbreviate funspecs i);
     change_no_check IMPORTS with IMP
  end.
  idtac "SETUP1 done".
  test_Component_prog_computed.
  idtac "SETUP2 done".
  let p := fresh "p" in
  match goal with |- @Component _ _ _ _ ?pp _ _ _ => set (p:=pp) end.
  idtac "SETUP3 done".
  assert (HA: PTree_samedom cenv_cs ha_env_cs) by repeat constructor.
  assert (LA: PTree_samedom cenv_cs la_env_cs) by repeat constructor.
  idtac "SETUP4 done".
  assert (OK: QPprogram_OK p)
   by (split; [apply compute_list_norepet_e; reflexivity
           |  apply (QPcompspecs_OK_i HA LA) ]).
  idtac "SETUP5(OK) done".
  pose (myenv:= (QP.prog_comp_env (QPprogram_of_program prog ha_env_cs la_env_cs))).
  assert (CSeq: _ = compspecs_of_QPcomposite_env myenv (proj2 OK))
   by (apply compspecs_eq_of_QPcomposite_env; reflexivity).
  subst myenv.
  change (QPprogram_of_program prog ha_env_cs la_env_cs) with p in CSeq.
  clear HA LA.
  idtac "SETUP6(CSeq) done -- entering exists OK; bullets".
  exists OK;
  [ idtac "B1 start"; check_Comp_Imports_Exports; idtac "B1 done"
  | idtac "B2 start"; (apply compute_list_norepet_e; reflexivity || fail "dup Externs++Imports"); idtac "B2 done"
  | idtac "B3 start"; (apply compute_list_norepet_e; reflexivity || fail "dup Exports"); idtac "B3 done"
  | idtac "B4 start"; (apply compute_list_norepet_e; reflexivity); idtac "B4 done"
  | idtac "B5 start"; (apply forallb_isSomeGfunExternal_e; reflexivity); idtac "B5 done"
  | idtac "B6 start"; prove_Comp_G_dom; idtac "B6 done"
  | idtac "B7 start";
    (let i := fresh in let H := fresh in
     intros i H; first [ solve contradiction | simpl in H];
     repeat (destruct H; [ subst; reflexivity |]); try contradiction);
    idtac "B7 done"
  | idtac "B8 start";
    (apply prove_G_justified;
     repeat apply Forall_cons; [ .. | apply Forall_nil];
     try SF_vacuous);
    idtac "B8 done (residual internal-body goals expected)"
  | idtac "B9 start"; finishComponent; idtac "B9 done"
  | idtac "B10 start";
    (first [ solve [intros; apply derives_refl] | solve [intros; reflexivity]
           | solve [intros; simpl; cancel] | idtac ]);
    idtac "B10 done"
  ].
  idtac "ALL BULLETS DISPATCHED".
Admitted.
