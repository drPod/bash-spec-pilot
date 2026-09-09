(* Draft until compiled by the main worker. Pure consequences of the existing
   abstract contract; no C-execution, termination, or full-trace theorem. *)
From Coq Require Import List ZArith Lia.
From compcert Require Import Integers.
Require Import VST.zlist.sublist.
Require Import Protocol Reach.
Import ListNotations RelayProtocol RelayReach.
Local Open Scope Z_scope.

Module RelayConservation.

Definition pending_of (p : phase) : list byte :=
  match p with Ready => [] | Drain chunk off => suffix off chunk
  | Halt _ pending => pending end.

Definition phase_bounds (p : phase) : Prop :=
  match p with
  | Drain chunk off => 0 < Zlength chunk <= 32 /\ 0 <= off <= Zlength chunk
  | _ => True
  end.

Lemma suffix_length off chunk : 0 <= off <= Zlength chunk ->
  Zlength (suffix off chunk) = Zlength chunk - off.
Proof. intro H; unfold suffix; rewrite Zlength_sublist by lia; reflexivity. Qed.

Lemma suffix_zero chunk : suffix 0 chunk = chunk.
Proof. unfold suffix; apply sublist_same; reflexivity. Qed.

Lemma suffix_end chunk : suffix (Zlength chunk) chunk = [].
Proof. unfold suffix; apply sublist_nil_gen; lia. Qed.

Lemma suffix_suffix off k chunk :
  0 <= off <= Zlength chunk -> 0 <= k ->
  suffix k (suffix off chunk) = suffix (off + k) chunk.
Proof.
  intros Hoff Hk. unfold suffix.
  rewrite Zlength_sublist by lia.
  rewrite sublist_suffix by lia.
  replace (k + off) with (off + k) by lia. reflexivity.
Qed.

Lemma suffix_nonempty off chunk : 0 <= off < Zlength chunk ->
  suffix off chunk <> [].
Proof.
  intros H E. pose proof (suffix_length off chunk ltac:(lia)) as Hlen.
  rewrite E in Hlen. change (0 = Zlength chunk - off) in Hlen. lia.
Qed.

Lemma reaches_phase_bounds initial p s :
  reaches initial p s -> phase_bounds p.
Proof.
  intro Hr.
  induction Hr as
    [|s Hr IH Hpositive|s Hr IH Herror|s Hr IH Heof
     |s chunk off Hr IH Hoff Hpositive|s chunk off Hr IH Hoff Herror
     |s chunk Hr IH]; simpl in *.
  - exact I.
  - pose proof (read_success_length s ltac:(lia)) as Hlen.
    pose proof (read_ret_bounds s) as Hbound. rewrite Hlen; lia.
  - exact I.
  - exact I.
  - pose proof (write_ret_bounds s (suffix off chunk)) as Hbound.
    rewrite (suffix_length off chunk ltac:(lia)) in Hbound. lia.
  - exact I.
  - exact I.
Qed.

Lemma reaches_drain_bounds initial s chunk off :
  reaches initial (Drain chunk off) s ->
  0 < Zlength chunk <= 32 /\ 0 <= off <= Zlength chunk.
Proof. apply reaches_phase_bounds. Qed.

Lemma read_nonpositive_no_bytes s : read_ret (read32 s) <= 0 ->
  read_bytes (read32 s) = [].
Proof.
  unfold read32. destruct (action 32 (reads s) <? 0); simpl;
    intro Hret; [reflexivity |].
  pose proof (read_amount_bounds (action 32 (reads s)) (unread s)) as Hbounds.
  assert (E : read_amount (action 32 (reads s)) (unread s) = 0) by lia.
  rewrite E. unfold prefix. apply sublist_nil_gen; lia.
Qed.

Lemma read_nonpositive_preserves_input s : read_ret (read32 s) <= 0 ->
  unread (read_world (read32 s)) = unread s.
Proof.
  intro H. pose proof (read_conservation s) as Hcons.
  rewrite (read_nonpositive_no_bytes s H) in Hcons. exact Hcons.
Qed.

Lemma read_eof_final_empty s : read_ret (read32 s) = 0 ->
  unread (read_world (read32 s)) = [].
Proof.
  intro H. rewrite (read_nonpositive_preserves_input s ltac:(lia)).
  apply read_zero_only_empty; exact H.
Qed.

(* Equality retains the initial delivered log. No subtraction of byte strings
   and no assumption that the initial log is empty is needed. *)
Lemma reaches_conservation initial p s : reaches initial p s ->
  delivered s ++ pending_of p ++ unread s = delivered initial ++ unread initial.
Proof.
  intro Hr.
  induction Hr as
    [|s Hr IH Hpositive|s Hr IH Herror|s Hr IH Heof
     |s chunk off Hr IH Hoff Hpositive|s chunk off Hr IH Hoff Herror
     |s chunk Hr IH]; simpl in *.
  - reflexivity.
  - rewrite read_preserves_output, suffix_zero, read_conservation. exact IH.
  - rewrite read_preserves_output,
      (read_nonpositive_preserves_input s ltac:(lia)). exact IH.
  - rewrite read_preserves_output,
      (read_nonpositive_preserves_input s ltac:(lia)). exact IH.
  - destruct (write_effect s (suffix off chunk)) as [Hdel Hunread].
    pose proof (write_success_partition s (suffix off chunk) ltac:(lia)) as Hpart.
    rewrite (suffix_suffix off
      (write_ret (write_block s (suffix off chunk))) chunk ltac:(lia) ltac:(lia))
      in Hpart.
    rewrite Hdel, Hunread.
    transitivity
      (delivered s ++
        (write_bytes (write_block s (suffix off chunk)) ++
         suffix (off + write_ret (write_block s (suffix off chunk))) chunk) ++
        unread s).
    + repeat rewrite app_assoc; reflexivity.
    + rewrite Hpart. exact IH.
  - destruct (write_nonpositive_preserves_channels s (suffix off chunk) Herror)
      as [Hdel Hunread].
    rewrite Hdel, Hunread. exact IH.
  - rewrite suffix_end in IH. exact IH.
Qed.

Lemma reaches_delivered_extension initial p s : reaches initial p s ->
  exists extra, delivered s = delivered initial ++ extra.
Proof.
  intro Hr.
  induction Hr as
    [|s Hr IH Hpositive|s Hr IH Herror|s Hr IH Heof
     |s chunk off Hr IH Hoff Hpositive|s chunk off Hr IH Hoff Herror
     |s chunk Hr IH].
  - exists []; rewrite app_nil_r; reflexivity.
  - rewrite read_preserves_output; exact IH.
  - rewrite read_preserves_output; exact IH.
  - rewrite read_preserves_output; exact IH.
  - destruct IH as [extra Hex].
    destruct (write_effect s (suffix off chunk)) as [Hdel Hunread].
    exists (extra ++ write_bytes (write_block s (suffix off chunk))).
    rewrite Hdel, Hex. repeat rewrite app_assoc; reflexivity.
  - destruct (write_nonpositive_preserves_channels s (suffix off chunk) Herror)
      as [Hdel Hunread]. rewrite Hdel; exact IH.
  - exact IH.
Qed.

Lemma reaches_new_output_partition initial p s : reaches initial p s ->
  exists extra, delivered s = delivered initial ++ extra /\
    extra ++ pending_of p ++ unread s = unread initial.
Proof.
  intro Hr. destruct (reaches_delivered_extension initial p s Hr) as [extra Hex].
  exists extra; split; [exact Hex |].
  pose proof (reaches_conservation initial p s Hr) as Hcons.
  rewrite Hex in Hcons.
  assert (Hcancel : delivered initial ++ (extra ++ pending_of p ++ unread s) =
    delivered initial ++ unread initial).
  { rewrite <- Hcons. repeat rewrite app_assoc; reflexivity. }
  apply app_inv_head in Hcancel. exact Hcancel.
Qed.

Lemma outcome_conservation initial status final pending :
  outcome initial status final pending ->
  exists extra, delivered final = delivered initial ++ extra /\
    extra ++ pending ++ unread final = unread initial.
Proof. unfold outcome; apply reaches_new_output_partition. Qed.

Lemma outcome_eof_pending initial final pending :
  outcome initial 0 final pending -> pending = [] /\ unread final = [].
Proof.
  unfold outcome. intro H. inversion H; subst.
  split; [reflexivity |]. apply read_eof_final_empty; assumption.
Qed.

Lemma outcome_read_error_pending initial final pending :
  outcome initial 1 final pending -> pending = [].
Proof. unfold outcome; intro H; inversion H; reflexivity. Qed.

Lemma outcome_write_error_pending initial final pending :
  outcome initial 2 final pending -> pending <> [].
Proof.
  unfold outcome. intro H. inversion H; subst.
  apply suffix_nonempty; assumption.
Qed.

(* Status zero entails exact new output, but the converse is deliberately absent:
   a read error can occur after every input byte has already been delivered. *)
Lemma outcome_success_exact initial final pending :
  outcome initial 0 final pending ->
  delivered final = delivered initial ++ unread initial /\
  pending = [] /\ unread final = [].
Proof.
  intro H. destruct (outcome_eof_pending initial final pending H) as [Hp Hu].
  destruct (outcome_conservation initial 0 final pending H) as [extra [Hd Hpart]].
  rewrite Hp, Hu in Hpart. simpl in Hpart. rewrite app_nil_r in Hpart.
  subst extra. auto.
Qed.

End RelayConservation.
