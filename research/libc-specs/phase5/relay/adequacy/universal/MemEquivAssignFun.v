(* Determinism of the Clight core step on nb_ext states (assignments included,
   builtins / inlined externals excluded), without VST's ef_deterministic_fun
   axiom.  Companion of MemEquivAssign.step_equiv_transfer_assign; together
   they are what the universal induction (UniversalMain.canon_universal's
   proof) needs for programs that store through pointers.  Not used by the
   relay theorems. *)
Require Import VST.floyd.proofauto.
Require Import VST.veric.Clight_core.
Require Import VST.veric.Clight_lemmas.
Require Import VST.msl.Coqlib2.
Require Import compcert.common.Globalenvs.
Require Import compcert.lib.Maps.
Require Import MemEquivStep MemEquivAssign.

Ltac fun_tac3 :=
  match goal with
  | H: ?A = Some _, H': ?A = Some _ |- _ => inversion2 H H'
  | H: ?A = fun_case_f _ _ _, H': ?A = fun_case_f _ _ _ |- _ => inversion2 H H'
  | H: Clight.eval_expr ?ge ?e ?le ?m ?A _, H': Clight.eval_expr ?ge ?e ?le ?m ?A _ |- _ =>
        apply (eval_expr_fun H) in H'; subst
  | H: Clight.eval_exprlist ?ge ?e ?le ?m ?A ?ty _, H': Clight.eval_exprlist ?ge ?e ?le ?m ?A ?ty _ |- _ =>
        apply (eval_exprlist_fun H) in H'; subst
  | H: Clight.eval_lvalue ?ge ?e ?le ?m ?A _ _ _, H': Clight.eval_lvalue ?ge ?e ?le ?m ?A _ _ _ |- _ =>
        apply (eval_lvalue_fun H) in H'; inv H'
  | H: Clight.assign_loc ?ge ?ty ?m ?b ?ofs ?bf ?v _, H': Clight.assign_loc ?ge ?ty ?m ?b ?ofs ?bf ?v _ |- _ =>
        apply (assign_loc_fun H) in H'; inv H'
  | H: Clight.alloc_variables ?ge ?e ?m ?vl _ _, H': Clight.alloc_variables ?ge ?e ?m ?vl _ _ |- _ =>
        apply (alloc_variables_fun H) in H'; inv H'
  end.

Section Step.
Variable ge : genv.

Lemma step_fun_nb_ext q m q1 m1 q2 m2 :
  nb_ext q -> Clight_core.step ge q m q1 m1 -> Clight_core.step ge q m q2 m2 -> (q1, m1) = (q2, m2).
Proof.
  intros Hnb H H0.
  inv H; inv H0; unfold nb_ext in Hnb; try contradiction;
  repeat fun_tac3; auto;
  repeat match goal with H: _ = _ \/ _ = _ |- _ => destruct H; try discriminate end;
  try contradiction.
  all: try (match goal with A : function_entry2 _ _ _ _ _ _ _, B : function_entry2 _ _ _ _ _ _ _ |- _ =>
              inv A; inv B end;
            repeat fun_tac3;
            try (match goal with A : alloc_variables _ _ _ _ _ _, B : alloc_variables _ _ _ _ _ _ |- _ =>
                   pose proof (alloc_variables_fun A B) as E; inv E end);
            auto).
  all: try (match goal with H : andb (ef_inline _) _ = true |- _ => rewrite Hnb in H; discriminate H end).
Qed.

End Step.

Check step_fun_nb_ext.
Print Assumptions step_fun_nb_ext.
