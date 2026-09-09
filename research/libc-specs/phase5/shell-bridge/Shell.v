(* Shell composition/query layer over the ACTUAL relay contract.

   The command grammar and the execution relation are a port of the phase3 Lean
   file research/libc-specs/phase3/ShellObservation.lean (Command/Exec/
   PrimitiveRefines/command_refines/query_transfer), with the exit status in Z
   because the VST postcondition of relay_spec (Specs.v) states
   outcome initial status final pending with status : Z.

   The relay primitive below is NOT a new relay semantics. It is exactly the
   PROP of the relay_spec POST: RelayReach.outcome initial status final pending
   (Reach.v), i.e. a derivation of reaches initial (Halt status pending) final
   over the scheduled primitives read32/write_block (Protocol.v). The "pending"
   bytes existentially hidden by the funspec are retained here in a shell-level
   ledger (lost) so that bytes discarded at process exit stay visible.

   Nothing here is Bash process/pipe/fd semantics, an OS model, a Clight
   execution theorem or a termination theorem. The Mark primitive models a
   successful one-byte stdout write by a separate command (as phase3's mark);
   its failures are outside this model. *)
From Coq Require Import List ZArith Lia.
From compcert Require Import Integers.
Require Import VST.zlist.sublist.
Require Import Protocol Reach ReachExamples Conservation.
Import ListNotations RelayProtocol RelayReach RelayConservation.
Local Open Scope Z_scope.

Module ShellComposition.

(* ---- Grammar (phase3 ShellObservation.Command) ---- *)

Inductive command (Atom : Type) : Type :=
| call (name : Atom)
| seq (left right : command Atom)
| and_then (left right : command Atom)
| or_else (left right : command Atom).
Arguments call {Atom}.
Arguments seq {Atom}.
Arguments and_then {Atom}.
Arguments or_else {Atom}.

Definition primitive (Atom State : Type) := Atom -> State -> Z -> State -> Prop.

(* ---- Execution relation (phase3 ShellObservation.Exec, six rules) ---- *)

Section Exec.
Context {Atom State : Type} (prim : primitive Atom State).

Inductive exec : command Atom -> State -> Z -> State -> Prop :=
| exec_call a s rc t :
    prim a s rc t -> exec (call a) s rc t
| exec_seq x y s rc1 t rc2 u :
    exec x s rc1 t -> exec y t rc2 u -> exec (seq x y) s rc2 u
| exec_and_zero x y s t rc u :
    exec x s 0 t -> exec y t rc u -> exec (and_then x y) s rc u
| exec_and_nonzero x y s rc t :
    exec x s rc t -> rc <> 0 -> exec (and_then x y) s rc t
| exec_or_zero x y s t :
    exec x s 0 t -> exec (or_else x y) s 0 t
| exec_or_nonzero x y s rc1 t rc2 u :
    exec x s rc1 t -> rc1 <> 0 -> exec y t rc2 u -> exec (or_else x y) s rc2 u.

End Exec.

(* ---- Generic refinement and query transfer (phase3 statements) ---- *)

Definition primitive_refines {Atom C A : Type}
  (concrete : primitive Atom C) (abstract : primitive Atom A)
  (R : C -> A -> Prop) : Prop :=
  forall name c a, R c a -> forall rc c', concrete name c rc c' ->
    exists a', abstract name a rc a' /\ R c' a'.

Theorem command_refines {Atom C A : Type}
  (concrete : primitive Atom C) (abstract : primitive Atom A)
  (R : C -> A -> Prop) (hp : primitive_refines concrete abstract R)
  (cmd : command Atom) (c c' : C) (rc : Z)
  (he : exec concrete cmd c rc c') :
  forall a, R c a -> exists a', exec abstract cmd a rc a' /\ R c' a'.
Proof.
  induction he as
    [a s rc t Hp
    |x y s rc1 t rc2 u He1 IH1 He2 IH2
    |x y s t rc u He1 IH1 He2 IH2
    |x y s rc t He IH Hn
    |x y s t He IH
    |x y s rc1 t rc2 u He1 IH1 Hn He2 IH2]; intros a0 Hr.
  - destruct (hp _ _ _ Hr _ _ Hp) as [a' [Ha Hr']].
    exists a'; split; [apply exec_call; exact Ha | exact Hr'].
  - destruct (IH1 a0 Hr) as [t' [Ht Hrt]].
    destruct (IH2 t' Hrt) as [u' [Hu Hru]].
    exists u'; split; [eapply exec_seq; eauto | exact Hru].
  - destruct (IH1 a0 Hr) as [t' [Ht Hrt]].
    destruct (IH2 t' Hrt) as [u' [Hu Hru]].
    exists u'; split; [eapply exec_and_zero; eauto | exact Hru].
  - destruct (IH a0 Hr) as [t' [Ht Hrt]].
    exists t'; split; [apply exec_and_nonzero; auto | exact Hrt].
  - destruct (IH a0 Hr) as [t' [Ht Hrt]].
    exists t'; split; [apply exec_or_zero; auto | exact Hrt].
  - destruct (IH1 a0 Hr) as [t' [Ht Hrt]].
    destruct (IH2 t' Hrt) as [u' [Hu Hru]].
    exists u'; split; [eapply exec_or_nonzero; eauto | exact Hru].
Qed.

Theorem query_transfer {Atom C A : Type}
  (concrete : primitive Atom C) (abstract : primitive Atom A)
  (R : C -> A -> Prop) (hp : primitive_refines concrete abstract R)
  (cmd : command Atom) (c : C) (a : A) (hr : R c a)
  (Q : Z -> A -> Prop) (P : Z -> C -> Prop)
  (hq : forall rc a', exec abstract cmd a rc a' -> Q rc a')
  (hobs : forall rc c' a', R c' a' -> Q rc a' -> P rc c') :
  forall rc c', exec concrete cmd c rc c' -> P rc c'.
Proof.
  intros rc c' he.
  destruct (command_refines concrete abstract R hp cmd c c' rc he a hr)
    as [a' [Ha' Hr']].
  exact (hobs rc c' a' Hr' (hq rc a' Ha')).
Qed.

(* ---- Instantiation with the actual relay contract ---- *)

(* Shell-level state: the relay's world (the has_ext resource of relay_spec)
   plus the ledger of bytes the relay had read but not delivered when it
   exited (the funspec's existentially quantified pending). *)
Record shell_state := ShellState { os : world; lost : list byte }.

Inductive atom := Relay | Mark (b : byte).

Definition deliver (s : world) (b : byte) : world :=
  World (unread s) (delivered s ++ [b]) (reads s) (writes s)
    (read_calls s) (write_calls s).

(* The Relay case is verbatim the relay_spec postcondition predicate. *)
Definition relay_prim : primitive atom shell_state := fun a s rc t =>
  match a with
  | Relay => exists pending,
      outcome (os s) rc (os t) pending /\ lost t = lost s ++ pending
  | Mark b => rc = 0 /\ os t = deliver (os s) b /\ lost t = lost s
  end.

(* ---- Generic consequences for every command over relay_prim ---- *)

Lemma relay_status s rc t :
  relay_prim Relay s rc t -> rc = 0 \/ rc = 1 \/ rc = 2.
Proof. intros [pending [Ho _]]. exact (outcome_status _ _ _ _ Ho). Qed.

(* Every command over Relay/Mark only redistributes bytes: stdout is extended,
   unread input is consumed from the front, the lost ledger grows, and the
   total byte count over the three ledgers is preserved when no Mark runs.
   This is the composed form of RelayConservation.outcome_conservation. *)
Definition byte_total (s : shell_state) : Z :=
  Zlength (delivered (os s)) + Zlength (lost s) + Zlength (unread (os s)).

Fixpoint relay_only (c : command atom) : Prop :=
  match c with
  | call Relay => True
  | call (Mark _) => False
  | seq x y | and_then x y | or_else x y => relay_only x /\ relay_only y
  end.

Lemma relay_step_shape s rc t :
  relay_prim Relay s rc t ->
  exists extra pending,
    delivered (os t) = delivered (os s) ++ extra /\
    lost t = lost s ++ pending /\
    extra ++ pending ++ unread (os t) = unread (os s).
Proof.
  intros [pending [Ho Hl]].
  destruct (outcome_conservation _ _ _ _ Ho) as [extra [Hd Hpart]].
  exists extra, pending; auto.
Qed.

Lemma relay_step_total s rc t :
  relay_prim Relay s rc t -> byte_total t = byte_total s.
Proof.
  intro H. destruct (relay_step_shape s rc t H) as [extra [pending [Hd [Hl Hu]]]].
  unfold byte_total. rewrite Hd, Hl, <- Hu.
  repeat rewrite Zlength_app. lia.
Qed.

Theorem exec_ledgers c s rc t :
  exec relay_prim c s rc t ->
  (exists extra, delivered (os t) = delivered (os s) ++ extra) /\
  (exists consumed, unread (os s) = consumed ++ unread (os t)) /\
  (exists pending, lost t = lost s ++ pending).
Proof.
  intro He.
  induction He as
    [a s rc t Hp
    |x y s rc1 t rc2 u He1 IH1 He2 IH2
    |x y s t rc u He1 IH1 He2 IH2
    |x y s rc t He IH Hn
    |x y s t He IH
    |x y s rc1 t rc2 u He1 IH1 Hn He2 IH2];
    try (destruct IH1 as [[e1 D1] [[c1 U1] [p1 L1]]];
         destruct IH2 as [[e2 D2] [[c2 U2] [p2 L2]]];
         repeat split;
         [exists (e1 ++ e2); rewrite D2, D1; repeat rewrite app_assoc; reflexivity
         |exists (c1 ++ c2); rewrite U1, U2; repeat rewrite app_assoc; reflexivity
         |exists (p1 ++ p2); rewrite L2, L1; repeat rewrite app_assoc; reflexivity]);
    try exact IH.
  destruct a as [|b].
  - destruct (relay_step_shape s rc t Hp) as [extra [pending [Hd [Hl Hu]]]].
    repeat split.
    + exists extra; exact Hd.
    + exists (extra ++ pending). rewrite <- Hu. repeat rewrite app_assoc; reflexivity.
    + exists pending; exact Hl.
  - destruct Hp as [_ [Ht Hl]]. rewrite Ht, Hl. repeat split.
    + exists [b]; reflexivity.
    + exists []; reflexivity.
    + exists []; rewrite app_nil_r; reflexivity.
Qed.

Theorem exec_relay_only_conservation c s rc t :
  relay_only c -> exec relay_prim c s rc t -> byte_total t = byte_total s.
Proof.
  intros Hro He.
  induction He as
    [a s rc t Hp
    |x y s rc1 t rc2 u He1 IH1 He2 IH2
    |x y s t rc u He1 IH1 He2 IH2
    |x y s rc t He IH Hn
    |x y s t He IH
    |x y s rc1 t rc2 u He1 IH1 Hn He2 IH2]; simpl in Hro;
    try (destruct Hro as [H1 H2]);
    try (rewrite IH2 by assumption; apply IH1; assumption);
    try (apply IH; assumption).
  destruct a as [|b]; [| contradiction].
  exact (relay_step_total s rc t Hp).
Qed.

(* ---- A status-sensitive query, for every initial state ---- *)

(* `relay && mark b`: the marker byte appears iff the relay reported status 0,
   in which case the whole input was delivered; otherwise stdout carries only a
   prefix of the input, the residual is in the ledger, and the marker is absent.
   Same-bytes-different-status executions are therefore told apart. *)
Definition relay_then_mark (b : byte) : command atom :=
  and_then (call Relay) (call (Mark b)).

Theorem relay_then_mark_query b s rc t :
  exec relay_prim (relay_then_mark b) s rc t ->
  (rc = 0 /\
    delivered (os t) = delivered (os s) ++ unread (os s) ++ [b] /\
    unread (os t) = [] /\ lost t = lost s)
  \/
  (rc <> 0 /\ (rc = 1 \/ rc = 2) /\
    exists extra pending,
      delivered (os t) = delivered (os s) ++ extra /\
      lost t = lost s ++ pending /\
      extra ++ pending ++ unread (os t) = unread (os s) /\
      (rc = 1 -> pending = []) /\ (rc = 2 -> pending <> [])).
Proof.
  intro He. inversion He; subst.
  - (* relay returned 0, marker ran *)
    left.
    match goal with
    | H1 : exec relay_prim (call Relay) _ 0 _,
      H2 : exec relay_prim (call (Mark _)) _ _ _ |- _ =>
      inversion H1; subst; inversion H2; subst
    end.
    match goal with
    | Hr : relay_prim Relay _ 0 _, Hm : relay_prim (Mark _) _ _ _ |- _ =>
      destruct Hr as [pending [Ho Hl]]; destruct Hm as [Hrc [Ht Hl']]
    end.
    destruct (outcome_success_exact _ _ _ Ho) as [Hd [Hp Hu]].
    subst pending. rewrite app_nil_r in Hl. subst rc.
    rewrite Ht, Hl', Hl. unfold deliver; simpl. rewrite Hd, Hu.
    repeat split; try reflexivity. repeat rewrite app_assoc; reflexivity.
  - (* relay returned nonzero, marker skipped *)
    right.
    match goal with
    | H1 : exec relay_prim (call Relay) _ _ _ |- _ => inversion H1; subst
    end.
    match goal with
    | Hr : relay_prim Relay _ _ _ |- _ =>
      pose proof (relay_status _ _ _ Hr) as Hst;
      destruct Hr as [pending [Ho Hl]]
    end.
    destruct (outcome_conservation _ _ _ _ Ho) as [extra [Hd Hpart]].
    split; [assumption |].
    split; [lia |].
    exists extra, pending. repeat split; try assumption.
    + intro Hrc1; subst. exact (outcome_read_error_pending _ _ _ Ho).
    + intro Hrc2; subst. exact (outcome_write_error_pending _ _ _ Ho).
Qed.

(* ---- Nonvacuity: concrete executions with actual outcome derivations ---- *)

(* Successful relay of abc (read 3, write all, then EOF). *)
Definition input_s := World abc [] [3] [] 0%nat 0%nat.
Definition read_s := read_world (read32 input_s).
Definition written_s := write_world (write_block read_s abc).
Definition final_s := read_world (read32 written_s).

Lemma read_s_reachable : reaches input_s (Drain abc 0) read_s.
Proof.
  change (reaches input_s (Drain (read_bytes (read32 input_s)) 0)
    (read_world (read32 input_s))).
  apply (@RelayReach.read_data input_s input_s);
    [apply initial_ready | vm_compute; easy].
Qed.

Lemma written_s_reachable : reaches input_s (Drain abc (Zlength abc)) written_s.
Proof.
  change (reaches input_s
    (Drain abc (0 + write_ret (write_block read_s (suffix 0 abc))))
    (write_world (write_block read_s (suffix 0 abc)))).
  apply (@RelayReach.write_data input_s read_s abc 0);
    [apply read_s_reachable | vm_compute; easy | vm_compute; easy].
Qed.

Lemma success_outcome : outcome input_s 0 final_s [].
Proof.
  unfold outcome, final_s.
  apply read_eof; [|vm_compute; reflexivity].
  apply drained with (chunk := abc). exact written_s_reachable.
Qed.

Definition bang := Byte.repr 33.

(* Example 1: late read error after full delivery (ReachExamples.input_a). *)
Example late_error_exec :
  exec relay_prim (relay_then_mark bang) (ShellState input_a []) 1
    (ShellState final_a []).
Proof.
  apply exec_and_nonzero; [| discriminate].
  apply exec_call. exists []. split; [exact read_error_outcome | reflexivity].
Qed.

(* Example 2: success on the same bytes. *)
Example success_exec :
  exec relay_prim (relay_then_mark bang) (ShellState input_s []) 0
    (ShellState (deliver final_s bang) []).
Proof.
  apply exec_and_zero with (t := ShellState final_s []).
  - apply exec_call. exists []. split; [exact success_outcome | reflexivity].
  - apply exec_call. simpl. auto.
Qed.

Example same_relay_bytes : delivered final_a = delivered final_s.
Proof. vm_compute; reflexivity. Qed.

Example same_relay_bytes_are_abc : delivered final_s = abc.
Proof. vm_compute; reflexivity. Qed.

Example different_composed_bytes :
  delivered final_a <> delivered (deliver final_s bang).
Proof.
  intro H. apply (f_equal (@length byte)) in H. vm_compute in H. discriminate.
Qed.

(* No function of the relay's stdout bytes alone predicts the composed stdout:
   the exit status carried by outcome is essential (phase3 no_stdout_only_context). *)
Theorem no_stdout_only_context :
  ~ exists f : list byte -> list byte,
      f (delivered final_a) = delivered final_a /\
      f (delivered final_s) = delivered (deliver final_s bang).
Proof.
  intros [f [Ha Hs]]. apply different_composed_bytes.
  rewrite <- Ha, <- Hs, same_relay_bytes. reflexivity.
Qed.

(* Example 3: pending bytes lost at process exit, then a fresh relay
   (phase3 RelayComposition.pending_discarded_at_exit): first relay reads abcd,
   delivers ab, write returns 0 (status 2, pending cd); second relay delivers ef. *)
Definition read_b2 := read_world (read32 final_b).
Definition ef := map Byte.repr [101; 102].
Definition written_b2 := write_world (write_block read_b2 ef).
Definition final_b2 := read_world (read32 written_b2).

Lemma read_b2_reachable : reaches final_b (Drain ef 0) read_b2.
Proof.
  change (reaches final_b (Drain (read_bytes (read32 final_b)) 0)
    (read_world (read32 final_b))).
  apply (@RelayReach.read_data final_b final_b);
    [apply initial_ready | vm_compute; easy].
Qed.

Lemma written_b2_reachable : reaches final_b (Drain ef (Zlength ef)) written_b2.
Proof.
  change (reaches final_b
    (Drain ef (0 + write_ret (write_block read_b2 (suffix 0 ef))))
    (write_world (write_block read_b2 (suffix 0 ef)))).
  apply (@RelayReach.write_data final_b read_b2 ef 0);
    [apply read_b2_reachable | vm_compute; easy | vm_compute; easy].
Qed.

Lemma second_relay_outcome : outcome final_b 0 final_b2 [].
Proof.
  unfold outcome, final_b2.
  apply read_eof; [|vm_compute; reflexivity].
  apply drained with (chunk := ef). exact written_b2_reachable.
Qed.

Example pending_lost_then_fresh_relay :
  exec relay_prim (seq (call Relay) (call Relay)) (ShellState input_b []) 0
    (ShellState final_b2 (suffix 2 abcd)).
Proof.
  apply exec_seq with (rc1 := 2) (t := ShellState final_b (suffix 2 abcd)).
  - apply exec_call. exists (suffix 2 abcd).
    split; [exact zero_write_outcome | reflexivity].
  - apply exec_call. exists [].
    split; [exact second_relay_outcome | symmetry; apply app_nil_r].
Qed.

Example pending_lost_observations :
  delivered final_b2 = map Byte.repr [97; 98; 101; 102] /\
  suffix 2 abcd = map Byte.repr [99; 100] /\
  unread final_b2 = [] /\
  delivered final_b2 ++ suffix 2 abcd ++ unread final_b2 <> abcdef /\
  byte_total (ShellState final_b2 (suffix 2 abcd)) =
    byte_total (ShellState input_b []).
Proof.
  repeat split; try (vm_compute; reflexivity).
  (* abef ++ cd ++ [] = abefcd differs from abcdef in position 3 *)
  intro H. apply (f_equal (map Byte.unsigned)) in H. vm_compute in H. discriminate.
Qed.

(* Example 4: NUL and 255 are ordinary bytes; the composed output keeps them. *)
Definition nul255 := map Byte.repr [0; 255; 10].
Definition input_n := World nul255 [] [3] [] 0%nat 0%nat.
Definition read_n := read_world (read32 input_n).
Definition written_n := write_world (write_block read_n nul255).
Definition final_n := read_world (read32 written_n).

Lemma read_n_reachable : reaches input_n (Drain nul255 0) read_n.
Proof.
  change (reaches input_n (Drain (read_bytes (read32 input_n)) 0)
    (read_world (read32 input_n))).
  apply (@RelayReach.read_data input_n input_n);
    [apply initial_ready | vm_compute; easy].
Qed.

Lemma written_n_reachable :
  reaches input_n (Drain nul255 (Zlength nul255)) written_n.
Proof.
  change (reaches input_n
    (Drain nul255 (0 + write_ret (write_block read_n (suffix 0 nul255))))
    (write_world (write_block read_n (suffix 0 nul255)))).
  apply (@RelayReach.write_data input_n read_n nul255 0);
    [apply read_n_reachable | vm_compute; easy | vm_compute; easy].
Qed.

Lemma nul255_outcome : outcome input_n 0 final_n [].
Proof.
  unfold outcome, final_n.
  apply read_eof; [|vm_compute; reflexivity].
  apply drained with (chunk := nul255). exact written_n_reachable.
Qed.

Example nul255_exec :
  exec relay_prim (relay_then_mark bang) (ShellState input_n []) 0
    (ShellState (deliver final_n bang) []).
Proof.
  apply exec_and_zero with (t := ShellState final_n []).
  - apply exec_call. exists []. split; [exact nul255_outcome | reflexivity].
  - apply exec_call. simpl. auto.
Qed.

Example nul255_observations :
  map Byte.unsigned (delivered (deliver final_n bang)) = [0; 255; 10; 33] /\
  unread final_n = [].
Proof. vm_compute; split; reflexivity. Qed.

(* The generic query agrees with the concrete executions. *)
Example late_error_query_instance :
  forall rc t, exec relay_prim (relay_then_mark bang) (ShellState input_a []) rc t ->
    rc = 0 \/ (rc <> 0 /\ exists pending, lost t = pending /\ (rc = 1 -> pending = [])).
Proof.
  intros rc t He. destruct (relay_then_mark_query bang _ _ _ He)
    as [[H0 _] | [Hn [_ [extra [pending [_ [Hl [_ [H1 _]]]]]]]]].
  - left; exact H0.
  - right. split; [exact Hn |]. exists pending. split; [exact Hl | exact H1].
Qed.

End ShellComposition.
