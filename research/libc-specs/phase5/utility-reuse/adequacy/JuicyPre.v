(* juicy_dry_ext_spec, first conjunct (PRE-preservation) for the actual
   IOSpecs read_spec/write_spec under IOW_Espec (JuicyDry.v): every juicy
   precondition witness (phi1, WITH-tuple) that funspec2pre accepts for a
   read/write external call yields the dry precondition iow_dry_spec
   demands of the dessicated witness. Modeled on relay/adequacy/Dry.v's
   juicy_dry_specs first bullet; the new obligations relative to relay are
   the parametric buffer size n (sizeof (tarray tuchar n) = n needs 0 <= n)
   and the errno cell (ErrnoLoad.errno_at_dry_pre). *)
Require Import VST.floyd.proofauto.
Require Import VST.sepcomp.extspec.
Require Import VST.veric.semax_ext.
Require Import VST.veric.juicy_extspec.
Require Import VST.veric.juicy_mem.
Require Import VST.veric.compcert_rmaps.
Require Import VST.veric.initial_world.
Require Import VST.veric.ghost_PCM.
Require Import VST.veric.SequentialClight.
Require Import VST.concurrency.conclib.
Require Import VST.veric.mem_lessdef.
Require Import dry_mem_lemmas.
Require Import relay Protocol Reach.
Require Import IOWorld IOSpecs.
Require Import Specialize MemAdequacy DryPost JuicyDry ErrnoBridge ErrnoLoad.
Import ListNotations.
Import IOW.
Local Open Scope Z_scope.

Section IOWJuicyPre.
Variable errno_id : ident.
Variable ext_link : string -> ident.

Notation iow_ext_spec' := (iow_ext_spec errno_id ext_link).
Notation iow_dry_spec' := (iow_dry_spec errno_id ext_link).
Notation iow_dessicate' := (iow_dessicate errno_id ext_link).

Theorem iow_juicy_dry_pre : forall e t t' b tl vl x jm,
  iow_dessicate' e jm t = t' ->
  ext_spec_pre iow_ext_spec' e t b tl vl x jm ->
  ext_spec_pre iow_dry_spec' e t' b tl vl x (m_dry jm).
Proof.
  intros e. simpl. unfold funspec2pre, iow_dessicate. simpl.
  if_tac.
  - (* read *)
    intros; subst.
    destruct t as (phi1 & ts & w). simpl in *.
    destruct H1 as (Hty & phi0 & phi1' & J & Hpre & Hr & Hext).
    destruct e; inv H; simpl in *.
    destruct w as (((((gv & s) & p) & n) & er) & sh).
    unfold SEPx in Hpre; simpl in Hpre.
    rewrite seplog.sepcon_emp in Hpre.
    destruct Hpre as [[Hvalid [Hwritable [Hn [Hfd _]]]] [Hargs [_ [phig [phir [J1 [Htrace Hrest]]]]]]].
    destruct Hrest as [phib [phie [J2 [Hbuf Herr]]]].
    assert (Hvl : vl = [vint (in_fd s); p; Vlong (Int64.repr n)]) by (inv Hargs; auto).
    subst vl.
    split; [reflexivity|].
    split; [reflexivity|].
    eapply has_ext_compat in Htrace as [? Htrace]; eauto; [|eapply join_sub_trans; eexists; eauto]; subst.
    split; [auto|].
    split; [exact Hvalid|].
    split; [exact Hn|].
    split.
    + destruct (data_at__writable_perm _ _ _ _ jm Hwritable Hbuf) as (b0 & ofs & Hp & Hperm).
      { apply join_sub_trans with phir; [eexists; exact J2|].
        apply join_sub_trans with phi0; [eexists; apply join_comm; exact J1|].
        eexists; exact J. }
      subst p. simpl in Hperm.
      rewrite ?Z.mul_1_l in Hperm. rewrite Z.max_r in Hperm by lia. exact Hperm.
    + pose proof Herr as Herr'. destruct Herr' as [Hfc _].
      apply field_compatible_isptr in Hfc.
      assert (Hsub : join_sub phie (m_phi jm)).
      { apply join_sub_trans with phir; [eexists; apply join_comm; exact J2|].
        apply join_sub_trans with phi0; [eexists; apply join_comm; exact J1|].
        eexists; exact J. }
      pose proof (proj1 Herr) as Hfc'.
      destruct (gv errno_id) eqn:Hgv; try contradiction.
      exists er. eapply errno_at_dry_pre; eauto.
    all: match goal with |- ?G => idtac "READ PRE leftover:" G end.
  - (* write *)
    clear H. unfold funspec2pre; simpl.
    if_tac; [|contradiction].
    intros; subst.
    destruct t as (phi1 & ts & w). simpl in *.
    destruct H1 as (Hty & phi0 & phi1' & J & Hpre & Hr & Hext).
    destruct e; inv H; simpl in *.
    destruct w as (((((gv & s) & p) & bs) & er) & sh).
    unfold SEPx in Hpre; simpl in Hpre.
    rewrite seplog.sepcon_emp in Hpre.
    destruct Hpre as [[Hvalid [Hreadable [Hlen [Hfd _]]]] [Hargs [_ [phig [phir [J1 [Htrace Hrest]]]]]]].
    destruct Hrest as [phib [phie [J2 [Hbuf Herr]]]].
    assert (Hvl : vl = [vint (out_fd s); p; Vlong (Int64.repr (Zlength bs))]) by (inv Hargs; auto).
    subst vl.
    split; [reflexivity|].
    split; [reflexivity|].
    eapply has_ext_compat in Htrace as [? Htrace]; eauto; [|eapply join_sub_trans; eexists; eauto]; subst.
    split; [auto|].
    split; [exact Hvalid|].
    split; [exact Hlen|].
    split.
    + unfold Specs.byte_array in Hbuf.
      eapply data_at_bytes in Hbuf; eauto.
      { destruct p; try contradiction.
        unfold bytes_to_memvals; rewrite map_map in Hbuf; eauto. }
      { rewrite Zlength_map; auto. }
      { apply join_sub_trans with phir; [eexists; exact J2|].
        apply join_sub_trans with phi0; [eexists; apply join_comm; exact J1|].
        eexists; exact J. }
      { apply Forall_map, Forall_forall; simpl; discriminate. }
    + pose proof Herr as Herr'. destruct Herr' as [Hfc _].
      apply field_compatible_isptr in Hfc.
      assert (Hsub : join_sub phie (m_phi jm)).
      { apply join_sub_trans with phir; [eexists; apply join_comm; exact J2|].
        apply join_sub_trans with phi0; [eexists; apply join_comm; exact J1|].
        eexists; exact J. }
      pose proof (proj1 Herr) as Hfc'.
      destruct (gv errno_id) eqn:Hgv; try contradiction.
      exists er. eapply errno_at_dry_pre; eauto.
    all: match goal with |- ?G => idtac "WRITE PRE leftover:" G end.
Qed.

End IOWJuicyPre.
