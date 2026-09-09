(* Semantic oracle lemmas for UnicodeSpec (Unicode 16, section 3.9.3, Tables 3-6/3-7).
   These connect the API-level classifier `decode` to the table relation `encoding`
   and check the review witnesses by computation. They audit classifier logic only:
   both definitions share the nine-row table, so they cannot certify the table
   transcription itself. Nothing here concerns the C function. No Admitted, no axioms. *)
From Coq Require Import List ZArith Bool Lia.
Import ListNotations.
Local Open Scope Z_scope.
Require Import UnicodeSpec.
Import UnicodeSpec.UnicodeSpec.

(* ---- Review witnesses from UNICODE-ORACLE-REVIEW.md, now machine-checked ---- *)
Example w_nul       : decode [0] = (1, 0).                     Proof. vm_compute. reflexivity. Qed.
Example w_c2a2ff    : decode [194;162;255] = (2, 162).         Proof. vm_compute. reflexivity. Qed.
Example w_e282      : decode [226;130] = (-2, 65533).          Proof. vm_compute. reflexivity. Qed.
Example w_e09f      : decode [224;159] = (-1, 65533).          Proof. vm_compute. reflexivity. Qed.
Example w_eda0      : decode [237;160] = (-1, 65533).          Proof. vm_compute. reflexivity. Qed.
Example w_f490      : decode [244;144] = (-1, 65533).          Proof. vm_compute. reflexivity. Qed.
Example w_f09080    : decode [240;144;128] = (-2, 65533).      Proof. vm_compute. reflexivity. Qed.
Example w_f48fbfbf  : decode [244;143;191;191] = (4, 1114111). Proof. vm_compute. reflexivity. Qed.
(* Documents review condition 1: the total Coq function is totalized at [], which
   `contract` excludes. Not an API case. *)
Example w_empty_totalized : decode [] = (-2, 65533).           Proof. vm_compute. reflexivity. Qed.

(* Table 3-7 first-byte column, stated independently of the row list and checked
   exhaustively over all 256 single-byte inputs. *)
Definition first_byte_class (b : Z) : Z :=
  if b <? 128 then 1 else if b <? 194 then -1 else if b <? 245 then -2 else -1.

Lemma first_byte_exhaustive :
  forallb (fun b => Z.eqb (fst (decode [b])) (first_byte_class b))
          (map Z.of_nat (seq 0 256)) = true.
Proof. vm_compute. reflexivity. Qed.

(* ---- Structural lemmas ---- *)

Lemma compatible_forall2 : forall row bs,
  compatible row bs = true -> (length row <= length bs)%nat ->
  Forall2 (fun bounds b => fst bounds <= b <= snd bounds) row (firstn (length row) bs).
Proof.
  induction row as [|[lo hi] rs IH]; intros bs Hc Hl; simpl.
  - constructor.
  - destruct bs as [|b tail]; simpl in Hl; [lia|].
    simpl in Hc. apply andb_prop in Hc as [Hb Hrest]. apply andb_prop in Hb as [Hlo Hhi].
    constructor.
    + simpl. split; apply Z.leb_le; assumption.
    + apply IH; [exact Hrest | lia].
Qed.

Lemma scalar_firstn : forall n bs, (1 <= n)%nat -> scalar n (firstn n bs) = scalar n bs.
Proof.
  intros n bs Hn. destruct n as [|n']; [lia|].
  destruct bs as [|b tail]; [reflexivity|].
  unfold scalar. simpl. rewrite firstn_firstn, Nat.min_id. reflexivity.
Qed.

Lemma compatible_app_false : forall row bs tail,
  compatible row bs = false -> compatible row (bs ++ tail) = false.
Proof.
  induction row as [|[lo hi] rs IH]; intros bs tail Hc; simpl in *.
  - discriminate.
  - destruct bs as [|b t]; simpl in *; [discriminate|].
    destruct ((lo <=? b) && (b <=? hi)); simpl in *; [apply IH; exact Hc | reflexivity].
Qed.

(* ---- Characterization of the three API outcomes ---- *)

(* Success: the consumed prefix is a complete legal encoding of the returned scalar;
   the suffix is irrelevant. *)
Theorem decode_success_encoding : forall bs k u,
  decode bs = (Z.of_nat k, u) -> (0 < k)%nat ->
  (k <= length bs)%nat /\ encoding u (firstn k bs).
Proof.
  intros bs k u Hd Hk. unfold decode in Hd.
  destruct (find (full_row bs) rows) as [row|] eqn:Hf.
  - apply find_some in Hf as [Hin Hfull].
    unfold full_row in Hfull. apply andb_prop in Hfull as [Hlen Hc].
    apply Nat.leb_le in Hlen.
    injection Hd as Hk' Hu. apply Nat2Z.inj in Hk'. subst k.
    split; [exact Hlen|].
    exists row. split; [exact Hin|].
    split; [rewrite length_firstn, Nat.min_l by exact Hlen; reflexivity|].
    split; [apply compatible_forall2; assumption|].
    rewrite <- Hu. symmetry. apply scalar_firstn. lia.
  - exfalso.
    destruct (existsb (fun row => compatible row bs) rows) eqn:He; try rewrite He in Hd;
      injection Hd as Hk' Hu; pose proof (Nat2Z.is_nonneg k); lia.
Qed.

(* Incomplete (-2): some table row is compatible with the whole input but strictly
   longer than it, i.e. the input is a proper prefix of a legal encoding. *)
Theorem decode_incomplete_prefix : forall bs,
  fst (decode bs) = -2 ->
  exists row, In row rows /\ compatible row bs = true /\ (length bs < length row)%nat.
Proof.
  intros bs Hd. unfold decode in Hd.
  destruct (find (full_row bs) rows) as [row|] eqn:Hf.
  - simpl in Hd. lia.
  - destruct (existsb (fun row => compatible row bs) rows) eqn:He; simpl in Hd; [|lia].
    apply existsb_exists in He as [row [Hin Hc]].
    exists row. split; [exact Hin|]. split; [exact Hc|].
    pose proof (find_none _ _ Hf row Hin) as Hfr.
    unfold full_row in Hfr. apply andb_false_iff in Hfr as [Hl|Hl].
    + apply Nat.leb_gt in Hl. exact Hl.
    + congruence.
Qed.

(* Invalid (-1): no table row is compatible with the input ... *)
Theorem decode_invalid_no_prefix : forall bs,
  fst (decode bs) = -1 -> forall row, In row rows -> compatible row bs = false.
Proof.
  intros bs Hd row Hin.
  destruct (compatible row bs) eqn:Hc; [exfalso|reflexivity].
  assert (He : existsb (fun r => compatible r bs) rows = true)
    by (apply existsb_exists; exists row; auto).
  unfold decode in Hd. rewrite He in Hd.
  destruct (find (full_row bs) rows) as [r|]; simpl in Hd;
    [pose proof (Nat2Z.is_nonneg (length r)); lia | discriminate Hd].
Qed.

(* ... and therefore no additional bytes can repair it (CALIBRATION.md: "an already
   forbidden second byte is invalid, even when the total buffer is shorter than the
   nominal encoding length"). *)
Theorem decode_invalid_stable : forall bs tail,
  fst (decode bs) = -1 -> decode (bs ++ tail) = (-1, 65533).
Proof.
  intros bs tail Hd.
  assert (Hall : forall row, In row rows -> compatible row (bs ++ tail) = false).
  { intros row Hin. apply compatible_app_false. exact (decode_invalid_no_prefix bs Hd row Hin). }
  unfold decode.
  destruct (find (full_row (bs ++ tail)) rows) as [row|] eqn:Hf.
  - apply find_some in Hf as [Hin Hfull]. unfold full_row in Hfull.
    apply andb_prop in Hfull as [_ Hc]. rewrite Hall in Hc by exact Hin. discriminate.
  - destruct (existsb (fun row => compatible row (bs ++ tail)) rows) eqn:He; [|reflexivity].
    apply existsb_exists in He as [row [Hin Hc]]. rewrite Hall in Hc by exact Hin. discriminate.
Qed.

(* Success is also suffix-stable: a complete first character is unaffected by later bytes. *)
Lemma compatible_app_true : forall row bs tail,
  (length row <= length bs)%nat -> compatible row bs = true -> compatible row (bs ++ tail) = true.
Proof.
  induction row as [|[lo hi] rs IH]; intros bs tail Hl Hc; simpl in *.
  - reflexivity.
  - destruct bs as [|b t]; simpl in *; [lia|].
    destruct ((lo <=? b) && (b <=? hi)); simpl in *; [apply IH; [lia|exact Hc] | discriminate].
Qed.

Lemma full_row_app : forall bs tail row,
  full_row bs row = true -> full_row (bs ++ tail) row = true.
Proof.
  intros bs tail row H. unfold full_row in *. apply andb_prop in H as [Hl Hc].
  apply Nat.leb_le in Hl. apply andb_true_intro. split.
  - apply Nat.leb_le. rewrite length_app. lia.
  - apply compatible_app_true; assumption.
Qed.

Lemma full_row_app_inv : forall bs tail row,
  (length row <= length bs)%nat -> full_row (bs ++ tail) row = true -> full_row bs row = true.
Proof.
  intros bs tail row Hl H. unfold full_row in *. apply andb_prop in H as [_ Hc].
  apply andb_true_intro. split; [apply Nat.leb_le; exact Hl|].
  revert bs Hl Hc. induction row as [|[lo hi] rs IH]; intros bs Hl Hc; simpl in *.
  - reflexivity.
  - destruct bs as [|b t]; simpl in *; [lia|].
    destruct ((lo <=? b) && (b <=? hi)); simpl in *; [apply IH; [lia|exact Hc] | discriminate].
Qed.
