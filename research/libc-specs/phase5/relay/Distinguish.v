(* Falsifiability of the accepted contract on the two fixed witnesses: the
   relation `outcome` admits exactly one status for each, so an implementation
   satisfying relay_spec cannot report success after the terminal read error
   (input_a) or after the zero-length write (input_b). Since Body.v/Main.v prove
   the generated relay meets relay_spec, these are the observations its
   postcondition is forced to preserve (design §9). Abstract statements. *)
From Coq Require Import List ZArith Lia.
From compcert Require Import Integers.
Require Import Protocol Reach ReachExamples Determinism.
Import ListNotations RelayProtocol RelayReach RelayDeterminism.
Local Open Scope Z_scope.

Module RelayDistinguish.

Theorem no_false_success_a final pending : ~ outcome input_a 0 final pending.
Proof.
  intro H.
  destruct (outcome_unique input_a 0 final pending 1 final_a [] H read_error_outcome)
    as [Hs _]. discriminate.
Qed.

Theorem no_write_error_a final pending : ~ outcome input_a 2 final pending.
Proof.
  intro H.
  destruct (outcome_unique input_a 2 final pending 1 final_a [] H read_error_outcome)
    as [Hs _]. discriminate.
Qed.

Theorem no_false_success_b final pending : ~ outcome input_b 0 final pending.
Proof.
  intro H.
  destruct (outcome_unique input_b 0 final pending 2 final_b (suffix 2 abcd) H
    zero_write_outcome) as [Hs _]. discriminate.
Qed.

Theorem no_read_error_b final pending : ~ outcome input_b 1 final pending.
Proof.
  intro H.
  destruct (outcome_unique input_b 1 final pending 2 final_b (suffix 2 abcd) H
    zero_write_outcome) as [Hs _]. discriminate.
Qed.

(* The status-2 outcome on input_b fixes the pending bytes and the final world:
   a mutant that silently drops the pending bytes (reporting pending = [])
   or retries forever (no outcome at all) is excluded or unconstrained
   respectively — the latter is why Progress.v is a separate obligation. *)
Theorem pending_forced_b final pending :
  outcome input_b 2 final pending -> pending = map Byte.repr [99; 100] /\ final = final_b.
Proof.
  intro H.
  destruct (outcome_unique input_b 2 final pending 2 final_b (suffix 2 abcd) H
    zero_write_outcome) as [_ [Hf Hp]].
  split; [| exact Hf]. rewrite Hp. vm_compute. reflexivity.
Qed.

End RelayDistinguish.
