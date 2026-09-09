(* Abstract-contract nonvacuity, not C execution witnesses. Draft until checked. *)
From Coq Require Import List ZArith Lia.
From compcert Require Import Integers.
Require Import VST.zlist.sublist.
Require Import Protocol Reach.
Import ListNotations RelayProtocol RelayReach.
Local Open Scope Z_scope.

Definition empty_eof_input := World [] [] [] [] 0%nat 0%nat.
Definition empty_error_input := World [] [] [-1] [] 0%nat 0%nat.

Example empty_eof_outcome :
  outcome empty_eof_input 0 (read_world (read32 empty_eof_input)) [].
Proof.
  unfold outcome. apply read_eof; [constructor | reflexivity].
Qed.

Example empty_error_outcome :
  outcome empty_error_input 1 (read_world (read32 empty_error_input)) [].
Proof.
  unfold outcome. apply read_error; [constructor | reflexivity].
Qed.

Definition input_a := World abc [] [3; -1] [] 0%nat 0%nat.
Definition read_a := read_world (read32 input_a).
Definition written_a := write_world (write_block read_a abc).
Definition final_a := read_world (read32 written_a).

Lemma read_a_reachable : reaches input_a (Drain abc 0) read_a.
Proof.
  change (reaches input_a (Drain (read_bytes (read32 input_a)) 0)
    (read_world (read32 input_a))).
  apply (@RelayReach.read_data input_a input_a);
    [apply initial_ready | vm_compute; easy].
Qed.

Lemma written_a_reachable : reaches input_a (Drain abc (Zlength abc)) written_a.
Proof.
  change (reaches input_a
    (Drain abc (0 + write_ret (write_block read_a (suffix 0 abc))))
    (write_world (write_block read_a (suffix 0 abc)))).
  apply (@RelayReach.write_data input_a read_a abc 0);
    [apply read_a_reachable | vm_compute; easy | vm_compute; easy].
Qed.

Example read_error_outcome : outcome input_a 1 final_a [].
Proof.
  unfold outcome, final_a.
  apply read_error; [|vm_compute; reflexivity].
  apply drained with (chunk := abc). exact written_a_reachable.
Qed.

Example read_error_observations :
  delivered final_a = abc /\ unread final_a = [] /\
  read_calls final_a = 2%nat /\ write_calls final_a = 1%nat.
Proof. vm_compute; repeat split; reflexivity. Qed.

Definition abcd := map Byte.repr [97; 98; 99; 100].
Definition input_b := World abcdef [] [4] [2; 0] 0%nat 0%nat.
Definition read_b := read_world (read32 input_b).
Definition written_b := write_world (write_block read_b abcd).
Definition final_b := write_world (write_block written_b (suffix 2 abcd)).

Lemma read_b_reachable : reaches input_b (Drain abcd 0) read_b.
Proof.
  change (reaches input_b (Drain (read_bytes (read32 input_b)) 0)
    (read_world (read32 input_b))).
  apply (@RelayReach.read_data input_b input_b);
    [apply initial_ready | vm_compute; easy].
Qed.

Lemma written_b_reachable : reaches input_b (Drain abcd 2) written_b.
Proof.
  change (reaches input_b
    (Drain abcd (0 + write_ret (write_block read_b (suffix 0 abcd))))
    (write_world (write_block read_b (suffix 0 abcd)))).
  apply (@RelayReach.write_data input_b read_b abcd 0);
    [apply read_b_reachable | vm_compute; easy | vm_compute; easy].
Qed.

Example zero_write_outcome : outcome input_b 2 final_b (suffix 2 abcd).
Proof.
  unfold outcome, final_b.
  apply write_error;
    [apply written_b_reachable | vm_compute; easy | vm_compute; easy].
Qed.

Example zero_write_observations :
  delivered final_b = map Byte.repr [97; 98] /\
  suffix 2 abcd = map Byte.repr [99; 100] /\
  unread final_b = map Byte.repr [101; 102] /\
  read_calls final_b = 1%nat /\ write_calls final_b = 2%nat.
Proof. vm_compute; repeat split; reflexivity. Qed.
