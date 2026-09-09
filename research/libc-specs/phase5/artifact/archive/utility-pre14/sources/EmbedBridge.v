(* World/ghost embedding bridge, one level above AssertionBridge.v's
   assertion projections and with every type/state boundary kept explicit:

   1. `relay_dry_spec_local`: relay's dry external_specification
      (relay/adequacy/Dry.v's `relay_dry_spec`) restated over
      `Specs.Relay_Espec ext_link` instead of `Main.Espec` (same
      `add_funspecs` construction; Main.v is the OOM import, see README).
      Its pre/post are MemAdequacy/DryPost's already-restated
      `relay_*_dry_pre/post`.
   2. `embed_dry_witness`: the witness transport
      `ext_spec_type relay_dry_spec_local ef -> ext_spec_type iow_dry_spec ef`
      (a relay WITH-tuple becomes the generalized one at n = 32, world along
      `embed`, plus the caller-supplied `gv`/errno value that relay has no
      counterpart for).
   3. `embed_dry_pre`: on the ACTUAL dry records, relay's ext_spec_pre plus
      the extra errno cell fact implies iow_dry_spec's ext_spec_pre at the
      transported witness and the embedded oracle `embed z`.
   4. `read_dry_post_n_to_relay` / `write_dry_post_n_to_relay`: the reverse
      (functional-consequence) direction of DryPost's specialization
      theorems: a generalized dry POST at n = 32/`embed` forces the oracle
      to be the `embed` image of relay's new world and yields relay's own
      dry POST (up to the extra errno store), with errno = 1 on error.
   5. `has_ext_embed`: the ghost-state coercion AssertionBridge.v's header
      said was missing. `has_ext` is typed to an oracle type Z through the
      ghost PCM `ext_PCM Z`; two `has_ext`s at different Z are different
      resources. The coercion is `set_ghost` replacing the ghost head
      `ext_ghost a` (PCM Z) by `ext_ghost (f a)` (PCM Z'); this is
      dry_mem_lemmas.change_has_ext generalized from one Z to Z -> Z' (its
      proof never used a = a' or Z = Z'). Instance: relay-typed
      `has_ext w` to IOW-typed `has_ext (embed w)`.
   Not claimed: a funspec_sub between the two DECLAREs (the errno resource
   makes it impossible, README "extras" point 1) or a juicy-level PRE
   transport of whole witnesses (that would need to re-establish
   ext_compat of the juicy memory under the coerced ghost; scoped in NEXT). *)
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
Require Specs.
Require Import IOWorld IOSpecs.
Require Import Specialize MemAdequacy DryPost JuicyDry.
Import ListNotations.
Local Open Scope Z_scope.

(* ---- 5. ghost-state coercion across oracle types ---- *)

Lemma has_ext_embed : forall {Z Z'} (f : Z -> Z') (a : Z) r rest H,
  app_pred (has_ext a) r ->
  app_pred (has_ext (f a)) (set_ghost r (Some (ext_ghost (f a), NoneP) :: rest) H).
Proof.
  intros; simpl in *.
  destruct H0 as (p & ? & ?); exists p.
  unfold set_ghost; rewrite resource_at_make_rmap, ghost_of_make_rmap.
  split; auto.
  exists (None :: rest); repeat constructor.
  match goal with |- join ?a _ ?b => assert (a = b) as ->; [|constructor] end.
  unfold ext_ghost; repeat f_equal.
Qed.

Corollary has_ext_relay_to_iow : forall (w : RelayProtocol.world) r rest H,
  app_pred (has_ext w) r ->
  app_pred (has_ext (embed w)) (set_ghost r (Some (ext_ghost (embed w), NoneP) :: rest) H).
Proof. intros; apply (has_ext_embed embed); auto. Qed.

(* ---- 4. reverse direction of DryPost's specializations ---- *)

Theorem read_dry_post_n_to_relay : forall m0 m r w p ep x,
  RelayProtocol.valid_reads (RelayProtocol.reads w) ->
  read_dry_post_n 32 m0 m r (embed w, p, ep) x ->
  x = embed (RelayProtocol.read_world (RelayProtocol.read32 w)) /\
  exists m1 e',
    relay_read_dry_post m0 m1 r (w, p) (RelayProtocol.read_world (RelayProtocol.read32 w)) /\
    (RelayProtocol.read_ret (RelayProtocol.read32 w) < 0 -> e' = 1) /\
    errno_dry_post_effect m1 m ep e'.
Proof.
  intros m0 m r w p ep x Hv Hpost.
  pose proof (Specialize.read_n_specializes_read32 w Hv) as Heq.
  unfold read_dry_post_n in Hpost. rewrite Heq in Hpost. simpl in Hpost.
  destruct Hpost as (Hr & Hx & m1 & e' & Hbuf & Hecond & Herr).
  split; [exact Hx|].
  exists m1, e'. split; [|split; [|exact Herr]].
  - unfold relay_read_dry_post. split; [exact Hr|]. split; [reflexivity|]. exact Hbuf.
  - intro Hlt. rewrite (Hecond Hlt), (proj2 (Z.ltb_lt _ _) Hlt). reflexivity.
Qed.

Theorem write_dry_post_n_to_relay : forall m0 m r w bs p ep x,
  RelayProtocol.valid_writes (RelayProtocol.writes w) ->
  write_dry_post_n m0 m r (embed w, p, bs, ep) x ->
  x = embed (RelayProtocol.write_world (RelayProtocol.write_block w bs)) /\
  exists e',
    relay_write_dry_post m0 m0 r (w, p, bs) (RelayProtocol.write_world (RelayProtocol.write_block w bs)) /\
    (RelayProtocol.write_ret (RelayProtocol.write_block w bs) < 0 -> e' = 1) /\
    errno_dry_post_effect m0 m ep e'.
Proof.
  intros m0 m r w bs p ep x Hv Hpost.
  pose proof (Specialize.write_n_specializes_write_block w bs Hv) as Heq.
  unfold write_dry_post_n in Hpost. rewrite Heq in Hpost. simpl in Hpost.
  destruct Hpost as (Hr & Hx & e' & Hecond & Herr).
  split; [exact Hx|].
  exists e'. split; [|split; [|exact Herr]].
  - unfold relay_write_dry_post. split; [reflexivity|]. split; [exact Hr | reflexivity].
  - intro Hlt. rewrite (Hecond Hlt), (proj2 (Z.ltb_lt _ _) Hlt). reflexivity.
Qed.

Section EmbedDry.
Variable errno_id : ident.
Variable ext_link : string -> ident.

Notation iow_dry_spec' := (iow_dry_spec errno_id ext_link).

(* ---- 1. relay's dry record over Relay_Espec (not Main.Espec) ---- *)

Definition relay_ext_spec_local := @OK_spec (Specs.Relay_Espec ext_link).

Program Definition relay_dry_spec_local : external_specification mem external_function RelayProtocol.world.
Proof.
  unshelve econstructor.
  - intro e.
    pose (ext_spec_type relay_ext_spec_local e) as T; simpl in T.
    destruct (oi_eq_dec _ _); [|destruct (oi_eq_dec _ _); [|exact False]];
      match goal with T := (_ * ?A)%type |- _ => exact (mem * A)%type end.
  - simpl; intros e x ge_s tys args z m.
    destruct (oi_eq_dec _ _); [|destruct (oi_eq_dec _ _); [|contradiction]].
    + destruct x as (m0 & _ & w).
      exact ((let '(s, p, sh) := w in args = [Vint Int.zero; p; Vlong (Int64.repr 32)]) /\
             m0 = m /\ (let '(s, p, sh) := w in relay_read_dry_pre m (s, p) z)).
    + destruct x as (m0 & _ & w).
      exact ((let '(s, p, bs, sh) := w in args = [Vint Int.one; p; Vlong (Int64.repr (Zlength bs))]) /\
             m0 = m /\ (let '(s, p, bs, sh) := w in relay_write_dry_pre m (s, p, bs) z)).
  - simpl; intros e x ge_s ot ret z m.
    destruct (oi_eq_dec _ _); [|destruct (oi_eq_dec _ _); [|contradiction]].
    + destruct x as (m0 & _ & w).
      destruct ret as [v|]; [|exact False].
      destruct v; [exact False | exact False | | exact False | exact False | exact False].
      exact (ot <> Xvoid /\ (let '(s, p, sh) := w in relay_read_dry_post m0 m i (s, p) z)).
    + destruct x as (m0 & _ & w).
      destruct ret as [v|]; [|exact False].
      destruct v; [exact False | exact False | | exact False | exact False | exact False].
      exact (ot <> Xvoid /\ (let '(s, p, bs, sh) := w in relay_write_dry_post m0 m i (s, p, bs) z)).
  - intros; exact True.
Defined.

(* ---- 2. witness transport ---- *)

Definition embed_dry_witness (gv : globals) (e : Z) : forall ef,
  ext_spec_type relay_dry_spec_local ef -> ext_spec_type iow_dry_spec' ef.
Proof.
  simpl; intros ef X.
  destruct (oi_eq_dec _ _); [|destruct (oi_eq_dec _ _); [|exact X]].
  - destruct X as (m0 & X). destruct X as [ts w]. destruct w as ((s & p) & sh).
    exact (m0, existT _ ts (gv, embed s, p, 32, e, sh)).
  - destruct X as (m0 & X). destruct X as [ts w]. destruct w as (((s & p) & bs) & sh).
    exact (m0, existT _ ts (gv, embed s, p, bs, e, sh)).
Defined.

(* ---- 3. PRE transport on the actual records ---- *)

Theorem embed_dry_pre : forall gv e ef t b tl vl z m,
  ext_spec_pre relay_dry_spec_local ef t b tl vl z m ->
  errno_dry_pre m (gv errno_id) e ->
  ext_spec_pre iow_dry_spec' ef (embed_dry_witness gv e ef t) b tl vl (embed z) m.
Proof.
  intros gv e ef. simpl. unfold embed_dry_witness. simpl.
  if_tac.
  - (* read *)
    intros t b tl vl z m Hpre Herr.
    destruct t as (m0 & ts & w). destruct w as ((s & p) & sh). simpl in *.
    destruct Hpre as (Hargs & Hm0 & Hpre).
    split; [rewrite Hargs; reflexivity|].
    split; [exact Hm0|].
    pose proof Hpre as Hsz. unfold relay_read_dry_pre in Hsz. destruct Hsz as (Hsz & _). subst z.
    exact (read_dry_pre_specializes _ _ _ _ _ Hpre Herr).
  - (* write *)
    clear H. simpl. if_tac; [|contradiction].
    intros t b tl vl z m Hpre Herr.
    destruct t as (m0 & ts & w). destruct w as (((s & p) & bs) & sh). simpl in *.
    destruct Hpre as (Hargs & Hm0 & Hpre).
    split; [rewrite Hargs; reflexivity|].
    split; [exact Hm0|].
    pose proof Hpre as Hsz. unfold relay_write_dry_pre in Hsz. destruct Hsz as (Hsz & _). subst z.
    exact (write_dry_pre_specializes _ _ _ _ _ _ Hpre Herr).
Qed.

End EmbedDry.
