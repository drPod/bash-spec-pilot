(* Checked specialization bridge: the generalized IOW.world primitives
   (../IOWorld.v, ../IOSpecs.v: parametric fd/count, errno-tracking) versus
   the original fixed relay32 primitives (../../relay/Protocol.v, module
   RelayProtocol; ../../relay/Specs.v's read_spec/write_spec). Pure
   mathematics only, no VST/funspec reasoning -- see MemAdequacy.v for the
   CompCert memory layer and README.md for why a literal funspec_sub between
   the two DECLARE-level contracts is NOT proved (and should not be claimed).

   Direction: `embed` takes a relay world to the generalized world with the
   two fds relay hard-codes (in_fd 0, out_fd 1) and an empty diagnostics log
   (relay never calls error()/reports an errno). The two theorems below show
   IOW.read_n/write_n, specialized at n = 32 and along `embed`, compute
   exactly the `embed`-image of RelayProtocol.read32/write_block -- i.e. the
   generalized primitive literally reduces to the original one under that
   instantiation; nothing here is a re-proof of either side's existing
   lemmas (REUSE.md's sense of "reused literally" applies to `action`,
   `prefix`, `suffix`, `min_bounds`, `max_one_positive`, all cited unchanged
   from Protocol.v by IOWorld.v already). *)
Require Import Coq.Lists.List.
Require Import Coq.ZArith.ZArith.
Require Import Coq.micromega.Lia.
From compcert Require Import Integers.
Require Import VST.zlist.sublist.
Require Import Protocol.
Require Import IOWorld.
Import ListNotations.
Import IOW.
Local Open Scope Z_scope.

(* ---- world embedding ---- *)

Definition embed (w : RelayProtocol.world) : IOW.world :=
  IOW.World 0 1
    (RelayProtocol.unread w) (RelayProtocol.delivered w)
    (RelayProtocol.reads w) (RelayProtocol.writes w)
    (RelayProtocol.read_calls w) (RelayProtocol.write_calls w)
    [].

Lemma embed_unread w : IOW.unread (embed w) = RelayProtocol.unread w.
Proof. reflexivity. Qed.
Lemma embed_delivered w : IOW.delivered (embed w) = RelayProtocol.delivered w.
Proof. reflexivity. Qed.
Lemma embed_reads w : IOW.reads (embed w) = RelayProtocol.reads w.
Proof. reflexivity. Qed.
Lemma embed_writes w : IOW.writes (embed w) = RelayProtocol.writes w.
Proof. reflexivity. Qed.
Lemma embed_in_fd w : IOW.in_fd (embed w) = 0. Proof. reflexivity. Qed.
Lemma embed_out_fd w : IOW.out_fd (embed w) = 1. Proof. reflexivity. Qed.
Lemma embed_diagnostics w : IOW.diagnostics (embed w) = []. Proof. reflexivity. Qed.

(* Extras relay does not track at all: read_calls/write_calls are carried
   through unchanged by embed but relay's own theorems never depend on
   them, so no lemma about them is needed for the specialization below. *)

(* embed's only nontrivial algebraic fact: RelayProtocol.valid_world's
   error sentinel is always literally -1 (see Protocol.v's valid_writes:
   `Forall (fun q => -1 <= q) xs`, valid_reads: `Forall (fun q => q = -1
   \/ 0 < q) xs`), so the *value* of a negative schedule action is pinned,
   unlike IOW's general -e (1 <= e <= Int.max_signed). This is exactly the
   "extra errno" IOW adds over relay (see README.md). *)
Lemma relay_read_action_neg1 w : RelayProtocol.valid_reads (RelayProtocol.reads w) ->
  RelayProtocol.action 32 (RelayProtocol.reads w) < 0 ->
  RelayProtocol.action 32 (RelayProtocol.reads w) = -1.
Proof.
  intros Hv Hneg. unfold RelayProtocol.action in *.
  destruct (RelayProtocol.reads w) as [|q rest]; simpl in *; [lia|].
  inversion Hv as [|? ? Hq]; subst. destruct Hq; lia.
Qed.

Lemma relay_write_action_neg1 w (bs : list byte) : RelayProtocol.valid_writes (RelayProtocol.writes w) ->
  RelayProtocol.action (Zlength bs) (RelayProtocol.writes w) < 0 ->
  RelayProtocol.action (Zlength bs) (RelayProtocol.writes w) = -1.
Proof.
  intros Hv Hneg. pose proof (Zlength_nonneg bs). unfold RelayProtocol.action in *.
  destruct (RelayProtocol.writes w) as [|q rest]; simpl in *; [lia|].
  inversion Hv as [|? ? Hq]; subst. lia.
Qed.

(* ---- read specialization ---- *)

Definition embed_read_result (r : RelayProtocol.read_result) : IOW.read_result :=
  IOW.ReadResult (RelayProtocol.read_ret r)
    (if RelayProtocol.read_ret r <? 0 then 1 else 0)
    (RelayProtocol.read_bytes r)
    (embed (RelayProtocol.read_world r)).

Theorem read_n_specializes_read32 : forall w,
  RelayProtocol.valid_reads (RelayProtocol.reads w) ->
  IOW.read_n 32 (embed w) = embed_read_result (RelayProtocol.read32 w).
Proof.
  intros w Hv.
  unfold IOW.read_n, RelayProtocol.read32, embed_read_result, embed, after_read; simpl.
  set (g := RelayProtocol.action 32 (RelayProtocol.reads w)) in *.
  destruct (Z.ltb_spec g 0) as [Hneg | Hpos]; simpl.
  - assert (Hg1 : g = -1) by (subst g; apply relay_read_action_neg1; auto).
    rewrite Hg1. reflexivity.
  - unfold IOW.read_amount, RelayProtocol.read_amount.
    set (k := Z.min (Z.max 1 g) (Z.min 32 (Zlength (RelayProtocol.unread w)))) in *.
    assert (Hk0 : 0 <= k).
    { subst k g. pose proof (RelayProtocol.read_amount_bounds
        (RelayProtocol.action 32 (RelayProtocol.reads w)) (RelayProtocol.unread w)) as Hb.
      unfold RelayProtocol.read_amount in Hb. lia. }
    destruct (Z.ltb_spec k 0) as [Hneg2 | Hpos2]; simpl; [lia | reflexivity].
Qed.

(* ---- write specialization (unconditional on n: write_n/write_block never
   consult a buffer-size parameter, only the requested Zlength bs) ---- *)

Definition embed_write_result (r : RelayProtocol.write_result) : IOW.write_result :=
  IOW.WriteResult (RelayProtocol.write_ret r)
    (if RelayProtocol.write_ret r <? 0 then 1 else 0)
    (RelayProtocol.write_bytes r)
    (embed (RelayProtocol.write_world r)).

Theorem write_n_specializes_write_block : forall w (bs : list byte),
  RelayProtocol.valid_writes (RelayProtocol.writes w) ->
  IOW.write_n bs (embed w) = embed_write_result (RelayProtocol.write_block w bs).
Proof.
  intros w bs Hv. pose proof (Zlength_nonneg bs).
  unfold IOW.write_n, RelayProtocol.write_block, embed_write_result, embed, after_write; simpl.
  set (g := RelayProtocol.action (Zlength bs) (RelayProtocol.writes w)) in *.
  destruct (Z.ltb_spec g 0) as [Hneg | Hpos]; simpl.
  - assert (Hg1 : g = -1) by (subst g; apply relay_write_action_neg1; auto).
    rewrite Hg1, app_nil_r. reflexivity.
  - set (k := Z.min g (Zlength bs)) in *.
    assert (Hk0 : 0 <= k) by (subst k; apply Z.min_glb; lia).
    destruct (Z.ltb_spec k 0) as [Hneg2 | Hpos2]; simpl; [lia | reflexivity].
Qed.

(* ---- validity transfers along embed (needed by MemAdequacy.v: the
   generalized read_dry_pre_n/write_dry_pre_n's `IOW.valid_world` precondition,
   given only relay's own `RelayProtocol.valid_world`) ---- *)

Lemma embed_valid : forall w, RelayProtocol.valid_world w -> IOW.valid_world (embed w).
Proof.
  intros w [Hr Hw].
  unfold RelayProtocol.valid_reads, RelayProtocol.valid_writes in Hr, Hw.
  assert (Hmax : Int.max_signed = 2147483647) by (vm_compute; reflexivity).
  split; unfold IOW.valid_reads, IOW.valid_writes; rewrite ?embed_reads, ?embed_writes, Forall_forall in *.
  - intros q Hq. destruct (Hr q Hq) as [-> | Hq']; [left; lia | right; lia].
  - intros q Hq. specialize (Hw q Hq).
    destruct (Z.eq_dec q (-1)) as [-> | Hne]; [left; lia | right; lia].
Qed.

(* ---- what these two theorems do and do not say ----
   They say: at the pure-function level, the generalized primitives are not
   an independent redefinition -- fixing n = 32 and mapping the world along
   `embed` reproduces relay's read32/write_block result-for-result, with the
   embed-image world evolving the same way (embed commutes with read_n/
   write_n at that instantiation, by these two theorems).
   They do NOT say the two DECLARE-level funspecs (../../relay/Specs.v's
   read_spec/write_spec vs ../IOSpecs.v's read_spec/write_spec) are equal or
   that one subsumes the other (funspec_sub): the generalized funspec's PRE
   additionally owns `errno_at (gv errno_id) e`, its PARAMS substitute
   `in_fd s`/`out_fd s` for relay's literal 0/1 (opaque under embed unless
   the caller already knows s = embed w for some w), it carries an extra
   GLOBALS clause, and its POST returns an existential errno witness e'
   relay's POST has no counterpart for. A relay call site owns none of
   those resources, so `funspec_sub (IOSpecs.read_spec ...) (Specs.read_spec)`
   is not obtainable from these theorems (and was not attempted); see
   README.md's "extras" list. *)
