(* Second batch of POST-preservation auxiliaries (see PostLemmas.v):
   - `inflate_store_unchanged`: if every VAL resource of phi already agrees
     with memory m, then inflate_store m phi = phi. This is what carries an
     UNCHANGED separation-logic resource (the write buffer `byte_array`, or
     the read buffer on the error path) across the errno store: the store
     does not touch those addresses, so their contents still agree and the
     inflated rmap is literally the old one.
   - `errno_at_inflate_store`: the errno cell after storing errno_memval e':
     from errno_at (Vptr b ofs) e held by phi, and a storebytes of
     errno_memval e' at that cell into a memory equivalent to m, derive
     errno_at (Vptr b ofs) e' held by inflate_store m phi. Uses
     inflate_store_address_mapsto plus CompCert's own encode/decode
     round trip (decode_encode_val_general), and ErrnoBridge's
     errno_at_address_mapsto in both directions. *)
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
Require Import IOSpecs MemAdequacy ErrnoBridge ErrnoLoad PostLemmas.
Import ListNotations.
Import Maps.
Local Open Scope Z_scope.

Lemma inflate_store_unchanged : forall m phi,
  (forall l sh rsh v pp, phi @ l = YES sh rsh (VAL v) pp -> contents_at m l = v /\ pp = NoneP) ->
  inflate_store m phi = phi.
Proof.
  intros m phi H.
  apply rmap_ext.
  - unfold inflate_store; rewrite level_make_rmap; reflexivity.
  - intro l. unfold inflate_store; rewrite resource_at_make_rmap.
    destruct (phi @ l) as [| sh rsh k pp |] eqn:Hl; auto.
    destruct k; try (rewrite <- Hl; apply resource_at_approx).
    destruct (H _ _ _ _ _ Hl) as [Hc Hpp]. subst pp. rewrite Hc. reflexivity.
  - unfold inflate_store; rewrite ghost_of_make_rmap; reflexivity.
Qed.

Lemma decode_errno_memval : forall e,
  decode_val Mint32 (errno_memval e) = Vint (Int.repr e).
Proof.
  intro e. unfold errno_memval.
  pose proof (decode_encode_val_general (Vint (Int.repr e)) Mint32 Mint32) as H.
  simpl in H. exact H.
Qed.

Theorem errno_at_inflate_store : forall b ofs e e' phi m,
  field_compatible tint [] (Vptr b ofs) ->
  app_pred (IOSpecs.errno_at (Vptr b ofs) e) phi ->
  Mem.loadbytes m b (Ptrofs.unsigned ofs) 4 = Some (errno_memval e') ->
  app_pred (IOSpecs.errno_at (Vptr b ofs) e') (inflate_store m phi).
Proof.
  intros b ofs e e' phi m Hfc Herr Hload.
  rewrite errno_at_address_mapsto in Herr |- * by exact Hfc.
  destruct Herr as [_ Hmap].
  split; [simpl; auto|].
  pose proof (inflate_store_address_mapsto Mint32 _ _ _ _ m _ _ Hmap Hload) as Hnew.
  rewrite decode_errno_memval in Hnew. exact Hnew.
Qed.
