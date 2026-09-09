(* semax_body proof for the actual generated relay against the frozen Specs.v
   contracts. This is a VST partial-correctness/safety theorem in VST's logic
   under the external funspecs read_spec/write_spec. It is not a termination
   theorem, not a dry/juicy external adequacy theorem, and not a host OS theorem. *)
Require Import VST.floyd.proofauto.
Require Import relay Protocol Reach Conservation Specs.
Import RelayProtocol RelayReach RelayConservation.
Local Open Scope Z_scope.

(* ---- memory bookkeeping for the fixed 32-byte stack buffer ---- *)

Lemma tuchar_subarray_offset n off p :
  field_compatible (Tarray tuchar n noattr) [] p -> 0 <= off <= n ->
  field_address0 (Tarray tuchar n noattr) [ArraySubsc off] p = offset_val off p.
Proof.
  intros Hfc Hoff.
  rewrite field_address0_offset.
  2:{ eapply field_compatible0_cons_Tarray; [reflexivity | exact Hfc | lia]. }
  f_equal. unfold nested_field_offset; simpl. lia.
Qed.

Lemma buffer_prefix_forget sh p bs :
  field_compatible (tarray tuchar 32) [] p -> 0 <= Zlength bs <= 32 ->
  buffer_prefix sh p bs |-- data_at_ sh (tarray tuchar 32) p.
Proof.
  intros Hfc Hlen. unfold buffer_prefix, byte_array, tarray in *.
  rewrite (split2_data_at__Tarray_tuchar sh 32 (Zlength bs) p Hlen
    (field_compatible_isptr _ _ _ Hfc) Hfc).
  rewrite (tuchar_subarray_offset 32 (Zlength bs) p Hfc Hlen).
  apply sepcon_derives; [apply data_at_data_at_ | apply derives_refl].
Qed.

Lemma buffer_prefix_empty sh p :
  field_compatible (tarray tuchar 32) [] p ->
  buffer_prefix sh p [] |-- data_at_ sh (tarray tuchar 32) p.
Proof.
  intro Hfc. apply buffer_prefix_forget; [exact Hfc | rewrite Zlength_nil; lia].
Qed.

(* Split the initialized chunk at off: the first off bytes stay framed, the
   suffix is exactly the requested write range at p + off. *)
Lemma byte_array_split sh p chunk off :
  field_compatible (tarray tuchar (Zlength chunk)) [] p ->
  0 <= off <= Zlength chunk ->
  byte_array sh p chunk =
  (byte_array sh p (prefix off chunk) *
   byte_array sh (offset_val off p) (suffix off chunk))%logic.
Proof.
  intros Hfc Hoff. unfold byte_array, tarray in *.
  rewrite (split2_data_at_Tarray_tuchar sh (Zlength chunk) off (map Vubyte chunk) p)
    by (auto; apply Zlength_map).
  rewrite (tuchar_subarray_offset (Zlength chunk) off p Hfc Hoff).
  unfold prefix, suffix. rewrite !sublist_map.
  rewrite !Zlength_sublist by lia.
  replace (off - 0) with off by lia.
  reflexivity.
Qed.

Lemma buffer_prefix_rejoin sh p chunk off :
  field_compatible (tarray tuchar (Zlength chunk)) [] p ->
  0 <= off <= Zlength chunk ->
  (byte_array sh p (prefix off chunk) *
   byte_array sh (offset_val off p) (suffix off chunk) *
   data_at_ sh (tarray tuchar (32 - Zlength chunk)) (offset_val (Zlength chunk) p))%logic
  |-- buffer_prefix sh p chunk.
Proof.
  intros Hfc Hoff. unfold buffer_prefix.
  rewrite (byte_array_split sh p chunk off Hfc Hoff). apply derives_refl.
Qed.

(* ---- pointer arithmetic produced by the generated Clight ---- *)

Lemma sem_add_ptr_long_tuchar p off :
  isptr p -> 0 <= off <= Int64.max_unsigned ->
  force_val (sem_add_ptr_long tuchar p (Vlong (Int64.repr off))) = offset_val off p.
Proof.
  intros Hp Hoff. destruct p; try contradiction. simpl.
  f_equal. f_equal. unfold Ptrofs.of_int64.
  rewrite Int64.unsigned_repr by rep_lia.
  rewrite Ptrofs.mul_commut, Ptrofs.mul_one. reflexivity.
Qed.

(* ---- the body theorem ---- *)

Lemma body_relay : semax_body Vprog Gprog f_relay relay_spec.
Proof.
  start_function.
  forward_loop (EX s : world,
    PROP (valid_world s; reaches initial Ready s;
          field_compatible (tarray tuchar 32) [] v_buf)
    LOCAL (lvar _buf (tarray tuchar 32) v_buf)
    SEP (has_ext s; data_at_ Tsh (tarray tuchar 32) v_buf)).
  { Exists initial. entailer!. apply initial_ready. }
  Intros s.
  forward_call (s, v_buf, Tsh).
  pose proof (read_ret_bounds s) as Hbounds.
  pose proof (read_valid_world s ltac:(assumption)) as Hvalid'.
  forward_if.
  { (* n < 0: read error, status 1 *)
    assert (E : (read_ret (read32 s) <? 0) = true) by (apply Z.ltb_lt; lia).
    rewrite E.
    forward.
    Exists 1 (read_world (read32 s)) (@nil byte).
    entailer!.
    apply read_error; [assumption | lia]. }
  assert (E : (read_ret (read32 s) <? 0) = false) by (apply Z.ltb_ge; lia).
  rewrite E.
  forward_if.
  { (* n == 0: EOF, status 0 *)
    assert (Hzero : read_ret (read32 s) = 0).
    { match goal with
      | Hz : Int64.repr _ = Int64.zero |- _ =>
          change Int64.zero with (Int64.repr 0) in Hz;
          apply repr_inj_signed64 in Hz; [exact Hz | rep_lia | rep_lia]
      end. }
    rewrite (read_nonpositive_no_bytes s ltac:(lia)).
    forward.
    Exists 0 (read_world (read32 s)) (@nil byte).
    entailer!.
    { apply read_eof; [assumption | lia]. }
    apply buffer_prefix_empty; assumption. }
  (* positive read: drain the chunk *)
  assert (Hpos : 0 < read_ret (read32 s)).
  { match goal with
    | Hz : Int64.repr _ <> Int64.repr 0 |- _ =>
        assert (read_ret (read32 s) <> 0)
          by (intro Heq; apply Hz; rewrite Heq; reflexivity); lia
    end. }
  pose proof (read_success_length s ltac:(lia)) as Hlen.
  forward.
  forward_while (EX t : world, EX off : Z,
    PROP (valid_world t; 0 <= off <= read_ret (read32 s);
          reaches initial (Drain (read_bytes (read32 s)) off) t;
          field_compatible (tarray tuchar 32) [] v_buf)
    LOCAL (temp _n (Vlong (Int64.repr (read_ret (read32 s))));
           temp _off (Vlong (Int64.repr off));
           lvar _buf (tarray tuchar 32) v_buf)
    SEP (has_ext t; buffer_prefix Tsh v_buf (read_bytes (read32 s)))).
  { (* loop entry *)
    Exists (read_world (read32 s)) 0. entailer!.
    apply read_data; [assumption | exact Hpos]. }
  { entailer!. }
  { (* loop body: off < n *)
    apply ltu_repr64 in HRE; [ | rep_lia | rep_lia].
    unfold buffer_prefix.
    assert_PROP (field_compatible (tarray tuchar (Zlength (read_bytes (read32 s)))) [] v_buf)
      as Hfcn by entailer!.
    assert (Hptr : isptr v_buf) by (eapply field_compatible_isptr; eassumption).
    rewrite (byte_array_split Tsh v_buf (read_bytes (read32 s)) off) by (auto; lia).
    forward_call (t, offset_val off v_buf, suffix off (read_bytes (read32 s)), Tsh).
    { rewrite suffix_length by lia. rewrite Hlen. entailer!.
      all: match goal with |- ?G => idtac "ARGS residual:" G end.
      all: try (rewrite Z.mul_1_l; reflexivity).
      all: try (rewrite sem_add_ptr_long_tuchar by (auto; rep_lia);
                rewrite ?sub64_repr; reflexivity).
      all: match goal with |- ?G => idtac "ARGS still open:" G end. }
    { cancel. }
    { rewrite suffix_length by lia. split; lia. }
    pose proof (write_ret_bounds t (suffix off (read_bytes (read32 s)))) as Hw.
    rewrite suffix_length in Hw by lia.
    pose proof (write_valid_world t (suffix off (read_bytes (read32 s))) ltac:(assumption)) as Hvalid''.
    forward_if.
    { (* w <= 0: write failure, status 2, pending = suffix *)
      forward.
      Exists 2 (write_world (write_block t (suffix off (read_bytes (read32 s)))))
        (suffix off (read_bytes (read32 s))).
      sep_apply (buffer_prefix_rejoin Tsh v_buf (read_bytes (read32 s)) off Hfcn ltac:(lia)).
      sep_apply (buffer_prefix_forget Tsh v_buf (read_bytes (read32 s)) ltac:(assumption) ltac:(lia)).
      entailer!.
      apply write_error; [assumption | lia | lia]. }
    (* w > 0: advance *)
    forward.
    Exists (write_world (write_block t (suffix off (read_bytes (read32 s)))),
            off + write_ret (write_block t (suffix off (read_bytes (read32 s))))).
    cbn [fst snd].
    try rewrite add64_repr.
    sep_apply (buffer_prefix_rejoin Tsh v_buf (read_bytes (read32 s)) off Hfcn ltac:(lia)).
    entailer!.
    apply write_data; [assumption | lia | lia]. }
  (* loop exit: off = n, chunk fully drained *)
  assert (Hge : off >= read_ret (read32 s))
    by (apply (ltu_repr_false64 off (read_ret (read32 s))); [rep_lia | rep_lia | exact HRE]).
  assert (Hoff : off = Zlength (read_bytes (read32 s))) by lia.
  forward.
  subst off.
  Exists t.
  sep_apply (buffer_prefix_forget Tsh v_buf (read_bytes (read32 s)) ltac:(assumption) ltac:(lia)).
  entailer!.
  apply drained with (chunk := read_bytes (read32 s)). assumption.
Qed.
