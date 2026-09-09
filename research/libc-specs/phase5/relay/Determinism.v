(* The abstract relay relation is deterministic: it coincides with iterating an
   executable step function, and any two Halt outcomes of the same initial world
   are equal. This makes `outcome` a computable reference for the scheduled
   environment (useful for differential checks) without identifying it with the
   Lean model. Abstract only; nothing here is about Clight execution. *)
From Coq Require Import List ZArith Lia.
From compcert Require Import Integers.
Require Import VST.zlist.sublist.
Require Import Protocol Reach Conservation.
Import ListNotations RelayProtocol RelayReach RelayConservation.
Local Open Scope Z_scope.

Module RelayDeterminism.

Definition config := (phase * world)%type.

Definition step (c : config) : option config :=
  match c with
  | (Ready, s) =>
      let r := read32 s in
      if read_ret r <? 0 then Some (Halt 1 [], read_world r)
      else if read_ret r =? 0 then Some (Halt 0 [], read_world r)
      else Some (Drain (read_bytes r) 0, read_world r)
  | (Drain chunk off, s) =>
      if Zlength chunk <=? off then Some (Ready, s)
      else
        let w := write_block s (suffix off chunk) in
        if write_ret w <=? 0 then Some (Halt 2 (suffix off chunk), write_world w)
        else Some (Drain chunk (off + write_ret w), write_world w)
  | (Halt _ _, _) => None
  end.

Fixpoint run (n : nat) (c : config) : option config :=
  match n with
  | O => Some c
  | S k => match step c with None => None | Some c' => run k c' end
  end.

Lemma run_snoc n c :
  run (S n) c = match run n c with Some c' => step c' | None => None end.
Proof.
  revert c. induction n as [| n IH]; intro c; simpl.
  - destruct (step c); reflexivity.
  - destruct (step c) as [c' |]; [apply IH | reflexivity].
Qed.

Lemma run_add n m c :
  run (n + m) c = match run n c with Some c' => run m c' | None => None end.
Proof.
  revert c. induction n as [| n IH]; intro c; simpl.
  - reflexivity.
  - destruct (step c); [apply IH | reflexivity].
Qed.

Lemma step_halt status pending s : step (Halt status pending, s) = None.
Proof. reflexivity. Qed.

(* Every derivation is a finite iteration of step from the initial Ready state. *)
Lemma reaches_run initial p s :
  reaches initial p s -> exists n, run n (Ready, initial) = Some (p, s).
Proof.
  intro Hr.
  induction Hr as
    [|s Hr [n IH] Hpos|s Hr [n IH] Herror|s Hr [n IH] Heof
     |s chunk off Hr [n IH] Hoff Hpos|s chunk off Hr [n IH] Hoff Herror
     |s chunk Hr [n IH]].
  - exists O. reflexivity.
  - exists (S n). rewrite run_snoc, IH. simpl.
    rewrite (proj2 (Z.ltb_ge (read_ret (read32 s)) 0)) by lia.
    rewrite (proj2 (Z.eqb_neq (read_ret (read32 s)) 0)) by lia.
    reflexivity.
  - exists (S n). rewrite run_snoc, IH. simpl.
    rewrite (proj2 (Z.ltb_lt (read_ret (read32 s)) 0)) by lia. reflexivity.
  - exists (S n). rewrite run_snoc, IH. simpl.
    rewrite (proj2 (Z.ltb_ge (read_ret (read32 s)) 0)) by lia.
    rewrite (proj2 (Z.eqb_eq (read_ret (read32 s)) 0) Heof).
    reflexivity.
  - exists (S n). rewrite run_snoc, IH. simpl.
    rewrite (proj2 (Z.leb_gt (Zlength chunk) off)) by lia.
    rewrite (proj2 (Z.leb_gt (write_ret (write_block s (suffix off chunk))) 0)) by lia.
    reflexivity.
  - exists (S n). rewrite run_snoc, IH. simpl.
    rewrite (proj2 (Z.leb_gt (Zlength chunk) off)) by lia.
    rewrite (proj2 (Z.leb_le (write_ret (write_block s (suffix off chunk))) 0) Herror).
    reflexivity.
  - exists (S n). rewrite run_snoc, IH. simpl.
    rewrite Z.leb_refl. reflexivity.
Qed.

(* Conversely, every iteration result is reachable. *)
Lemma run_reaches initial n p s :
  run n (Ready, initial) = Some (p, s) -> reaches initial p s.
Proof.
  revert p s. induction n as [| n IH]; intros p s Hrun.
  - simpl in Hrun. inversion Hrun; subst. apply initial_ready.
  - rewrite run_snoc in Hrun.
    destruct (run n (Ready, initial)) as [[p' s'] |] eqn:Hprev; [| discriminate].
    specialize (IH p' s' eq_refl).
    destruct p' as [| chunk off | status pending]; simpl in Hrun.
    + destruct (read_ret (read32 s') <? 0) eqn:Hneg.
      * inversion Hrun; subst. apply read_error; [exact IH |].
        apply Z.ltb_lt in Hneg. pose proof (read_ret_bounds s'). lia.
      * destruct (read_ret (read32 s') =? 0) eqn:Hzero.
        -- inversion Hrun; subst. apply read_eof; [exact IH | apply Z.eqb_eq; exact Hzero].
        -- inversion Hrun; subst. apply read_data; [exact IH |].
           apply Z.ltb_ge in Hneg. apply Z.eqb_neq in Hzero. lia.
    + pose proof (reaches_drain_bounds initial s' chunk off IH) as Hb.
      destruct (Zlength chunk <=? off) eqn:Hend.
      * inversion Hrun; subst. apply Z.leb_le in Hend.
        assert (E : off = Zlength chunk) by lia. subst off.
        apply drained with (chunk := chunk). exact IH.
      * apply Z.leb_gt in Hend.
        destruct (write_ret (write_block s' (suffix off chunk)) <=? 0) eqn:Hfail.
        -- inversion Hrun; subst. apply write_error; [exact IH | lia | apply Z.leb_le; exact Hfail].
        -- inversion Hrun; subst. apply write_data; [exact IH | lia | apply Z.leb_gt; exact Hfail].
    + discriminate.
Qed.

Theorem outcome_run initial status final pending :
  outcome initial status final pending <->
  exists n, run n (Ready, initial) = Some (Halt status pending, final).
Proof.
  split.
  - apply reaches_run.
  - intros [n Hn]. exact (run_reaches initial n _ _ Hn).
Qed.

Theorem outcome_unique initial a fa pa b fb pb :
  outcome initial a fa pa -> outcome initial b fb pb ->
  a = b /\ fa = fb /\ pa = pb.
Proof.
  intros Ha Hb.
  destruct (reaches_run _ _ _ Ha) as [n Hn].
  destruct (reaches_run _ _ _ Hb) as [m Hm].
  assert (Hchain : forall i j st pend f st' pend' f',
    (i < j)%nat ->
    run i (Ready, initial) = Some (Halt st pend, f) ->
    run j (Ready, initial) = Some (Halt st' pend', f') -> False).
  { intros i j st pend f st' pend' f' Hlt Hi Hj.
    replace j with (i + S (j - i - 1))%nat in Hj by lia.
    rewrite run_add, Hi in Hj. simpl in Hj. try rewrite step_halt in Hj. discriminate. }
  destruct (lt_eq_lt_dec n m) as [[Hlt | Heq] | Hgt].
  - exfalso. exact (Hchain n m _ _ _ _ _ _ Hlt Hn Hm).
  - subst m. rewrite Hn in Hm. inversion Hm; subst. auto.
  - exfalso. exact (Hchain m n _ _ _ _ _ _ Hgt Hm Hn).
Qed.

End RelayDeterminism.
