(* VST contracts for head_bytes / wc_lines. Reuses IOSpecs.v's byte_array,
   errno_at, safe_read_spec, error_spec, quotearg_spec UNCHANGED (Require
   Import only, not re-proved). New: quoteaf_spec (gnulib quote.h, 1-arg
   pure), xwrite_stdout_spec (stdio trust boundary, built on
   CaseWorld.XWrite), rawmemchr_spec (glibc trust boundary), head_bytes_spec,
   wc_lines_spec. *)
Require Import VST.floyd.proofauto.
Require Import IOWorld CaseWorld.
Require Specs IOSpecs.
Import IOW.
Local Open Scope Z_scope.

#[global] Existing Instance Specs.CompSpecs.
Notation CompSpecs := Specs.CompSpecs.
Notation byte_array := Specs.byte_array.
Notation errno_at := IOSpecs.errno_at.

Section Funspecs.
Variable errno_id : ident.

(* gnulib quote.h (declaration only, pure w.r.t. our footprint - same
   convention as IOSpecs.quotearg_spec). *)
Definition quoteaf_spec (id : ident) :=
 DECLARE id
 WITH arg : val
 PRE [ tptr tschar ] PROP () PARAMS (arg) SEP ()
 POST [ tptr tschar ] EX q : val, PROP (is_pointer_or_null q) RETURN (q) SEP ().

(* xwrite_stdout (head.c:176-189): buffered-stdio write, NOT body-verified
   (trust boundary, same status as write_error/error in utility-reuse).
   Contract = CaseWorld.XWrite: when the call returns, all n_bytes bytes were
   accepted by the stdout stream (stdout_put); n_bytes = 0 touches nothing.
   A failing fwrite makes the source exit and never return, so no returning
   execution violates this. The buffer is only read. *)
Definition xwrite_stdout_spec (id : ident) :=
 DECLARE id
 WITH gv : globals, s : world, p : val, bs : list byte, sh : share, e : Z
 PRE [ tptr tschar, tulong ]
   PROP (readable_share sh; 0 <= Zlength bs <= SYS_BUFSIZE_MAX)
   PARAMS (p; Vlong (Int64.repr (Zlength bs)))
   GLOBALS (gv)
   SEP (has_ext s; byte_array sh p bs; errno_at (gv errno_id) e)
 POST [ tvoid ]
   EX e' : Z, EX t : world,
   PROP (XWrite bs s e t e')
   RETURN ()
   SEP (has_ext t; byte_array sh p bs; errno_at (gv errno_id) e').

(* glibc rawmemchr(s, c) (GNU extension, string.h): returns a pointer to the
   first byte equal to (unsigned char) c at or after s; the caller guarantees
   such a byte exists (otherwise undefined). NOT body-verified: this is the
   libc trust boundary for wc_lines' long-line arm. Footprint: the caller's
   whole local `char buf[n]` (contents vl, some entries possibly Vundef beyond
   the initialized prefix), with s = &buf[i]. The sentinel-based caller
   discharges the existence obligation with the '\n' it stored at buf[r].
   Idealization recorded in RESULTS.md: real glibc may read past the found
   byte (vectorized), but stays inside the same object; the footprint here is
   that whole object. *)
Definition rawmemchr_spec (id : ident) :=
 DECLARE id
 WITH sh : share, buf : val, n : Z, vl : list val, i : Z, c : byte
 PRE [ tptr tvoid, tint ]
   PROP (readable_share sh; 0 <= i < n; Zlength vl = n;
         exists j, i <= j < n /\ Znth j vl = Vbyte c)
   PARAMS (field_address (tarray tschar n) [ArraySubsc i] buf; Vint (Int.repr (Byte.unsigned c)))
   SEP (data_at sh (tarray tschar n) vl buf)
 POST [ tptr tvoid ]
   EX j : Z,
   PROP (i <= j < n; Znth j vl = Vbyte c; forall k, i <= k < j -> Znth k vl <> Vbyte c)
   RETURN (field_address (tarray tschar n) [ArraySubsc j] buf)
   SEP (data_at sh (tarray tschar n) vl buf).

(* head_bytes (head.c:774-797, full function): the local buffer is head_bytes'
   own stack array (BUFSIZ = 8192), not a caller-supplied parameter, so it is
   not part of this interface; VST's start_function supplies its data_at_.
   filename is only used for the (uninterpreted) diagnostic text. N ranges
   over every uintmax_t value the CLI can pass (`head -c N`). *)
Definition head_bytes_spec (id : ident) :=
 DECLARE id
 WITH gv : globals, s : world, fname : val, N : Z, e : Z
 PRE [ tptr tschar, tint, tulong ]
   PROP (valid_world s; 0 <= N <= Int64.max_unsigned; 0 <= in_fd s <= Int.max_signed;
         is_pointer_or_null fname)
   PARAMS (fname; Vint (Int.repr (in_fd s)); Vlong (Int64.repr N))
   GLOBALS (gv)
   SEP (has_ext s; errno_at (gv errno_id) e)
 POST [ tbool ]
   EX t : world, EX e' : Z, EX b : bool,
   PROP (HeadOutcome 8192 N s e b t e')
   RETURN (Vint (Int.repr (if b then 1 else 0)))
   SEP (has_ext t; errno_at (gv errno_id) e').

(* wc_lines (wc.c:266-330), whole function, for callers that supply both
   out-pointers (the source's own defensive `if (!lines_out || !bytes_out)
   return false;` is covered separately by wc_lines_null_spec below). The
   out-cells receive Int64.repr of the mathematical totals = the source's
   modular uintmax_t arithmetic. On error the *_out cells are left untouched
   (source returns before the final stores), matching negative control #4. *)
Definition wc_lines_spec (id : ident) :=
 DECLARE id
 WITH gv : globals, s : world, fname : val, lp : val, bp : val, shl : share, shb : share, e : Z
 PRE [ tptr tschar, tint, tptr tulong, tptr tulong ]
   PROP (valid_world s; 0 <= in_fd s <= Int.max_signed; is_pointer_or_null fname;
         writable_share shl; writable_share shb; isptr lp; isptr bp)
   PARAMS (fname; Vint (Int.repr (in_fd s)); lp; bp)
   GLOBALS (gv)
   SEP (has_ext s; errno_at (gv errno_id) e; data_at_ shl tulong lp; data_at_ shb tulong bp)
 POST [ tbool ]
   EX t : world, EX e' : Z, EX b : bool, EX lines : Z, EX bytes : Z,
   PROP (WcLines 16384 s b t lines bytes)
   RETURN (Vint (Int.repr (if b then 1 else 0)))
   SEP (has_ext t; errno_at (gv errno_id) e';
        if b then data_at shl tulong (Vlong (Int64.repr lines)) lp
             else data_at_ shl tulong lp;
        if b then data_at shb tulong (Vlong (Int64.repr bytes)) bp
             else data_at_ shb tulong bp).

(* The defensive branch: a null out-pointer makes wc_lines return false
   without touching the world, errno or memory. (When lines_out is null the
   source short-circuits and never evaluates bytes_out; when lines_out is a
   valid pointer and bytes_out is null the pointer test needs lines_out's
   cell to be a valid location, hence the data_at_ in that case.) *)
Definition wc_lines_null_spec (id : ident) :=
 DECLARE id
 WITH gv : globals, s : world, fname : val, lp : val, bp : val, shl : share, e : Z
 PRE [ tptr tschar, tint, tptr tulong, tptr tulong ]
   PROP (is_pointer_or_null fname; is_pointer_or_null lp; is_pointer_or_null bp;
         lp = nullval \/ bp = nullval)
   PARAMS (fname; Vint (Int.repr (in_fd s)); lp; bp)
   GLOBALS (gv)
   SEP (has_ext s; errno_at (gv errno_id) e;
        if eq_dec lp nullval then emp else data_at_ shl tulong lp)
 POST [ tbool ]
   PROP ()
   RETURN (Vint (Int.repr 0))
   SEP (has_ext s; errno_at (gv errno_id) e;
        if eq_dec lp nullval then emp else data_at_ shl tulong lp).

End Funspecs.
