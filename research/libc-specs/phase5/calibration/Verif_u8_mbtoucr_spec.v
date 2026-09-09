(* Frozen VST 2.15 specification obligation for gnulib u8_mbtoucr (CompCert 3.15 Clight
   AST in u8_mbtoucr.v, generated from the frozen source by clightgen; see RESULTS.md).
   STATEMENT ONLY. This file contains no body proof, no Admitted and no axioms; it
   fixes the theorem type that a proof-generation trial must prove without editing.
   Typechecking this file is not a verification result. *)
Require Import VST.floyd.proofauto.
Require Import u8_mbtoucr.
Require Import UnicodeSpec.

#[export] Instance CompSpecs : compspecs. make_compspecs prog. Defined.
Definition Vprog : varspecs. mk_varspecs prog. Defined.

(* Input bytes as C unsigned-char values. The Forall byte-range hypothesis in the
   precondition is what makes this representation injective (review condition 2). *)
Definition byte_vals (bs : list Z) : list val := map (fun b => Vint (Int.repr b)) bs.

(* Ownership: caller owns n initialized readable input bytes and one separate writable
   output cell. Input contents are returned unchanged; only the output cell is updated.
   n is the actual list length, n > 0 (frozen API precondition), and representable as
   size_t. Zero length is outside the API and outside this theorem. *)
Definition u8_mbtoucr_spec : ident * funspec :=
 DECLARE _u8_mbtoucr
 WITH shs : share, shp : share, puc : val, s : val, bs : list Z
 PRE [ tptr tuint, tptr tuchar, tulong ]
   PROP (readable_share shs; writable_share shp;
         bs <> nil;
         Zlength bs <= Int64.max_unsigned;
         Forall (fun b => 0 <= b <= 255) bs)
   PARAMS (puc; s; Vlong (Int64.repr (Zlength bs)))
   SEP (data_at shs (tarray tuchar (Zlength bs)) (byte_vals bs) s;
        data_at_ shp tuint puc)
 POST [ tint ]
   EX ret : Z, EX cp : Z,
   PROP (UnicodeSpec.UnicodeSpec.contract bs ret cp)
   RETURN (Vint (Int.repr ret))
   SEP (data_at shs (tarray tuchar (Zlength bs)) (byte_vals bs) s;
        data_at shp tuint (Vint (Int.repr cp)) puc).

Definition Gprog : funspecs := [u8_mbtoucr_spec].

(* The C-conformance obligation. Left as a Prop, deliberately unproved here. *)
Definition body_obligation : Prop :=
  semax_body Vprog Gprog f_u8_mbtoucr u8_mbtoucr_spec.
