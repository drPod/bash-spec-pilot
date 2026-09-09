(* Relations for the case-studies pair (coreutils head_bytes / wc_lines), built
   by reusing utility-reuse/coq/IOWorld.v's `world`, `SafeRead` and their
   lemmas UNCHANGED (Require Import only; nothing here edits or re-proves
   anything in that file). Pure mathematics only, as IOWorld.v itself is.

   Revision history (see RESULTS.md):
   - case-studies4 (2026-09-07): first version; `XWrite` was built on
     `IOW.FullWrite`, i.e. it modeled buffered `fwrite(stdout)` as a loop of
     write(2) syscalls that consume the `writes` quota schedule and bump
     `write_calls`. `wc_lines` had only the short-line branch (`WcLinesShort`
     with a per-block `dense` hypothesis).
   - case-proofs-6 (2026-09-08): `XWrite` re-modeled as an explicit stdio
     boundary (`stdout_put`, below); `wc_lines` relation now covers the whole
     function (both counting branches; the branch choice is not observable).
     Functional consequence theorems added for both utilities. *)
From Coq Require Import List ZArith Lia Bool.
From compcert Require Import Integers.
Require Import VST.zlist.sublist.
Require Import IOWorld.
Import ListNotations.
Import IOW.
Local Open Scope Z_scope.

(* ---- xwrite_stdout (head.c:176-189): the stdio trust boundary.

   Source:  if (n_bytes > 0 && fwrite (buffer, 1, n_bytes, stdout) < n_bytes)
              { clearerr (stdout); fpurge (stdout); error (EXIT_FAILURE, ...); }

   fwrite hands the bytes to the stdout FILE stream; whether/when they reach
   file descriptor 1 (buffer flush, close_stdout at exit) is outside this
   function. So the ONLY thing a caller may rely on when xwrite_stdout returns
   is: the n_bytes bytes were accepted by the stream (C11 7.21.8.2: fwrite
   returns fewer than n only on a write error, and the source turns that case
   into a non-returning exit). We therefore model `delivered` for head_bytes
   as "bytes accepted by the stdout stream", extended by `stdout_put`, which
   touches no syscall schedule (`reads`/`writes`), no call counter and no
   diagnostic. errno after a successful fwrite is unconstrained (POSIX allows
   library calls to modify errno on success; the source never reads it here).
   n_bytes = 0 is a real source branch that never calls fwrite: world and
   errno unchanged.

   This is a declared trust-boundary contract for libc stdio, NOT a body proof
   of xwrite_stdout/fwrite (same status as utility-reuse's assumed
   write_error/error contracts). It deliberately does not reuse FullWrite:
   claiming that fwrite performs full_write's write(2) loop at the call site
   would misrepresent buffered stdio. *)
Definition stdout_put (s : world) (bs : list byte) : world :=
  World (in_fd s) (out_fd s) (unread s) (delivered s ++ bs) (reads s) (writes s)
    (read_calls s) (write_calls s) (diagnostics s).

Inductive XWrite (bs : list byte) (s : world) (e : Z) : world -> Z -> Prop :=
| xw_zero : bs = [] -> XWrite bs s e s e
| xw_put : forall e', bs <> [] -> XWrite bs s e (stdout_put s bs) e'.

Lemma XWrite_effect bs s e t e' : XWrite bs s e t e' ->
  delivered t = delivered s ++ bs /\ unread t = unread s /\
  in_fd t = in_fd s /\ out_fd t = out_fd s /\ diagnostics t = diagnostics s /\
  reads t = reads s /\ writes t = writes s.
Proof.
  intro H. destruct H; subst; simpl; rewrite ?app_nil_r; auto 8.
Qed.

Lemma XWrite_valid bs s e t e' : valid_world s -> XWrite bs s e t e' -> valid_world t.
Proof. intros [Hr Hw] H. destruct H; subst; split; simpl; auto. Qed.

(* ---- head_bytes (head.c:774-797): bounded remaining-count read/write loop.
   `bufsize` is the fixed local buffer size (8192, the BUFSIZ adapter
   constant); `N` is the initial `bytes_to_write`. Reuses SafeRead unchanged;
   each successful chunk goes through XWrite above. Structured as a growing
   left-recursive "loop-head states" relation (HeadLoop) plus a terminal step
   (HeadOutcome), the same two-tier shape as utility-reuse's CatLoop/
   CatOutcome, because it is exactly what a VST loop invariant needs. *)
Inductive HeadLoop (bufsize N : Z) (s : world) (e0 : Z) : world -> Z -> Z -> Prop :=
| hl_start : HeadLoop bufsize N s e0 s 0 e0
| hl_chunk : forall t consumed e r e1 bs t1 e2 t2,
    HeadLoop bufsize N s e0 t consumed e -> consumed < N ->
    SafeRead (Z.min bufsize (N - consumed)) t r e1 bs t1 -> 0 < r ->
    XWrite bs t1 e1 t2 e2 ->
    HeadLoop bufsize N s e0 t2 (consumed + r) e2.

Inductive HeadOutcome (bufsize N : Z) (s : world) (e0 : Z) : bool -> world -> Z -> Prop :=
| ho_done : forall t e, HeadLoop bufsize N s e0 t N e -> HeadOutcome bufsize N s e0 true t e
| ho_eof : forall t consumed e r e1 bs t1, consumed < N -> HeadLoop bufsize N s e0 t consumed e ->
    SafeRead (Z.min bufsize (N - consumed)) t r e1 bs t1 -> r = 0 ->
    HeadOutcome bufsize N s e0 true t1 e1
| ho_err : forall t consumed e r e1 bs t1, consumed < N -> HeadLoop bufsize N s e0 t consumed e ->
    SafeRead (Z.min bufsize (N - consumed)) t r e1 bs t1 -> r < 0 ->
    HeadOutcome bufsize N s e0 false (report e1 t1) e1.

Lemma HeadLoop_bounds bufsize N s e0 t consumed e : 0 < bufsize -> 0 <= N ->
  HeadLoop bufsize N s e0 t consumed e -> 0 <= consumed <= N.
Proof.
  intros Hbuf HN H. induction H; [lia |].
  assert (Hmn : 0 < Z.min bufsize (N - consumed)) by (apply Z.min_glb_lt; lia).
  pose proof (SafeRead_ret_bounds _ _ _ _ _ _ (Z.lt_le_incl _ _ Hmn) H1) as Hb; lia.
Qed.

Lemma HeadLoop_valid bufsize N s e0 t consumed e : valid_world s ->
  HeadLoop bufsize N s e0 t consumed e -> valid_world t.
Proof. intros Hv H. induction H; eauto using SafeRead_valid, XWrite_valid. Qed.

Lemma HeadLoop_conservation bufsize N s e0 t consumed e : 0 < bufsize -> 0 <= N ->
  HeadLoop bufsize N s e0 t consumed e ->
  exists extra, delivered t = delivered s ++ extra /\ extra ++ unread t = unread s /\
    Zlength extra = consumed /\ in_fd t = in_fd s /\ out_fd t = out_fd s /\ diagnostics t = diagnostics s.
Proof.
  intros Hbuf HN H. induction H.
  - exists []. rewrite ?app_nil_r, Zlength_nil. auto 8.
  - assert (Hmn : 0 < Z.min bufsize (N - consumed)) by (apply Z.min_glb_lt; lia).
    assert (Hmn' : 0 <= Z.min bufsize (N - consumed)) by lia.
    pose proof (SafeRead_length _ _ _ _ _ _ Hmn' H1 ltac:(lia)) as Hlen.
    destruct (SafeRead_conservation _ _ _ _ _ _ Hmn' H1) as (Hb0 & Hd0 & Hi0 & Ho0 & Hg0 & _).
    destruct (XWrite_effect _ _ _ _ _ H3) as (Hd1 & Hu1 & Hi1 & Ho1 & Hg1 & _).
    destruct IHHeadLoop as (extra & Hd2 & Hu2 & Hlen2 & Hi2 & Ho2 & Hg2).
    exists (extra ++ bs). repeat split.
    + rewrite Hd1, Hd0, Hd2, app_assoc. reflexivity.
    + rewrite <- app_assoc, Hu1, Hb0. exact Hu2.
    + rewrite Zlength_app. lia.
    + congruence.
    + congruence.
    + congruence.
Qed.

(* Source-preserving functional summary of head_bytes (what `head -c N` does
   to the streams when the function returns): on `true`, stdout received a
   prefix of the input of length N, or the whole input if it was shorter
   (EOF is success, nothing more is read); no diagnostic. *)
Theorem head_true_prefix bufsize N s e0 t e : 0 < bufsize -> 0 <= N ->
  HeadOutcome bufsize N s e0 true t e ->
  exists extra, delivered t = delivered s ++ extra /\ extra ++ unread t = unread s /\
    Zlength extra <= N /\ (Zlength extra = N \/ unread t = []) /\
    diagnostics t = diagnostics s /\ in_fd t = in_fd s /\ out_fd t = out_fd s.
Proof.
  intros Hbuf HN H. remember true as b eqn:Eb in H.
  destruct H as [t0 e1 Hloop | t0 consumed e1 r e2 bs t1 Hlt Hloop Hsr Hr | t0 consumed e1 r e2 bs t1 Hlt Hloop Hsr Hr];
    [| | discriminate]; clear Eb.
  - destruct (HeadLoop_conservation _ _ _ _ _ _ _ Hbuf HN Hloop) as (extra & Hd & Hu & Hlen & Hi & Ho & Hg).
    exists extra. repeat split; auto; lia.
  - subst r.
    destruct (HeadLoop_conservation _ _ _ _ _ _ _ Hbuf HN Hloop) as (extra & Hd & Hu & Hlen & Hi & Ho & Hg).
    assert (Hmn : 0 < Z.min bufsize (N - consumed)) by (apply Z.min_glb_lt; lia).
    destruct (SafeRead_zero _ _ _ _ _ _ Hmn Hsr eq_refl) as [Hempty Hbs].
    destruct (SafeRead_conservation _ _ _ _ _ _ (Z.lt_le_incl _ _ Hmn) Hsr) as (Hb & Hd1 & Hi1 & Ho1 & Hg1 & _).
    subst bs. simpl in Hb.
    exists extra. repeat split; try congruence; try lia.
    all: first [ rewrite Hb; exact Hu | right; congruence ].
Qed.

(* On `false`, a read error stopped the copy: what was read so far (fewer than
   N bytes) was accepted by stdout, the rest is unread, and exactly one
   diagnostic with a genuine errno was recorded. *)
Theorem head_false_reports bufsize N s e0 t e : 0 < bufsize -> 0 <= N -> valid_world s ->
  HeadOutcome bufsize N s e0 false t e ->
  exists extra, delivered t = delivered s ++ extra /\ extra ++ unread t = unread s /\
    Zlength extra < N /\ diagnostics t = diagnostics s ++ [e] /\ e <> EINTR /\ 1 <= e <= Int.max_signed.
Proof.
  intros Hbuf HN Hv H. remember false as b eqn:Eb in H.
  destruct H as [t0 e1 Hloop | t0 consumed e1 r e2 bs t1 Hlt Hloop Hsr Hr | t0 consumed e1 r e2 bs t1 Hlt Hloop Hsr Hr];
    [discriminate | discriminate |]; clear Eb.
  destruct (HeadLoop_conservation _ _ _ _ _ _ _ Hbuf HN Hloop) as (extra & Hd & Hu & Hlen & Hi & Ho & Hg).
  pose proof (HeadLoop_valid _ _ _ _ _ _ _ Hv Hloop) as Hv0.
  assert (Hmn : 0 <= Z.min bufsize (N - consumed)) by (apply Z.min_glb; lia).
  destruct (SafeRead_fail _ _ _ _ _ _ Hmn Hv0 Hsr Hr) as (_ & Hbs & Hne & [Hlo Hhi]).
  destruct (SafeRead_conservation _ _ _ _ _ _ Hmn Hsr) as (Hb & Hd1 & Hi1 & Ho1 & Hg1 & _).
  subst bs. simpl in Hb.
  exists extra. simpl. repeat split; try congruence; try lia.
  all: try (rewrite Hb; exact Hu).
Qed.

(* ---- wc_lines (wc.c:266-330), whole function.
   The source keeps `lines` and `bytes` as uintmax_t and adds per block;
   here they are the mathematical totals. The C out-parameters receive
   `Int64.repr` of these totals (see CaseSpecs.wc_lines_spec), which IS the
   source's modular uintmax_t behaviour: no "counts never overflow"
   precondition is assumed anywhere.

   Two counting code paths exist in the source: the byte loop
   (`lines += *p++ == '\n'`) and the sentinel + rawmemchr loop, selected per
   block by `long_lines`, which the previous block's density sets
   (`lines - plines <= bytes_read / 15`). Both paths add exactly the number
   of '\n' bytes in the block, so the branch choice is not observable and the
   relation does not track it; the body proof (WcLinesBody.v) covers BOTH
   paths for every block. `long_after` records the source's density test for
   documentation and for the differential oracle. *)
Definition is_nl (b : byte) : bool := Byte.eq b (Byte.repr 10).
Definition count_nl (bs : list byte) : Z := Zlength (filter is_nl bs).

Lemma count_nl_app xs ys : count_nl (xs ++ ys) = count_nl xs + count_nl ys.
Proof. unfold count_nl. rewrite filter_app, Zlength_app. reflexivity. Qed.

Lemma count_nl_nonneg bs : 0 <= count_nl bs.
Proof. apply Zlength_nonneg. Qed.

Lemma count_nl_bound bs : count_nl bs <= Zlength bs.
Proof.
  unfold count_nl. induction bs as [|b bs' IH].
  - simpl. rewrite Zlength_nil. lia.
  - simpl. rewrite Zlength_cons. destruct (is_nl b); simpl; rewrite ?Zlength_cons; lia.
Qed.

Lemma count_nl_nil : count_nl [] = 0.
Proof. reflexivity. Qed.

Lemma count_nl_snoc bs b : count_nl (bs ++ [b]) = count_nl bs + (if is_nl b then 1 else 0).
Proof.
  rewrite count_nl_app. f_equal. unfold count_nl. simpl filter.
  destruct (is_nl b); [rewrite Zlength_cons |]; rewrite Zlength_nil; lia.
Qed.

(* the source's per-block density test (`lines - plines <= bytes_read / 15`) *)
Definition long_after (bs : list byte) : bool := count_nl bs <=? Zlength bs / 15.

Inductive WcLoop (n : Z) (s : world) : world -> Z -> Z -> Prop :=
| wl_start : WcLoop n s s 0 0
| wl_step : forall t lines bytes r e bs t1,
    WcLoop n s t lines bytes -> SafeRead n t r e bs t1 -> 0 < r ->
    WcLoop n s t1 (lines + count_nl bs) (bytes + r).

Inductive WcLines (n : Z) (s : world) : bool -> world -> Z -> Z -> Prop :=
| wl_eof : forall t lines bytes r e bs t1,
    WcLoop n s t lines bytes -> SafeRead n t r e bs t1 -> r = 0 ->
    WcLines n s true t1 lines bytes
| wl_err : forall t lines bytes r e bs t1,
    WcLoop n s t lines bytes -> SafeRead n t r e bs t1 -> r < 0 ->
    WcLines n s false (report e t1) lines bytes.

Lemma WcLoop_conservation n s t lines bytes : 0 < n -> WcLoop n s t lines bytes ->
  exists consumed, consumed ++ unread t = unread s /\ lines = count_nl consumed /\
    bytes = Zlength consumed /\ delivered t = delivered s /\
    in_fd t = in_fd s /\ out_fd t = out_fd s /\ diagnostics t = diagnostics s.
Proof.
  intros Hn H. induction H.
  - exists []. simpl. rewrite count_nl_nil, Zlength_nil. auto 9.
  - destruct IHWcLoop as (consumed & Hu & Hl & Hb & Hd & Hi & Ho & Hg).
    destruct (SafeRead_conservation n t r e bs t1 ltac:(lia) H0) as (Hb1 & Hd1 & Hi1 & Ho1 & Hg1 & _).
    pose proof (SafeRead_length n t r e bs t1 ltac:(lia) H0 ltac:(lia)) as Hlen.
    exists (consumed ++ bs). repeat split; try congruence.
    + rewrite <- app_assoc, Hb1. exact Hu.
    + rewrite count_nl_app. lia.
    + rewrite Zlength_app. lia.
Qed.

Lemma WcLoop_valid n s t lines bytes : valid_world s -> WcLoop n s t lines bytes -> valid_world t.
Proof. intros Hv H. induction H; eauto using SafeRead_valid. Qed.

Lemma WcLoop_nonneg n s t lines bytes : 0 < n -> WcLoop n s t lines bytes -> 0 <= lines /\ 0 <= bytes.
Proof.
  intros Hn H. induction H; [lia |].
  pose proof (count_nl_nonneg bs). lia.
Qed.

(* Source-preserving functional summary of wc_lines: on `true` the whole
   input was consumed, `lines` is the number of '\n' bytes and `bytes` the
   number of bytes of the input; nothing is written, no diagnostic. *)
Theorem wc_true_counts n s t lines bytes : 0 < n -> WcLines n s true t lines bytes ->
  unread t = [] /\ lines = count_nl (unread s) /\ bytes = Zlength (unread s) /\
  delivered t = delivered s /\ diagnostics t = diagnostics s.
Proof.
  intros Hn H. remember true as b eqn:Eb in H.
  destruct H as [t0 lines0 bytes0 r e bs t1 Hloop Hsr Hr | t0 lines0 bytes0 r e bs t1 Hloop Hsr Hr];
    [| discriminate]; clear Eb. subst r.
  destruct (WcLoop_conservation _ _ _ _ _ Hn Hloop) as (consumed & Hu & Hl & Hb & Hd & Hi & Ho & Hg).
  destruct (SafeRead_zero _ _ _ _ _ _ Hn Hsr eq_refl) as [Hempty Hbs].
  destruct (SafeRead_conservation _ _ _ _ _ _ (Z.lt_le_incl _ _ Hn) Hsr) as (Hb1 & Hd1 & _ & _ & Hg1 & _).
  subst bs. simpl in Hb1. rewrite Hempty, app_nil_r in Hu. subst consumed.
  repeat split; congruence.
Qed.

(* On `false` a read error stopped the count: the totals describe exactly the
   consumed prefix, and one diagnostic with a genuine errno was recorded. The
   C function returns before storing to the out-parameters in this case
   (CaseSpecs.wc_lines_spec leaves them uninitialized). *)
Theorem wc_false_reports n s t lines bytes : 0 < n -> valid_world s ->
  WcLines n s false t lines bytes ->
  exists consumed e, consumed ++ unread t = unread s /\ lines = count_nl consumed /\
    bytes = Zlength consumed /\ delivered t = delivered s /\
    diagnostics t = diagnostics s ++ [e] /\ e <> EINTR /\ 1 <= e <= Int.max_signed.
Proof.
  intros Hn Hv H. remember false as b eqn:Eb in H.
  destruct H as [t0 lines0 bytes0 r e bs t1 Hloop Hsr Hr | t0 lines0 bytes0 r e bs t1 Hloop Hsr Hr];
    [discriminate |]; clear Eb.
  destruct (WcLoop_conservation _ _ _ _ _ Hn Hloop) as (consumed & Hu & Hl & Hb & Hd & Hi & Ho & Hg).
  pose proof (WcLoop_valid _ _ _ _ _ Hv Hloop) as Hv0.
  destruct (SafeRead_fail _ _ _ _ _ _ (Z.lt_le_incl _ _ Hn) Hv0 Hsr Hr) as (_ & Hbs & Hne & [Hlo Hhi]).
  destruct (SafeRead_conservation _ _ _ _ _ _ (Z.lt_le_incl _ _ Hn) Hsr) as (Hb1 & Hd1 & _ & _ & Hg1 & _).
  subst bs. simpl in Hb1.
  exists consumed, e. simpl. repeat split; try congruence; try lia.
  all: try (rewrite Hb1; exact Hu).
Qed.
