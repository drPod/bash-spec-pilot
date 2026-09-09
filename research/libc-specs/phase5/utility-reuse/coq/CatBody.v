(* semax_body for the generated GNU coreutils simple_cat (cat_fragment.v,
   byte-extracted from cat.c) against the wrapper contracts safe_read_spec /
   full_write_spec and the assumed externals quotearg_n_style_colon, error,
   write_error (non-returning). *)
Require Import VST.floyd.proofauto.
Require Import IOWorld IOSpecs.
Require Import cat_fragment.
Import IOW.
Local Open Scope Z_scope.

Definition Vprog : varspecs. mk_varspecs prog. Defined.

Lemma cenv_ok : @cenv_cs CompSpecs = prog_comp_env prog.
Proof. reflexivity. Qed.

Definition Gprog : funspecs :=
  ltac:(with_library prog [safe_read_spec _errno _safe_read; full_write_spec _errno _full_write;
                           quotearg_spec _quotearg_n_style_colon; error_spec _error;
                           write_error_spec _write_error;
                           simple_cat_spec _errno _simple_cat _input_desc _infile]).

Lemma body_simple_cat :
  semax_body Vprog Gprog f_simple_cat (simple_cat_spec _errno _simple_cat _input_desc _infile).
Proof.
  start_function.
  assert_PROP (field_compatible (tarray tuchar n) [] p) as Hfc by entailer!.
  forward_loop (EX t : world, EX e1 : Z,
    PROP (valid_world t; in_fd t = in_fd s; out_fd t = 1; CatLoop n s e t e1)
    LOCAL (temp _buf p; temp _bufsize (Vlong (Int64.repr n)); gvars gv)
    SEP (has_ext t; data_at_ sh (tarray tuchar n) p; errno_at (gv _errno) e1;
         data_at Ews tint (Vint (Int.repr (in_fd s))) (gv _input_desc);
         data_at Ews (tptr tschar) name (gv _infile))).
  { Exists s e. entailer!. apply cl_start. }
  Intros t e1.
  forward.
  match goal with Hx : in_fd t = in_fd s |- _ => rename Hx into Hin end.
  rewrite <- Hin.
  repeat simple apply seq_assoc1.
  forward_call (gv, t, p, n, e1, sh).
  all: try solve [entailer!].
  all: try solve [repeat split; auto; rep_lia].
  Intros ret. destruct ret as [[[r e2] bs] t2]. simpl fst in *; simpl snd in *.
  match goal with Hx : SafeRead _ _ _ _ _ _ |- _ => rename Hx into Hsr end.
  pose proof (SafeRead_ret_bounds n t r e2 bs t2 ltac:(lia) Hsr) as Hr.
  destruct (SafeRead_conservation n t r e2 bs t2 ltac:(lia) Hsr) as (Hb & Hd & Hi & Ho & Hg & Hw).
  pose proof (SafeRead_valid n t r e2 bs t2 ltac:(assumption) Hsr) as Hv2.
  forward.
  forward_if.
  { (* n_read == SAFE_READ_ERROR: report errno, return false *)
    match goal with Hc : Int64.eq _ _ = _ |- _ => norm_cmp Hc | _ => idtac end.
    assert (Hm1 : r = -1).
    { match goal with
      | Hc : Int64.repr r = Int64.repr _ |- _ => apply repr_inj_signed64 in Hc; rep_lia
      | Hc : r = _ |- _ => lia
      | |- _ => idtac "no matching hypothesis"
      end. }
    subst r.
    assert (E : ((-1) <? 0) = true) by reflexivity. rewrite E.
    forward.
    repeat simple apply seq_assoc1.
    forward_call (0, 3, name).
    all: try solve [entailer!].
    all: try solve [repeat split; auto; rep_lia].
    Intros q.
    unfold errno_at. forward.
    repeat simple apply seq_assoc1.
    forward_call (t2, e2, gv ___stringlit_1, q).
    all: try solve [entailer!].
    all: try solve [repeat split; auto; rep_lia].
    forward.
    rewrite Hin.
    Exists false (report e2 t2) e2. unfold errno_at. entailer!.
    all: try (eapply co_error; eauto). }
  match goal with Hc : Int64.eq _ _ = _ |- _ => norm_cmp Hc | _ => idtac end.
  assert (Hnm1 : r <> -1).
  { intro Eq. subst r.
    match goal with
    | Hc : Int64.repr (-1) <> Int64.repr _ |- _ => apply Hc; reflexivity
    | Hc : -1 <> -1 |- _ => contradiction
    end. }
  forward_if.
  { (* n_read == 0: EOF, return true *)
    match goal with Hc : Int64.eq _ _ = _ |- _ => norm_cmp Hc | _ => idtac end.
    assert (Hz : r = 0).
    { match goal with
      | Hc : Int64.repr r = Int64.repr _ |- _ => apply repr_inj_signed64 in Hc; rep_lia
      | Hc : Int64.repr r = Int64.zero |- _ =>
          change Int64.zero with (Int64.repr 0) in Hc; apply repr_inj_signed64 in Hc; rep_lia
      | Hc : r = _ |- _ => lia
      | |- _ => idtac "no matching hypothesis"
      end. }
    subst r.
    destruct (SafeRead_zero n t 0 e2 bs t2 ltac:(lia) Hsr eq_refl) as [_ Hbs]. subst bs.
    assert (E : (0 <? 0) = false) by reflexivity. rewrite E.
    forward.
    rewrite Hin.
    Exists true t2 e2. entailer!.
    all: try (eapply co_eof; eauto).
    all: try (apply buffer_prefix_n_forget; [assumption | rewrite Zlength_nil; lia]). }
  match goal with Hc : Int64.eq _ _ = _ |- _ => norm_cmp Hc | _ => idtac end.
  assert (Hpos : 0 < r).
  { assert (r <> 0).
    { intro Eq. subst r.
      match goal with
      | Hc : Int64.repr 0 <> Int64.repr _ |- _ => apply Hc; reflexivity
      | Hc : Int64.repr 0 <> Int64.zero |- _ => apply Hc; reflexivity
      | Hc : 0 <> 0 |- _ => contradiction
      end. }
    lia. }
  pose proof (SafeRead_length n t r e2 bs t2 ltac:(lia) Hsr ltac:(lia)) as Hlen.
  assert (E : (r <? 0) = false) by (apply Z.ltb_ge; lia). rewrite E.
  pose proof (buffer_prefix_n_forget sh p n bs Hfc ltac:(lia)) as Hforget.
  unfold buffer_prefix_n in *.
  rewrite <- Hlen.
  assert (Hout2 : out_fd t2 = 1) by congruence.
  rewrite <- Hout2.
  repeat simple apply seq_assoc1.
  forward_call (gv, t2, p, bs, e2, sh).
  all: try solve [entailer!].
  all: try solve [repeat split; auto; rep_lia].
  Intros ret2. destruct ret2 as [[total e3] t3]. simpl fst in *; simpl snd in *.
  match goal with Hx : FullWrite _ _ _ _ _ _ |- _ => rename Hx into Hfw end.
  pose proof (FullWrite_total_bounds _ _ _ _ _ _ Hfw) as Htot.
  destruct (FullWrite_effect _ _ _ _ _ _ Hfw) as (Hd3 & Hu3 & Hi3 & Ho3 & Hg3 & _).
  pose proof (FullWrite_valid _ _ _ _ _ _ Hv2 Hfw) as Hv3.
  forward_if.
  { (* full_write returned less than n_read: write_error() does not return *)
    repeat simple apply seq_assoc1.
    forward_call t3.
    entailer!. }
  (* full_write transferred everything: next chunk *)
  match goal with Hc : Int64.eq _ _ = _ |- _ => norm_cmp Hc | _ => idtac end.
  assert (Htot' : total = Zlength bs).
  { match goal with
    | Hc : Int64.repr total = Int64.repr _ |- _ => apply repr_inj_signed64 in Hc; rep_lia
    | Hc : total = _ |- _ => lia
    | |- _ => idtac "no matching hypothesis"
    end. }
  subst total.
  rewrite Hlen in Hfw.
  assert (Hin3 : in_fd t3 = in_fd s) by congruence.
  assert (Hout3 : out_fd t3 = out_fd t2) by congruence.
  assert (Hout3' : out_fd t3 = 1) by congruence.
  assert (Hloop3 : CatLoop n s e t3 e3) by (eapply cl_chunk; eauto).
  forward.
  rewrite Hin.
  Exists t3 e3.
  entailer!.
  all: try (apply Hforget).
  all: try (rewrite sepcon_comm; apply Hforget).
  all: try (sep_apply Hforget; cancel).
Qed.
