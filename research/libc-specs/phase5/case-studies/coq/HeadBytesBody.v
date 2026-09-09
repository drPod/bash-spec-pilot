(* semax_body for the generated GNU coreutils head_bytes (head_bytes_fragment.v,
   byte-extracted from head.c) against safe_read_spec (reused unchanged from
   utility-reuse/coq/IOSpecs.v), the new xwrite_stdout_spec (stdio trust
   boundary) / quoteaf_spec, and the assumed external error (reused
   error_spec, status 0 only).

   History: the case-studies4 attempt (same statement) hung for 240 s inside
   the forward_call to safe_read. Cause: the call site handed VST the whole
   local buffer `data_at_ Tsh (tarray tuchar 8192)` while safe_read_spec's
   footprint is `data_at_ sh (tarray tuchar n)` with n the symbolic request
   count, so frame inference could not cancel and searched. Fix (case-proofs-6/8):
   split the buffer at the request count with VST's own split lemma before
   the call (buffer_split) and rejoin afterwards (buffer_join); every
   forward_call now cancels syntactically. *)
Require Import VST.floyd.proofauto.
Require Import IOWorld CaseWorld.
Require Import IOSpecs CaseSpecs.
Require Body.
Require Import head_bytes_fragment.
Import IOW.
Local Open Scope Z_scope.

Definition Vprog : varspecs. mk_varspecs prog. Defined.

Lemma cenv_ok : @cenv_cs CompSpecs = prog_comp_env prog.
Proof. reflexivity. Qed.

(* Local `char buffer[BUFSIZ]` compiles to `tarray tschar 8192`; safe_read_spec
   / xwrite_stdout_spec (reused / new, both byte-array-typed) need
   `tarray tuchar`. Bridged via VST's own tschar/tuchar <-> memory_block
   equalities (field_compat.v); no assumption, this is a proved equality. *)
Lemma buffer_tschar_tuchar sh p :
  @data_at_ CompSpecs sh (tarray tschar 8192) p =
  @data_at_ CompSpecs sh (tarray tuchar 8192) p.
Proof.
  rewrite <- (memory_block_data_at__tarray_tschar_eq sh p 8192 ltac:(rep_lia)).
  rewrite <- (memory_block_data_at__tarray_tuchar_eq sh p 8192 ltac:(rep_lia)).
  reflexivity.
Qed.

(* Split the local buffer at the requested read count k: the first k bytes are
   exactly safe_read_spec's footprint, the remainder is framed. *)
Lemma buffer_split sh p k : field_compatible (tarray tuchar 8192) [] p -> 0 <= k <= 8192 ->
  @data_at_ CompSpecs sh (tarray tschar 8192) p =
  (@data_at_ CompSpecs sh (tarray tuchar k) p *
   @data_at_ CompSpecs sh (tarray tuchar (8192 - k)) (offset_val k p))%logic.
Proof.
  intros Hfc Hk. rewrite buffer_tschar_tuchar. unfold tarray.
  rewrite (split2_data_at__Tarray_tuchar sh 8192 k p Hk (field_compatible_isptr _ _ _ Hfc) Hfc).
  rewrite (Body.tuchar_subarray_offset 8192 k p Hfc Hk). reflexivity.
Qed.

Lemma buffer_join sh p k : field_compatible (tarray tuchar 8192) [] p -> 0 <= k <= 8192 ->
  @data_at_ CompSpecs sh (tarray tuchar k) p *
  @data_at_ CompSpecs sh (tarray tuchar (8192 - k)) (offset_val k p)
  |-- @data_at_ CompSpecs sh (tarray tschar 8192) p.
Proof. intros. rewrite (buffer_split sh p k); auto. Qed.

(* Wrapper hiding an equation from VST's automatic `subst` (forward/entailer!
   substitute any hypothesis `x = e`, which would eliminate the opaque read
   count rd again). Unfolded only where the equation is needed. *)
Definition rd_eq (a b : Z) : Prop := a = b.

Definition Gprog : funspecs :=
  ltac:(with_library prog
    [safe_read_spec _errno _safe_read; quoteaf_spec _quoteaf; error_spec _error;
     xwrite_stdout_spec _errno _xwrite_stdout;
     head_bytes_spec _errno _head_bytes]).

Lemma body_head_bytes :
  semax_body Vprog Gprog f_head_bytes (head_bytes_spec _errno _head_bytes).
Proof.
  start_function.
  rewrite buffer_tschar_tuchar.
  assert_PROP (field_compatible (tarray tuchar 8192) [] v_buffer) as Hfc by entailer!.
  rewrite <- buffer_tschar_tuchar.
  forward.
  forward_loop (EX consumed : Z, EX t : world, EX e1 : Z, EX br : Z,
    PROP (valid_world t; in_fd t = in_fd s; 0 <= consumed <= N; HeadLoop 8192 N s e t consumed e1;
          Z.min 8192 (N - consumed) <= br <= 8192)
    LOCAL (temp _bytes_to_write (Vlong (Int64.repr (N - consumed))); temp _bytes_to_read (Vlong (Int64.repr br));
           temp _filename fname; temp _fd (Vint (Int.repr (in_fd s))); lvar _buffer (tarray tschar 8192) v_buffer;
           gvars gv)
    SEP (data_at_ Tsh (tarray tschar 8192) v_buffer; has_ext t; errno_at (gv _errno) e1))
  break: (EX t : world, EX e1 : Z,
    PROP (valid_world t; HeadOutcome 8192 N s e true t e1)
    LOCAL (lvar _buffer (tarray tschar 8192) v_buffer; gvars gv)
    SEP (has_ext t; data_at_ Tsh (tarray tschar 8192) v_buffer; errno_at (gv _errno) e1)).
  { Exists 0 s e 8192. entailer!.
    all: repeat split; auto using hl_start; try lia. }
  { Intros consumed t e1 br.
    match goal with Hx : Z.min 8192 (N - consumed) <= br <= 8192 |- _ => rename Hx into Hbr end.
    match goal with Hx : in_fd t = in_fd s |- _ => rename Hx into Hin end.
    match goal with Hx : HeadLoop _ _ _ _ _ _ _ |- _ => rename Hx into Hloop end.
    forward_if.
    { (* bytes_to_write <> 0: one more iteration *)
      match goal with
      | Hc : typed_true _ _ |- _ => hnf in Hc; simpl in Hc; try norm_cmp Hc
      | _ => idtac
      end.
      assert (Hlt : consumed < N).
      { destruct (zlt consumed N) as [Hl | Hge]; [exact Hl | exfalso].
        replace (N - consumed) with 0 in * by lia.
        first
          [ match goal with Hc : _ <> _ |- _ => solve [apply Hc; reflexivity] end
          | match goal with Hc : typed_true _ _ |- _ =>
              solve [hnf in Hc; simpl in Hc; congruence | vm_compute in Hc; discriminate | inv Hc] end
          | match goal with Hc : _ = _ |- _ => solve [vm_compute in Hc; discriminate] end
          | lia ]. }
      forward_if (PROP ()
        LOCAL (temp _bytes_to_read (Vlong (Int64.repr (Z.min 8192 (N - consumed))));
               temp _bytes_to_write (Vlong (Int64.repr (N - consumed)));
               temp _filename fname; temp _fd (Vint (Int.repr (in_fd s))); lvar _buffer (tarray tschar 8192) v_buffer;
               gvars gv)
        SEP (data_at_ Tsh (tarray tschar 8192) v_buffer; has_ext t; errno_at (gv _errno) e1)).
      { (* N - consumed < br: bytes_to_read := bytes_to_write *)
        match goal with
        | Hc : typed_true _ _ |- _ => hnf in Hc; simpl in Hc; try norm_cmp Hc
        | _ => idtac
        end.
        assert (Hmin : Z.min 8192 (N - consumed) = N - consumed) by lia.
        forward. try rewrite Hmin. entailer!.
        all: try (f_equal; f_equal; lia). }
      { (* N - consumed >= br: bytes_to_read already equals the clamp *)
        match goal with
        | Hc : typed_false _ _ |- _ => hnf in Hc; simpl in Hc; try norm_cmp Hc
        | _ => idtac
        end.
        assert (Hmin : Z.min 8192 (N - consumed) = br) by lia.
        forward. try rewrite Hmin. entailer!.
        all: try (f_equal; f_equal; lia). }
      (* rd is kept opaque (remember, not set/let): VST's simplifications inside
         forward_call unfold a let-bound or literal Z.min term and hang. *)
      remember (Z.min 8192 (N - consumed)) as rd eqn:Hrd.
      assert (Hk : 0 <= rd <= 8192) by lia.
      assert (Hrdpos : 0 < rd) by lia.
      change (rd = Z.min 8192 (N - consumed)) with (rd_eq rd (Z.min 8192 (N - consumed))) in Hrd.
      (* The buffer is the FIRST SEP conjunct on purpose: after the split the
         two halves must be separate SEP entries (flatten_sepcon_in_SEP only
         flattens the head), otherwise VST's frame inference cannot cancel
         and forward_call spins in after_forward_call (case6-diag5c). *)
      rewrite (buffer_split Tsh v_buffer rd Hfc Hk).
      flatten_sepcon_in_SEP.
      assert_PROP (field_compatible (tarray tuchar rd) [] v_buffer) as Hfcrd by entailer!.
      rewrite <- Hin.
      (* Reassociate so the call is `Scall (Some _t'1); (Sset _bytes_read ...; ...)`
         and VST's after_forward_call removes the 3-character temp _t'1 from
         LOCAL, not _bytes_read: simplify_remove_localdef_temp runs `simpl` on
         ident_eq over clightgen's string-encoded identifiers ($"bytes_read"),
         whose cost explodes with the name length (bisected in case6-diag8b/9,
         IdentBench; same trick as utility-reuse/coq/CatBody.v). *)
      repeat simple apply seq_assoc1.
      forward_call (gv, t, v_buffer, rd, e1, Tsh).
      all: try solve [repeat split; auto;
                      first [ apply writable_share_top | apply readable_share_top | rep_lia | lia ]].
      Intros r0. destruct r0 as [[[r e2] bs] t1]. simpl fst in *; simpl snd in *.
      match goal with Hx : SafeRead _ _ _ _ _ _ |- _ => rename Hx into Hsr end.
      assert (Hmin_nonneg : 0 <= rd) by lia.
      pose proof (SafeRead_ret_bounds _ _ _ _ _ _ Hmin_nonneg Hsr) as Hrb.
      match goal with Hv : valid_world t |- _ => pose proof (SafeRead_valid _ _ _ _ _ _ Hv Hsr) as Hv1 end.
      destruct (SafeRead_conservation _ _ _ _ _ _ Hmin_nonneg Hsr) as (Hb1 & Hd1 & Hi1 & Ho1 & Hg1 & Hw1).
      forward.
      forward_if.
      { (* bytes_read == SAFE_READ_ERROR: report, return false *)
        match goal with Hc : Int64.eq _ _ = _ |- _ => norm_cmp Hc | _ => idtac end.
        assert (Hm1 : r = -1).
        { first
            [ match goal with Hc : Int64.repr r = Int64.repr _ |- _ => apply repr_inj_signed64 in Hc; rep_lia end
            | lia ]. }
        subst r.
        assert (E : ((-1) <? 0) = true) by reflexivity. rewrite E.
        repeat simple apply seq_assoc1.
        forward_call fname.
        Intros q.
        unfold errno_at. forward.
        repeat simple apply seq_assoc1.
        forward_call (t1, e2, gv ___stringlit_1, q).
        forward.
        sep_apply (buffer_join Tsh v_buffer rd Hfc Hk).
        Exists (report e2 t1) e2 false.
        entailer!.
        unfold rd_eq in Hrd. assert (Hsr' := Hsr). rewrite Hrd in Hsr'.
        eapply ho_err; eauto; lia. }
      match goal with Hc : Int64.eq _ _ = _ |- _ => norm_cmp Hc | _ => idtac end.
      assert (Hnm1 : r <> -1).
      { intro Eq. subst r.
        first
          [ match goal with Hc : _ <> _ |- _ => solve [apply Hc; reflexivity] end
          | lia ]. }
      forward_if.
      { (* bytes_read == 0: EOF, break; the loop postcondition is the true outcome *)
        match goal with Hc : Int64.eq _ _ = _ |- _ => norm_cmp Hc | _ => idtac end.
        assert (Hz : r = 0).
        { first
            [ match goal with Hc : Int64.repr r = Int64.repr _ |- _ => apply repr_inj_signed64 in Hc; rep_lia end
            | match goal with Hc : Int64.repr r = Int64.zero |- _ =>
                change Int64.zero with (Int64.repr 0) in Hc; apply repr_inj_signed64 in Hc; rep_lia end
            | lia ]. }
        subst r.
        destruct (SafeRead_zero _ _ _ _ _ _ Hrdpos Hsr eq_refl) as [_ Hbs]. subst bs.
        assert (E : (0 <? 0) = false) by reflexivity. rewrite E.
        pose proof (buffer_prefix_n_forget Tsh v_buffer rd [] Hfcrd
                      ltac:(rewrite Zlength_nil; lia)) as Hforget.
        sep_apply Hforget.
        sep_apply (buffer_join Tsh v_buffer rd Hfc Hk).
        forward.
        Exists t1 e2.
        entailer!.
        unfold rd_eq in Hrd. assert (Hsr' := Hsr). rewrite Hrd in Hsr'.
        eapply ho_eof; eauto; try lia. }
      match goal with Hc : Int64.eq _ _ = _ |- _ => norm_cmp Hc | _ => idtac end.
      assert (Hpos : 0 < r).
      { assert (r <> 0).
        { intro Eq. subst r.
          first
            [ match goal with Hc : _ <> _ |- _ => solve [apply Hc; reflexivity] end
            | lia ]. }
        lia. }
      pose proof (SafeRead_length _ _ _ _ _ _ Hmin_nonneg Hsr (Z.lt_le_incl _ _ Hpos)) as Hlen.
      assert (E : (r <? 0) = false) by (apply Z.ltb_ge; lia). rewrite E.
      pose proof (buffer_prefix_n_forget Tsh v_buffer rd bs Hfcrd ltac:(lia)) as Hforget.
      unfold buffer_prefix_n in *.
      flatten_sepcon_in_SEP.
      replace (Vlong (Int64.repr r)) with (Vlong (Int64.repr (Zlength bs))) by (rewrite Hlen; reflexivity).
      repeat simple apply seq_assoc1.
      forward_call (gv, t1, v_buffer, bs, Tsh, e2).
      all: try solve [repeat split; auto;
                      first [ apply writable_share_top | apply readable_share_top | rep_lia | lia ]].
      Intros r1. destruct r1 as [e3 t2]. simpl fst in *; simpl snd in *.
      match goal with Hx : XWrite _ _ _ _ _ |- _ => rename Hx into Hxw end.
      pose proof (XWrite_valid _ _ _ _ _ Hv1 Hxw) as Hv2.
      destruct (XWrite_effect _ _ _ _ _ Hxw) as (Hd2 & Hu2 & Hi2 & Ho2 & Hg2 & _).
      forward.
      sep_apply Hforget.
      sep_apply (buffer_join Tsh v_buffer rd Hfc Hk).
      unfold rd_eq in Hrd. assert (Hsr' := Hsr). rewrite Hrd in Hsr'.
      assert (Hchunk : HeadLoop 8192 N s e t2 (consumed + Zlength bs) e3)
        by (rewrite Hlen; eapply hl_chunk; eauto).
      Exists (consumed + Zlength bs) t2 e3 rd.
      entailer!.
      all: try (rewrite sub64_repr; f_equal; f_equal; lia).
      all: try (f_equal; f_equal; lia).
      all: repeat split; try congruence; try lia. }
    (* bytes_to_write == 0: natural loop exit *)
    match goal with
    | Hc : typed_false _ _ |- _ => hnf in Hc; simpl in Hc; try norm_cmp Hc
    | _ => idtac
    end.
    assert (HeqN : consumed = N).
    { first
        [ lia
        | match goal with Hc : Int64.repr (N - consumed) = Int64.repr 0 |- _ =>
            apply repr_inj_unsigned64 in Hc; rep_lia end
        | match goal with Hc : Int64.repr (N - consumed) = Int64.zero |- _ =>
            change Int64.zero with (Int64.repr 0) in Hc; apply repr_inj_unsigned64 in Hc; rep_lia end
        | match goal with Hc : Vlong (Int64.repr (N - consumed)) = Vlong Int64.zero |- _ =>
            inversion Hc as [Hc']; change Int64.zero with (Int64.repr 0) in Hc';
            apply repr_inj_unsigned64 in Hc'; rep_lia end ]. }
    subst consumed.
    forward.
    Exists t e1. entailer!.
    all: try (apply ho_done; auto). }
  Intros t e1.
  forward.
  Exists t e1 true.
  entailer!.
Qed.
