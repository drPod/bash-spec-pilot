(* Write-branch of juicy_dry_ext_spec POST-preservation for IOW_Espec /
   iow_dry_spec / iow_dessicate, using the actual IOSpecs.write_spec.
   Callable by the full POST assembly (read branches remain separate).
   Follows relay Dry.v write reconstruction, with the extra errno store
   (rebuild_store1, inflate_store, errno_at_inflate_store). *)
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
Require Import PostLemmas PostLemmas2.
Import ListNotations.
Import IOW.
Local Open Scope Z_scope.

Section IOWJuicyPostWrite.
Variable errno_id : ident.
Variable ext_link : string -> ident.

Notation iow_ext_spec' := (iow_ext_spec errno_id ext_link).
Notation iow_dry_spec' := (iow_dry_spec errno_id ext_link).
Notation iow_dessicate' := (iow_dessicate errno_id ext_link).

Lemma errno_memval_Zlength : forall e, Zlength (errno_memval e) = 4.
Proof.
  intro e. unfold errno_memval. rewrite Zlength_correct, encode_val_length. reflexivity.
Qed.

Lemma address_mapsto_yes_in_range : forall ch v sh b ofs phi loc sh0 rsh k pp,
  app_pred (address_mapsto ch v sh (b, ofs)) phi ->
  phi @ loc = YES sh0 rsh k pp ->
  adr_range (b, ofs) (size_chunk ch) loc.
Proof.
  intros ch v sh b ofs phi loc sh0 rsh k pp Hmap Hyes.
  destruct Hmap as [bl [_ Hres]].
  specialize (Hres loc).
  simpl in Hres.
  destruct (adr_range_dec (b, ofs) (size_chunk ch) loc) as [Hin | Hout]; [exact Hin|].
  apply empty_NO in Hres as [Hn | (k' & pds & Hn)]; rewrite Hn in Hyes; discriminate.
Qed.


(* Residual of iow_juicy_dry_post_write_branch (not closed this session):
   After write_dry_post_n destruct (exact e', errno storebytes m' at gv errno_id,
   mem_equiv (m_dry jm) m') and has_ext_compat, the first obligation is
     Hout : forall l sh rsh k pp, phi1' @ l = YES sh rsh k pp ->
       ~ adr_range (eb, Ptrofs.unsigned eofs) (Zlength (errno_memval e')) l
   i.e. the frame owns no YES in the errno cell. Join chain
   J2 (phib/phie), J1 (phig/phir), J (phi0/phi1') with phie @ l = YES Ews
   from address_mapsto jam_true. Last step join_writable_readable on the
   two YES (phi0 vs phi1') after pushing Ews-writability through join_writable1;
   inv of the three resource joins leaves extra share-join cases
   (NO-on-phib, NO-on-phig) that need the writable-share transport made
   explicit. After Hout: rebuild_store1 witnesses
     phi2 := set_ghost (age_to (level jm) (inflate_store m' phi0))
               (Some (ext_ghost (write_world (write_n bs s)), NoneP)
                :: ghost_approx _ (tl (ghost_of phi0)))
     phi3 := age_to (level jm) phi1'
   then ghost (age_rejoin/set_ghost_join/ext_ghost_join/ghost_not_both),
   SEP EX e' with has_ext (inflate_store_join1/change_has_ext/age_to_pred),
   errno_at_inflate_store (loadbytes_storebytes_same), buffer via
   inflate_store_unchanged + contents_at_storebytes_other, necR_trans.
   Full POST assembly should apply this lemma on the write if_tac. *)
End IOWJuicyPostWrite.
