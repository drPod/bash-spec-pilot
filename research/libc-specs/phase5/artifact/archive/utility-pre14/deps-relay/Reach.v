(* Abstract utility contract. Not a C interpreter or a generated-source theorem.
   Draft until the separate command receipt records successful Coq checking. *)
From Coq Require Import List ZArith.
From compcert Require Import Integers.
Require Import VST.zlist.sublist.
Require Import Protocol.
Import ListNotations RelayProtocol.
Local Open Scope Z_scope.

Module RelayReach.

Inductive phase :=
| Ready
| Drain (chunk : list byte) (off : Z)
| Halt (status : Z) (pending : list byte).

(* Keep the reason for termination, including read error after complete delivery.
   Conservation alone would admit a false-success implementation in that case. *)
Inductive reaches (initial : world) : phase -> world -> Prop :=
| initial_ready : reaches initial Ready initial
| read_data s :
    reaches initial Ready s ->
    0 < read_ret (read32 s) ->
    reaches initial (Drain (read_bytes (read32 s)) 0) (read_world (read32 s))
| read_error s :
    reaches initial Ready s ->
    read_ret (read32 s) = -1 ->
    reaches initial (Halt 1 []) (read_world (read32 s))
| read_eof s :
    reaches initial Ready s ->
    read_ret (read32 s) = 0 ->
    reaches initial (Halt 0 []) (read_world (read32 s))
| write_data s chunk off :
    reaches initial (Drain chunk off) s ->
    0 <= off < Zlength chunk ->
    0 < write_ret (write_block s (suffix off chunk)) ->
    reaches initial
      (Drain chunk (off + write_ret (write_block s (suffix off chunk))))
      (write_world (write_block s (suffix off chunk)))
| write_error s chunk off :
    reaches initial (Drain chunk off) s ->
    0 <= off < Zlength chunk ->
    write_ret (write_block s (suffix off chunk)) <= 0 ->
    reaches initial (Halt 2 (suffix off chunk))
      (write_world (write_block s (suffix off chunk)))
| drained s chunk :
    reaches initial (Drain chunk (Zlength chunk)) s ->
    reaches initial Ready s.

Definition outcome initial status final pending :=
  reaches initial (Halt status pending) final.

Lemma reaches_valid initial p s :
  valid_world initial -> reaches initial p s -> valid_world s.
Proof.
  intros Hv Hr. induction Hr;
    auto using read_valid_world, write_valid_world.
Qed.

Lemma outcome_status initial status final pending :
  outcome initial status final pending -> status = 0 \/ status = 1 \/ status = 2.
Proof.
  unfold outcome. intro H. inversion H; subst; auto.
Qed.

End RelayReach.
