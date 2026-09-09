(* Pipe (`|`) semantics over the ACTUAL relay contract's own read32/write_block
   primitives (Protocol.v, unchanged). This is a NEW file; Protocol.v, Reach.v,
   Conservation.v, ReachExamples.v and shell-bridge/{Shell,Parse,Lex,Bridge,
   Fixtures,RandomFixtures,ShellAudit}.v are frozen and not imported for
   modification, only for reuse.

   SCOPE, stated up front (see shell-expansion/README.md for the full
   discussion): a supported FRAGMENT, not Bash's process/pipe/fd model.

   - Finite buffer: the pipe channel `pw_buf` is a plain `list byte` capped at
     PIPE_CAP = 4 bytes. This is deliberately far smaller than POSIX PIPE_BUF
     (no claim about real pipe capacity is made); it is chosen so that a
     capacity-exhausted round is exercised by a short, vm_compute-checkable
     example. `pstep_fn_capacity`/`prun_capacity` below prove the bound holds
     at every step and every fuel value, not just in the examples.
   - Scheduling: `pstep_fn` is a single DETERMINISTIC small-step scheduler,
     not an arbitrary-interleaving relation. Priority order: (1) if the
     buffer is non-empty and the consumer has not halted, drain one
     consumer write_block call; (2) else if the producer has not halted,
     do one read32 call, or push its pending carry into the buffer (partial
     if the buffer has less room than the carry: backpressure, see below),
     or halt with the modelled SIGPIPE status if the consumer is already
     gone; (3) else if the buffer is empty and the producer has halted,
     the consumer sees EOF; (4) else no step (both sides halted or, if the
     producer halted but the buffer is non-empty, priority (1) already took
     it). This is ONE fair, "prefer draining the reader" schedule among the
     many a real kernel could choose; it is not claimed to be the only
     correct one, only a genuine byte-level interleaving.
   - Backpressure: the push step in case (2) is available only while
     `Zlength pw_buf < PIPE_CAP`; when the buffer is full, the scheduler's
     priority (1) forces a consumer drain before any further producer
     progress. No push step ever writes more than the room available: this
     is a structural fact (`push_take_bounds`), not a numeric side condition
     checked and discarded.
   - Partial write / retry: read32 (unchanged, up to 32 bytes per call) can
     return more bytes than the buffer currently has room for; only the
     bytes that fit are pushed, and the remainder is put back on the
     producer's own `unread` list (so it is read again, as new bytes, once
     room frees up). `total_bytes_step` accounts for every byte across every
     round, so nothing is silently created or dropped by this retry.
   - EOF: the producer's own read32 returning 0 is relay's own EOF
     convention (Reach.v `read_eof`), unchanged. The consumer reaches EOF
     (status 0) once the buffer it reads from is drained AND the producer
     has halted: exactly the condition under which a real `read()` on a
     pipe, after the write end has closed, returns 0.
   - SIGPIPE: MODELLED, not delivered. If the consumer has already halted
     (its read end is gone) and the producer still has queued bytes,
     `pstep_fn` halts the producer at status 141 (bash's 128+SIGPIPE
     convention) and records the queued bytes in `pw_prod_lost`. This is a
     deterministic step taken only when the modelled condition holds; no
     asynchronous signal, no interrupted instruction pointer.
   - pipefail: `pipeline_status` is a total function of both final statuses,
     matching bash's two-stage rule exactly (rightmost non-zero if
     `set -o pipefail`, else simply the rightmost). `pipe_prim` (Bridge2.v)
     hardwires pipefail OFF, bash's default.
   - What is NOT modelled: process creation/exec, real fds/dup2, the actual
     kernel pipe capacity or SIGPIPE delivery mechanism, more than two
     pipeline stages, `$PIPESTATUS`, and any pipeline stage other than the
     two `Relay`-shaped endpoints used in the composition examples. *)
From Coq Require Import List ZArith Lia Bool.
From compcert Require Import Integers.
Require Import VST.zlist.sublist.
Require Import Protocol.
Import ListNotations RelayProtocol.
Local Open Scope Z_scope.

Module ShellPipeline.

Definition PIPE_CAP : Z := 4.

Record pworld := PWorld {
  pw_producer    : world;
  pw_prod_carry  : list byte;
  pw_prod_status : option Z;
  pw_prod_lost   : list byte;
  pw_buf         : list byte;
  pw_consumer    : world;
  pw_cons_status : option Z;
  pw_cons_lost   : list byte
}.

Definition push_take (pw : pworld) : Z :=
  Z.min (PIPE_CAP - Zlength (pw_buf pw)) (Zlength (pw_prod_carry pw)).

Definition cons_take (pw : pworld) : Z :=
  Z.min 32 (Zlength (pw_buf pw)).

(* One step of the fixed scheduler described above. *)
Definition pstep_fn (pw : pworld) : option pworld :=
  if (negb (Zeq_bool (Zlength (pw_buf pw)) 0)) && (match pw_cons_status pw with None => true | _ => false end)
  then
    (* (1) drain the consumer *)
    let k := cons_take pw in
    match write_block (pw_consumer pw) (prefix k (pw_buf pw)) with
    | WriteResult r out s' =>
        if r <=? 0 then
          Some (PWorld (pw_producer pw) (pw_prod_carry pw) (pw_prod_status pw) (pw_prod_lost pw)
                  (suffix k (pw_buf pw)) s' (Some 2) (pw_cons_lost pw ++ prefix k (pw_buf pw)))
        else
          Some (PWorld (pw_producer pw) (pw_prod_carry pw) (pw_prod_status pw) (pw_prod_lost pw)
                  (suffix r (prefix k (pw_buf pw)) ++ suffix k (pw_buf pw))
                  s' (pw_cons_status pw) (pw_cons_lost pw))
    end
  else
    match pw_prod_status pw with
    | None =>
        match pw_prod_carry pw with
        | [] =>
            (* (2a) read one chunk from the producer's own stdin *)
            match read32 (pw_producer pw) with
            | ReadResult r bytes s' =>
                if r <? 0 then
                  Some (PWorld s' [] (Some 1) (pw_prod_lost pw) (pw_buf pw) (pw_consumer pw)
                          (pw_cons_status pw) (pw_cons_lost pw))
                else if Zeq_bool r 0 then
                  Some (PWorld s' [] (Some 0) (pw_prod_lost pw) (pw_buf pw) (pw_consumer pw)
                          (pw_cons_status pw) (pw_cons_lost pw))
                else
                  Some (PWorld s' bytes None (pw_prod_lost pw) (pw_buf pw) (pw_consumer pw)
                          (pw_cons_status pw) (pw_cons_lost pw))
            end
        | _ :: _ =>
            (* (2b)/(2c) push the pending carry, or SIGPIPE if the reader is gone *)
            match pw_cons_status pw with
            | Some _ =>
                Some (PWorld (pw_producer pw) [] (Some 141) (pw_prod_lost pw ++ pw_prod_carry pw)
                        (pw_buf pw) (pw_consumer pw) (pw_cons_status pw) (pw_cons_lost pw))
            | None =>
                let n := push_take pw in
                Some (PWorld
                        (World (suffix n (pw_prod_carry pw) ++ unread (pw_producer pw))
                          (delivered (pw_producer pw)) (reads (pw_producer pw)) (writes (pw_producer pw))
                          (read_calls (pw_producer pw)) (write_calls (pw_producer pw)))
                        [] None (pw_prod_lost pw)
                        (pw_buf pw ++ prefix n (pw_prod_carry pw))
                        (pw_consumer pw) (pw_cons_status pw) (pw_cons_lost pw))
            end
        end
    | Some _ =>
        (* (3) producer halted, buffer empty (else branch (1) would have fired) *)
        match pw_cons_status pw with
        | None =>
            Some (PWorld (pw_producer pw) (pw_prod_carry pw) (pw_prod_status pw) (pw_prod_lost pw)
                    [] (pw_consumer pw) (Some 0) (pw_cons_lost pw))
        | Some _ => None
        end
    end.

Fixpoint prun (fuel : nat) (pw : pworld) : pworld :=
  match fuel with
  | O => pw
  | S n => match pstep_fn pw with Some pw' => prun n pw' | None => pw end
  end.

Definition pipe_done (pw : pworld) : bool :=
  match pw_prod_status pw, pw_cons_status pw with
  | Some _, Some _ => true
  | _, _ => false
  end.

(* pipefail: a total function of both final statuses, matching bash exactly
   for a two-stage pipeline. `pipe_prim` (Bridge2.v) uses the `false` case
   (bash's default: pipefail OFF, the pipeline's status is the last stage's). *)
Definition pipeline_status (pipefail_on : bool) (left_status right_status : Z) : Z :=
  if pipefail_on then
    if negb (Zeq_bool right_status 0) then right_status
    else if negb (Zeq_bool left_status 0) then left_status else 0
  else right_status.

(* ---- The buffer never exceeds PIPE_CAP: genuine bounded buffering, not an
   unbounded/naive concatenation of the two sides' byte streams. ---- *)

Lemma push_take_room pw : push_take pw <= PIPE_CAP - Zlength (pw_buf pw).
Proof.
  unfold push_take. pose proof (Zlength_nonneg (pw_prod_carry pw)).
  destruct (Z.min_spec (PIPE_CAP - Zlength (pw_buf pw)) (Zlength (pw_prod_carry pw)))
    as [[Hlt Heq] | [Hge Heq]]; lia.
Qed.

Lemma push_take_nonneg pw : Zlength (pw_buf pw) <= PIPE_CAP -> 0 <= push_take pw.
Proof.
  intro Hcap. unfold push_take. pose proof (Zlength_nonneg (pw_prod_carry pw)).
  destruct (Z.min_spec (PIPE_CAP - Zlength (pw_buf pw)) (Zlength (pw_prod_carry pw)))
    as [[Hlt Heq] | [Hge Heq]]; lia.
Qed.

Lemma push_take_le_carry pw : push_take pw <= Zlength (pw_prod_carry pw).
Proof.
  unfold push_take.
  destruct (Z.min_spec (PIPE_CAP - Zlength (pw_buf pw)) (Zlength (pw_prod_carry pw)))
    as [[Hlt Heq] | [Hge Heq]]; lia.
Qed.

(* Extract the LENGTH of the `pw_buf` field from `Some (PWorld ...) = Some
   pw'` as a plain Z equation, so the rest of each case is closed by `lia`
   alone (no `rewrite` on list-valued hypotheses, which is fragile here
   because the other seven fields of the record are left as opaque terms). *)
Ltac buflen_eq H :=
  let H2 := fresh "H" in
  pose proof (f_equal (fun x => match x with
                                 | Some p => Zlength (pw_buf p)
                                 | None => 0
                                 end) H) as H2;
  cbn in H2; clear H; rename H2 into H.

Theorem pstep_fn_capacity pw pw' :
  Zlength (pw_buf pw) <= PIPE_CAP -> pstep_fn pw = Some pw' ->
  Zlength (pw_buf pw') <= PIPE_CAP.
Proof.
  intros Hcap H. unfold pstep_fn in H.
  destruct (negb (Zeq_bool (Zlength (pw_buf pw)) 0) &&
            match pw_cons_status pw with None => true | Some _ => false end) eqn:E1.
  - (* consumer drains: buffer only shrinks *)
    destruct (write_block (pw_consumer pw) (prefix (cons_take pw) (pw_buf pw)))
      as [r out s'] eqn:Ew.
    assert (Hk : 0 <= cons_take pw <= Zlength (pw_buf pw)).
    { unfold cons_take. pose proof (Zlength_nonneg (pw_buf pw)).
      destruct (Z.min_spec 32 (Zlength (pw_buf pw))) as [[Hl He] | [Hl He]]; lia. }
    destruct (r <=? 0) eqn:Er; buflen_eq H.
    + assert (Hlen : Zlength (suffix (cons_take pw) (pw_buf pw)) = Zlength (pw_buf pw) - cons_take pw).
      { unfold suffix. rewrite Zlength_sublist by lia. lia. }
      cbn in Hlen. lia.
    + assert (Hr : 0 <= r <= cons_take pw).
      { apply Z.leb_gt in Er.
        pose proof (write_ret_bounds (pw_consumer pw) (prefix (cons_take pw) (pw_buf pw))) as Hb.
        rewrite Ew in Hb. simpl in Hb.
        rewrite (prefix_length (cons_take pw) (pw_buf pw) Hk) in Hb. lia. }
      assert (Hk' : Zlength (prefix (cons_take pw) (pw_buf pw)) = cons_take pw)
        by (apply prefix_length; exact Hk).
      assert (Hlen : Zlength (suffix r (prefix (cons_take pw) (pw_buf pw)) ++ suffix (cons_take pw) (pw_buf pw))
                     = Zlength (pw_buf pw) - r).
      { rewrite Zlength_app. unfold suffix.
        rewrite Zlength_sublist by lia.
        rewrite Zlength_sublist by lia.
        lia. }
      cbn in Hlen. lia.
  - destruct (pw_prod_status pw) as [rc |] eqn:Eprod.
    + destruct (pw_cons_status pw) as [rc' |] eqn:Econs.
      * discriminate H.
      * buflen_eq H. rewrite <- H. apply Z.leb_le. vm_compute. reflexivity.
    + destruct (pw_prod_carry pw) as [| b cs] eqn:Ecarry.
      * destruct (read32 (pw_producer pw)) as [r bytes s'] eqn:Er.
        destruct (r <? 0) eqn:E2.
        { buflen_eq H; lia. }
        destruct (Zeq_bool r 0) eqn:E3; buflen_eq H; lia.
      * destruct (pw_cons_status pw) as [rc' |] eqn:Econs.
        { buflen_eq H; lia. }
        buflen_eq H.
        rewrite Zlength_app in H. pose proof (push_take_room pw) as Hr.
        pose proof (prefix_length (push_take pw) (pw_prod_carry pw)
          (conj (push_take_nonneg pw Hcap) (push_take_le_carry pw))) as Hlen.
        rewrite Ecarry in Hlen. cbn in Hlen. lia.
Qed.

Corollary prun_capacity fuel pw :
  Zlength (pw_buf pw) <= PIPE_CAP -> Zlength (pw_buf (prun fuel pw)) <= PIPE_CAP.
Proof.
  revert pw. induction fuel as [| n IH]; intros pw Hcap; simpl; [exact Hcap |].
  destruct (pstep_fn pw) as [pw' |] eqn:E; [| exact Hcap].
  apply IH. exact (pstep_fn_capacity pw pw' Hcap E).
Qed.

(* ---- Concrete traces: a real interleaving, real backpressure, real EOF,
   and a real modelled SIGPIPE, all checked by vm_compute against the
   scheduler above (not asserted). ---- *)

Definition demo_bytes := map Byte.repr [97; 98; 99; 100; 101; 102]. (* "abcdef" *)
Definition demo_producer0 := World demo_bytes [] [6] [] 0%nat 0%nat.
Definition demo_consumer0 := World [] [] [] [] 0%nat 0%nat.
Definition demo_pw0 := PWorld demo_producer0 [] None [] [] demo_consumer0 None [].

(* After exactly one read (6 bytes) and one push, only 4 of the 6 bytes
   (PIPE_CAP) have reached the buffer; the other 2 are held back on the
   producer's own input, not yet anywhere near the consumer. A naive
   "concatenate the two sides' byte streams" model has no such intermediate
   state: this is the buffer capacity actually constraining the trace. *)
Example demo_backpressure_after_two_steps :
  pw_buf (prun 2 demo_pw0) = map Byte.repr [97; 98; 99; 100] /\
  unread (pw_producer (prun 2 demo_pw0)) = map Byte.repr [101; 102] /\
  pw_prod_carry (prun 2 demo_pw0) = [].
Proof. vm_compute. repeat split; reflexivity. Qed.

(* Run to completion: clean EOF on both ends, every byte delivered in order,
   through a buffer that never held more than 4 of the 6 bytes at once. *)
Example demo_pipeline_success :
  pw_prod_status (prun 20 demo_pw0) = Some 0 /\
  pw_cons_status (prun 20 demo_pw0) = Some 0 /\
  pw_buf (prun 20 demo_pw0) = [] /\
  delivered (pw_consumer (prun 20 demo_pw0)) = demo_bytes.
Proof. vm_compute. repeat split; reflexivity. Qed.

(* The consumer's own downstream write fails immediately (modelling, e.g., a
   closed real fd beyond it): it halts at status 2 having lost the 4 bytes it
   had already popped from the pipe, and every later push finds the reader
   gone, so the producer halts at the modelled SIGPIPE status 141, losing the
   remaining 2 bytes. Every one of the original 6 bytes is accounted for
   between the two loss ledgers; none is silently dropped or duplicated. *)
Definition demo_consumer0_epipe := World [] [] [] [-1] 0%nat 0%nat.
Definition demo_pw0_epipe := PWorld demo_producer0 [] None [] [] demo_consumer0_epipe None [].

Example demo_sigpipe :
  pw_cons_status (prun 20 demo_pw0_epipe) = Some 2 /\
  pw_cons_lost (prun 20 demo_pw0_epipe) = map Byte.repr [97; 98; 99; 100] /\
  pw_prod_status (prun 20 demo_pw0_epipe) = Some 141 /\
  pw_prod_lost (prun 20 demo_pw0_epipe) = map Byte.repr [101; 102] /\
  delivered (pw_consumer (prun 20 demo_pw0_epipe)) = [] /\
  pw_buf (prun 20 demo_pw0_epipe) = [].
Proof. vm_compute. repeat split; reflexivity. Qed.

(* pipefail: OFF (bash's default, what `pipe_prim` in Bridge2.v uses) always
   reports the rightmost stage; ON reports the rightmost non-zero, or 0. *)
Example pipeline_status_examples :
  pipeline_status false 1 0 = 0 /\ pipeline_status false 0 2 = 2 /\
  pipeline_status true 1 0 = 1 /\ pipeline_status true 1 2 = 2 /\
  pipeline_status true 0 0 = 0.
Proof. vm_compute. repeat split; reflexivity. Qed.

End ShellPipeline.
