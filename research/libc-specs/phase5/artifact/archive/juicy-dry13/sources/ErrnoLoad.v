(* Scalar errno memory bridge, completing what ErrnoBridge.v started:
   from the juicy fact `errno_at (Vptr b ofs) e` (a `data_at Ews tint`) held
   by some phi with `join_sub phi (m_phi jm)`, derive the exact dry fact
   `Mem.loadbytes (m_dry jm) b (Ptrofs.unsigned ofs) 4 = Some (errno_memval e)`
   that MemAdequacy.errno_dry_pre is stated with. Two genuinely new pieces
   relative to dry_mem_lemmas.v:
   - `address_mapsto_loadbytes`: chunk-generic resource extraction from ONE
     `address_mapsto` (which spans size_chunk ch consecutive addresses via a
     single `allp (jam ..)`), rather than data_at_bytes's induction over an
     array of one-byte mapstos; same JMcontents/JMaccess/getN mechanics.
   - `decode_val_Mint32_inj`: decode_val Mint32 bl = Vint i with |bl| = 4
     forces bl = encode_val Mint32 (Vint i). Proved from
     bytes_of_int/int_of_bytes (a new round-trip lemma
     `bytes_of_int_of_bytes`, the inverse direction of CompCert's
     `int_of_bytes_of_int`) plus proj/inj_bytes; the Fragment/None branch is
     ruled out by Archi.ptr64 = true (x86_64), not assumed. *)
Require Import VST.floyd.proofauto.
Require Import VST.veric.res_predicates.
Require Import VST.veric.juicy_mem.
Require Import VST.veric.compcert_rmaps.
Require Import dry_mem_lemmas.
Require Import IOSpecs.
Require Import MemAdequacy.
Require Import ErrnoBridge.
Import ListNotations.
Import Maps.
Local Open Scope Z_scope.

(* ---- integer/byte round trip, the direction CompCert's Memdata does not
   state (it has int_of_bytes_of_int) ---- *)

Lemma bytes_of_int_of_bytes : forall l, bytes_of_int (length l) (int_of_bytes l) = l.
Proof.
  induction l as [|b l IH]; [reflexivity|].
  cbn [bytes_of_int int_of_bytes Datatypes.length].
  pose proof (Byte.unsigned_range b) as Hb. change Byte.modulus with 256 in Hb.
  f_equal.
  - transitivity (Byte.repr (Byte.unsigned b)); [|apply Byte.repr_unsigned].
    apply Byte.eqm_samerepr. red. exists (int_of_bytes l).
    change Byte.modulus with 256. lia.
  - replace ((Byte.unsigned b + int_of_bytes l * 256) / 256) with (int_of_bytes l).
    + exact IH.
    + rewrite Z.div_add by lia. rewrite Z.div_small by lia. lia.
Qed.

Lemma decode_val_Mint32_inj : forall bl i,
  length bl = 4%nat -> decode_val Mint32 bl = Vint i -> bl = encode_val Mint32 (Vint i).
Proof.
  intros bl i Hlen Hdec.
  unfold decode_val in Hdec. destruct (proj_bytes bl) as [bs|] eqn:Hp.
  - injection Hdec as Hi. subst i.
    apply inj_proj_bytes in Hp. subst bl.
    rewrite length_inj_bytes in Hlen.
    simpl. f_equal.
    assert (Hrange : 0 <= decode_int bs <= Int.max_unsigned).
    { unfold decode_int. pose proof (int_of_bytes_range (rev_if_be bs)) as H.
      rewrite rev_if_be_length, Hlen in H.
      assert (two_p (Z.of_nat 4 * 8) = Int.modulus) by reflexivity.
      unfold Int.max_unsigned. lia. }
    rewrite Int.unsigned_repr by exact Hrange.
    unfold encode_int, decode_int.
    rewrite <- (rev_if_be_involutive bs) at 1. f_equal.
    rewrite <- (bytes_of_int_of_bytes (rev_if_be bs)) at 1.
    rewrite rev_if_be_length, Hlen. reflexivity.
  - assert (Hp64 : Archi.ptr64 = true) by reflexivity.
    rewrite Hp64 in Hdec. discriminate.
Qed.

(* ---- getN from per-address contents ---- *)

Lemma getN_contents : forall m b (bl : list memval) lo,
  (forall k, (k < length bl)%nat -> contents_at m (b, lo + Z.of_nat k) = nth k bl Undef) ->
  Mem.getN (length bl) lo (PMap.get b (Mem.mem_contents m)) = bl.
Proof.
  induction bl as [|a bl IH]; intros lo H; simpl; auto.
  f_equal.
  - specialize (H O ltac:(simpl; lia)). unfold contents_at in H; simpl in H.
    rewrite Z.add_0_r in H. exact H.
  - apply IH. intros k Hk.
    specialize (H (S k) ltac:(simpl; lia)). simpl in H.
    rewrite <- H. f_equal. f_equal. lia.
Qed.

(* ---- chunk-generic: one address_mapsto held by a sub-rmap of a juicy
   memory yields a loadbytes of its bytes ---- *)

Lemma address_mapsto_loadbytes : forall ch v sh b ofs phi jm,
  app_pred (address_mapsto ch v sh (b, ofs)) phi ->
  join_sub phi (m_phi jm) ->
  exists bl, length bl = size_chunk_nat ch /\ decode_val ch bl = v /\
    Mem.loadbytes (m_dry jm) b ofs (size_chunk ch) = Some bl.
Proof.
  intros ch v sh b ofs phi jm Hmap Hsub.
  destruct Hmap as [bl [[Hlen [Hdec Halign]] Hres]].
  exists bl. split; [exact Hlen|]. split; [exact Hdec|].
  assert (Hk : forall o, ofs <= o < ofs + size_chunk ch ->
    exists sh' rsh', m_phi jm @ (b, o) = YES sh' rsh' (VAL (nth (Z.to_nat (o - ofs)) bl Undef)) NoneP).
  { intros o Ho. specialize (Hres (b, o)). simpl in Hres.
    rewrite if_true in Hres by (unfold adr_range; split; auto).
    destruct Hres as [rsh Hres]. hnf in Hres.
    try rewrite preds_fmap_NoneP in Hres.
    destruct Hsub as [phi' J]. apply (resource_at_join _ _ _ (b, o)) in J.
    rewrite Hres in J. inv J; eauto. }
  assert (Hperm : Mem.range_perm (m_dry jm) b ofs (ofs + size_chunk ch) Cur Readable).
  { intros o Ho. destruct (Hk o Ho) as (sh' & rsh' & Hy).
    pose proof (juicy_mem_access jm (b, o)) as Ha. rewrite Hy in Ha; simpl in Ha.
    eapply access_at_readable; eauto. }
  Transparent Mem.loadbytes.
  unfold Mem.loadbytes.
  Opaque Mem.loadbytes.
  destruct (Mem.range_perm_dec (m_dry jm) b ofs (ofs + size_chunk ch) Cur Readable); [|contradiction].
  f_equal.
  change (Z.to_nat (size_chunk ch)) with (size_chunk_nat ch).
  rewrite <- Hlen.
  apply getN_contents.
  intros k Hkl.
  assert (Ho : ofs <= ofs + Z.of_nat k < ofs + size_chunk ch).
  { rewrite size_chunk_conv, <- Hlen. lia. }
  destruct (Hk _ Ho) as (sh' & rsh' & Hy).
  pose proof (juicy_mem_contents jm _ _ _ _ _ Hy) as [Hc _].
  rewrite Hc. f_equal. rewrite Z.add_simpl_l, Nat2Z.id. reflexivity.
Qed.

(* ---- the errno cell specifically ---- *)

Theorem errno_at_loadbytes : forall b ofs e phi jm,
  field_compatible tint [] (Vptr b ofs) ->
  app_pred (IOSpecs.errno_at (Vptr b ofs) e) phi ->
  join_sub phi (m_phi jm) ->
  Mem.loadbytes (m_dry jm) b (Ptrofs.unsigned ofs) 4 = Some (errno_memval e).
Proof.
  intros b ofs e phi jm Hfc Herr Hsub.
  rewrite errno_at_address_mapsto in Herr by exact Hfc.
  destruct Herr as [_ Hmap].
  destruct (address_mapsto_loadbytes _ _ _ _ _ _ _ Hmap Hsub) as (bl & Hlen & Hdec & Hload).
  change (size_chunk Mint32) with 4 in Hload.
  change (size_chunk_nat Mint32) with 4%nat in Hlen.
  apply decode_val_Mint32_inj in Hdec; [|exact Hlen]. subst bl.
  exact Hload.
Qed.

Corollary errno_at_dry_pre : forall b ofs e phi jm,
  field_compatible tint [] (Vptr b ofs) ->
  app_pred (IOSpecs.errno_at (Vptr b ofs) e) phi ->
  join_sub phi (m_phi jm) ->
  errno_dry_pre (m_dry jm) (Vptr b ofs) e.
Proof.
  intros; unfold errno_dry_pre; eapply errno_at_loadbytes; eauto.
Qed.
