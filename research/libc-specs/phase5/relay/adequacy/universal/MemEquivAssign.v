(* Extension of MemEquivStep.step_equiv_transfer to assignments
   (universal-relay-4, for the non-UTF-8 case studies; not needed by the relay
   programs).  Sassign steps go through assign_loc (Mem.store / storebytes /
   bitfield load+store); all three transfer along mem_equiv.  With this, the
   only states excluded from the transfer are builtins / inlined externals
   (CompCert's axiomatised external_call).  Separate file so that the accepted
   MemEquivStep.v is untouched. *)
Require Import VST.floyd.proofauto.
Require Import VST.veric.Clight_core.
Require Import VST.veric.Memory.
Require Import VST.veric.juicy_mem.
Require Import VST.veric.mem_lessdef.
Require Import VST.veric.Clight_mem_lessdef.
Require Import compcert.common.Globalenvs.
Require Import compcert.lib.Maps.
Require Import MemEquivStep.
Local Open Scope Z_scope.

Lemma equiv_load chunk m1 m2 b ofs :
  mem_equiv m1 m2 -> Mem.load chunk m1 b ofs = Mem.load chunk m2 b ofs.
Proof.
  intros (Hl & Hp & Hn).
  destruct (Mem.load chunk m1 b ofs) as [v |] eqn:L1.
  - destruct (Mem.load_loadbytes _ _ _ _ _ L1) as (bytes & Lb & ->).
    pose proof (Mem.load_valid_access _ _ _ _ _ L1) as [_ Hal].
    rewrite Hl in Lb. symmetry. apply Mem.loadbytes_load; assumption.
  - destruct (Mem.load chunk m2 b ofs) as [v |] eqn:L2; [| reflexivity].
    destruct (Mem.load_loadbytes _ _ _ _ _ L2) as (bytes & Lb & ->).
    pose proof (Mem.load_valid_access _ _ _ _ _ L2) as [_ Hal].
    rewrite <- Hl in Lb. rewrite (Mem.loadbytes_load _ _ _ _ _ Lb Hal) in L1. discriminate.
Qed.

Lemma equiv_store chunk m1 m2 b ofs v m1' :
  mem_equiv m1 m2 -> Mem.store chunk m1 b ofs v = Some m1' ->
  exists m2', Mem.store chunk m2 b ofs v = Some m2' /\ mem_equiv m1' m2'.
Proof.
  intros Heq S1.
  pose proof (Mem.store_valid_access_3 _ _ _ _ _ _ S1) as [_ Hal].
  apply Mem.store_storebytes in S1.
  destruct (equiv_storebytes _ _ _ _ _ _ Heq S1) as (m2' & S2 & Heq').
  exists m2'. split; [apply Mem.storebytes_store; assumption | exact Heq'].
Qed.

Lemma equiv_assign_loc ce ty m1 b ofs bf v m1' m2 :
  mem_equiv m1 m2 -> assign_loc ce ty m1 b ofs bf v m1' ->
  exists m2', assign_loc ce ty m2 b ofs bf v m2' /\ mem_equiv m1' m2'.
Proof.
  intros Heq Ha. pose proof Heq as (Hl & _ & _). inv Ha.
  - (* by value *)
    match goal with S : Mem.storev _ m1 _ _ = Some _ |- _ =>
      simpl in S; destruct (equiv_store _ _ _ _ _ _ _ Heq S) as (m2' & S2 & E) end.
    exists m2'. split; [eapply assign_loc_value; eauto | exact E].
  - (* by copy *)
    match goal with S : Mem.storebytes m1 _ _ _ = Some _ |- _ =>
      destruct (equiv_storebytes _ _ _ _ _ _ Heq S) as (m2' & S2 & E) end.
    exists m2'. split; [| exact E].
    eapply assign_loc_copy; try eassumption. rewrite <- Hl. eassumption.
  - (* bitfield *)
    match goal with SB : store_bitfield _ _ _ _ _ m1 _ _ _ _ |- _ => inv SB end.
    match goal with L : Mem.loadv _ m1 _ = Some _, S : Mem.storev _ m1 _ _ = Some _ |- _ =>
      simpl in L, S; destruct (equiv_store _ _ _ _ _ _ _ Heq S) as (m2' & S2 & E);
      exists m2'; split; [| exact E];
      eapply assign_loc_bitfield; econstructor; try eassumption; try reflexivity;
      simpl; rewrite <- (equiv_load _ _ _ _ _ Heq); exact L end.
Qed.

Section Step.
Variable ge : genv.

(* Only builtins / inlined externals are excluded now. *)
Definition nb_ext (q : CC_core) : Prop :=
  match q with
  | Clight_core.State _ (Sbuiltin _ _ _ _) _ _ _ => False
  | Clight_core.Callstate (External ef _ _ _) _ _ => ef_inline ef = false
  | _ => True
  end.

Lemma step_equiv_transfer_assign q m1 q1 m1' m2 :
  nb_ext q -> Clight_core.step ge q m1 q1 m1' -> mem_equiv m1 m2 ->
  exists m2', Clight_core.step ge q m2 q1 m2' /\ mem_equiv m1' m2'.
Proof.
  intros Hnb Hstep Heq.
  destruct q as [f s k e le | fd args k | v k]; [destruct s | destruct fd |];
    try (eapply step_equiv_transfer; [cbv [nb nb_ext] in *; first [exact I | exact Hnb] | exact Hstep | exact Heq]).
  (* Sassign *)
  inv Hstep; try (match goal with H : _ = _ \/ _ = _ |- _ => destruct H; discriminate end).
  pose proof (mem_equiv_lessalloc _ _ Heq) as M.
  match goal with A : assign_loc _ _ ?mm _ _ _ _ _, HE : mem_equiv ?mm m2 |- _ =>
    destruct (equiv_assign_loc _ _ _ _ _ _ _ _ m2 HE A) as (m2' & A2 & E) end.
  exists m2'. split; [| exact E].
  eapply step_assign; [eapply eval_lvalue_mem_lessalloc; eauto | eapply eval_expr_mem_lessalloc; eauto
                      | rewrite <- (sem_cast_mem_lessaloc M); eassumption | exact A2].
Qed.

End Step.

Check step_equiv_transfer_assign.
Print Assumptions step_equiv_transfer_assign.
