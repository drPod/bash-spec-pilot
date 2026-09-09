(* Dry (CompCert-memory) external specification for the exit-wrapper program
   relay_exit.prog (adequacy-resume-2) and its adequacy with respect to the
   juicy funspecs of MainExit.v.

   read/write: exactly the cases of ../Dry.v (same witnesses, same
   Mem.storebytes / Mem.loadbytes effects, same no-effect error cases); the
   proof scripts are Dry.v's, replayed under the three-case specification.

   exit(status): dry precondition
     args = [Vint (Int.repr status)] /\ final = z /\ outcome w0 status final pending
   for the witness (status, final, pending): the argument actually passed is
   the status, the current oracle is the world `final`, and the program has
   established `outcome w0 status final pending` for the INITIAL world w0 (this
   is main's obligation, proved in MainExit.body_main from relay's
   postcondition; it is not assumed of read/write).  Dry postcondition: False,
   i.e. the environment never returns from exit (VST's own exit_spec' has the
   same shape).  Nothing about the host OS is asserted.

   The dry exit predicate is still True (forced by funspec2extspec /
   postcondition_allows_exit, see ../Dry.v); the returned status is recovered
   from the exit CALL's precondition instead. *)
Require Import VST.floyd.proofauto.
Require Import VST.sepcomp.extspec.
Require Import VST.veric.semax_ext.
Require Import VST.veric.juicy_mem.
Require Import VST.veric.compcert_rmaps.
Require Import VST.veric.initial_world.
Require Import VST.veric.ghost_PCM.
Require Import VST.veric.SequentialClight.
Require Import VST.concurrency.conclib.
Require Import dry_mem_lemmas.
Require Import VST.veric.mem_lessdef.
Require Import relay_exit Protocol Reach MainExit.
Import RelayProtocol RelayReach.
Local Open Scope Z_scope.

Local Opaque RelayProtocol.read32 RelayProtocol.write_block Z.ltb.

Section Exit_Dry.

Variable w0 : world.

Definition bytes_to_memvals li := concat (map (fun i => encode_val Mint8unsigned (Vubyte i)) li).

Lemma bytes_to_memvals_length : forall li, Zlength (bytes_to_memvals li) = Zlength li.
Proof.
  intros.
  rewrite !Zlength_correct; f_equal.
  unfold bytes_to_memvals.
  rewrite <- map_map, encode_vals_length, map_length; auto.
Qed.

(* ---- dry pre/post for the two primitives ---- *)

(* read(0, p, 32): the caller owns a writable 32-byte range at p.  The witness
   world s is the current oracle. *)
Definition read_dry_pre (m : mem) (w : world * val * share) (z : world) :=
  let '(s, p, sh) := w in
  s = z /\ valid_world s /\
  match p with
  | Vptr b ofs => Mem.range_perm m b (Ptrofs.unsigned ofs) (Ptrofs.unsigned ofs + 32)
                    Memtype.Cur Memtype.Writable
  | _ => False
  end.

(* Result read_ret (read32 s); new oracle read_world (read32 s).  On error the
   memory is unchanged; otherwise exactly the returned bytes were stored at p
   (for EOF the stored list is empty). *)
Definition read_dry_post (m0 m : mem) (r : int64) (w : world * val * share) (z : world) :=
  let '(s, p, sh) := w in
  r = Int64.repr (read_ret (read32 s)) /\ z = read_world (read32 s) /\
  match p with
  | Vptr b ofs =>
      if read_ret (read32 s) <? 0 then m0 = m
      else exists m', Mem.storebytes m0 b (Ptrofs.unsigned ofs)
                        (bytes_to_memvals (read_bytes (read32 s))) = Some m' /\
                      mem_equiv m m'
  | _ => False
  end.

(* write(1, p, |bs|): the bytes actually in memory at p are bs. *)
Definition write_dry_pre (m : mem) (w : world * val * list byte * share) (z : world) :=
  let '(s, p, bs, sh) := w in
  s = z /\ valid_world s /\ 0 < Zlength bs <= 32 /\
  match p with
  | Vptr b ofs => Mem.loadbytes m b (Ptrofs.unsigned ofs) (Zlength bs) = Some (bytes_to_memvals bs)
  | _ => False
  end.

Definition write_dry_post (m0 m : mem) (r : int64) (w : world * val * list byte * share) (z : world) :=
  let '(s, p, bs, sh) := w in
  m0 = m /\ r = Int64.repr (write_ret (write_block s bs)) /\ z = write_world (write_block s bs).

(* exit(status) in world final = z, with the program's outcome established for
   the initial world w0.  No dry post (the call does not return). *)
Definition exit_dry_pre (args : list val) (w : Z * world * list byte) (z : world) :=
  let '(status, final, pending) := w in
  args = [Vint (Int.repr status)] /\ final = z /\ outcome w0 status final pending.

(* The juicy specification actually used by MainExit.prog_correct w0. *)
Definition exit_ext_spec := @OK_spec (Espec w0).

Program Definition exit_dry_spec : external_specification mem external_function world.
Proof.
  unshelve econstructor.
  - intro e.
    pose (ext_spec_type exit_ext_spec e) as T; unfold exit_ext_spec, Espec in T; simpl in T.
    destruct (oi_eq_dec _ _); [|destruct (oi_eq_dec _ _); [|destruct (oi_eq_dec _ _); [|exact False]]];
      match goal with T := (_ * ?A)%type |- _ => exact (mem * A)%type end.
  - simpl; intros e x ge_s tys args z m.
    destruct (oi_eq_dec _ _); [|destruct (oi_eq_dec _ _); [|destruct (oi_eq_dec _ _); [|contradiction]]].
    + destruct x as (m0 & _ & w).
      exact ((let '(s, p, sh) := w in args = [Vint Int.zero; p; Vlong (Int64.repr 32)]) /\
             m0 = m /\ read_dry_pre m w z).
    + destruct x as (m0 & _ & w).
      exact ((let '(s, p, bs, sh) := w in args = [Vint Int.one; p; Vlong (Int64.repr (Zlength bs))]) /\
             m0 = m /\ write_dry_pre m w z).
    + destruct x as (m0 & _ & w).
      exact (exit_dry_pre args w z /\ m0 = m).
  - simpl; intros e x ge_s ot ret z m.
    destruct (oi_eq_dec _ _); [|destruct (oi_eq_dec _ _); [|destruct (oi_eq_dec _ _); [|contradiction]]].
    + destruct x as (m0 & _ & w).
      destruct ret as [v|]; [|exact False].
      destruct v; [exact False | exact False | | exact False | exact False | exact False].
      exact (ot <> Xvoid /\ read_dry_post m0 m i w z).
    + destruct x as (m0 & _ & w).
      destruct ret as [v|]; [|exact False].
      destruct v; [exact False | exact False | | exact False | exact False | exact False].
      exact (ot <> Xvoid /\ write_dry_post m0 m i w z).
    + exact False.
  - intros; exact True.
Defined.

Definition dessicate : forall ef (jm : juicy_mem), ext_spec_type exit_ext_spec ef -> ext_spec_type exit_dry_spec ef.
Proof.
  unfold exit_ext_spec, Espec; simpl; intros.
  destruct (oi_eq_dec _ _); [|destruct (oi_eq_dec _ _); [|destruct (oi_eq_dec _ _); [|assumption]]].
  - destruct X as [_ X]; exact (m_dry jm, X).
  - destruct X as [_ X]; exact (m_dry jm, X).
  - destruct X as [_ X]; exact (m_dry jm, X).
Defined.

(* ---- new memory lemma: inflating an rmap from a store keeps VAL-ness ---- *)

Lemma inflate_store_VALspec_range : forall n sh l m phi,
  app_pred (res_predicates.VALspec_range n sh l) phi ->
  app_pred (res_predicates.VALspec_range n sh l) (inflate_store m phi).
Proof.
  intros n sh l m phi H.
  hnf in H |- *.
  intro loc; specialize (H loc).
  destruct (adr_range_dec l n loc) as [Hin | Hout].
  - rewrite res_predicates.jam_true in H |- * by auto.
    hnf in H; destruct H as (v & H).
    hnf in H; destruct H as (rsh & H).
    hnf in H.
    exists (contents_at m loc).
    hnf; exists rsh.
    hnf.
    unfold inflate_store; rewrite resource_at_make_rmap, level_make_rmap, H.
    rewrite !preds_fmap_NoneP; reflexivity.
  - rewrite res_predicates.jam_false in H |- * by auto.
    hnf in H |- *.
    unfold inflate_store; rewrite resource_at_make_rmap.
    apply empty_NO in H as [H | (k & pds & H)]; rewrite H.
    + apply NO_identity.
    + apply PURE_identity.
Qed.

Local Transparent memory_block.

Lemma inflate_store_data_at_ : forall sh n b o m phi,
  readable_share sh -> 0 <= n ->
  app_pred (data_at_ sh (tarray tuchar n) (Vptr b o)) phi ->
  app_pred (data_at_ sh (tarray tuchar n) (Vptr b o)) (inflate_store m phi).
Proof.
  intros sh n b o m phi Hsh Hn Hdata.
  pose proof (proj1 Hdata) as Hfc.
  assert (Hmod : 0 <= n < Ptrofs.modulus).
  { destruct Hfc as (_ & _ & Hsize & _); simpl in Hsize.
    rewrite Z.max_r in Hsize by lia. pose proof (Ptrofs.unsigned_range o). lia. }
  rewrite <- memory_block_data_at__tarray_tuchar_eq in Hdata |- * by exact Hmod.
  unfold memory_block in Hdata |- *.
  hnf in Hdata; destruct Hdata as [Hbound Hblock]; hnf in Hbound.
  split; [exact Hbound|].
  pose proof (Ptrofs.unsigned_range o) as Hrange.
  change (Ptrofs.unsigned o + n < Ptrofs.modulus) in Hbound.
  assert (Hside1 : 0 <= Ptrofs.unsigned o) by lia.
  assert (Hside2 : Z.of_nat (Z.to_nat n) + Ptrofs.unsigned o < Ptrofs.modulus)
    by (rewrite Z2Nat.id by lia; lia).
  rewrite (mapsto_memory_block.memory_block'_eq sh (Z.to_nat n) b (Ptrofs.unsigned o) Hside1 Hside2) in Hblock |- *.
  unfold mapsto_memory_block.memory_block'_alt in Hblock |- *.
  destruct (readable_share_dec sh); [|contradiction].
  apply inflate_store_VALspec_range; auto.
Qed.

(* ---- adequacy: juicy funspecs of MainExit.Espec w0 versus exit_dry_spec ---- *)

Theorem exit_juicy_dry_specs : juicy_dry_ext_spec _ exit_ext_spec exit_dry_spec dessicate.
Proof.
  split; [|split]; try reflexivity; unfold exit_ext_spec, Espec; simpl.
  - (* preconditions *)
    unfold funspec2pre, dessicate; simpl.
    intros ?; if_tac.
    + (* read *)
      intros; subst.
      destruct t as (? & ? & ((s, p), sh)); simpl in *.
      destruct H1 as (? & phi0 & phi1 & J & Hpre & Hr & Hext).
      destruct e; inv H; simpl in *.
      unfold SEPx in Hpre; simpl in Hpre.
      rewrite seplog.sepcon_emp in Hpre.
      destruct Hpre as [[Hvalid [Hwritable _]] [Hargs [_ [phig [phir [J1 [Htrace Hbuf]]]]]]].
      assert (Hvl : vl = [Vint Int.zero; p; Vlong (Int64.repr 32)]) by (inv Hargs; auto).
      subst vl.
      split; [auto|].
      split; auto.
      eapply has_ext_compat in Htrace as [? Htrace]; eauto; [|eapply join_sub_trans; eexists; eauto]; subst.
      split; auto.
      split; auto.
      destruct (data_at__writable_perm _ _ _ _ jm Hwritable Hbuf) as (? & ? & ? & Hperm); subst; simpl.
      { eapply sepalg.join_sub_trans; [|eexists; eauto].
        eexists; eauto. }
      simpl in Hperm.
      rewrite ?Z.mul_1_l in Hperm; auto.
      all: match goal with |- ?G => idtac "READ PRE leftover:" G end.
      all: match goal with H : _ |- _ => idtac "  hyp:" H end.
    + clear H.
      unfold funspec2pre; simpl.
      if_tac.
      2:{ (* exit: the status argument, current world and outcome *)
        clear H.
        unfold funspec2pre; simpl.
        if_tac; [|contradiction].
        intros; subst.
        destruct t as (? & ? & ((status, final), pending)); simpl in *.
        destruct H1 as (? & phi0 & phi1 & J & Hpre & Hr & Hext).
        destruct e; inv H; simpl in *.
        unfold SEPx in Hpre; simpl in Hpre.
        rewrite seplog.sepcon_emp in Hpre.
        destruct Hpre as [[Houtcome _] [Hargs [_ Htrace]]].
        assert (Hvl : vl = [Vint (Int.repr status)]) by (inv Hargs; auto).
        subst vl.
        eapply has_ext_compat in Htrace as [Hfz _]; eauto.
        all: try (eexists; eassumption).
        all: subst; split; [split; [reflexivity | split; [reflexivity | exact Houtcome]] | reflexivity].
        all: match goal with |- ?G => idtac "EXIT PRE leftover:" G end. }
      (* write *)
      intros; subst.
      destruct t as (? & ? & (((s, p), bs), sh)); simpl in *.
      destruct H1 as (? & phi0 & phi1 & J & Hpre & Hr & Hext).
      destruct e; inv H; simpl in *.
      unfold SEPx in Hpre; simpl in Hpre.
      rewrite seplog.sepcon_emp in Hpre.
      destruct Hpre as [[Hvalid [Hreadable [Hlen _]]] [Hargs [_ [phig [phir [J1 [Htrace Hbuf]]]]]]].
      assert (Hvl : vl = [Vint Int.one; p; Vlong (Int64.repr (Zlength bs))]) by (inv Hargs; auto).
      subst vl.
      split; [auto|].
      split; auto.
      eapply has_ext_compat in Htrace as [? Htrace]; eauto; [|eapply join_sub_trans; eexists; eauto]; subst.
      split; auto.
      split; auto.
      split; auto.
      unfold byte_array in Hbuf.
      eapply data_at_bytes in Hbuf; eauto.
      { destruct p; try contradiction.
        unfold bytes_to_memvals; rewrite map_map in Hbuf; eauto. }
      { rewrite Zlength_map; auto. }
      { eapply join_sub_trans; [|eexists; eauto].
        eexists; eauto. }
      { apply Forall_map, Forall_forall; simpl; discriminate. }
      all: match goal with |- ?G => idtac "WRITE PRE leftover:" G end.
  - (* postconditions *)
    unfold funspec2pre, funspec2post, dessicate; simpl.
    intros ?; if_tac.
    + (* read *)
      intros; subst.
      destruct H0 as (_ & vl & z0 & ? & _ & phi0 & phi1' & J & Hpre & ? & ?).
      destruct t as (phi1 & t); subst; simpl in *.
      destruct t as (? & ((s, p), sh)); simpl in *.
      unfold SEPx in Hpre; simpl in Hpre.
      rewrite seplog.sepcon_emp in Hpre.
      destruct Hpre as [[Hvalid [Hwritable _]] [_ [_ [phig [phir [J1 [Htrace Hbuf]]]]]]].
      edestruct (has_ext_compat _ z0 _ phi0 Htrace) as (? & Hg & Hg0); eauto; [eexists; eauto | eapply ext_compat_sub; eauto; eexists; eauto|]; subst.
      destruct v; try contradiction.
      destruct v; try contradiction.
      destruct H4 as (? & Hret & Hz & Hpost); subst.
      destruct p as [ | ? | ? | ? | ? | pb pofs]; try contradiction.
      pose proof (read_ret_bounds z0) as Hbounds.
      destruct (join_level _ _ _ J).
      match type of Hpost with context [?c <? 0] => destruct (c <? 0) eqn:E end.
      * (* read error: memory unchanged *)
        apply Z.ltb_lt in E.
        rewrite <- Hpost in *.
        rewrite rebuild_same in H2.
        unshelve eexists (age_to.age_to (level jm) (set_ghost phi0 (Some (ext_ghost (read_world (read32 z0)), NoneP) :: tl (ghost_of phi0)) _)), (age_to.age_to (level jm) phi1'); auto.
        { rewrite <- ghost_of_approx at 2; simpl.
          destruct (ghost_of phi0); auto. }
        split; [|split].
        -- eapply age_rejoin; eauto.
           intro; rewrite H2; auto.
        -- split3; simpl.
           { split; auto. }
           { unfold_lift. split; auto. split; [|intro Hx; inv Hx].
             unfold eval_id; simpl. unfold semax.make_ext_rval; simpl.
             destruct ot; try contradiction; reflexivity. }
           unfold SEPx; simpl.
           rewrite seplog.sepcon_emp.
           try (match goal with |- context [if ?c then _ else _] =>
             replace c with true by (destruct (Z.ltb_spec (read_ret (read32 z0)) 0); [reflexivity | lia]) end).
           unshelve eexists (age_to.age_to _ (set_ghost phig (Some (ext_ghost (read_world (read32 z0)), NoneP) :: tl (ghost_of phig)) _)), (age_to.age_to _ phir);
             try (split; [apply age_to.age_to_join_eq|]); try apply set_ghost_join; eauto.
           { rewrite <- ghost_of_approx at 2.
             destruct (ghost_of phig); auto. }
           { apply ghost_of_join in J1.
             rewrite Hg, Hg0 in J1; inv J1; constructor; auto.
             all: match goal with |- ?G => idtac "GHOST goal:" G end.
             all: try (repeat match goal with H : join _ _ _ |- _ => let t := type of H in idtac "  hyp" H ":" t; fail end).
             all: try (repeat match goal with H : _ = _ |- _ => let t := type of H in idtac "  eq" H ":" t; fail end).
             match goal with Hj : join (Some (ext_ghost _, _)) _ _ |- _ =>
               apply ext_ghost_join in Hj as [[]|[]]; eauto; subst end.
             match goal with Hj : Some (ext_ghost _, _) = Some (ext_both _, _) |- _ =>
               apply ghost_not_both in Hj; contradiction end. }
           { unfold set_ghost; rewrite level_make_rmap; lia. }
           split.
           ++ eapply age_to.age_to_pred, change_has_ext; eauto.
           ++ apply age_to.age_to_pred; auto.
        -- eapply necR_trans; eauto; apply age_to.age_to_necR.
        all: match goal with |- ?G => idtac "READ POST ERR leftover:" G end.
      * (* successful read (possibly EOF): the returned prefix was stored *)
        destruct Hpost as (m' & Hstore & Heq).
        apply Z.ltb_ge in E.
        pose proof (read_success_length z0 E) as Hklen.
        set (bs := read_bytes (read32 z0)) in *.
        assert (Hk : 0 <= Zlength bs <= 32) by (rewrite Hklen; lia).
        pose proof (proj1 Hbuf) as Hfc.
        assert (Hbound : Ptrofs.unsigned pofs + Zlength bs <= Ptrofs.max_unsigned).
        { destruct Hfc as (_ & _ & Hsize & _); simpl in Hsize.
          try rewrite Z.max_r in Hsize by lia. unfold Ptrofs.max_unsigned in *; rep_lia. }
        pose proof Hbuf as Hbuf32.
        apply data_at__VALspec_range in Hbuf32; auto.
        (* split the 32-byte buffer at the stored length *)
        assert (Hsplit : data_at_ sh (tarray tuchar 32) (Vptr pb pofs) |--
                  data_at_ sh (tarray tuchar (Zlength bs)) (Vptr pb pofs) *
                  data_at_ sh (tarray tuchar (32 - Zlength bs)) (offset_val (Zlength bs) (Vptr pb pofs))).
        { unfold tarray.
          rewrite (split2_data_at__Tarray_tuchar sh 32 (Zlength bs) (Vptr pb pofs) Hk I Hfc).
          rewrite (tuchar_subarray_offset 32 (Zlength bs) (Vptr pb pofs) Hfc Hk).
          apply derives_refl. }
        rewrite derives_eq in Hsplit.
        destruct (Hsplit _ Hbuf) as (phiA & phiB & JAB & HA & HB).
        apply data_at__VALspec_range in HA; auto.
        unshelve eexists (set_ghost (age_to.age_to (level jm) (inflate_store m' phi0)) (Some (ext_ghost (read_world (read32 z0)), NoneP) :: own.ghost_approx (age_to.age_to (level jm) (inflate_store m' phi0)) (tl (ghost_of phi0))) _),
          (age_to.age_to (level jm) phi1').
        { simpl; rewrite ghost_fmap_fmap, approx_oo_approx; auto. }
        assert (level (age_to.age_to (level (m_phi jm)) (inflate_store m' phi0)) = level (m_phi jm)) as Hl.
        { apply age_to.level_age_to.
          unfold inflate_store; rewrite level_make_rmap; lia. }
        split.
        -- apply resource_at_join2; auto.
           ++ unfold set_ghost; rewrite level_make_rmap; auto.
           ++ rewrite age_to.level_age_to; auto.
              rewrite level_juice_level_phi; lia.
           ++ intros.
              unfold set_ghost; rewrite resource_at_make_rmap.
              eapply rebuild_store; eauto.
              intros (b', o') ???? Hr1 []; subst.
              apply (resource_at_join _ _ _ (b', o')) in J; rewrite Hr1 in J.
              rewrite bytes_to_memvals_length in *.
              apply VALspec_range_e with (loc := (b', o')) in Hbuf32 as [? Hr]; [|split; auto; lia].
              apply (resource_at_join _ _ _ (b', o')) in J1; rewrite Hr in J1.
              inv J1; match goal with Hx : _ = phi0 @ _ |- _ => rewrite <- Hx in J end; inv J;
                eapply join_writable_readable; eauto;
                apply join_comm in RJ; eapply join_writable1; eauto.
           ++ unfold set_ghost; rewrite ghost_of_make_rmap, !age_to_resource_at.age_to_ghost_of.
              rewrite H3.
              apply ghost_of_join in J.
              rewrite level_juice_level_phi, Hl.
              rewrite Hg0 in J; inv J; constructor; auto.
              (* goal 1: the frame's ghost head is either a unit or the reference *)
              destruct (ext_ghost_join _ _ _ _ H12) as [[Ha3 Hd] | [Ha2 Ha3]]; subst.
              { inv H12; [constructor|].
                first [ match goal with Hp : join (ext_ghost _, NoneP) ?a0 (ext_ghost _, NoneP) |- _ =>
                          destruct a0, Hp as (? & ? & ?); simpl in *; subst; rewrite ?preds_fmap_NoneP; eauto end
                      | match goal with Hp : join (_, _) ?a0 _ |- _ =>
                          destruct a0, Hp as (? & ? & ?); simpl in *; subst; rewrite ?preds_fmap_NoneP; eauto end
                      | idtac "GHOST2 case1 unsolved" ]. }
              { (* reference in the frame contradicts ext_compat of the pre juicy memory *)
                unfold semax.ext_compat in H6; rewrite <- H11 in H6.
                exfalso; destruct H6 as [? J']; inv J'.
                eapply no_two_ref; eauto. }
              (* goal 2: the tails *)
              all: try (simpl; apply ghost_fmap_join; auto).
        -- split.
           ++ split3; simpl.
              { split; auto. }
              { unfold_lift. split; auto. split; [|intro Hx; inv Hx].
                unfold eval_id; simpl. unfold semax.make_ext_rval; simpl.
                destruct ot; try contradiction; reflexivity. }
              unfold SEPx; simpl.
              rewrite seplog.sepcon_emp.
              try (match goal with |- context [if ?c then _ else _] =>
                replace c with false by (destruct (Z.ltb_spec (read_ret (read32 z0)) 0); [lia | reflexivity]) end).
              unshelve eexists (set_ghost (age_to.age_to _ phig) (Some (ext_ghost (read_world (read32 z0)), NoneP) :: own.ghost_approx (age_to.age_to (level jm) (inflate_store m' phi0)) (tl (ghost_of phig))) _), (age_to.age_to _ (inflate_store m' phir));
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
                           | idtac "GHOST3 case1 unsolved" ]
                   | apply ghost_not_both in Hc; contradiction ] end.
                 all: try (simpl; apply ghost_fmap_join; auto).
              ** eapply change_has_ext, age_to.age_to_pred; eauto.
              ** apply age_to.age_to_pred.
                 unfold buffer_prefix, byte_array.
                 exists (inflate_store m' phiA), (inflate_store m' phiB).
                 split; [apply inflate_store_join; auto|].
                 split.
                 --- rewrite <- (Zlength_map _ _ Vubyte).
                     eapply store_bytes_data_at; rewrite ?Zlength_map; auto.
                     { rewrite Forall_map, Forall_forall; simpl; intros.
                       exists (Int.repr (Byte.unsigned x)); split; auto.
                       rewrite Int.unsigned_repr; rep_lia. }
                     { rewrite map_map; eauto. }
                 --- apply inflate_store_data_at_; [auto | lia | exact HB].
           ++ eapply necR_trans; eauto; apply age_to.age_to_necR.
        all: match goal with |- ?G => idtac "READ POST STORE leftover:" G end.
    + clear H.
      unfold funspec2pre, funspec2post, dessicate; simpl.
      if_tac.
      2:{ (* exit: no dry postcondition (False) *)
        clear H.
        unfold funspec2pre, funspec2post; simpl.
        if_tac; [|contradiction].
        intros; simpl in *.
        match goal with Hf : False |- _ => destruct Hf end.
        all: match goal with |- ?G => idtac "EXIT POST leftover:" G end. }
      (* write *)
      intros; subst.
      destruct H0 as (_ & vl & z0 & ? & _ & phi0 & phi1' & J & Hpre & ? & ?).
      destruct t as (phi1 & t); subst; simpl in *.
      destruct t as (? & (((s, p), bs), sh)); simpl in *.
      unfold SEPx in Hpre; simpl in Hpre.
      rewrite seplog.sepcon_emp in Hpre.
      destruct Hpre as [[Hvalid [Hreadable [Hlen _]]] [_ [_ [phig [phir [J1 [Htrace Hbuf]]]]]]].
      edestruct (has_ext_compat _ z0 _ phi0 Htrace) as (? & Hg & Hg0); eauto; [eexists; eauto | eapply ext_compat_sub; eauto; eexists; eauto|]; subst.
      destruct v; try contradiction.
      destruct v; try contradiction.
      destruct H4 as (? & Hmem & ? & ?); subst.
      rewrite <- Hmem in *.
      rewrite rebuild_same in H2.
      unshelve eexists (age_to.age_to (level jm) (set_ghost phi0 (Some (ext_ghost (write_world (write_block z0 bs)), NoneP) :: tl (ghost_of phi0)) _)), (age_to.age_to (level jm) phi1'); auto.
      { rewrite <- ghost_of_approx at 2; simpl.
        destruct (ghost_of phi0); auto. }
      destruct (join_level _ _ _ J).
      split; [|split].
      * eapply age_rejoin; eauto.
        intro; rewrite H2; auto.
      * split3; simpl.
        { split; auto. }
        { unfold_lift. split; auto. split; [|intro Hx; inv Hx].
          unfold eval_id; simpl. unfold semax.make_ext_rval; simpl.
          destruct ot; try contradiction; reflexivity. }
        unfold SEPx; simpl.
        rewrite seplog.sepcon_emp.
        unshelve eexists (age_to.age_to _ (set_ghost phig (Some (ext_ghost (write_world (write_block z0 bs)), NoneP) :: tl (ghost_of phig)) _)), (age_to.age_to _ phir);
          try (split; [apply age_to.age_to_join_eq|]); try apply set_ghost_join; eauto.
        { rewrite <- ghost_of_approx at 2.
          destruct (ghost_of phig); auto. }
        { apply ghost_of_join in J1.
          rewrite Hg, Hg0 in J1; inv J1; constructor; auto.
          all: match goal with |- ?G => idtac "GHOST goal:" G end.
             all: try (repeat match goal with H : join _ _ _ |- _ => let t := type of H in idtac "  hyp" H ":" t; fail end).
             all: try (repeat match goal with H : _ = _ |- _ => let t := type of H in idtac "  eq" H ":" t; fail end).
             match goal with Hj : join (Some (ext_ghost _, _)) _ _ |- _ =>
            apply ext_ghost_join in Hj as [[]|[]]; eauto; subst end.
          match goal with Hj : Some (ext_ghost _, _) = Some (ext_both _, _) |- _ =>
            apply ghost_not_both in Hj; contradiction end. }
        { unfold set_ghost; rewrite level_make_rmap; lia. }
        split.
        -- eapply age_to.age_to_pred, change_has_ext; eauto.
        -- apply age_to.age_to_pred; auto.
      * eapply necR_trans; eauto; apply age_to.age_to_necR.
      all: match goal with |- ?G => idtac "WRITE POST leftover:" G end.
Qed.

(* ---- memory evolution ---- *)

Lemma exit_dry_spec_mem : ext_spec_mem_evolve _ exit_dry_spec.
Proof.
  intros ??????????? Hpre Hpost.
  simpl in Hpre, Hpost.
  simpl in *.
  if_tac in Hpre.
  - destruct w as (m0 & _ & ((?, ?), ?)).
    destruct Hpre as (_ & ? & Hpre); subst.
    destruct v; try contradiction.
    destruct v; try contradiction.
    destruct Hpost as (? & ? & ? & Hpost); subst.
    destruct v0; try contradiction.
    match type of Hpost with context [?c <? 0] => destruct (c <? 0) end.
    + subst; reflexivity.
    + destruct Hpost as (? & Hstore & ?).
      eapply mem_evolve_equiv2; [|apply mem_equiv_sym; eauto].
      eapply mem_evolve_access, storebytes_access; eauto.
  - if_tac in Hpre.
    2:{ if_tac in Hpre; [|contradiction].
        simpl in Hpost. destruct Hpost. }
    destruct w as (m0 & _ & (((?, ?), ?), ?)).
    destruct Hpre as (_ & ? & Hpre); subst.
    destruct v; try contradiction.
    destruct v; try contradiction.
    destruct Hpost as (? & ? & ? & ?); subst.
    reflexivity.
Qed.

End Exit_Dry.

Check exit_juicy_dry_specs.
Check exit_dry_spec_mem.
