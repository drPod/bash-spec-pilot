(* tint errno data_at-to-dry bridge: the connecting lemma this directory's
   NEXT.md item 2 asks for, needed before the `juicy_dry_ext_spec`
   PRE-preservation conjunct can discharge its errno `SEP` obligation. This
   file checks the *entry point* (unfolding `errno_at` down to
   `address_mapsto`, eliminating `mapsto`'s `Vundef` disjunct -- the same
   first step `dry_mem_lemmas.data_at_bytes` takes for the `tarray tuchar`
   case) under one explicit, standard hypothesis (`field_compatible tint []
   (Vptr b ofs)`, always available where this would actually be invoked:
   it's the same fact `IOSpecs.read_spec`/`write_spec`'s own `data_at_`
   preconditions already carry for their own pointers, extractable from
   `errno_at`'s own `data_at` the same way there), and documents precisely,
   not vaguely, what is still needed and why it is a larger undertaking
   than fits this bounded session -- worked out so the next attempt does
   not redo this analysis from scratch. *)
Require Import VST.floyd.proofauto.
Require Import VST.veric.res_predicates.
Require Import dry_mem_lemmas.
Require Import IOSpecs.
Import ListNotations.
Local Open Scope Z_scope.

Theorem errno_at_address_mapsto : forall b ofs e,
  field_compatible tint [] (Vptr b ofs) ->
  IOSpecs.errno_at (Vptr b ofs) e =
  (!! tc_val tint (Vint (Int.repr e)) &&
   address_mapsto Mint32 (Vint (Int.repr e)) Ews (b, Ptrofs.unsigned ofs))%logic.
Proof.
  intros b ofs e Hfc. unfold IOSpecs.errno_at.
  unfold data_at, field_at, at_offset; simpl.
  rewrite data_at_rec_eq; simpl.
  unfold unfold_reptype; simpl.
  rewrite ptrofs_add_repr_0_r.
  unfold mapsto; simpl.
  destruct (readable_share_dec Ews); [| exfalso; apply n, writable_readable, writable_Ews].
  apply pred_ext.
  - apply andp_left2. apply orp_left.
    + apply derives_refl.
    + apply andp_left1. normalize. congruence.
  - apply andp_right; [apply prop_right; auto |].
    apply orp_right1. apply derives_refl.
Qed.

(* ---- what remains (not attempted this session; see this directory's
   NEXT.md for the ordered plan) ----
   `address_mapsto Mint32 (Vint (Int.repr e)) Ews (b, ofs)` unfolds
   (res_predicates.v) to `EX bl : list memval, !!(length bl = 4 /\
   decode_val Mint32 bl = Vint (Int.repr e) /\ ...) && <rmap fact that bl's
   4 bytes sit at consecutive resource_at locations>`. Turning that rmap
   fact into `Mem.loadbytes (m_dry jm) b ofs 4 = Some bl` needs the same
   per-location `resource_at`/`JMcontents`/`contents_at` extraction
   `dry_mem_lemmas.data_at_bytes` does for `tarray tuchar` (that lemma's
   last ~40 lines, from `Transparent Mem.loadbytes` on), done 4 times (one
   per offset) rather than by induction over a caller-supplied array
   length -- `data_at_bytes`'s induction is driven by the *array*'s
   length, tuchar arrays being one `mapsto` per element; `tint`'s 4 bytes
   are ONE `mapsto` whose own `address_mapsto` already spans all 4
   addresses via a single `allp (jam ...)`, a different (not harder in
   principle, but not a direct instantiation of the existing lemma)
   resource pattern.
   Separately, `bl = errno_memval e` (the *exact* byte sequence
   `MemAdequacy.v`/`DryPost.v`'s `errno_dry_pre`/`errno_dry_post_effect`
   require) does not follow from `decode_val Mint32 bl = Vint (Int.repr e)`
   by decode_val's definition alone in general (decode/encode round-trip
   lemmas -- CompCert's `Memdata.decode_encode_int_4`,
   `decode_encode_val_general` -- go encode-then-decode, not the needed
   decode-implies-was-that-encoding direction); it additionally needs `bl`
   to be all-`Byte` (no `Undef`/pointer fragments), which
   `address_mapsto`'s own resource shape (`yesat NoneP (VAL ...)`, a
   *defined* value resource, not `Undef`) should supply, plus an actual
   injectivity argument for `decode_int`/`encode_int` on 4-byte lists
   (`Byte`-level; not found as a single ready-made CompCert lemma during
   this session's search of `Memdata.v` -- `decode_encode_int_4` is the
   nearest existing fact and is the right induction target, not a direct
   citation). Estimated scope: comparable to `dry_mem_lemmas.data_at_bytes`
   itself (a from-scratch ~70-100 line lemma), not a short follow-up. *)
