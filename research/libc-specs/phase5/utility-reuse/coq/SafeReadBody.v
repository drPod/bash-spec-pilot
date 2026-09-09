(* semax_body for the generated gnulib safe_read (safe_read.v) against the
   generalized contracts. Partial correctness in VST's logic under read_spec. *)
Require Import VST.floyd.proofauto.
Require Import IOWorld IOSpecs.
Require Import safe_read.
Import IOW.
Local Open Scope Z_scope.

Definition Vprog : varspecs. mk_varspecs prog. Defined.

Lemma cenv_ok : @cenv_cs CompSpecs = prog_comp_env prog.
Proof. reflexivity. Qed.

Definition Gprog : funspecs :=
  ltac:(with_library prog [read_spec _errno _read; safe_read_spec _errno _safe_read]).

Lemma body_safe_read : semax_body Vprog Gprog f_safe_read (safe_read_spec _errno _safe_read).
Proof.
  start_function.
  forward_loop (EX t : world, EX e1 : Z,
    PROP (valid_world t; in_fd t = in_fd s;
          forall r e' bs t', SafeRead n t r e' bs t' -> SafeRead n s r e' bs t')
    LOCAL (temp _fd (Vint (Int.repr (in_fd t))); temp _buf p;
           temp _count (Vlong (Int64.repr n)); gvars gv)
    SEP (has_ext t; data_at_ sh (tarray tuchar n) p; errno_at (gv _errno) e1))
  continue: (EX t : world, EX e1 : Z,
    PROP (valid_world t; in_fd t = in_fd s;
          forall r e' bs t', SafeRead n t r e' bs t' -> SafeRead n s r e' bs t')
    LOCAL (temp _fd (Vint (Int.repr (in_fd t))); temp _buf p;
           temp _count (Vlong (Int64.repr n)); gvars gv)
    SEP (has_ext t; data_at_ sh (tarray tuchar n) p; errno_at (gv _errno) e1)).
  { Exists s e. entailer!. }
  Intros t e1.
  apply -> semax_skip_seq. abbreviate_semax.
  match goal with Hk : forall r e' bs t', SafeRead _ _ _ _ _ _ -> _ |- _ => rename Hk into Hcont end.
  forward_call (gv, t, p, n, e1, sh).
  all: try solve [entailer!].
  all: try solve [repeat split; auto; rep_lia].
  Intros e2.
  match goal with Hx : read_ret (read_n n t) < 0 -> e2 = _ |- _ => rename Hx into He2 end.
  pose proof (read_ret_bounds n t ltac:(lia)) as Hbounds.
  pose proof (read_valid n t ltac:(assumption)) as Hvalid'.
  pose proof (read_frame n t) as Hframe.
  (* forward_call also consumed `result = _t'1`. The if's only fall-through path is the dead `count = SYS_BUFSIZE_MAX`
     assignment (impossible under count <= SYS_BUFSIZE_MAX); its post is False. *)
  forward_if (PROP (False) LOCAL () SEP ()).
  { (* 0 <= result: return it *)
    match goal with
    | Hc : Int64.signed (Int64.repr 0) <= Int64.signed (Int64.repr _) |- _ => norm_cmp Hc
    | Hc : Int64.lt _ _ = false |- _ => norm_cmp Hc
    | _ => idtac
    end.
    assert (E : (read_ret (read_n n t) <? 0) = false) by (apply Z.ltb_ge; lia).
    rewrite E.
    forward.
    Exists (read_ret (read_n n t)) e2 (read_bytes (read_n n t)) (read_world (read_n n t)).
    rewrite E. entailer!.
    apply Hcont. apply sr_done; lia. }
  assert (E : (read_ret (read_n n t) <? 0) = true) by (apply Z.ltb_lt; lia).
  rewrite E.
  assert (He2eq : e2 = read_errno (read_n n t)) by (apply He2; lia).
  subst e2.
  pose proof (read_error_errno n t ltac:(lia) ltac:(assumption) ltac:(lia)) as Herrno.
  unfold errno_at.
  forward.
  forward_if (PROP (False) LOCAL () SEP ()).
  { (* errno == EINTR: continue *)
    match goal with Hc : Int.eq _ _ = _ |- _ => norm_cmp Hc | _ => idtac end.
    destruct Hframe as (Hf1 & Hf2 & Hf3 & Hf4 & Hf5 & Hf6).
    assert (Hin' : in_fd (read_world (read_n n t)) = in_fd s) by congruence.
    assert (Heintr : read_errno (read_n n t) = EINTR).
    { unfold EINTR.
      match goal with
      | Hc : Int.repr _ = Int.repr _ |- _ => apply repr_inj_signed in Hc; rep_lia
      | Hc : read_errno (read_n n t) = _ |- _ => lia
      | |- _ => idtac "no matching hypothesis"
      end. }
    assert (Hcont' : forall r e' bs t', SafeRead n (read_world (read_n n t)) r e' bs t' ->
                                        SafeRead n s r e' bs t').
    { intros r e' bs t' Hsr. apply Hcont. apply sr_eintr; auto. }
    forward.
    Exists (read_world (read_n n t)) (read_errno (read_n n t)).
    entailer!. }
  (* errno != EINTR: the EINVAL shrink test *)
  match goal with Hc : Int.eq _ _ = _ |- _ => norm_cmp Hc | _ => idtac end.
  forward.
  forward_if (EX flag : Z,
    PROP (flag = 0)
    LOCAL (temp _t'2 (Vint (Int.repr flag)); temp _result (Vlong (Int64.repr (read_ret (read_n n t))));
           temp _fd (Vint (Int.repr (in_fd t))); temp _buf p;
           temp _count (Vlong (Int64.repr n)); gvars gv)
    SEP (has_ext (read_world (read_n n t)); data_at_ sh (tarray tuchar n) p;
         data_at Ews tint (Vint (Int.repr (read_errno (read_n n t)))) (gv _errno))).
  { (* errno == EINVAL: SYS_BUFSIZE_MAX < count is false under the count bound *)
    forward.
    Exists 0. entailer!.
    unfold Int64.cmpu, Int64.ltu. rewrite !Int64.unsigned_repr by rep_lia.
    rewrite zlt_false by lia. reflexivity. }
  { forward. Exists 0. entailer!. }
  Intros flag. subst flag.
  forward_if.
  { forward. entailer!.
    all: try (match goal with Hc : typed_true _ _ |- _ =>
                apply typed_true_tint_Vint in Hc; exfalso; apply Hc; reflexivity end). }
  forward.
  destruct (read_error_shape n t ltac:(lia) ltac:(lia)) as (Hm1 & _).
  assert (Hfail : SafeRead n s (-1) (read_errno (read_n n t)) [] (read_world (read_n n t))).
  { apply Hcont. apply sr_fail; [lia |].
    unfold EINTR. intro Heq.
    match goal with
    | Hc : Int.repr _ <> Int.repr _ |- _ => apply Hc; rewrite Heq; reflexivity
    | Hc : read_errno (read_n n t) <> _ |- _ => lia
    | |- _ => idtac "no matching hypothesis"
    end. }
  Exists (-1) (read_errno (read_n n t)) (@nil byte) (read_world (read_n n t)).
  rewrite Hm1.
  entailer!.
  all: try (Intros; contradiction).
Qed.
