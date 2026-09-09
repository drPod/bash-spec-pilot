(* Diagnostic-only, continuation of CatFragmentVSU_diag.v: bullets 1-9 of
   mkComponent's automation all dispatch quickly for CatFragmentVSU; the
   whole run hangs inside bullet 10 (Comp_MkInitPred, the GP entailment
   "first [derives_refl | reflexivity | simpl;cancel | idtac]"). This file
   isolates which of the three real candidates inside that `first` is the
   one that doesn't terminate, by trying each individually under an Ltac
   Timeout so a hang shows up as a printed timeout marker instead of
   silently absorbing the whole run. Not evidence; ends in Admitted. *)
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

Lemma CatFragmentVSU_diag2 : @VSU NullExtension.Espec
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
  | (idtac "B10 start";
     idtac "B10: trying derives_refl (15s cap)";
     (try (Timeout 15 (intros; apply derives_refl)));
     idtac "B10: derives_refl attempt finished (or goal still open)";
     idtac "B10: trying reflexivity (15s cap)";
     (try (Timeout 15 reflexivity));
     idtac "B10: reflexivity attempt finished (or goal still open)";
     idtac "B10: trying simpl alone (15s cap)";
     (try (Timeout 15 simpl));
     idtac "B10: simpl attempt finished";
     idtac "B10: trying cancel after simpl (15s cap)";
     (try (Timeout 15 cancel));
     idtac "B10: cancel attempt finished")
  ].
  idtac "ALL BULLETS DISPATCHED (diag2)".
Admitted.
