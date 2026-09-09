(* Concrete CompCert memory/load/store adequacy for the generalized
   utility-reuse read/write leaves (../IOSpecs.v), parametric in the buffer
   size n and carrying the extra errno memory cell IOSpecs.errno_at adds.
   Modeled on ../../relay/adequacy/Dry.v's read_dry_pre/write_dry_pre (dry =
   CompCert-memory, not the VST juicy model); this file's *_n definitions
   specialize to at n = 32 via Specialize.embed (proved below).

   IMPORT NOTE: this file does NOT `Require Import Dry` (relay's
   adequacy/Dry.v) or `dry_mem_lemmas`, even though it restates two of
   Dry.v's definitions almost verbatim below (`relay_read_dry_pre`/
   `relay_write_dry_pre`, byte-for-byte diffable against
   ../../relay/adequacy/Dry.v lines 52-59/77-83, modulo dropping the unused
   `sh : share` witness component -- relay's own `read_dry_pre`/
   `write_dry_pre` never reads `sh` in their body either, so this drops a
   dead parameter, not behavior). Reason: `Require Import Dry` transitively
   pulls `relay_main Protocol Reach Main` (relay's full VST body/progress/
   audit development) and was measured to OOM coqc against this container's
   3 GiB cap (`utility-leaf8-memadeq-1`, exit_status 134, peak RSS ~2.87
   GiB, fatal error exactly at that Require -- receipt in STATUS.md). This
   is a real, checked resource constraint, not a style choice; the two
   restated definitions are not a re-proof of anything (they are plain
   `Prop`-valued `Definition`s, not theorems) and the restatement is
   mechanically checkable against the original file with `diff`.

   SCOPE (read before citing): this file gives the dry PRE-side adequacy --
   generalized read_dry_pre_n/write_dry_pre_n definitions carrying an
   explicit errno_dry_pre conjunct, and one directed specialization lemma
   per primitive showing the n=32/embed instance is implied by relay's own
   (restated) read/write_dry_pre plus a fresh errno witness. It does NOT
   attempt: (1) the POST-side store effect (read_dry_post_n/
   write_dry_post_n and their specialization), (2) connecting errno_at's
   `data_at Ews tint` juicy fact to errno_dry_pre (the tint-level analogue
   of dry_mem_lemmas.data_at_bytes, itself stated for tarray tuchar only),
   (3) the full `juicy_dry_ext_spec` adequacy record analogous to Dry.v's
   `juicy_dry_specs` (the ~300-line ghost-state proof) for IOSpecs' actual
   read_spec/write_spec. All three are the explicit remaining gap; see
   STATUS.md/REPORT.md, not this file's comments, for the authoritative
   list. *)
Require Import VST.floyd.proofauto.
Require Import relay Protocol Reach.
Require Import IOWorld IOSpecs.
Require Import Specialize.
Import ListNotations.
Import IOW.
Local Open Scope Z_scope.

(* ---- verbatim restatement of relay/adequacy/Dry.v's dry pre-conditions
   (see the IMPORT NOTE above for why this is restated, not imported) ---- *)

Definition bytes_to_memvals (li : list byte) := concat (map (fun i => encode_val Mint8unsigned (Vubyte i)) li).

Definition relay_read_dry_pre (m : mem) (w : RelayProtocol.world * val) (z : RelayProtocol.world) :=
  let '(s, p) := w in
  s = z /\ RelayProtocol.valid_world s /\
  match p with
  | Vptr b ofs => Mem.range_perm m b (Ptrofs.unsigned ofs) (Ptrofs.unsigned ofs + 32) Memtype.Cur Memtype.Writable
  | _ => False
  end.

Definition relay_write_dry_pre (m : mem) (w : RelayProtocol.world * val * list byte) (z : RelayProtocol.world) :=
  let '(s, p, bs) := w in
  s = z /\ RelayProtocol.valid_world s /\ 0 < Zlength bs <= 32 /\
  match p with
  | Vptr b ofs => Mem.loadbytes m b (Ptrofs.unsigned ofs) (Zlength bs) = Some (bytes_to_memvals bs)
  | _ => False
  end.

(* ---- errno cell: the one piece of memory the generalized spec owns that
   relay's Dry.v has no counterpart for at all (relay's read_spec/write_spec
   carry no errno_at conjunct: REUSE.md, "Generalizations relative to the
   relay contracts"). errno_at is `data_at Ews tint (Vint (Int.repr e)) p`
   (IOSpecs.v); tint has size 4, so its dry counterpart is a 4-byte
   Mem.loadbytes fact via Mint32 encoding. ---- *)

Definition errno_memval (e : Z) : list memval := encode_val Mint32 (Vint (Int.repr e)).

Definition errno_dry_pre (m : mem) (ep : val) (e : Z) : Prop :=
  match ep with
  | Vptr b ofs => Mem.loadbytes m b (Ptrofs.unsigned ofs) 4 = Some (errno_memval e)
  | _ => False
  end.

(* ---- read: buffer side, generalized to n ---- *)

Definition read_dry_pre_n (n : Z) (m : mem) (w : IOW.world * val * val) (z : IOW.world) :=
  let '(s, p, ep) := w in
  s = z /\ IOW.valid_world s /\ 0 <= n <= SYS_BUFSIZE_MAX /\
  match p with
  | Vptr b ofs => Mem.range_perm m b (Ptrofs.unsigned ofs) (Ptrofs.unsigned ofs + n) Memtype.Cur Memtype.Writable
  | _ => False
  end /\
  exists e, errno_dry_pre m ep e.

(* ---- write: buffer side, generalized (write_n/write_block never consult a
   buffer-size bound, only the requested Zlength bs -- Specialize.v's
   write_n_specializes_write_block is likewise unconditional on n) ---- *)

Definition write_dry_pre_n (m : mem) (w : IOW.world * val * list byte * val) (z : IOW.world) :=
  let '(s, p, bs, ep) := w in
  s = z /\ IOW.valid_world s /\ 0 <= Zlength bs <= SYS_BUFSIZE_MAX /\
  match p with
  | Vptr b ofs => Mem.loadbytes m b (Ptrofs.unsigned ofs) (Zlength bs) = Some (bytes_to_memvals bs)
  | _ => False
  end /\
  exists e, errno_dry_pre m ep e.

(* ---- specialization: n = 32, world along embed, given a fresh errno
   witness, the generalized dry PRE follows from relay's own dry PRE plus
   that witness -- i.e. instantiating the generalized fd/count/errno
   contract at the relay's own fd/count reproduces relay's memory
   precondition, with the errno conjunct as the one genuinely additional
   obligation (it is not absorbed into anything relay already required:
   relay's read_dry_pre/write_dry_pre have no field position for it). This
   is the CompCert-memory-layer analogue of Specialize.v's
   read_n_specializes_read32/write_n_specializes_write_block. ---- *)

Theorem read_dry_pre_specializes : forall m w p ep e,
  relay_read_dry_pre m (w, p) w ->
  errno_dry_pre m ep e ->
  read_dry_pre_n 32 m (embed w, p, ep) (embed w).
Proof.
  intros m w p ep e Hpre Herrno.
  unfold relay_read_dry_pre in Hpre.
  destruct Hpre as (_ & Hvalid & Hperm).
  destruct (Specialize.embed_valid w Hvalid) as [Hevr Hevw].
  unfold read_dry_pre_n.
  repeat split.
  - exact Hevr.
  - exact Hevw.
  - lia.
  - lia.
  - destruct p; try contradiction. exact Hperm.
  - exists e; exact Herrno.
Qed.

Theorem write_dry_pre_specializes : forall m w p bs ep e,
  relay_write_dry_pre m (w, p, bs) w ->
  errno_dry_pre m ep e ->
  write_dry_pre_n m (embed w, p, bs, ep) (embed w).
Proof.
  intros m w p bs ep e Hpre Herrno.
  unfold relay_write_dry_pre in Hpre.
  destruct Hpre as (_ & Hvalid & Hlen & Hload).
  destruct (Specialize.embed_valid w Hvalid) as [Hevr Hevw].
  unfold write_dry_pre_n.
  repeat split.
  - exact Hevr.
  - exact Hevw.
  - lia.
  - lia.
  - destruct p; try contradiction. exact Hload.
  - exists e; exact Herrno.
Qed.
