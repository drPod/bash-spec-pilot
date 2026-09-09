(* Independent table specification: Unicode 16, section 3.9.3, Tables 3-6/3-7.
   The return/error conventions are from the frozen gnulib API declaration.
   This specification is not itself evidence that the C function implements it. *)
From Coq Require Import List ZArith Bool.
Import ListNotations.
Local Open Scope Z_scope.

Module UnicodeSpec.

Definition rows : list (list (Z * Z)) :=
 [ [(0,127)];
   [(194,223);(128,191)];
   [(224,224);(160,191);(128,191)];
   [(225,236);(128,191);(128,191)];
   [(237,237);(128,159);(128,191)];
   [(238,239);(128,191);(128,191)];
   [(240,240);(144,191);(128,191);(128,191)];
   [(241,243);(128,191);(128,191);(128,191)];
   [(244,244);(128,143);(128,191);(128,191)] ].

Fixpoint compatible (row : list (Z * Z)) (bs : list Z) : bool :=
  match row, bs with
  | (lo,hi)::rs, b::tail => (lo <=? b) && (b <=? hi) && compatible rs tail
  | _, _ => true
  end.

Definition scalar (n : nat) (bs : list Z) : Z :=
  let lead := match n with 2%nat => 192 | 3%nat => 224 | 4%nat => 240 | _ => 0 end in
  fold_left (fun u b => 64*u + b - 128)
    (firstn (Nat.pred n) (tl bs)) (hd 0 bs - lead).

Definition full_row bs row :=
  (length row <=? length bs)%nat && compatible row bs.

Definition decode (bs : list Z) : Z * Z :=
  match find (full_row bs) rows with
  | Some row => (Z.of_nat (length row), scalar (length row) bs)
  | None => (if existsb (fun row => compatible row bs) rows then -2 else -1, 65533)
  end.

(* The relation separates complete legal encoding from API-level classification.
   It is deliberately not a proof of equivalence to another decoder. *)
Definition encoding (u : Z) (bs : list Z) : Prop :=
  exists row, In row rows /\ length row = length bs /\
    Forall2 (fun bounds b => fst bounds <= b <= snd bounds) row bs /\
    u = scalar (length row) bs.

Definition contract (bs : list Z) (ret codepoint : Z) : Prop :=
  bs <> [] /\ decode bs = (ret, codepoint).

End UnicodeSpec.
