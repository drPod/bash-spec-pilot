(* UNIVERSAL execution theorem for the exit-wrapper program relay_exit.prog
   (universal-relay-4); see UniversalMain.v for the original relay_main.prog.

   TerminateMain.relay_main_termination exhibits ONE finite execution (an
   existential witness) of the Clight core semantics of relay_main.prog, in the
   scheduled environment Dry.relay_dry_spec (Trace.dry_step), halting in
   Returnstate (Vint (Int.repr status)) Kstop with outcome w0 status final
   pending.  Trace.dry_step is nondeterministic: a scheduled read may hand back
   any memory mem_equiv-equivalent to the Mem.storebytes result, and an
   external call whose dry precondition has NO witness would be unconstrained.

   This file states and proves the universal version: for every valid initial
   world w0 there is a bound N and the protocol outcome (status, final,
   pending) such that EVERY dry_steps execution from the initial core
     * has length at most N;
     * at every reached state satisfies the dry precondition for an explicit
       witness whenever it is at an external call (so no vacuous environment
       step is ever reachable);
     * can take a further dry_step whenever it is shorter than N;
     * after exactly N steps is halted in Returnstate (Vint (Int.repr status))
       Kstop in world final;
     * is halted only at length N, and can step only below N.
   I.e. every maximal execution in the specified environment terminates after
   exactly N steps with main returning the protocol status of w0, and reachable
   states differ from the canonical ones only by mem_equiv (memories).

   Method: (1) MemEquivStep.step_equiv_transfer moves any non-builtin,
   non-assign Clight core step along mem_equiv; (2) the dry pre/post of
   relay_dry_spec pin the result, the new world and (up to mem_equiv) the new
   memory as soon as ONE witness satisfies the precondition, and the
   precondition itself transfers along mem_equiv (pre_transfer, post_pins,
   ext_transfer below: inspected, not assumed -- the read effect is pinned
   because the witness memory is forced equal to the call memory and
   Mem.storebytes is a function; the write bytes are pinned by loadbytes and
   the length argument); (3) the canonical trajectory of TerminateMain.v is
   re-derived as `csteps`, which additionally records at every core step that
   the state is not at a builtin/assignment (nb); (4) canon_universal turns
   determinism-modulo-mem_equiv along the canonical trajectory into the
   statement about all executions.

   Premises: valid_world w0 only.  No Jsub, no safety theorem, no new axiom.
   Trusted/assumed, unchanged: the environment model relay_dry_spec (each
   scheduled read/write returns with the specified effect), the C->Clight
   translation (relay_main.v hashes); nothing about the host OS.  The result is
   about the environment relation dry_step exactly as frozen in Trace.v; no
   contract was narrowed. *)
Require Import VST.floyd.proofauto.
Require Import VST.sepcomp.semantics.
Require Import VST.sepcomp.extspec.
Require Import VST.veric.semax_ext.
Require Import VST.veric.Clight_core.
Require Import VST.veric.SequentialClight.
Require Import VST.veric.mem_lessdef.
Require Import compcert.common.Globalenvs.
Require Import compcert.lib.Maps.
Require Import Trace MemEquivStep.
Require Import relay_exit Protocol Reach Conservation Progress Determinism Evaluator DryExit SafetyExit ExitOutcome.
Require Import Terminate.
Import RelayProtocol RelayReach RelayConservation RelayProgress RelayEvaluator.
Local Open Scope Z_scope.

Local Opaque RelayProtocol.read32 RelayProtocol.write_block.

Local Notation CState := Clight_core.State.
Local Notation CCall := Clight_core.Callstate.
Local Notation CRet := Clight_core.Returnstate.
Local Notation ge := (globalenv prog).
Local Notation csem := (cl_core_sem (globalenv prog)).
Local Notation exit_ge :=
  (Clight.genv_genv {| Clight.genv_genv := Genv.globalenv prog; Clight.genv_cenv := prog_comp_env prog |}).

(* ---------- state equivalence: same core state and world, mem_equiv memories ---------- *)

Definition sequiv (s1 s2 : CC_core * mem * world) : Prop :=
  let '(q1, m1, z1) := s1 in let '(q2, m2, z2) := s2 in q1 = q2 /\ mem_equiv m1 m2 /\ z1 = z2.

Lemma sequiv_refl s : sequiv s s.
Proof. destruct s as ((q, m), z). split; [reflexivity | split; [apply mem_equiv_refl | reflexivity]]. Qed.
Lemma sequiv_sym s1 s2 : sequiv s1 s2 -> sequiv s2 s1.
Proof. destruct s1 as ((q1, m1), z1), s2 as ((q2, m2), z2). intros (A & B & C). subst. split; [reflexivity | split; [apply mem_equiv_sym; exact B | reflexivity]]. Qed.
Lemma sequiv_trans s1 s2 s3 : sequiv s1 s2 -> sequiv s2 s3 -> sequiv s1 s3.
Proof.
  destruct s1 as ((q1, m1), z1), s2 as ((q2, m2), z2), s3 as ((q3, m3), z3).
  intros (A & B & C) (D & E & F). subst. split; [reflexivity | split; [eapply mem_equiv_trans; eauto | reflexivity]].
Qed.

Definition nbs (s : CC_core * mem * world) : Prop := let '(q, _, _) := s in nb q.

(* ---------- the dry specification along mem_equiv (inspected, not assumed) ---------- *)

Section ExitUniversal.
Variable w0 : world.
Local Notation spec := (exit_dry_spec w0).
Local Notation symb := (semax.genv_symb_injective exit_ge).
Local Notation dstep := (dry_step csem spec semax.genv_symb_injective exit_ge).
Local Notation dsteps := (dry_steps csem spec semax.genv_symb_injective exit_ge).
Local Notation ext_ok := (Terminate.ext_ok w0).
Local Notation ok_steps := (Terminate.ok_steps w0).
Local Notation read_ext_step := (Terminate.read_ext_step w0).
Local Notation write_ext_step := (Terminate.write_ext_step w0).


Ltac spec_cases x := revert x; unfold exit_dry_spec; cbn [ext_spec_pre ext_spec_post ext_spec_type];
  destruct (oi_eq_dec _ _) as [_ | _]; [| destruct (oi_eq_dec _ _) as [_ | _]; [| destruct (oi_eq_dec _ _) as [_ | _]; [| intro x; destruct x]]].

(* The precondition transfers along mem_equiv (witness memory replaced). *)
Lemma pre_transfer e x args z m1 m2 :
  mem_equiv m1 m2 ->
  ext_spec_pre spec e x symb (map proj_xtype (sig_args (ef_sig e))) args z m1 ->
  exists x2, ext_spec_pre spec e x2 symb (map proj_xtype (sig_args (ef_sig e))) args z m2.
Proof.
  intros Heq. pose proof Heq as (Hl & Hp & Hn). intro Hpre. revert Hpre. spec_cases x; intros x Hpre.
  - destruct x as (m0 & ts & w). destruct w as ((s, p), sh). simpl in Hpre.
    destruct Hpre as [Hargs [Hm0 [Hs [Hv Hperm]]]].
    exists (m2, existT _ ts (s, p, sh)). simpl.
    split; [exact Hargs|]. split; [reflexivity|]. split; [exact Hs|]. split; [exact Hv|].
    destruct p; try contradiction. intros o Ho. rewrite <- Hp. apply Hperm; exact Ho.
  - destruct x as (m0 & ts & w). destruct w as (((s, p), bs), sh). simpl in Hpre.
    destruct Hpre as [Hargs [Hm0 [Hs [Hv [Hlen Hld]]]]].
    exists (m2, existT _ ts (s, p, bs, sh)). simpl.
    split; [exact Hargs|]. split; [reflexivity|]. split; [exact Hs|]. split; [exact Hv|]. split; [exact Hlen|].
    destruct p; try contradiction. rewrite <- Hl. exact Hld.
  - destruct x as (m0 & ts & w). destruct w as ((st, fin), pend). simpl in Hpre.
    destruct Hpre as [Hx Hm0]. exists (m2, existT _ ts (st, fin, pend)). simpl. split; [exact Hx | reflexivity].
Qed.

(* With one witness of the precondition, any two answers of the environment
   agree on result and world and have mem_equiv memories. *)
Lemma post_pins e x args z m ret1 z1 m1 ret2 z2 m2 :
  ext_spec_pre spec e x symb (map proj_xtype (sig_args (ef_sig e))) args z m ->
  ext_spec_post spec e x symb (sig_res (ef_sig e)) ret1 z1 m1 ->
  ext_spec_post spec e x symb (sig_res (ef_sig e)) ret2 z2 m2 ->
  ret1 = ret2 /\ z1 = z2 /\ mem_equiv m1 m2.
Proof.
  intros Hpre Hp1 Hp2. revert Hpre Hp1 Hp2. spec_cases x; intros x Hpre Hp1 Hp2.
  - destruct x as (m0 & ts & w). destruct w as ((s, p), sh). simpl in Hpre, Hp1, Hp2.
    destruct Hpre as [Hargs [Hm0 [Hs [Hv Hperm]]]]. subst m0 s.
    destruct ret1 as [[| ? | i1 | ? | ? | ? ?]|]; try contradiction.
    destruct ret2 as [[| ? | i2 | ? | ? | ? ?]|]; try contradiction.
    destruct Hp1 as [_ [Hi1 [Hz1 Hmem1]]]. destruct Hp2 as [_ [Hi2 [Hz2 Hmem2]]]. subst.
    destruct p as [| | | | | b ofs]; try contradiction.
    split; [reflexivity|]. split; [reflexivity|].
    match type of Hmem1 with context [?c <? 0] => destruct (c <? 0) eqn:E end; try rewrite E in Hmem1; try rewrite E in Hmem2.
    + subst. apply mem_equiv_refl.
    + destruct Hmem1 as (ma & Ha & Ea). destruct Hmem2 as (mb & Hb & Eb).
      rewrite Ha in Hb. inv Hb. eapply mem_equiv_trans; [exact Ea | apply mem_equiv_sym; exact Eb].
  - destruct x as (m0 & ts & w). destruct w as (((s, p), bs), sh). simpl in Hpre, Hp1, Hp2.
    destruct Hpre as [Hargs [Hm0 [Hs [Hv [Hlen Hld]]]]]. subst m0 s.
    destruct ret1 as [[| ? | i1 | ? | ? | ? ?]|]; try contradiction.
    destruct ret2 as [[| ? | i2 | ? | ? | ? ?]|]; try contradiction.
    destruct Hp1 as [_ [Hm1 [Hi1 Hz1]]]. destruct Hp2 as [_ [Hm2 [Hi2 Hz2]]]. subst.
    split; [reflexivity | split; [reflexivity | apply mem_equiv_refl]].
  - destruct x as (m0 & ts & w). simpl in Hp1. contradiction.
Qed.

(* The scheduled answer transfers along mem_equiv: from an equivalent call
   memory the same result and world are admitted, with an equivalent memory,
   for EVERY witness of the precondition there. *)
Lemma ext_transfer e args z m1 m2 ret z1 m1' :
  mem_equiv m1 m2 ->
  (exists x1, ext_spec_pre spec e x1 symb (map proj_xtype (sig_args (ef_sig e))) args z m1) ->
  (forall x1, ext_spec_pre spec e x1 symb (map proj_xtype (sig_args (ef_sig e))) args z m1 ->
              ext_spec_post spec e x1 symb (sig_res (ef_sig e)) ret z1 m1') ->
  exists m2',
    (forall x2, ext_spec_pre spec e x2 symb (map proj_xtype (sig_args (ef_sig e))) args z m2 ->
                ext_spec_post spec e x2 symb (sig_res (ef_sig e)) ret z1 m2') /\
    mem_equiv m1' m2'.
Proof.
  intros Heq (x1 & Hpre1) Hall. pose proof (Hall x1 Hpre1) as Hpost1. clear Hall.
  pose proof Heq as (Hl & Hp & Hn).
  revert Hpre1 Hpost1. spec_cases x1; intros x1 Hpre1 Hpost1.
  - destruct x1 as (m0 & ts & w). destruct w as ((s, p), sh). simpl in Hpre1, Hpost1.
    destruct Hpre1 as [Hargs [Hm0 [Hs [Hv Hperm]]]]. subst m0 s.
    destruct ret as [[| ? | i | ? | ? | ? ?]|]; try contradiction.
    destruct Hpost1 as [Hot [Hi [Hz1 Hmem]]].
    destruct p as [| | | | | b ofs]; try contradiction.
    match type of Hmem with context [?c <? 0] => destruct (c <? 0) eqn:E end; try rewrite E in Hmem.
    + subst m1'. exists m2. split; [| exact Heq].
      intros x2 Hpre2. destruct x2 as (m0' & ts' & w'). destruct w' as ((s', p'), sh'). simpl in Hpre2 |- *.
      destruct Hpre2 as [Hargs' [Hm0' [Hs' [Hv' Hperm']]]]. rewrite Hargs in Hargs'. inv Hargs'. try subst m0'; try subst s'.
      split; [exact Hot|]. split; [first [exact Hi | reflexivity]|]. split; [first [exact Hz1 | reflexivity]|]. rewrite E. reflexivity.
    + destruct Hmem as (ma & Ha & Ea).
      destruct (equiv_storebytes _ _ _ _ _ _ Heq Ha) as (mb & Hb & Eb).
      exists mb. split; [| eapply mem_equiv_trans; [exact Ea | exact Eb]].
      intros x2 Hpre2. destruct x2 as (m0' & ts' & w'). destruct w' as ((s', p'), sh'). simpl in Hpre2 |- *.
      destruct Hpre2 as [Hargs' [Hm0' [Hs' [Hv' Hperm']]]]. rewrite Hargs in Hargs'. inv Hargs'. try subst m0'; try subst s'.
      split; [exact Hot|]. split; [first [exact Hi | reflexivity]|]. split; [first [exact Hz1 | reflexivity]|]. rewrite E.
      exists mb. split; [exact Hb | apply mem_equiv_refl].
  - destruct x1 as (m0 & ts & w). destruct w as (((s, p), bs), sh). simpl in Hpre1, Hpost1.
    destruct Hpre1 as [Hargs [Hm0 [Hs [Hv [Hlen Hld]]]]]. subst m0 s.
    destruct ret as [[| ? | i | ? | ? | ? ?]|]; try contradiction.
    destruct Hpost1 as [Hot [Hm1 [Hi Hz1]]]. subst m1'.
    destruct p as [| | | | | b ofs]; try contradiction.
    exists m2. split; [| exact Heq].
    intros x2 Hpre2. destruct x2 as (m0' & ts' & w'). destruct w' as (((s', p'), bs'), sh'). simpl in Hpre2 |- *.
    destruct Hpre2 as [Hargs' [Hm0' [Hs' [Hv' [Hlen' Hld']]]]]. rewrite Hargs in Hargs'. inv Hargs'. try subst m0'; try subst s'.
    assert (Hbl : Zlength bs' = Zlength bs).
    { match goal with H : Int64.Z_mod_modulus _ = Int64.Z_mod_modulus _ |- _ =>
        rewrite !Int64.Z_mod_modulus_eq in H; rewrite !Z.mod_small in H by rep_lia; lia end. }
    rewrite Hbl, <- Hl, Hld in Hld'. inv Hld'.
    match goal with H : bytes_to_memvals _ = bytes_to_memvals _ |- _ => apply bytes_to_memvals_inj in H; subst bs' end.
    split; [exact Hot|]. split; [reflexivity|]. split; [first [exact Hi | reflexivity] | first [exact Hz1 | reflexivity]].
  - destruct x1 as (m0 & ts & w). simpl in Hpost1. contradiction.
Qed.

(* ---------- one dry step: functional modulo mem_equiv, transfers along it ---------- *)

Lemma core_step_inv q m q' m' : semantics.corestep csem q m q' m' -> Clight_core.step ge q m q' m'.
Proof. intro H; exact H. Qed.

Lemma at_ext_mem q m1 m2 : semantics.at_external csem q m1 = semantics.at_external csem q m2.
Proof. reflexivity. Qed.

Lemma ext_ok_equiv s1 s2 : sequiv s1 s2 -> ext_ok s1 -> ext_ok s2.
Proof.
  destruct s1 as ((q1, m1), z1), s2 as ((q2, m2), z2). intros (A & B & C) Hok. subst.
  intros e args Hat. rewrite (at_ext_mem q2 m2 m1) in Hat.
  destruct (Hok e args Hat) as (x & Hx). exact (pre_transfer e x args z2 m1 m2 B Hx).
Qed.

Lemma nbs_equiv s1 s2 : sequiv s1 s2 -> nbs s1 -> nbs s2.
Proof. destruct s1 as ((q1, m1), z1), s2 as ((q2, m2), z2). intros (A & _ & _) H. subst. exact H. Qed.

Lemma dstep_fun s t1 t2 : nbs s -> ext_ok s -> dstep s t1 -> dstep s t2 -> sequiv t1 t2.
Proof.
  intros Hnb Hok H1 H2. inv H1; inv H2.
  - match goal with A : semantics.corestep csem _ _ _ _, B : semantics.corestep csem _ _ _ _ |- _ =>
      pose proof (step_fun_nb ge _ _ _ _ _ _ Hnb (core_step_inv _ _ _ _ A) (core_step_inv _ _ _ _ B)) as E; inv E end.
    apply sequiv_refl.
  - match goal with A : semantics.corestep csem _ _ _ _, B : semantics.at_external csem _ _ = Some _ |- _ =>
      rewrite (semantics.corestep_not_at_external csem _ _ _ _ A) in B; discriminate B end.
  - match goal with A : semantics.corestep csem _ _ _ _, B : semantics.at_external csem _ _ = Some _ |- _ =>
      rewrite (semantics.corestep_not_at_external csem _ _ _ _ A) in B; discriminate B end.
  - match goal with A : semantics.at_external csem ?q ?m = Some _, B : semantics.at_external csem ?q ?m = Some _ |- _ =>
      rewrite A in B; inv B end.
    match goal with Hat : semantics.at_external csem _ _ = Some (?e, ?args) |- _ =>
      destruct (Hok e args Hat) as (x & Hx) end.
    match goal with P1 : forall x, _ -> ext_spec_post _ _ _ _ _ ?r1 ?z1 ?m1, P2 : forall x, _ -> ext_spec_post _ _ _ _ _ ?r2 ?z2 ?m2 |- _ =>
      destruct (post_pins _ _ _ _ _ _ _ _ _ _ _ Hx (P1 x Hx) (P2 x Hx)) as (Er & Ez & Em) end.
    subst. match goal with A : semantics.after_external csem _ _ _ = Some _, B : semantics.after_external csem _ _ _ = Some _ |- _ =>
      simpl in A, B; rewrite A in B; inv B end.
    split; [reflexivity | split; [exact Em | reflexivity]].
Qed.

Lemma dstep_transfer s1 s1' s2 : nbs s1 -> ext_ok s1 -> dstep s1 s1' -> sequiv s1 s2 ->
  exists s2', dstep s2 s2' /\ sequiv s1' s2'.
Proof.
  destruct s1 as ((q1, m1), z1), s2 as ((q2, m2), z2). intros Hnb Hok Hstep (A & B & C). subst q2 z2.
  inv Hstep.
  - match goal with H : semantics.corestep csem _ _ _ _ |- _ =>
      destruct (step_equiv_transfer ge _ _ _ _ m2 Hnb (core_step_inv _ _ _ _ H) B) as (m2' & Hs2 & E2) end.
    eexists. split; [apply dry_step_core; exact Hs2 |]. split; [reflexivity | split; [exact E2 | reflexivity]].
  - match goal with Hat : semantics.at_external csem _ _ = Some (?e, ?args),
                    Hall : forall x, _ -> ext_spec_post _ _ _ _ _ ?ret ?z' ?m1',
                    Haft : semantics.after_external csem ?ret _ _ = Some ?q' |- _ =>
      destruct (ext_transfer e args z1 m1 m2 ret z' m1' B (Hok e args Hat) Hall) as (m2' & Hall2 & E2);
      exists (q', m2', z'); split;
      [ eapply dry_step_ext with (e := e) (args := args) (ret := ret) (m' := m2') (z' := z') (q' := q');
        [ rewrite (at_ext_mem _ m2 m1); exact Hat | assumption | assumption | exact Hall2 | exact Haft ]
      | split; [reflexivity | split; [exact E2 | reflexivity]] ] end.
Qed.

Lemma dstep_det s1 s1' s2 s2' : nbs s1 -> ext_ok s1 -> dstep s1 s1' -> sequiv s1 s2 -> dstep s2 s2' -> sequiv s1' s2'.
Proof.
  intros Hnb Hok H1 Heq H2.
  destruct (dstep_transfer _ _ _ Hnb Hok H1 Heq) as (s2'' & H2'' & E).
  pose proof (dstep_fun _ _ _ (nbs_equiv _ _ Heq Hnb) (ext_ok_equiv _ _ Heq Hok) H2 H2'') as E'.
  eapply sequiv_trans; [exact E | apply sequiv_sym; exact E'].
Qed.

(* ---------- canonical trajectory: ok_steps plus the nb side condition ---------- *)

Inductive csteps : nat -> CC_core * mem * world -> CC_core * mem * world -> Prop :=
| c_0 s : csteps 0 s s
| c_S k s s' s'' : nbs s -> ext_ok s -> dstep s s' -> csteps k s' s'' -> csteps (S k) s s''.

Definition cstar s s' := exists k, csteps k s s'.
Lemma cstar_refl s : cstar s s.
Proof. exists O; constructor. Qed.
Lemma cstep_l s s' s'' : nbs s -> ext_ok s -> dstep s s' -> cstar s' s'' -> cstar s s''.
Proof. intros H0 H1 H2 (k & H3). exists (S k); econstructor; eauto. Qed.
Lemma cstar_trans s s' s'' : cstar s s' -> cstar s' s'' -> cstar s s''.
Proof.
  intros (k1 & H1) (k2 & H2). exists (k1 + k2)%nat.
  revert H2; induction H1 as [| k a b c Hn Ho Hd Hc IH]; intro H2; simpl; [exact H2 | econstructor; eauto].
Qed.
Lemma csteps_ok k s s' : csteps k s s' -> ok_steps k s s'.
Proof. induction 1; econstructor; eauto. Qed.

(* ---------- from the canonical trajectory to ALL executions ---------- *)

Lemma canon_universal : forall N s0 sN, csteps N s0 sN ->
  ext_ok sN ->
  (forall s', sequiv sN s' -> forall s'', ~ dstep s' s'') ->
  forall s0', sequiv s0 s0' -> forall k s', dsteps k s0' s' ->
    (k <= N)%nat /\ ext_ok s' /\
    ((k < N)%nat -> exists s'', dstep s' s'') /\
    (k = N -> sequiv sN s').
Proof.
  intros N s0 sN Hc. induction Hc; intros HokN Hterm t0 Heq kk t Hd.
  - inv Hd.
    + split; [lia|]. split; [exact (ext_ok_equiv _ _ Heq HokN)|]. split; [lia|]. intros _; exact Heq.
    + exfalso. eapply Hterm; eauto.
  - rename H into Hnb. rename H0 into Hok. rename H1 into Hstep. rename IHHc into IH.
    inv Hd.
    + split; [lia|]. split; [exact (ext_ok_equiv _ _ Heq Hok)|]. split; [| lia].
      intros _. destruct (dstep_transfer _ _ _ Hnb Hok Hstep Heq) as (Xt2 & XH2 & _). eauto.
    + match goal with Ht : dry_step _ _ _ _ ?a ?t1, Hr : dry_steps _ _ _ _ _ ?t1 ?b |- _ =>
        pose proof (dstep_det _ _ _ _ Hnb Hok Hstep Heq Ht) as XHeq1;
        destruct (IH HokN Hterm _ XHeq1 _ _ Hr) as (XB1 & XB2 & XB3 & XB4) end.
      split; [lia|]. split; [exact XB2|]. split; [intro; apply XB3; lia | intro; apply XB4; lia].
Qed.

(* the exit call has no dry step once its precondition has a witness: the
   dry postcondition of exit is False (the environment does not return) *)
Lemma exit_terminal args k m z s' :
  ext_ok (CCall exit_fd args k, m, z) -> ~ dstep (CCall exit_fd args k, m, z) s'.
Proof.
  intros Hok H. inv H.
  - match goal with H : semantics.corestep csem _ _ _ _ |- _ =>
      pose proof (semantics.corestep_not_at_external csem _ _ _ _ H) as N; simpl in N; discriminate N end.
  - match goal with Hat : semantics.at_external csem _ _ = Some (?e, ?a), Hall : forall x, _ -> ext_spec_post _ _ _ _ _ _ _ _ |- _ =>
      destruct (Hok e a Hat) as (x & Hx); simpl in Hat; inv Hat;
      exact (exit_dry_post_False w0 x _ _ _ _ _ (Hall x Hx)) end.
Qed.
Lemma exit_term_equiv args k m z : ext_ok (CCall exit_fd args k, m, z) ->
  forall s', sequiv (CCall exit_fd args k, m, z) s' -> forall s'', ~ dstep s' s''.
Proof.
  intros Hok ((q', m'), z') (E & Em & Ez) s''. subst q' z'.
  apply exit_terminal. exact (ext_ok_equiv (CCall exit_fd args k, m, z) (CCall exit_fd args k, m', z) (conj eq_refl (conj Em eq_refl)) Hok).
Qed.
(* the exit call state of the canonical trajectory satisfies ext_ok: the
   witness is the protocol outcome itself *)
Lemma exit_ext_ok status final pending m :
  outcome w0 status final pending -> ext_ok (st_exit status, m, final).
Proof.
  intros Hout e args H. simpl in H. inv H.
  unfold exit_dry_spec; cbn [ext_spec_pre ext_spec_type].
  destruct (oi_eq_dec _ _) as [E | _]; [exfalso; vm_compute in E; discriminate E|].
  destruct (oi_eq_dec _ _) as [E | _]; [exfalso; vm_compute in E; discriminate E|].
  destruct (oi_eq_dec _ _) as [_ | N]; [| exfalso; apply N; vm_compute; reflexivity].
  exists (m, existT _ nil (status, final, pending)). simpl. repeat split. exact Hout.
Qed.


(* ---------- the canonical trajectory, re-derived with nb (segments of Terminate.v) ---------- *)


Ltac rl := rep_lia.
Ltac solve_ne := let H := fresh in intro H; vm_compute in H; discriminate H.
Ltac ptree := repeat first [rewrite PTree.gss | rewrite PTree.gso by solve_ne].
Ltac not_ext := let H := fresh in intros ? ? H; simpl in H; discriminate H.
Ltac ev :=
  first [ eapply eval_Econst_int
        | eapply eval_Etempvar; ptree; first [reflexivity | eassumption]
        | eapply eval_Elvalue; [eapply eval_Evar_local; reflexivity | apply deref_loc_reference; reflexivity]
        | eapply eval_Elvalue; [eapply eval_Evar_global; [reflexivity | eassumption] | apply deref_loc_reference; reflexivity] ].
Ltac nb_tac := cbv [nbs nb read_fd write_fd exit_fd read_ef write_ef exit_ef st_ready st_drain st_exit q0]; first [exact I | reflexivity].
Ltac core := eapply cstep_l; [nb_tac | not_ext | apply dry_step_core; apply core_step |].
Ltac uz := first [rewrite Ptrofs.unsigned_zero | rewrite Ptrofs.unsigned_repr by rl].
Ltac ptree_solve := ptree; first [reflexivity | eassumption].
(* ---- return from relay with a status, through main, to the exit call ---- *)

Lemma useg_return status b le m k z :
  buf_ok m b -> call_cont k = Krelay -> Int.min_signed <= status <= Int.max_signed ->
  exists m', cstar (CState f_relay (Sreturn (Some (Econst_int (Int.repr status) tint))) k (e_relay b) le, m, z)
                     (st_exit status, m', z).
Proof.
  intros Hbuf Hk Hst.
  destruct (Mem.range_perm_free m b 0 32 Hbuf) as (m' & Hfree).
  destruct exit_sym as (bx & Hxs & Hxd).
  exists m'.
  core. { eapply step_return_1; [ev | apply sem_cast_int_int |].
          assert (Hbl : blocks_of_env ge (e_relay b) = [(b, 0, 32)]) by reflexivity.
          rewrite Hbl. cbn [Mem.free_list]. rewrite Hfree. reflexivity. }
  rewrite Hk. unfold Krelay.
  core. { eapply step_returnstate. }
  cbn [set_opttemp].
  unfold Kmain. core. { eapply step_skip_seq. }
  unfold call_exit.
  core. { eapply step_call; [reflexivity | ev | | | ].
          - econstructor; [ev | apply sem_cast_int_int | constructor].
          - rewrite Genv.find_funct_find_funct_ptr. exact Hxd.
          - reflexivity. }
  apply cstar_refl.
Qed.

(* ---- Ready: the read call, up to the statement S3 with n set ---- *)

Lemma useg_read z b le m :
  valid_world z -> buf_ok m b ->
  exists m',
    cstar (st_ready b le, m, z)
            (CState f_relay S3 KL (e_relay b)
               (PTree.set _n (Vlong (Int64.repr (read_ret (read32 z))))
                  (PTree.set _t'1 (Vlong (Int64.repr (read_ret (read32 z)))) le)),
             m', read_world (read32 z)) /\
    buf_ok m' b /\
    (0 <= read_ret (read32 z) ->
     Mem.loadbytes m' b 0 (Zlength (read_bytes (read32 z))) = Some (bytes_to_memvals (read_bytes (read32 z)))).
Proof.
  intros Hv Hbuf.
  destruct read_sym as (br & Hrs & Hrd).
  destruct (read_ext_step z b m (Kcall (Some _t'1) f_relay (e_relay b) le Kread) Hv Hbuf)
    as (m' & Hok & Hstep & Hbuf' & Hload).
  exists m'. split; [| split; assumption].
  unfold st_ready, call_read.
  core. { eapply step_call; [reflexivity | ev | | | ].
          - econstructor; [ev | apply sem_cast_int_int |].
            econstructor; [ev | apply sem_cast_arr |].
            econstructor; [ev | apply sem_cast_i2ul; rl | constructor].
          - rewrite Genv.find_funct_find_funct_ptr. exact Hrd.
          - reflexivity. }
  eapply cstep_l; [nb_tac | exact Hok | exact Hstep |].
  core. { eapply step_returnstate. }
  cbn [set_opttemp].
  unfold Kread. core. { eapply step_skip_seq. }
  unfold set_n. core. { eapply step_set. ev. }
  core. { eapply step_skip_seq. }
  apply cstar_refl.
Qed.

(* ---- S3 with n = r: the three outcomes of the read ---- *)

Lemma useg_S3_neg z b le m r :
  buf_ok m b -> -1 <= r < 0 ->
  PTree.get _n le = Some (Vlong (Int64.repr r)) ->
  exists m', cstar (CState f_relay S3 KL (e_relay b) le, m, z) (st_exit 1, m', z).
Proof.
  intros Hbuf Hr Hn.
  destruct (useg_return 1 b le m (Kseq (Ssequence if_zero (Ssequence set_off0 wloop)) KL) z Hbuf eq_refl
              ltac:(rl)) as (m' & Hret).
  exists m'.
  unfold S3. core. { eapply step_seq. }
  unfold if_neg.
  core. { eapply step_ifthenelse with (b := true); [econstructor; [ev | ev | apply sem_lt_n0; lia] |].
          rewrite bool_val_of_bool. f_equal. apply Z.ltb_lt; lia. }
  cbv iota. exact Hret.
Qed.

Lemma useg_S3_zero z b le m :
  buf_ok m b ->
  PTree.get _n le = Some (Vlong (Int64.repr 0)) ->
  exists m', cstar (CState f_relay S3 KL (e_relay b) le, m, z) (st_exit 0, m', z).
Proof.
  intros Hbuf Hn.
  destruct (useg_return 0 b le m (Kseq (Ssequence set_off0 wloop) KL) z Hbuf eq_refl ltac:(rl))
    as (m' & Hret).
  exists m'.
  unfold S3. core. { eapply step_seq. }
  unfold if_neg.
  core. { eapply step_ifthenelse with (b := false); [econstructor; [ev | ev | apply sem_lt_n0; lia] |].
          rewrite bool_val_of_bool. reflexivity. }
  cbv iota.
  core. { eapply step_skip_seq. }
  core. { eapply step_seq. }
  unfold if_zero.
  core. { eapply step_ifthenelse with (b := true); [econstructor; [ev | ev | apply sem_eq_n0; lia] |].
          rewrite bool_val_of_bool. reflexivity. }
  cbv iota. exact Hret.
Qed.

Lemma useg_S3_pos z b le m r :
  0 < r <= 32 ->
  PTree.get _n le = Some (Vlong (Int64.repr r)) ->
  cstar (CState f_relay S3 KL (e_relay b) le, m, z)
          (st_drain b (PTree.set _off (Vlong (Int64.repr 0)) le), m, z).
Proof.
  intros Hr Hn.
  unfold S3. core. { eapply step_seq. }
  unfold if_neg.
  core. { eapply step_ifthenelse with (b := false); [econstructor; [ev | ev | apply sem_lt_n0; lia] |].
          rewrite bool_val_of_bool. f_equal. apply Z.ltb_ge; lia. }
  cbv iota.
  core. { eapply step_skip_seq. }
  core. { eapply step_seq. }
  unfold if_zero.
  core. { eapply step_ifthenelse with (b := false); [econstructor; [ev | ev | apply sem_eq_n0; lia] |].
          rewrite bool_val_of_bool. f_equal. apply Z.eqb_neq; lia. }
  cbv iota.
  core. { eapply step_skip_seq. }
  core. { eapply step_seq. }
  unfold set_off0.
  core. { eapply step_set. eapply eval_Ecast; [ev | apply sem_cast_i2ul; rl]. }
  core. { eapply step_skip_seq. }
  apply cstar_refl.
Qed.

(* ---- Drain: the while test ---- *)

Lemma useg_drain_end z b le m n :
  0 <= n <= 32 ->
  PTree.get _n le = Some (Vlong (Int64.repr n)) ->
  PTree.get _off le = Some (Vlong (Int64.repr n)) ->
  cstar (st_drain b le, m, z) (st_ready b le, m, z).
Proof.
  intros Hn Hln Hlo.
  unfold st_drain, wloop, Swhile.
  core. { eapply step_loop. }
  core. { eapply step_seq. }
  unfold cond_w.
  core. { eapply step_ifthenelse with (b := false);
          [econstructor; [ev | eapply eval_Ecast; [ev | apply sem_cast_ll] | apply sem_ltu; lia] |].
          rewrite bool_val_of_bool. f_equal. apply Z.ltb_ge; lia. }
  cbv iota.
  core. { eapply step_break_seq. }
  core. { eapply step_break_loop1. }
  unfold KL.
  core. { eapply step_skip_or_continue_loop1; left; reflexivity. }
  core. { eapply step_skip_loop2. }
  core. { eapply step_loop. }
  unfold S1. core. { eapply step_seq. }
  core. { eapply step_skip_seq. }
  unfold S2. core. { eapply step_seq. }
  core. { eapply step_seq. }
  apply cstar_refl.
Qed.

Lemma useg_drain_write z b le m chunk off :
  valid_world z -> 0 <= off < Zlength chunk -> Zlength chunk <= 32 ->
  Mem.loadbytes m b 0 (Zlength chunk) = Some (bytes_to_memvals chunk) ->
  PTree.get _n le = Some (Vlong (Int64.repr (Zlength chunk))) ->
  PTree.get _off le = Some (Vlong (Int64.repr off)) ->
  let wr := write_ret (write_block z (suffix off chunk)) in
  cstar (st_drain b le, m, z)
          (CState f_relay (Ssequence if_w set_off) KW (e_relay b)
             (PTree.set _w (Vlong (Int64.repr wr)) (PTree.set _t'2 (Vlong (Int64.repr wr)) le)),
           m, write_world (write_block z (suffix off chunk))).
Proof.
  intros Hv Hoff Hlen Hload Hln Hlo wr.
  destruct write_sym as (bw & Hws & Hwd).
  destruct (write_ext_step z b m (Kcall (Some _t'2) f_relay (e_relay b) le
              (Kseq set_w (Kseq (Ssequence if_w set_off) KW))) chunk off Hv Hoff Hlen Hload)
    as (Hok & Hstep).
  unfold st_drain, wloop, Swhile.
  core. { eapply step_loop. }
  core. { eapply step_seq. }
  unfold cond_w.
  core. { eapply step_ifthenelse with (b := true);
          [econstructor; [ev | eapply eval_Ecast; [ev | apply sem_cast_ll] | apply sem_ltu; lia] |].
          rewrite bool_val_of_bool. f_equal. apply Z.ltb_lt; lia. }
  cbv iota.
  core. { eapply step_skip_seq. }
  unfold wbody at 1. core. { eapply step_seq. }
  core. { eapply step_seq. }
  unfold call_write.
  core. { eapply step_call; [reflexivity | ev | | | ].
          - econstructor; [ev | apply sem_cast_int_int |].
            econstructor; [econstructor; [ev | ev | apply sem_add_ptr; lia] | apply sem_cast_ptr |].
            econstructor; [econstructor; [eapply eval_Ecast; [ev | apply sem_cast_ll] | ev | apply sem_sub_ul]
                          | apply sem_cast_ulul | constructor].
          - rewrite Genv.find_funct_find_funct_ptr. exact Hwd.
          - reflexivity. }
  eapply cstep_l; [nb_tac | exact Hok | exact Hstep |].
  core. { eapply step_returnstate. }
  cbn [set_opttemp].
  core. { eapply step_skip_seq. }
  unfold set_w. core. { eapply step_set. ev. }
  core. { eapply step_skip_seq. }
  apply cstar_refl.
Qed.

Lemma useg_w_fail z b le m wr :
  buf_ok m b -> -1 <= wr <= 0 ->
  PTree.get _w le = Some (Vlong (Int64.repr wr)) ->
  exists m', cstar (CState f_relay (Ssequence if_w set_off) KW (e_relay b) le, m, z) (st_exit 2, m', z).
Proof.
  intros Hbuf Hw Hlw.
  destruct (useg_return 2 b le m (Kseq set_off KW) z Hbuf eq_refl ltac:(rl)) as (m' & Hret).
  exists m'.
  core. { eapply step_seq. }
  unfold if_w.
  core. { eapply step_ifthenelse with (b := true); [econstructor; [ev | ev | apply sem_le_w0; lia] |].
          rewrite bool_val_of_bool. f_equal. apply Z.leb_le; lia. }
  cbv iota. exact Hret.
Qed.

Lemma useg_w_ok z b le m wr off :
  0 < wr <= 32 -> 0 <= off <= 32 ->
  PTree.get _w le = Some (Vlong (Int64.repr wr)) ->
  PTree.get _off le = Some (Vlong (Int64.repr off)) ->
  cstar (CState f_relay (Ssequence if_w set_off) KW (e_relay b) le, m, z)
          (st_drain b (PTree.set _off (Vlong (Int64.repr (off + wr))) le), m, z).
Proof.
  intros Hw Hoff Hlw Hlo.
  core. { eapply step_seq. }
  unfold if_w.
  core. { eapply step_ifthenelse with (b := false); [econstructor; [ev | ev | apply sem_le_w0; lia] |].
          rewrite bool_val_of_bool. f_equal. apply Z.leb_gt; lia. }
  cbv iota.
  core. { eapply step_skip_seq. }
  unfold set_off.
  core. { eapply step_set. econstructor; [ev | eapply eval_Ecast; [ev | apply sem_cast_ll] | apply sem_add_ul]. }
  unfold KW.
  core. { eapply step_skip_or_continue_loop1; left; reflexivity. }
  core. { eapply step_skip_loop2. }
  apply cstar_refl.
Qed.

(* ---- the initial segment: main entry, relay entry (allocation of buf), loop entry ---- *)




Lemma useg_init z :
  exists b m1, cstar (q0, init_mem, z) (st_ready b (create_undef_temps (fn_temps f_relay)), m1, z) /\ buf_ok m1 b.
Proof.
  destruct relay_sym as (brl & Hrls & Hrld).
  destruct (Mem.alloc init_mem 0 32) as [m1 b] eqn:Halloc.
  exists b, m1. split.
  2:{ intros ofs Hofs. eapply Mem.perm_alloc_2; eauto. }
  unfold q0.
  core. { eapply step_internal_function.
          econstructor; [constructor | constructor | intros ? ? Hx; simpl in Hx; contradiction | constructor | reflexivity]. }
  rewrite main_body_eq.
  core. { eapply step_seq. }
  core. { eapply step_seq. }
  core. { eapply step_seq. }
  unfold call_relay.
  core. { eapply step_call; [reflexivity | ev | constructor | | ].
          - rewrite Genv.find_funct_find_funct_ptr. exact Hrld.
          - reflexivity. }
  core. { eapply step_internal_function.
          econstructor; [constructor; [simpl; tauto | constructor] | constructor
                        | intros ? ? Hx; simpl in Hx; contradiction | | reflexivity].
          econstructor; [exact Halloc | constructor]. }
  rewrite relay_body_eq.
  core. { eapply step_loop. }
  unfold S1. core. { eapply step_seq. }
  core. { eapply step_skip_seq. }
  unfold S2. core. { eapply step_seq. }
  core. { eapply step_seq. }
  apply cstar_refl.
Qed.

Lemma usim_step p s p' s' q m :
  valid_world s -> RelayDeterminism.step (p, s) = Some (p', s') -> match_state p q m ->
  exists q' m', cstar (q, m, s) (q', m', s') /\ match_state p' q' m'.
Proof.
  intros Hv Hstep Hm.
  destruct Hm as [b le m Hbuf | b le m chunk off Hbuf Hchunk Hoff Hload Hln Hlo | status pending m].
  - (* Ready: one read *)
    simpl in Hstep.
    pose proof (read_ret_bounds s) as Hb.
    destruct (useg_read s b le m Hv Hbuf) as (m1 & Hstar & Hbuf1 & Hload1).
    set (v := Vlong (Int64.repr (read_ret (read32 s)))) in *.
    set (le1 := PTree.set _n v (PTree.set _t'1 v le)) in *.
    assert (Hln1 : PTree.get _n le1 = Some v) by (unfold le1; ptree_solve).
    destruct (read_ret (read32 s) <? 0) eqn:E1.
    + inv Hstep. apply Z.ltb_lt in E1.
      destruct (useg_S3_neg (read_world (read32 s)) b le1 m1 (read_ret (read32 s)) Hbuf1 ltac:(lia) Hln1)
        as (m2 & Hstar2).
      exists (st_exit 1), m2. split; [eapply cstar_trans; eauto | constructor].
    + apply Z.ltb_ge in E1.
      destruct (read_ret (read32 s) =? 0) eqn:E2.
      * inv Hstep. apply Z.eqb_eq in E2.
        assert (Hln0 : PTree.get _n le1 = Some (Vlong (Int64.repr 0))) by (rewrite Hln1; unfold v; rewrite E2; reflexivity).
        destruct (useg_S3_zero (read_world (read32 s)) b le1 m1 Hbuf1 Hln0) as (m2 & Hstar2).
        exists (st_exit 0), m2. split; [eapply cstar_trans; eauto | constructor].
      * inv Hstep. apply Z.eqb_neq in E2.
        pose proof (read_success_length s E1) as Hlen.
        exists (st_drain b (PTree.set _off (Vlong (Int64.repr 0)) le1)), m1. split.
        { eapply cstar_trans; [exact Hstar|].
          apply useg_S3_pos with (r := read_ret (read32 s)); [lia | exact Hln1]. }
        apply match_drain.
        -- exact Hbuf1.
        -- rewrite Hlen; lia.
        -- rewrite Hlen; lia.
        -- apply Hload1; lia.
        -- rewrite Hlen. unfold le1; ptree_solve.
        -- ptree_solve.
  - (* Drain: the while test, possibly one write *)
    simpl in Hstep.
    destruct (Zlength chunk <=? off) eqn:E1.
    + inv Hstep. apply Z.leb_le in E1.
      assert (Hend : off = Zlength chunk) by lia. subst off.
      exists (st_ready b le), m. split.
      { apply useg_drain_end with (n := Zlength chunk); [lia | exact Hln | exact Hlo]. }
      constructor; exact Hbuf.
    + apply Z.leb_gt in E1.
      pose proof (write_ret_bounds s (suffix off chunk)) as Hw.
      rewrite (suffix_length off chunk ltac:(lia)) in Hw.
      pose proof (useg_drain_write s b le m chunk off Hv ltac:(lia) ltac:(lia) Hload Hln Hlo) as Hstar.
      cbv zeta in Hstar.
      set (wr := write_ret (write_block s (suffix off chunk))) in *.
      set (le2 := PTree.set _w (Vlong (Int64.repr wr)) (PTree.set _t'2 (Vlong (Int64.repr wr)) le)) in *.
      assert (Hlw2 : PTree.get _w le2 = Some (Vlong (Int64.repr wr))) by (unfold le2; ptree_solve).
      assert (Hlo2 : PTree.get _off le2 = Some (Vlong (Int64.repr off))) by (unfold le2; ptree_solve).
      assert (Hln2 : PTree.get _n le2 = Some (Vlong (Int64.repr (Zlength chunk)))) by (unfold le2; ptree_solve).
      destruct (wr <=? 0) eqn:E2.
      * inv Hstep. apply Z.leb_le in E2.
        destruct (useg_w_fail (write_world (write_block s (suffix off chunk))) b le2 m wr Hbuf ltac:(lia) Hlw2)
          as (m2 & Hstar2).
        exists (st_exit 2), m2. split; [eapply cstar_trans; eauto | constructor].
      * inv Hstep. apply Z.leb_gt in E2.
        exists (st_drain b (PTree.set _off (Vlong (Int64.repr (off + wr))) le2)), m. split.
        { eapply cstar_trans; [exact Hstar|].
          apply useg_w_ok with (wr := wr) (off := off); [lia | lia | exact Hlw2 | exact Hlo2]. }
        apply match_drain.
        -- exact Hbuf.
        -- exact Hchunk.
        -- lia.
        -- exact Hload.
        -- ptree_solve.
        -- ptree_solve.
  - simpl in Hstep. discriminate.
Qed.

Hypothesis Hv0 : valid_world w0.

Lemma usim_run k : forall p s q m status pending final,
  reaches w0 p s ->
  RelayDeterminism.run k (p, s) = Some (Halt status pending, final) ->
  match_state p q m ->
  exists m', cstar (q, m, s) (st_exit status, m', final).
Proof.
  induction k as [| k IH]; intros p s q m status pending final Hr Hrun Hm.
  - cbn [RelayDeterminism.run] in Hrun. inv Hrun. inv Hm. exists m. apply cstar_refl.
  - cbn [RelayDeterminism.run] in Hrun.
    destruct (RelayDeterminism.step (p, s)) as [[p' s'] |] eqn:Hstep; [| discriminate].
    pose proof (reaches_valid w0 p s Hv0 Hr) as Hv.
    destruct (usim_step p s p' s' q m Hv Hstep Hm) as (q' & m1 & Hstar & Hm').
    pose proof (step_reaches w0 p s p' s' Hr Hstep) as Hr'.
    destruct (IH p' s' q' m1 status pending final Hr' Hrun Hm') as (m2 & Hstar2).
    exists m2. eapply cstar_trans; eauto.
Qed.
(* ---------- the theorem ---------- *)

Theorem relay_exit_universal :
  exists q0 N status final pending,
    semantics.initial_core csem 0 init_mem q0 init_mem (Vptr main_block Ptrofs.zero) [] /\
    outcome w0 status final pending /\
    forall k q m z, dsteps k (q0, init_mem, w0) (q, m, z) ->
      (k <= N)%nat /\
      ext_ok (q, m, z) /\
      ((k < N)%nat -> exists s', dstep (q, m, z) s') /\
      (k = N -> semantics.at_external csem q m = Some (exit_ef, [Vint (Int.repr status)]) /\ z = final) /\
      (forall e args, semantics.at_external csem q m = Some (e, args) -> e = exit_ef -> k = N) /\
      (forall s', dstep (q, m, z) s' -> (k < N)%nat).
Proof.
  destruct (run_halts_within (fuel w0) w0 Ready w0 (initial_ready w0)) as (k & status & pending & final & Hk & Hrun).
  { unfold fuel. rewrite Z2Nat.id by apply measure_nonneg. lia. }
  destruct (useg_init w0) as (b & m1 & Hstar0 & Hbuf).
  destruct (usim_run k Ready w0 (st_ready b (create_undef_temps (fn_temps f_relay))) m1 status pending final
              (initial_ready w0) Hrun (match_ready b (create_undef_temps (fn_temps f_relay)) m1 Hbuf))
    as (m2 & Hstar).
  destruct (cstar_trans _ _ _ Hstar0 Hstar) as (N & Hsteps).
  pose proof (RelayDeterminism.run_reaches w0 k _ _ Hrun) as Hout.
  exists q0, N, status, final, pending.
  split; [exact init_core|]. split; [exact Hout|].
  intros k' q m z Hd.
  pose proof (exit_ext_ok status final pending m2 Hout) as HokN.
  pose proof (canon_universal N _ _ Hsteps HokN (exit_term_equiv _ _ _ _ HokN)
                _ (sequiv_refl _) k' _ Hd) as (B1 & B2 & B3 & B4).
  split; [exact B1|]. split; [exact B2|]. split; [exact B3|].
  assert (B4' : k' = N -> semantics.at_external csem q m = Some (exit_ef, [Vint (Int.repr status)]) /\ z = final).
  { intro E. destruct (B4 E) as (Eq & _ & Ez). subst. split; reflexivity. }
  split; [exact B4'|]. split.
  - intros e args Hat He. subst e. destruct (Nat.eq_dec k' N) as [E | NE]; [exact E|].
    exfalso. destruct (B3 ltac:(lia)) as (s' & Hs'). inv Hs'.
    + match goal with H : semantics.corestep csem _ _ _ _ |- _ =>
        rewrite (semantics.corestep_not_at_external csem _ _ _ _ H) in Hat; discriminate Hat end.
    + match goal with Hat2 : semantics.at_external csem q m = Some (?e2, ?a2), Hall : forall x, _ -> ext_spec_post _ _ _ _ _ _ _ _ |- _ =>
        rewrite Hat in Hat2; inv Hat2; destruct (B2 _ _ Hat) as (x & Hx);
        exact (exit_dry_post_False w0 x _ _ _ _ _ (Hall x Hx)) end.
  - intros s' Hs'. destruct (Nat.eq_dec k' N) as [E | NE]; [| lia].
    exfalso. destruct (B4 E) as (Eq & Em & Ez). subst.
    exact (exit_term_equiv _ _ _ _ HokN (st_exit status, m, _) (conj eq_refl (conj Em eq_refl)) _ Hs').
Qed.

End ExitUniversal.

Check relay_exit_universal.
Print Assumptions relay_exit_universal.
Print Assumptions canon_universal.
Print Assumptions ext_transfer.
