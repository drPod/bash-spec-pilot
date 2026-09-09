(* Generic memory-equivalence transfer for the Clight core semantics
   (universal-relay-4).

   The dry environment model (Trace.dry_step over Dry.relay_dry_spec /
   DryExit.exit_dry_spec) lets a scheduled read return ANY memory
   mem_equiv-equivalent to the Mem.storebytes result.  To turn the existential
   execution witnesses of Terminate.v / TerminateMain.v into statements about
   ALL executions, one needs: the Clight core step relation transfers along
   mem_equiv (same core state, equivalent memory -> same successor core state,
   equivalent successor memory).  This file proves that for every
   Clight_core.step constructor except the two that invoke CompCert's
   axiomatised external_call on an inlined builtin (step_builtin,
   step_external_function with ef_inline = true) and Sassign (assign_loc is not
   needed by the relay programs, which never store through a pointer; excluded
   here rather than proved, see nb below).  These exclusions are recorded as
   the explicit side condition `nb` on the source state; the canonical relay
   trajectories discharge it state by state.

   mem_equiv (VST 2.15 veric/mem_lessdef.v) is
     Mem.loadbytes m1 = Mem.loadbytes m2 /\ Mem.perm m1 = Mem.perm m2 /\
     Mem.nextblock m1 = Mem.nextblock m2,
   equivalently (mem_equiv'_spec) equal contents at readable locations,
   equal permissions, equal nextblock.  Program-independent; nothing here is
   about relay. *)
Require Import VST.floyd.proofauto.
Require Import VST.veric.Clight_core.
Require Import VST.veric.Memory.
Require Import VST.veric.juicy_mem.
Require Import VST.veric.mem_lessdef.
Require Import VST.veric.Clight_mem_lessdef.
Require Import VST.veric.Clight_lemmas.
Require Import VST.msl.Coqlib2.
Require Import compcert.common.Globalenvs.
Require Import compcert.lib.Maps.
Local Open Scope Z_scope.

(* ---------- memory operations along mem_equiv ---------- *)

Lemma all_undef_eq (l1 l2 : list memval) :
  (forall x, In x l1 -> x = Undef) -> (forall x, In x l2 -> x = Undef) ->
  length l1 = length l2 -> l1 = l2.
Proof.
  revert l2; induction l1 as [| a l1 IH]; intros [| c l2] H1 H2 Hl; simpl in *; try discriminate; [reflexivity|].
  rewrite (H1 a), (H2 c) by auto. f_equal. apply IH; auto.
Qed.

Lemma equiv_alloc m1 m2 lo hi m1' b :
  mem_equiv m1 m2 -> Mem.alloc m1 lo hi = (m1', b) ->
  exists m2', Mem.alloc m2 lo hi = (m2', b) /\ mem_equiv m1' m2'.
Proof.
  intros Heq Ha1.
  destruct (Mem.alloc m2 lo hi) as [m2' b2] eqn:Ha2.
  pose proof (Mem.alloc_result _ _ _ _ _ Ha1) as Hb1.
  pose proof (Mem.alloc_result _ _ _ _ _ Ha2) as Hb2.
  destruct Heq as (Hl & Hp & Hn).
  assert (Hbb : b2 = b) by (rewrite Hb1, Hb2; symmetry; exact Hn). clear Hb2. subst b2.
  exists m2'. split; [reflexivity|].
  assert (Hp' : Mem.perm m1' = Mem.perm m2').
  { extensionality b' ofs k p. apply prop_ext. split; intro Hpm.
    - pose proof (Mem.perm_alloc_inv _ _ _ _ _ Ha1 _ _ _ _ Hpm) as Hinv.
      destruct (eq_block b' b) as [E | NE].
      + subst b'. eapply Mem.perm_implies; [eapply Mem.perm_alloc_2; eauto | constructor].
      + eapply Mem.perm_alloc_1; [exact Ha2 |]. rewrite <- Hp. exact Hinv.
    - pose proof (Mem.perm_alloc_inv _ _ _ _ _ Ha2 _ _ _ _ Hpm) as Hinv.
      destruct (eq_block b' b) as [E | NE].
      + subst b'. eapply Mem.perm_implies; [eapply Mem.perm_alloc_2; eauto | constructor].
      + eapply Mem.perm_alloc_1; [exact Ha1 |]. rewrite Hp. exact Hinv. }
  split; [| split; [exact Hp' |]].
  2:{ rewrite (Mem.nextblock_alloc _ _ _ _ _ Ha1), (Mem.nextblock_alloc _ _ _ _ _ Ha2), Hn. reflexivity. }
  extensionality b' ofs n.
  destruct (zle n 0) as [Hn0 | Hn0].
  { rewrite !Mem.loadbytes_empty by lia. reflexivity. }
  destruct (peq b' b) as [E | NE].
  - subst b'.
    destruct (Mem.loadbytes m1' b ofs n) as [l1 |] eqn:L1; destruct (Mem.loadbytes m2' b ofs n) as [l2 |] eqn:L2.
    + f_equal. apply all_undef_eq.
      * intros x Hx. exact (Mem.loadbytes_alloc_same _ _ _ _ _ Ha1 _ _ _ _ L1 Hx).
      * intros x Hx. exact (Mem.loadbytes_alloc_same _ _ _ _ _ Ha2 _ _ _ _ L2 Hx).
      * rewrite (Mem.loadbytes_length _ _ _ _ _ L1), (Mem.loadbytes_length _ _ _ _ _ L2). reflexivity.
    + exfalso. pose proof (Mem.loadbytes_range_perm _ _ _ _ _ L1) as R.
      assert (R2 : Mem.range_perm m2' b ofs (ofs + n) Memtype.Cur Memtype.Readable)
        by (intros o Ho; rewrite <- Hp'; apply R; exact Ho).
      destruct (Mem.range_perm_loadbytes _ _ _ _ R2) as (l & L). congruence.
    + exfalso. pose proof (Mem.loadbytes_range_perm _ _ _ _ _ L2) as R.
      assert (R1 : Mem.range_perm m1' b ofs (ofs + n) Memtype.Cur Memtype.Readable)
        by (intros o Ho; rewrite Hp'; apply R; exact Ho).
      destruct (Mem.range_perm_loadbytes _ _ _ _ R1) as (l & L). congruence.
    + reflexivity.
  - destruct (plt b' (Mem.nextblock m1)) as [V | NV].
    + rewrite (Mem.loadbytes_alloc_unchanged _ _ _ _ _ Ha1 _ ofs n V).
      rewrite (Mem.loadbytes_alloc_unchanged _ _ _ _ _ Ha2 _ ofs n) by (unfold Mem.valid_block; rewrite <- Hn; exact V).
      rewrite Hl. reflexivity.
    + assert (NV' : ~ Mem.valid_block m1' b').
      { unfold Mem.valid_block in *. rewrite (Mem.nextblock_alloc _ _ _ _ _ Ha1). subst b. unfold Plt in *. lia. }
      assert (NV2 : ~ Mem.valid_block m2' b').
      { unfold Mem.valid_block in *. rewrite (Mem.nextblock_alloc _ _ _ _ _ Ha2), <- Hn. subst b. unfold Plt in *. lia. }
      destruct (Mem.loadbytes m1' b' ofs n) as [l1 |] eqn:L1.
      { exfalso. apply NV'. eapply Mem.perm_valid_block with (ofs := ofs).
        apply (Mem.loadbytes_range_perm _ _ _ _ _ L1). lia. }
      destruct (Mem.loadbytes m2' b' ofs n) as [l2 |] eqn:L2; [| reflexivity].
      exfalso. apply NV2. eapply Mem.perm_valid_block with (ofs := ofs).
      apply (Mem.loadbytes_range_perm _ _ _ _ _ L2). lia.
Qed.

Lemma equiv_free m1 m2 b lo hi m1' :
  mem_equiv m1 m2 -> Mem.free m1 b lo hi = Some m1' ->
  exists m2', Mem.free m2 b lo hi = Some m2' /\ mem_equiv m1' m2'.
Proof.
  intros Heq Hf1.
  pose proof (Mem.free_range_perm _ _ _ _ _ Hf1) as Hrp.
  destruct Heq as (Hl & Hp & Hn).
  assert (Hrp2 : Mem.range_perm m2 b lo hi Memtype.Cur Memtype.Freeable).
  { intros ofs Hofs. rewrite <- Hp. apply Hrp; exact Hofs. }
  destruct (Mem.range_perm_free _ _ _ _ Hrp2) as (m2' & Hf2).
  exists m2'. split; [exact Hf2|].
  assert (Hp' : Mem.perm m1' = Mem.perm m2').
  { extensionality b' ofs k p. apply prop_ext. split; intro Hpm.
    - pose proof (Mem.perm_free_3 _ _ _ _ _ Hf1 _ _ _ _ Hpm) as H1.
      eapply Mem.perm_free_1; [exact Hf2 | | rewrite <- Hp; exact H1].
      destruct (eq_block b' b) as [E | NE]; [| left; exact NE]. subst b'.
      destruct (zlt ofs lo); [right; left; lia|]. destruct (zle hi ofs); [right; right; lia|].
      exfalso. eapply Mem.perm_free_2; [exact Hf1 | | exact Hpm]. lia.
    - pose proof (Mem.perm_free_3 _ _ _ _ _ Hf2 _ _ _ _ Hpm) as H1.
      eapply Mem.perm_free_1; [exact Hf1 | | rewrite Hp; exact H1].
      destruct (eq_block b' b) as [E | NE]; [| left; exact NE]. subst b'.
      destruct (zlt ofs lo); [right; left; lia|]. destruct (zle hi ofs); [right; right; lia|].
      exfalso. eapply Mem.perm_free_2; [exact Hf2 | | exact Hpm]. lia. }
  split; [| split; [exact Hp' |]].
  2:{ rewrite (Mem.nextblock_free _ _ _ _ _ Hf1), (Mem.nextblock_free _ _ _ _ _ Hf2). exact Hn. }
  extensionality b' ofs n.
  destruct (zle n 0) as [Hn0 | Hn0].
  { rewrite !Mem.loadbytes_empty by lia. reflexivity. }
  (* disjoint from the freed range: both sides unchanged *)
  assert (Hsep : (b' <> b \/ lo >= hi \/ ofs + n <= lo \/ hi <= ofs) \/
                 (b' = b /\ lo < hi /\ lo < ofs + n /\ ofs < hi)).
  { destruct (eq_block b' b); [| left; left; assumption].
    destruct (zlt lo hi); [| left; right; left; lia].
    destruct (zle (ofs + n) lo); [left; right; right; left; lia|].
    destruct (zle hi ofs); [left; right; right; right; lia|]. right; lia. }
  destruct Hsep as [Hsep | (E & H1 & H2 & H3)].
  - rewrite (Mem.loadbytes_free _ _ _ _ _ Hf1 _ _ _ Hsep), (Mem.loadbytes_free _ _ _ _ _ Hf2 _ _ _ Hsep), Hl.
    reflexivity.
  - subst b'.
    (* an offset in both ranges lost its permission on both sides *)
    set (o := Z.max ofs lo).
    assert (Ho1 : lo <= o < hi) by (unfold o; lia).
    assert (Ho2 : ofs <= o < ofs + n) by (unfold o; lia).
    destruct (Mem.loadbytes m1' b ofs n) as [l1 |] eqn:L1.
    { exfalso. eapply Mem.perm_free_2; [exact Hf1 | exact Ho1 |].
      apply (Mem.loadbytes_range_perm _ _ _ _ _ L1). exact Ho2. }
    destruct (Mem.loadbytes m2' b ofs n) as [l2 |] eqn:L2; [| reflexivity].
    exfalso. eapply Mem.perm_free_2; [exact Hf2 | exact Ho1 |].
    apply (Mem.loadbytes_range_perm _ _ _ _ _ L2). exact Ho2.
Qed.

Lemma equiv_free_list l : forall m1 m2 m1',
  mem_equiv m1 m2 -> Mem.free_list m1 l = Some m1' ->
  exists m2', Mem.free_list m2 l = Some m2' /\ mem_equiv m1' m2'.
Proof.
  induction l as [| [[b lo] hi] l IH]; intros m1 m2 m1' Heq Hfl; simpl in *.
  - inv Hfl. exists m2; auto.
  - destruct (Mem.free m1 b lo hi) as [m1x |] eqn:Hf; [| discriminate].
    destruct (equiv_free _ _ _ _ _ _ Heq Hf) as (m2x & Hf2 & Heqx).
    rewrite Hf2. eapply IH; eauto.
Qed.

Lemma setN_get_eq vl : forall p c1 c2 q,
  (q < p \/ q >= p + Z.of_nat (length vl) -> ZMap.get q c1 = ZMap.get q c2) ->
  ZMap.get q (Mem.setN vl p c1) = ZMap.get q (Mem.setN vl p c2).
Proof.
  induction vl as [| v vl IH]; intros p c1 c2 q H; simpl.
  - apply H. simpl. lia.
  - apply IH. intro Hq. rewrite !ZMap.gsspec.
    destruct (ZIndexed.eq q p); [reflexivity|]. apply H. simpl in *. lia.
Qed.

Lemma equiv_storebytes m1 m2 b ofs bytes m1' :
  mem_equiv m1 m2 -> Mem.storebytes m1 b ofs bytes = Some m1' ->
  exists m2', Mem.storebytes m2 b ofs bytes = Some m2' /\ mem_equiv m1' m2'.
Proof.
  intros Heq Hs1.
  pose proof (Mem.storebytes_range_perm _ _ _ _ _ Hs1) as Hrp.
  apply mem_equiv'_spec in Heq. destruct Heq as (Hc & Hp & Hn).
  assert (Hrp2 : Mem.range_perm m2 b ofs (ofs + Z.of_nat (length bytes)) Memtype.Cur Memtype.Writable).
  { intros o Ho. rewrite <- Hp. apply Hrp; exact Ho. }
  destruct (Mem.range_perm_storebytes _ _ _ _ Hrp2) as (m2' & Hs2).
  exists m2'. split; [exact Hs2|].
  apply mem_equiv'_spec. split; [| split].
  - intros (b', o) Hr. change (Mem.perm m1' b' o Memtype.Cur Memtype.Readable) in Hr.
    pose proof (Mem.perm_storebytes_2 _ _ _ _ _ Hs1 _ _ _ _ Hr) as Hr1.
    unfold contents_at; simpl.
    rewrite (Mem.storebytes_mem_contents _ _ _ _ _ Hs1), (Mem.storebytes_mem_contents _ _ _ _ _ Hs2).
    rewrite !PMap.gsspec. destruct (peq b' b) as [E | NE].
    + subst b'. apply setN_get_eq. intros _. exact (Hc (b, o) Hr1).
    + exact (Hc (b', o) Hr1).
  - extensionality b' o k p. apply prop_ext. split; intro Hpm.
    + eapply Mem.perm_storebytes_1; [exact Hs2|]. rewrite <- Hp.
      eapply Mem.perm_storebytes_2; eauto.
    + eapply Mem.perm_storebytes_1; [exact Hs1|]. rewrite Hp.
      eapply Mem.perm_storebytes_2; eauto.
  - rewrite (Mem.nextblock_storebytes _ _ _ _ _ Hs1), (Mem.nextblock_storebytes _ _ _ _ _ Hs2). exact Hn.
Qed.

(* ---------- Clight pieces along mem_equiv ---------- *)

Lemma bool_val_equiv v t m1 m2 :
  mem_equiv m1 m2 -> Cop.bool_val v t m1 = Cop.bool_val v t m2.
Proof.
  intro Heq. pose proof (mem_equiv_lessalloc _ _ Heq) as M.
  unfold Cop.bool_val. rewrite (weak_valid_pointer_lessalloc M). reflexivity.
Qed.

Section Step.
Variable ge : genv.

Lemma equiv_alloc_variables vars : forall e m1 e' m1' m2,
  mem_equiv m1 m2 -> alloc_variables ge e m1 vars e' m1' ->
  exists m2', alloc_variables ge e m2 vars e' m2' /\ mem_equiv m1' m2'.
Proof.
  induction vars as [| [id ty] vars IH]; intros e m1 e' m1' m2 Heq Hav; inv Hav.
  - exists m2. split; [constructor | exact Heq].
  - match goal with Ha : Mem.alloc m1 0 _ = (?m1x, ?b1) |- _ =>
      destruct (equiv_alloc _ _ _ _ _ _ Heq Ha) as (m2x & Ha2 & Heqx) end.
    match goal with Hrest : alloc_variables ge _ _ vars e' m1' |- _ =>
      destruct (IH _ _ _ _ _ Heqx Hrest) as (m2' & Hav2 & Heq') end.
    exists m2'. split; [econstructor; eauto | exact Heq'].
Qed.

Lemma equiv_function_entry2 f vargs m1 e le m1' m2 :
  mem_equiv m1 m2 -> function_entry2 ge f vargs m1 e le m1' ->
  exists m2', function_entry2 ge f vargs m2 e le m2' /\ mem_equiv m1' m2'.
Proof.
  intros Heq Hfe. inv Hfe.
  match goal with Hav : alloc_variables ge empty_env m1 _ e m1' |- _ =>
    destruct (equiv_alloc_variables _ _ _ _ _ _ Heq Hav) as (m2' & Hav2 & Heq') end.
  exists m2'. split; [econstructor; eauto | exact Heq'].
Qed.

(* Side condition: the source state is not at a builtin, not at an assignment,
   and not an inlined external Callstate.  Only these three step forms invoke
   external_call / assign_loc. *)
Definition nb (q : CC_core) : Prop :=
  match q with
  | Clight_core.State _ (Sbuiltin _ _ _ _) _ _ _ => False
  | Clight_core.State _ (Sassign _ _) _ _ _ => False
  | Clight_core.Callstate (External ef _ _ _) _ _ => ef_inline ef = false
  | _ => True
  end.

(* THE transfer lemma: a core step from q in m1 is matched, in any m2
   equivalent to m1, by a step to the SAME core state and an equivalent memory. *)
Lemma step_equiv_transfer q m1 q1 m1' m2 :
  nb q -> Clight_core.step ge q m1 q1 m1' -> mem_equiv m1 m2 ->
  exists m2', Clight_core.step ge q m2 q1 m2' /\ mem_equiv m1' m2'.
Proof.
  intros Hnb Hstep Heq.
  pose proof (mem_equiv_lessalloc _ _ Heq) as M.
  inv Hstep; unfold nb in Hnb; try contradiction;
    try solve [exists m2; split; [econstructor; eauto | exact Heq]].
  - (* set *)
    exists m2; split; [| exact Heq]. eapply step_set. eapply eval_expr_mem_lessalloc; eauto.
  - (* call *)
    exists m2; split; [| exact Heq].
    eapply step_call; eauto.
    + eapply eval_expr_mem_lessalloc; eauto.
    + eapply eval_exprlist_mem_lessalloc; eauto.
  - (* ifthenelse *)
    exists m2; split; [| exact Heq].
    eapply step_ifthenelse; [eapply eval_expr_mem_lessalloc; eauto |].
    rewrite <- (bool_val_equiv _ _ _ _ Heq). assumption.
  - (* return None *)
    match goal with Hfl : Mem.free_list m1 _ = Some m1' |- _ =>
      destruct (equiv_free_list _ _ _ _ Heq Hfl) as (m2' & Hfl2 & Heq') end.
    exists m2'; split; [eapply step_return_0; eauto | exact Heq'].
  - (* return Some *)
    match goal with Hfl : Mem.free_list m1 _ = Some m1' |- _ =>
      destruct (equiv_free_list _ _ _ _ Heq Hfl) as (m2' & Hfl2 & Heq') end.
    exists m2'; split; [| exact Heq'].
    eapply step_return_1; eauto.
    + eapply eval_expr_mem_lessalloc; eauto.
    + rewrite <- (sem_cast_mem_lessaloc M). assumption.
  - (* skip at call cont *)
    match goal with Hfl : Mem.free_list m1 _ = Some m1' |- _ =>
      destruct (equiv_free_list _ _ _ _ Heq Hfl) as (m2' & Hfl2 & Heq') end.
    exists m2'; split; [eapply step_skip_call; eauto | exact Heq'].
  - (* switch *)
    exists m2; split; [| exact Heq].
    eapply step_switch; eauto. eapply eval_expr_mem_lessalloc; eauto.
  - (* internal function entry *)
    match goal with Hfe : function_entry2 ge _ _ m1 _ _ m1' |- _ =>
      destruct (equiv_function_entry2 _ _ _ _ _ _ _ Heq Hfe) as (m2' & Hfe2 & Heq') end.
    exists m2'; split; [eapply step_internal_function; eauto | exact Heq'].
  - (* inlined external: excluded by nb *)
    match goal with H : andb (ef_inline _) _ = true |- _ => rewrite Hnb in H; discriminate H end.
Qed.

(* Determinism of the core step on nb states, WITHOUT VST's ef_deterministic_fun
   axiom: VST's cl_corestep_fun (veric/semax_lemmas.v) needs that axiom only in
   the step_builtin / inlined step_external_function cases, which nb excludes. *)
Ltac fun_tac2 :=
  match goal with
  | H: ?A = Some _, H': ?A = Some _ |- _ => inversion2 H H'
  | H: ?A = fun_case_f _ _ _, H': ?A = fun_case_f _ _ _ |- _ => inversion2 H H'
  | H: Clight.eval_expr ?ge ?e ?le ?m ?A _, H': Clight.eval_expr ?ge ?e ?le ?m ?A _ |- _ =>
        apply (eval_expr_fun H) in H'; subst
  | H: Clight.eval_exprlist ?ge ?e ?le ?m ?A ?ty _, H': Clight.eval_exprlist ?ge ?e ?le ?m ?A ?ty _ |- _ =>
        apply (eval_exprlist_fun H) in H'; subst
  | H: Clight.eval_lvalue ?ge ?e ?le ?m ?A _ _ _, H': Clight.eval_lvalue ?ge ?e ?le ?m ?A _ _ _ |- _ =>
        apply (eval_lvalue_fun H) in H'; inv H'
  | H: Clight.alloc_variables ?ge ?e ?m ?vl _ _, H': Clight.alloc_variables ?ge ?e ?m ?vl _ _ |- _ =>
        apply (alloc_variables_fun H) in H'; inv H'
  end.

Lemma step_fun_nb q m q1 m1 q2 m2 :
  nb q -> Clight_core.step ge q m q1 m1 -> Clight_core.step ge q m q2 m2 -> (q1, m1) = (q2, m2).
Proof.
  intros Hnb H H0.
  inv H; inv H0; unfold nb in Hnb; try contradiction;
  repeat fun_tac2; auto;
  repeat match goal with H: _ = _ \/ _ = _ |- _ => destruct H; try discriminate end;
  try contradiction.
  all: try (match goal with A : function_entry2 _ _ _ _ _ _ _, B : function_entry2 _ _ _ _ _ _ _ |- _ =>
              inv A; inv B end;
            repeat fun_tac2;
            try (match goal with A : alloc_variables _ _ _ _ _ _, B : alloc_variables _ _ _ _ _ _ |- _ =>
                   pose proof (alloc_variables_fun A B) as E; inv E end);
            auto).
  all: try (match goal with H : andb (ef_inline _) _ = true |- _ => rewrite Hnb in H; discriminate H end).
Qed.

End Step.

Check step_equiv_transfer.
Print Assumptions step_equiv_transfer.
Check step_fun_nb.
Print Assumptions step_fun_nb.
Print Assumptions equiv_storebytes.
