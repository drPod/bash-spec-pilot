(* semax_body for the generated GNU coreutils wc_lines (wc_lines_fragment.v,
   byte-extracted from wc.c, whole function incl. both counting branches)
   against safe_read_spec (reused unchanged from utility-reuse), quotearg_spec
   / error_spec (reused), rawmemchr_spec (new glibc trust boundary) and
   wc_lines_spec (CaseSpecs.v). Idioms carried over from HeadBytesBody.v:
   buffer first in SEP, flatten_sepcon_in_SEP after every split,
   `repeat simple apply seq_assoc1` before each forward_call. *)
Require Import VST.floyd.proofauto.
Require Import IOWorld CaseWorld.
Require Import IOSpecs CaseSpecs.
Require Body.
Require Import wc_lines_fragment.
Import IOW.
Local Open Scope Z_scope.

Definition Vprog : varspecs. mk_varspecs prog. Defined.

Lemma cenv_ok : @cenv_cs CompSpecs = prog_comp_env prog.
Proof. reflexivity. Qed.

(* ---- local buffer lemmas: `char buf[BUFFER_SIZE + 1]` = tarray tschar 16385;
   safe_read_spec reads at most 16384 bytes into it, the last byte is the
   sentinel slot of the long-line arm. *)
Lemma buf_tschar_tuchar sh p :
  @data_at_ CompSpecs sh (tarray tschar 16385) p =
  @data_at_ CompSpecs sh (tarray tuchar 16385) p.
Proof.
  rewrite <- (memory_block_data_at__tarray_tschar_eq sh p 16385 ltac:(rep_lia)).
  rewrite <- (memory_block_data_at__tarray_tuchar_eq sh p 16385 ltac:(rep_lia)).
  reflexivity.
Qed.

Lemma buf_split sh p : field_compatible (tarray tuchar 16385) [] p ->
  @data_at_ CompSpecs sh (tarray tschar 16385) p =
  (@data_at_ CompSpecs sh (tarray tuchar 16384) p *
   @data_at_ CompSpecs sh (tarray tuchar 1) (offset_val 16384 p))%logic.
Proof.
  intros Hfc. rewrite buf_tschar_tuchar. unfold tarray.
  rewrite (split2_data_at__Tarray_tuchar sh 16385 16384 p ltac:(lia) (field_compatible_isptr _ _ _ Hfc) Hfc).
  rewrite (Body.tuchar_subarray_offset 16385 16384 p Hfc ltac:(lia)). reflexivity.
Qed.

Lemma buf_join sh p : field_compatible (tarray tuchar 16385) [] p ->
  @data_at_ CompSpecs sh (tarray tuchar 16384) p *
  @data_at_ CompSpecs sh (tarray tuchar 1) (offset_val 16384 p)
  |-- @data_at_ CompSpecs sh (tarray tschar 16385) p.
Proof. intros. rewrite (buf_split sh p); auto. Qed.

(* tschar sibling of relay Body.tuchar_subarray_offset *)
Lemma tschar_subarray_offset n off p :
  field_compatible (tarray tschar n) [] p -> 0 <= off <= n ->
  field_address0 (tarray tschar n) [ArraySubsc off] p = offset_val off p.
Proof.
  intros Hfc Hoff.
  rewrite field_address0_offset.
  2:{ eapply field_compatible0_cons_Tarray; [reflexivity | exact Hfc | lia]. }
  f_equal. unfold nested_field_offset; simpl. lia.
Qed.

(* After a successful read of bs into the first 16384 bytes: view the whole
   local buffer as one tschar array whose first |bs| entries are the bytes
   (needed for the byte loop's loads and the sentinel store). *)
Lemma buf_view sh p bs : field_compatible (tarray tschar 16385) [] p -> 0 <= Zlength bs <= 16384 ->
  byte_array sh p bs *
  @data_at_ CompSpecs sh (tarray tuchar (16384 - Zlength bs)) (offset_val (Zlength bs) p) *
  @data_at_ CompSpecs sh (tarray tuchar 1) (offset_val 16384 p)
  |-- @data_at CompSpecs sh (tarray tschar 16385) (map Vbyte bs ++ Zrepeat Vundef (16385 - Zlength bs)) p.
Proof.
  intros Hfc Hlen.
  rewrite (split2_data_at_Tarray_app (Zlength bs) 16385 sh tschar (map Vbyte bs)
             (Zrepeat Vundef (16385 - Zlength bs)) p)
    by (rewrite ?Zlength_map, ?Zlength_Zrepeat; lia).
  rewrite (tschar_subarray_offset 16385 (Zlength bs) p Hfc ltac:(lia)).
  unfold Specs.byte_array.
  rewrite (data_at_tarray_tschar_tuchar sh (Zlength bs) bs p).
  rewrite <- (data_at__tarray' sh tschar (16385 - Zlength bs) (Zrepeat Vundef (16385 - Zlength bs)))
    by reflexivity.
  rewrite sepcon_assoc. apply sepcon_derives; [apply derives_refl |].
  rewrite <- (memory_block_data_at__tarray_tschar_eq sh (offset_val (Zlength bs) p) (16385 - Zlength bs) ltac:(rep_lia)).
  rewrite <- (memory_block_data_at__tarray_tuchar_eq sh (offset_val (Zlength bs) p) (16384 - Zlength bs) ltac:(rep_lia)).
  rewrite <- (memory_block_data_at__tarray_tuchar_eq sh (offset_val 16384 p) 1 ltac:(rep_lia)).
  destruct Hfc as (Hp & _ & Hsz & _).
  destruct p; try contradiction. simpl in Hsz. simpl offset_val.
  rewrite !Ptrofs.add_unsigned.
  rewrite (Ptrofs.unsigned_repr (Zlength bs)) by rep_lia.
  rewrite (Ptrofs.unsigned_repr 16384) by rep_lia.
  replace (16385 - Zlength bs) with ((16384 - Zlength bs) + 1) by lia.
  rewrite (memory_block_split sh b (Ptrofs.unsigned i + Zlength bs) (16384 - Zlength bs) 1) by rep_lia.
  replace (Ptrofs.unsigned i + Zlength bs + (16384 - Zlength bs)) with (Ptrofs.unsigned i + 16384) by lia.
  apply derives_refl.
Qed.

(* ---- pointer-into-buffer lemmas (VST's canonical form for `*p` is
   field_address (tarray tschar 16385) [ArraySubsc i] buf). *)
Lemma buf_fa i p : field_compatible (tarray tschar 16385) [] p -> 0 <= i < 16385 ->
  field_address (tarray tschar 16385) [ArraySubsc i] p = offset_val i p.
Proof.
  intros Hfc Hi. rewrite field_address_offset.
  2:{ eapply field_compatible_cons_Tarray; [reflexivity | exact Hfc | lia]. }
  f_equal. unfold nested_field_offset; simpl. lia.
Qed.

Lemma buf_fa_isptr i p : field_compatible (tarray tschar 16385) [] p -> 0 <= i < 16385 ->
  isptr (field_address (tarray tschar 16385) [ArraySubsc i] p).
Proof.
  intros Hfc Hi. rewrite buf_fa by auto. destruct Hfc as (Hp & _). destruct p; try contradiction; exact I.
Qed.

Lemma buf_size_bound p : field_compatible (tarray tschar 16385) [] p ->
  exists b o, p = Vptr b o /\ Ptrofs.unsigned o + 16385 < Ptrofs.modulus.
Proof.
  intros (Hp & _ & Hsz & _). destruct p; try contradiction.
  exists b, i. split; [reflexivity |]. simpl in Hsz. lia.
Qed.

Lemma buf_fa_inj i j p : field_compatible (tarray tschar 16385) [] p ->
  0 <= i < 16385 -> 0 <= j < 16385 ->
  field_address (tarray tschar 16385) [ArraySubsc i] p =
  field_address (tarray tschar 16385) [ArraySubsc j] p -> i = j.
Proof.
  intros Hfc Hi Hj Heq. rewrite !buf_fa in Heq by auto.
  destruct (buf_size_bound p Hfc) as (b & o & -> & Hb).
  apply (f_equal (fun v => match v with Vptr _ o' => Ptrofs.unsigned o' | _ => 0 end)) in Heq.
  cbv beta iota delta [offset_val] in Heq.
  rewrite !Ptrofs.add_unsigned in Heq.
  rewrite (Ptrofs.unsigned_repr i) in Heq by rep_lia.
  rewrite (Ptrofs.unsigned_repr j) in Heq by rep_lia.
  rewrite !Ptrofs.unsigned_repr in Heq by rep_lia. lia.
Qed.

Lemma buf_ptr_succ i p : field_compatible (tarray tschar 16385) [] p -> 0 <= i -> i + 1 < 16385 ->
  force_val (sem_add_ptr_int tschar Signed (field_address (tarray tschar 16385) [ArraySubsc i] p)
               (Vint (Int.repr 1))) =
  field_address (tarray tschar 16385) [ArraySubsc (i + 1)] p.
Proof.
  intros Hfc Hi Hi1.
  rewrite (sem_add_pi_ptr_special tschar _ 1 Signed) by (first [reflexivity | apply buf_fa_isptr; auto; lia | rep_lia]).
  simpl force_val. replace (sizeof tschar * 1) with 1 by reflexivity.
  rewrite !buf_fa by (auto; lia). rewrite offset_offset_val. first [reflexivity | (f_equal; lia)].
Qed.

(* `p + 1` as VST evaluates it (pointer + int) *)
Lemma buf_ptr_succ' i p : field_compatible (tarray tschar 16385) [] p -> 0 <= i -> i + 1 < 16385 ->
  force_val (sem_binary_operation' Oadd (tptr tschar) tint
               (field_address (tarray tschar 16385) [ArraySubsc i] p) (Vint (Int.repr 1))) =
  field_address (tarray tschar 16385) [ArraySubsc (i + 1)] p.
Proof. intros. rewrite <- buf_ptr_succ by auto. reflexivity. Qed.

Lemma buf_valid_ptr vl p i : 0 <= i < 16385 ->
  @data_at CompSpecs Tsh (tarray tschar 16385) vl p |--
  valid_pointer (field_address (tarray tschar 16385) [ArraySubsc i] p).
Proof.
  intros Hi. entailer!.
  rewrite buf_fa by auto.
  eapply derives_trans; [apply data_at_memory_block |].
  apply memory_block_valid_pointer; [simpl; lia | apply readable_nonidentity, readable_share_top].
Qed.
#[local] Hint Extern 1 (data_at _ _ _ _ |-- valid_pointer _) => (apply buf_valid_ptr; lia) : valid_pointer.

Lemma is_int8_Vbyte b : is_int I8 Signed (Vbyte b).
Proof.
  unfold Vbyte. simpl. pose proof (Byte.signed_range b).
  rewrite Int.signed_repr by rep_lia.
  change Byte.min_signed with (-128) in *; change Byte.max_signed with 127 in *. lia.
Qed.

Lemma tc_val_tschar_Vbyte b : tc_val tschar (Vbyte b).
Proof. apply is_int8_Vbyte. Qed.

(* the byte test `*p == '\n'` on a tschar value vs. the model's is_nl *)
Lemma int_eq_nl b : Int.eq (Int.repr (Byte.signed b)) (Int.repr 10) = is_nl b.
Proof.
  unfold is_nl. pose proof (Byte.signed_range b) as Hr.
  destruct (Byte.eq_dec b (Byte.repr 10)) as [-> | Hne].
  - rewrite Byte.eq_true. reflexivity.
  - rewrite Byte.eq_false by auto.
    apply Int.eq_false. intro Heq. apply Hne.
    apply repr_inj_signed in Heq; try rep_lia.
    rewrite <- (Byte.repr_signed b). rewrite Heq. reflexivity.
Qed.

Lemma count_nl_sublist_succ bs i : 0 <= i < Zlength bs ->
  count_nl (sublist 0 (i + 1) bs) = count_nl (sublist 0 i bs) + (if is_nl (Znth i bs) then 1 else 0).
Proof.
  intros Hi. rewrite (sublist_split 0 i (i + 1)) by lia. rewrite sublist_len_1 by lia.
  apply count_nl_snoc.
Qed.

Lemma count_nl_sublist_all bs : count_nl (sublist 0 (Zlength bs) bs) = count_nl bs.
Proof. rewrite sublist_same by lia. reflexivity. Qed.

Lemma filter_all_false {A} (f : A -> bool) (l : list A) :
  Forall (fun x => f x = false) l -> filter f l = [].
Proof. induction 1; simpl; [reflexivity | rewrite H, IHForall; reflexivity]. Qed.

Lemma count_nl_sublist_nonl bs i j : 0 <= i <= j -> j <= Zlength bs ->
  (forall k, i <= k < j -> is_nl (Znth k bs) = false) ->
  count_nl (sublist 0 j bs) = count_nl (sublist 0 i bs).
Proof.
  intros Hij Hj Hno.
  rewrite (sublist_split 0 i j) by lia. rewrite count_nl_app.
  assert (Hz : count_nl (sublist i j bs) = 0).
  { unfold count_nl. rewrite filter_all_false; [reflexivity |].
    apply Forall_forall. intros x Hin.
    apply In_Znth_iff in Hin. destruct Hin as (k & Hk & <-).
    rewrite Zlength_sublist in Hk by lia. rewrite Znth_sublist by lia.
    apply Hno; lia. }
  lia.
Qed.

Lemma Vbyte_inj a b : Vbyte a = Vbyte b -> a = b.
Proof.
  unfold Vbyte. intro H.
  pose proof (Byte.signed_range a). pose proof (Byte.signed_range b).
  apply (f_equal (fun v => match v with Vint n => Int.signed n | _ => 0 end)) in H.
  cbv beta iota in H. rewrite !Int.signed_repr in H by rep_lia.
  rewrite <- (Byte.repr_signed a), <- (Byte.repr_signed b), H. reflexivity.
Qed.

Lemma buf_fa0 p : field_compatible (tarray tschar 16385) [] p ->
  field_address (tarray tschar 16385) [ArraySubsc 0] p = p.
Proof.
  intros Hfc. rewrite buf_fa by (auto; lia).
  apply isptr_offset_val_zero. apply (field_compatible_isptr _ _ _ Hfc).
Qed.

Lemma buf_fa_offset1 i p : field_compatible (tarray tschar 16385) [] p -> 0 <= i -> i + 1 < 16385 ->
  offset_val 1 (field_address (tarray tschar 16385) [ArraySubsc i] p) =
  field_address (tarray tschar 16385) [ArraySubsc (i + 1)] p.
Proof.
  intros Hfc Hi Hi1. rewrite !buf_fa by (auto; lia).
  rewrite offset_offset_val. first [reflexivity | (f_equal; lia)].
Qed.

(* contents of the buffer after a read of bs (plus, in the long arm, the sentinel) *)
Definition bufv (bs : list byte) : list val := map Vbyte bs ++ Zrepeat Vundef (16385 - Zlength bs).

Lemma bufv_Zlength bs : 0 <= Zlength bs <= 16384 -> Zlength (bufv bs) = 16385.
Proof. intros. unfold bufv. rewrite Zlength_app, Zlength_map, Zlength_Zrepeat; lia. Qed.

Lemma bufv_Znth bs i : 0 <= i < Zlength bs -> Znth i (bufv bs) = Vbyte (Znth i bs).
Proof.
  intros. unfold bufv. rewrite app_Znth1 by (rewrite Zlength_map; lia). rewrite Znth_map by lia. reflexivity.
Qed.

Ltac bool_contra :=
  exfalso;
  match goal with
  | H : typed_true _ _ |- _ =>
      first [ discriminate H | (hnf in H; simpl in H; congruence) | (vm_compute in H; discriminate) | inv H ]
  | H : typed_false _ _ |- _ =>
      first [ discriminate H | (hnf in H; simpl in H; congruence) | (vm_compute in H; discriminate) | inv H ]
  | H : False |- _ => exact H
  | H : Vptr _ _ = nullval |- _ => discriminate H
  | H : nullval = Vptr _ _ |- _ => discriminate H
  | H : Int.repr _ <> Int.repr _ |- _ => apply H; reflexivity
  | H : Int.repr _ = Int.repr _ |- _ => (vm_compute in H; discriminate) || (apply repr_inj_signed in H; rep_lia)
  | H : _ <> _ |- _ => apply H; reflexivity
  | H : _ = _ |- _ => (vm_compute in H; discriminate)
  end.

(* `end = buf + bytes_read` as VST evaluates it (array + unsigned long) *)
Lemma buf_end_addr p r : field_compatible (tarray tschar 16385) [] p -> 0 <= r <= 16384 ->
  force_val (sem_binary_operation' Oadd (tarray tschar 16385) tulong p (Vlong (Int64.repr r))) =
  field_address (tarray tschar 16385) [ArraySubsc r] p.
Proof.
  intros Hfc Hr. rewrite buf_fa by (auto; lia).
  rewrite <- (sem_add_ptr_long_tschar p r (field_compatible_isptr _ _ _ Hfc) ltac:(rep_lia)).
  reflexivity.
Qed.

Lemma bufv_tc bs k : 0 <= k < Zlength bs -> tc_val tschar (Znth k (bufv bs)).
Proof. intros. rewrite bufv_Znth by lia. apply tc_val_tschar_Vbyte. Qed.
#[local] Hint Extern 1 (tc_val tschar (Znth _ (bufv _))) => (apply bufv_tc; lia) : core.
#[local] Hint Extern 1 (is_int I8 Signed (Znth _ (bufv _))) => (apply bufv_tc; lia) : core.

(* the C update `lines += *p++ == '\n'` as VST evaluates it, vs. the model *)
Lemma lines_step L c :
  Int64.add (Int64.repr L)
    (Int64.repr (Int.signed (Int.repr (Z.b2z (Int.eq (Int.repr (Byte.signed c)) (Int.repr 10)))))) =
  Int64.repr (L + (if is_nl c then 1 else 0)).
Proof.
  rewrite add64_repr, int_eq_nl. destruct (is_nl c); simpl Z.b2z;
    rewrite Int.signed_repr by rep_lia; reflexivity.
Qed.

(* buffer contents after the long arm's sentinel store *)
Definition bufv' (bs : list byte) (r : Z) : list val := upd_Znth r (bufv bs) (Vbyte (Byte.repr 10)).

Lemma bufv'_Zlength bs r : 0 <= Zlength bs <= 16384 -> Zlength (bufv' bs r) = 16385.
Proof. intros. unfold bufv'. rewrite Zlength_upd_Znth. apply bufv_Zlength; auto. Qed.

Lemma bufv'_sentinel bs r : 0 <= Zlength bs <= 16384 -> 0 <= r < 16385 ->
  Znth r (bufv' bs r) = Vbyte (Byte.repr 10).
Proof.
  intros H Hr. pose proof (bufv_Zlength bs H) as HL. unfold bufv'.
  rewrite upd_Znth_same by lia. reflexivity.
Qed.

Lemma bufv'_Znth bs r k : 0 <= k < Zlength bs -> Zlength bs = r -> Zlength bs <= 16384 ->
  Znth k (bufv' bs r) = Vbyte (Znth k bs).
Proof.
  intros Hk Hr Hb. pose proof (bufv_Zlength bs ltac:(lia)) as HL. unfold bufv'.
  rewrite upd_Znth_diff by lia. apply bufv_Znth; lia.
Qed.

Lemma is_nl_true b : is_nl b = true -> b = Byte.repr 10.
Proof. unfold is_nl. apply Byte.same_if_eq. Qed.

(* ordered pointer comparison `p < end` inside the buffer (VST's tc and branch forms) *)
Lemma buf_test_order vl p a c : 0 <= a < 16385 -> 0 <= c < 16385 ->
  @data_at CompSpecs Tsh (tarray tschar 16385) vl p |--
  denote_tc_test_order (field_address (tarray tschar 16385) [ArraySubsc a] p)
                       (field_address (tarray tschar 16385) [ArraySubsc c] p).
Proof.
  intros Ha Hc. entailer!.
  rewrite !buf_fa by auto.
  destruct (buf_size_bound p H) as [bb [ofs [Hv Hbb]]]. rewrite Hv.
  unfold denote_tc_test_order, test_order_ptrs. simpl.
  destruct (peq bb bb) as [Heq | Hne]; [| exfalso; apply Hne; reflexivity]. simpl.
  apply andp_right.
  - change (Vptr bb (Ptrofs.add ofs (Ptrofs.repr a))) with (offset_val a (Vptr bb ofs)).
    eapply derives_trans; [apply data_at_memory_block |].
    apply memory_block_weak_valid_pointer; [simpl; lia | simpl; lia | apply readable_nonidentity, readable_share_top].
  - change (Vptr bb (Ptrofs.add ofs (Ptrofs.repr c))) with (offset_val c (Vptr bb ofs)).
    eapply derives_trans; [apply data_at_memory_block |].
    apply memory_block_weak_valid_pointer; [simpl; lia | simpl; lia | apply readable_nonidentity, readable_share_top].
Qed.
#[local] Hint Extern 1 (data_at _ _ _ _ |-- denote_tc_test_order _ _) => (apply buf_test_order; lia) : valid_pointer.

(* frame-tolerant form: any assertion that proves both pointers valid *)
Lemma buf_test_order_from_valid (P : mpred) p a c : field_compatible (tarray tschar 16385) [] p ->
  0 <= a < 16385 -> 0 <= c < 16385 ->
  (P |-- valid_pointer (field_address (tarray tschar 16385) [ArraySubsc a] p)) ->
  (P |-- valid_pointer (field_address (tarray tschar 16385) [ArraySubsc c] p)) ->
  P |-- denote_tc_test_order (field_address (tarray tschar 16385) [ArraySubsc a] p)
                             (field_address (tarray tschar 16385) [ArraySubsc c] p).
Proof.
  intros Hfc Ha Hc Hp Hq.
  rewrite (buf_fa a p Hfc Ha) in Hp |- *. rewrite (buf_fa c p Hfc Hc) in Hq |- *.
  destruct (buf_size_bound p Hfc) as [bb [ofs [Hv Hbb]]]. subst p.
  simpl offset_val in *.
  unfold denote_tc_test_order, test_order_ptrs. simpl.
  destruct (peq bb bb) as [Heq | Hne]; [| exfalso; apply Hne; reflexivity]. simpl.
  apply andp_right; apply valid_pointer_weak'; assumption.
Qed.

Lemma buf_cmp_lt p a c : field_compatible (tarray tschar 16385) [] p -> 0 <= a < 16385 -> 0 <= c < 16385 ->
  force_val (sem_cmp_pp Clt (field_address (tarray tschar 16385) [ArraySubsc a] p)
                            (field_address (tarray tschar 16385) [ArraySubsc c] p)) =
  bool2val (a <? c).
Proof.
  intros Hfc Ha Hc. rewrite !buf_fa by auto.
  destruct (buf_size_bound p Hfc) as [bb [ofs [-> Hbb]]].
  unfold sem_cmp_pp. simpl. unfold eq_block. rewrite peq_true. simpl.
  unfold Ptrofs.ltu. rewrite !Ptrofs.add_unsigned.
  rewrite (Ptrofs.unsigned_repr a) by rep_lia. rewrite (Ptrofs.unsigned_repr c) by rep_lia.
  rewrite !Ptrofs.unsigned_repr by rep_lia.
  destruct (zlt (Ptrofs.unsigned ofs + a) (Ptrofs.unsigned ofs + c)).
  - rewrite (proj2 (Z.ltb_lt a c)) by lia. reflexivity.
  - rewrite (proj2 (Z.ltb_ge a c)) by lia. reflexivity.
Qed.

(* the same comparison in the unfolded force_val form VST leaves in branch hypotheses *)
Lemma buf_cmp_lt' p a c : field_compatible (tarray tschar 16385) [] p -> 0 <= a < 16385 -> 0 <= c < 16385 ->
  match sem_cmp_pp Clt (field_address (tarray tschar 16385) [ArraySubsc a] p)
                       (field_address (tarray tschar 16385) [ArraySubsc c] p)
  with Some v' => v' | None => Vundef end = bool2val (a <? c).
Proof. intros. apply buf_cmp_lt; auto. Qed.

Definition Gprog : funspecs :=
  ltac:(with_library prog
    [safe_read_spec _errno _safe_read; quotearg_spec _quotearg_n_style_colon; error_spec _error;
     rawmemchr_spec _rawmemchr; wc_lines_spec _errno _wc_lines]).

Lemma body_wc_lines :
  semax_body Vprog Gprog f_wc_lines (wc_lines_spec _errno _wc_lines).
Proof.
  start_function.
  rewrite buf_tschar_tuchar.
  assert_PROP (field_compatible (tarray tuchar 16385) [] v_buf) as Hfc by entailer!.
  rewrite <- buf_tschar_tuchar.
  assert_PROP (field_compatible (tarray tschar 16385) [] v_buf) as Hfcs by entailer!.
  match goal with H : isptr lp |- _ => destruct lp; try contradiction end.
  match goal with H : isptr bp |- _ => destruct bp; try contradiction end.
  forward.  (* long_lines = false *)
  (* defensive null check; both out-pointers are valid here *)
  forward_if (PROP ()
    LOCAL (temp _t'1 (Vint (Int.repr 0)); temp _long_lines (Vint (Int.repr 0));
           temp _file fname; temp _fd (Vint (Int.repr (in_fd s))); temp _lines_out (Vptr b i);
           temp _bytes_out (Vptr b0 i0); lvar _buf (tarray tschar 16385) v_buf; gvars gv)
    SEP (data_at_ Tsh (tarray tschar 16385) v_buf; has_ext s; errno_at (gv _errno) e;
         data_at_ shl tulong (Vptr b i); data_at_ shb tulong (Vptr b0 i0))).
  { bool_contra. }
  { forward. entailer!.
    all: try (first [reflexivity | (simpl; reflexivity) | (vm_compute; reflexivity)]). }
  forward_if.
  { bool_contra. }
  forward. forward. forward.
  forward_loop (EX t : world, EX e1 : Z, EX lines : Z, EX bytes : Z, EX ll : bool,
    PROP (valid_world t; in_fd t = in_fd s; WcLoop 16384 s t lines bytes)
    LOCAL (temp _lines (Vlong (Int64.repr lines)); temp _bytes (Vlong (Int64.repr bytes));
           temp _long_lines (Vint (Int.repr (if ll then 1 else 0)));
           temp _file fname; temp _fd (Vint (Int.repr (in_fd s))); temp _lines_out (Vptr b i);
           temp _bytes_out (Vptr b0 i0); lvar _buf (tarray tschar 16385) v_buf; gvars gv)
    SEP (data_at_ Tsh (tarray tschar 16385) v_buf; has_ext t; errno_at (gv _errno) e1;
         data_at_ shl tulong (Vptr b i); data_at_ shb tulong (Vptr b0 i0)))
  break: (EX t : world, EX e1 : Z, EX lines : Z, EX bytes : Z,
    PROP (WcLines 16384 s true t lines bytes)
    LOCAL (temp _lines (Vlong (Int64.repr lines)); temp _bytes (Vlong (Int64.repr bytes));
           temp _lines_out (Vptr b i); temp _bytes_out (Vptr b0 i0);
           lvar _buf (tarray tschar 16385) v_buf; gvars gv)
    SEP (data_at_ Tsh (tarray tschar 16385) v_buf; has_ext t; errno_at (gv _errno) e1;
         data_at_ shl tulong (Vptr b i); data_at_ shb tulong (Vptr b0 i0))).
  { Exists s e 0 0 false. entailer!.
    all: try (first [apply wl_start | (repeat split; auto using wl_start) | reflexivity | (vm_compute; reflexivity)]). }
  { Intros t e1 lines bytes ll.
    match goal with Hx : in_fd t = in_fd s |- _ => rename Hx into Hin end.
    match goal with Hx : WcLoop _ _ _ _ _ |- _ => rename Hx into Hloop end.
    match goal with Hx : valid_world t |- _ => rename Hx into Hvt end.
    rewrite (buf_split Tsh v_buf Hfc). flatten_sepcon_in_SEP.
    assert_PROP (field_compatible (tarray tuchar 16384) [] v_buf) as Hfc84 by entailer!.
    rewrite <- Hin.
    repeat simple apply seq_assoc1.
    forward_call (gv, t, v_buf, 16384, e1, Tsh).
    all: try solve [repeat split; auto; first [apply writable_share_top | rep_lia | lia]].
    Intros r0. destruct r0 as [[[r e2] bs] t1]. simpl fst in *; simpl snd in *.
    match goal with Hx : SafeRead _ _ _ _ _ _ |- _ => rename Hx into Hsr end.
    assert (H16 : 0 <= 16384) by lia.
    pose proof (SafeRead_ret_bounds _ _ _ _ _ _ H16 Hsr) as Hrb.
    pose proof (SafeRead_valid _ _ _ _ _ _ Hvt Hsr) as Hv1.
    destruct (SafeRead_conservation _ _ _ _ _ _ H16 Hsr) as (Hb1 & Hd1 & Hi1 & Ho1 & Hg1 & Hw1).
    forward.  (* t'4 = (unsigned long) t'3 *)
    forward.  (* bytes_read = t'4 *)
    forward_if.
    2:{ (* t'4 <= 0 as unsigned: EOF (r = 0), break *)
      assert (Hz : r = 0).
      { match goal with
        | Hle : Int64.unsigned (Int64.repr 0) >= Int64.unsigned (Int64.repr r) |- _ =>
            change (Int64.unsigned (Int64.repr 0)) with 0 in Hle;
            destruct (Z.eq_dec r (-1)) as [-> | Hn1];
            [ change (Int64.unsigned (Int64.repr (-1))) with 18446744073709551615 in Hle; lia
            | rewrite Int64.unsigned_repr in Hle by rep_lia; lia ]
        | Hle : typed_false _ _ |- _ =>
            destruct (Z.eq_dec r (-1)) as [-> | Hn1];
            [ exfalso; first [ lia | (vm_compute in Hle; discriminate) ]
            | destruct (zlt 0 r) as [Hpos | Hnp]; [exfalso | lia];
              unfold Int64.ltu in Hle; rewrite !Int64.unsigned_repr in Hle by rep_lia;
              rewrite zlt_true in Hle by lia; first [discriminate | (vm_compute in Hle; discriminate)] ]
        | |- _ => lia
        end. }
      subst r.
      destruct (SafeRead_zero 16384 t 0 e2 bs t1 ltac:(lia) Hsr eq_refl) as [_ Hbs]. subst bs.
      assert (E : (0 <? 0) = false) by reflexivity. rewrite E.
      pose proof (buffer_prefix_n_forget Tsh v_buf 16384 [] Hfc84 ltac:(rewrite Zlength_nil; lia)) as Hforget.
      sep_apply Hforget. sep_apply (buf_join Tsh v_buf Hfc).
      forward.
      Exists t1 e2 lines bytes. entailer!.
      eapply wl_eof; eauto. }
    (* t'4 > 0 as unsigned: r <> 0 *)
    assert (Hnz : r <> 0).
    { intro Hz. subst r.
      match goal with
      | Hgt : Int64.unsigned (Int64.repr 0) < Int64.unsigned (Int64.repr 0) |- _ => lia
      | Hgt : typed_true _ _ |- _ => first [ lia | (vm_compute in Hgt; discriminate) | (hnf in Hgt; simpl in Hgt; congruence) ]
      | |- _ => lia
      end. }
    forward_if.
    { (* bytes_read == SAFE_READ_ERROR: diagnostic, return false *)
      match goal with Hc : Int64.eq _ _ = _ |- _ => norm_cmp Hc | _ => idtac end.
      assert (Hm1 : r = -1).
      { first [ match goal with Hc : Int64.repr r = Int64.repr _ |- _ => apply repr_inj_signed64 in Hc; rep_lia end | lia ]. }
      subst r.
      assert (E : ((-1) <? 0) = true) by reflexivity. rewrite E.
      sep_apply (buf_join Tsh v_buf Hfc).
      repeat simple apply seq_assoc1.
      forward_call (0, 3, fname).
      Intros q.
      unfold errno_at. forward.
      repeat simple apply seq_assoc1.
      forward_call (t1, e2, gv ___stringlit_1, q).
      forward.
      Exists (report e2 t1) e2 false lines bytes.
      entailer!.
      all: try (eapply wl_err; eauto; lia).
      all: try (simpl; cancel). }
    match goal with Hc : Int64.eq _ _ = _ |- _ => norm_cmp Hc | _ => idtac end.
    assert (Hnm1 : r <> -1).
    { intro Eq. subst r. first [ match goal with Hc : _ <> _ |- _ => solve [apply Hc; reflexivity] end | lia ]. }
    assert (Hpos : 0 < r) by lia.
    pose proof (SafeRead_length _ _ _ _ _ _ H16 Hsr (Z.lt_le_incl _ _ Hpos)) as Hlen.
    assert (E : (r <? 0) = false) by (apply Z.ltb_ge; lia). rewrite E.
    unfold buffer_prefix_n. flatten_sepcon_in_SEP.
    sep_apply (buf_view Tsh v_buf bs Hfcs ltac:(lia)).
    fold (bufv bs).
    forward.  (* bytes += bytes_read *)
    forward.  (* p = buf *)
    forward.  (* end = buf + bytes_read *)
    forward.  (* plines = lines *)
    rewrite add64_repr.
    rewrite (buf_end_addr v_buf r Hfcs ltac:(lia)).
    forward_if (EX vl : list val,
      PROP (Zlength vl = 16385)
      LOCAL (temp _lines (Vlong (Int64.repr (lines + count_nl bs)));
             temp _plines (Vlong (Int64.repr lines));
             temp _end (field_address (tarray tschar 16385) [ArraySubsc r] v_buf);
             temp _bytes (Vlong (Int64.repr (bytes + r)));
             temp _bytes_read (Vlong (Int64.repr r));
             temp _long_lines (Vint (Int.repr (if ll then 1 else 0)));
             temp _file fname; temp _fd (Vint (Int.repr (in_fd t)));
             temp _lines_out (Vptr b i); temp _bytes_out (Vptr b0 i0);
             lvar _buf (tarray tschar 16385) v_buf; gvars gv)
      SEP (data_at Tsh (tarray tschar 16385) vl v_buf; has_ext t1; errno_at (gv _errno) e2;
           data_at_ shl tulong (Vptr b i); data_at_ shb tulong (Vptr b0 i0))).
    { (* short-line arm: byte loop `while (p != end) lines += *p++ == '\n';` *)
      destruct ll; [bool_contra |].
      forward_while (EX k : Z,
        PROP (0 <= k <= r)
        LOCAL (temp _p (field_address (tarray tschar 16385) [ArraySubsc k] v_buf);
               temp _lines (Vlong (Int64.repr (lines + count_nl (sublist 0 k bs))));
               temp _plines (Vlong (Int64.repr lines));
               temp _end (field_address (tarray tschar 16385) [ArraySubsc r] v_buf);
               temp _bytes (Vlong (Int64.repr (bytes + r)));
               temp _bytes_read (Vlong (Int64.repr r));
               temp _long_lines (Vint (Int.repr 0));
               temp _file fname; temp _fd (Vint (Int.repr (in_fd t)));
               temp _lines_out (Vptr b i); temp _bytes_out (Vptr b0 i0);
               lvar _buf (tarray tschar 16385) v_buf; gvars gv)
        SEP (data_at Tsh (tarray tschar 16385) (bufv bs) v_buf; has_ext t1; errno_at (gv _errno) e2;
             data_at_ shl tulong (Vptr b i); data_at_ shb tulong (Vptr b0 i0))).
      { Exists 0. rewrite sublist_nil, count_nl_nil, Z.add_0_r. entailer!.
        all: try (first [apply buf_fa0; auto | (symmetry; apply buf_fa0; auto)]). }
      { entailer!. }
      { (* body: k < r because p <> end *)
        assert (Hk : k < r).
        { destruct (zlt k r) as [Hlt | Hge]; [assumption | exfalso].
          assert (k = r) by lia. subst k.
          match goal with
          | H : _ <> _ |- _ => solve [apply H; reflexivity]
          | H : typed_true _ _ |- _ => first [ (vm_compute in H; discriminate) | (hnf in H; simpl in H; congruence) ]
          end. }
        forward.  (* t'6 = p *)
        forward.  (* p = t'6 + 1 *)
        { (* tc: t'6 is a pointer *)
          entailer!.
          all: try (rewrite if_true by (eapply field_compatible_cons_Tarray; [reflexivity | exact Hfcs | lia])).
          all: try (apply isptr_offset_val'; apply (field_compatible_isptr _ _ _ Hfcs)).
          all: try (destruct (buf_size_bound v_buf Hfcs) as [bb [ofs [Hv Hbb]]]; rewrite Hv; exact I). }
        assert (Hzk : Znth k (bufv bs) = Vbyte (Znth k bs)) by (apply bufv_Znth; lia).
        unfold bufv in *.
        (* VST unfolded field_address in _t'6 while checking the pointer add; restore the canonical form *)
        assert (Hfck : field_compatible (tarray tschar 16385) [ArraySubsc k] v_buf)
          by (eapply field_compatible_cons_Tarray; [reflexivity | exact Hfcs | lia]).
        try rewrite if_true by exact Hfck.
        rewrite <- (field_address_offset (tarray tschar 16385) [ArraySubsc k] v_buf Hfck).
        rewrite (buf_ptr_succ' k v_buf Hfcs ltac:(lia) ltac:(lia)).
        forward.  (* t'9 = *t'6 *)
        { (* the loaded byte is a well-typed char *)
          entailer!.
          all: try (rewrite app_Znth1 by (rewrite Zlength_map; lia); rewrite Znth_map by lia;
                    first [apply is_int8_Vbyte | apply tc_val_tschar_Vbyte]). }
        rewrite app_Znth1 by (rewrite Zlength_map; lia). rewrite Znth_map by lia.
        forward.  (* lines = lines + (t'9 == 10) *)
        rewrite lines_step.
        Exists (k + 1). entailer!.
        all: try (rewrite count_nl_sublist_succ by lia; reflexivity).
        all: try (rewrite count_nl_sublist_succ by lia; f_equal; f_equal; lia). }
      (* loop exit: p == end, so k = r and every byte was counted *)
      assert (Hkr : k = r) by (apply (buf_fa_inj k r v_buf Hfcs ltac:(lia) ltac:(lia) HRE)).
      subst k.
      forward.  (* end of the then-branch (skip) *)
      Exists (bufv bs). unfold bufv. entailer!.
      all: try (rewrite Zlength_app, Zlength_map, Zlength_Zrepeat; lia).
      all: try (rewrite count_nl_sublist_all; reflexivity).
      all: try (rewrite <- Hlen, count_nl_sublist_all; reflexivity). }
    { (* long-line arm: sentinel store + rawmemchr loop *)
      destruct ll; [| bool_contra].
      forward.  (* *end = '\n' *)
      forward_loop (EX k : Z,
        PROP (0 <= k <= r)
        LOCAL (temp _p (field_address (tarray tschar 16385) [ArraySubsc k] v_buf);
               temp _lines (Vlong (Int64.repr (lines + count_nl (sublist 0 k bs))));
               temp _plines (Vlong (Int64.repr lines));
               temp _end (field_address (tarray tschar 16385) [ArraySubsc r] v_buf);
               temp _bytes (Vlong (Int64.repr (bytes + r)));
               temp _bytes_read (Vlong (Int64.repr r));
               temp _long_lines (Vint (Int.repr 1));
               temp _file fname; temp _fd (Vint (Int.repr (in_fd t)));
               temp _lines_out (Vptr b i); temp _bytes_out (Vptr b0 i0);
               lvar _buf (tarray tschar 16385) v_buf; gvars gv)
        SEP (data_at Tsh (tarray tschar 16385) (bufv' bs r) v_buf; has_ext t1; errno_at (gv _errno) e2;
             data_at_ shl tulong (Vptr b i); data_at_ shb tulong (Vptr b0 i0)))
      break: (PROP ()
        LOCAL (temp _lines (Vlong (Int64.repr (lines + count_nl bs)));
               temp _plines (Vlong (Int64.repr lines));
               temp _end (field_address (tarray tschar 16385) [ArraySubsc r] v_buf);
               temp _bytes (Vlong (Int64.repr (bytes + r)));
               temp _bytes_read (Vlong (Int64.repr r));
               temp _long_lines (Vint (Int.repr 1));
               temp _file fname; temp _fd (Vint (Int.repr (in_fd t)));
               temp _lines_out (Vptr b i); temp _bytes_out (Vptr b0 i0);
               lvar _buf (tarray tschar 16385) v_buf; gvars gv)
        SEP (data_at Tsh (tarray tschar 16385) (bufv' bs r) v_buf; has_ext t1; errno_at (gv _errno) e2;
             data_at_ shl tulong (Vptr b i); data_at_ shb tulong (Vptr b0 i0))).
      { Exists 0. rewrite sublist_nil, count_nl_nil, Z.add_0_r. unfold bufv', bufv.
        change (Vbyte (Byte.repr 10)) with (Vint (Int.repr 10)).
        entailer!.
        all: try (first [apply buf_fa0; auto | (symmetry; apply buf_fa0; auto)]). }
      { Intros k.
        repeat simple apply seq_assoc1.
        forward_call (Tsh, v_buf, 16385, bufv' bs r, k, Byte.repr 10).
        all: try solve [ repeat split; auto; try lia; try apply readable_share_top;
                         try (apply bufv'_Zlength; lia);
                         exists r; split; try lia; try (apply bufv'_sentinel; lia) ].
        Intros j.
        match goal with H : forall k0 : Z, _ -> Znth k0 _ <> _ |- _ => rename H into Hnone end.
        match goal with H : Znth j _ = Vbyte _ |- _ => rename H into Hj end.
        assert (Hjr : j <= r).
        { destruct (zlt r j) as [Hlt | Hge]; try lia. exfalso.
          apply (Hnone r ltac:(lia)). apply bufv'_sentinel; lia. }
        forward.  (* t'8 = t'7 cast to char pointer *)
        (* VST unfolded field_address in the cast result; restore the canonical form *)
        assert (Hfcj : field_compatible (tarray tschar 16385) [ArraySubsc j] v_buf)
          by (eapply field_compatible_cons_Tarray; [reflexivity | exact Hfcs | lia]).
        try rewrite if_true by exact Hfcj.
        try replace (0 + 1 * j) with j by lia.
        try rewrite <- (buf_fa j v_buf Hfcs ltac:(lia)).
        forward.  (* p = t'8 *)
        forward_if.
        { (* the ordered pointer comparison typechecks *)
          entailer!.
          all: try (rewrite <- (buf_fa j v_buf Hfcs ltac:(lia))).
          all: try (apply buf_test_order_from_valid; try lia; try exact Hfcs;
                    repeat apply sepcon_valid_pointer1; apply buf_valid_ptr; lia). }
        2:{ (* t'8 >= end: only the sentinel was found, j = r; break *)
          match goal with H : typed_false _ _ |- _ =>
            try replace (0 + 1 * j) with j in H by lia;
            try rewrite <- (buf_fa j v_buf Hfcs ltac:(lia)) in H;
            first [ rewrite (buf_cmp_lt' v_buf j r Hfcs ltac:(lia) ltac:(lia)) in H
                  | rewrite (buf_cmp_lt v_buf j r Hfcs ltac:(lia) ltac:(lia)) in H ];
            apply typed_false_of_bool in H; apply Z.ltb_ge in H
          end.
          assert (Hjr' : j = r) by lia. subst j.
          assert (Hskip : count_nl (sublist 0 k bs) = count_nl bs).
          { rewrite <- (count_nl_sublist_all bs). rewrite Hlen. symmetry.
            apply count_nl_sublist_nonl; try lia. intros k0 Hk0.
            specialize (Hnone k0 Hk0). rewrite bufv'_Znth in Hnone by lia.
            destruct (is_nl (Znth k0 bs)) eqn:Enl; [exfalso | reflexivity].
            apply is_nl_true in Enl. rewrite Enl in Hnone. apply Hnone; reflexivity. }
          forward.  (* break *)
          entailer!.
          all: try (rewrite Hskip; reflexivity).
          all: try (rewrite Hskip; f_equal). }
        (* t'8 < end: a newline at j < r; count it and continue after it *)
        match goal with H : typed_true _ _ |- _ =>
          try replace (0 + 1 * j) with j in H by lia;
          try rewrite <- (buf_fa j v_buf Hfcs ltac:(lia)) in H;
          first [ rewrite (buf_cmp_lt' v_buf j r Hfcs ltac:(lia) ltac:(lia)) in H
                | rewrite (buf_cmp_lt v_buf j r Hfcs ltac:(lia) ltac:(lia)) in H ];
          apply typed_true_of_bool in H; apply Z.ltb_lt in H
        end.
        assert (Hjnl : is_nl (Znth j bs) = true).
        { rewrite bufv'_Znth in Hj by lia. apply Vbyte_inj in Hj. rewrite Hj. unfold is_nl. apply Byte.eq_true. }
        assert (Hskip : count_nl (sublist 0 j bs) = count_nl (sublist 0 k bs)).
        { apply count_nl_sublist_nonl; try lia. intros k0 Hk0.
          specialize (Hnone k0 Hk0). rewrite bufv'_Znth in Hnone by lia.
          destruct (is_nl (Znth k0 bs)) eqn:Enl; [exfalso | reflexivity].
          apply is_nl_true in Enl. rewrite Enl in Hnone. apply Hnone; reflexivity. }
        try replace (0 + 1 * j) with j by lia.
        try rewrite <- (buf_fa j v_buf Hfcs ltac:(lia)).
        forward.  (* p = p + 1 *)
        try replace (0 + 1 * j) with j by lia.
        try rewrite <- (buf_fa j v_buf Hfcs ltac:(lia)).
        try rewrite (buf_ptr_succ' j v_buf Hfcs ltac:(lia) ltac:(lia)).
        try rewrite (buf_ptr_succ j v_buf Hfcs ltac:(lia) ltac:(lia)).
        forward.  (* lines = lines + 1 *)
        rewrite add64_repr.
        Exists (j + 1). entailer!.
        all: try (rewrite count_nl_sublist_succ by lia; rewrite Hjnl, Hskip; reflexivity).
        all: try (rewrite count_nl_sublist_succ by lia; rewrite Hjnl, Hskip; f_equal; f_equal; lia).
        all: try (split; [ rewrite buf_fa by (auto; lia); f_equal; simpl; lia
                         | rewrite count_nl_sublist_succ by lia; rewrite Hjnl, Hskip; f_equal; f_equal; lia ]). }
      (* after the rawmemchr loop: end of the else-branch *)
      try forward.
      Exists (bufv' bs r). entailer!.
      all: try (apply bufv'_Zlength; lia). }
    (* both arms joined: lines counts this block; now the density test *)
    Intros vl.
    forward_if (EX ll' : bool,
      PROP ()
      LOCAL (temp _long_lines (Vint (Int.repr (if ll' then 1 else 0)));
             temp _lines (Vlong (Int64.repr (lines + count_nl bs)));
             temp _bytes (Vlong (Int64.repr (bytes + r)));
             temp _file fname; temp _fd (Vint (Int.repr (in_fd t)));
             temp _lines_out (Vptr b i); temp _bytes_out (Vptr b0 i0);
             lvar _buf (tarray tschar 16385) v_buf; gvars gv)
      SEP (data_at Tsh (tarray tschar 16385) vl v_buf; has_ext t1; errno_at (gv _errno) e2;
           data_at_ shl tulong (Vptr b i); data_at_ shb tulong (Vptr b0 i0))).
    { forward. Exists true. entailer!. }
    { forward. Exists false. entailer!. }
    Intros ll'.
    sep_apply (data_at_data_at_ Tsh (tarray tschar 16385) vl v_buf).
    Exists t1 e2 (lines + count_nl bs) (bytes + r) ll'.
    entailer!.
    all: try (repeat split; try congruence; try (eapply wl_step; eauto)). }
  (* EOF: store the totals and return true *)
  Intros t2 e3 lines2 bytes2.
  forward. forward. forward.
  Exists t2 e3 true lines2 bytes2.
  entailer!.
  all: try (simpl; cancel).
Qed.
