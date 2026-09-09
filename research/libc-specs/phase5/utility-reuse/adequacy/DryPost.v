(* POST-side (store/load effect) CompCert dry adequacy, completing what
   MemAdequacy.v (PRE side only) deliberately left open. Generalizes
   ../../relay/adequacy/Dry.v's read_dry_post/write_dry_post the same way
   MemAdequacy.v generalized read_dry_pre/write_dry_pre: parametric buffer
   size n, plus an explicit errno memory effect relay's originals have no
   counterpart for at all. Does not `Require Import Dry` for the same
   measured reason as MemAdequacy.v (OOM via relay_main/Main.v -- see
   MemAdequacy.v's IMPORT NOTE and STATUS.md); the two relay POST
   definitions are restated verbatim below under local names, diffable
   against relay/adequacy/Dry.v lines 64-74/85-87. `mem_equiv` (VST.veric.
   mem_lessdef) was probe-tested standalone (utility-leaf9-probe-mem-1,
   peak RSS 644 MiB, no OOM) before use here: the earlier OOM was Main.v
   specifically, not VST's juicy/extspec/ghost machinery in general, which
   this file (and JuicyDry.v) now rely on directly. *)
Require Import VST.floyd.proofauto.
Require Import VST.veric.mem_lessdef.
Require Import relay Protocol Reach.
Require Import IOWorld IOSpecs.
Require Import Specialize.
Require Import MemAdequacy.
Import ListNotations.
Import IOW.
Local Open Scope Z_scope.

(* ---- verbatim restatement of relay/adequacy/Dry.v's dry post-conditions ---- *)

Definition relay_read_dry_post (m0 m : mem) (r : int64) (w : RelayProtocol.world * val) (z : RelayProtocol.world) :=
  let '(s, p) := w in
  r = Int64.repr (RelayProtocol.read_ret (RelayProtocol.read32 s)) /\ z = RelayProtocol.read_world (RelayProtocol.read32 s) /\
  match p with
  | Vptr b ofs =>
      if RelayProtocol.read_ret (RelayProtocol.read32 s) <? 0 then m0 = m
      else exists m', Mem.storebytes m0 b (Ptrofs.unsigned ofs)
                        (bytes_to_memvals (RelayProtocol.read_bytes (RelayProtocol.read32 s))) = Some m' /\
                      mem_equiv m m'
  | _ => False
  end.

Definition relay_write_dry_post (m0 m : mem) (r : int64) (w : RelayProtocol.world * val * list byte) (z : RelayProtocol.world) :=
  let '(s, p, bs) := w in
  m0 = m /\ r = Int64.repr (RelayProtocol.write_ret (RelayProtocol.write_block s bs)) /\ z = RelayProtocol.write_world (RelayProtocol.write_block s bs).

(* ---- errno post effect: the byte-level counterpart of errno_dry_pre.
   Modeled with mem_equiv the same way relay's own read_dry_post is, for
   uniformity with whatever a later juicy adequacy proof needs. ---- *)

Definition errno_dry_post_effect (m0 m : mem) (ep : val) (e' : Z) : Prop :=
  match ep with
  | Vptr eb eofs => exists m', Mem.storebytes m0 eb (Ptrofs.unsigned eofs) (errno_memval e') = Some m' /\ mem_equiv m m'
  | _ => False
  end.

(* ---- read: buffer effect (generalized to n) composed with an errno
   effect. e' is forced to the actual new errno on error, and otherwise an
   unconstrained existential -- exactly IOSpecs.read_spec's own POST shape
   (`EX e', PROP (ret<0 -> e'=read_errno...)`), not a weakening of it. ---- *)

Definition read_dry_post_n (n : Z) (m0 m : mem) (r : int64) (w : IOW.world * val * val) (z : IOW.world) :=
  let '(s, p, ep) := w in
  r = Int64.repr (read_ret (read_n n s)) /\ z = read_world (read_n n s) /\
  exists m1 e',
    (match p with
     | Vptr b ofs =>
         if read_ret (read_n n s) <? 0 then m0 = m1
         else exists m', Mem.storebytes m0 b (Ptrofs.unsigned ofs)
                           (bytes_to_memvals (read_bytes (read_n n s))) = Some m' /\ mem_equiv m1 m'
     | _ => False
     end) /\
    (read_ret (read_n n s) < 0 -> e' = read_errno (read_n n s)) /\
    errno_dry_post_effect m1 m ep e'.

(* ---- write: no buffer effect at all (write_spec's POST keeps byte_array
   unchanged, same as relay's write_dry_post's bare `m0 = m`), only the
   errno effect, chained directly off m0. ---- *)

Definition write_dry_post_n (m0 m : mem) (r : int64) (w : IOW.world * val * list byte * val) (z : IOW.world) :=
  let '(s, p, bs, ep) := w in
  r = Int64.repr (write_ret (write_n bs s)) /\ z = write_world (write_n bs s) /\
  exists e',
    (write_ret (write_n bs s) < 0 -> e' = write_errno (write_n bs s)) /\
    errno_dry_post_effect m0 m ep e'.

(* ---- specialization: n = 32, world along embed. Reuses
   Specialize.read_n_specializes_read32/write_n_specializes_write_block
   directly (rewriting IOW.read_n 32 (embed w) to embed_read_result
   (RelayProtocol.read32 w) turns every projection in read_dry_post_n's
   statement into the corresponding relay-level quantity by plain `simpl`,
   the same technique Specialize.v's own two theorems used) rather than
   re-deriving the action/schedule case split from scratch. ---- *)

Theorem read_dry_post_specializes : forall m0 m1 m r w p ep,
  RelayProtocol.valid_reads (RelayProtocol.reads w) ->
  relay_read_dry_post m0 m1 r (w, p) (RelayProtocol.read_world (RelayProtocol.read32 w)) ->
  errno_dry_post_effect m1 m ep (if RelayProtocol.read_ret (RelayProtocol.read32 w) <? 0 then 1 else 0) ->
  read_dry_post_n 32 m0 m r (embed w, p, ep) (embed (RelayProtocol.read_world (RelayProtocol.read32 w))).
Proof.
  intros m0 m1 m r w p ep Hv Hrelay Herrno.
  pose proof (Specialize.read_n_specializes_read32 w Hv) as Heq.
  destruct Hrelay as (Hr & _ & Hbuf).
  unfold read_dry_post_n. rewrite Heq. simpl.
  split; [exact Hr|]. split; [reflexivity|].
  exists m1, (if RelayProtocol.read_ret (RelayProtocol.read32 w) <? 0 then 1 else 0).
  split; [exact Hbuf|]. split; [intros _; reflexivity | exact Herrno].
Qed.

Theorem write_dry_post_specializes : forall m0 m r w bs p ep,
  RelayProtocol.valid_writes (RelayProtocol.writes w) ->
  relay_write_dry_post m0 m0 r (w, p, bs) (RelayProtocol.write_world (RelayProtocol.write_block w bs)) ->
  errno_dry_post_effect m0 m ep (if RelayProtocol.write_ret (RelayProtocol.write_block w bs) <? 0 then 1 else 0) ->
  write_dry_post_n m0 m r (embed w, p, bs, ep) (embed (RelayProtocol.write_world (RelayProtocol.write_block w bs))).
Proof.
  intros m0 m r w bs p ep Hv Hrelay Herrno.
  pose proof (Specialize.write_n_specializes_write_block w bs Hv) as Heq.
  destruct Hrelay as (_ & Hr & _).
  unfold write_dry_post_n. rewrite Heq. simpl.
  split; [exact Hr|]. split; [reflexivity|].
  exists (if RelayProtocol.write_ret (RelayProtocol.write_block w bs) <? 0 then 1 else 0).
  split; [intros _; reflexivity | exact Herrno].
Qed.
