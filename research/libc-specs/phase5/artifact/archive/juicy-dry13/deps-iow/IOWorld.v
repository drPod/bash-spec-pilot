(* Generalized scheduled I/O world for the GNU coreutils simple_cat / gnulib
   safe_read, safe_write, full_write transfer (phase5/utility-reuse).

   Relation to the relay world (relay/Protocol.v, module RelayProtocol): same
   design (deterministic primitives driven by finite quota schedules, finite
   list of unread input bytes, delivered output bytes), generalized in four
   ways: (1) the descriptor the input stream belongs to is a world field
   (in_fd) and the output descriptor likewise (out_fd), instead of fixed 0/1;
   (2) the read count is a parameter n instead of 32; (3) negative schedule
   entries -e mean "the syscall fails with errno e" (the relay only had -1);
   (4) diagnostics records the errno values reported through error(0, e, ...).
   The list helpers prefix/suffix/action and their lemmas are reused literally
   from Protocol.v; nothing in that file is changed or re-proved here.

   Pure mathematics only: not a C interpreter, not an OS model. *)
From Coq Require Import List ZArith Lia Bool.
From compcert Require Import Integers.
Require Import VST.zlist.sublist.
Require Protocol.
Import ListNotations.
Local Open Scope Z_scope.

Module IOW.

Module RP := Protocol.RelayProtocol.
Notation prefix := RP.prefix.
Notation suffix := RP.suffix.
Notation action := RP.action.

(* Linux asm-generic/errno-base.h values, as in the adapter errno.h. *)
Definition EINTR : Z := 4.
Definition EINVAL : Z := 22.
Definition ENOSPC : Z := 28.
(* gnulib sys-limits.h: INT_MAX >> 20 << 20 *)
Notation SYS_BUFSIZE_MAX := 2146435072.
Lemma SYS_BUFSIZE_MAX_eq : SYS_BUFSIZE_MAX = Z.shiftl (Z.shiftr Int.max_signed 20) 20.
Proof. reflexivity. Qed.

Record world := World {
  in_fd : Z;
  out_fd : Z;
  unread : list byte;
  delivered : list byte;
  reads : list Z;
  writes : list Z;
  read_calls : nat;
  write_calls : nat;
  diagnostics : list Z
}.

(* A negative entry -e is an error with errno e (representable as a C int);
   nonnegative entries are quotas. Read quota 0 is treated as 1 (as in relay). *)
Definition valid_reads (xs : list Z) :=
  Forall (fun q => 1 <= -q <= Int.max_signed \/ 0 < q) xs.
Definition valid_writes (xs : list Z) :=
  Forall (fun q => 1 <= -q <= Int.max_signed \/ 0 <= q) xs.
Definition valid_world (s : world) :=
  valid_reads (reads s) /\ valid_writes (writes s).

Definition after_read (s : world) (rest : list byte) : world :=
  World (in_fd s) (out_fd s) rest (delivered s) (tl (reads s)) (writes s)
    (S (read_calls s)) (write_calls s) (diagnostics s).
Definition after_write (s : world) (out : list byte) : world :=
  World (in_fd s) (out_fd s) (unread s) (delivered s ++ out) (reads s) (tl (writes s))
    (read_calls s) (S (write_calls s)) (diagnostics s).
Definition report (e : Z) (s : world) : world :=
  World (in_fd s) (out_fd s) (unread s) (delivered s) (reads s) (writes s)
    (read_calls s) (write_calls s) (diagnostics s ++ [e]).

(* ---- one read(2) call with count n ---- *)

Record read_result := ReadResult {
  read_ret : Z; read_errno : Z; read_bytes : list byte; read_world : world }.

Definition read_amount (q n : Z) (xs : list byte) :=
  Z.min (Z.max 1 q) (Z.min n (Zlength xs)).

Definition read_n (n : Z) (s : world) : read_result :=
  let q := action n (reads s) in
  if q <? 0 then ReadResult (-1) (-q) [] (after_read s (unread s))
  else
    let k := read_amount q n (unread s) in
    ReadResult k 0 (prefix k (unread s)) (after_read s (suffix k (unread s))).

(* ---- one write(2) call for the request bytes bs ---- *)

Record write_result := WriteResult {
  write_ret : Z; write_errno : Z; write_bytes : list byte; write_world : world }.

Definition write_n (bs : list byte) (s : world) : write_result :=
  let q := action (Zlength bs) (writes s) in
  if q <? 0 then WriteResult (-1) (-q) [] (after_write s [])
  else
    let k := Z.min q (Zlength bs) in
    WriteResult k 0 (prefix k bs) (after_write s (prefix k bs)).

(* ---- primitive lemmas ---- *)

Ltac crush :=
  repeat match goal with H : _ /\ _ |- _ => destruct H end;
  repeat split; intros;
  repeat match goal with
         | Hi : ?A -> _, HA : ?A |- _ => specialize (Hi HA)
         | H : _ /\ _ |- _ => destruct H
         end;
  try solve [congruence | lia | tauto].

Lemma read_amount_bounds q n xs : 0 <= n ->
  0 <= read_amount q n xs /\ read_amount q n xs <= n /\ read_amount q n xs <= Zlength xs.
Proof.
  intro Hn. pose proof (Zlength_nonneg xs) as Hlen.
  pose proof (RP.max_one_positive q) as Hq.
  pose proof (RP.min_bounds n (Zlength xs) Hn Hlen) as Hinner.
  pose proof (RP.min_bounds (Z.max 1 q) (Z.min n (Zlength xs)) ltac:(lia) ltac:(lia)) as Houter.
  unfold read_amount; lia.
Qed.

Lemma read_amount_positive q n xs : 0 < n -> 0 < Zlength xs -> 0 < read_amount q n xs.
Proof.
  intros Hn Hlen. pose proof (RP.max_one_positive q) as Hq. unfold read_amount.
  destruct (Z.min_spec n (Zlength xs)) as [[Hm Em] | [Hm Em]]; rewrite Em;
    match goal with
    | |- 0 < Z.min ?a ?b => destruct (Z.min_spec a b) as [[Hm' Em'] | [Hm' Em']]; rewrite Em'; lia
    end.
Qed.

Lemma read_ret_bounds n s : 0 <= n -> -1 <= read_ret (read_n n s) <= n.
Proof.
  intro Hn. unfold read_n. destruct (action n (reads s) <? 0); simpl; [lia |].
  pose proof (read_amount_bounds (action n (reads s)) n (unread s) Hn); lia.
Qed.

Lemma read_success_length n s : 0 <= n -> 0 <= read_ret (read_n n s) ->
  Zlength (read_bytes (read_n n s)) = read_ret (read_n n s).
Proof.
  intro Hn. unfold read_n. destruct (action n (reads s) <? 0); simpl; intro H; [lia |].
  apply RP.prefix_length. pose proof (read_amount_bounds (action n (reads s)) n (unread s) Hn); lia.
Qed.

Lemma read_conservation n s : 0 <= n ->
  read_bytes (read_n n s) ++ unread (read_world (read_n n s)) = unread s.
Proof.
  intro Hn. unfold read_n. destruct (action n (reads s) <? 0); simpl; auto.
  apply RP.prefix_suffix. pose proof (read_amount_bounds (action n (reads s)) n (unread s) Hn); lia.
Qed.

Lemma read_frame n s :
  delivered (read_world (read_n n s)) = delivered s /\
  in_fd (read_world (read_n n s)) = in_fd s /\
  out_fd (read_world (read_n n s)) = out_fd s /\
  diagnostics (read_world (read_n n s)) = diagnostics s /\
  reads (read_world (read_n n s)) = tl (reads s) /\
  writes (read_world (read_n n s)) = writes s.
Proof. unfold read_n; destruct (action n (reads s) <? 0); simpl; repeat split; reflexivity. Qed.

Lemma read_zero_only_empty n s : 0 < n -> read_ret (read_n n s) = 0 -> unread s = [].
Proof.
  intro Hn. unfold read_n. destruct (action n (reads s) <? 0); simpl; intro H; [lia |].
  destruct (unread s) as [|b bs] eqn:E; [reflexivity |].
  assert (Hlen : 0 < Zlength (b :: bs)) by (rewrite Zlength_cons; pose proof (Zlength_nonneg bs); lia).
  pose proof (read_amount_positive (action n (reads s)) n (b :: bs) Hn Hlen). lia.
Qed.

Lemma read_error_shape n s : 0 <= n -> read_ret (read_n n s) < 0 ->
  read_ret (read_n n s) = -1 /\ read_bytes (read_n n s) = [] /\
  unread (read_world (read_n n s)) = unread s /\
  read_errno (read_n n s) = - action n (reads s) /\ action n (reads s) < 0.
Proof.
  intro Hn. unfold read_n. destruct (action n (reads s) <? 0) eqn:E; simpl; intro H.
  - apply Z.ltb_lt in E. repeat split; auto.
  - pose proof (read_amount_bounds (action n (reads s)) n (unread s) Hn). lia.
Qed.

Lemma read_error_errno n s : 0 <= n -> valid_world s -> read_ret (read_n n s) < 0 ->
  1 <= read_errno (read_n n s) <= Int.max_signed.
Proof.
  intros Hn [Hr _] H. destruct (read_error_shape n s Hn H) as (_ & _ & _ & He & Hneg).
  rewrite He. unfold action in *. destruct (reads s) as [|q rest]; simpl in *; [lia |].
  inversion Hr; subst. lia.
Qed.

Lemma read_valid n s : valid_world s -> valid_world (read_world (read_n n s)).
Proof.
  intros [Hr Hw]. unfold valid_world, valid_reads, valid_writes in *.
  unfold read_n; destruct (action n (reads s) <? 0); simpl; split; auto using RP.valid_tail.
Qed.

Lemma write_ret_bounds bs s : -1 <= write_ret (write_n bs s) <= Zlength bs.
Proof.
  pose proof (Zlength_nonneg bs) as Hlen. unfold write_n.
  destruct (action (Zlength bs) (writes s) <? 0) eqn:E; simpl; [lia |].
  apply Z.ltb_ge in E. pose proof (RP.min_bounds (action (Zlength bs) (writes s)) (Zlength bs) E Hlen); lia.
Qed.

Lemma write_frame bs s :
  delivered (write_world (write_n bs s)) = delivered s ++ write_bytes (write_n bs s) /\
  unread (write_world (write_n bs s)) = unread s /\
  in_fd (write_world (write_n bs s)) = in_fd s /\
  out_fd (write_world (write_n bs s)) = out_fd s /\
  diagnostics (write_world (write_n bs s)) = diagnostics s /\
  reads (write_world (write_n bs s)) = reads s /\
  writes (write_world (write_n bs s)) = tl (writes s).
Proof. unfold write_n; destruct (action (Zlength bs) (writes s) <? 0); simpl; repeat split; reflexivity. Qed.

Lemma write_success_prefix bs s : 0 <= write_ret (write_n bs s) ->
  write_bytes (write_n bs s) = prefix (write_ret (write_n bs s)) bs /\
  Zlength (write_bytes (write_n bs s)) = write_ret (write_n bs s).
Proof.
  unfold write_n. destruct (action (Zlength bs) (writes s) <? 0) eqn:E; simpl; intro Hr; [lia |].
  split; [reflexivity |]. apply RP.prefix_length. apply Z.ltb_ge in E.
  pose proof (Zlength_nonneg bs) as Hlen.
  pose proof (RP.min_bounds (action (Zlength bs) (writes s)) (Zlength bs) E Hlen); lia.
Qed.

Lemma write_error_shape bs s : write_ret (write_n bs s) < 0 ->
  write_ret (write_n bs s) = -1 /\ write_bytes (write_n bs s) = [] /\
  write_errno (write_n bs s) = - action (Zlength bs) (writes s) /\ action (Zlength bs) (writes s) < 0.
Proof.
  unfold write_n. destruct (action (Zlength bs) (writes s) <? 0) eqn:E; simpl; intro H.
  - apply Z.ltb_lt in E; repeat split; auto.
  - apply Z.ltb_ge in E. pose proof (Zlength_nonneg bs).
    pose proof (RP.min_bounds (action (Zlength bs) (writes s)) (Zlength bs) E ltac:(lia)); lia.
Qed.

Lemma write_error_errno bs s : valid_world s -> write_ret (write_n bs s) < 0 ->
  1 <= write_errno (write_n bs s) <= Int.max_signed.
Proof.
  intros [_ Hw] H. destruct (write_error_shape bs s H) as (_ & _ & He & Hneg).
  pose proof (Zlength_nonneg bs) as Hlen.
  rewrite He. unfold action in *. destruct (writes s) as [|q rest]; simpl in *; [lia |].
  inversion Hw; subst. lia.
Qed.

Lemma write_valid bs s : valid_world s -> valid_world (write_world (write_n bs s)).
Proof.
  intros [Hr Hw]. unfold valid_world, valid_reads, valid_writes in *.
  unfold write_n; destruct (action (Zlength bs) (writes s) <? 0); simpl; split; auto using RP.valid_tail.
Qed.

(* ---- gnulib safe_read / safe_write (count <= SYS_BUFSIZE_MAX) ----
   Under that count bound the source's EINVAL shrink branch
   (errno == EINVAL && SYS_BUFSIZE_MAX < count) is never taken, so a non-EINTR
   failure returns immediately. e is the errno cell after the call: fixed on
   failure, arbitrary (unchanged by the wrapper itself) on success. *)

Inductive SafeRead (n : Z) : world -> Z -> Z -> list byte -> world -> Prop :=
| sr_done : forall s e, 0 <= read_ret (read_n n s) ->
    SafeRead n s (read_ret (read_n n s)) e (read_bytes (read_n n s)) (read_world (read_n n s))
| sr_eintr : forall s r e bs t,
    read_ret (read_n n s) < 0 -> read_errno (read_n n s) = EINTR ->
    SafeRead n (read_world (read_n n s)) r e bs t -> SafeRead n s r e bs t
| sr_fail : forall s, read_ret (read_n n s) < 0 -> read_errno (read_n n s) <> EINTR ->
    SafeRead n s (-1) (read_errno (read_n n s)) [] (read_world (read_n n s)).

Inductive SafeWrite (bs : list byte) : world -> Z -> Z -> list byte -> world -> Prop :=
| sw_done : forall s e, 0 <= write_ret (write_n bs s) ->
    SafeWrite bs s (write_ret (write_n bs s)) e (write_bytes (write_n bs s)) (write_world (write_n bs s))
| sw_eintr : forall s r e out t,
    write_ret (write_n bs s) < 0 -> write_errno (write_n bs s) = EINTR ->
    SafeWrite bs (write_world (write_n bs s)) r e out t -> SafeWrite bs s r e out t
| sw_fail : forall s, write_ret (write_n bs s) < 0 -> write_errno (write_n bs s) <> EINTR ->
    SafeWrite bs s (-1) (write_errno (write_n bs s)) [] (write_world (write_n bs s)).

(* gnulib full_write: FullWrite bs s e0 total e t : request bs from world s with
   errno e0 on entry; total bytes transferred, errno e and world t on exit. *)
Inductive FullWrite : list byte -> world -> Z -> Z -> Z -> world -> Prop :=
| fw_nil : forall s e0, FullWrite [] s e0 0 e0 s
| fw_err : forall bs s e0 e t, bs <> [] -> SafeWrite bs s (-1) e [] t -> FullWrite bs s e0 0 e t
| fw_zero : forall bs s e0 e t, bs <> [] -> SafeWrite bs s 0 e [] t -> FullWrite bs s e0 0 ENOSPC t
| fw_step : forall bs s e0 k e1 out t total e t', bs <> [] ->
    SafeWrite bs s k e1 out t -> 0 < k ->
    FullWrite (suffix k bs) t e1 total e t' -> FullWrite bs s e0 (k + total) e t'.

(* coreutils simple_cat with buffer size n: loop-head states, then outcomes. *)
Inductive CatLoop (n : Z) (s : world) (e0 : Z) : world -> Z -> Prop :=
| cl_start : CatLoop n s e0 s e0
| cl_chunk : forall t e r e1 bs t1 e2 t2,
    CatLoop n s e0 t e -> SafeRead n t r e1 bs t1 -> 0 < r ->
    FullWrite bs t1 e1 r e2 t2 -> CatLoop n s e0 t2 e2.

Inductive CatOutcome (n : Z) (s : world) (e0 : Z) : bool -> world -> Z -> Prop :=
| co_eof : forall t e e1 bs t1,
    CatLoop n s e0 t e -> SafeRead n t 0 e1 bs t1 -> CatOutcome n s e0 true t1 e1
| co_error : forall t e e1 bs t1,
    CatLoop n s e0 t e -> SafeRead n t (-1) e1 bs t1 ->
    CatOutcome n s e0 false (report e1 t1) e1.

(* ---- wrapper-level facts ---- *)

Lemma SafeRead_ret_bounds n s r e bs t : 0 <= n -> SafeRead n s r e bs t -> -1 <= r <= n.
Proof.
  intros Hn H. induction H; [apply read_ret_bounds; auto | auto | lia].
Qed.

Lemma SafeRead_length n s r e bs t : 0 <= n -> SafeRead n s r e bs t -> 0 <= r -> Zlength bs = r.
Proof.
  intros Hn H. induction H; intro Hr; [apply read_success_length; auto | auto | lia].
Qed.

Lemma SafeRead_conservation n s r e bs t : 0 <= n -> SafeRead n s r e bs t ->
  bs ++ unread t = unread s /\ delivered t = delivered s /\
  in_fd t = in_fd s /\ out_fd t = out_fd s /\ diagnostics t = diagnostics s /\ writes t = writes s.
Proof.
  intros Hn H. induction H.
  - pose proof (read_conservation n s Hn). pose proof (read_frame n s). crush.
  - destruct (read_error_shape n s Hn ltac:(assumption)) as (_ & _ & Hu & _).
    pose proof (read_frame n s). crush.
  - destruct (read_error_shape n s Hn ltac:(assumption)) as (_ & _ & Hu & _).
    pose proof (read_frame n s). simpl. crush.
Qed.

Lemma SafeRead_valid n s r e bs t : valid_world s -> SafeRead n s r e bs t -> valid_world t.
Proof. intros Hv H. induction H; auto using read_valid. Qed.

Lemma SafeRead_zero n s r e bs t : 0 < n -> SafeRead n s r e bs t -> r = 0 -> unread s = [] /\ bs = [].
Proof.
  intros Hn H. induction H; intro Hr.
  - split; [apply read_zero_only_empty with n; auto |].
    apply Zlength_nil_inv. rewrite read_success_length by lia. exact Hr.
  - destruct (IHSafeRead Hr) as [Hu Hb]. split; auto.
    destruct (read_error_shape n s ltac:(lia) ltac:(assumption)) as (_ & _ & Hu' & _). congruence.
  - lia.
Qed.

Lemma SafeRead_fail n s r e bs t : 0 <= n -> valid_world s -> SafeRead n s r e bs t -> r < 0 ->
  r = -1 /\ bs = [] /\ e <> EINTR /\ 1 <= e <= Int.max_signed.
Proof.
  intros Hn Hv H. induction H; intro Hr.
  - lia.
  - apply IHSafeRead; [apply read_valid; auto | auto].
  - pose proof (read_error_errno n s Hn Hv ltac:(assumption)) as Hrng.
    repeat split; auto; lia.
Qed.

Lemma SafeWrite_ret_bounds bs s r e out t : SafeWrite bs s r e out t -> -1 <= r <= Zlength bs.
Proof.
  intro H. pose proof (Zlength_nonneg bs).
  induction H; [apply write_ret_bounds | auto | lia].
Qed.

Lemma SafeWrite_effect bs s r e out t : SafeWrite bs s r e out t ->
  delivered t = delivered s ++ out /\ (0 <= r -> out = prefix r bs /\ Zlength out = r) /\
  (r < 0 -> out = []) /\
  unread t = unread s /\ in_fd t = in_fd s /\ out_fd t = out_fd s /\ diagnostics t = diagnostics s /\
  reads t = reads s.
Proof.
  intro H. induction H.
  - pose proof (write_frame bs s) as Hf. pose proof (write_success_prefix bs s H). crush.
  - destruct (write_error_shape bs s ltac:(assumption)) as (_ & Hb & _).
    pose proof (write_frame bs s) as Hf. rewrite Hb, app_nil_r in Hf. crush.
  - destruct (write_error_shape bs s ltac:(assumption)) as (_ & Hb & _).
    pose proof (write_frame bs s) as Hf. rewrite Hb, app_nil_r in Hf. rewrite app_nil_r. crush.
Qed.

Lemma SafeWrite_valid bs s r e out t : valid_world s -> SafeWrite bs s r e out t -> valid_world t.
Proof. intros Hv H. induction H; auto using write_valid. Qed.

Lemma SafeWrite_fail bs s r e out t : valid_world s -> SafeWrite bs s r e out t -> r < 0 ->
  r = -1 /\ out = [] /\ e <> EINTR /\ 1 <= e <= Int.max_signed.
Proof.
  intros Hv H. induction H; intro Hr.
  - lia.
  - apply IHSafeWrite; [apply write_valid; auto | auto].
  - pose proof (write_error_errno bs s Hv ltac:(assumption)) as Hrng.
    repeat split; auto; lia.
Qed.

Lemma suffix_suffix k j bs : 0 <= k -> 0 <= j -> k + j <= Zlength bs ->
  suffix j (suffix k bs) = suffix (k + j) bs.
Proof.
  intros Hk Hj Hkj. unfold RP.suffix.
  rewrite Zlength_sublist by lia. rewrite sublist_sublist by lia.
  f_equal; lia.
Qed.

Lemma prefix_app_suffix k j bs : 0 <= k -> 0 <= j -> k + j <= Zlength bs ->
  prefix k bs ++ prefix j (suffix k bs) = prefix (k + j) bs.
Proof.
  intros Hk Hj Hkj. unfold RP.prefix, RP.suffix.
  rewrite sublist_sublist by lia.
  replace (0 + k) with k by lia. replace (j + k) with (k + j) by lia.
  apply sublist_rejoin; lia.
Qed.

Lemma FullWrite_total_bounds bs s e0 total e t : FullWrite bs s e0 total e t -> 0 <= total <= Zlength bs.
Proof.
  intro H. induction H.
  - rewrite Zlength_nil; lia.
  - pose proof (Zlength_nonneg bs); lia.
  - pose proof (Zlength_nonneg bs); lia.
  - pose proof (SafeWrite_ret_bounds _ _ _ _ _ _ H0).
    unfold RP.suffix in IHFullWrite. rewrite Zlength_sublist in IHFullWrite by lia. lia.
Qed.

Lemma FullWrite_effect bs s e0 total e t : FullWrite bs s e0 total e t ->
  delivered t = delivered s ++ prefix total bs /\
  unread t = unread s /\ in_fd t = in_fd s /\ out_fd t = out_fd s /\ diagnostics t = diagnostics s /\
  reads t = reads s.
Proof.
  intro H. induction H.
  - unfold RP.prefix. rewrite sublist_nil_gen by lia. rewrite app_nil_r. crush.
  - destruct (SafeWrite_effect _ _ _ _ _ _ H0) as (Hd & _ & _ & Hu & Hi & Ho & Hg & Hr).
    unfold RP.prefix. rewrite sublist_nil_gen by lia. rewrite ?app_nil_r in *. crush.
  - destruct (SafeWrite_effect _ _ _ _ _ _ H0) as (Hd & _ & _ & Hu & Hi & Ho & Hg & Hr).
    unfold RP.prefix. rewrite sublist_nil_gen by lia. rewrite ?app_nil_r in *. crush.
  - destruct (SafeWrite_effect _ _ _ _ _ _ H0) as (Hd & Hp & _ & Hu & Hi & Ho & Hg & Hr).
    destruct (Hp ltac:(lia)) as [Hout _].
    pose proof (SafeWrite_ret_bounds _ _ _ _ _ _ H0) as Hk.
    destruct IHFullWrite as (Hd' & Hu' & Hi' & Ho' & Hg' & Hr').
    pose proof (FullWrite_total_bounds _ _ _ _ _ _ H2) as Ht.
    unfold RP.suffix in Ht. rewrite Zlength_sublist in Ht by lia.
    split; [| crush].
    rewrite Hd', Hd, Hout, <- app_assoc. f_equal.
    apply prefix_app_suffix; lia.
Qed.

Lemma FullWrite_complete bs s e0 e t : FullWrite bs s e0 (Zlength bs) e t ->
  delivered t = delivered s ++ bs.
Proof.
  intro H. destruct (FullWrite_effect _ _ _ _ _ _ H) as (Hd & _).
  rewrite Hd. f_equal. unfold RP.prefix. apply sublist_same; auto.
Qed.

Lemma FullWrite_valid bs s e0 total e t : valid_world s -> FullWrite bs s e0 total e t -> valid_world t.
Proof. intros Hv H. induction H; eauto using SafeWrite_valid. Qed.

(* ---- simple_cat consequences ---- *)

Lemma CatLoop_conservation n s e0 t e : 0 < n -> CatLoop n s e0 t e ->
  exists extra, delivered t = delivered s ++ extra /\ extra ++ unread t = unread s /\
  in_fd t = in_fd s /\ out_fd t = out_fd s /\ diagnostics t = diagnostics s.
Proof.
  intros Hn H. induction H.
  - exists []. rewrite app_nil_r. crush.
  - destruct IHCatLoop as (extra & Hd & Hu & Hi & Ho & Hg).
    destruct (SafeRead_conservation n t r e1 bs t1 ltac:(lia) H0) as (Hb & Hd1 & Hi1 & Ho1 & Hg1 & _).
    pose proof (SafeRead_length n t r e1 bs t1 ltac:(lia) H0 ltac:(lia)) as Hlen.
    rewrite <- Hlen in H2.
    pose proof (FullWrite_complete _ _ _ _ _ H2) as Hd2.
    destruct (FullWrite_effect _ _ _ _ _ _ H2) as (_ & Hu2 & Hi2 & Ho2 & Hg2 & _).
    exists (extra ++ bs). repeat split; try congruence.
    + rewrite Hd2, Hd1, Hd, app_assoc. reflexivity.
    + rewrite Hu2, <- app_assoc, Hb. exact Hu.
Qed.

Lemma CatLoop_valid n s e0 t e : valid_world s -> CatLoop n s e0 t e -> valid_world t.
Proof. intros Hv H. induction H; eauto using SafeRead_valid, FullWrite_valid. Qed.

Lemma CatOutcome_inv n s e0 b t e : CatOutcome n s e0 b t e ->
  exists t0 e1 r bs t1, CatLoop n s e0 t0 e1 /\ SafeRead n t0 r e bs t1 /\
    ((b = true /\ r = 0 /\ t = t1) \/ (b = false /\ r = -1 /\ t = report e t1)).
Proof.
  intro H. destruct H; do 5 eexists; (split; [eassumption | split; [eassumption |]]);
    [left | right]; repeat split; reflexivity.
Qed.

Theorem cat_true_copies_all n s e0 t e : 0 < n -> CatOutcome n s e0 true t e ->
  unread t = [] /\ delivered t = delivered s ++ unread s /\ diagnostics t = diagnostics s.
Proof.
  intros Hn H.
  destruct (CatOutcome_inv _ _ _ _ _ _ H) as (t0 & e1 & r & bs & t1 & Hl & Hr & [(_ & Hr0 & Ht) | (Hb & _ & _)]);
    [| discriminate].
  subst r t.
  destruct (CatLoop_conservation n s e0 t0 e1 Hn Hl) as (extra & Hd & Hu & _ & _ & Hg).
  destruct (SafeRead_zero n t0 0 e bs t1 Hn Hr eq_refl) as [Hempty Hbs].
  destruct (SafeRead_conservation n t0 0 e bs t1 ltac:(lia) Hr) as (Hb & Hd1 & _ & _ & Hg1 & _).
  subst bs. simpl in Hb. rewrite Hempty, app_nil_r in Hu.
  repeat split; congruence.
Qed.

Theorem cat_false_reports n s e0 t e : 0 < n -> valid_world s -> CatOutcome n s e0 false t e ->
  exists extra, delivered t = delivered s ++ extra /\ extra ++ unread t = unread s /\
  diagnostics t = diagnostics s ++ [e] /\ e <> EINTR /\ 1 <= e <= Int.max_signed.
Proof.
  intros Hn Hv H.
  destruct (CatOutcome_inv _ _ _ _ _ _ H) as (t0 & e1 & r & bs & t1 & Hl & Hr & [(Hb & _ & _) | (_ & Hr1 & Ht)]);
    [discriminate |].
  subst r t.
  destruct (CatLoop_conservation n s e0 t0 e1 Hn Hl) as (extra & Hd & Hu & _ & _ & Hg).
  pose proof (CatLoop_valid n s e0 t0 e1 Hv Hl) as Hv0.
  destruct (SafeRead_fail n t0 (-1) e bs t1 ltac:(lia) Hv0 Hr ltac:(lia)) as (_ & Hbs & Hne & Hrng).
  destruct (SafeRead_conservation n t0 (-1) e bs t1 ltac:(lia) Hr) as (Hb & Hd1 & _ & _ & Hg1 & _).
  subst bs. simpl in Hb. destruct Hrng as [Hlo Hhi].
  exists extra. simpl. repeat split; try congruence; try lia; try (rewrite Hb; exact Hu).
Qed.

End IOW.
