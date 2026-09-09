(* Concrete execution witness / termination for the ORIGINAL wrapper program
   relay_main.prog (adequacy-resume-3): `int main(void){ return relay(); }`
   with relay.c unchanged.

   Same construction as Terminate.v (for relay_exit.prog), retargeted: the
   environment model is Dry.relay_dry_spec (read/write only), the initial core
   and memory are Safety.v's, and the execution ends HALTED:
     Returnstate (Vint (Int.repr status)) Kstop
   with outcome w0 status final pending, i.e. main's actual return value on
   the concrete Clight execution is the protocol status of w0.  VST's forced
   exit predicate True is irrelevant here: no safety theorem is used, the
   trace is constructed directly, and every external call on it satisfies its
   dry precondition (ok_steps).  No Jsub.

   Trusted/assumed, unchanged: the scheduled environment model (each read/write
   returns with the specified memory effect), the C->Clight translation
   (relay_main.v hashes); nothing about the host OS. *)
Require Import VST.floyd.proofauto.
Require Import VST.sepcomp.semantics.
Require Import VST.sepcomp.extspec.
Require Import VST.veric.semax_ext.
Require Import VST.veric.Clight_core.
Require Import VST.veric.SequentialClight.
Require Import VST.veric.mem_lessdef.
Require Import compcert.common.Globalenvs.
Require Import compcert.lib.Maps.
Require Import Trace.
Require relay.
Require Import relay_main Protocol Reach Conservation Progress Determinism Evaluator Dry Safety.
Import RelayProtocol RelayReach RelayConservation RelayProgress RelayEvaluator.
Local Open Scope Z_scope.

Local Opaque RelayProtocol.read32 RelayProtocol.write_block.

Local Notation CState := Clight_core.State.
Local Notation CCall := Clight_core.Callstate.
Local Notation CRet := Clight_core.Returnstate.
Local Notation ge := (globalenv prog).
Local Notation csem := (cl_core_sem (globalenv prog)).
Local Notation relay_ge :=
  (Clight.genv_genv {| Clight.genv_genv := Genv.globalenv prog; Clight.genv_cenv := prog_comp_env prog |}).

(* ---------- the external functions and global symbols of relay_main.prog ---------- *)

Definition rw_sig := mksignature (AST.Xint :: AST.Xptr :: AST.Xlong :: nil) AST.Xlong cc_default.
Definition read_ef := EF_external "read" rw_sig.
Definition write_ef := EF_external "write" rw_sig.
Definition ty_rw := Tfunction (tint :: tptr tvoid :: tulong :: nil) tlong cc_default.
Definition read_fd : Clight.fundef := External read_ef (tint :: tptr tvoid :: tulong :: nil) tlong cc_default.
Definition write_fd : Clight.fundef := External write_ef (tint :: tptr tvoid :: tulong :: nil) tlong cc_default.

Lemma sym_fun (id : ident) (fd : Clight.fundef) :
  PTree.get id (prog_defmap prog) = Some (Gfun fd) ->
  exists b, Genv.find_symbol (Genv.globalenv prog) id = Some b /\
            Genv.find_funct_ptr (Genv.globalenv prog) b = Some fd.
Proof.
  intro H. destruct (proj1 (Genv.find_def_symbol _ _ _) H) as (b & Hs & Hd).
  exists b; split; [exact Hs | apply Genv.find_funct_ptr_iff; exact Hd].
Qed.

Lemma read_sym : exists b, Genv.find_symbol (Genv.globalenv prog) _read = Some b /\
                           Genv.find_funct_ptr (Genv.globalenv prog) b = Some read_fd.
Proof. apply sym_fun; vm_compute; reflexivity. Qed.
Lemma write_sym : exists b, Genv.find_symbol (Genv.globalenv prog) _write = Some b /\
                            Genv.find_funct_ptr (Genv.globalenv prog) b = Some write_fd.
Proof. apply sym_fun; vm_compute; reflexivity. Qed.
Lemma relay_sym : exists b, Genv.find_symbol (Genv.globalenv prog) _relay = Some b /\
                            Genv.find_funct_ptr (Genv.globalenv prog) b = Some (Internal f_relay).
Proof. apply sym_fun; vm_compute; reflexivity. Qed.

Lemma main_fd : Genv.find_funct_ptr (genv_genv ge) main_block = Some (Internal f_main).
Proof.
  destruct (sym_fun _main (Internal f_main)) as (b & Hs & Hd); [vm_compute; reflexivity|].
  assert (Hm : Genv.find_symbol (Genv.globalenv prog) _main = Some main_block)
    by exact (proj2_sig main_block_exists).
  rewrite Hs in Hm; inv Hm. exact Hd.
Qed.

(* ---------- AST pieces (checked against the generated AST by reflexivity) ---------- *)

Definition call_read := Scall (Some _t'1) (Evar _read ty_rw)
  (Econst_int (Int.repr 0) tint :: Evar _buf (tarray tuchar 32) :: Econst_int (Int.repr 32) tint :: nil).
Definition set_n := Sset _n (Etempvar _t'1 tlong).
Definition if_neg := Sifthenelse (Ebinop Olt (Etempvar _n tlong) (Econst_int (Int.repr 0) tint) tint)
  (Sreturn (Some (Econst_int (Int.repr 1) tint))) Sskip.
Definition if_zero := Sifthenelse (Ebinop Oeq (Etempvar _n tlong) (Econst_int (Int.repr 0) tint) tint)
  (Sreturn (Some (Econst_int (Int.repr 0) tint))) Sskip.
Definition set_off0 := Sset _off (Ecast (Econst_int (Int.repr 0) tint) tulong).
Definition cond_w := Ebinop Olt (Etempvar _off tulong) (Ecast (Etempvar _n tlong) tulong) tint.
Definition call_write := Scall (Some _t'2) (Evar _write ty_rw)
  (Econst_int (Int.repr 1) tint ::
   Ebinop Oadd (Evar _buf (tarray tuchar 32)) (Etempvar _off tulong) (tptr tuchar) ::
   Ebinop Osub (Ecast (Etempvar _n tlong) tulong) (Etempvar _off tulong) tulong :: nil).
Definition set_w := Sset _w (Etempvar _t'2 tlong).
Definition if_w := Sifthenelse (Ebinop Ole (Etempvar _w tlong) (Econst_int (Int.repr 0) tint) tint)
  (Sreturn (Some (Econst_int (Int.repr 2) tint))) Sskip.
Definition set_off := Sset _off (Ebinop Oadd (Etempvar _off tulong) (Ecast (Etempvar _w tlong) tulong) tulong).
Definition wbody := Ssequence (Ssequence call_write set_w) (Ssequence if_w set_off).
Definition wloop := Swhile cond_w wbody.
Definition S3 := Ssequence if_neg (Ssequence if_zero (Ssequence set_off0 wloop)).
Definition S2 := Ssequence (Ssequence call_read set_n) S3.
Definition S1 := Ssequence Sskip S2.
Definition ret0 := Sreturn (Some (Econst_int (Int.repr 0) tint)).
Definition call_relay := Scall (Some _t'1) (Evar _relay (Tfunction nil tint cc_default)) nil.
Definition ret_t1 := Sreturn (Some (Etempvar _t'1 tint)).

Lemma relay_body_eq : fn_body f_relay = Sloop S1 Sskip.
Proof. reflexivity. Qed.
Lemma main_body_eq : fn_body f_main = Ssequence (Ssequence call_relay ret_t1) ret0.
Proof. reflexivity. Qed.

(* ---------- concrete checkpoint states ---------- *)

Definition le_main0 := create_undef_temps (fn_temps f_main).
Definition Kmain := Kseq ret_t1 (Kseq ret0 Kstop).
Definition Krelay := Kcall (Some _t'1) f_main empty_env le_main0 Kmain.
Definition KL := Kloop1 S1 Sskip Krelay.
Definition Kread := Kseq set_n (Kseq S3 KL).
Definition KW := Kloop1 (Ssequence (Sifthenelse cond_w Sskip Sbreak) wbody) Sskip KL.
Definition e_relay (b : block) : env := PTree.set _buf (b, tarray tuchar 32) empty_env.

Definition st_ready b le := CState f_relay call_read Kread (e_relay b) le.
Definition st_drain b le := CState f_relay wloop KL (e_relay b) le.
(* the halted final state: main has returned the status *)
Definition st_halt (status : Z) := CRet (Vint (Int.repr status)) Kstop.

(* the 32-byte stack buffer is fully owned (allocated, never freed until return) *)
Definition buf_ok (m : mem) (b : block) := Mem.range_perm m b 0 32 Memtype.Cur Memtype.Freeable.

Lemma buf_ok_writable m b : buf_ok m b -> forall lo hi, 0 <= lo -> hi <= 32 ->
  Mem.range_perm m b lo hi Memtype.Cur Memtype.Writable.
Proof.
  intros H lo hi Hlo Hhi ofs Hofs. eapply Mem.perm_implies; [apply H; lia | constructor].
Qed.

(* ---------- byte lists as memvals ---------- *)

Lemma encode_vubyte c : encode_val Mint8unsigned (Vubyte c) = [Byte c].
Proof.
  unfold Vubyte; simpl.
  pose proof (Byte.unsigned_range_2 c).
  rewrite Int.unsigned_repr by rep_lia.
  unfold encode_int, rev_if_be, bytes_of_int, inj_bytes; simpl.
  rewrite Byte.repr_unsigned. reflexivity.
Qed.

Lemma bytes_to_memvals_map l : bytes_to_memvals l = map Byte l.
Proof.
  induction l as [| c l IH]; [reflexivity|].
  unfold bytes_to_memvals in *. cbn [map concat]. rewrite encode_vubyte, IH. reflexivity.
Qed.

Lemma bytes_to_memvals_inj l1 l2 : bytes_to_memvals l1 = bytes_to_memvals l2 -> l1 = l2.
Proof.
  rewrite !bytes_to_memvals_map. revert l2; induction l1 as [| c l1 IH]; intros [| d l2] H; simpl in H;
    try discriminate; [reflexivity|]. inv H. f_equal. apply IH; assumption.
Qed.

Lemma bytes_to_memvals_app l1 l2 : bytes_to_memvals (l1 ++ l2) = bytes_to_memvals l1 ++ bytes_to_memvals l2.
Proof. rewrite !bytes_to_memvals_map. apply map_app. Qed.

Lemma length_bytes_to_memvals l : Z.of_nat (length (bytes_to_memvals l)) = Zlength l.
Proof. rewrite <- Zlength_correct. apply bytes_to_memvals_length. Qed.

Lemma app_inv_length {A} (l1 l2 l1' l2' : list A) :
  l1 ++ l2 = l1' ++ l2' -> length l1 = length l1' -> l2 = l2'.
Proof.
  revert l1'; induction l1 as [| x l1 IH]; intros [| y l1'] Heq Hl; simpl in *; try discriminate; auto.
  inv Heq. eauto.
Qed.

(* the suffix of a stored chunk is loadable from its offset *)
Lemma loadbytes_suffix m b chunk off :
  0 <= off <= Zlength chunk ->
  Mem.loadbytes m b 0 (Zlength chunk) = Some (bytes_to_memvals chunk) ->
  Mem.loadbytes m b off (Zlength chunk - off) = Some (bytes_to_memvals (suffix off chunk)).
Proof.
  intros Hoff Hload.
  rewrite <- (prefix_suffix off chunk Hoff) in Hload at 2.
  rewrite bytes_to_memvals_app in Hload.
  assert (Hz : Zlength chunk = off + (Zlength chunk - off)) by lia.
  rewrite Hz in Hload at 1.
  destruct (Mem.loadbytes_split _ _ _ _ _ _ Hload ltac:(lia) ltac:(lia)) as (b1 & b2 & H1 & H2 & Heq).
  pose proof (Mem.loadbytes_length _ _ _ _ _ H1) as L1.
  assert (Hl1 : length b1 = length (bytes_to_memvals (prefix off chunk))).
  { rewrite L1. apply Nat2Z.inj. rewrite length_bytes_to_memvals, prefix_length by lia.
    rewrite Z2Nat.id by lia. reflexivity. }
  pose proof (app_inv_length _ _ _ _ Heq (eq_sym Hl1)) as Hb2.
  rewrite <- Hb2 in H2. rewrite Z.add_0_l in H2. exact H2.
Qed.

(* ---------- expression semantics on the values that occur ---------- *)

Lemma sem_cast_int_int i m : Cop.sem_cast (Vint i) tint tint m = Some (Vint i).
Proof. reflexivity. Qed.
Lemma sem_cast_arr b o m : Cop.sem_cast (Vptr b o) (tarray tuchar 32) (tptr tvoid) m = Some (Vptr b o).
Proof. reflexivity. Qed.
Lemma sem_cast_ptr b o m : Cop.sem_cast (Vptr b o) (tptr tuchar) (tptr tvoid) m = Some (Vptr b o).
Proof. reflexivity. Qed.
Lemma sem_cast_ll l m : Cop.sem_cast (Vlong l) tlong tulong m = Some (Vlong l).
Proof. reflexivity. Qed.
Lemma sem_cast_ulul l m : Cop.sem_cast (Vlong l) tulong tulong m = Some (Vlong l).
Proof. reflexivity. Qed.
Lemma sem_cast_i2ul z m : Int.min_signed <= z <= Int.max_signed ->
  Cop.sem_cast (Vint (Int.repr z)) tint tulong m = Some (Vlong (Int64.repr z)).
Proof.
  intros. simpl. rewrite Int.signed_repr by rep_lia. reflexivity.
Qed.

Lemma bool_val_of_bool bb m : Cop.bool_val (Val.of_bool bb) tint m = Some bb.
Proof.
  destruct bb; unfold Cop.bool_val; simpl.
  - try (rewrite Int.eq_false by apply Int.one_not_zero). reflexivity.
  - try rewrite Int.eq_true. reflexivity.
Qed.

Lemma sem_lt_n0 cenv r m : -1 <= r <= 32 ->
  Cop.sem_binary_operation cenv Olt (Vlong (Int64.repr r)) tlong (Vint (Int.repr 0)) tint m
  = Some (Val.of_bool (r <? 0)).
Proof.
  intros Hr. unfold Cop.sem_binary_operation, Cop.sem_cmp, Cop.sem_binarith; simpl.
  rewrite Int.signed_repr by rep_lia.
  unfold Int64.lt. rewrite !Int64.signed_repr by rep_lia.
  destruct (zlt r 0), (Z.ltb_spec r 0); first [reflexivity | lia].
Qed.

Lemma sem_eq_n0 cenv r m : 0 <= r <= 32 ->
  Cop.sem_binary_operation cenv Oeq (Vlong (Int64.repr r)) tlong (Vint (Int.repr 0)) tint m
  = Some (Val.of_bool (r =? 0)).
Proof.
  intros Hr. unfold Cop.sem_binary_operation, Cop.sem_cmp, Cop.sem_binarith; simpl.
  rewrite Int.signed_repr by rep_lia.
  unfold Int64.eq. rewrite !Int64.unsigned_repr by rep_lia.
  destruct (zeq r 0), (Z.eqb_spec r 0); first [reflexivity | lia].
Qed.

Lemma sem_le_w0 cenv r m : -1 <= r <= 32 ->
  Cop.sem_binary_operation cenv Ole (Vlong (Int64.repr r)) tlong (Vint (Int.repr 0)) tint m
  = Some (Val.of_bool (r <=? 0)).
Proof.
  intros Hr. unfold Cop.sem_binary_operation, Cop.sem_cmp, Cop.sem_binarith; simpl.
  rewrite Int.signed_repr by rep_lia.
  unfold Int64.lt. rewrite !Int64.signed_repr by rep_lia.
  destruct (zlt 0 r), (Z.leb_spec r 0); simpl; first [reflexivity | lia].
Qed.

Lemma sem_ltu cenv a n m : 0 <= a <= 32 -> 0 <= n <= 32 ->
  Cop.sem_binary_operation cenv Olt (Vlong (Int64.repr a)) tulong (Vlong (Int64.repr n)) tulong m
  = Some (Val.of_bool (a <? n)).
Proof.
  intros Ha Hn. unfold Cop.sem_binary_operation, Cop.sem_cmp, Cop.sem_binarith; simpl.
  unfold Int64.ltu. rewrite !Int64.unsigned_repr by rep_lia.
  destruct (zlt a n), (Z.ltb_spec a n); first [reflexivity | lia].
Qed.

Lemma sem_add_ptr cenv b off m : 0 <= off <= 32 ->
  Cop.sem_binary_operation cenv Oadd (Vptr b Ptrofs.zero) (tarray tuchar 32) (Vlong (Int64.repr off)) tulong m
  = Some (Vptr b (Ptrofs.repr off)).
Proof.
  intros Hoff. unfold Cop.sem_binary_operation, Cop.sem_add; simpl.
  rewrite Ptrofs.add_zero_l. unfold Ptrofs.of_int64. rewrite Int64.unsigned_repr by rep_lia.
  rewrite Ptrofs.mul_commut, Ptrofs.mul_one. reflexivity.
Qed.

Lemma sem_sub_ul cenv a c m :
  Cop.sem_binary_operation cenv Osub (Vlong (Int64.repr a)) tulong (Vlong (Int64.repr c)) tulong m
  = Some (Vlong (Int64.repr (a - c))).
Proof.
  unfold Cop.sem_binary_operation, Cop.sem_sub, Cop.sem_binarith; simpl. rewrite sub64_repr. reflexivity.
Qed.

Lemma sem_add_ul cenv a c m :
  Cop.sem_binary_operation cenv Oadd (Vlong (Int64.repr a)) tulong (Vlong (Int64.repr c)) tulong m
  = Some (Vlong (Int64.repr (a + c))).
Proof.
  unfold Cop.sem_binary_operation, Cop.sem_add, Cop.sem_binarith; simpl. rewrite add64_repr. reflexivity.
Qed.

(* ---------- traces whose external calls all satisfy the dry precondition ---------- *)

Section Witness.

Variable w0 : world.

Local Notation spec := relay_dry_spec.
Local Notation symb := (semax.genv_symb_injective relay_ge).
Local Notation dstep := (dry_step csem spec semax.genv_symb_injective relay_ge).
Local Notation dsteps := (dry_steps csem spec semax.genv_symb_injective relay_ge).

Definition ext_ok (s : CC_core * mem * world) : Prop :=
  let '(q, m, z) := s in
  forall e args, semantics.at_external csem q m = Some (e, args) ->
    exists x, ext_spec_pre spec e x symb (map proj_xtype (sig_args (ef_sig e))) args z m.

Inductive ok_steps : nat -> CC_core * mem * world -> CC_core * mem * world -> Prop :=
| ok_0 s : ok_steps 0 s s
| ok_S k s s' s'' : ext_ok s -> dstep s s' -> ok_steps k s' s'' -> ok_steps (S k) s s''.

Lemma ok_steps_dry k s s' : ok_steps k s s' -> dsteps k s s'.
Proof. induction 1; econstructor; eauto. Qed.

Definition ok_star s s' := exists k, ok_steps k s s'.

Lemma ok_refl s : ok_star s s.
Proof. exists O; constructor. Qed.

Lemma ok_step_l s s' s'' : ext_ok s -> dstep s s' -> ok_star s' s'' -> ok_star s s''.
Proof. intros H1 H2 (k & H3). exists (S k); econstructor; eauto. Qed.

Lemma ok_trans s s' s'' : ok_star s s' -> ok_star s' s'' -> ok_star s s''.
Proof.
  intros (k1 & H1) (k2 & H2). exists (k1 + k2)%nat.
  revert H2; induction H1; intro H2; simpl; [exact H2 | econstructor; eauto].
Qed.

Lemma core_step q m q' m' : Clight_core.step ge q m q' m' -> semantics.corestep csem q m q' m'.
Proof. intro H; exact H. Qed.

Ltac solve_ne := let H := fresh in intro H; vm_compute in H; discriminate H.
Ltac ptree := repeat first [rewrite PTree.gss | rewrite PTree.gso by solve_ne].
Ltac not_ext := let H := fresh in intros ? ? H; simpl in H; discriminate H.
Ltac ev :=
  first [ eapply eval_Econst_int
        | eapply eval_Etempvar; ptree; first [reflexivity | eassumption]
        | eapply eval_Elvalue; [eapply eval_Evar_local; reflexivity | apply deref_loc_reference; reflexivity]
        | eapply eval_Elvalue; [eapply eval_Evar_global; [reflexivity | eassumption] | apply deref_loc_reference; reflexivity] ].
Ltac core := eapply ok_step_l; [not_ext | apply dry_step_core; apply core_step |].
Ltac uz := first [rewrite Ptrofs.unsigned_zero | rewrite Ptrofs.unsigned_repr by rep_lia].
Ltac ptree_solve := ptree; first [reflexivity | eassumption].

(* ---- the two external calls, answered as scheduled, with their preconditions met ---- *)

Lemma read_ext_step z b m k :
  valid_world z -> buf_ok m b ->
  exists m',
    ext_ok (CCall read_fd [Vint (Int.repr 0); Vptr b Ptrofs.zero; Vlong (Int64.repr 32)] k, m, z) /\
    dstep (CCall read_fd [Vint (Int.repr 0); Vptr b Ptrofs.zero; Vlong (Int64.repr 32)] k, m, z)
          (CRet (Vlong (Int64.repr (read_ret (read32 z)))) k, m', read_world (read32 z)) /\
    buf_ok m' b /\
    (0 <= read_ret (read32 z) ->
     Mem.loadbytes m' b 0 (Zlength (read_bytes (read32 z))) = Some (bytes_to_memvals (read_bytes (read32 z)))).
Proof.
  intros Hv Hbuf.
  pose proof (read_ret_bounds z) as Hb.
  (* the memory after the call *)
  assert (Hm' : exists m', (if read_ret (read32 z) <? 0 then m' = m
                 else Mem.storebytes m b 0 (bytes_to_memvals (read_bytes (read32 z))) = Some m')).
  { destruct (read_ret (read32 z) <? 0) eqn:E; [eauto|].
    apply Z.ltb_ge in E.
    pose proof (read_success_length z E) as Hlen.
    edestruct (Mem.range_perm_storebytes m b 0 (bytes_to_memvals (read_bytes (read32 z)))) as (m' & Hst).
    { rewrite length_bytes_to_memvals. apply buf_ok_writable; [exact Hbuf | lia | lia]. }
    eauto. }
  destruct Hm' as (m' & Hm').
  exists m'. split; [| split; [| split]].
  - (* precondition holds for the witness (z, buf, Tsh) *)
    intros e args H. simpl in H. inv H.
    unfold relay_dry_spec; cbn [ext_spec_pre ext_spec_type].
    destruct (oi_eq_dec _ _) as [_ | N]; [| exfalso; apply N; vm_compute; reflexivity].
    exists (m, existT _ nil (z, Vptr b Ptrofs.zero, Tsh)). simpl.
    split; [reflexivity|]. split; [reflexivity|]. split; [reflexivity|]. split; [exact Hv|].
    uz. apply buf_ok_writable; [exact Hbuf | lia | lia].
  - (* the environment step *)
    eapply dry_step_ext with (ret := Some (Vlong (Int64.repr (read_ret (read32 z))))).
    + reflexivity.
    + simpl; repeat split; try reflexivity.
    + simpl; try exact I; auto.
    + unfold relay_dry_spec; cbn [ext_spec_pre ext_spec_post ext_spec_type].
      destruct (oi_eq_dec _ _) as [_ | N]; [| exfalso; apply N; vm_compute; reflexivity].
      intros x Hpre. destruct x as (m0 & ts & w). destruct w as ((s, p), sh). simpl in Hpre |- *.
      destruct Hpre as [Hargs [Hm0 [Hs [Hvs Hperm]]]]. inv Hargs. try subst m0. try subst s. simpl.
      split; [discriminate|]. split; [reflexivity|]. split; [reflexivity|].
      uz.
      match type of Hm' with context [?c <? 0] => destruct (c <? 0) eqn:E end; try rewrite E in Hm'; simpl in Hm';
        [symmetry; exact Hm' | exists m'; split; [exact Hm' | apply mem_equiv_refl]].
    + reflexivity.
  - (* permissions survive *)
    match type of Hm' with context [?c <? 0] => destruct (c <? 0) eqn:E end; try rewrite E in Hm'; simpl in Hm'; [subst m'; exact Hbuf|].
    intros ofs Hofs. eapply Mem.perm_storebytes_1; [exact Hm' | apply Hbuf; exact Hofs].
  - intro Hge. match type of Hm' with context [?c <? 0] => destruct (c <? 0) eqn:E end; try rewrite E in Hm'; simpl in Hm';
      [apply Z.ltb_lt in E; lia|].
    pose proof (Mem.loadbytes_storebytes_same _ _ _ _ _ Hm') as Hl.
    rewrite length_bytes_to_memvals in Hl. exact Hl.
Qed.

Lemma write_ext_step z b m k chunk off :
  valid_world z -> 0 <= off < Zlength chunk -> Zlength chunk <= 32 ->
  Mem.loadbytes m b 0 (Zlength chunk) = Some (bytes_to_memvals chunk) ->
  ext_ok (CCall write_fd [Vint (Int.repr 1); Vptr b (Ptrofs.repr off); Vlong (Int64.repr (Zlength chunk - off))] k, m, z) /\
  dstep (CCall write_fd [Vint (Int.repr 1); Vptr b (Ptrofs.repr off); Vlong (Int64.repr (Zlength chunk - off))] k, m, z)
        (CRet (Vlong (Int64.repr (write_ret (write_block z (suffix off chunk))))) k, m,
         write_world (write_block z (suffix off chunk))).
Proof.
  intros Hv Hoff Hlen Hload.
  pose proof (loadbytes_suffix m b chunk off ltac:(lia) Hload) as Hsuf.
  pose proof (suffix_length off chunk ltac:(lia)) as Hsl.
  split.
  - intros e args H. simpl in H. inv H.
    unfold relay_dry_spec; cbn [ext_spec_pre ext_spec_type].
    destruct (oi_eq_dec _ _) as [E | _]; [exfalso; vm_compute in E; discriminate E|].
    destruct (oi_eq_dec _ _) as [_ | N]; [| exfalso; apply N; vm_compute; reflexivity].
    exists (m, existT _ nil (z, Vptr b (Ptrofs.repr off), suffix off chunk, Tsh)). simpl.
    rewrite Hsl.
    split; [reflexivity|]. split; [reflexivity|]. split; [reflexivity|]. split; [exact Hv|].
    split; [lia|]. rewrite Ptrofs.unsigned_repr by rep_lia. exact Hsuf.
  - eapply dry_step_ext with (ret := Some (Vlong (Int64.repr (write_ret (write_block z (suffix off chunk)))))).
    + reflexivity.
    + simpl; repeat split; try reflexivity.
    + simpl; try exact I; auto.
    + unfold relay_dry_spec; cbn [ext_spec_pre ext_spec_post ext_spec_type].
      destruct (oi_eq_dec _ _) as [E | _]; [exfalso; vm_compute in E; discriminate E|].
      destruct (oi_eq_dec _ _) as [_ | N]; [| exfalso; apply N; vm_compute; reflexivity].
      intros x Hpre. destruct x as (m0 & ts & w). destruct w as (((s, p), bs), sh). simpl in Hpre |- *.
      destruct Hpre as [Hargs [Hm0 [Hs [Hvs [Hbs Hld]]]]]. inv Hargs. try subst m0. try subst s. simpl.
      assert (Hbl : Zlength bs = Zlength chunk - off).
      { match goal with H : Int64.Z_mod_modulus _ = Int64.Z_mod_modulus _ |- _ =>
          rewrite !Int64.Z_mod_modulus_eq in H; rewrite !Z.mod_small in H by rep_lia; lia end. }
      rewrite Ptrofs.unsigned_repr in Hld by rep_lia.
      rewrite Hbl, Hsuf in Hld. inv Hld.
      match goal with H : bytes_to_memvals _ = bytes_to_memvals _ |- _ =>
        apply bytes_to_memvals_inj in H; subst bs end.
      split; [discriminate|]. split; [reflexivity|]. split; reflexivity.
    + reflexivity.
Qed.

(* ---- return from relay with a status, through main, to the halted state ---- *)

Lemma seg_return status b le m k z :
  buf_ok m b -> call_cont k = Krelay -> Int.min_signed <= status <= Int.max_signed ->
  exists m', ok_star (CState f_relay (Sreturn (Some (Econst_int (Int.repr status) tint))) k (e_relay b) le, m, z)
                     (st_halt status, m', z).
Proof.
  intros Hbuf Hk Hst.
  destruct (Mem.range_perm_free m b 0 32 Hbuf) as (m' & Hfree).
  exists m'.
  core. { eapply step_return_1; [ev | apply sem_cast_int_int |].
          assert (Hbl : blocks_of_env ge (e_relay b) = [(b, 0, 32)]) by reflexivity.
          rewrite Hbl. cbn [Mem.free_list]. rewrite Hfree. reflexivity. }
  rewrite Hk. unfold Krelay.
  core. { eapply step_returnstate. }
  cbn [set_opttemp].
  unfold Kmain. core. { eapply step_skip_seq. }
  unfold ret_t1.
  core. { eapply step_return_1; [ev | apply sem_cast_int_int | reflexivity]. }
  apply ok_refl.
Qed.

(* ---- Ready: the read call, up to the statement S3 with n set ---- *)

Lemma seg_read z b le m :
  valid_world z -> buf_ok m b ->
  exists m',
    ok_star (st_ready b le, m, z)
            (CState f_relay S3 KL (e_relay b)
               (PTree.set _n (Vlong (Int64.repr (read_ret (read32 z))))
                  (PTree.set _t'1 (Vlong (Int64.repr (read_ret (read32 z)))) le)),
             m', read_world (read32 z)) /\
    buf_ok m' b /\
    (0 <= read_ret (read32 z) ->
     Mem.loadbytes m' b 0 (Zlength (read_bytes (read32 z))) = Some (bytes_to_memvals (read_bytes (read32 z)))).
Proof.
  intros Hv Hbuf.
  destruct read_sym as (br & Hrs & Hrd).
  destruct (read_ext_step z b m (Kcall (Some _t'1) f_relay (e_relay b) le Kread) Hv Hbuf)
    as (m' & Hok & Hstep & Hbuf' & Hload).
  exists m'. split; [| split; assumption].
  unfold st_ready, call_read.
  core. { eapply step_call; [reflexivity | ev | | | ].
          - econstructor; [ev | apply sem_cast_int_int |].
            econstructor; [ev | apply sem_cast_arr |].
            econstructor; [ev | apply sem_cast_i2ul; rep_lia | constructor].
          - rewrite Genv.find_funct_find_funct_ptr. exact Hrd.
          - reflexivity. }
  eapply ok_step_l; [exact Hok | exact Hstep |].
  core. { eapply step_returnstate. }
  cbn [set_opttemp].
  unfold Kread. core. { eapply step_skip_seq. }
  unfold set_n. core. { eapply step_set. ev. }
  core. { eapply step_skip_seq. }
  apply ok_refl.
Qed.

(* ---- S3 with n = r: the three outcomes of the read ---- *)

Lemma seg_S3_neg z b le m r :
  buf_ok m b -> -1 <= r < 0 ->
  PTree.get _n le = Some (Vlong (Int64.repr r)) ->
  exists m', ok_star (CState f_relay S3 KL (e_relay b) le, m, z) (st_halt 1, m', z).
Proof.
  intros Hbuf Hr Hn.
  destruct (seg_return 1 b le m (Kseq (Ssequence if_zero (Ssequence set_off0 wloop)) KL) z Hbuf eq_refl
              ltac:(rep_lia)) as (m' & Hret).
  exists m'.
  unfold S3. core. { eapply step_seq. }
  unfold if_neg.
  core. { eapply step_ifthenelse with (b := true); [econstructor; [ev | ev | apply sem_lt_n0; lia] |].
          rewrite bool_val_of_bool. f_equal. apply Z.ltb_lt; lia. }
  cbv iota. exact Hret.
Qed.

Lemma seg_S3_zero z b le m :
  buf_ok m b ->
  PTree.get _n le = Some (Vlong (Int64.repr 0)) ->
  exists m', ok_star (CState f_relay S3 KL (e_relay b) le, m, z) (st_halt 0, m', z).
Proof.
  intros Hbuf Hn.
  destruct (seg_return 0 b le m (Kseq (Ssequence set_off0 wloop) KL) z Hbuf eq_refl ltac:(rep_lia))
    as (m' & Hret).
  exists m'.
  unfold S3. core. { eapply step_seq. }
  unfold if_neg.
  core. { eapply step_ifthenelse with (b := false); [econstructor; [ev | ev | apply sem_lt_n0; lia] |].
          rewrite bool_val_of_bool. reflexivity. }
  cbv iota.
  core. { eapply step_skip_seq. }
  core. { eapply step_seq. }
  unfold if_zero.
  core. { eapply step_ifthenelse with (b := true); [econstructor; [ev | ev | apply sem_eq_n0; lia] |].
          rewrite bool_val_of_bool. reflexivity. }
  cbv iota. exact Hret.
Qed.

Lemma seg_S3_pos z b le m r :
  0 < r <= 32 ->
  PTree.get _n le = Some (Vlong (Int64.repr r)) ->
  ok_star (CState f_relay S3 KL (e_relay b) le, m, z)
          (st_drain b (PTree.set _off (Vlong (Int64.repr 0)) le), m, z).
Proof.
  intros Hr Hn.
  unfold S3. core. { eapply step_seq. }
  unfold if_neg.
  core. { eapply step_ifthenelse with (b := false); [econstructor; [ev | ev | apply sem_lt_n0; lia] |].
          rewrite bool_val_of_bool. f_equal. apply Z.ltb_ge; lia. }
  cbv iota.
  core. { eapply step_skip_seq. }
  core. { eapply step_seq. }
  unfold if_zero.
  core. { eapply step_ifthenelse with (b := false); [econstructor; [ev | ev | apply sem_eq_n0; lia] |].
          rewrite bool_val_of_bool. f_equal. apply Z.eqb_neq; lia. }
  cbv iota.
  core. { eapply step_skip_seq. }
  core. { eapply step_seq. }
  unfold set_off0.
  core. { eapply step_set. eapply eval_Ecast; [ev | apply sem_cast_i2ul; rep_lia]. }
  core. { eapply step_skip_seq. }
  apply ok_refl.
Qed.

(* ---- Drain: the while test ---- *)

Lemma seg_drain_end z b le m n :
  0 <= n <= 32 ->
  PTree.get _n le = Some (Vlong (Int64.repr n)) ->
  PTree.get _off le = Some (Vlong (Int64.repr n)) ->
  ok_star (st_drain b le, m, z) (st_ready b le, m, z).
Proof.
  intros Hn Hln Hlo.
  unfold st_drain, wloop, Swhile.
  core. { eapply step_loop. }
  core. { eapply step_seq. }
  unfold cond_w.
  core. { eapply step_ifthenelse with (b := false);
          [econstructor; [ev | eapply eval_Ecast; [ev | apply sem_cast_ll] | apply sem_ltu; lia] |].
          rewrite bool_val_of_bool. f_equal. apply Z.ltb_ge; lia. }
  cbv iota.
  core. { eapply step_break_seq. }
  core. { eapply step_break_loop1. }
  unfold KL.
  core. { eapply step_skip_or_continue_loop1; left; reflexivity. }
  core. { eapply step_skip_loop2. }
  core. { eapply step_loop. }
  unfold S1. core. { eapply step_seq. }
  core. { eapply step_skip_seq. }
  unfold S2. core. { eapply step_seq. }
  core. { eapply step_seq. }
  apply ok_refl.
Qed.

Lemma seg_drain_write z b le m chunk off :
  valid_world z -> 0 <= off < Zlength chunk -> Zlength chunk <= 32 ->
  Mem.loadbytes m b 0 (Zlength chunk) = Some (bytes_to_memvals chunk) ->
  PTree.get _n le = Some (Vlong (Int64.repr (Zlength chunk))) ->
  PTree.get _off le = Some (Vlong (Int64.repr off)) ->
  let wr := write_ret (write_block z (suffix off chunk)) in
  ok_star (st_drain b le, m, z)
          (CState f_relay (Ssequence if_w set_off) KW (e_relay b)
             (PTree.set _w (Vlong (Int64.repr wr)) (PTree.set _t'2 (Vlong (Int64.repr wr)) le)),
           m, write_world (write_block z (suffix off chunk))).
Proof.
  intros Hv Hoff Hlen Hload Hln Hlo wr.
  destruct write_sym as (bw & Hws & Hwd).
  destruct (write_ext_step z b m (Kcall (Some _t'2) f_relay (e_relay b) le
              (Kseq set_w (Kseq (Ssequence if_w set_off) KW))) chunk off Hv Hoff Hlen Hload)
    as (Hok & Hstep).
  unfold st_drain, wloop, Swhile.
  core. { eapply step_loop. }
  core. { eapply step_seq. }
  unfold cond_w.
  core. { eapply step_ifthenelse with (b := true);
          [econstructor; [ev | eapply eval_Ecast; [ev | apply sem_cast_ll] | apply sem_ltu; lia] |].
          rewrite bool_val_of_bool. f_equal. apply Z.ltb_lt; lia. }
  cbv iota.
  core. { eapply step_skip_seq. }
  unfold wbody at 1. core. { eapply step_seq. }
  core. { eapply step_seq. }
  unfold call_write.
  core. { eapply step_call; [reflexivity | ev | | | ].
          - econstructor; [ev | apply sem_cast_int_int |].
            econstructor; [econstructor; [ev | ev | apply sem_add_ptr; lia] | apply sem_cast_ptr |].
            econstructor; [econstructor; [eapply eval_Ecast; [ev | apply sem_cast_ll] | ev | apply sem_sub_ul]
                          | apply sem_cast_ulul | constructor].
          - rewrite Genv.find_funct_find_funct_ptr. exact Hwd.
          - reflexivity. }
  eapply ok_step_l; [exact Hok | exact Hstep |].
  core. { eapply step_returnstate. }
  cbn [set_opttemp].
  core. { eapply step_skip_seq. }
  unfold set_w. core. { eapply step_set. ev. }
  core. { eapply step_skip_seq. }
  apply ok_refl.
Qed.

Lemma seg_w_fail z b le m wr :
  buf_ok m b -> -1 <= wr <= 0 ->
  PTree.get _w le = Some (Vlong (Int64.repr wr)) ->
  exists m', ok_star (CState f_relay (Ssequence if_w set_off) KW (e_relay b) le, m, z) (st_halt 2, m', z).
Proof.
  intros Hbuf Hw Hlw.
  destruct (seg_return 2 b le m (Kseq set_off KW) z Hbuf eq_refl ltac:(rep_lia)) as (m' & Hret).
  exists m'.
  core. { eapply step_seq. }
  unfold if_w.
  core. { eapply step_ifthenelse with (b := true); [econstructor; [ev | ev | apply sem_le_w0; lia] |].
          rewrite bool_val_of_bool. f_equal. apply Z.leb_le; lia. }
  cbv iota. exact Hret.
Qed.

Lemma seg_w_ok z b le m wr off :
  0 < wr <= 32 -> 0 <= off <= 32 ->
  PTree.get _w le = Some (Vlong (Int64.repr wr)) ->
  PTree.get _off le = Some (Vlong (Int64.repr off)) ->
  ok_star (CState f_relay (Ssequence if_w set_off) KW (e_relay b) le, m, z)
          (st_drain b (PTree.set _off (Vlong (Int64.repr (off + wr))) le), m, z).
Proof.
  intros Hw Hoff Hlw Hlo.
  core. { eapply step_seq. }
  unfold if_w.
  core. { eapply step_ifthenelse with (b := false); [econstructor; [ev | ev | apply sem_le_w0; lia] |].
          rewrite bool_val_of_bool. f_equal. apply Z.leb_gt; lia. }
  cbv iota.
  core. { eapply step_skip_seq. }
  unfold set_off.
  core. { eapply step_set. econstructor; [ev | eapply eval_Ecast; [ev | apply sem_cast_ll] | apply sem_add_ul]. }
  unfold KW.
  core. { eapply step_skip_or_continue_loop1; left; reflexivity. }
  core. { eapply step_skip_loop2. }
  apply ok_refl.
Qed.

(* ---- the initial segment: main entry, relay entry (allocation of buf), loop entry ---- *)

Definition q0 : CC_core := CCall (Internal f_main) nil Kstop.

Lemma init_core : semantics.initial_core csem 0 init_mem q0 init_mem (Vptr main_block Ptrofs.zero) nil.
Proof.
  change (cl_initial_core ge (Vptr main_block Ptrofs.zero) nil = Some q0).
  unfold cl_initial_core. cbv iota.
  destruct (Ptrofs.eq_dec Ptrofs.zero Ptrofs.zero) as [_ | N]; [| exfalso; apply N; reflexivity].
  rewrite main_fd. reflexivity.
Qed.

Lemma seg_init z :
  exists b m1, ok_star (q0, init_mem, z) (st_ready b (create_undef_temps (fn_temps f_relay)), m1, z) /\ buf_ok m1 b.
Proof.
  destruct relay_sym as (brl & Hrls & Hrld).
  destruct (Mem.alloc init_mem 0 32) as [m1 b] eqn:Halloc.
  exists b, m1. split.
  2:{ intros ofs Hofs. eapply Mem.perm_alloc_2; eauto. }
  unfold q0.
  core. { eapply step_internal_function.
          econstructor; [constructor | constructor | intros ? ? Hx; simpl in Hx; contradiction | constructor | reflexivity]. }
  rewrite main_body_eq.
  core. { eapply step_seq. }
  core. { eapply step_seq. }
  unfold call_relay.
  core. { eapply step_call; [reflexivity | ev | constructor | | ].
          - rewrite Genv.find_funct_find_funct_ptr. exact Hrld.
          - reflexivity. }
  core. { eapply step_internal_function.
          econstructor; [constructor; [simpl; tauto | constructor] | constructor
                        | intros ? ? Hx; simpl in Hx; contradiction | | reflexivity].
          econstructor; [exact Halloc | constructor]. }
  rewrite relay_body_eq.
  core. { eapply step_loop. }
  unfold S1. core. { eapply step_seq. }
  core. { eapply step_skip_seq. }
  unfold S2. core. { eapply step_seq. }
  core. { eapply step_seq. }
  apply ok_refl.
Qed.

(* ---- simulation of the abstract executable step ---- *)

Inductive match_state : phase -> CC_core -> mem -> Prop :=
| match_ready b le m : buf_ok m b -> match_state Ready (st_ready b le) m
| match_drain b le m chunk off :
    buf_ok m b -> 0 < Zlength chunk <= 32 -> 0 <= off <= Zlength chunk ->
    Mem.loadbytes m b 0 (Zlength chunk) = Some (bytes_to_memvals chunk) ->
    PTree.get _n le = Some (Vlong (Int64.repr (Zlength chunk))) ->
    PTree.get _off le = Some (Vlong (Int64.repr off)) ->
    match_state (Drain chunk off) (st_drain b le) m
| match_halt status pending m : match_state (Halt status pending) (st_halt status) m.

Lemma sim_step p s p' s' q m :
  valid_world s -> RelayDeterminism.step (p, s) = Some (p', s') -> match_state p q m ->
  exists q' m', ok_star (q, m, s) (q', m', s') /\ match_state p' q' m'.
Proof.
  intros Hv Hstep Hm.
  destruct Hm as [b le m Hbuf | b le m chunk off Hbuf Hchunk Hoff Hload Hln Hlo | status pending m].
  - (* Ready: one read *)
    simpl in Hstep.
    pose proof (read_ret_bounds s) as Hb.
    destruct (seg_read s b le m Hv Hbuf) as (m1 & Hstar & Hbuf1 & Hload1).
    set (v := Vlong (Int64.repr (read_ret (read32 s)))) in *.
    set (le1 := PTree.set _n v (PTree.set _t'1 v le)) in *.
    assert (Hln1 : PTree.get _n le1 = Some v) by (unfold le1; ptree_solve).
    destruct (read_ret (read32 s) <? 0) eqn:E1.
    + inv Hstep. apply Z.ltb_lt in E1.
      destruct (seg_S3_neg (read_world (read32 s)) b le1 m1 (read_ret (read32 s)) Hbuf1 ltac:(lia) Hln1)
        as (m2 & Hstar2).
      exists (st_halt 1), m2. split; [eapply ok_trans; eauto | constructor].
    + apply Z.ltb_ge in E1.
      destruct (read_ret (read32 s) =? 0) eqn:E2.
      * inv Hstep. apply Z.eqb_eq in E2.
        assert (Hln0 : PTree.get _n le1 = Some (Vlong (Int64.repr 0))) by (rewrite Hln1; unfold v; rewrite E2; reflexivity).
        destruct (seg_S3_zero (read_world (read32 s)) b le1 m1 Hbuf1 Hln0) as (m2 & Hstar2).
        exists (st_halt 0), m2. split; [eapply ok_trans; eauto | constructor].
      * inv Hstep. apply Z.eqb_neq in E2.
        pose proof (read_success_length s E1) as Hlen.
        exists (st_drain b (PTree.set _off (Vlong (Int64.repr 0)) le1)), m1. split.
        { eapply ok_trans; [exact Hstar|].
          apply seg_S3_pos with (r := read_ret (read32 s)); [lia | exact Hln1]. }
        apply match_drain.
        -- exact Hbuf1.
        -- rewrite Hlen; lia.
        -- rewrite Hlen; lia.
        -- apply Hload1; lia.
        -- rewrite Hlen. unfold le1; ptree_solve.
        -- ptree_solve.
  - (* Drain: the while test, possibly one write *)
    simpl in Hstep.
    destruct (Zlength chunk <=? off) eqn:E1.
    + inv Hstep. apply Z.leb_le in E1.
      assert (Hend : off = Zlength chunk) by lia. subst off.
      exists (st_ready b le), m. split.
      { apply seg_drain_end with (n := Zlength chunk); [lia | exact Hln | exact Hlo]. }
      constructor; exact Hbuf.
    + apply Z.leb_gt in E1.
      pose proof (write_ret_bounds s (suffix off chunk)) as Hw.
      rewrite (suffix_length off chunk ltac:(lia)) in Hw.
      pose proof (seg_drain_write s b le m chunk off Hv ltac:(lia) ltac:(lia) Hload Hln Hlo) as Hstar.
      cbv zeta in Hstar.
      set (wr := write_ret (write_block s (suffix off chunk))) in *.
      set (le2 := PTree.set _w (Vlong (Int64.repr wr)) (PTree.set _t'2 (Vlong (Int64.repr wr)) le)) in *.
      assert (Hlw2 : PTree.get _w le2 = Some (Vlong (Int64.repr wr))) by (unfold le2; ptree_solve).
      assert (Hlo2 : PTree.get _off le2 = Some (Vlong (Int64.repr off))) by (unfold le2; ptree_solve).
      assert (Hln2 : PTree.get _n le2 = Some (Vlong (Int64.repr (Zlength chunk)))) by (unfold le2; ptree_solve).
      destruct (wr <=? 0) eqn:E2.
      * inv Hstep. apply Z.leb_le in E2.
        destruct (seg_w_fail (write_world (write_block s (suffix off chunk))) b le2 m wr Hbuf ltac:(lia) Hlw2)
          as (m2 & Hstar2).
        exists (st_halt 2), m2. split; [eapply ok_trans; eauto | constructor].
      * inv Hstep. apply Z.leb_gt in E2.
        exists (st_drain b (PTree.set _off (Vlong (Int64.repr (off + wr))) le2)), m. split.
        { eapply ok_trans; [exact Hstar|].
          apply seg_w_ok with (wr := wr) (off := off); [lia | lia | exact Hlw2 | exact Hlo2]. }
        apply match_drain.
        -- exact Hbuf.
        -- exact Hchunk.
        -- lia.
        -- exact Hload.
        -- ptree_solve.
        -- ptree_solve.
  - simpl in Hstep. discriminate.
Qed.

Hypothesis Hv0 : valid_world w0.

Lemma sim_run k : forall p s q m status pending final,
  reaches w0 p s ->
  RelayDeterminism.run k (p, s) = Some (Halt status pending, final) ->
  match_state p q m ->
  exists m', ok_star (q, m, s) (st_halt status, m', final).
Proof.
  induction k as [| k IH]; intros p s q m status pending final Hr Hrun Hm.
  - cbn [RelayDeterminism.run] in Hrun. inv Hrun. inv Hm. exists m. apply ok_refl.
  - cbn [RelayDeterminism.run] in Hrun.
    destruct (RelayDeterminism.step (p, s)) as [[p' s'] |] eqn:Hstep; [| discriminate].
    pose proof (reaches_valid w0 p s Hv0 Hr) as Hv.
    destruct (sim_step p s p' s' q m Hv Hstep Hm) as (q' & m1 & Hstar & Hm').
    pose proof (step_reaches w0 p s p' s' Hr Hstep) as Hr'.
    destruct (IH p' s' q' m1 status pending final Hr' Hrun Hm') as (m2 & Hstar2).
    exists m2. eapply ok_trans; eauto.
Qed.

(* ---------- the theorem ---------- *)

(* For the valid initial world w0 there is a finite execution of the Clight core
   semantics of relay_main.prog from the initial core, in which every external
   call is read/write answered as relay_dry_spec prescribes AND satisfies the
   dry precondition for an explicit witness (ok_steps), that ends HALTED in
   Returnstate (Vint (Int.repr status)) Kstop, in world final with
   outcome w0 status final pending: main's actual return value on the concrete
   execution is the protocol status of w0. *)
Theorem relay_main_termination :
  exists q0,
  semantics.initial_core csem 0 init_mem q0 init_mem (Vptr main_block Ptrofs.zero) [] /\
  exists k q m final status pending,
    ok_steps k (q0, init_mem, w0) (q, m, final) /\
    q = CRet (Vint (Int.repr status)) Kstop /\
    (forall i, semantics.halted csem q i) /\
    outcome w0 status final pending.
Proof.
  exists q0. split; [exact init_core|].
  destruct (run_halts_within (fuel w0) w0 Ready w0 (initial_ready w0)) as (k & status & pending & final & Hk & Hrun).
  { unfold fuel. rewrite Z2Nat.id by apply measure_nonneg. lia. }
  destruct (seg_init w0) as (b & m1 & Hstar0 & Hbuf).
  destruct (sim_run k Ready w0 (st_ready b (create_undef_temps (fn_temps f_relay))) m1 status pending final
              (initial_ready w0) Hrun (match_ready b (create_undef_temps (fn_temps f_relay)) m1 Hbuf))
    as (m2 & Hstar).
  destruct (ok_trans _ _ _ Hstar0 Hstar) as (n & Hsteps).
  exists n, (st_halt status), m2, final, status, pending.
  split; [exact Hsteps|]. split; [reflexivity|].
  split.
  { intro i. change (cl_halted (CRet (Vint (Int.repr status)) Kstop) <> None). discriminate. }
  exact (RelayDeterminism.run_reaches w0 k _ _ Hrun).
Qed.

(* The same execution as a plain Trace.dry_steps trace (the relation of
   Trace.relay_concrete_trace). *)
Corollary relay_main_termination_dry :
  exists q0,
  semantics.initial_core csem 0 init_mem q0 init_mem (Vptr main_block Ptrofs.zero) [] /\
  exists k q m final status pending,
    dsteps k (q0, init_mem, w0) (q, m, final) /\
    q = CRet (Vint (Int.repr status)) Kstop /\
    (forall i, semantics.halted csem q i) /\
    outcome w0 status final pending.
Proof.
  destruct relay_main_termination as (q0' & Hi & k & q & m & final & status & pending & Hs & Hq & Hh & Ho).
  exists q0'. split; [exact Hi|].
  exists k, q, m, final, status, pending. split; [apply ok_steps_dry; exact Hs | auto].
Qed.

End Witness.

Check (eq_refl : relay_main.f_relay = relay.f_relay).
Check relay_body_eq.
Print Assumptions relay_body_eq.
Check main_body_eq.
Print Assumptions main_body_eq.
Check relay_main_termination.
Print Assumptions relay_main_termination.
Check relay_main_termination_dry.
Print Assumptions relay_main_termination_dry.
