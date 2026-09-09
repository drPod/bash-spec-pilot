(* Progress and termination of the abstract relay relation. This is a theorem
   about the scheduled mathematical environment (Protocol/Reach), i.e. about
   abstract read/write operations, not about Clight instructions. It assumes
   nothing about host POSIX; it does not upgrade the VST semax_body result
   (partial correctness) to total correctness of the C program. The bridge from
   this rank argument to C execution still requires (a) finite internal paths
   between external calls and (b) every specified external call returning. *)
From Coq Require Import List ZArith Lia.
From compcert Require Import Integers.
Require Import VST.zlist.sublist.
Require Import Protocol Reach Conservation.
Import ListNotations RelayProtocol RelayReach RelayConservation.
Local Open Scope Z_scope.

Module RelayProgress.

Definition phase_rank (p : phase) : Z :=
  match p with Halt _ _ => 0 | Ready => 1 | Drain _ _ => 2 end.

(* Pending never exceeds 32 bytes on reachable states, so one byte of unread
   input outweighs any pending growth; three units of phase rank never
   outweigh one byte moved. *)
Definition measure (p : phase) (s : world) : Z :=
  3 * (33 * Zlength (unread s) + Zlength (pending_of p)) + phase_rank p.

Definition halted (p : phase) : Prop :=
  exists status pending, p = Halt status pending.

Lemma read_data_unread s : 0 < read_ret (read32 s) ->
  Zlength (unread (read_world (read32 s))) =
  Zlength (unread s) - read_ret (read32 s).
Proof.
  intro Hpos.
  pose proof (read_conservation s) as Hcons.
  pose proof (read_success_length s ltac:(lia)) as Hlen.
  apply (f_equal (@Zlength byte)) in Hcons. rewrite Zlength_app in Hcons. lia.
Qed.

(* Every reachable non-halted configuration has a successor reachable
   configuration of strictly smaller measure. *)
Lemma reaches_progress initial p s :
  reaches initial p s ->
  halted p \/
  exists p' s', reaches initial p' s' /\ measure p' s' < measure p s.
Proof.
  intro Hr.
  pose proof (reaches_phase_bounds initial p s Hr) as Hb.
  destruct p as [| chunk off | status pending].
  - (* Ready *)
    right.
    pose proof (read_ret_bounds s) as Hbounds.
    destruct (Z.lt_trichotomy (read_ret (read32 s)) 0) as [Hneg | [Hzero | Hpos]].
    + exists (Halt 1 []), (read_world (read32 s)).
      split; [apply read_error; [exact Hr | lia] |].
      unfold measure, pending_of, phase_rank.
      rewrite (read_nonpositive_preserves_input s ltac:(lia)). lia.
    + exists (Halt 0 []), (read_world (read32 s)).
      split; [apply read_eof; [exact Hr | exact Hzero] |].
      unfold measure, pending_of, phase_rank.
      rewrite (read_nonpositive_preserves_input s ltac:(lia)). lia.
    + exists (Drain (read_bytes (read32 s)) 0), (read_world (read32 s)).
      split; [apply read_data; [exact Hr | exact Hpos] |].
      unfold measure, pending_of, phase_rank.
      rewrite suffix_zero, (read_data_unread s Hpos),
        (read_success_length s ltac:(lia)), Zlength_nil.
      lia.
  - (* Drain *)
    right. simpl in Hb.
    destruct (Z.eq_dec off (Zlength chunk)) as [Hend | Hmid].
    + subst off.
      exists Ready, s.
      split; [apply drained with (chunk := chunk); exact Hr |].
      unfold measure, pending_of, phase_rank. rewrite suffix_end. lia.
    + assert (Hoff : 0 <= off < Zlength chunk) by lia.
      pose proof (write_ret_bounds s (suffix off chunk)) as Hw.
      rewrite (suffix_length off chunk ltac:(lia)) in Hw.
      destruct (write_effect s (suffix off chunk)) as [_ Hunread].
      destruct (Z_le_gt_dec (write_ret (write_block s (suffix off chunk))) 0)
        as [Hfail | Hok].
      * exists (Halt 2 (suffix off chunk)),
          (write_world (write_block s (suffix off chunk))).
        split; [apply write_error; [exact Hr | exact Hoff | exact Hfail] |].
        unfold measure, pending_of, phase_rank. rewrite Hunread. lia.
      * exists (Drain chunk (off + write_ret (write_block s (suffix off chunk)))),
          (write_world (write_block s (suffix off chunk))).
        split; [apply write_data; [exact Hr | exact Hoff | lia] |].
        unfold measure, pending_of, phase_rank. rewrite Hunread.
        rewrite !suffix_length by lia. lia.
  - left. exists status, pending. reflexivity.
Qed.

Lemma measure_nonneg p s : 0 <= measure p s.
Proof.
  unfold measure. pose proof (Zlength_nonneg (unread s)).
  pose proof (Zlength_nonneg (pending_of p)).
  destruct p; unfold phase_rank; lia.
Qed.

Lemma reaches_halts_within n : forall initial p s,
  reaches initial p s -> measure p s <= Z.of_nat n ->
  exists status final pending, outcome initial status final pending.
Proof.
  induction n as [| n IH]; intros initial p s Hr Hm.
  - destruct (reaches_progress initial p s Hr) as [[status [pending Hp]] | [p' [s' [_ Hlt]]]].
    + subst p. exists status, s, pending. exact Hr.
    + pose proof (measure_nonneg p' s'). simpl in Hm. lia.
  - destruct (reaches_progress initial p s Hr) as [[status [pending Hp]] | [p' [s' [Hr' Hlt]]]].
    + subst p. exists status, s, pending. exact Hr.
    + apply (IH initial p' s' Hr'). rewrite Nat2Z.inj_succ in Hm. lia.
Qed.

(* Termination of the abstract relay: every world (finite unread input, any
   schedules, including error/zero entries) reaches some Halt. No validity
   hypothesis is needed because the primitives are total functions. *)
Theorem outcome_exists initial :
  exists status final pending, outcome initial status final pending.
Proof.
  apply (reaches_halts_within (Z.to_nat (measure Ready initial)) initial Ready initial).
  - apply initial_ready.
  - rewrite Z2Nat.id by apply measure_nonneg. lia.
Qed.

(* Bound on the number of abstract steps: any chain of successive reachable
   configurations has length at most the initial measure. Stated via the
   measure itself; the measure of the initial Ready configuration is
   99 * |unread| + 1. *)
Lemma initial_measure initial :
  measure Ready initial = 99 * Zlength (unread initial) + 1.
Proof. unfold measure, pending_of, phase_rank. rewrite Zlength_nil. lia. Qed.

End RelayProgress.
