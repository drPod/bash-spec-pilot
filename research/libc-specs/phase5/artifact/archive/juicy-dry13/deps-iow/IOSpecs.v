(* Generalized VST contracts for read/write (libc trust boundary), the gnulib
   wrappers safe_read / safe_write / full_write, the assumed coreutils
   externals, and simple_cat. Funspecs are parametric in the identifiers the
   particular translation unit assigns (each clightgen output numbers its own
   identifiers), so the *same* funspec definition is used both where a body is
   proved and where the function is called. Whole-program linking of the
   translation units (VSU) is not done here. *)
Require Import VST.floyd.proofauto.
Require Import VST.veric.juicy_extspec.
Require Import IOWorld.
Require Specs Body.
Import IOW.
Local Open Scope Z_scope.

(* None of the programs has composites; the relay's compspecs are reused as
   is (each body file checks cenv_cs against its program by reflexivity). *)
#[global] Existing Instance Specs.CompSpecs.
Notation CompSpecs := Specs.CompSpecs.

(* Literal reuse of the relay memory predicate. *)
Notation byte_array := Specs.byte_array.

Definition errno_at (p : val) (e : Z) : mpred := data_at Ews tint (Vint (Int.repr e)) p.

(* buffer_prefix generalized from the fixed 32 to a buffer of length n *)
Definition buffer_prefix_n (sh : share) (p : val) (n : Z) (bs : list byte) : mpred :=
  (byte_array sh p bs *
   data_at_ sh (tarray tuchar (n - Zlength bs)) (offset_val (Zlength bs) p))%logic.

Lemma buffer_prefix_relay sh p bs : Specs.buffer_prefix sh p bs = buffer_prefix_n sh p 32 bs.
Proof. reflexivity. Qed.

Lemma buffer_prefix_n_forget sh p n bs :
  field_compatible (tarray tuchar n) [] p -> 0 <= Zlength bs <= n ->
  buffer_prefix_n sh p n bs |-- data_at_ sh (tarray tuchar n) p.
Proof.
  intros Hfc Hlen. unfold buffer_prefix_n, Specs.byte_array, tarray in *.
  rewrite (split2_data_at__Tarray_tuchar sh n (Zlength bs) p Hlen
    (field_compatible_isptr _ _ _ Hfc) Hfc).
  rewrite (Body.tuchar_subarray_offset n (Zlength bs) p Hfc Hlen).
  apply sepcon_derives; [apply data_at_data_at_ | apply derives_refl].
Qed.

Lemma sem_add_ptr_long_tschar p off :
  isptr p -> 0 <= off <= Int64.max_unsigned ->
  force_val (sem_add_ptr_long tschar p (Vlong (Int64.repr off))) = offset_val off p.
Proof.
  intros Hp Hoff. destruct p; try contradiction. simpl.
  f_equal. f_equal. unfold Ptrofs.of_int64.
  rewrite Int64.unsigned_repr by rep_lia.
  rewrite Ptrofs.mul_commut, Ptrofs.mul_one. reflexivity.
Qed.

(* Normalize the comparison hypotheses VST leaves after forward_if on the
   generated 64/32-bit tests: turn Int64.eq/Int.eq into (dis)equalities of
   repr terms and compute the constant casts clightgen emits. *)
Ltac norm_cmp H :=
  try (apply Int64.same_if_eq in H);
  try (apply Int.same_if_eq in H);
  try (match type of H with Int64.eq ?a ?b = false =>
         let S := fresh "S" in pose proof (Int64.eq_spec a b) as S; rewrite H in S; clear H; rename S into H end);
  try (match type of H with Int.eq ?a ?b = false =>
         let S := fresh "S" in pose proof (Int.eq_spec a b) as S; rewrite H in S; clear H; rename S into H end);
  try change Int64.zero with (Int64.repr 0) in H;
  try change Int.zero with (Int.repr 0) in H;
  try change (Int.signed (Int.neg (Int.repr 1))) with (-1) in H;
  try change (Int.unsigned (Int.neg (Int.repr 1))) with 4294967295 in H;
  try change (Int.signed (Int.repr 0)) with 0 in H;
  try change (Int.unsigned (Int.repr 0)) with 0 in H;
  try change (Int64.signed (Int64.repr 0)) with 0 in H;
  try change (Int64.unsigned (Int64.repr 0)) with 0 in H;
  try (rewrite !Int64.unsigned_repr in H by rep_lia);
  try (rewrite !Int64.signed_repr in H by rep_lia).

Section Funspecs.
Variable errno_id : ident.

(* read(fd, p, n): fd must be the world's input descriptor; the buffer is a
   writable n-byte array; on success the first read_ret bytes are the bytes
   consumed from the stream; on failure -1 with errno set. *)
Definition read_spec (id : ident) :=
 DECLARE id
 WITH gv : globals, s : world, p : val, n : Z, e : Z, sh : share
 PRE [ tint, tptr tvoid, tulong ]
   PROP (valid_world s; writable_share sh; 0 <= n <= SYS_BUFSIZE_MAX;
         0 <= in_fd s <= Int.max_signed)
   PARAMS (Vint (Int.repr (in_fd s)); p; Vlong (Int64.repr n))
   GLOBALS (gv)
   SEP (has_ext s; data_at_ sh (tarray tuchar n) p; errno_at (gv errno_id) e)
 POST [ tlong ]
   EX e' : Z,
   PROP (read_ret (read_n n s) < 0 -> e' = read_errno (read_n n s))
   RETURN (Vlong (Int64.repr (read_ret (read_n n s))))
   SEP (has_ext (read_world (read_n n s)); errno_at (gv errno_id) e';
        if read_ret (read_n n s) <? 0
        then data_at_ sh (tarray tuchar n) p
        else buffer_prefix_n sh p n (read_bytes (read_n n s))).

Definition write_spec (id : ident) :=
 DECLARE id
 WITH gv : globals, s : world, p : val, bs : list byte, e : Z, sh : share
 PRE [ tint, tptr tvoid, tulong ]
   PROP (valid_world s; readable_share sh; 0 <= Zlength bs <= SYS_BUFSIZE_MAX;
         0 <= out_fd s <= Int.max_signed)
   PARAMS (Vint (Int.repr (out_fd s)); p; Vlong (Int64.repr (Zlength bs)))
   GLOBALS (gv)
   SEP (has_ext s; byte_array sh p bs; errno_at (gv errno_id) e)
 POST [ tlong ]
   EX e' : Z,
   PROP (write_ret (write_n bs s) < 0 -> e' = write_errno (write_n bs s))
   RETURN (Vlong (Int64.repr (write_ret (write_n bs s))))
   SEP (has_ext (write_world (write_n bs s)); errno_at (gv errno_id) e'; byte_array sh p bs).

Definition safe_read_spec (id : ident) :=
 DECLARE id
 WITH gv : globals, s : world, p : val, n : Z, e : Z, sh : share
 PRE [ tint, tptr tvoid, tulong ]
   PROP (valid_world s; writable_share sh; 0 <= n <= SYS_BUFSIZE_MAX;
         0 <= in_fd s <= Int.max_signed)
   PARAMS (Vint (Int.repr (in_fd s)); p; Vlong (Int64.repr n))
   GLOBALS (gv)
   SEP (has_ext s; data_at_ sh (tarray tuchar n) p; errno_at (gv errno_id) e)
 POST [ tulong ]
   EX r : Z, EX e' : Z, EX bs : list byte, EX t : world,
   PROP (SafeRead n s r e' bs t)
   RETURN (Vlong (Int64.repr r))
   SEP (has_ext t; errno_at (gv errno_id) e';
        if r <? 0 then data_at_ sh (tarray tuchar n) p else buffer_prefix_n sh p n bs).

Definition safe_write_spec (id : ident) :=
 DECLARE id
 WITH gv : globals, s : world, p : val, bs : list byte, e : Z, sh : share
 PRE [ tint, tptr tvoid, tulong ]
   PROP (valid_world s; readable_share sh; 0 <= Zlength bs <= SYS_BUFSIZE_MAX;
         0 <= out_fd s <= Int.max_signed)
   PARAMS (Vint (Int.repr (out_fd s)); p; Vlong (Int64.repr (Zlength bs)))
   GLOBALS (gv)
   SEP (has_ext s; byte_array sh p bs; errno_at (gv errno_id) e)
 POST [ tulong ]
   EX r : Z, EX e' : Z, EX out : list byte, EX t : world,
   PROP (SafeWrite bs s r e' out t)
   RETURN (Vlong (Int64.repr r))
   SEP (has_ext t; errno_at (gv errno_id) e'; byte_array sh p bs).

Definition full_write_spec (id : ident) :=
 DECLARE id
 WITH gv : globals, s : world, p : val, bs : list byte, e : Z, sh : share
 PRE [ tint, tptr tvoid, tulong ]
   PROP (valid_world s; readable_share sh; 0 <= Zlength bs <= SYS_BUFSIZE_MAX;
         0 <= out_fd s <= Int.max_signed)
   PARAMS (Vint (Int.repr (out_fd s)); p; Vlong (Int64.repr (Zlength bs)))
   GLOBALS (gv)
   SEP (has_ext s; byte_array sh p bs; errno_at (gv errno_id) e)
 POST [ tulong ]
   EX total : Z, EX e' : Z, EX t : world,
   PROP (FullWrite bs s e total e' t)
   RETURN (Vlong (Int64.repr total))
   SEP (has_ext t; errno_at (gv errno_id) e'; byte_array sh p bs).

(* Assumed coreutils/gnulib externals used by the fragment (not verified). *)

(* quotearg_n_style_colon: treated as pure with respect to our footprint. *)
Definition quotearg_spec (id : ident) :=
 DECLARE id
 WITH k : Z, style : Z, arg : val
 PRE [ tint, tint, tptr tschar ]
   PROP () PARAMS (Vint (Int.repr k); Vint (Int.repr style); arg) SEP ()
 POST [ tptr tschar ]
   EX q : val, PROP (is_pointer_or_null q) RETURN (q) SEP ().

(* error(0, e, fmt, arg): status 0 returns; the diagnostic is recorded as the
   errno value e in the world. Message text is not modeled. *)
Definition error_spec (id : ident) :=
 DECLARE id
 WITH s : world, e : Z, fmt : val, arg : val
 PRE [ tint, tint, tptr tschar, tptr tschar ]
   PROP () PARAMS (Vint (Int.repr 0); Vint (Int.repr e); fmt; arg) SEP (has_ext s)
 POST [ tvoid ]
   PROP () RETURN () SEP (has_ext (report e s)).

(* write_error(): coreutils system.h calls error(EXIT_FAILURE, ...), which
   exits; the contract asserts that it does not return. *)
Definition write_error_spec (id : ident) :=
 DECLARE id
 WITH s : world
 PRE [] PROP () PARAMS () SEP (has_ext s)
 POST [ tvoid ] PROP (False) RETURN () SEP ().

Definition simple_cat_spec (id input_desc_id infile_id : ident) :=
 DECLARE id
 WITH gv : globals, s : world, p : val, n : Z, e : Z, sh : share, name : val
 PRE [ tptr tschar, tlong ]
   PROP (valid_world s; writable_share sh; 0 < n <= SYS_BUFSIZE_MAX;
         0 <= in_fd s <= Int.max_signed; out_fd s = 1; is_pointer_or_null name)
   PARAMS (p; Vlong (Int64.repr n))
   GLOBALS (gv)
   SEP (has_ext s; data_at_ sh (tarray tuchar n) p; errno_at (gv errno_id) e;
        data_at Ews tint (Vint (Int.repr (in_fd s))) (gv input_desc_id);
        data_at Ews (tptr tschar) name (gv infile_id))
 POST [ tbool ]
   EX b : bool, EX t : world, EX e' : Z,
   PROP (CatOutcome n s e b t e')
   RETURN (Vint (Int.repr (if b then 1 else 0)))
   SEP (has_ext t; data_at_ sh (tarray tuchar n) p; errno_at (gv errno_id) e';
        data_at Ews tint (Vint (Int.repr (in_fd s))) (gv input_desc_id);
        data_at Ews (tptr tschar) name (gv infile_id)).

End Funspecs.
