(* semax_body for the generated gnulib full_write (full_write.v) against the
   generalized contracts, with safe_write assumed by its funspec. *)
Require Import VST.floyd.proofauto.
Require Import IOWorld IOSpecs.
Require Import full_write.
Require Body Conservation.
Import IOW.
Import Conservation.RelayConservation (suffix_length, suffix_zero, suffix_end).
Local Open Scope Z_scope.

Definition Vprog : varspecs. mk_varspecs prog. Defined.

Lemma cenv_ok : @cenv_cs CompSpecs = prog_comp_env prog.
Proof. reflexivity. Qed.

Definition Gprog : funspecs :=
  ltac:(with_library prog [safe_write_spec _errno _safe_write; full_write_spec _errno _full_write]).

Lemma suffix_nonempty off bs : 0 <= off < Zlength bs -> suffix off bs <> [].
Proof.
  intros H E. pose proof (suffix_length off bs ltac:(lia)) as Hl.
  rewrite E, Zlength_nil in Hl. lia.
Qed.

(* `ptr += n_rw` on a `const char *`: the generated Clight binop is
   Oadd (tptr tschar) tulong, which VST's sem_binary_operation' reduces to
   sem_add_ptr_long tschar; IOSpecs.sem_add_ptr_long_tschar finishes. *)
Lemma sem_add_tptr_tschar_tulong q off :
  isptr q -> 0 <= off <= Int64.max_unsigned ->
  force_val (sem_binary_operation' Oadd (tptr tschar) tulong q (Vlong (Int64.repr off))) =
  offset_val off q.
Proof.
  intros Hq Hoff.
  first [ change (force_val (sem_binary_operation' Oadd (tptr tschar) tulong q (Vlong (Int64.repr off))))
            with (force_val (sem_add_ptr_long tschar q (Vlong (Int64.repr off))));
          apply sem_add_ptr_long_tschar; auto
        | destruct q; try contradiction; simpl; f_equal; f_equal; unfold Ptrofs.of_int64;
          rewrite Int64.unsigned_repr by rep_lia;
          rewrite Ptrofs.mul_commut, Ptrofs.mul_one; reflexivity ].
Qed.

Lemma body_full_write : semax_body Vprog Gprog f_full_write (full_write_spec _errno _full_write).
Proof.
  start_function.
  forward. forward.
  assert_PROP (field_compatible (tarray tuchar (Zlength bs)) [] p) as Hfc.
  { unfold Specs.byte_array. entailer!. }
  assert (Hptr : isptr p) by (eapply field_compatible_isptr; eassumption).
  forward_loop (EX t : world, EX off : Z, EX e1 : Z,
    PROP (valid_world t; out_fd t = out_fd s; 0 <= off <= Zlength bs;
          forall total e' t', FullWrite (suffix off bs) t e1 total e' t' ->
                              FullWrite bs s e (off + total) e' t')
    LOCAL (temp _total (Vlong (Int64.repr off)); temp _ptr (offset_val off p);
           temp _count (Vlong (Int64.repr (Zlength bs - off)));
           temp _fd (Vint (Int.repr (out_fd t))); temp _buf p; gvars gv)
    SEP (has_ext t; byte_array sh p bs; errno_at (gv _errno) e1))
  break: (EX total : Z, EX e' : Z, EX t : world,
    PROP (FullWrite bs s e total e' t)
    LOCAL (temp _total (Vlong (Int64.repr total)); temp _buf p; gvars gv)
    SEP (has_ext t; byte_array sh p bs; errno_at (gv _errno) e')).
  { Exists s 0 e. rewrite isptr_offset_val_zero by auto. rewrite Z.sub_0_r.
    entailer!. intros total e' t' Hfw. rewrite suffix_zero in Hfw. exact Hfw. }
  Intros t off e1.
  match goal with Hk : forall total e' t', FullWrite _ _ _ _ _ _ -> _ |- _ => rename Hk into Hcont end.
  forward_if (PROP (off < Zlength bs)
    LOCAL (temp _total (Vlong (Int64.repr off)); temp _ptr (offset_val off p);
           temp _count (Vlong (Int64.repr (Zlength bs - off)));
           temp _fd (Vint (Int.repr (out_fd t))); temp _buf p; gvars gv)
    SEP (has_ext t; byte_array sh p bs; errno_at (gv _errno) e1)).
  { (* count > 0 *)
    forward. entailer!.
    match goal with
    | Hc : Int64.unsigned (Int64.repr 0) < Int64.unsigned (Int64.repr _) |- _ => norm_cmp Hc; lia
    | Hc : 0 < _ |- _ => lia
    | |- _ => idtac "no matching hypothesis"
    end. }
  { (* count == 0: loop exit, total = off = Zlength bs *)
    forward.
    assert (Hend : off = Zlength bs).
    { match goal with
      | Hc : Int64.unsigned (Int64.repr 0) >= Int64.unsigned (Int64.repr _) |- _ => norm_cmp Hc; lia
      | Hc : ~ (Int64.unsigned (Int64.repr 0) < Int64.unsigned (Int64.repr _)) |- _ => norm_cmp Hc; lia
      | Hc : Int64.unsigned (Int64.repr 0) <= _ |- _ => idtac "no-hyp"; lia
      | |- _ => idtac "no-hyp"; lia
      end. }
    Exists off e1 t. entailer!.
    match goal with |- FullWrite bs s ?ee ?o ?e1' ?t' =>
      replace o with (o + 0) by lia end.
    apply Hcont. try rewrite Hend. rewrite suffix_end. apply fw_nil. }
  Intros.
  rewrite (Body.byte_array_split sh p bs off Hfc ltac:(lia)).
  repeat simple apply seq_assoc1.
  forward_call (gv, t, offset_val off p, suffix off bs, e1, sh).
  all: try (rewrite suffix_length by lia).
  all: try solve [entailer!].
  all: try solve [repeat split; auto; rep_lia].
  Intros ret. destruct ret as [[[r e2] out] t2]. simpl fst in *; simpl snd in *.
  match goal with Hx : SafeWrite _ _ _ _ _ _ |- _ => rename Hx into Hsw end.
  pose proof (SafeWrite_ret_bounds _ _ _ _ _ _ Hsw) as Hr.
  rewrite suffix_length in Hr by lia.
  destruct (SafeWrite_effect _ _ _ _ _ _ Hsw) as (Hd2 & Hp2 & Hz2 & Hu2 & Hi2 & Ho2 & Hg2 & Hrd2).
  pose proof (SafeWrite_valid _ _ _ _ _ _ ltac:(eassumption) Hsw) as Hv2.
  pose proof (suffix_nonempty off bs ltac:(lia)) as Hne.
  forward.
  forward_if.
  { (* n_rw == (size_t)-1 *)
    match goal with Hc : Int64.eq _ _ = _ |- _ => norm_cmp Hc | _ => idtac end.
    assert (Hm1 : r = -1).
    { match goal with
      | Hc : Int64.repr r = Int64.repr _ |- _ => apply repr_inj_signed64 in Hc; rep_lia
      | Hc : r = _ |- _ => lia
      end. }
    subst r. specialize (Hz2 ltac:(lia)). subst out.
    forward.
    Exists off e2 t2.
    rewrite (Body.byte_array_split sh p bs off Hfc ltac:(lia)).
    entailer!.
    match goal with |- FullWrite bs s ?ee ?o _ _ => replace o with (o + 0) by lia end.
    apply Hcont. apply fw_err; auto. }
  match goal with Hc : Int64.eq _ _ = _ |- _ => norm_cmp Hc | _ => idtac end.
  assert (Hnm1 : r <> -1).
  { intro E. subst r.
    match goal with
    | Hc : Int64.repr (-1) <> Int64.repr _ |- _ => apply Hc; reflexivity
    | Hc : -1 <> -1 |- _ => contradiction
    end. }
  forward_if.
  { (* n_rw == 0: errno = ENOSPC; break *)
    match goal with Hc : Int64.eq _ _ = _ |- _ => norm_cmp Hc | _ => idtac end.
    assert (Hz : r = 0).
    { match goal with
      | Hc : Int64.repr r = Int64.repr _ |- _ => apply repr_inj_signed64 in Hc; rep_lia
      | Hc : Int64.repr r = Int64.zero |- _ =>
          change Int64.zero with (Int64.repr 0) in Hc; apply repr_inj_signed64 in Hc; rep_lia
      | Hc : r = _ |- _ => lia
      end. }
    subst r. destruct (Hp2 ltac:(lia)) as [Hout _].
    pose proof (Zlength_nonneg (suffix off bs)) as Hsl.
    assert (Hout' : out = []) by (apply Zlength_nil_inv; rewrite Hout; apply RP.prefix_length; lia).
    subst out.
    unfold errno_at. forward. forward.
    Exists off ENOSPC t2.
    rewrite (Body.byte_array_split sh p bs off Hfc ltac:(lia)).
    unfold errno_at, ENOSPC. entailer!.
    match goal with |- FullWrite bs s ?ee ?o _ _ => replace o with (o + 0) by lia end.
    apply Hcont. eapply fw_zero; [auto | exact Hsw]. }
  match goal with Hc : Int64.eq _ _ = _ |- _ => norm_cmp Hc | _ => idtac end.
  assert (Hpos : 0 < r).
  { assert (r <> 0).
    { intro E. subst r.
      match goal with
      | Hc : Int64.repr 0 <> Int64.repr _ |- _ => apply Hc; reflexivity
      | Hc : Int64.repr 0 <> Int64.zero |- _ => apply Hc; reflexivity
      | Hc : 0 <> 0 |- _ => contradiction
      end. }
    lia. }
  forward. forward. forward.
  (* total += n_rw; ptr += n_rw; count -= n_rw.  Normalize the three updated
     temps to the invariant's shape before introducing the witnesses, so that
     entailer! is left with nothing but the PROP obligations. *)
  rewrite (sem_add_tptr_tschar_tulong (offset_val off p) r) by (auto; rep_lia).
  rewrite offset_offset_val, add64_repr, sub64_repr.
  replace (Zlength bs - off - r) with (Zlength bs - (off + r)) by lia.
  Exists t2 (off + r) e2.
  rewrite (Body.byte_array_split sh p bs off Hfc ltac:(lia)).
  entailer!.
  (* Residual: the continuation obligation of the invariant
     (run utility-resume2-FullWriteBody-1 showed it is the only one). *)
  intros total e' t' Hfw. replace (off + r + total) with (off + (r + total)) by lia.
  apply Hcont. eapply fw_step; eauto.
  rewrite suffix_suffix by lia. exact Hfw.
  Intros total e' t'.
  forward.
  Exists total e' t'. entailer!.
Qed.
