(* Draft VST contracts for the actual generated relay. No body proof is claimed.
   The external world is concrete; later dry-call adequacy must connect it to
   actual Clight memory and external execution, not to an assumed abstract IO token. *)
Require Import VST.floyd.proofauto.
Require Import VST.veric.juicy_extspec.
Require Import relay Protocol Reach.
Import RelayProtocol RelayReach.
Local Open Scope Z_scope.

#[export] Instance CompSpecs : compspecs. make_compspecs prog. Defined.
Definition Vprog : varspecs. mk_varspecs prog. Defined.

Definition byte_array sh p bs : mpred :=
  data_at sh (tarray tuchar (Zlength bs)) (map Vubyte bs) p.

Definition buffer_prefix sh p bs : mpred :=
  (byte_array sh p bs *
  data_at_ sh (tarray tuchar (32 - Zlength bs))
    (offset_val (Zlength bs) p))%logic.

Definition read_spec :=
 DECLARE _read
 WITH s : world, p : val, sh : share
 PRE [ tint, tptr tvoid, tulong ]
   PROP (valid_world s; writable_share sh)
   PARAMS (Vint Int.zero; p; Vlong (Int64.repr 32))
   SEP (has_ext s; data_at_ sh (tarray tuchar 32) p)
 POST [ tlong ]
   PROP ()
   RETURN (Vlong (Int64.repr (read_ret (read32 s))))
   SEP (has_ext (read_world (read32 s));
        if read_ret (read32 s) <? 0
        then data_at_ sh (tarray tuchar 32) p
        else buffer_prefix sh p (read_bytes (read32 s))).

Definition write_spec :=
 DECLARE _write
 WITH s : world, p : val, bs : list byte, sh : share
 PRE [ tint, tptr tvoid, tulong ]
   PROP (valid_world s; readable_share sh; 0 < Zlength bs <= 32)
   PARAMS (Vint Int.one; p; Vlong (Int64.repr (Zlength bs)))
   SEP (has_ext s; byte_array sh p bs)
 POST [ tlong ]
   PROP ()
   RETURN (Vlong (Int64.repr (write_ret (write_block s bs))))
   SEP (has_ext (write_world (write_block s bs)); byte_array sh p bs).

Definition relay_spec :=
 DECLARE _relay
 WITH initial : world
 PRE []
   PROP (valid_world initial)
   PARAMS ()
   SEP (has_ext initial)
 POST [ tint ]
   EX status : Z, EX final : world, EX pending : list byte,
   PROP (outcome initial status final pending)
   RETURN (Vint (Int.repr status))
   SEP (has_ext final).

Definition Gprog : funspecs :=
  ltac:(with_library prog [read_spec; write_spec; relay_spec]).

(* This establishes only the construction of an oracle specification. A program
   semantic theorem additionally needs a deliberate exit predicate, external
   memory/frame correspondence and the applicable VST soundness hypotheses. *)
Definition Relay_void_Espec : OracleKind := ok_void_spec world.

Definition Relay_Espec (ext_link : string -> ident) : OracleKind :=
  add_funspecs Relay_void_Espec ext_link
    [(ext_link "read"%string, snd read_spec);
     (ext_link "write"%string, snd write_spec)].
