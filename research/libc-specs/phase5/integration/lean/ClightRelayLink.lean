import RelayClightDump
import CalculusRelaySchedules
import CalculusRelayShared
import CalculusCommands
open ClightSubset RelayClightDump

set_option linter.unusedSimpArgs false

/-!
# ClightRelayLink: the generated Clight `f_relay` runs exactly as `BufferRelay.execute`

Stage A: kernel-checked decomposition of the GENERATED body into named pieces, and the
evaluation lemmas for its expressions, call arguments and the two external calls. -/

namespace ClightRelayLink

/-! ## Named pieces of the generated body (identities checked by `rfl`) -/

def externTy : Ty := .tfunction [.tint, (.tptr .tvoid), .tulong] .tlong
def bufE : Expr := .evar "buf" (.tarray .tuchar 32)
def readArgs : List Expr := [(.econst_int 0 .tint), bufE, (.econst_int 32 .tint)]
def readCall : Stmt := .scall (some "t'1") (.evar "read" externTy) readArgs
def setN : Stmt := .sset "n" (.etempvar "t'1" .tlong)
def nNeg : Expr := .ebinop .olt (.etempvar "n" .tlong) (.econst_int 0 .tint) .tint
def nZero : Expr := .ebinop .oeq (.etempvar "n" .tlong) (.econst_int 0 .tint) .tint
def retC (k : Int) : Stmt := .sreturn (some (.econst_int k .tint))
def setOff0 : Stmt := .sset "off" (.ecast (.econst_int 0 .tint) .tulong)
def nU : Expr := .ecast (.etempvar "n" .tlong) .tulong
def innerCond : Expr := .ebinop .olt (.etempvar "off" .tulong) nU .tint
def writeArgs : List Expr :=
  [(.econst_int 1 .tint), (.ebinop .oadd bufE (.etempvar "off" .tulong) (.tptr .tuchar)),
   (.ebinop .osub nU (.etempvar "off" .tulong) .tulong)]
def writeCall : Stmt := .scall (some "t'2") (.evar "write" externTy) writeArgs
def setW : Stmt := .sset "w" (.etempvar "t'2" .tlong)
def wNonpos : Expr := .ebinop .ole (.etempvar "w" .tlong) (.econst_int 0 .tint) .tint
def advE : Expr := .ebinop .oadd (.etempvar "off" .tulong) (.ecast (.etempvar "w" .tlong) .tulong) .tulong
def advOff : Stmt := .sset "off" advE
def innerBody : Stmt :=
  .ssequence (.ssequence writeCall setW) (.ssequence (.sifthenelse wNonpos (retC 2) .sskip) advOff)
def innerLoop : Stmt := swhile innerCond innerBody
def outerBody : Stmt :=
  .ssequence (.ssequence readCall setN)
    (.ssequence (.sifthenelse nNeg (retC 1) .sskip)
      (.ssequence (.sifthenelse nZero (retC 0) .sskip) (.ssequence setOff0 innerLoop)))
def outerLoop : Stmt := .sloop (.ssequence .sskip outerBody) .sskip

theorem fRelay_body : fRelay.body = outerLoop := rfl
theorem fRelay_ret : fRelay.ret = .tint := rfl
theorem innerLoop_eq : innerLoop = .sloop (.ssequence (.sifthenelse innerCond .sskip .sbreak) innerBody) .sskip := rfl
theorem innerCond_typeof : innerCond.typeof = .tint := rfl
theorem wNonpos_typeof : wNonpos.typeof = .tint := rfl
theorem nNeg_typeof : nNeg.typeof = .tint := rfl
theorem nZero_typeof : nZero.typeof = .tint := rfl
theorem econst_typeof (k : Int) : (Expr.econst_int k .tint).typeof = .tint := rfl

/-! ## Small closed facts about the bit-vector values that occur -/

theorem sext0 : (BitVec.ofInt 32 0).signExtend 64 = (0 : BitVec 64) := by decide
theorem sext0' : (0#32 : BitVec 32).signExtend 64 = (0 : BitVec 64) := by decide
theorem sext0'' : BitVec.signExtend 64 (0 : BitVec 32) = (0 : BitVec 64) := by decide
theorem ofInt32_0 : BitVec.ofInt 32 0 = (0 : BitVec 32) := by decide
theorem ofInt32_1 : BitVec.ofInt 32 1 = (1 : BitVec 32) := by decide
theorem ofInt32_2 : BitVec.ofInt 32 2 = (2 : BitVec 32) := by decide
theorem ofInt32_32 : BitVec.ofInt 32 32 = (32 : BitVec 32) := by decide
theorem toNat32 : (32 : BitVec 64).toNat = 32 := by decide
theorem neg1_slt0 : (-1 : BitVec 64).slt 0 = true := by decide
theorem neg1_sle0 : (-1 : BitVec 64).sle 0 = true := by decide
theorem ofNat_slt0 : ∀ k, k ≤ 32 → (BitVec.ofNat 64 k).slt 0 = false := by decide
theorem ofNat_sle0 : ∀ k, k ≤ 32 → (BitVec.ofNat 64 k).sle 0 = decide (k = 0) := by decide
theorem ofNat_beq0 : ∀ k, k ≤ 32 → ((BitVec.ofNat 64 k) == 0) = decide (k = 0) := by decide
theorem ofNat_ult : ∀ j, j ≤ 32 → ∀ k, k ≤ 32 →
    (BitVec.ofNat 64 j).ult (BitVec.ofNat 64 k) = decide (j < k) := by decide
theorem ofNat_sub_toNat : ∀ k, k ≤ 32 → ∀ j, j ≤ k →
    (BitVec.ofNat 64 k - BitVec.ofNat 64 j).toNat = k - j := by decide
theorem ofNat_toNat32 : ∀ k, k ≤ 32 → (BitVec.ofNat 64 k).toNat = k := by decide
theorem ofNat_add32 : ∀ j, j ≤ 32 → ∀ k, k ≤ 32 →
    BitVec.ofNat 64 j + BitVec.ofNat 64 k = BitVec.ofNat 64 (j + k) := by decide
theorem boolVal_ofBool (b : Bool) : boolVal (ofBool b) .tint = some b := by
  cases b <;> decide

/-! ## Evaluation of the expressions of the body -/

theorem evalArgs_read (w : World) :
    evalArgs w readArgs [.tint, (.tptr .tvoid), .tulong] = some [.vint 0, .vptr 0, .vlong 32] := by
  first | rfl | decide

theorem evalExpr_nNeg (w : World) (n : BitVec 64)
    (h : CalculusNested.lookup w.temps "n" = some (.vlong n)) :
    evalExpr w nNeg = some (ofBool (n.slt 0)) := by
  simp [nNeg, evalExpr, h, Expr.typeof, semBinop, sext0]

theorem evalExpr_nZero (w : World) (n : BitVec 64)
    (h : CalculusNested.lookup w.temps "n" = some (.vlong n)) :
    evalExpr w nZero = some (ofBool (n == 0)) := by
  simp [nZero, evalExpr, h, Expr.typeof, semBinop, sext0]

theorem evalExpr_innerCond (w : World) (n off : BitVec 64)
    (hn : CalculusNested.lookup w.temps "n" = some (.vlong n))
    (hoff : CalculusNested.lookup w.temps "off" = some (.vlong off)) :
    evalExpr w innerCond = some (ofBool (off.ult n)) := by
  simp [innerCond, nU, evalExpr, hn, hoff, Expr.typeof, semBinop, semCast]

theorem evalArgs_write (w : World) (n off : BitVec 64)
    (hn : CalculusNested.lookup w.temps "n" = some (.vlong n))
    (hoff : CalculusNested.lookup w.temps "off" = some (.vlong off)) :
    evalArgs w writeArgs [.tint, (.tptr .tvoid), .tulong] =
      some [.vint 1, .vptr off, .vlong (n - off)] := by
  simp [writeArgs, bufE, nU, evalArgs, evalExpr, hn, hoff, Expr.typeof, semBinop, semCast, ofInt32_1]

theorem evalExpr_wNonpos (w : World) (wv : BitVec 64)
    (h : CalculusNested.lookup w.temps "w" = some (.vlong wv)) :
    evalExpr w wNonpos = some (ofBool (wv.sle 0)) := by
  simp [wNonpos, evalExpr, h, Expr.typeof, semBinop, sext0]

theorem evalExpr_advE (w : World) (off wv : BitVec 64)
    (hoff : CalculusNested.lookup w.temps "off" = some (.vlong off))
    (hw : CalculusNested.lookup w.temps "w" = some (.vlong wv)) :
    evalExpr w advE = some (.vlong (off + wv)) := by
  simp [advE, evalExpr, hoff, hw, Expr.typeof, semBinop, semCast]

theorem evalExpr_off0 (w : World) :
    evalExpr w (.ecast (.econst_int 0 .tint) .tulong) = some (.vlong 0) := by
  first | rfl | decide

theorem evalExpr_retC (w : World) (k : Int) :
    evalExpr w (.econst_int k .tint) = some (.vint (BitVec.ofInt 32 k)) := rfl

/-! ## The two external calls on the argument shapes that occur -/

theorem extRead_neg (w : World) (q : Int) (rest : List Int)
    (ha : BufferRelay.action 32 w.reads = (q, rest)) (hq : q < 0) :
    extRead (some "t'1") [.vint 0, .vptr 0, .vlong 32] w =
      some { w with reads := rest, readCalls := w.readCalls + 1,
                    temps := CalculusNested.assocSet w.temps "t'1" (.vlong (-1)) } := by
  simp [extRead, toNat32, ha, hq, setOpt]

theorem extRead_pos (w : World) (q : Int) (rest : List Int)
    (ha : BufferRelay.action 32 w.reads = (q, rest)) (hq : ¬ q < 0) :
    extRead (some "t'1") [.vint 0, .vptr 0, .vlong 32] w =
      some { w with mem := MemoryTransfer.store w.mem 0 (w.input.take (BufferRelay.readAmount w.input q)),
                    input := w.input.drop (BufferRelay.readAmount w.input q),
                    reads := rest, readCalls := w.readCalls + 1,
                    temps := CalculusNested.assocSet w.temps "t'1"
                      (.vlong (BitVec.ofNat 64 (BufferRelay.readAmount w.input q))) } := by
  have hb := (BufferRelay.readAmount_bounds w.input q).1
  simp [extRead, toNat32, ha, hq, setOpt, hb]

theorem extWrite_eq (w : World) (offN nN : Nat) (hle : offN ≤ nN) (h32 : nN ≤ 32) :
    extWrite (some "t'2") [.vint 1, .vptr (BitVec.ofNat 64 offN), .vlong (BitVec.ofNat 64 nN - BitVec.ofNat 64 offN)] w =
      let bs := MemoryTransfer.load w.mem offN (nN - offN) (by omega)
      let qr := BufferRelay.action bs.length w.writes
      if qr.1 < 0 then
        some { w with writes := qr.2, writeCalls := w.writeCalls + 1,
                      temps := CalculusNested.assocSet w.temps "t'2" (.vlong (-1)) }
      else
        some { w with delivered := w.delivered ++ bs.take (min qr.1.toNat bs.length), writes := qr.2,
                      writeCalls := w.writeCalls + 1,
                      temps := CalculusNested.assocSet w.temps "t'2"
                        (.vlong (BitVec.ofNat 64 (min qr.1.toNat bs.length))) } := by
  have h1 := ofNat_toNat32 offN (by omega)
  have h2 := ofNat_sub_toNat nN h32 offN hle
  simp only [extWrite, h1, h2, setOpt]
  simp only [show ¬ ((1 : BitVec 32) ≠ 1) from fun h => h rfl, if_false]
  rw [dif_pos (by omega)]


/-! ## Stage B: one-step equations of `exec` and the inner write loop -/

theorem exec_sskip (r : Ty) (n : Nat) (w : World) : exec r (n + 1) .sskip w = some (.normal, w) := rfl
theorem exec_sbreak (r : Ty) (n : Nat) (w : World) : exec r (n + 1) .sbreak w = some (.brk, w) := rfl
theorem exec_ssequence (r : Ty) (n : Nat) (a b : Stmt) (w : World) :
    exec r (n + 1) (.ssequence a b) w =
      match exec r n a w with
      | some (.normal, w1) => exec r n b w1
      | res => res := rfl
theorem exec_sset (r : Ty) (n : Nat) (x : String) (e : Expr) (w : World) :
    exec r (n + 1) (.sset x e) w =
      match evalExpr w e with
      | some v => some (.normal, { w with temps := CalculusNested.assocSet w.temps x v })
      | none => none := rfl
theorem exec_sifthenelse (r : Ty) (n : Nat) (c : Expr) (t e : Stmt) (w : World) :
    exec r (n + 1) (.sifthenelse c t e) w =
      match evalExpr w c with
      | some v =>
        match boolVal v c.typeof with
        | some true => exec r n t w
        | some false => exec r n e w
        | none => none
      | none => none := rfl
theorem exec_sreturn_some (r : Ty) (n : Nat) (e : Expr) (w : World) :
    exec r (n + 1) (.sreturn (some e)) w =
      match evalExpr w e with
      | some v =>
        match semCast v e.typeof r with
        | some v' => some (.ret (some v'), w)
        | none => none
      | none => none := rfl
theorem exec_scall_read (r : Ty) (n : Nat) (dst : Option String) (ps : List Ty) (rt : Ty)
    (args : List Expr) (w : World) :
    exec r (n + 1) (.scall dst (.evar "read" (.tfunction ps rt)) args) w =
      match evalArgs w args ps with
      | some vs => (extRead dst vs w).map (fun w' => (.normal, w'))
      | none => none := rfl
theorem exec_scall_write (r : Ty) (n : Nat) (dst : Option String) (ps : List Ty) (rt : Ty)
    (args : List Expr) (w : World) :
    exec r (n + 1) (.scall dst (.evar "write" (.tfunction ps rt)) args) w =
      match evalArgs w args ps with
      | some vs => (extWrite dst vs w).map (fun w' => (.normal, w'))
      | none => none := rfl
theorem exec_sloop (r : Ty) (n : Nat) (a b : Stmt) (w : World) :
    exec r (n + 1) (.sloop a b) w =
      match exec r n a w with
      | some (.normal, w1) | some (.cont, w1) =>
        match exec r n b w1 with
        | some (.normal, w2) => exec r n (.sloop a b) w2
        | some (.brk, w2) => some (.normal, w2)
        | some (.cont, _) => none
        | res => res
      | some (.brk, w1) => some (.normal, w1)
      | res => res := rfl

theorem load_length (m : Mem) (off k : Nat) (h : off + k ≤ 32) :
    (MemoryTransfer.load m off k h).length = k := by
  simp [MemoryTransfer.load]

/-- Return value of `write` as stored in `t'2`/`w`. -/
def wRet (q : Int) (len : Nat) : BitVec 64 :=
  if q < 0 then -1 else BitVec.ofNat 64 (min q.toNat len)

theorem wRet_sle0 (q : Int) (len : Nat) (hlen : len ≤ 32) (hpos : 0 < len) :
    (wRet q len).sle 0 = decide (q ≤ 0) := by
  unfold wRet
  by_cases hq : q < 0
  · simp [hq, neg1_sle0]; omega
  · rw [if_neg hq, ofNat_sle0 _ (by omega)]
    by_cases hz : q ≤ 0
    · have : q = 0 := by omega
      subst this; simp
    · have : ¬ (min q.toNat len = 0) := by omega
      simp [hz, this]

/-- Lookups through the two temps written by one inner iteration. -/
theorem lookup_t2 (t : List (String × Val)) (v : Val) :
    CalculusNested.lookup (CalculusNested.assocSet t "t'2" v) "t'2" = some v :=
  CalculusNested.lookup_assocSet_same _ _ _
theorem lookup_w2 (t : List (String × Val)) (v u : Val) :
    CalculusNested.lookup (CalculusNested.assocSet (CalculusNested.assocSet t "t'2" v) "w" u) "w" = some u :=
  CalculusNested.lookup_assocSet_same _ _ _
theorem lookup_off2 (t : List (String × Val)) (v u x : Val)
    (h : CalculusNested.lookup t "off" = some x) :
    CalculusNested.lookup (CalculusNested.assocSet (CalculusNested.assocSet t "t'2" v) "w" u) "off" = some x := by
  rw [CalculusNested.lookup_assocSet_other _ _ _ _ (by decide),
    CalculusNested.lookup_assocSet_other _ _ _ _ (by decide)]
  exact h
theorem lookup_n2 (t : List (String × Val)) (v u x : Val)
    (h : CalculusNested.lookup t "n" = some x) :
    CalculusNested.lookup (CalculusNested.assocSet (CalculusNested.assocSet t "t'2" v) "w" u) "n" = some x := by
  rw [CalculusNested.lookup_assocSet_other _ _ _ _ (by decide),
    CalculusNested.lookup_assocSet_other _ _ _ _ (by decide)]
  exact h

/-- One inner iteration with `off < n`, write fails (`q ≤ 0`): `return 2`. -/
theorem inner_step_fail (fuel : Nat) (w : World) (nN offN : Nat) (hlt : offN < nN) (h32 : nN ≤ 32)
    (hn : CalculusNested.lookup w.temps "n" = some (.vlong (BitVec.ofNat 64 nN)))
    (hoff : CalculusNested.lookup w.temps "off" = some (.vlong (BitVec.ofNat 64 offN)))
    (bs : List Byte) (hbs : MemoryTransfer.load w.mem offN (nN - offN) (by omega) = bs)
    (q : Int) (rest : List Int) (hqr : BufferRelay.action bs.length w.writes = (q, rest))
    (hq : q ≤ 0) :
    exec .tint (fuel + 7) (.ssequence (.sifthenelse innerCond .sskip .sbreak) innerBody) w =
      some (.ret (some (.vint 2)),
        { w with writes := rest, writeCalls := w.writeCalls + 1,
                 temps := CalculusNested.assocSet
                   (CalculusNested.assocSet w.temps "t'2" (.vlong (wRet q bs.length)))
                   "w" (.vlong (wRet q bs.length)) }) := by
  have hlen : bs.length = nN - offN := by rw [← hbs, load_length]
  have hext := extWrite_eq w offN nN (by omega) h32
  simp only [hbs, hqr] at hext
  by_cases hneg : q < 0
  · have hwr : wRet q bs.length = -1 := by simp [wRet, hneg]
    rw [hwr]
    simp only [innerBody, writeCall, setW, retC, externTy, exec_ssequence, exec_sifthenelse, exec_sskip,
      exec_sbreak, exec_sset, exec_sreturn_some, exec_scall_write, evalExpr_innerCond w _ _ hn hoff,
      innerCond_typeof, boolVal_ofBool, ofNat_ult offN (by omega) nN h32, decide_eq_true hlt,
      evalArgs_write w _ _ hn hoff, hext, hneg, if_true, Option.map_some]
    simp only [exec_ssequence, exec_sset, exec_sifthenelse, exec_sreturn_some, wNonpos, evalExpr,
      Expr.typeof, semBinop, semCast, sext0, lookup_t2, lookup_w2, boolVal_ofBool, neg1_sle0,
      ofInt32_2]
  · have hz : q = 0 := by omega
    subst hz
    have hwr : wRet 0 bs.length = BitVec.ofNat 64 0 := by simp [wRet]
    rw [hwr]
    simp only [innerBody, writeCall, setW, retC, externTy, exec_ssequence, exec_sifthenelse, exec_sskip,
      exec_sbreak, exec_sset, exec_sreturn_some, exec_scall_write, evalExpr_innerCond w _ _ hn hoff,
      innerCond_typeof, boolVal_ofBool, ofNat_ult offN (by omega) nN h32, decide_eq_true hlt,
      evalArgs_write w _ _ hn hoff, hext, hneg, if_false, Option.map_some, Int.toNat_zero,
      Nat.zero_min, List.take_zero, List.append_nil]
    simp only [exec_ssequence, exec_sset, exec_sifthenelse, exec_sreturn_some, wNonpos, evalExpr,
      Expr.typeof, semBinop, semCast, sext0, lookup_t2, lookup_w2, boolVal_ofBool,
      ofNat_sle0 0 (by omega), decide_true, ofInt32_2]

/-- One inner iteration with `off < n`, write succeeds (`0 < q`): advance `off`. -/
theorem inner_step_ok (fuel : Nat) (w : World) (nN offN : Nat) (hlt : offN < nN) (h32 : nN ≤ 32)
    (hn : CalculusNested.lookup w.temps "n" = some (.vlong (BitVec.ofNat 64 nN)))
    (hoff : CalculusNested.lookup w.temps "off" = some (.vlong (BitVec.ofNat 64 offN)))
    (bs : List Byte) (hbs : MemoryTransfer.load w.mem offN (nN - offN) (by omega) = bs)
    (q : Int) (rest : List Int) (hqr : BufferRelay.action bs.length w.writes = (q, rest))
    (hq : 0 < q) :
    exec .tint (fuel + 7) (.ssequence (.sifthenelse innerCond .sskip .sbreak) innerBody) w =
      some (.normal,
        { w with delivered := w.delivered ++ bs.take (min q.toNat bs.length),
                 writes := rest, writeCalls := w.writeCalls + 1,
                 temps := CalculusNested.assocSet (CalculusNested.assocSet
                   (CalculusNested.assocSet w.temps "t'2" (.vlong (BitVec.ofNat 64 (min q.toNat bs.length))))
                   "w" (.vlong (BitVec.ofNat 64 (min q.toNat bs.length))))
                   "off" (.vlong (BitVec.ofNat 64 (offN + min q.toNat bs.length))) }) := by
  have hlen : bs.length = nN - offN := by rw [← hbs, load_length]
  have hext := extWrite_eq w offN nN (by omega) h32
  simp only [hbs, hqr] at hext
  have hneg : ¬ q < 0 := by omega
  have hk0 : ¬ (min q.toNat bs.length = 0) := by omega
  have hadd : BitVec.ofNat 64 offN + BitVec.ofNat 64 (min q.toNat bs.length) =
      BitVec.ofNat 64 (offN + min q.toNat bs.length) :=
    ofNat_add32 offN (by omega) _ (by omega)
  simp only [innerBody, writeCall, setW, retC, advOff, externTy, exec_ssequence, exec_sifthenelse,
    exec_sskip, exec_sbreak, exec_sset, exec_sreturn_some, exec_scall_write,
    evalExpr_innerCond w _ _ hn hoff, innerCond_typeof, boolVal_ofBool,
    ofNat_ult offN (by omega) nN h32, decide_eq_true hlt, evalArgs_write w _ _ hn hoff, hext, hneg,
    if_false, Option.map_some]
  have ho2 : ∀ v u, CalculusNested.lookup (CalculusNested.assocSet
      (CalculusNested.assocSet w.temps "t'2" v) "w" u) "off" = some (.vlong (BitVec.ofNat 64 offN)) :=
    fun v u => lookup_off2 _ _ _ _ hoff
  simp only [exec_ssequence, exec_sset, exec_sifthenelse, exec_sskip, wNonpos, advE, evalExpr,
    Expr.typeof, semBinop, semCast, sext0, lookup_t2, lookup_w2, ho2, boolVal_ofBool,
    ofNat_sle0 _ (by omega : min q.toNat bs.length ≤ 32), decide_eq_false hk0, hadd]

/-! ## Stage C: the inner write loop is `BufferRelay.drain` on the loaded range -/

theorem load_drop (m : Mem) (off n j : Nat) (h : off + n ≤ 32) (hj : j ≤ n) :
    (MemoryTransfer.load m off n h).drop j = MemoryTransfer.load m (off + j) (n - j) (by omega) := by
  have hr := BufferRelay.retry_pointer_load m off n j (n - j) h (by omega)
  rw [← hr, List.take_of_length_le]
  simp [List.length_drop, load_length]

/-- Loop exit: `off = n`, the condition is false, the loop leaves normally. -/
theorem inner_done (fuel : Nat) (w : World) (nN : Nat) (h32 : nN ≤ 32)
    (hn : CalculusNested.lookup w.temps "n" = some (.vlong (BitVec.ofNat 64 nN)))
    (hoff : CalculusNested.lookup w.temps "off" = some (.vlong (BitVec.ofNat 64 nN))) :
    exec .tint (fuel + 9) innerLoop w = some (.normal, w) := by
  rw [innerLoop_eq, show fuel + 9 = (fuel + 8) + 1 by omega, exec_sloop]
  simp only [exec_ssequence, exec_sifthenelse, exec_sskip, exec_sbreak,
    evalExpr_innerCond w _ _ hn hoff, innerCond_typeof, boolVal_ofBool, ofNat_ult nN h32 nN h32,
    decide_eq_false (Nat.lt_irrefl nN)]

theorem drain_nil (ws : List Int) : BufferRelay.drain [] ws = ⟨[], [], ws, 0, false⟩ := by
  rw [BufferRelay.drain]; simp

theorem drain_fail (bs : List Byte) (ws : List Int) (hne : bs ≠ []) (q : Int) (rest : List Int)
    (hqr : BufferRelay.action bs.length ws = (q, rest)) (hq : q ≤ 0) :
    BufferRelay.drain bs ws = ⟨[], bs, rest, 1, true⟩ := by
  rw [BufferRelay.drain, dif_neg hne]; simp [hqr, hq]

theorem drain_ok (bs : List Byte) (ws : List Int) (hne : bs ≠ []) (q : Int) (rest : List Int)
    (hqr : BufferRelay.action bs.length ws = (q, rest)) (hq : ¬ q ≤ 0) :
    BufferRelay.drain bs ws =
      ⟨bs.take (min q.toNat bs.length) ++ (BufferRelay.drain (bs.drop (min q.toNat bs.length)) rest).output,
       (BufferRelay.drain (bs.drop (min q.toNat bs.length)) rest).pending,
       (BufferRelay.drain (bs.drop (min q.toNat bs.length)) rest).writes,
       (BufferRelay.drain (bs.drop (min q.toNat bs.length)) rest).calls + 1,
       (BufferRelay.drain (bs.drop (min q.toNat bs.length)) rest).failed⟩ := by
  rw [BufferRelay.drain, dif_neg hne]; simp [hqr, hq]

set_option maxHeartbeats 1000000 in
/-- The inner `while` from `off ≤ n`: exactly `BufferRelay.drain` on the bytes `[off, n)` of the
    block; on failure `return 2` with the unwritten suffix `[off', n)` still in memory. -/
theorem inner_run : ∀ (d fuel : Nat) (w : World) (nN offN : Nat)
    (_hd : nN - offN ≤ d) (hle : offN ≤ nN) (h32 : nN ≤ 32)
    (_hn : CalculusNested.lookup w.temps "n" = some (.vlong (BitVec.ofNat 64 nN)))
    (_hoff : CalculusNested.lookup w.temps "off" = some (.vlong (BitVec.ofNat 64 offN)))
    (bs : List Byte) (_hbs : MemoryTransfer.load w.mem offN (nN - offN) (by omega) = bs),
    ∃ w', exec .tint (fuel + d + 9) innerLoop w =
        some (if (BufferRelay.drain bs w.writes).failed then .ret (some (.vint 2)) else .normal, w') ∧
      w'.mem = w.mem ∧ w'.input = w.input ∧ w'.reads = w.reads ∧ w'.readCalls = w.readCalls ∧
      w'.writes = (BufferRelay.drain bs w.writes).writes ∧
      w'.delivered = w.delivered ++ (BufferRelay.drain bs w.writes).output ∧
      w'.writeCalls = w.writeCalls + (BufferRelay.drain bs w.writes).calls ∧
      CalculusNested.lookup w'.temps "n" = some (.vlong (BitVec.ofNat 64 nN)) ∧
      ((BufferRelay.drain bs w.writes).failed = true →
        ∃ off', ∃ hle' : off' ≤ nN,
          CalculusNested.lookup w'.temps "off" = some (.vlong (BitVec.ofNat 64 off')) ∧
          MemoryTransfer.load w.mem off' (nN - off') (by omega) = (BufferRelay.drain bs w.writes).pending) ∧
      ((BufferRelay.drain bs w.writes).failed = false →
        CalculusNested.lookup w'.temps "off" = some (.vlong (BitVec.ofNat 64 nN))) := by
  intro d
  induction d with
  | zero =>
    intro fuel w nN offN hd hle h32 hn hoff bs hbs
    have heq : offN = nN := by omega
    subst heq
    have hbs0 : bs = [] := by
      apply List.eq_nil_of_length_eq_zero
      rw [← hbs, load_length]; omega
    subst hbs0
    rw [drain_nil]
    refine ⟨w, ?_, rfl, rfl, rfl, rfl, rfl, ?_, ?_, hn, ?_, ?_⟩
    · rw [show fuel + 0 + 9 = fuel + 9 by omega, inner_done fuel w offN h32 hn hoff]; simp
    · simp
    · simp
    · intro h; cases h
    · intro _; exact hoff
  | succ d ih =>
    intro fuel w nN offN hd hle h32 hn hoff bs hbs
    by_cases hz : offN = nN
    · subst hz
      have hbs0 : bs = [] := by
        apply List.eq_nil_of_length_eq_zero
        rw [← hbs, load_length]; omega
      subst hbs0
      rw [drain_nil]
      refine ⟨w, ?_, rfl, rfl, rfl, rfl, rfl, ?_, ?_, hn, ?_, ?_⟩
      · rw [show fuel + (d + 1) + 9 = (fuel + d + 1) + 9 by omega,
          inner_done (fuel + d + 1) w offN h32 hn hoff]; simp
      · simp
      · simp
      · intro h; cases h
      · intro _; exact hoff
    · have hlt : offN < nN := by omega
      subst hbs
      have hlen : (MemoryTransfer.load w.mem offN (nN - offN) (by omega)).length = nN - offN :=
        load_length _ _ _ _
      have hne : MemoryTransfer.load w.mem offN (nN - offN) (by omega) ≠ [] := by
        intro h; rw [h] at hlen; simp at hlen; omega
      obtain ⟨⟨q, rest⟩, hqr⟩ : ∃ p, BufferRelay.action
        (MemoryTransfer.load w.mem offN (nN - offN) (by omega)).length w.writes = p := ⟨_, rfl⟩
      rw [innerLoop_eq, show fuel + (d + 1) + 9 = (fuel + d + 9) + 1 by omega, exec_sloop]
      by_cases hq : q ≤ 0
      · have hstep := inner_step_fail (fuel + d + 2) w nN offN hlt h32 hn hoff _ rfl q rest hqr hq
        rw [show fuel + d + 2 + 7 = fuel + d + 9 by omega] at hstep
        rw [hstep, drain_fail _ w.writes hne q rest hqr hq]
        refine ⟨_, rfl, rfl, rfl, rfl, rfl, rfl, ?_, rfl, ?_, ?_, ?_⟩
        · simp
        · exact lookup_n2 _ _ _ _ hn
        · intro _
          exact ⟨offN, hle, lookup_off2 _ _ _ _ hoff, rfl⟩
        · intro h; cases h
      · have hqpos : 0 < q := by omega
        have hstep := inner_step_ok (fuel + d + 2) w nN offN hlt h32 hn hoff _ rfl q rest hqr hqpos
        rw [show fuel + d + 2 + 7 = fuel + d + 9 by omega] at hstep
        rw [hstep, drain_ok _ w.writes hne q rest hqr hq]
        obtain ⟨k, hk⟩ : ∃ k, min q.toNat
          (MemoryTransfer.load w.mem offN (nN - offN) (by omega)).length = k := ⟨_, rfl⟩
        rw [hk]
        have hk1 : 1 ≤ k := by omega
        have hk2 : k ≤ nN - offN := by omega
        have hload : MemoryTransfer.load w.mem (offN + k) (nN - (offN + k)) (by omega) =
            (MemoryTransfer.load w.mem offN (nN - offN) (by omega)).drop k := by
          rw [load_drop w.mem offN (nN - offN) k (by omega) hk2]
          congr 1; omega
        obtain ⟨w', hrun, hmem, hin, hrd, hrc, hws, hdv, hwc, hn', hfail, hok⟩ :=
          ih fuel
            { w with delivered := w.delivered ++
                       (MemoryTransfer.load w.mem offN (nN - offN) (by omega)).take k,
                     writes := rest, writeCalls := w.writeCalls + 1,
                     temps := CalculusNested.assocSet (CalculusNested.assocSet
                       (CalculusNested.assocSet w.temps "t'2" (.vlong (BitVec.ofNat 64 k)))
                       "w" (.vlong (BitVec.ofNat 64 k)))
                       "off" (.vlong (BitVec.ofNat 64 (offN + k))) }
            nN (offN + k) (by omega) (by omega) h32
            (by
              show CalculusNested.lookup (CalculusNested.assocSet (CalculusNested.assocSet
                (CalculusNested.assocSet w.temps "t'2" (.vlong (BitVec.ofNat 64 k)))
                "w" (.vlong (BitVec.ofNat 64 k))) "off" (.vlong (BitVec.ofNat 64 (offN + k)))) "n" = _
              rw [CalculusNested.lookup_assocSet_other _ _ _ _ (by decide)]
              exact lookup_n2 _ _ _ _ hn)
            (CalculusNested.lookup_assocSet_same _ _ _) _ hload
        rw [innerLoop_eq] at hrun
        simp only at hmem hin hrd hrc hws hdv hwc
        refine ⟨w', ?_, hmem, hin, hrd, hrc, hws, ?_, ?_, hn', ?_, hok⟩
        · simp only [exec_sskip, hrun]
        · rw [hdv, List.append_assoc]
        · rw [hwc]; (try dsimp only); omega
        · intro hf
          obtain ⟨off', hle', hoff', hload'⟩ := hfail hf
          exact ⟨off', hle', hoff', hload'⟩

#print axioms inner_run

/-! ## Stage D: the outer read loop is `BufferRelay.execute` -/

theorem action_rest (n : Nat) (xs : List Int) (q : Int) (rest : List Int)
    (h : BufferRelay.action n xs = (q, rest)) : rest = xs.drop 1 := by
  cases xs with
  | nil => simp [BufferRelay.action] at h; rw [h.2]; rfl
  | cons a t => simp [BufferRelay.action] at h; rw [h.2]; rfl

/-- Residual write schedule of `drain` is the schedule dropped by its call count. -/
theorem drain_writes_drop : ∀ (d : Nat) (bs : List Byte) (ws : List Int), bs.length ≤ d →
    (BufferRelay.drain bs ws).writes = ws.drop (BufferRelay.drain bs ws).calls := by
  intro d
  induction d with
  | zero =>
    intro bs ws hd
    have : bs = [] := List.eq_nil_of_length_eq_zero (by omega)
    subst this; rw [drain_nil]; rfl
  | succ d ih =>
    intro bs ws hd
    by_cases hz : bs = []
    · subst hz; rw [drain_nil]; rfl
    · obtain ⟨⟨q, rest⟩, hqr⟩ : ∃ p, BufferRelay.action bs.length ws = p := ⟨_, rfl⟩
      have hrest := action_rest _ _ _ _ hqr
      by_cases hq : q ≤ 0
      · rw [drain_fail bs ws hz q rest hqr hq]; exact hrest
      · rw [drain_ok bs ws hz q rest hqr hq]
        have hk : 1 ≤ min q.toNat bs.length := by
          have := List.length_pos_iff.mpr hz; omega
        have := ih (bs.drop (min q.toNat bs.length)) rest (by simp [List.length_drop]; omega)
        simp only
        rw [this, hrest, List.drop_drop, Nat.add_comm]

theorem ofInt32_0' : BitVec.ofInt 32 0 = BitVec.ofNat 32 0 := by decide
theorem ofInt32_1' : BitVec.ofInt 32 1 = BitVec.ofNat 32 1 := by decide
theorem ofInt32_2' : BitVec.ofInt 32 2 = BitVec.ofNat 32 2 := by decide

/-- Temps after `read`+`n := t'1`: `n` is the read result. -/
theorem lookup_n_after (t : List (String × Val)) (v : Val) :
    CalculusNested.lookup (CalculusNested.assocSet (CalculusNested.assocSet t "t'1" v) "n" v) "n" = some v :=
  CalculusNested.lookup_assocSet_same _ _ _

/-- The read call followed by `n := t'1` on a world with schedule head `q`. -/
theorem read_and_set (fuel : Nat) (w : World) (q : Int) (rest : List Int)
    (ha : BufferRelay.action 32 w.reads = (q, rest)) :
    exec .tint (fuel + 2) (.ssequence readCall setN) w =
      if q < 0 then
        some (.normal, { w with
          reads := rest, readCalls := w.readCalls + 1,
          temps := CalculusNested.assocSet (CalculusNested.assocSet w.temps "t'1" (.vlong (-1))) "n"
            (.vlong (-1)) })
      else
        some (.normal, { w with
          mem := MemoryTransfer.store w.mem 0 (w.input.take (BufferRelay.readAmount w.input q)),
          input := w.input.drop (BufferRelay.readAmount w.input q),
          reads := rest, readCalls := w.readCalls + 1,
          temps := CalculusNested.assocSet (CalculusNested.assocSet w.temps "t'1"
            (.vlong (BitVec.ofNat 64 (BufferRelay.readAmount w.input q)))) "n"
            (.vlong (BitVec.ofNat 64 (BufferRelay.readAmount w.input q))) }) := by
  by_cases hq : q < 0
  · rw [if_pos hq]
    simp only [readCall, setN, externTy, exec_ssequence, exec_scall_read, exec_sset, evalArgs_read,
      extRead_neg w q rest ha hq, Option.map_some, evalExpr, CalculusNested.lookup_assocSet_same]
  · rw [if_neg hq]
    simp only [readCall, setN, externTy, exec_ssequence, exec_scall_read, exec_sset, evalArgs_read,
      extRead_pos w q rest ha hq, Option.map_some, evalExpr, CalculusNested.lookup_assocSet_same]

/-- Outer iteration, read error: `return 1`. -/
theorem outer_read_error (fuel : Nat) (w : World) (q : Int) (rest : List Int)
    (ha : BufferRelay.action 32 w.reads = (q, rest)) (hq : q < 0) :
    exec .tint (fuel + 7) (.ssequence .sskip outerBody) w =
      some (.ret (some (.vint (BitVec.ofNat 32 1))),
        { w with
          reads := rest, readCalls := w.readCalls + 1,
          temps := CalculusNested.assocSet (CalculusNested.assocSet w.temps "t'1" (.vlong (-1))) "n"
            (.vlong (-1)) }) := by
  have hr := read_and_set (fuel + 3) w q rest ha
  rw [if_pos hq] at hr
  simp only [outerBody, exec_ssequence, exec_sskip, hr, exec_sifthenelse, retC, exec_sreturn_some,
    nNeg, evalExpr, Expr.typeof, lookup_n_after, semBinop, sext0, boolVal_ofBool, neg1_slt0,
    semCast, ofInt32_1']

/-- Outer iteration, EOF (`q ≥ 0`, empty input): `return 0`. -/
theorem outer_eof (fuel : Nat) (w : World) (q : Int) (rest : List Int)
    (ha : BufferRelay.action 32 w.reads = (q, rest)) (hq : ¬ q < 0) (hin : w.input = []) :
    exec .tint (fuel + 7) (.ssequence .sskip outerBody) w =
      some (.ret (some (.vint (BitVec.ofNat 32 0))),
        { w with
          mem := MemoryTransfer.store w.mem 0 [], input := [], reads := rest,
          readCalls := w.readCalls + 1,
          temps := CalculusNested.assocSet (CalculusNested.assocSet w.temps "t'1"
            (.vlong (BitVec.ofNat 64 0))) "n" (.vlong (BitVec.ofNat 64 0)) }) := by
  have hr := read_and_set (fuel + 3) w q rest ha
  rw [if_neg hq] at hr
  have hk : BufferRelay.readAmount [] q = 0 := by simp [BufferRelay.readAmount]
  simp only [hin, hk, List.take_nil, List.drop_nil] at hr
  simp only [outerBody, exec_ssequence, exec_sskip, hr, exec_sifthenelse, retC, exec_sreturn_some,
    nNeg, nZero, evalExpr, Expr.typeof, lookup_n_after, semBinop, sext0, sext0', sext0'', boolVal_ofBool,
    ofNat_slt0 0 (by omega), ofNat_beq0 0 (by omega), decide_true, semCast, ofInt32_0']

theorem lookup_n_after_off (t : List (String × Val)) (v u : Val) :
    CalculusNested.lookup (CalculusNested.assocSet (CalculusNested.assocSet
      (CalculusNested.assocSet t "t'1" v) "n" v) "off" u) "n" = some v := by
  rw [CalculusNested.lookup_assocSet_other _ _ _ _ (by decide)]
  exact lookup_n_after _ _

theorem two_eq : (2 : BitVec 32) = BitVec.ofNat 32 2 := rfl

theorem load_store_len (m : Mem) (xs : List Byte) (n : Nat) (hn : xs.length = n) (h : 0 + n ≤ 32) :
    MemoryTransfer.load (MemoryTransfer.store m 0 xs) 0 n h = xs := by
  subst hn; exact MemoryTransfer.load_store m 0 xs h

set_option maxHeartbeats 1000000 in
/-- Outer iteration with data (`q ≥ 0`, nonempty input): read `k` bytes, then the inner loop is
    `BufferRelay.drain` on those bytes; `return 2` on write failure, otherwise fall through. -/
theorem outer_data (fuel : Nat) (w : World) (q : Int) (rest : List Int)
    (ha : BufferRelay.action 32 w.reads = (q, rest)) (hq : ¬ q < 0) (hne : w.input ≠ []) :
    ∃ w4, exec .tint (fuel + w.input.length + 45) (.ssequence .sskip outerBody) w =
        some (if (BufferRelay.drain (w.input.take (BufferRelay.readAmount w.input q)) w.writes).failed
                then .ret (some (.vint (BitVec.ofNat 32 2))) else .normal, w4) ∧
      w4.mem = MemoryTransfer.store w.mem 0 (w.input.take (BufferRelay.readAmount w.input q)) ∧
      w4.input = w.input.drop (BufferRelay.readAmount w.input q) ∧
      w4.reads = rest ∧ w4.readCalls = w.readCalls + 1 ∧
      w4.writes = (BufferRelay.drain (w.input.take (BufferRelay.readAmount w.input q)) w.writes).writes ∧
      w4.delivered = w.delivered ++
        (BufferRelay.drain (w.input.take (BufferRelay.readAmount w.input q)) w.writes).output ∧
      w4.writeCalls = w.writeCalls +
        (BufferRelay.drain (w.input.take (BufferRelay.readAmount w.input q)) w.writes).calls ∧
      ((BufferRelay.drain (w.input.take (BufferRelay.readAmount w.input q)) w.writes).failed = true →
        ∃ off', ∃ hle' : off' ≤ BufferRelay.readAmount w.input q,
          CalculusNested.lookup w4.temps "n" =
            some (.vlong (BitVec.ofNat 64 (BufferRelay.readAmount w.input q))) ∧
          CalculusNested.lookup w4.temps "off" = some (.vlong (BitVec.ofNat 64 off')) ∧
          MemoryTransfer.load w4.mem off' (BufferRelay.readAmount w.input q - off')
            (by have := (BufferRelay.readAmount_bounds w.input q).1; omega) =
            (BufferRelay.drain (w.input.take (BufferRelay.readAmount w.input q)) w.writes).pending) := by
  have hkb := BufferRelay.readAmount_bounds w.input q
  have hkpos := BufferRelay.readAmount_positive w.input q hne
  have hr := read_and_set (fuel + w.input.length + 41) w q rest ha
  rw [if_neg hq, show fuel + w.input.length + 41 + 2 = fuel + w.input.length + 43 by omega] at hr
  have hl : (w.input.take (BufferRelay.readAmount w.input q)).length = BufferRelay.readAmount w.input q := by
    simp [List.length_take]; omega
  have hload : MemoryTransfer.load (MemoryTransfer.store w.mem 0 (w.input.take (BufferRelay.readAmount w.input q)))
      0 (BufferRelay.readAmount w.input q - 0) (by omega) = w.input.take (BufferRelay.readAmount w.input q) :=
    load_store_len _ _ _ (by rw [hl]; omega) _
  obtain ⟨w4, hrun, hmem, hin, hrd, hrc, hws, hdv, hwc, hn', hfail, hok⟩ :=
    inner_run (BufferRelay.readAmount w.input q) (fuel + w.input.length + 31 - BufferRelay.readAmount w.input q)
      { w with mem := MemoryTransfer.store w.mem 0 (w.input.take (BufferRelay.readAmount w.input q)),
               input := w.input.drop (BufferRelay.readAmount w.input q),
               reads := rest, readCalls := w.readCalls + 1,
               temps := CalculusNested.assocSet (CalculusNested.assocSet (CalculusNested.assocSet
                 w.temps "t'1" (.vlong (BitVec.ofNat 64 (BufferRelay.readAmount w.input q)))) "n"
                 (.vlong (BitVec.ofNat 64 (BufferRelay.readAmount w.input q))))
                 "off" (.vlong 0) }
      (BufferRelay.readAmount w.input q) 0 (Nat.le_refl _) (Nat.zero_le _) hkb.1 (lookup_n_after_off _ _ _)
      (CalculusNested.lookup_assocSet_same _ _ _) _ hload
  rw [show fuel + w.input.length + 31 - BufferRelay.readAmount w.input q + BufferRelay.readAmount w.input q + 9 =
    fuel + w.input.length + 40 by omega] at hrun
  simp only at hmem hin hrd hrc hws hdv hwc
  refine ⟨w4, ?_, hmem, hin, hrd, hrc, hws, hdv, hwc, ?_⟩
  · simp only [outerBody, exec_ssequence, exec_sskip, hr, exec_sifthenelse, retC, setOff0, nNeg, nZero,
      evalExpr, Expr.typeof, lookup_n_after, semBinop, sext0, sext0', sext0'', boolVal_ofBool,
      ofNat_slt0 _ hkb.1, ofNat_beq0 _ hkb.1, decide_eq_false (by omega : ¬ BufferRelay.readAmount w.input q = 0),
      exec_sset, semCast, ofInt32_0, hrun, two_eq]
  · intro hf
    obtain ⟨off', hle', hoff', hload'⟩ := hfail hf
    exact ⟨off', hle', hn', hoff', by rw [hmem]; exact hload'⟩

set_option maxHeartbeats 2000000 in
/-- The generated `relay` body from any memory `m` and world fields runs to exactly
    `BufferRelay.execute m inp rs ws`: same status, delivered output, remaining input, residual
    schedules and cumulative counters; on status 2 the undelivered bytes `[off, n)` are in memory. -/
theorem outer_run (m : Mem) (inp : List Byte) (rs ws : List Int) :
    ∀ (fuel : Nat) (temps : List (String × Val)) (dv : List Byte) (rc wc : Nat),
    ∃ w', exec .tint (fuel + inp.length + 46) outerLoop ⟨m, temps, inp, rs, ws, dv, rc, wc⟩ =
        some (.ret (some (.vint (BitVec.ofNat 32 (BufferRelay.execute m inp rs ws).status))), w') ∧
      w'.delivered = dv ++ (BufferRelay.execute m inp rs ws).output ∧
      w'.input = (BufferRelay.execute m inp rs ws).remaining ∧
      w'.reads = rs.drop (BufferRelay.execute m inp rs ws).readCalls ∧
      w'.writes = ws.drop (BufferRelay.execute m inp rs ws).writeCalls ∧
      w'.readCalls = rc + (BufferRelay.execute m inp rs ws).readCalls ∧
      w'.writeCalls = wc + (BufferRelay.execute m inp rs ws).writeCalls ∧
      ((BufferRelay.execute m inp rs ws).status = 2 →
        ∃ nN off', ∃ hle : off' ≤ nN, ∃ h32 : nN ≤ 32,
          CalculusNested.lookup w'.temps "n" = some (.vlong (BitVec.ofNat 64 nN)) ∧
          CalculusNested.lookup w'.temps "off" = some (.vlong (BitVec.ofNat 64 off')) ∧
          MemoryTransfer.load w'.mem off' (nN - off') (by omega) =
            (BufferRelay.execute m inp rs ws).pending) := by
  induction m, inp, rs, ws using BufferRelay.execute.induct with
  | case1 mem input reads writes q rest ha hq =>
    intro fuel temps dv rc wc
    rw [BufferRelay.execute_read_error _ _ _ _ q rest ha hq]
    have h := outer_read_error (fuel + input.length + 38) ⟨mem, temps, input, reads, writes, dv, rc, wc⟩
      q rest ha hq
    rw [show fuel + input.length + 38 + 7 = fuel + input.length + 45 by omega] at h
    rw [outerLoop, show fuel + input.length + 46 = (fuel + input.length + 45) + 1 by omega, exec_sloop, h]
    refine ⟨_, rfl, by simp, rfl, action_rest _ _ _ _ ha, rfl, rfl, by simp, ?_⟩
    intro h2; simp at h2
  | case2 mem reads writes q rest ha hq =>
    intro fuel temps dv rc wc
    rw [BufferRelay.execute_eof _ _ _ q rest ha (by omega)]
    have h := outer_eof (fuel + 38) ⟨mem, temps, [], reads, writes, dv, rc, wc⟩ q rest ha hq rfl
    rw [show fuel + 38 + 7 = fuel + ([] : List Byte).length + 45 by simp] at h
    rw [outerLoop, show fuel + ([] : List Byte).length + 46 = (fuel + ([] : List Byte).length + 45) + 1 by simp,
      exec_sloop, h]
    refine ⟨_, rfl, by simp, rfl, action_rest _ _ _ _ ha, rfl, rfl, by simp, ?_⟩
    intro h2; simp at h2
  | case3 mem input reads writes q rest ha hq hn d hf =>
    intro fuel temps dv rc wc
    dsimp only [d] at hf
    rw [BufferRelay.loaded_eq] at hf
    rw [BufferRelay.execute_write_failure _ _ _ _ q rest ha (by omega) hn (by rw [BufferRelay.loaded_eq]; exact hf)]
    simp only [BufferRelay.loaded_eq]
    obtain ⟨w4, hrun, hmem, hin, hrd, hrc, hws, hdv, hwc, hpend⟩ :=
      outer_data fuel ⟨mem, temps, input, reads, writes, dv, rc, wc⟩ q rest ha hq hn
    simp only at hrun hmem hin hrd hrc hws hdv hwc hpend
    rw [hf] at hrun
    rw [outerLoop, show fuel + input.length + 46 = (fuel + input.length + 45) + 1 by omega, exec_sloop, hrun]
    refine ⟨w4, rfl, hdv, hin, ?_, ?_, hrc, hwc, ?_⟩
    · rw [hrd]; exact action_rest _ _ _ _ ha
    · rw [hws]; exact drain_writes_drop _ _ _ (Nat.le_refl _)
    · intro _
      obtain ⟨off', hle', hn', hoff', hload'⟩ := hpend hf
      exact ⟨_, off', hle', (BufferRelay.readAmount_bounds input q).1, hn', hoff', hload'⟩
  | case4 mem input reads writes q rest ha hq hn k nextMem d hf ih =>
    intro fuel temps dv rc wc
    dsimp only [d, k, nextMem] at hf ih
    rw [BufferRelay.loaded_eq] at hf ih
    have hf' : (BufferRelay.drain (input.take (BufferRelay.readAmount input q)) writes).failed = false := by
      cases h : (BufferRelay.drain (input.take (BufferRelay.readAmount input q)) writes).failed <;> simp_all
    have hex : BufferRelay.execute mem input reads writes =
        ⟨(BufferRelay.drain (input.take (BufferRelay.readAmount input q)) writes).output ++
            (BufferRelay.execute (BufferRelay.fill mem input q) (input.drop (BufferRelay.readAmount input q)) rest
              (BufferRelay.drain (input.take (BufferRelay.readAmount input q)) writes).writes).output,
          (BufferRelay.execute (BufferRelay.fill mem input q) (input.drop (BufferRelay.readAmount input q)) rest
            (BufferRelay.drain (input.take (BufferRelay.readAmount input q)) writes).writes).remaining,
          (BufferRelay.execute (BufferRelay.fill mem input q) (input.drop (BufferRelay.readAmount input q)) rest
            (BufferRelay.drain (input.take (BufferRelay.readAmount input q)) writes).writes).pending,
          (BufferRelay.execute (BufferRelay.fill mem input q) (input.drop (BufferRelay.readAmount input q)) rest
            (BufferRelay.drain (input.take (BufferRelay.readAmount input q)) writes).writes).status,
          (BufferRelay.execute (BufferRelay.fill mem input q) (input.drop (BufferRelay.readAmount input q)) rest
            (BufferRelay.drain (input.take (BufferRelay.readAmount input q)) writes).writes).readCalls + 1,
          (BufferRelay.drain (input.take (BufferRelay.readAmount input q)) writes).calls +
            (BufferRelay.execute (BufferRelay.fill mem input q) (input.drop (BufferRelay.readAmount input q)) rest
              (BufferRelay.drain (input.take (BufferRelay.readAmount input q)) writes).writes).writeCalls⟩ := by
      rw [BufferRelay.execute]
      simp only [ha, hq, if_false, hn, dite_false, BufferRelay.loaded_eq, hf', Bool.false_eq_true]
    rw [hex]
    obtain ⟨w4, hrun, hmem, hin, hrd, hrc, hws, hdv, hwc, _⟩ :=
      outer_data fuel ⟨mem, temps, input, reads, writes, dv, rc, wc⟩ q rest ha hq hn
    simp only at hrun hmem hin hrd hrc hws hdv hwc
    rw [hf'] at hrun
    simp only [Bool.false_eq_true, if_false] at hrun
    have hkpos := BufferRelay.readAmount_positive input q hn
    have hkb := (BufferRelay.readAmount_bounds input q).2
    have hlen : (input.drop (BufferRelay.readAmount input q)).length = input.length - BufferRelay.readAmount input q := by
      simp [List.length_drop]
    obtain ⟨w', hrun', hdv', hin', hrd', hws', hrc', hwc', hpend'⟩ :=
      ih (fuel + BufferRelay.readAmount input q - 1) w4.temps (dv ++ (BufferRelay.drain (input.take (BufferRelay.readAmount input q)) writes).output)
        (rc + 1) (wc + (BufferRelay.drain (input.take (BufferRelay.readAmount input q)) writes).calls)
    have hw4 : w4 = ⟨BufferRelay.fill mem input q, w4.temps, input.drop (BufferRelay.readAmount input q), rest,
        (BufferRelay.drain (input.take (BufferRelay.readAmount input q)) writes).writes,
        dv ++ (BufferRelay.drain (input.take (BufferRelay.readAmount input q)) writes).output, rc + 1,
        wc + (BufferRelay.drain (input.take (BufferRelay.readAmount input q)) writes).calls⟩ := by
      cases w4
      simp only at hmem hin hrd hrc hws hdv hwc
      simp only [hmem, hin, hrd, hrc, hws, hdv, hwc, BufferRelay.fill]
    rw [show fuel + BufferRelay.readAmount input q - 1 + (input.drop (BufferRelay.readAmount input q)).length + 46 =
      fuel + input.length + 45 by rw [hlen]; omega] at hrun'
    rw [outerLoop] at hrun' ⊢
    rw [show fuel + input.length + 46 = (fuel + input.length + 45) + 1 by omega, exec_sloop, hrun]
    simp only [exec_sskip]
    rw [← hw4] at hrun'
    rw [hrun']
    refine ⟨w', rfl, ?_, hin', ?_, ?_, ?_, ?_, hpend'⟩
    · rw [hdv', List.append_assoc]
    · rw [hrd', action_rest _ _ _ _ ha, List.drop_drop, Nat.add_comm]
    · rw [hws', drain_writes_drop _ _ _ (Nat.le_refl _), List.drop_drop]
    · rw [hrc']; omega
    · rw [hwc']; omega

#print axioms outer_data
#print axioms outer_run

#print axioms drain_writes_drop
#print axioms outer_read_error
#print axioms outer_eof

/-! ## Stage E: the generated C relay from the driver's initial world, and the calculus -/

/-- The GENERATED Clight `f_relay`, run from any initial memory with the given input and
    schedules, returns exactly `BufferRelay.execute`'s status and leaves its output, remaining
    input, residual schedules and call counters; on status 2 the undelivered chunk suffix is the
    memory range `[off, n)`. -/
theorem relay_clight_execute (m0 : Mem) (inp : List Byte) (rs ws : List Int) (fuel : Nat) :
    ∃ w', runFunc fRelay (fuel + inp.length + 46) m0 inp rs ws =
        some (.ret (some (.vint (BitVec.ofNat 32 (BufferRelay.execute m0 inp rs ws).status))), w') ∧
      w'.delivered = (BufferRelay.execute m0 inp rs ws).output ∧
      w'.input = (BufferRelay.execute m0 inp rs ws).remaining ∧
      w'.reads = rs.drop (BufferRelay.execute m0 inp rs ws).readCalls ∧
      w'.writes = ws.drop (BufferRelay.execute m0 inp rs ws).writeCalls ∧
      w'.readCalls = (BufferRelay.execute m0 inp rs ws).readCalls ∧
      w'.writeCalls = (BufferRelay.execute m0 inp rs ws).writeCalls ∧
      ((BufferRelay.execute m0 inp rs ws).status = 2 →
        ∃ nN off', ∃ hle : off' ≤ nN, ∃ h32 : nN ≤ 32,
          CalculusNested.lookup w'.temps "n" = some (.vlong (BitVec.ofNat 64 nN)) ∧
          CalculusNested.lookup w'.temps "off" = some (.vlong (BitVec.ofNat 64 off')) ∧
          MemoryTransfer.load w'.mem off' (nN - off') (by omega) =
            (BufferRelay.execute m0 inp rs ws).pending) := by
  obtain ⟨w', h, hdv, hin, hrd, hws, hrc, hwc, hpend⟩ := outer_run m0 inp rs ws fuel [] [] 0 0
  refine ⟨w', ?_, ?_, hin, hrd, hws, ?_, ?_, hpend⟩
  · show exec .tint (fuel + inp.length + 46) outerLoop ⟨m0, [], inp, rs, ws, [], 0, 0⟩ = _
    exact h
  · rw [hdv, List.nil_append]
  · rw [hrc, Nat.zero_add]
  · rw [hwc, Nat.zero_add]

open CalculusRelaySpec CalculusRelaySchedules CalculusRelayShared in
/-- C source as specification meets the actual calculus, fresh state: the generated Clight relay
    and the actual Nested run of the exported calculus `relay` (accepted
    `relay_matches_phase3_schedules`) return the same status, and the calculus root fields are
    exactly the C world's delivered bytes, remaining input, both counters and both residual
    schedules; `lost` is the reference's pending list, which on status 2 is the C memory range
    `[off, n)`. Premises: the exported body identities and the accepted input-length headroom. -/
theorem clight_calculus_initialState (actDef : String → CalculusNested.Stmt String)
    (hwb : actDef "write_block" = CalculusBody.writeBlockBody)
    (hrb : actDef "read_block" = CalculusRelayOuter.readBlockBody)
    (hrelay : actDef "relay" = CalculusBody.relayBody)
    (fuel : Nat) (inp : List Byte) (rs ws : List Int)
    (hlen : (inp.length : Int) + 1 ≤ CalculusNested.maxInt) :
    ∃ w' st', runFunc fRelay (fuel + inp.length + 46) (fun _ => 0) inp rs ws =
        some (.ret (some (.vint (BitVec.ofNat 32 (BufferRelay.run inp rs ws).status))), w') ∧
      CalculusNested.runEntry actDef (fuel + 2 * inp.length + 110) "relay"
        (initialState (toInts inp) rs ws) =
        .continue (CalculusNested.assocSet CalculusNested.initEnv "rc"
          (.v (.lit (.int ((BufferRelay.run inp rs ws).status : Int))))) st' ∧
      CalculusNested.getAttrAt .here st' "delivered" =
        some (CalculusNested.Val.ofIntList (toInts w'.delivered)) ∧
      CalculusNested.getAttrAt .here st' "input" = some (CalculusNested.Val.ofIntList (toInts w'.input)) ∧
      CalculusNested.getAttrAt .here st' "read_calls" = some (.lit (.int w'.readCalls)) ∧
      CalculusNested.getAttrAt .here st' "write_calls" = some (.lit (.int w'.writeCalls)) ∧
      CalculusNested.getAttrAt .here st' "reads" = some (CalculusNested.Val.ofIntList w'.reads) ∧
      CalculusNested.getAttrAt .here st' "writes" = some (CalculusNested.Val.ofIntList w'.writes) ∧
      CalculusNested.getAttrAt .here st' "lost" =
        some (CalculusNested.Val.ofIntList (toInts (BufferRelay.runDetailed inp rs ws).pending)) ∧
      ((BufferRelay.run inp rs ws).status = 2 →
        ∃ nN off', ∃ hle : off' ≤ nN, ∃ h32 : nN ≤ 32,
          CalculusNested.lookup w'.temps "n" = some (.vlong (BitVec.ofNat 64 nN)) ∧
          CalculusNested.lookup w'.temps "off" = some (.vlong (BitVec.ofNat 64 off')) ∧
          MemoryTransfer.load w'.mem off' (nN - off') (by omega) =
            (BufferRelay.runDetailed inp rs ws).pending) := by
  obtain ⟨w', hc, hdv, hin, hrd, hws, hrc, hwc, hpend⟩ :=
    relay_clight_execute (fun _ => 0) inp rs ws fuel
  obtain ⟨st', hk, hox⟩ := relay_matches_phase3_schedules actDef hwb hrb hrelay fuel inp rs ws hlen
  have hres := OuterExactSchedules.residuals_drop st' _ _ _ _ _ (fun _ => 0) inp rs ws hox
  refine ⟨w', st', hc, hk, ?_, ?_, ?_, ?_, ?_, ?_, hox.hls, hpend⟩
  · rw [hdv]; exact hox.hdv
  · rw [hin]; exact hox.hinp
  · rw [hrc]; exact hox.hrc
  · rw [hwc]; exact hox.hwc
  · rw [hrd]; exact hres.1
  · rw [hws]; exact hres.2

open CalculusRelaySpec CalculusRelayShared in
/-- C source as specification meets the actual calculus on ANY related shared state: the script
    grammar's `relay` atom (`CalculusCommands.atomStep .relay`, the primitive behind every
    accepted command/query theorem) is what the generated Clight relay computes from the shared
    world's current input and schedules, and the actual Nested `relay` action (accepted
    `relay_action_shared`) reaches a state related to that same world. -/
theorem clight_calculus_shared (actDef : String → CalculusNested.Stmt String)
    (hwb : actDef "write_block" = CalculusBody.writeBlockBody)
    (hrb : actDef "read_block" = CalculusRelayOuter.readBlockBody)
    (hrelay : actDef "relay" = CalculusBody.relayBody)
    (fuel : Nat) (env : CalculusNested.Env) (name : String) (st : CalculusNested.St)
    (w : QueryWorld) (hr : Related st w) (hb : Headroom w) :
    ∃ w' st', runFunc fRelay (fuel + w.input.length + 46) (fun _ => 0) w.input w.reads w.writes =
        some (.ret (some (.vint (BitVec.ofNat 32
          (CalculusCommands.atomStep CalculusCommands.Atom.relay w).1))), w') ∧
      CalculusNested.interp actDef (fuel + 2 * w.input.length + 110)
        (.action name "relay" (.lit .unit)) env st =
        .continue (CalculusNested.assocSet env name
          (.v (.lit (.int ((CalculusCommands.atomStep CalculusCommands.Atom.relay w).1 : Int))))) st' ∧
      Related st' (CalculusCommands.atomStep CalculusCommands.Atom.relay w).2 ∧
      (CalculusCommands.atomStep CalculusCommands.Atom.relay w).2.input = w'.input ∧
      (CalculusCommands.atomStep CalculusCommands.Atom.relay w).2.reads = w'.reads ∧
      (CalculusCommands.atomStep CalculusCommands.Atom.relay w).2.writes = w'.writes ∧
      (CalculusCommands.atomStep CalculusCommands.Atom.relay w).2.delivered = w.delivered ++ w'.delivered ∧
      (CalculusCommands.atomStep CalculusCommands.Atom.relay w).2.readCalls =
        w.readCalls + (w'.readCalls : Int) ∧
      (CalculusCommands.atomStep CalculusCommands.Atom.relay w).2.writeCalls =
        w.writeCalls + (w'.writeCalls : Int) ∧
      (CalculusCommands.atomStep CalculusCommands.Atom.relay w).2.lost = w.lost ++ (result w).pending ∧
      ((CalculusCommands.atomStep CalculusCommands.Atom.relay w).1 = 2 →
        ∃ nN off', ∃ hle : off' ≤ nN, ∃ h32 : nN ≤ 32,
          CalculusNested.lookup w'.temps "n" = some (.vlong (BitVec.ofNat 64 nN)) ∧
          CalculusNested.lookup w'.temps "off" = some (.vlong (BitVec.ofNat 64 off')) ∧
          MemoryTransfer.load w'.mem off' (nN - off') (by omega) = (result w).pending) := by
  obtain ⟨w', hc, hdv, hin, hrd, hws, hrc, hwc, hpend⟩ :=
    relay_clight_execute (fun _ => 0) w.input w.reads w.writes fuel
  obtain ⟨st', he, hx⟩ := relay_action_shared actDef hwb hrb hrelay fuel env name st w hr hb
  refine ⟨w', st', hc, he, hx, ?_, ?_, ?_, ?_, ?_, ?_, rfl, hpend⟩
  · show (result w).remaining = w'.input; exact hin.symm
  · show w.reads.drop (result w).readCalls = w'.reads; exact hrd.symm
  · show w.writes.drop (result w).writeCalls = w'.writes; exact hws.symm
  · show w.delivered ++ (result w).output = w.delivered ++ w'.delivered; rw [hdv]; rfl
  · show w.readCalls + ((result w).readCalls : Int) = w.readCalls + (w'.readCalls : Int); rw [hrc]; rfl
  · show w.writeCalls + ((result w).writeCalls : Int) = w.writeCalls + (w'.writeCalls : Int); rw [hwc]; rfl

/-- The same, stated literally on the generated function's return type and body. -/
theorem relay_clight_execute_body (m0 : Mem) (inp : List Byte) (rs ws : List Int) (fuel : Nat) :
    ∃ w', exec fRelay.ret (fuel + inp.length + 46) fRelay.body (initWorld m0 inp rs ws) =
        some (.ret (some (.vint (BitVec.ofNat 32 (BufferRelay.execute m0 inp rs ws).status))), w') ∧
      w'.delivered = (BufferRelay.execute m0 inp rs ws).output ∧
      w'.input = (BufferRelay.execute m0 inp rs ws).remaining ∧
      w'.reads = rs.drop (BufferRelay.execute m0 inp rs ws).readCalls ∧
      w'.writes = ws.drop (BufferRelay.execute m0 inp rs ws).writeCalls ∧
      w'.readCalls = (BufferRelay.execute m0 inp rs ws).readCalls ∧
      w'.writeCalls = (BufferRelay.execute m0 inp rs ws).writeCalls :=
  let ⟨w', h, hdv, hin, hrd, hws, hrc, hwc, _⟩ := relay_clight_execute m0 inp rs ws fuel
  ⟨w', h, hdv, hin, hrd, hws, hrc, hwc⟩

#print axioms read_and_set
#print axioms inner_step_fail
#print axioms inner_step_ok
#print axioms inner_done
#print axioms relay_clight_execute
#print axioms relay_clight_execute_body
#print axioms clight_calculus_initialState
#print axioms clight_calculus_shared

#print axioms fRelay_body
#print axioms evalArgs_read
#print axioms extRead_pos
#print axioms extWrite_eq

end ClightRelayLink
