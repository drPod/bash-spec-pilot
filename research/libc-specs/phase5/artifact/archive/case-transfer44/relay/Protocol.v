(* Draft: source review only; compilation is reserved for the main toolchain
   window. Pure scheduled primitives, not a C interpreter or an OS model. *)
From Coq Require Import List ZArith Lia.
From compcert Require Import Integers.
Require Import VST.zlist.sublist.
Import ListNotations.
Local Open Scope Z_scope.

Module RelayProtocol.

Record world := World {
  unread : list byte;
  delivered : list byte;
  reads : list Z;
  writes : list Z;
  read_calls : nat;
  write_calls : nat
}.

Definition valid_reads (xs : list Z) :=
  Forall (fun q => q = -1 \/ 0 < q) xs.
Definition valid_writes (xs : list Z) := Forall (fun q => -1 <= q) xs.
Definition valid_world (s : world) :=
  valid_reads (reads s) /\ valid_writes (writes s).

Definition action (fallback : Z) (xs : list Z) :=
  match xs with [] => fallback | q :: _ => q end.

Definition prefix (n : Z) (xs : list byte) := sublist 0 n xs.
Definition suffix (n : Z) (xs : list byte) := sublist n (Zlength xs) xs.

(* Totalization agrees with the earlier model on valid schedules. On invalid
   read quota zero it uses quota one; all negative actions mean error. *)
Definition read_amount (q : Z) (xs : list byte) :=
  Z.min (Z.max 1 q) (Z.min 32 (Zlength xs)).

Record read_result := ReadResult {
  read_ret : Z;
  read_bytes : list byte;
  read_world : world
}.

Definition read32 (s : world) : read_result :=
  let q := action 32 (reads s) in
  if q <? 0 then
    ReadResult (-1) []
      (World (unread s) (delivered s) (tl (reads s)) (writes s)
        (S (read_calls s)) (write_calls s))
  else
    let k := read_amount q (unread s) in
    ReadResult k (prefix k (unread s))
      (World (suffix k (unread s)) (delivered s)
        (tl (reads s)) (writes s) (S (read_calls s)) (write_calls s)).

Record write_result := WriteResult {
  write_ret : Z;
  write_bytes : list byte;
  write_world : world
}.

(* bs is the entire initialized request. Its link to actual C memory is a
   separate funspec/adequacy obligation. Empty requests are totalized here;
   relay's write funspec will require 0 < Zlength bs <= 32. *)
Definition write_block (s : world) (bs : list byte) : write_result :=
  let q := action (Zlength bs) (writes s) in
  if q <? 0 then
    WriteResult (-1) []
      (World (unread s) (delivered s) (reads s) (tl (writes s))
        (read_calls s) (S (write_calls s)))
  else
    let k := Z.min q (Zlength bs) in
    let out := prefix k bs in
    WriteResult k out
      (World (unread s) (delivered s ++ out)
        (reads s) (tl (writes s)) (read_calls s) (S (write_calls s))).

Lemma min_bounds a b : 0 <= a -> 0 <= b ->
  0 <= Z.min a b /\ Z.min a b <= a /\ Z.min a b <= b.
Proof.
  intros Ha Hb. destruct (Z.min_spec a b) as [[H E] | [H E]];
    rewrite E; lia.
Qed.

Lemma max_one_positive q : 0 < Z.max 1 q.
Proof.
  destruct (Z.max_spec 1 q) as [[H E] | [H E]]; rewrite E; lia.
Qed.

Lemma read_amount_bounds q xs :
  0 <= read_amount q xs /\ read_amount q xs <= 32 /\
  read_amount q xs <= Zlength xs.
Proof.
  pose proof (Zlength_nonneg xs) as Hlen.
  pose proof (max_one_positive q) as Hq.
  pose proof (min_bounds 32 (Zlength xs) ltac:(lia) Hlen) as Hinner.
  pose proof (min_bounds (Z.max 1 q) (Z.min 32 (Zlength xs))
    ltac:(lia) ltac:(lia)) as Houter.
  unfold read_amount; lia.
Qed.

Lemma read_amount_positive q xs :
  0 < Zlength xs -> 0 < read_amount q xs.
Proof.
  intro Hlen. pose proof (max_one_positive q) as Hpositive.
  unfold read_amount.
  destruct (Z.min_spec 32 (Zlength xs)) as [[H E] | [H E]];
    rewrite E;
    match goal with
    | |- 0 < Z.min ?a ?b =>
      destruct (Z.min_spec a b) as [[H' E'] | [H' E']]; rewrite E'; lia
    end.
Qed.

Lemma prefix_length k xs : 0 <= k <= Zlength xs ->
  Zlength (prefix k xs) = k.
Proof.
  intro H. unfold prefix. rewrite Zlength_sublist by lia. lia.
Qed.

Lemma prefix_suffix k xs : 0 <= k <= Zlength xs ->
  prefix k xs ++ suffix k xs = xs.
Proof.
  intro H. unfold prefix, suffix.
  rewrite sublist_rejoin by lia. apply sublist_same; reflexivity.
Qed.

Lemma read_ret_bounds s : -1 <= read_ret (read32 s) <= 32.
Proof.
  unfold read32. destruct (action 32 (reads s) <? 0) eqn:H;
    simpl; [lia |]. pose proof (read_amount_bounds
      (action 32 (reads s)) (unread s)); lia.
Qed.

Lemma read_conservation s :
  read_bytes (read32 s) ++ unread (read_world (read32 s)) = unread s.
Proof.
  unfold read32. destruct (action 32 (reads s) <? 0); simpl; auto.
  apply prefix_suffix. pose proof (read_amount_bounds
    (action 32 (reads s)) (unread s)); lia.
Qed.

Lemma read_preserves_output s :
  delivered (read_world (read32 s)) = delivered s.
Proof. unfold read32; destruct (action 32 (reads s) <? 0); reflexivity. Qed.

Lemma read_schedule_effect s :
  reads (read_world (read32 s)) = tl (reads s) /\
  writes (read_world (read32 s)) = writes s.
Proof.
  unfold read32; destruct (action 32 (reads s) <? 0); split; reflexivity.
Qed.

Lemma read_counter_effect s :
  read_calls (read_world (read32 s)) = S (read_calls s) /\
  write_calls (read_world (read32 s)) = write_calls s.
Proof.
  unfold read32; destruct (action 32 (reads s) <? 0); split; reflexivity.
Qed.

Lemma read_success_length s : 0 <= read_ret (read32 s) ->
  Zlength (read_bytes (read32 s)) = read_ret (read32 s).
Proof.
  unfold read32. destruct (action 32 (reads s) <? 0); simpl;
    intro H; [lia |]. apply prefix_length.
  pose proof (read_amount_bounds (action 32 (reads s)) (unread s)); lia.
Qed.

Lemma read_error_first s : action 32 (reads s) < 0 ->
  read_ret (read32 s) = -1 /\ read_bytes (read32 s) = [] /\
  unread (read_world (read32 s)) = unread s.
Proof.
  intro H. unfold read32.
  assert (E : (action 32 (reads s) <? 0) = true) by
    (apply Z.ltb_lt; exact H).
  rewrite E; simpl; auto.
Qed.

Lemma read_zero_only_empty s : read_ret (read32 s) = 0 -> unread s = [].
Proof.
  unfold read32. destruct (action 32 (reads s) <? 0); simpl;
    intro H; [lia |].
  destruct (unread s) as [|b bs] eqn:E; [reflexivity |].
  assert (Hlen : 0 < Zlength (b :: bs)).
  { rewrite Zlength_cons. pose proof (Zlength_nonneg bs); lia. }
  pose proof (read_amount_positive (action 32 (reads s)) (b :: bs) Hlen).
  lia.
Qed.

Lemma write_ret_bounds s bs :
  -1 <= write_ret (write_block s bs) <= Zlength bs.
Proof.
  pose proof (Zlength_nonneg bs) as Hlen.
  unfold write_block.
  destruct (action (Zlength bs) (writes s) <? 0) eqn:H; simpl; [lia |].
  apply Z.ltb_ge in H.
  pose proof (min_bounds (action (Zlength bs) (writes s)) (Zlength bs) H Hlen).
  lia.
Qed.

Lemma write_effect s bs :
  delivered (write_world (write_block s bs)) =
    delivered s ++ write_bytes (write_block s bs) /\
  unread (write_world (write_block s bs)) = unread s.
Proof.
  unfold write_block; destruct (action (Zlength bs) (writes s) <? 0);
    simpl; split; try reflexivity; rewrite app_nil_r; reflexivity.
Qed.

Lemma write_schedule_effect s bs :
  writes (write_world (write_block s bs)) = tl (writes s) /\
  reads (write_world (write_block s bs)) = reads s.
Proof.
  unfold write_block; destruct (action (Zlength bs) (writes s) <? 0);
    split; reflexivity.
Qed.

Lemma write_counter_effect s bs :
  write_calls (write_world (write_block s bs)) = S (write_calls s) /\
  read_calls (write_world (write_block s bs)) = read_calls s.
Proof.
  unfold write_block; destruct (action (Zlength bs) (writes s) <? 0);
    split; reflexivity.
Qed.

Lemma write_success_prefix s bs : 0 <= write_ret (write_block s bs) ->
  write_bytes (write_block s bs) = prefix (write_ret (write_block s bs)) bs /\
  Zlength (write_bytes (write_block s bs)) = write_ret (write_block s bs).
Proof.
  unfold write_block.
  destruct (action (Zlength bs) (writes s) <? 0) eqn:H; simpl;
    intro Hr; [lia |].
  split; [reflexivity |]. apply prefix_length.
  apply Z.ltb_ge in H. pose proof (Zlength_nonneg bs).
  pose proof (min_bounds (action (Zlength bs) (writes s)) (Zlength bs)
    H ltac:(lia)); lia.
Qed.

Lemma write_nonpositive_no_bytes s bs :
  write_ret (write_block s bs) <= 0 -> write_bytes (write_block s bs) = [].
Proof.
  unfold write_block.
  destruct (action (Zlength bs) (writes s) <? 0) eqn:H; simpl;
    intro Hr; [reflexivity |].
  apply Z.ltb_ge in H. pose proof (Zlength_nonneg bs).
  pose proof (min_bounds (action (Zlength bs) (writes s)) (Zlength bs)
    H ltac:(lia)).
  assert (E : Z.min (action (Zlength bs) (writes s)) (Zlength bs) = 0) by lia.
  rewrite E. unfold prefix. apply sublist_nil_gen; lia.
Qed.

Lemma write_success_partition s bs : 0 <= write_ret (write_block s bs) ->
  write_bytes (write_block s bs) ++ suffix (write_ret (write_block s bs)) bs = bs.
Proof.
  intro H. destruct (write_success_prefix s bs H) as [Hbytes Hlen].
  rewrite Hbytes. apply prefix_suffix.
  pose proof (write_ret_bounds s bs); lia.
Qed.

Lemma write_nonpositive_preserves_channels s bs :
  write_ret (write_block s bs) <= 0 ->
  delivered (write_world (write_block s bs)) = delivered s /\
  unread (write_world (write_block s bs)) = unread s.
Proof.
  intro H. destruct (write_effect s bs) as [Hd Hu].
  rewrite (write_nonpositive_no_bytes s bs H), app_nil_r in Hd.
  auto.
Qed.

Lemma valid_tail {A} (P : A -> Prop) xs : Forall P xs -> Forall P (tl xs).
Proof. destruct xs; simpl; intro H; [constructor | inversion H; assumption]. Qed.

Lemma read_valid_world s : valid_world s -> valid_world (read_world (read32 s)).
Proof.
  intros [Hr Hw]. unfold valid_world, valid_reads, valid_writes in *.
  unfold read32; destruct (action 32 (reads s) <? 0); simpl;
    split; auto using valid_tail.
Qed.

Lemma write_valid_world s bs :
  valid_world s -> valid_world (write_world (write_block s bs)).
Proof.
  intros [Hr Hw]. unfold valid_world, valid_reads, valid_writes in *.
  unfold write_block; destruct (action (Zlength bs) (writes s) <? 0); simpl;
    split; auto using valid_tail.
Qed.

(* Functions give totality without assuming successful behavior or termination
   of external C calls. These graph relations are convenient funspec predicates. *)
Definition ReadStep s r bs t := read32 s = ReadResult r bs t.
Definition WriteStep s bs r out t := write_block s bs = WriteResult r out t.

Lemma read_total s : exists r bs t, ReadStep s r bs t.
Proof. unfold ReadStep. destruct (read32 s) as [r bs t]; eauto. Qed.
Lemma write_total s bs : exists r out t, WriteStep s bs r out t.
Proof. unfold WriteStep. destruct (write_block s bs) as [r out t]; eauto. Qed.

(* Explicit primitive sequences, not a relay evaluator. *)
Definition abc := map Byte.repr [97; 98; 99].
Definition abcdef := map Byte.repr [97; 98; 99; 100; 101; 102].

Example delivered_then_read_error :
  let r1 := read32 (World abc [] [3; -1] [] 0%nat 0%nat) in
  let w1 := write_block (read_world r1) (read_bytes r1) in
  let r2 := read32 (write_world w1) in
  delivered (read_world r2) = abc /\ read_ret r2 = -1 /\
  unread (read_world r2) = [] /\
  read_calls (read_world r2) = 2%nat /\ write_calls (read_world r2) = 1%nat.
Proof. vm_compute; repeat split; reflexivity. Qed.

Example short_write_then_zero :
  let r := read32 (World abcdef [] [4] [2; 0] 0%nat 0%nat) in
  let w1 := write_block (read_world r) (read_bytes r) in
  let pending := suffix (write_ret w1) (read_bytes r) in
  let w2 := write_block (write_world w1) pending in
  delivered (write_world w2) = map Byte.repr [97; 98] /\
  pending = map Byte.repr [99; 100] /\
  unread (write_world w2) = map Byte.repr [101; 102] /\ write_ret w2 = 0 /\
  read_calls (write_world w2) = 1%nat /\ write_calls (write_world w2) = 2%nat.
Proof. vm_compute; repeat split; reflexivity. Qed.

End RelayProtocol.
