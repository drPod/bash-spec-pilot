(* A total, fuel-bounded executable evaluator for the abstract relay, proved
   sound and complete with respect to `outcome`, with fuel = the Progress.v
   measure of the initial configuration. Abstract environment only: a
   computable Coq reference for differential checks, not a C evaluator. *)
From Coq Require Import List ZArith Lia.
From compcert Require Import Integers.
Require Import VST.zlist.sublist.
Require Import Protocol Reach Conservation Progress Determinism ReachExamples.
Import ListNotations RelayProtocol RelayReach RelayConservation
  RelayProgress RelayDeterminism.
Local Open Scope Z_scope.

Module RelayEvaluator.

Lemma step_reaches initial p s p' s' :
  reaches initial p s -> step (p, s) = Some (p', s') -> reaches initial p' s'.
Proof.
  intros Hr Hstep.
  destruct (reaches_run initial p s Hr) as [n Hn].
  apply (run_reaches initial (S n)).
  rewrite run_snoc, Hn. exact Hstep.
Qed.

Lemma step_measure initial p s p' s' :
  reaches initial p s -> step (p, s) = Some (p', s') ->
  measure p' s' < measure p s.
Proof.
  intros Hr Hstep.
  pose proof (reaches_phase_bounds initial p s Hr) as Hb.
  destruct p as [| chunk off | status pending]; simpl in Hstep.
  - pose proof (read_ret_bounds s) as Hbounds.
    destruct (read_ret (read32 s) <? 0) eqn:Hneg.
    + inversion Hstep; subst. apply Z.ltb_lt in Hneg.
      unfold measure, pending_of, phase_rank.
      rewrite (read_nonpositive_preserves_input s ltac:(lia)). lia.
    + destruct (read_ret (read32 s) =? 0) eqn:Hzero.
      * inversion Hstep; subst. apply Z.eqb_eq in Hzero.
        unfold measure, pending_of, phase_rank.
        rewrite (read_nonpositive_preserves_input s ltac:(lia)). lia.
      * inversion Hstep; subst. apply Z.ltb_ge in Hneg. apply Z.eqb_neq in Hzero.
        assert (Hpos : 0 < read_ret (read32 s)) by lia.
        unfold measure, pending_of, phase_rank.
        rewrite suffix_zero, (read_data_unread s Hpos),
          (read_success_length s ltac:(lia)), Zlength_nil. lia.
  - simpl in Hb.
    destruct (Zlength chunk <=? off) eqn:Hend.
    + inversion Hstep; subst. apply Z.leb_le in Hend.
      assert (E : off = Zlength chunk) by lia. subst off.
      unfold measure, pending_of, phase_rank. rewrite suffix_end. lia.
    + apply Z.leb_gt in Hend.
      pose proof (write_ret_bounds s (suffix off chunk)) as Hw.
      rewrite (suffix_length off chunk ltac:(lia)) in Hw.
      destruct (write_effect s (suffix off chunk)) as [_ Hunread].
      destruct (write_ret (write_block s (suffix off chunk)) <=? 0) eqn:Hfail.
      * inversion Hstep; subst.
        unfold measure, pending_of, phase_rank. rewrite Hunread. lia.
      * inversion Hstep; subst. apply Z.leb_gt in Hfail.
        unfold measure, pending_of, phase_rank. rewrite Hunread.
        rewrite !suffix_length by lia. lia.
  - discriminate.
Qed.

Lemma step_not_halted p s :
  (forall status pending, p <> Halt status pending) ->
  exists c', step (p, s) = Some c'.
Proof.
  intro Hnh. destruct p as [| chunk off | status pending]; simpl.
  - destruct (read_ret (read32 s) <? 0); [eauto |].
    destruct (read_ret (read32 s) =? 0); eauto.
  - destruct (Zlength chunk <=? off); [eauto |].
    destruct (write_ret (write_block s (suffix off chunk)) <=? 0); eauto.
  - exfalso. apply (Hnh status pending). reflexivity.
Qed.

(* Within measure-many steps, run reaches a Halt. *)
Lemma run_halts_within n : forall initial p s,
  reaches initial p s -> measure p s <= Z.of_nat n ->
  exists k status pending final,
    (k <= n)%nat /\ run k (p, s) = Some (Halt status pending, final).
Proof.
  induction n as [| n IH]; intros initial p s Hr Hm.
  - destruct p as [| chunk off | status pending].
    + exfalso. unfold measure, phase_rank in Hm.
      pose proof (Zlength_nonneg (unread s)).
      pose proof (Zlength_nonneg (pending_of Ready)). change (Z.of_nat 0) with 0 in Hm. lia.
    + exfalso. unfold measure, phase_rank in Hm.
      pose proof (Zlength_nonneg (unread s)).
      pose proof (Zlength_nonneg (pending_of (Drain chunk off))). change (Z.of_nat 0) with 0 in Hm. lia.
    + exists O, status, pending, s. split; [lia | reflexivity].
  - destruct p as [| chunk off | status pending].
    + destruct (step_not_halted Ready s ltac:(discriminate)) as [[p' s'] Hstep].
      pose proof (step_reaches initial Ready s p' s' Hr Hstep) as Hr'.
      pose proof (step_measure initial Ready s p' s' Hr Hstep) as Hlt.
      destruct (IH initial p' s' Hr' ltac:(rewrite Nat2Z.inj_succ in Hm; lia))
        as [k [st [pend [f [Hk Hrun]]]]].
      exists (S k), st, pend, f. split; [lia |]. cbn [run]. rewrite Hstep. exact Hrun.
    + destruct (step_not_halted (Drain chunk off) s ltac:(discriminate)) as [[p' s'] Hstep].
      pose proof (step_reaches initial _ s p' s' Hr Hstep) as Hr'.
      pose proof (step_measure initial _ s p' s' Hr Hstep) as Hlt.
      destruct (IH initial p' s' Hr' ltac:(rewrite Nat2Z.inj_succ in Hm; lia))
        as [k [st [pend [f [Hk Hrun]]]]].
      exists (S k), st, pend, f. split; [lia |]. cbn [run]. rewrite Hstep. exact Hrun.
    + exists O, status, pending, s. split; [lia | reflexivity].
Qed.

(* The evaluator stops at Halt instead of stepping into None. *)
Fixpoint eval (n : nat) (c : config) : option config :=
  match c with
  | (Halt _ _, _) => Some c
  | _ =>
      match n with
      | O => None
      | S k => match step c with None => None | Some c' => eval k c' end
      end
  end.

Lemma eval_of_run k : forall n c status pending final,
  run k c = Some (Halt status pending, final) -> (k <= n)%nat ->
  eval n c = Some (Halt status pending, final).
Proof.
  induction k as [| k IH]; intros n c status pending final Hrun Hk.
  - simpl in Hrun. inversion Hrun; subst. destruct n; reflexivity.
  - destruct c as [p s]. destruct p as [| chunk off | st pend].
    + cbn [run] in Hrun. destruct n as [| n]; [lia |]. cbn [eval].
      destruct (step (Ready, s)) as [c' |]; [| discriminate].
      apply IH; [exact Hrun | lia].
    + cbn [run] in Hrun. destruct n as [| n]; [lia |]. cbn [eval].
      destruct (step (Drain chunk off, s)) as [c' |]; [| discriminate].
      apply IH; [exact Hrun | lia].
    + simpl in Hrun. discriminate.
Qed.

Lemma run_of_eval n : forall c c', eval n c = Some c' -> exists k, run k c = Some c'.
Proof.
  induction n as [| n IH]; intros [p s] c' Heval.
  - destruct p; simpl in Heval; try discriminate.
    inversion Heval; subst. exists O. reflexivity.
  - destruct p as [| chunk off | st pend]; cbn [eval] in Heval.
    + destruct (step (Ready, s)) as [c1 |] eqn:Hstep; [| discriminate].
      destruct (IH c1 c' Heval) as [k Hk]. exists (S k). cbn [run]. rewrite Hstep. exact Hk.
    + destruct (step (Drain chunk off, s)) as [c1 |] eqn:Hstep; [| discriminate].
      destruct (IH c1 c' Heval) as [k Hk]. exists (S k). cbn [run]. rewrite Hstep. exact Hk.
    + inversion Heval; subst. exists O. reflexivity.
Qed.

Definition fuel (initial : world) : nat := Z.to_nat (measure Ready initial).

(* Soundness: whatever the evaluator returns is a genuine outcome. *)
Theorem eval_sound n initial status pending final :
  eval n (Ready, initial) = Some (Halt status pending, final) ->
  outcome initial status final pending.
Proof.
  intro Heval. destruct (run_of_eval n _ _ Heval) as [k Hk].
  exact (run_reaches initial k _ _ Hk).
Qed.

(* Totality with the measure as fuel: the evaluator always halts, and its
   result is the (unique) outcome. *)
Theorem eval_total initial :
  exists status pending final,
    eval (fuel initial) (Ready, initial) = Some (Halt status pending, final) /\
    outcome initial status final pending.
Proof.
  destruct (run_halts_within (fuel initial) initial Ready initial (initial_ready initial))
    as [k [status [pending [final [Hk Hrun]]]]].
  { unfold fuel. rewrite Z2Nat.id by apply measure_nonneg. lia. }
  exists status, pending, final. split.
  - exact (eval_of_run k (fuel initial) _ _ _ _ Hrun Hk).
  - exact (run_reaches initial k _ _ Hrun).
Qed.

(* The two distinguishing witnesses, now computed rather than derived. *)
Example eval_a :
  match eval (fuel input_a) (Ready, input_a) with
  | Some (Halt status pending, final) =>
      status = 1 /\ pending = [] /\ delivered final = abc /\ unread final = []
  | _ => False
  end.
Proof. vm_compute. repeat split; reflexivity. Qed.

Example eval_b :
  match eval (fuel input_b) (Ready, input_b) with
  | Some (Halt status pending, final) =>
      status = 2 /\ pending = map Byte.repr [99; 100] /\
      delivered final = map Byte.repr [97; 98] /\
      unread final = map Byte.repr [101; 102]
  | _ => False
  end.
Proof. vm_compute. repeat split; reflexivity. Qed.

End RelayEvaluator.
