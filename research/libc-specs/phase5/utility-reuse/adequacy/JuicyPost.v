(* juicy_dry_ext_spec, second conjunct (POST-preservation) for the actual
   IOSpecs read_spec/write_spec under IOW_Espec (JuicyDry.v): from the dry
   postcondition iow_dry_spec demands (DryPost.read_dry_post_n /
   write_dry_post_n: exact return value, exact new world, buffer storebytes
   on success, errno storebytes) and the juicy-memory rebuild hypotheses of
   VST.veric.SequentialClight.juicy_dry_ext_spec, reconstruct the juicy
   postcondition of read_spec/write_spec: a frame-preserving split of the
   new juicy memory into a witness rmap satisfying
   EX e', PROP (...) RETURN (...) SEP (has_ext; errno_at e'; buffer)
   and the aged frame. Modeled on relay/adequacy/Dry.v's second bullet;
   the three utility-specific differences are (1) the errno cell is
   ALWAYS stored (relay never touched memory on error / write), so every
   branch uses the inflate_store witness, (2) the read-success branch has
   two stores with a mem_equiv between them (PostLemmas3.rebuild_store2'),
   and (3) the buffer size is parametric n (split at Zlength bs <= n). *)
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
Require Import VST.veric.res_predicates.
Require Import dry_mem_lemmas.
Require Import relay Protocol Reach.
Require Import IOWorld IOSpecs.
Require Import Specialize MemAdequacy DryPost JuicyDry ErrnoBridge ErrnoLoad.
Require Import PostLemmas PostLemmas2 PostLemmas3.
Import ListNotations.
Import IOW.
Local Open Scope Z_scope.


(* The ghost head after the external call: the frame's head is either a
   unit (then the new ext_ghost joins it) or the reference, which the
   ext_compat hypothesis on jm0 rules out. Same case analysis as relay's
   Dry.v, with the auto-generated hypothesis names replaced by patterns. *)
Ltac ghost_head Hext jm0 :=
  match goal with Hj : join (Some (ext_ghost _, _)) ?a2 ?a3 |- _ =>
    destruct (ext_ghost_join _ _ _ _ Hj) as [[Ha3 Hd] | [Ha2 Ha3]]; subst;
    [ inv Hj; [constructor|];
      first [ match goal with Hp : join (ext_ghost _, NoneP) ?a0 (ext_ghost _, NoneP) |- _ =>
                destruct a0, Hp as (? & ? & ?); simpl in *; subst; rewrite ?preds_fmap_NoneP; eauto end
            | match goal with Hp : join (_, _) ?a0 _ |- _ =>
                destruct a0, Hp as (? & ? & ?); simpl in *; subst; rewrite ?preds_fmap_NoneP; eauto end
            | match goal with |- ?G => idtac "GHOST head case unsolved:" G end ]
    | unfold semax.ext_compat in Hext;
      first [ match goal with Hm : _ = ghost_of (m_phi jm0) |- _ => rewrite <- Hm in Hext end
            | match goal with Hm : ghost_of (m_phi jm0) = _ |- _ => rewrite Hm in Hext end ];
      exfalso; destruct Hext as [? J']; inv J'; eapply no_two_ref; eauto ] end.

Section IOWJuicyPost.
Variable errno_id : ident.
Variable ext_link : string -> ident.

Notation iow_ext_spec' := (iow_ext_spec errno_id ext_link).
Notation iow_dry_spec' := (iow_dry_spec errno_id ext_link).
Notation iow_dessicate' := (iow_dessicate errno_id ext_link).

Theorem iow_juicy_dry_post : forall ef t t' b ot v x jm0 jm,
  (exists tl vl x0, iow_dessicate' ef jm0 t = t' /\
     ext_spec_pre iow_ext_spec' ef t b tl vl x0 jm0) ->
  (level jm <= level jm0)%nat ->
  resource_at (m_phi jm) = resource_fmap (approx (level jm)) (approx (level jm))
     oo juicy_mem_lemmas.rebuild_juicy_mem_fmap jm0 (m_dry jm) ->
  ghost_of (m_phi jm) = Some (ext_ghost x, NoneP)
     :: ghost_fmap (approx (level jm)) (approx (level jm)) (tl (ghost_of (m_phi jm0))) ->
  ext_spec_post iow_dry_spec' ef t' b ot v x (m_dry jm) ->
  ext_spec_post iow_ext_spec' ef t b ot v x jm.
Proof.
  intros ef. simpl. unfold funspec2pre, funspec2post, iow_dessicate. simpl.
  if_tac.
  - (* read *)
    intros; subst.
    destruct H0 as (_ & vl & z0 & ? & _ & phi0 & phi1' & J & Hpre & ? & ?).
    destruct t as (phi1 & ts & w); subst; simpl in *.
    destruct w as (((((gv & s) & p) & n) & er) & sh).
    unfold SEPx in Hpre; simpl in Hpre. rewrite seplog.sepcon_emp in Hpre.
    destruct Hpre as [[Hvalid [Hwritable [Hn [Hfd _]]]] [_ [_ [phig [phir [J1 [Htrace Hrest]]]]]]].
    destruct Hrest as [phib [phie [J2 [Hbuf Herr]]]].
    edestruct (has_ext_compat _ z0 _ phi0 Htrace) as (? & Hg & Hg0); eauto; [eexists; eauto | eapply ext_compat_sub; eauto; eexists; eauto|]; subst.
    destruct v; try contradiction. destruct v; try contradiction.
    destruct H4 as (Hot & Hpost). unfold read_dry_post_n in Hpost.
    destruct Hpost as (Hret & Hz & m1 & e' & Hbufeff & Hecond & Herreff).
    subst i x.
    (* pointer shapes *)
    destruct p as [| | | | | pb pofs]; try contradiction.
    pose proof (proj1 Herr) as Hfc.
    pose proof (field_compatible_isptr _ _ _ Hfc) as Hisptr.
    destruct (gv errno_id) as [| | | | | eb eofs] eqn:Hgv; try contradiction.
    destruct Herreff as (m2 & Hst2 & Heq2).
    (* shared facts *)
    pose proof (read_ret_bounds n z0 (proj1 Hn)) as Hbounds.
    destruct (join_level _ _ _ J) as [Hl0 Hl1].
    assert (Hrsh : readable_share sh) by (apply writable_readable_share; exact Hwritable).
    assert (Hsub0 : join_sub phi0 (m_phi jm0)) by (eexists; exact J).
    assert (Hsub_e : join_sub phie phi0).
    { apply join_sub_trans with phir; [eexists; apply join_comm; exact J2 | eexists; apply join_comm; exact J1]. }
    assert (Hsub_b : join_sub phib phi0).
    { apply join_sub_trans with phir; [eexists; exact J2 | eexists; apply join_comm; exact J1]. }
    assert (Hout_e : forall l sh0 rsh k pp, phi1' @ l = YES sh0 rsh k pp ->
      ~ adr_range (eb, Ptrofs.unsigned eofs) (Zlength (errno_memval e')) l).
    { intros l sh0 rsh k pp Hl Hin. rewrite errno_memval_Zlength in Hin.
      destruct (errno_at_YES _ _ _ _ _ Hfc Herr Hin) as (rsh' & vv & Hy).
      destruct (join_sub_YES_writable _ _ _ _ _ _ _ Hsub_e Hy writable_Ews) as (sh' & rsh'' & Hy0 & Hw').
      exact (YES_join_writable_absurd _ _ _ _ _ _ _ _ _ _ _ _ (join_comm J) Hl Hy0 Hw'). }
    assert (Hout_be : forall l sh0 rsh k pp, phib @ l = YES sh0 rsh k pp ->
      ~ adr_range (eb, Ptrofs.unsigned eofs) (Zlength (errno_memval e')) l).
    { intros l sh0 rsh k pp Hl Hin. rewrite errno_memval_Zlength in Hin.
      destruct (errno_at_YES _ _ _ _ _ Hfc Herr Hin) as (rsh' & vv & Hy).
      exact (YES_join_writable_absurd _ _ _ _ _ _ _ _ _ _ _ _ J2 Hl Hy writable_Ews). }
    assert (Hload2 : Mem.loadbytes m2 eb (Ptrofs.unsigned eofs) 4 = Some (errno_memval e')).
    { pose proof (Mem.loadbytes_storebytes_same _ _ _ _ _ Hst2) as Hl2.
      assert (H4 : Z.of_nat (length (errno_memval e')) = 4)
        by (rewrite <- Zlength_correct; apply errno_memval_Zlength).
      rewrite H4 in Hl2. exact Hl2. }
    match type of Hbufeff with context [if ?Y then _ else _] => destruct Y eqn:E end.
    * (* read error: only the errno cell is stored *)
      apply Z.ltb_lt in E.
      assert (Hm1 : m_dry jm0 = m1) by exact Hbufeff.
      subst m1.
      unshelve eexists (set_ghost (age_to.age_to (level jm) (inflate_store m2 phi0)) (Some (ext_ghost (read_world (read_n n z0)), NoneP) :: own.ghost_approx (age_to.age_to (level jm) (inflate_store m2 phi0)) (tl (ghost_of phi0))) _),
        (age_to.age_to (level jm) phi1').
      { simpl; rewrite ghost_fmap_fmap, approx_oo_approx; auto. }
      assert (level (age_to.age_to (level (m_phi jm)) (inflate_store m2 phi0)) = level (m_phi jm)) as Hl.
      { apply age_to.level_age_to.
        unfold inflate_store; rewrite level_make_rmap; lia. }
      split.
      -- apply resource_at_join2; auto.
         ++ unfold set_ghost; rewrite level_make_rmap; auto.
         ++ rewrite age_to.level_age_to; auto.
            rewrite level_juice_level_phi; lia.
         ++ intros loc.
            unfold set_ghost; rewrite resource_at_make_rmap.
            exact (rebuild_store1 jm0 (m_phi jm) (m_dry jm) m2 eb (Ptrofs.unsigned eofs) (errno_memval e') phi0 phi1' loc H1 H2 Hst2 Heq2 J Hout_e).
         ++ unfold set_ghost; rewrite ghost_of_make_rmap, !age_to_resource_at.age_to_ghost_of.
            rewrite H3.
            apply ghost_of_join in J.
            rewrite level_juice_level_phi, Hl.
            rewrite Hg0 in J; inv J; constructor; auto.
            ghost_head H6 jm0.
            all: try (simpl; apply ghost_fmap_join; auto).
            all: match goal with |- ?G => idtac "READ ERR GHOST leftover:" G end.
      -- split.
         ++ exists e'.
            split3; simpl.
            { split; auto. }
            { unfold_lift. split; auto. split; [|intro Hx; inv Hx].
              unfold eval_id; simpl. unfold semax.make_ext_rval; simpl.
              destruct ot; try contradiction; reflexivity. }
            unfold SEPx; simpl.
            rewrite seplog.sepcon_emp.
            try (match goal with |- context [if ?c then _ else _] =>
              replace c with true by (destruct (Z.ltb_spec (read_ret (read_n n z0)) 0); [reflexivity | lia]) end).
            unshelve eexists (set_ghost (age_to.age_to _ phig) (Some (ext_ghost (read_world (read_n n z0)), NoneP) :: own.ghost_approx (age_to.age_to (level jm) (inflate_store m2 phi0)) (tl (ghost_of phig))) _), (age_to.age_to _ (inflate_store m2 phir));
              try (split3; [apply set_ghost_join; [apply age_to.age_to_join_eq | ..] | ..]).
            ** simpl; rewrite Hl, age_to.level_age_to, ghost_fmap_fmap, approx_oo_approx; auto.
               apply join_level in J1 as []; lia.
            ** eapply inflate_store_join1; eauto.
               clear - Htrace. apply has_ext_noat in Htrace. auto.
            ** unfold inflate_store; rewrite level_make_rmap; lia.
            ** rewrite level_juice_level_phi, Hl.
               rewrite age_to_resource_at.age_to_ghost_of.
               unfold inflate_store; rewrite ghost_of_make_rmap.
               apply ghost_of_join in J1; rewrite Hg, Hg0 in J1; inv J1; constructor; auto.
               match goal with Hj : join (Some (ext_ghost _, _)) ?a2 (Some (ext_ghost _, _)) |- _ =>
                 destruct (ext_ghost_join _ _ _ _ Hj) as [[Hc Hd] | [Ha2 Hc]]; subst;
                 [ inv Hj; [constructor|];
                   first [ match goal with Hp : join (ext_ghost _, NoneP) ?a0 (ext_ghost _, NoneP) |- _ =>
                             destruct a0, Hp as (? & ? & ?); simpl in *; subst; rewrite ?preds_fmap_NoneP; eauto end
                         | match goal with Hp : join (_, _) ?a0 _ |- _ =>
                             destruct a0, Hp as (? & ? & ?); simpl in *; subst; rewrite ?preds_fmap_NoneP; eauto end
                         | match goal with |- ?G => idtac "READ ERR GHOST3 case1 unsolved:" G end ]
                 | apply ghost_not_both in Hc; contradiction ] end.
               all: try (simpl; apply ghost_fmap_join; auto).
               all: match goal with |- ?G => idtac "READ ERR GHOST3 leftover:" G end.
            ** eapply change_has_ext, age_to.age_to_pred; eauto.
            ** apply age_to.age_to_pred.
               exists (inflate_store m2 phie), (inflate_store m2 phib).
               split; [apply inflate_store_join; apply join_comm; exact J2|].
               split.
               --- exact (errno_at_inflate_store _ _ _ _ _ _ Hfc Herr Hload2).
               --- rewrite (inflate_store_unchanged m2 phib); [exact Hbuf|].
                   intros l sh0 rsh vv pp Hyl.
                   exact (contents_unchanged_sub jm0 phib _ m2 eb (Ptrofs.unsigned eofs) (errno_memval e') l _ _ _ _
                            (join_sub_trans Hsub_b Hsub0) eq_refl Hst2 (Hout_be _ _ _ _ _ Hyl) Hyl).
         ++ eapply necR_trans; eauto; apply age_to.age_to_necR.
      all: match goal with |- ?G => idtac "READ ERR leftover:" G end.
    * (* successful read (possibly EOF): the prefix was stored, then errno *)
      destruct Hbufeff as (m1' & Hst1 & Heq1).
      apply Z.ltb_ge in E.
      pose proof (read_success_length n z0 (proj1 Hn) E) as Hklen.
      set (bs := read_bytes (read_n n z0)) in *.
      assert (Hk : 0 <= Zlength bs <= n) by (rewrite Hklen; lia).
      pose proof (proj1 Hbuf) as Hfc_b.
      assert (Hbound : Ptrofs.unsigned pofs + Zlength bs <= Ptrofs.max_unsigned).
      { destruct Hfc_b as (_ & _ & Hsize & _); simpl in Hsize.
        rewrite ?Z.mul_1_l in Hsize. rewrite Z.max_r in Hsize by lia.
        unfold Ptrofs.max_unsigned in *; lia. }
      pose proof Hbuf as HbufV.
      apply data_at__VALspec_range in HbufV; [|exact Hrsh].
      (* split the n-byte buffer at the stored length *)
      assert (Hsplit : data_at_ sh (tarray tuchar n) (Vptr pb pofs) |--
                data_at_ sh (tarray tuchar (Zlength bs)) (Vptr pb pofs) *
                data_at_ sh (tarray tuchar (n - Zlength bs)) (offset_val (Zlength bs) (Vptr pb pofs))).
      { unfold tarray.
        rewrite (split2_data_at__Tarray_tuchar sh n (Zlength bs) (Vptr pb pofs) Hk I Hfc_b).
        rewrite (Body.tuchar_subarray_offset n (Zlength bs) (Vptr pb pofs) Hfc_b Hk).
        apply derives_refl. }
      rewrite derives_eq in Hsplit.
      destruct (Hsplit _ Hbuf) as (phiA & phiB & JAB & HA & HB).
      apply data_at__VALspec_range in HA; [|exact Hrsh].
      assert (Hsub_A : join_sub phiA phib) by (eexists; exact JAB).
      (* the frame owns nothing in the stored prefix *)
      assert (Hout_b : forall l sh0 rsh k pp, phi1' @ l = YES sh0 rsh k pp ->
        ~ adr_range (pb, Ptrofs.unsigned pofs) (Zlength (bytes_to_memvals bs)) l).
      { intros l sh0 rsh k pp Hl Hin. rewrite bytes_to_memvals_length in Hin.
        assert (Hin' : adr_range (pb, Ptrofs.unsigned pofs) n l)
          by (destruct l; destruct Hin; split; auto; lia).
        destruct (VALspec_range_e _ _ _ _ _ HbufV Hin') as [[vv rsh'] Hy]; simpl in Hy.
        destruct (join_sub_YES_writable _ _ _ _ _ _ _ Hsub_b Hy Hwritable) as (sh' & rsh'' & Hy0 & Hw').
        exact (YES_join_writable_absurd _ _ _ _ _ _ _ _ _ _ _ _ (join_comm J) Hl Hy0 Hw'). }
      unshelve eexists (set_ghost (age_to.age_to (level jm) (inflate_store m2 phi0)) (Some (ext_ghost (read_world (read_n n z0)), NoneP) :: own.ghost_approx (age_to.age_to (level jm) (inflate_store m2 phi0)) (tl (ghost_of phi0))) _),
        (age_to.age_to (level jm) phi1').
      { simpl; rewrite ghost_fmap_fmap, approx_oo_approx; auto. }
      assert (level (age_to.age_to (level (m_phi jm)) (inflate_store m2 phi0)) = level (m_phi jm)) as Hl.
      { apply age_to.level_age_to.
        unfold inflate_store; rewrite level_make_rmap; lia. }
      split.
      -- apply resource_at_join2; auto.
         ++ unfold set_ghost; rewrite level_make_rmap; auto.
         ++ rewrite age_to.level_age_to; auto.
            rewrite level_juice_level_phi; lia.
         ++ intros loc.
            unfold set_ghost; rewrite resource_at_make_rmap.
            exact (rebuild_store2' jm0 (m_phi jm) (m_dry jm) m1 m1' m2 pb (Ptrofs.unsigned pofs) (bytes_to_memvals bs)
                     eb (Ptrofs.unsigned eofs) (errno_memval e') phi0 phi1' loc H1 H2 Hst1 Heq1 Hst2 Heq2 J Hout_b Hout_e).
         ++ unfold set_ghost; rewrite ghost_of_make_rmap, !age_to_resource_at.age_to_ghost_of.
            rewrite H3.
            apply ghost_of_join in J.
            rewrite level_juice_level_phi, Hl.
            rewrite Hg0 in J; inv J; constructor; auto.
            ghost_head H6 jm0.
            all: try (simpl; apply ghost_fmap_join; auto).
            all: match goal with |- ?G => idtac "READ OK GHOST leftover:" G end.
      -- split.
         ++ exists e'.
            split3; simpl.
            { split; auto. }
            { unfold_lift. split; auto. split; [|intro Hx; inv Hx].
              unfold eval_id; simpl. unfold semax.make_ext_rval; simpl.
              destruct ot; try contradiction; reflexivity. }
            unfold SEPx; simpl.
            rewrite seplog.sepcon_emp.
            try (match goal with |- context [if ?c then _ else _] =>
              replace c with false by (destruct (Z.ltb_spec (read_ret (read_n n z0)) 0); [lia | reflexivity]) end).
            unshelve eexists (set_ghost (age_to.age_to _ phig) (Some (ext_ghost (read_world (read_n n z0)), NoneP) :: own.ghost_approx (age_to.age_to (level jm) (inflate_store m2 phi0)) (tl (ghost_of phig))) _), (age_to.age_to _ (inflate_store m2 phir));
              try (split3; [apply set_ghost_join; [apply age_to.age_to_join_eq | ..] | ..]).
            ** simpl; rewrite Hl, age_to.level_age_to, ghost_fmap_fmap, approx_oo_approx; auto.
               apply join_level in J1 as []; lia.
            ** eapply inflate_store_join1; eauto.
               clear - Htrace. apply has_ext_noat in Htrace. auto.
            ** unfold inflate_store; rewrite level_make_rmap; lia.
            ** rewrite level_juice_level_phi, Hl.
               rewrite age_to_resource_at.age_to_ghost_of.
               unfold inflate_store; rewrite ghost_of_make_rmap.
               apply ghost_of_join in J1; rewrite Hg, Hg0 in J1; inv J1; constructor; auto.
               match goal with Hj : join (Some (ext_ghost _, _)) ?a2 (Some (ext_ghost _, _)) |- _ =>
                 destruct (ext_ghost_join _ _ _ _ Hj) as [[Hc Hd] | [Ha2 Hc]]; subst;
                 [ inv Hj; [constructor|];
                   first [ match goal with Hp : join (ext_ghost _, NoneP) ?a0 (ext_ghost _, NoneP) |- _ =>
                             destruct a0, Hp as (? & ? & ?); simpl in *; subst; rewrite ?preds_fmap_NoneP; eauto end
                         | match goal with Hp : join (_, _) ?a0 _ |- _ =>
                             destruct a0, Hp as (? & ? & ?); simpl in *; subst; rewrite ?preds_fmap_NoneP; eauto end
                         | match goal with |- ?G => idtac "READ OK GHOST3 case1 unsolved:" G end ]
                 | apply ghost_not_both in Hc; contradiction ] end.
               all: try (simpl; apply ghost_fmap_join; auto).
               all: match goal with |- ?G => idtac "READ OK GHOST3 leftover:" G end.
            ** eapply change_has_ext, age_to.age_to_pred; eauto.
            ** apply age_to.age_to_pred.
               exists (inflate_store m2 phie), (inflate_store m2 phib).
               split; [apply inflate_store_join; apply join_comm; exact J2|].
               split.
               --- exact (errno_at_inflate_store _ _ _ _ _ _ Hfc Herr Hload2).
               --- unfold buffer_prefix_n, Specs.byte_array.
                   exists (inflate_store m2 phiA), (inflate_store m2 phiB).
                   split; [apply inflate_store_join; exact JAB|].
                   split.
                   +++ (* the stored prefix: contents of m2 agree with the buffer store's result m1' there *)
                       rewrite (inflate_store_ext m2 m1' phiA).
                       2:{ intros l sh0 rsh vv pp Hyl.
                           rewrite (contents_at_storebytes_other _ _ _ _ _ _ Hst2).
                           2:{ destruct (join_sub_YES _ _ _ _ _ _ _ Hsub_A Hyl) as (sh' & rsh' & Hl' & _).
                               exact (Hout_be _ _ _ _ _ Hl'). }
                           destruct l as (lb & lo).
                           apply mem_equiv_contents; [exact Heq1|].
                           destruct Heq1 as (_ & Hperm1 & _). rewrite Hperm1.
                           eapply Mem.perm_storebytes_1; [exact Hst1|].
                           eapply join_sub_YES_perm_readable; [|exact Hyl].
                           apply join_sub_trans with phib; [exact Hsub_A|].
                           apply join_sub_trans with phi0; [exact Hsub_b | exact Hsub0]. }
                       rewrite <- (Zlength_map _ _ Vubyte).
                       eapply store_bytes_data_at; rewrite ?Zlength_map; auto.
                       { rewrite Forall_map, Forall_forall; simpl; intros bt _.
                         exists (Int.repr (Byte.unsigned bt)); split; auto.
                         rewrite Int.unsigned_repr; rep_lia. }
                       { rewrite map_map; eauto. }
                   +++ apply inflate_store_data_at_; [exact Hrsh | lia | exact HB].
         ++ eapply necR_trans; eauto; apply age_to.age_to_necR.
      all: match goal with |- ?G => idtac "READ OK leftover:" G end.
  - (* write *)
    clear H. unfold funspec2pre, funspec2post; simpl.
    if_tac; [|contradiction].
    intros; subst.
    destruct H0 as (_ & vl & z0 & ? & _ & phi0 & phi1' & J & Hpre & ? & ?).
    destruct t as (phi1 & ts & w); subst; simpl in *.
    destruct w as (((((gv & s) & p) & bs) & er) & sh).
    unfold SEPx in Hpre; simpl in Hpre. rewrite seplog.sepcon_emp in Hpre.
    destruct Hpre as [[Hvalid [Hreadable [Hlen [Hfd _]]]] [_ [_ [phig [phir [J1 [Htrace Hrest]]]]]]].
    destruct Hrest as [phib [phie [J2 [Hbuf Herr]]]].
    edestruct (has_ext_compat _ z0 _ phi0 Htrace) as (? & Hg & Hg0); eauto; [eexists; eauto | eapply ext_compat_sub; eauto; eexists; eauto|]; subst.
    destruct v; try contradiction. destruct v; try contradiction.
    destruct H4 as (Hot & Hpost). unfold write_dry_post_n in Hpost.
    destruct Hpost as (Hret & Hz & e' & Hecond & Herreff).
    subst i x.
    pose proof (proj1 Herr) as Hfc.
    pose proof (field_compatible_isptr _ _ _ Hfc) as Hisptr.
    destruct (gv errno_id) as [| | | | | eb eofs] eqn:Hgv; try contradiction.
    destruct Herreff as (m2 & Hst2 & Heq2).
    destruct (join_level _ _ _ J) as [Hl0 Hl1].
    assert (Hsub0 : join_sub phi0 (m_phi jm0)) by (eexists; exact J).
    assert (Hsub_e : join_sub phie phi0).
    { apply join_sub_trans with phir; [eexists; apply join_comm; exact J2 | eexists; apply join_comm; exact J1]. }
    assert (Hsub_b : join_sub phib phi0).
    { apply join_sub_trans with phir; [eexists; exact J2 | eexists; apply join_comm; exact J1]. }
    assert (Hout_e : forall l sh0 rsh k pp, phi1' @ l = YES sh0 rsh k pp ->
      ~ adr_range (eb, Ptrofs.unsigned eofs) (Zlength (errno_memval e')) l).
    { intros l sh0 rsh k pp Hl Hin. rewrite errno_memval_Zlength in Hin.
      destruct (errno_at_YES _ _ _ _ _ Hfc Herr Hin) as (rsh' & vv & Hy).
      destruct (join_sub_YES_writable _ _ _ _ _ _ _ Hsub_e Hy writable_Ews) as (sh' & rsh'' & Hy0 & Hw').
      exact (YES_join_writable_absurd _ _ _ _ _ _ _ _ _ _ _ _ (join_comm J) Hl Hy0 Hw'). }
    assert (Hout_be : forall l sh0 rsh k pp, phib @ l = YES sh0 rsh k pp ->
      ~ adr_range (eb, Ptrofs.unsigned eofs) (Zlength (errno_memval e')) l).
    { intros l sh0 rsh k pp Hl Hin. rewrite errno_memval_Zlength in Hin.
      destruct (errno_at_YES _ _ _ _ _ Hfc Herr Hin) as (rsh' & vv & Hy).
      exact (YES_join_writable_absurd _ _ _ _ _ _ _ _ _ _ _ _ J2 Hl Hy writable_Ews). }
    assert (Hload2 : Mem.loadbytes m2 eb (Ptrofs.unsigned eofs) 4 = Some (errno_memval e')).
    { pose proof (Mem.loadbytes_storebytes_same _ _ _ _ _ Hst2) as Hl2.
      assert (H4 : Z.of_nat (length (errno_memval e')) = 4)
        by (rewrite <- Zlength_correct; apply errno_memval_Zlength).
      rewrite H4 in Hl2. exact Hl2. }
    unshelve eexists (set_ghost (age_to.age_to (level jm) (inflate_store m2 phi0)) (Some (ext_ghost (write_world (write_n bs z0)), NoneP) :: own.ghost_approx (age_to.age_to (level jm) (inflate_store m2 phi0)) (tl (ghost_of phi0))) _),
      (age_to.age_to (level jm) phi1').
    { simpl; rewrite ghost_fmap_fmap, approx_oo_approx; auto. }
    assert (level (age_to.age_to (level (m_phi jm)) (inflate_store m2 phi0)) = level (m_phi jm)) as Hl.
    { apply age_to.level_age_to.
      unfold inflate_store; rewrite level_make_rmap; lia. }
    split.
    + apply resource_at_join2; auto.
      * unfold set_ghost; rewrite level_make_rmap; auto.
      * rewrite age_to.level_age_to; auto.
        rewrite level_juice_level_phi; lia.
      * intros loc.
        unfold set_ghost; rewrite resource_at_make_rmap.
        exact (rebuild_store1 jm0 (m_phi jm) (m_dry jm) m2 eb (Ptrofs.unsigned eofs) (errno_memval e') phi0 phi1' loc H1 H2 Hst2 Heq2 J Hout_e).
      * unfold set_ghost; rewrite ghost_of_make_rmap, !age_to_resource_at.age_to_ghost_of.
        rewrite H3.
        apply ghost_of_join in J.
        rewrite level_juice_level_phi, Hl.
        rewrite Hg0 in J; inv J; constructor; auto.
        ghost_head H6 jm0.
        all: try (simpl; apply ghost_fmap_join; auto).
        all: match goal with |- ?G => idtac "WRITE GHOST leftover:" G end.
    + split.
      * exists e'.
        split3; simpl.
        { split; auto. }
        { unfold_lift. split; auto. split; [|intro Hx; inv Hx].
          unfold eval_id; simpl. unfold semax.make_ext_rval; simpl.
          destruct ot; try contradiction; reflexivity. }
        unfold SEPx; simpl.
        rewrite seplog.sepcon_emp.
        unshelve eexists (set_ghost (age_to.age_to _ phig) (Some (ext_ghost (write_world (write_n bs z0)), NoneP) :: own.ghost_approx (age_to.age_to (level jm) (inflate_store m2 phi0)) (tl (ghost_of phig))) _), (age_to.age_to _ (inflate_store m2 phir));
          try (split3; [apply set_ghost_join; [apply age_to.age_to_join_eq | ..] | ..]).
        -- simpl; rewrite Hl, age_to.level_age_to, ghost_fmap_fmap, approx_oo_approx; auto.
           apply join_level in J1 as []; lia.
        -- eapply inflate_store_join1; eauto.
           clear - Htrace. apply has_ext_noat in Htrace. auto.
        -- unfold inflate_store; rewrite level_make_rmap; lia.
        -- rewrite level_juice_level_phi, Hl.
           rewrite age_to_resource_at.age_to_ghost_of.
           unfold inflate_store; rewrite ghost_of_make_rmap.
           apply ghost_of_join in J1; rewrite Hg, Hg0 in J1; inv J1; constructor; auto.
           match goal with Hj : join (Some (ext_ghost _, _)) ?a2 (Some (ext_ghost _, _)) |- _ =>
             destruct (ext_ghost_join _ _ _ _ Hj) as [[Hc Hd] | [Ha2 Hc]]; subst;
             [ inv Hj; [constructor|];
               first [ match goal with Hp : join (ext_ghost _, NoneP) ?a0 (ext_ghost _, NoneP) |- _ =>
                         destruct a0, Hp as (? & ? & ?); simpl in *; subst; rewrite ?preds_fmap_NoneP; eauto end
                     | match goal with Hp : join (_, _) ?a0 _ |- _ =>
                         destruct a0, Hp as (? & ? & ?); simpl in *; subst; rewrite ?preds_fmap_NoneP; eauto end
                     | match goal with |- ?G => idtac "WRITE GHOST3 case1 unsolved:" G end ]
             | apply ghost_not_both in Hc; contradiction ] end.
           all: try (simpl; apply ghost_fmap_join; auto).
           all: match goal with |- ?G => idtac "WRITE GHOST3 leftover:" G end.
        -- eapply change_has_ext, age_to.age_to_pred; eauto.
        -- apply age_to.age_to_pred.
           exists (inflate_store m2 phie), (inflate_store m2 phib).
           split; [apply inflate_store_join; apply join_comm; exact J2|].
           split.
           ++ exact (errno_at_inflate_store _ _ _ _ _ _ Hfc Herr Hload2).
           ++ rewrite (inflate_store_unchanged m2 phib); [exact Hbuf|].
              intros l sh0 rsh vv pp Hyl.
              exact (contents_unchanged_sub jm0 phib _ m2 eb (Ptrofs.unsigned eofs) (errno_memval e') l _ _ _ _
                       (join_sub_trans Hsub_b Hsub0) eq_refl Hst2 (Hout_be _ _ _ _ _ Hyl) Hyl).
      * eapply necR_trans; eauto; apply age_to.age_to_necR.
    all: match goal with |- ?G => idtac "WRITE leftover:" G end.
Qed.

End IOWJuicyPost.
