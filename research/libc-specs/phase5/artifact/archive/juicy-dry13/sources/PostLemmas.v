(* Auxiliary lemmas for the juicy_dry_ext_spec POST-preservation conjunct
   of IOW_Espec/iow_dry_spec (JuicyDry.v). What differs from relay's
   Dry.v POST proof and therefore needs new lemmas:
   - every branch (read error, read success, write) now stores the errno
     cell, so relay's "memory unchanged" error path does not apply, and the
     read-success branch performs TWO storebytes (buffer, then errno).
     `rebuild_store` (dry_mem_lemmas.v) is single-store; `rebuild_store_gen`
     below abstracts exactly the two facts its proof used the store for
     (access unchanged; contents unchanged wherever the frame phi1 owns a
     VAL), and `rebuild_store2` instantiates it for two sequential stores.
   - the errno cell is a scalar `address_mapsto Mint32`, not a `tarray
     tuchar`, so `store_bytes_data_at` does not apply;
     `inflate_store_address_mapsto` is its scalar counterpart.
   `inflate_store_VALspec_range`/`inflate_store_data_at_` are restated
   verbatim from relay/adequacy/Dry.v (same Main.v OOM reason as
   MemAdequacy.v's IMPORT NOTE); nothing from Dry.v's theorems is used. *)
Require Import VST.floyd.proofauto.
Require Import VST.sepcomp.extspec.
Require Import VST.veric.semax_ext.
Require Import VST.veric.juicy_mem.
Require Import VST.veric.compcert_rmaps.
Require Import VST.veric.initial_world.
Require Import VST.veric.ghost_PCM.
Require Import VST.veric.SequentialClight.
Require Import VST.concurrency.conclib.
Require Import VST.veric.mem_lessdef.
Require Import VST.veric.res_predicates.
Require Import dry_mem_lemmas.
Require Import ErrnoLoad.
Import ListNotations.
Import Maps.
Local Open Scope Z_scope.

(* ---- contents outside a storebytes range are unchanged ---- *)

Lemma contents_at_storebytes_other : forall m1 b ofs bytes m2 loc,
  Mem.storebytes m1 b ofs bytes = Some m2 ->
  ~ adr_range (b, ofs) (Zlength bytes) loc ->
  contents_at m2 loc = contents_at m1 loc.
Proof.
  intros m1 b ofs bytes m2 [b' o'] Hst Hout.
  unfold contents_at; simpl.
  rewrite (Mem.storebytes_mem_contents _ _ _ _ _ Hst).
  rewrite PMap.gsspec.
  destruct (peq b' b); [subst | reflexivity].
  rewrite Mem.setN_outside; [reflexivity|].
  unfold adr_range in Hout. rewrite Zlength_correct in Hout. lia.
Qed.

(* ---- rebuild_store, with the store abstracted to the two facts its
   proof actually uses ---- *)

Lemma rebuild_store_gen : forall jm0 phi m m' phi0 phi1 loc
  (Hlevel : (level phi <= level (m_phi jm0))%nat)
  (Hrebuild : resource_at phi =
     resource_fmap (approx (level phi)) (approx (level phi))
     oo juicy_mem_lemmas.rebuild_juicy_mem_fmap jm0 m)
  (Hacc : access_at (m_dry jm0) = access_at m') (Heq : mem_equiv m m')
  (J : join phi0 phi1 (m_phi jm0))
  (Hcont : forall l sh rsh k p, phi1 @ l = YES sh rsh k p -> contents_at m' l = contents_at (m_dry jm0) l),
  join (age_to.age_to (level phi) (inflate_store m' phi0) @ loc)
         (age_to.age_to (level phi) phi1 @ loc) (phi @ loc).
Proof.
  intros.
  destruct (join_level _ _ _ J).
  rewrite Hrebuild, !age_to_resource_at.age_to_resource_at.
  unfold compose, inflate_store, juicy_mem_lemmas.rebuild_juicy_mem_fmap; rewrite !resource_at_make_rmap.
  apply (resource_at_join _ _ _ loc) in J.
  simpl.
  inv J; try constructor.
  - rewrite if_false; [constructor; auto|].
    erewrite mem_equiv_access by eauto.
    rewrite <- Hacc.
    destruct jm0; simpl in *.
    rewrite (JMaccess loc), <- H4; simpl.
    if_tac; auto.
    intro X; inv X.
  - destruct k; try (rewrite resource_fmap_fmap, approx_oo_approx', approx'_oo_approx by lia; constructor; auto).
    destruct jm0; simpl in *.
    pose proof (JMaccess loc) as Haccess.
    rewrite <- H4 in Haccess; simpl in Haccess.
    rewrite Hacc, <- (mem_equiv_access m m' Heq) in Haccess.
    destruct loc as (b', o').
    erewrite <- (mem_equiv_contents m m'); eauto.
    rewrite Haccess, if_true.
    constructor; auto.
    { unfold perm_of_sh.
      if_tac; if_tac; constructor || contradiction. }
    { eapply access_at_readable; eauto. }
  - destruct k; try (constructor; auto).
    pose proof (juicy_mem_access jm0 loc) as Haccess.
    rewrite <- H4 in Haccess; simpl in Haccess.
    rewrite Hacc, <- (mem_equiv_access m m' Heq) in Haccess.
    rewrite Haccess, if_true.
    destruct loc as (b', o').
    erewrite (mem_equiv_contents m m'); eauto.
    exploit (juicy_mem_contents jm0); eauto; intros []; subst.
    match goal with HY : YES _ _ _ _ = phi1 @ (b', o') |- _ => rewrite (Hcont _ _ _ _ _ (eq_sym HY)) end.
    constructor; auto.
    { eapply access_at_readable; eauto. }
    { unfold perm_of_sh.
      if_tac; if_tac; constructor || contradiction. }
  - destruct k; try (rewrite resource_fmap_fmap, approx_oo_approx', approx'_oo_approx by lia; constructor; auto).
    pose proof (juicy_mem_access jm0 loc) as Haccess.
    rewrite <- H4 in Haccess; simpl in Haccess.
    rewrite Hacc, <- (mem_equiv_access m m' Heq) in Haccess.
    rewrite Haccess, if_true.
    destruct loc as (b', o').
    erewrite (mem_equiv_contents m); eauto.
    exploit (juicy_mem_contents jm0); eauto; intros []; subst.
    match goal with HY : YES _ _ _ _ = phi1 @ (b', o') |- _ => rewrite (Hcont _ _ _ _ _ (eq_sym HY)) end.
    constructor; auto.
    { eapply access_at_readable; eauto. }
    { unfold perm_of_sh.
      if_tac; if_tac; constructor || contradiction. }
Qed.

(* ---- two sequential stores (buffer, then errno) ---- *)

Lemma rebuild_store2 : forall jm0 phi m m1 m2 b1 o1 lv1 b2 o2 lv2 phi0 phi1 loc
  (Hlevel : (level phi <= level (m_phi jm0))%nat)
  (Hrebuild : resource_at phi =
     resource_fmap (approx (level phi)) (approx (level phi))
     oo juicy_mem_lemmas.rebuild_juicy_mem_fmap jm0 m)
  (Hst1 : Mem.storebytes (m_dry jm0) b1 o1 lv1 = Some m1)
  (Hst2 : Mem.storebytes m1 b2 o2 lv2 = Some m2)
  (Heq : mem_equiv m m2)
  (J : join phi0 phi1 (m_phi jm0))
  (Hout1 : forall l sh rsh k p, phi1 @ l = YES sh rsh k p -> ~ adr_range (b1, o1) (Zlength lv1) l)
  (Hout2 : forall l sh rsh k p, phi1 @ l = YES sh rsh k p -> ~ adr_range (b2, o2) (Zlength lv2) l),
  join (age_to.age_to (level phi) (inflate_store m2 phi0) @ loc)
         (age_to.age_to (level phi) phi1 @ loc) (phi @ loc).
Proof.
  intros.
  eapply rebuild_store_gen; eauto.
  - rewrite (storebytes_access _ _ _ _ _ Hst1), (storebytes_access _ _ _ _ _ Hst2); reflexivity.
  - intros l sh rsh k p Hl.
    rewrite (contents_at_storebytes_other _ _ _ _ _ _ Hst2) by (eapply Hout2; eauto).
    rewrite (contents_at_storebytes_other _ _ _ _ _ _ Hst1) by (eapply Hout1; eauto).
    reflexivity.
Qed.

(* ---- single store, same statement shape as relay's rebuild_store, as a
   corollary of the generic one (so the write branch and the read-error
   branch, which only store errno, use the same lemma family) ---- *)

Lemma rebuild_store1 : forall jm0 phi m m1 b1 o1 lv1 phi0 phi1 loc
  (Hlevel : (level phi <= level (m_phi jm0))%nat)
  (Hrebuild : resource_at phi =
     resource_fmap (approx (level phi)) (approx (level phi))
     oo juicy_mem_lemmas.rebuild_juicy_mem_fmap jm0 m)
  (Hst1 : Mem.storebytes (m_dry jm0) b1 o1 lv1 = Some m1)
  (Heq : mem_equiv m m1)
  (J : join phi0 phi1 (m_phi jm0))
  (Hout1 : forall l sh rsh k p, phi1 @ l = YES sh rsh k p -> ~ adr_range (b1, o1) (Zlength lv1) l),
  join (age_to.age_to (level phi) (inflate_store m1 phi0) @ loc)
         (age_to.age_to (level phi) phi1 @ loc) (phi @ loc).
Proof.
  intros.
  eapply rebuild_store_gen; eauto.
  - apply (storebytes_access _ _ _ _ _ Hst1).
  - intros l sh rsh k p Hl.
    apply (contents_at_storebytes_other _ _ _ _ _ _ Hst1); eapply Hout1; eauto.
Qed.

(* ---- restated from relay/adequacy/Dry.v (inflate_store_VALspec_range,
   inflate_store_data_at_), verbatim ---- *)

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

(* ---- new: the scalar counterpart of store_bytes_data_at for the errno
   cell. If phi holds an address_mapsto ch of ANY value at (b,ofs) and the
   final memory m holds bytes bl there, then inflate_store m phi holds
   address_mapsto ch (decode_val ch bl) at (b,ofs). ---- *)

Lemma inflate_store_address_mapsto : forall ch v sh b ofs m phi bl,
  app_pred (address_mapsto ch v sh (b, ofs)) phi ->
  Mem.loadbytes m b ofs (size_chunk ch) = Some bl ->
  app_pred (address_mapsto ch (decode_val ch bl) sh (b, ofs)) (inflate_store m phi).
Proof.
  intros ch v sh b ofs m phi bl Hmap Hload.
  destruct Hmap as [bl0 [[Hlen0 [Hdec0 Halign]] Hres]].
  assert (Hlen : length bl = size_chunk_nat ch).
  { apply Mem.loadbytes_length in Hload. rewrite Hload. reflexivity. }
  assert (Hcont : forall k, (k < size_chunk_nat ch)%nat ->
    contents_at m (b, ofs + Z.of_nat k) = nth k bl Undef).
  { intros k Hk.
    Transparent Mem.loadbytes. unfold Mem.loadbytes in Hload. Opaque Mem.loadbytes.
    destruct (Mem.range_perm_dec m b ofs (ofs + size_chunk ch) Cur Readable); [|discriminate].
    injection Hload as Hload. subst bl.
    change (Z.to_nat (size_chunk ch)) with (size_chunk_nat ch) in *.
    unfold contents_at; simpl.
    clear - Hk.
    revert ofs k Hk; induction (size_chunk_nat ch) as [|n IH]; intros ofs k Hk; [lia|].
    destruct k as [|k]; simpl.
    - rewrite Z.add_0_r; reflexivity.
    - rewrite <- (IH (ofs + 1) k) by lia. f_equal. lia. }
  exists bl. split; [split; [exact Hlen | split; [reflexivity | exact Halign]]|].
  intro loc. specialize (Hres loc). simpl in Hres |- *.
  destruct (adr_range_dec (b, ofs) (size_chunk ch) loc) as [Hin | Hout].
  - destruct Hres as [rsh Hres]. hnf in Hres. exists rsh. hnf.
    unfold inflate_store; rewrite resource_at_make_rmap; try rewrite level_make_rmap; rewrite Hres.
    try rewrite !preds_fmap_NoneP.
    destruct loc as [b' o']. destruct Hin as [Hb Ho]; subst b'.
    assert (Hk : (Z.to_nat (o' - ofs) < size_chunk_nat ch)%nat) by (rewrite size_chunk_conv in Ho; lia).
    assert (Hn : nth (Z.to_nat (o' - ofs)) bl Undef = contents_at m (b, o')).
    { rewrite <- (Hcont _ Hk). f_equal. f_equal. rewrite Z2Nat.id; lia. }
    simpl in Hn |- *. rewrite Hn. try rewrite !preds_fmap_NoneP. reflexivity.
  - hnf in Hres |- *.
    unfold inflate_store; rewrite resource_at_make_rmap.
    apply empty_NO in Hres as [H | (k & pds & H)]; rewrite H.
    + apply NO_identity.
    + apply PURE_identity.
Qed.
