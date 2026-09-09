(* semax_body for the generated gnulib safe_write (safe_write.v) against the
   generalized contracts. Partial correctness in VST's logic under write_spec.
   gnulib builds safe_write by `#define SAFE_WRITE` + `#include "safe-read.c"`;
   the generated f_safe_write is f_safe_read modulo the names read/write and
   safe_read/safe_write (generated/safe_read.v vs safe_write.v), so this file
   is the checked SafeReadBody.v script transferred to the write-side model
   (write_n / SafeWrite and the write_* lemmas of IOWorld.v). *)
Require Import VST.floyd.proofauto.
Require Import IOWorld IOSpecs.
Require Import safe_write.
Import IOW.
Local Open Scope Z_scope.

Definition Vprog : varspecs. mk_varspecs prog. Defined.

Lemma cenv_ok : @cenv_cs CompSpecs = prog_comp_env prog.
Proof. reflexivity. Qed.

Definition Gprog : funspecs :=
  ltac:(with_library prog [write_spec _errno _write; safe_write_spec _errno _safe_write]).

Lemma body_safe_write : semax_body Vprog Gprog f_safe_write (safe_write_spec _errno _safe_write).
Proof.
  start_function.
  forward_loop (EX t : world, EX e1 : Z,
    PROP (valid_world t; out_fd t = out_fd s;
          forall r e' out t', SafeWrite bs t r e' out t' -> SafeWrite bs s r e' out t')
    LOCAL (temp _fd (Vint (Int.repr (out_fd t))); temp _buf p;
           temp _count (Vlong (Int64.repr (Zlength bs))); gvars gv)
    SEP (has_ext t; byte_array sh p bs; errno_at (gv _errno) e1))
  continue: (EX t : world, EX e1 : Z,
    PROP (valid_world t; out_fd t = out_fd s;
          forall r e' out t', SafeWrite bs t r e' out t' -> SafeWrite bs s r e' out t')
    LOCAL (temp _fd (Vint (Int.repr (out_fd t))); temp _buf p;
           temp _count (Vlong (Int64.repr (Zlength bs))); gvars gv)
    SEP (has_ext t; byte_array sh p bs; errno_at (gv _errno) e1)).
  { Exists s e. entailer!. }
  Intros t e1.
  apply -> semax_skip_seq. abbreviate_semax.
  match goal with Hk : forall r e' out t', SafeWrite _ _ _ _ _ _ -> _ |- _ => rename Hk into Hcont end.
  forward_call (gv, t, p, bs, e1, sh).
  all: try solve [entailer!].
  all: try solve [repeat split; auto; rep_lia].
  Intros e2.
  match goal with Hx : write_ret (write_n bs t) < 0 -> e2 = _ |- _ => rename Hx into He2 end.
  pose proof (write_ret_bounds bs t) as Hbounds.
  pose proof (write_valid bs t ltac:(assumption)) as Hvalid'.
  pose proof (write_frame bs t) as Hframe.
  pose proof (Zlength_nonneg bs) as Hlen.
  (* forward_call also consumed `result = _t'1`. The if's only fall-through path is the dead `count = SYS_BUFSIZE_MAX`
     assignment (impossible under count <= SYS_BUFSIZE_MAX); its post is False. *)
  forward_if (PROP (False) LOCAL () SEP ()).
  { (* 0 <= result: return it *)
    match goal with
    | Hc : Int64.signed (Int64.repr 0) <= Int64.signed (Int64.repr _) |- _ => norm_cmp Hc
    | Hc : Int64.lt _ _ = false |- _ => norm_cmp Hc
    | _ => idtac
    end.
    forward.
    Exists (write_ret (write_n bs t)) e2 (write_bytes (write_n bs t)) (write_world (write_n bs t)).
    entailer!.
    apply Hcont. apply sw_done; lia. }
  assert (He2eq : e2 = write_errno (write_n bs t)) by (apply He2; lia).
  subst e2.
  pose proof (write_error_errno bs t ltac:(assumption) ltac:(lia)) as Herrno.
  unfold errno_at.
  forward.
  forward_if (PROP (False) LOCAL () SEP ()).
  { (* errno == EINTR: continue *)
    match goal with Hc : Int.eq _ _ = _ |- _ => norm_cmp Hc | _ => idtac end.
    destruct Hframe as (Hf1 & Hf2 & Hf3 & Hf4 & Hf5 & Hf6 & Hf7).
    assert (Hout' : out_fd (write_world (write_n bs t)) = out_fd s) by congruence.
    assert (Heintr : write_errno (write_n bs t) = EINTR).
    { unfold EINTR.
      match goal with
      | Hc : Int.repr _ = Int.repr _ |- _ => apply repr_inj_signed in Hc; rep_lia
      | Hc : write_errno (write_n bs t) = _ |- _ => lia
      | |- _ => idtac "no matching hypothesis"
      end. }
    assert (Hcont' : forall r e' out t', SafeWrite bs (write_world (write_n bs t)) r e' out t' ->
                                         SafeWrite bs s r e' out t').
    { intros r e' out t' Hsw. apply Hcont. apply sw_eintr; auto. }
    forward.
    Exists (write_world (write_n bs t)) (write_errno (write_n bs t)).
    entailer!. }
  (* errno != EINTR: the EINVAL shrink test *)
  match goal with Hc : Int.eq _ _ = _ |- _ => norm_cmp Hc | _ => idtac end.
  forward.
  forward_if (EX flag : Z,
    PROP (flag = 0)
    LOCAL (temp _t'2 (Vint (Int.repr flag)); temp _result (Vlong (Int64.repr (write_ret (write_n bs t))));
           temp _fd (Vint (Int.repr (out_fd t))); temp _buf p;
           temp _count (Vlong (Int64.repr (Zlength bs))); gvars gv)
    SEP (has_ext (write_world (write_n bs t)); byte_array sh p bs;
         data_at Ews tint (Vint (Int.repr (write_errno (write_n bs t)))) (gv _errno))).
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
  destruct (write_error_shape bs t ltac:(lia)) as (Hm1 & _).
  assert (Hfail : SafeWrite bs s (-1) (write_errno (write_n bs t)) [] (write_world (write_n bs t))).
  { apply Hcont. apply sw_fail; [lia |].
    unfold EINTR. intro Heq.
    match goal with
    | Hc : Int.repr _ <> Int.repr _ |- _ => apply Hc; rewrite Heq; reflexivity
    | Hc : write_errno (write_n bs t) <> _ |- _ => lia
    | |- _ => idtac "no matching hypothesis"
    end. }
  Exists (-1) (write_errno (write_n bs t)) (@nil byte) (write_world (write_n bs t)).
  rewrite Hm1.
  entailer!.
  all: try (Intros; contradiction).
Qed.
