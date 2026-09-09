/-
CalculusRelayRaising.lean (raising-entry-catch-118; snapshot114 6873bf80 preserved byte-exact)

Bounded: prologue + runEntry "relay_raising" + compose CalculusTryCatch with proved
callee (termination/result-shape only: ret0 | raise ReadError(-1) | ret2).
97/101/111/114 snapshots preserved. Job 128: neg-read same-post + catch same-`s` + one positive inner same-post.
Job 131: full inner-loop same post-`St` (continue / ret-2) by structural induction.
Job 138: one positive outer continue-arm same post-`St` + full outer same-post induction.
Job 143: prologue + runEntry same-post vs ordinary relay; catch restores status 1
    at the same post-`St` via raising_prologue (not undischarged hwrap).
Job 146: compose 143 same-post with accepted `relay_matches_phase3_schedules`
    (exact status + seven root fields vs `BufferRelay.run` / `runDetailed`).
-/
import CalculusLowering
import CalculusTryCatch
import CalculusRelaySchedules
open CalculusNested CalculusBody CalculusSimulation CalculusLowering CalculusRelayOuter CalculusRelayLoop
open CalculusRelaySpec CalculusRelaySchedules

set_option linter.unusedSimpArgs false

namespace CalculusRelayRaising

/-- Inner `while` of exported `relay_raising` (temps `$t22`/`$t23`/`$t24`, vs `$t18`/`$t19`/`$t20`
    on `relay`). Same control as `relayInnerBody`. -/
def raisingInnerBody : Stmt String :=
(.seq
  (.seq
    (.seq
      (.action "$t22" "write_block"
        (.pair (.var "b")
          (.pair (.fn (.range 0 4611686018427387903) (.var "off"))
            (.fn (.range 0 4611686018427387903) (.var "r")))))
      (.assign "w" (.var "$t22")))
    (.seq
      (.cond (.fn .le (.pair (.var "w") (.lit (.int 0))))
        (.seq
          (.seq
            (.get "$t23" (.var "σ") "lost")
            (.seq
              (.get "$t24" (.var "b") "bytes")
              (.setAttr (.var "σ") "lost"
                (.fn .append (.pair (.var "$t23")
                  (.fn .slice (.pair (.var "$t24")
                    (.pair (.fn (.range 0 4611686018427387903) (.var "off"))
                      (.fn (.range 0 4611686018427387903) (.var "r"))))))))))
          (.ret (.lit (.int 2))))
        .pass)
      (.assign "off" (.fn .add (.pair (.var "off") (.var "w"))))))
  .pass)

def raisingInnerLoop : Stmt String :=
  .while (.fn .lt (.pair (.var "off") (.var "r"))) raisingInnerBody

/-- Outer-loop body of `relay_raising`: same as `relayOuterBody` except
    `raise (ReadError, r)` for the negative-read arm and `$t21` for the read_block temp. -/
def raisingOuterBody : Stmt String :=
(.seq
  (.seq
    (.seq
      (.action "$t21" "read_block" (.var "b"))
      (.assign "r" (.var "$t21")))
    (.seq
      (.cond (.fn .lt (.pair (.var "r") (.lit (.int 0))))
        (.raise (.pair (.lit (.str "ReadError")) (.var "r")))
        .pass)
      (.seq
        (.cond (.fn .eq (.pair (.var "r") (.lit (.int 0))))
          (.ret (.lit (.int 0)))
          .pass)
        (.seq
          (.assign "off" (.lit (.int 0)))
          raisingInnerLoop))))
  .pass)

def raisingOuterLoop : Stmt String := .while (.lit (.bool true)) raisingOuterBody

/-- Kernel identity: the exported `relayRaisingBody` IS prologue + `raisingOuterLoop`. -/
theorem relayRaisingBody_eq : relayRaisingBody =
(.seq
  (.removeElem (.var "σ") "block" (.lit (.int 0)))
  (.seq
    (.addElem (.var "σ") "block" (.lit (.int 0)))
    (.seq
      (.assign "b" (.elem (.var "σ") "block" (.lit (.int 0))))
      (.seq
        (.setAttr (.var "b") "cap" (.lit (.int 32)))
        (.seq
          (.setAttr (.var "b") "len" (.lit (.int 0)))
          (.seq
            (.setAttr (.var "b") "bytes" (.fn .empty (.lit .unit)))
            raisingOuterLoop)))))) := rfl

/-- The only statement that differs in control from `relay`'s corresponding cond. -/
def readErrorRaise : Stmt String :=
  .cond (.fn .lt (.pair (.var "r") (.lit (.int 0))))
    (.raise (.pair (.lit (.str "ReadError")) (.var "r")))
    .pass

def readErrorRet1 : Stmt String :=
  .cond (.fn .lt (.pair (.var "r") (.lit (.int 0))))
    (.ret (.lit (.int 1)))
    .pass

/-- Negative `r`: the raising cond raises `ReadError(r)` at the same env/state. -/
theorem readErrorRaise_of_neg (actDef : String → Stmt String) (fuel : Nat) (env : Env)
    (st : St) (r : Int) (hr : lookup env "r" = some (.v (.lit (.int r)))) (hneg : r < 0) :
    interp actDef (fuel + 2) readErrorRaise env st =
      .raise (.pair (.lit (.str "ReadError")) (.lit (.int r))) env st := by
  simp only [readErrorRaise, interp_succ_cond, interp_succ_raise, evalExpr, hr, funcDef_lt,
    hneg, decide_true, Option.map]

/-- Negative `r`: `relay`'s cond returns 1 at the same env/state. -/
theorem readErrorRet1_of_neg (actDef : String → Stmt String) (fuel : Nat) (env : Env)
    (st : St) (r : Int) (hr : lookup env "r" = some (.v (.lit (.int r)))) (hneg : r < 0) :
    interp actDef (fuel + 2) readErrorRet1 env st =
      .ret (.lit (.int 1)) env st := by
  simp only [readErrorRet1, interp_succ_cond, interp_succ_ret, evalExpr, hr, funcDef_lt,
    hneg, decide_true, Option.map]

/-- Non-negative `r`: both conds fall through to `.pass` (same continue). -/
theorem readErrorRaise_of_nonneg (actDef : String → Stmt String) (fuel : Nat) (env : Env)
    (st : St) (r : Int) (hr : lookup env "r" = some (.v (.lit (.int r)))) (hnn : ¬ r < 0) :
    interp actDef (fuel + 2) readErrorRaise env st = .continue env st := by
  simp only [readErrorRaise, interp_succ_cond, interp_succ_pass, evalExpr, hr, funcDef_lt,
    hnn, decide_false, Option.map]

theorem readErrorRet1_of_nonneg (actDef : String → Stmt String) (fuel : Nat) (env : Env)
    (st : St) (r : Int) (hr : lookup env "r" = some (.v (.lit (.int r)))) (hnn : ¬ r < 0) :
    interp actDef (fuel + 2) readErrorRet1 env st = .continue env st := by
  simp only [readErrorRet1, interp_succ_cond, interp_succ_pass, evalExpr, hr, funcDef_lt,
    hnn, decide_false, Option.map]

/-- Direct swap on the cond: negative read maps `.ret 1` to `.raise ReadError(r)` at identical
    env and state. -/
theorem readError_swap_neg (actDef : String → Stmt String) (fuel : Nat) (env : Env)
    (st : St) (r : Int) (hr : lookup env "r" = some (.v (.lit (.int r)))) (hneg : r < 0) :
    interp actDef (fuel + 2) readErrorRaise env st =
      match interp actDef (fuel + 2) readErrorRet1 env st with
      | .ret (.lit (.int 1)) e s =>
          .raise (.pair (.lit (.str "ReadError")) (.lit (.int r))) e s
      | other => other := by
  rw [readErrorRaise_of_neg actDef fuel env st r hr hneg,
      readErrorRet1_of_neg actDef fuel env st r hr hneg]
  rfl

/-- Direct swap on the cond: non-negative `r` is identical continue. -/
theorem readError_swap_nonneg (actDef : String → Stmt String) (fuel : Nat) (env : Env)
    (st : St) (r : Int) (hr : lookup env "r" = some (.v (.lit (.int r)))) (hnn : ¬ r < 0) :
    interp actDef (fuel + 2) readErrorRaise env st =
      interp actDef (fuel + 2) readErrorRet1 env st := by
  rw [readErrorRaise_of_nonneg actDef fuel env st r hr hnn,
      readErrorRet1_of_nonneg actDef fuel env st r hr hnn]

/-- One outer iteration of `raisingOuterLoop` when `read_block` returns a negative `r`:
    the loop raises `ReadError(r)` and does not enter the inner write loop.
    Fuel: `read_block` is invoked at `fuel`; the loop is run at `fuel + 6`. -/
theorem raising_outer_of_neg_read (actDef : String → Stmt String) (fuel : Nat)
    (env e : Env) (st s : St) (pb : Path) (r : Int)
    (hb : lookup env "b" = some (.sref pb))
    (hrb : actDef "read_block" = readBlockBody)
    (hcall : interp actDef fuel readBlockBody (calleeEnv (.sref pb)) st =
      .ret (.lit (.int r)) e s)
    (hneg : r < 0) :
    interp actDef (fuel + 6) raisingOuterLoop env st =
      .raise (.pair (.lit (.str "ReadError")) (.lit (.int r)))
        (assocSet (assocSet env "$t21" (.v (.lit (.int r)))) "r" (.v (.lit (.int r)))) s := by
  cases fuel with
  | zero =>
    simp [readBlockBody, interp] at hcall
  | succ f =>
    have hctrue : evalExpr env (.lit (.bool true)) = some (.v (.lit (.bool true))) := rfl
    rw [raisingOuterLoop, interp_while_true actDef (f + 1 + 5) env st _ raisingOuterBody hctrue]
    unfold raisingOuterBody
    simp only [interp_succ_seq, interp_succ_action, interp_succ_assign, interp_succ_cond,
      interp_succ_raise, evalExpr, lookup_assocSet_same, hb, hrb, hcall, funcDef_lt,
      hneg, decide_true, Option.map]

/-- Same negative-read step on `relayOuterLoop` returns 1 (existing control, restated at the
    same fuel so the swap is comparable). -/
theorem relay_outer_of_neg_read (actDef : String → Stmt String) (fuel : Nat)
    (env e : Env) (st s : St) (pb : Path) (r : Int)
    (hb : lookup env "b" = some (.sref pb))
    (hrb : actDef "read_block" = readBlockBody)
    (hcall : interp actDef fuel readBlockBody (calleeEnv (.sref pb)) st =
      .ret (.lit (.int r)) e s)
    (hneg : r < 0) :
    interp actDef (fuel + 6) relayOuterLoop env st =
      .ret (.lit (.int 1))
        (assocSet (assocSet env "$t17" (.v (.lit (.int r)))) "r" (.v (.lit (.int r)))) s := by
  cases fuel with
  | zero =>
    simp [readBlockBody, interp] at hcall
  | succ f =>
    have hctrue : evalExpr env (.lit (.bool true)) = some (.v (.lit (.bool true))) := rfl
    rw [relayOuterLoop, interp_while_true actDef (f + 1 + 5) env st _ relayOuterBody hctrue]
    unfold relayOuterBody
    simp only [interp_succ_seq, interp_succ_action, interp_succ_assign, interp_succ_cond,
      interp_succ_ret, evalExpr, lookup_assocSet_same, hb, hrb, hcall, funcDef_lt,
      hneg, decide_true, Option.map]

/-- `read_block` returns exactly `-1` on a negative schedule entry (`read_block_body_neg`).
    So the raise payload of `raising_outer_of_neg_read` is the constant `-1` whenever the
    callee is the actual exported body. -/
theorem raising_outer_of_neg_read_payload_neg1 (actDef : String → Stmt String) (fuel : Nat)
    (env e : Env) (st s : St) (pb : Path)
    (hb : lookup env "b" = some (.sref pb))
    (hrb : actDef "read_block" = readBlockBody)
    (hcall : interp actDef fuel readBlockBody (calleeEnv (.sref pb)) st =
      .ret (.lit (.int (-1))) e s) :
    interp actDef (fuel + 6) raisingOuterLoop env st =
      .raise (.pair (.lit (.str "ReadError")) (.lit (.int (-1))))
        (assocSet (assocSet env "$t21" (.v (.lit (.int (-1))))) "r" (.v (.lit (.int (-1))))) s :=
  raising_outer_of_neg_read actDef fuel env e st s pb (-1) hb hrb hcall (by decide)

/-- One outer iteration when `read_block` returns `r = 0`: the loop returns 0 and does not
    enter the inner write loop. Fuel: `read_block` at `fuel`; loop at `fuel + 6`. -/
theorem raising_outer_of_zero_read (actDef : String → Stmt String) (fuel : Nat)
    (env e : Env) (st s : St) (pb : Path)
    (hb : lookup env "b" = some (.sref pb))
    (hrb : actDef "read_block" = readBlockBody)
    (hcall : interp actDef fuel readBlockBody (calleeEnv (.sref pb)) st =
      .ret (.lit (.int 0)) e s) :
    interp actDef (fuel + 6) raisingOuterLoop env st =
      .ret (.lit (.int 0))
        (assocSet (assocSet env "$t21" (.v (.lit (.int 0)))) "r" (.v (.lit (.int 0)))) s := by
  cases fuel with
  | zero =>
    simp [readBlockBody, interp] at hcall
  | succ f =>
    cases f with
    | zero =>
      simp [readBlockBody, interp] at hcall
    | succ f =>
      have hctrue : evalExpr env (.lit (.bool true)) = some (.v (.lit (.bool true))) := rfl
      have hlt : decide ((0 : Int) < 0) = false := rfl
      have heq : decide ((0 : Int) = 0) = true := rfl
      have ht : decide True = true := rfl
      have hf : decide False = false := rfl
      rw [raisingOuterLoop, interp_while_true actDef (f + 2 + 5) env st _ raisingOuterBody hctrue]
      unfold raisingOuterBody
      simp only [interp_succ_seq, interp_succ_action, interp_succ_assign, interp_succ_cond,
        interp_succ_ret, interp_succ_pass, evalExpr, lookup_assocSet_same, hb, hrb, hcall,
        funcDef_lt, funcDef_eq_int, Option.map_some, hlt, heq, ht, hf]

/-- Same zero-read step on `relayOuterLoop` also returns 0 (`$t17` vs `$t21`). -/
theorem relay_outer_of_zero_read (actDef : String → Stmt String) (fuel : Nat)
    (env e : Env) (st s : St) (pb : Path)
    (hb : lookup env "b" = some (.sref pb))
    (hrb : actDef "read_block" = readBlockBody)
    (hcall : interp actDef fuel readBlockBody (calleeEnv (.sref pb)) st =
      .ret (.lit (.int 0)) e s) :
    interp actDef (fuel + 6) relayOuterLoop env st =
      .ret (.lit (.int 0))
        (assocSet (assocSet env "$t17" (.v (.lit (.int 0)))) "r" (.v (.lit (.int 0)))) s := by
  cases fuel with
  | zero =>
    simp [readBlockBody, interp] at hcall
  | succ f =>
    cases f with
    | zero =>
      simp [readBlockBody, interp] at hcall
    | succ f =>
      have hctrue : evalExpr env (.lit (.bool true)) = some (.v (.lit (.bool true))) := rfl
      have hlt : decide ((0 : Int) < 0) = false := rfl
      have heq : decide ((0 : Int) = 0) = true := rfl
      have ht : decide True = true := rfl
      have hf : decide False = false := rfl
      rw [relayOuterLoop, interp_while_true actDef (f + 2 + 5) env st _ relayOuterBody hctrue]
      unfold relayOuterBody
      simp only [interp_succ_seq, interp_succ_action, interp_succ_assign, interp_succ_cond,
        interp_succ_ret, interp_succ_pass, evalExpr, lookup_assocSet_same, hb, hrb, hcall,
        funcDef_lt, funcDef_eq_int, Option.map_some, hlt, heq, ht, hf]

/-- The `w ≤ 0` inner iteration of exported `relay_raising` (temps `$t22`/`$t23`/`$t24`):
    `lost` is extended by the unwritten slice and the loop returns 2. Same hyps as
    `CalculusRelayLoop.relay_inner_lost`; not an interpreter-equivalence on alpha-renamed
    temps. -/
theorem raising_inner_lost (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody) (fuel : Nat) (env e : Env)
    (st st' st'' : St) (pb : Path) (off r w : Int) (bs ls : List Int)
    (hb : lookup env "b" = some (.sref pb))
    (hσ : lookup env "σ" = some (.sref .here))
    (hoff : lookup env "off" = some (.v (.lit (.int off))))
    (hr : lookup env "r" = some (.v (.lit (.int r))))
    (h0 : 0 ≤ off) (hor : off < r) (hrmax : r ≤ 4611686018427387903)
    (hcall : interp actDef (fuel + 24) writeBlockBody
      (calleeEnv (.rpair (.sref pb) (.v (.pair (.lit (.int off)) (.lit (.int r)))))) st =
      .ret (.lit (.int w)) e st')
    (hw : w ≤ 0)
    (hlost : getAttrAt .here st' "lost" = some (Val.ofIntList ls))
    (hls : ls.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hbytes : getAttrAt pb st' "bytes" = some (Val.ofIntList bs))
    (hbs : bs.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hrb : r ≤ (bs.length : Int))
    (hset : setAttrAt .here st' "lost"
      (Val.ofIntList (ls ++ (bs.drop off.toNat).take (r - off).toNat)) = some st'') :
    ∃ env', interp actDef (fuel + 30) raisingInnerLoop env st = .ret (.lit (.int 2)) env' st'' := by
  have hoff0 : 0 ≤ off ∧ off ≤ 4611686018427387903 := ⟨h0, by omega⟩
  have hr0 : 0 ≤ r ∧ r ≤ 4611686018427387903 := ⟨by omega, hrmax⟩
  have hslice : 0 ≤ off ∧ off ≤ r ∧ r ≤ (bs.length : Int) := ⟨h0, by omega, hrb⟩
  have hsl : ((bs.drop off.toNat).take (r - off).toNat).all
      (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true := all_take_of_all _ _ (all_drop_of_all _ _ hbs)
  generalize hW : writeBlockBody = W at hcall hwb
  have hc : evalExpr env (.fn .lt (.pair (.var "off") (.var "r"))) = some (.v (.lit (.bool true))) := by
    simp only [evalExpr, hoff, hr, funcDef_lt, hor, decide_true, Option.map_some]
  have iseq : ∀ {n : Nat} {a b : Stmt String} {e : Env} {s : St},
      interp actDef (n + 1) (.seq a b) e s =
        match interp actDef n a e s with
        | .continue e s => interp actDef n b e s
        | r => r := fun {n a b e s} => rfl
  have iact : ∀ {n : Nat} {v a : String} {e : Expr} {env : Env} {st : St},
      interp actDef (n + 1) (.action v a e) env st =
        match evalExpr env e with
        | none => .failure
        | some arg =>
          match interp actDef n (actDef a) (calleeEnv arg) st with
          | .ret res _ st => .continue (assocSet env v (.v res)) st
          | .raise x _ st => .raise x env st
          | _ => .failure := fun {n v a e env st} => rfl
  have iasg : ∀ {n : Nat} {v : String} {e : Expr} {env : Env} {st : St},
      interp actDef (n + 1) (.assign v e) env st =
        match evalExpr env e with
        | some x => .continue (assocSet env v x) st
        | none => .failure := fun {n v e env st} => rfl
  have icnd : ∀ {n : Nat} {c : Expr} {t e : Stmt String} {env : Env} {st : St},
      interp actDef (n + 1) (.cond c t e) env st =
        match evalExpr env c with
        | some (.v (.lit (.bool true))) => interp actDef n t env st
        | some (.v (.lit (.bool false))) => interp actDef n e env st
        | _ => .failure := fun {n c t e env st} => rfl
  have iget : ∀ {n : Nat} {v : String} {base : Expr} {attr : String} {env : Env} {st : St},
      interp actDef (n + 1) (.get v base attr) env st =
        match evalExpr env base with
        | some (.sref p) =>
          match getAttrAt p st attr with
          | some x => .continue (assocSet env v (.v x)) st
          | none => .failure
        | _ => .failure := fun {n v base attr env st} => rfl
  have iset : ∀ {n : Nat} {base : Expr} {attr : String} {e : Expr} {env : Env} {st : St},
      interp actDef (n + 1) (.setAttr base attr e) env st =
        match evalExpr env base, evalExpr env e with
        | some (.sref p), some (.v x) =>
          match setAttrAt p st attr x with
          | some st => .continue env st
          | none => .failure
        | _, _ => .failure := fun {n base attr e env st} => rfl
  have iret : ∀ {n : Nat} {e : Expr} {env : Env} {st : St},
      interp actDef (n + 1) (.ret e) env st =
        match evalExpr env e with
        | some x => .ret (match x with | .v x => x | .sref _ => .lit .unit | .rpair _ _ => .lit .unit) env st
        | none => .failure := fun {n e env st} => rfl
  refine ⟨?e, ?h⟩
  case h =>
  show interp actDef (fuel + 29 + 1) raisingInnerLoop env st = _
  rw [raisingInnerLoop, interp_while_true actDef (fuel + 29) env st _ raisingInnerBody hc]
  unfold raisingInnerBody
  simp only [iseq, iact, iasg, icnd, iget, iset, iret, hwb, hcall, evalExpr,
    lookup_assocSet_same, lookup_assocSet_other, hb, hσ, hoff, hr, hlost, hbytes, hset,
    funcDef_le, funcDef_range off 0 _ hoff0, funcDef_range r 0 _ hr0,
    funcDef_slice bs off r hbs hslice, funcDef_append ls _ hls hsl, hw, decide_true,
    Option.map_some, ne_eq, not_false_eq_true, String.reduceEq]
  rfl


/-- One positive-write iteration of `raisingInnerLoop` (temps `$t22`, vs `$t18` on `relay`).
    Same hyps as `CalculusBody.relay_inner_step`; kernel-checked on the actual AST, not
    by renaming. -/
theorem raising_inner_step (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody) (fuel : Nat) (env : Env)
    (st st1 st2 st3 : St) (pb : Path) (off r len cap wc : Int) (bs ws dv req : List Int)
    (hb : lookup env "b" = some (.sref pb))
    (hσ : lookup env "σ" = some (.sref .here))
    (hoff : lookup env "off" = some (.v (.lit (.int off))))
    (hr : lookup env "r" = some (.v (.lit (.int r))))
    (hlen : getAttrAt pb st "len" = some (.lit (.int len)))
    (hcap : getAttrAt pb st "cap" = some (.lit (.int cap)))
    (hbytes : getAttrAt pb st "bytes" = some (Val.ofIntList bs))
    (hbs : bs.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hbslen : (bs.length : Int) = len)
    (hws : getAttrAt .here st "writes" = some (Val.ofIntList ws))
    (hwc : getAttrAt .here st "write_calls" = some (.lit (.int wc)))
    (hdv : getAttrAt .here st "delivered" = some (Val.ofIntList dv))
    (hdvb : dv.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (h0 : 0 ≤ off) (hor : off < r) (hrl : r ≤ len) (hlc : len ≤ cap)
    (hrmax : r ≤ 4611686018427387903)
    (hwc1 : minInt ≤ wc + 1 ∧ wc + 1 ≤ maxInt)
    (hreq : req = (bs.drop off.toNat).take (r - off).toNat)
    (hq : 0 ≤ wbQ ws req)
    (hkpos : 0 < min (wbQ ws req) (req.length : Int))
    (h1 : setAttrAt .here st "writes" (Val.ofIntList ws.tail) = some st1)
    (h2 : setAttrAt .here st1 "write_calls" (.lit (.int (wc + 1))) = some st2)
    (h3 : setAttrAt .here st2 "delivered"
      (Val.ofIntList (dv ++ req.take (min (wbQ ws req) (req.length : Int)).toNat)) = some st3) :
    interp actDef (fuel + 30) raisingInnerLoop env st =
      interp actDef (fuel + 28) raisingInnerLoop
        (assocSet (assocSet (assocSet env "$t22" (.v (.lit (.int (min (wbQ ws req) (req.length : Int))))))
          "w" (.v (.lit (.int (min (wbQ ws req) (req.length : Int))))))
          "off" (.v (.lit (.int (off + min (wbQ ws req) (req.length : Int))))))
        st3 := by
  obtain ⟨e, he⟩ := write_block_body_ret actDef fuel
    (calleeEnv (.rpair (.sref pb) (.v (.pair (.lit (.int off)) (.lit (.int r))))))
    st st1 st2 st3 pb .here off r len cap wc bs ws dv req
    (by simp [calleeEnv, lookup]) (by simp [calleeEnv, lookup])
    hlen hcap hbytes hbs hbslen hws hwc hdv hdvb h0 (by omega) hrl hlc hrmax hwc1 hreq h1 h2 hq h3
  have hreqlen : (req.length : Int) ≤ r - off := by
    rw [hreq]; simp only [List.length_take, List.length_drop]; omega
  have hoff0 : 0 ≤ off ∧ off ≤ 4611686018427387903 := ⟨h0, by omega⟩
  have hr0 : 0 ≤ r ∧ r ≤ 4611686018427387903 := ⟨by omega, hrmax⟩
  have hkle : ¬ (min (wbQ ws req) (req.length : Int) ≤ 0) := by omega
  have hadd : minInt ≤ off + min (wbQ ws req) (req.length : Int) ∧
      off + min (wbQ ws req) (req.length : Int) ≤ maxInt := by
    simp only [minInt, maxInt]; omega
  generalize hW : writeBlockBody = W at he hwb
  have hc : evalExpr env (.fn .lt (.pair (.var "off") (.var "r"))) = some (.v (.lit (.bool true))) := by
    simp only [evalExpr, hoff, hr, funcDef_lt, hor, decide_true, Option.map_some]
  have hbody : interp actDef (fuel + 28) raisingInnerBody env st =
      .continue (assocSet (assocSet (assocSet env "$t22"
          (.v (.lit (.int (min (wbQ ws req) (req.length : Int))))))
          "w" (.v (.lit (.int (min (wbQ ws req) (req.length : Int))))))
          "off" (.v (.lit (.int (off + min (wbQ ws req) (req.length : Int)))))) st3 := by
    have iseq : ∀ {n : Nat} {a b : Stmt String} {e : Env} {s : St},
        interp actDef (n + 1) (.seq a b) e s =
          match interp actDef n a e s with
          | .continue e s => interp actDef n b e s
          | r => r := fun {n a b e s} => rfl
    have iact : ∀ {n : Nat} {v a : String} {e : Expr} {env : Env} {st : St},
        interp actDef (n + 1) (.action v a e) env st =
          match evalExpr env e with
          | none => .failure
          | some arg =>
            match interp actDef n (actDef a) (calleeEnv arg) st with
            | .ret res _ st => .continue (assocSet env v (.v res)) st
            | .raise x _ st => .raise x env st
            | _ => .failure := fun {n v a e env st} => rfl
    have iasg : ∀ {n : Nat} {v : String} {e : Expr} {env : Env} {st : St},
        interp actDef (n + 1) (.assign v e) env st =
          match evalExpr env e with
          | some x => .continue (assocSet env v x) st
          | none => .failure := fun {n v e env st} => rfl
    have icnd : ∀ {n : Nat} {c : Expr} {t e : Stmt String} {env : Env} {st : St},
        interp actDef (n + 1) (.cond c t e) env st =
          match evalExpr env c with
          | some (.v (.lit (.bool true))) => interp actDef n t env st
          | some (.v (.lit (.bool false))) => interp actDef n e env st
          | _ => .failure := fun {n c t e env st} => rfl
    have ipass : ∀ {n : Nat} {env : Env} {st : St},
        interp actDef (n + 1) .pass env st = .continue env st := fun {n env st} => rfl
    have mcont : ∀ {e : Env} {s : St} {P : Env → St → Res},
        (match (Res.continue e s : Res) with
         | .continue e s => P e s
         | r => r) = P e s := fun {e s P} => rfl
    have harg :
        evalExpr env (.pair (.var "b")
          (.pair (.fn (.range 0 4611686018427387903) (.var "off"))
            (.fn (.range 0 4611686018427387903) (.var "r")))) =
          some (.rpair (.sref pb) (.v (.pair (.lit (.int off)) (.lit (.int r))))) := by
      simp only [evalExpr, hb, hoff, hr, funcDef_range off 0 _ hoff0, funcDef_range r 0 _ hr0,
        Option.map_some]
    let _ := hσ
    unfold raisingInnerBody
    rw [show fuel + 28 = (fuel + 27) + 1 from rfl, iseq]
    rw [show fuel + 27 = (fuel + 26) + 1 from rfl, iseq]
    rw [show fuel + 26 = (fuel + 25) + 1 from rfl, iseq]
    rw [show fuel + 25 = (fuel + 24) + 1 from rfl, iact, harg]
    simp only [hwb, he]
    rw [show fuel + 25 = (fuel + 24) + 1 from rfl, iasg]
    simp only [evalExpr, lookup_assocSet_same]
    rw [show fuel + 26 = (fuel + 25) + 1 from rfl, iseq]
    rw [show fuel + 25 = (fuel + 24) + 1 from rfl, icnd]
    simp only [evalExpr, lookup_assocSet_same, hkle, funcDef_le, decide_false, Option.map_some]
    rw [show fuel + 24 = (fuel + 23) + 1 from rfl, ipass]
    rw [mcont]
    rw [show fuel + 25 = (fuel + 24) + 1 from rfl, iasg]
    have hoff' :
        lookup (assocSet (assocSet env "$t22"
            (.v (.lit (.int (min (wbQ ws req) (req.length : Int))))))
            "w" (.v (.lit (.int (min (wbQ ws req) (req.length : Int)))))) "off" =
          some (.v (.lit (.int off))) := by
      rw [lookup_assocSet_other (a := "w") (b := "off") (h := by decide)]
      rw [lookup_assocSet_other (a := "$t22") (b := "off") (h := by decide)]
      exact hoff
    simp only [evalExpr, lookup_assocSet_same, hoff', funcDef_add off _ hadd, Option.map_some]
    rw [show fuel + 24 + 1 + 1 + 1 = (fuel + 26) + 1 from rfl, ipass]
  show interp actDef (fuel + 29 + 1) raisingInnerLoop env st = _
  rw [raisingInnerLoop, interp_while_true actDef (fuel + 29) env st _ raisingInnerBody hc]
  show (match interp actDef (fuel + 28) raisingInnerBody env st with
    | .continue env st => interp actDef (fuel + 28) (.while (.fn .lt (.pair (.var "off") (.var "r"))) raisingInnerBody) env st
    | r => r) = _
  rw [hbody]

/-- Preservation and progress for one inner iteration of `relay_raising`. Reuses
    `CalculusRelayLoop.InnerInv` (binds `b`/`σ`/`off`/`r`, not the write temps). -/
theorem raising_inner_step_inv (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody) (fuel : Nat) (env : Env) (st : St)
    (pb : Path) (len cap : Int) (bs : List Int) (other : String → Option Val) (wcmax : Int)
    (off r : Int)
    (inv : InnerInv pb len cap bs other wcmax env st off r) (hor : off < r) :
    (∃ env' st' off', interp actDef (fuel + 30) raisingInnerLoop env st =
        interp actDef (fuel + 28) raisingInnerLoop env' st' ∧
      InnerInv pb len cap bs other wcmax env' st' off' r ∧ off < off' ∧ off' ≤ r) ∨
    (∃ env' st', interp actDef (fuel + 30) raisingInnerLoop env st = .ret (.lit (.int 2)) env' st') := by
  obtain ⟨ws, hws⟩ := inv.hws
  obtain ⟨wc, hwc, hwc0, hwcb⟩ := inv.hwc
  obtain ⟨dv, hdv, hdvb⟩ := inv.hdv
  obtain ⟨ls, hlost, hls⟩ := inv.hlost
  have hwcmax := inv.hwcmax
  have hwc1 : minInt ≤ wc + 1 ∧ wc + 1 ≤ maxInt := ⟨by omega, by omega⟩
  have hrb : r ≤ (bs.length : Int) := by have := inv.hrl; have := inv.hbslen; omega
  obtain ⟨st1, h1⟩ := setAttrAt_isSome_of_getAttrAt .here st "writes" "writes" _
    (Val.ofIntList ws.tail) hws
  obtain ⟨st2, h2⟩ := setAttrAt_isSome_of_getAttrAt .here st1 "writes" "write_calls" _
    (.lit (.int (wc + 1))) (setAttrAt_same _ _ _ _ _ h1)
  have fpb1 : ∀ a, getAttrAt pb st1 a = getAttrAt pb st a := fun a =>
    setAttrAt_frame _ _ _ _ _ h1 pb a (Or.inl inv.hpb)
  have fpb2 : ∀ a, getAttrAt pb st2 a = getAttrAt pb st a := fun a => by
    rw [setAttrAt_frame _ _ _ _ _ h2 pb a (Or.inl inv.hpb), fpb1]
  have fr1 : ∀ a, a ≠ "writes" → getAttrAt .here st1 a = getAttrAt .here st a := fun a ha =>
    setAttrAt_frame _ _ _ _ _ h1 .here a (Or.inr ha)
  have fr2 : ∀ a, a ≠ "writes" → a ≠ "write_calls" →
      getAttrAt .here st2 a = getAttrAt .here st a := fun a ha hb => by
    rw [setAttrAt_frame _ _ _ _ _ h2 .here a (Or.inr hb), fr1 a ha]
  have hreqlen : (((bs.drop off.toNat).take (r - off).toNat).length : Int) ≤ r - off := by
    simp only [List.length_take, List.length_drop]; omega
  by_cases hq : 0 ≤ wbQ ws ((bs.drop off.toNat).take (r - off).toNat)
  · obtain ⟨st3, h3⟩ := setAttrAt_isSome_of_getAttrAt .here st2 "write_calls" "delivered" _
      (Val.ofIntList (dv ++ ((bs.drop off.toNat).take (r - off).toNat).take
        (min (wbQ ws ((bs.drop off.toNat).take (r - off).toNat))
          ((((bs.drop off.toNat).take (r - off).toNat).length : Int))).toNat))
      (setAttrAt_same _ _ _ _ _ h2)
    have fpb3 : ∀ a, getAttrAt pb st3 a = getAttrAt pb st a := fun a => by
      rw [setAttrAt_frame _ _ _ _ _ h3 pb a (Or.inl inv.hpb), fpb2]
    have fr3 : ∀ a, a ≠ "writes" → a ≠ "write_calls" → a ≠ "delivered" →
        getAttrAt .here st3 a = getAttrAt .here st a := fun a ha hb hc => by
      rw [setAttrAt_frame _ _ _ _ _ h3 .here a (Or.inr hc), fr2 a ha hb]
    by_cases hk : 0 < min (wbQ ws ((bs.drop off.toNat).take (r - off).toNat))
        ((((bs.drop off.toNat).take (r - off).toNat).length : Int))
    · have hstep := raising_inner_step actDef hwb fuel env st st1 st2 st3 pb off r len cap wc bs ws
        dv _ inv.hb inv.hσ inv.hoff inv.hr inv.hlen inv.hcap inv.hbytes inv.hbs inv.hbslen hws hwc
        hdv hdvb inv.h0 hor inv.hrl inv.hlc inv.hrmax hwc1 rfl hq hk h1 h2 h3
      left
      refine ⟨_, st3, off + min (wbQ ws ((bs.drop off.toNat).take (r - off).toNat))
        ((((bs.drop off.toNat).take (r - off).toNat).length : Int)), hstep, ?_, by omega, by omega⟩
      exact {
        hb := by simp [lookup_assocSet_other, inv.hb]
        hσ := by simp [lookup_assocSet_other, inv.hσ]
        hoff := lookup_assocSet_same _ _ _
        hr := by simp [lookup_assocSet_other, inv.hr]
        hpb := inv.hpb
        hlen := by rw [fpb3]; exact inv.hlen
        hcap := by rw [fpb3]; exact inv.hcap
        hbytes := by rw [fpb3]; exact inv.hbytes
        hbs := inv.hbs
        hbslen := inv.hbslen
        hws := ⟨ws.tail, by
          rw [setAttrAt_frame _ _ _ _ _ h3 .here "writes" (Or.inr (by decide)),
            setAttrAt_frame _ _ _ _ _ h2 .here "writes" (Or.inr (by decide))]
          exact setAttrAt_same _ _ _ _ _ h1⟩
        hwc := ⟨wc + 1, by
          rw [setAttrAt_frame _ _ _ _ _ h3 .here "write_calls" (Or.inr (by decide))]
          exact setAttrAt_same _ _ _ _ _ h2, by omega, by omega⟩
        hdv := ⟨_, setAttrAt_same _ _ _ _ _ h3, by
          rw [List.all_append, hdvb, all_take_of_all _ _
            (all_take_of_all _ _ (all_drop_of_all _ _ inv.hbs))]; rfl⟩
        hwcmax := inv.hwcmax
        hother := fun a ha hb hc hd => by rw [fr3 a ha hb hc]; exact inv.hother a ha hb hc hd
        hlost := ⟨ls, by rw [fr3 "lost" (by decide) (by decide) (by decide)]; exact hlost, hls⟩
        h0 := by have := inv.h0; omega
        hor := by have := inv.hor; omega
        hrl := inv.hrl
        hlc := inv.hlc
        hrmax := inv.hrmax }
    · obtain ⟨e, he⟩ := write_block_body_ret actDef fuel
        (calleeEnv (.rpair (.sref pb) (.v (.pair (.lit (.int off)) (.lit (.int r))))))
        st st1 st2 st3 pb .here off r len cap wc bs ws dv _
        (by simp [calleeEnv, lookup]) (by simp [calleeEnv, lookup])
        inv.hlen inv.hcap inv.hbytes inv.hbs inv.hbslen hws hwc hdv hdvb inv.h0 (by omega)
        inv.hrl inv.hlc inv.hrmax hwc1 rfl h1 h2 hq h3
      obtain ⟨st4, h4⟩ := setAttrAt_isSome_of_getAttrAt .here st3 "delivered" "lost" _
        (Val.ofIntList (ls ++ (bs.drop off.toNat).take (r - off).toNat))
        (setAttrAt_same _ _ _ _ _ h3)
      right
      obtain ⟨env', hret⟩ := raising_inner_lost actDef hwb fuel env e st st3 st4 pb off r _ bs ls
        inv.hb inv.hσ inv.hoff inv.hr inv.h0 hor inv.hrmax he (by omega)
        (by rw [fr3 "lost" (by decide) (by decide) (by decide)]; exact hlost) hls
        (by rw [fpb3]; exact inv.hbytes) inv.hbs hrb h4
      exact ⟨env', st4, hret⟩
  · obtain ⟨e, he⟩ := write_block_body_neg actDef fuel
      (calleeEnv (.rpair (.sref pb) (.v (.pair (.lit (.int off)) (.lit (.int r))))))
      st st1 st2 pb .here off r len cap wc bs ws _
      (by simp [calleeEnv, lookup]) (by simp [calleeEnv, lookup])
      inv.hlen inv.hcap inv.hbytes inv.hbs inv.hbslen hws hwc inv.h0 (by omega)
      inv.hrl inv.hlc inv.hrmax hwc1 rfl h1 h2 (by omega)
    obtain ⟨st4, h4⟩ := setAttrAt_isSome_of_getAttrAt .here st2 "write_calls" "lost" _
      (Val.ofIntList (ls ++ (bs.drop off.toNat).take (r - off).toNat))
      (setAttrAt_same _ _ _ _ _ h2)
    right
    obtain ⟨env', hret⟩ := raising_inner_lost actDef hwb fuel env e st st2 st4 pb off r (-1) bs ls
      inv.hb inv.hσ inv.hoff inv.hr inv.h0 hor inv.hrmax he (by omega)
      (by rw [fr2 "lost" (by decide) (by decide)]; exact hlost) hls
      (by rw [fpb2]; exact inv.hbytes) inv.hbs hrb h4
    exact ⟨env', st4, hret⟩

theorem raising_inner_loop_run (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody) (pb : Path) (len cap : Int) (bs : List Int)
    (other : String → Option Val) (wcmax : Int)
    (r : Int) : ∀ (m fuel : Nat) (env : Env) (st : St) (off : Int),
    InnerInv pb len cap bs other wcmax env st off r → (r - off).toNat ≤ m →
    (∃ env' st', interp actDef (fuel + 2 * m + 30) raisingInnerLoop env st = .continue env' st' ∧
      InnerInv pb len cap bs other wcmax env' st' r r) ∨
    (∃ env' st', interp actDef (fuel + 2 * m + 30) raisingInnerLoop env st =
      .ret (.lit (.int 2)) env' st') := by
  intro m
  induction m with
  | zero =>
    intro fuel env st off inv hm
    have hoffr : off = r := by have := inv.hor; omega
    subst hoffr
    have hc : evalExpr env (.fn .lt (.pair (.var "off") (.var "r"))) =
        some (.v (.lit (.bool false))) := by
      simp only [evalExpr, inv.hoff, inv.hr, funcDef_lt, Int.lt_irrefl, decide_false,
        Option.map_some]
    left
    refine ⟨env, st, ?_, inv⟩
    rw [show fuel + 2 * 0 + 30 = (fuel + 29) + 1 by omega, raisingInnerLoop,
      interp_while_false actDef (fuel + 29) env st _ raisingInnerBody hc]
  | succ m ih =>
    intro fuel env st off inv hm
    by_cases hlt : off < r
    · rcases raising_inner_step_inv actDef hwb (fuel + 2 * m + 2) env st pb len cap bs other wcmax
        off r inv hlt
        with ⟨env', st', off', hstep, inv', hlt', hle'⟩ | ⟨env', st', hret⟩
      · rw [show fuel + 2 * (m + 1) + 30 = (fuel + 2 * m + 2) + 30 by omega, hstep,
          show fuel + 2 * m + 2 + 28 = fuel + 2 * m + 30 by omega]
        exact ih fuel env' st' off' inv' (by omega)
      · right
        rw [show fuel + 2 * (m + 1) + 30 = (fuel + 2 * m + 2) + 30 by omega, hret]
        exact ⟨env', st', rfl⟩
    · have hoffr : off = r := by have := inv.hor; omega
      subst hoffr
      have hc : evalExpr env (.fn .lt (.pair (.var "off") (.var "r"))) =
          some (.v (.lit (.bool false))) := by
        simp only [evalExpr, inv.hoff, inv.hr, funcDef_lt, Int.lt_irrefl, decide_false,
          Option.map_some]
      left
      refine ⟨env, st, ?_, inv⟩
      rw [show fuel + 2 * (m + 1) + 30 = (fuel + 2 * m + 31) + 1 by omega, raisingInnerLoop,
        interp_while_false actDef (fuel + 2 * m + 31) env st _ raisingInnerBody hc]

theorem raising_inner_loop_terminates (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody) (fuel : Nat) (env : Env) (st : St)
    (pb : Path) (len cap : Int) (bs : List Int) (other : String → Option Val) (wcmax : Int)
    (off r : Int) (inv : InnerInv pb len cap bs other wcmax env st off r) :
    (∃ env' st', interp actDef (fuel + 2 * (r - off).toNat + 30) raisingInnerLoop env st =
        .continue env' st' ∧ InnerInv pb len cap bs other wcmax env' st' r r) ∨
    (∃ env' st', interp actDef (fuel + 2 * (r - off).toNat + 30) raisingInnerLoop env st =
      .ret (.lit (.int 2)) env' st') :=
  raising_inner_loop_run actDef hwb pb len cap bs other wcmax r (r - off).toNat fuel env st off inv
    (Nat.le_refl _)

theorem raising_inner_loop_terminates_any_fuel (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody) (g : Nat) (env : Env) (st : St)
    (pb : Path) (len cap : Int) (bs : List Int) (other : String → Option Val) (wcmax : Int)
    (off r : Int) (inv : InnerInv pb len cap bs other wcmax env st off r)
    (hg : 2 * (r - off).toNat + 30 ≤ g) :
    (∃ env' st', interp actDef g raisingInnerLoop env st = .continue env' st' ∧
      InnerInv pb len cap bs other wcmax env' st' r r) ∨
    (∃ env' st', interp actDef g raisingInnerLoop env st = .ret (.lit (.int 2)) env' st') := by
  rcases raising_inner_loop_terminates actDef hwb 0 env st pb len cap bs other wcmax off r inv
    with ⟨env', st', hrun, inv'⟩ | ⟨env', st', hrun⟩
  · left
    refine ⟨env', st', ?_, inv'⟩
    rw [interp_fuel_mono_le actDef (0 + 2 * (r - off).toNat + 30) g raisingInnerLoop env st
      (by omega) (by rw [hrun]; exact Res.noConfusion), hrun]
  · right
    refine ⟨env', st', ?_⟩
    rw [interp_fuel_mono_le actDef (0 + 2 * (r - off).toNat + 30) g raisingInnerLoop env st
      (by omega) (by rw [hrun]; exact Res.noConfusion), hrun]


/-- One outer iteration of `raisingOuterLoop` under `OuterInv`. Positive `rbK`
    runs the proved inner loop (`$t21` read temp, not `$t17`). Outcomes:
    continue with strictly shorter input, return 0 (EOF), raise `ReadError(-1)`
    (negative schedule; `read_block` returns exactly `-1`), or return 2
    (inner write failure). -/
theorem raising_outer_step (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody) (fuel : Nat) (env : Env) (st : St)
    (pb : Path) (cap : Int) (inp : List Int) (inv : OuterInv pb cap inp env st) :
    (∃ env' st' inp', interp actDef (fuel + 2 * cap.toNat + 37) raisingOuterLoop env st =
        interp actDef (fuel + 2 * cap.toNat + 35) raisingOuterLoop env' st' ∧
      OuterInv pb cap inp' env' st' ∧ inp'.length < inp.length) ∨
    (∃ (env' : Env) (st' : St), interp actDef (fuel + 2 * cap.toNat + 37) raisingOuterLoop env st =
        .ret (.lit (.int 0)) env' st') ∨
    (∃ (env' : Env) (st' : St), interp actDef (fuel + 2 * cap.toNat + 37) raisingOuterLoop env st =
        .raise (.pair (.lit (.str "ReadError")) (.lit (.int (-1)))) env' st') ∨
    (∃ (env' : Env) (st' : St), interp actDef (fuel + 2 * cap.toNat + 37) raisingOuterLoop env st =
        .ret (.lit (.int 2)) env' st') := by
  obtain ⟨rs, hrs⟩ := inv.hrs
  obtain ⟨rc, hrc, hrc0, hrcb⟩ := inv.hrc
  obtain ⟨ws, hws⟩ := inv.hws
  obtain ⟨wc, hwc, hwc0, hwcb⟩ := inv.hwc
  obtain ⟨dv, hdv, hdvb⟩ := inv.hdv
  obtain ⟨ls, hlost, hls⟩ := inv.hlost
  have hcap0 : 0 ≤ cap := by have := inv.hcap1; omega
  have hrc1 : minInt ≤ rc + 1 ∧ rc + 1 ≤ maxInt := ⟨by omega, by omega⟩
  obtain ⟨st1, h1⟩ := setAttrAt_isSome_of_getAttrAt .here st "reads" "reads" _
    (Val.ofIntList rs.tail) hrs
  obtain ⟨st2, h2⟩ := setAttrAt_isSome_of_getAttrAt .here st1 "reads" "read_calls" _
    (.lit (.int (rc + 1))) (setAttrAt_same _ _ _ _ _ h1)
  have fpb1 : ∀ a, getAttrAt pb st1 a = getAttrAt pb st a := fun a =>
    setAttrAt_frame _ _ _ _ _ h1 pb a (Or.inl inv.hpb)
  have fpb2 : ∀ a, getAttrAt pb st2 a = getAttrAt pb st a := fun a => by
    rw [setAttrAt_frame _ _ _ _ _ h2 pb a (Or.inl inv.hpb), fpb1]
  have fr2 : ∀ a, a ≠ "reads" → a ≠ "read_calls" →
      getAttrAt .here st2 a = getAttrAt .here st a := fun a ha hb => by
    rw [setAttrAt_frame _ _ _ _ _ h2 .here a (Or.inr hb),
      setAttrAt_frame _ _ _ _ _ h1 .here a (Or.inr ha)]
  have hcall_env_ι : lookup (calleeEnv (.sref pb)) "ι" = some (.sref pb) := by
    simp [calleeEnv, lookup]
  have hcall_env_σ : lookup (calleeEnv (.sref pb)) "σ" = some (.sref .here) := by
    simp [calleeEnv, lookup]
  have hctrue : evalExpr env (.lit (.bool true)) = some (.v (.lit (.bool true))) := rfl
  by_cases hq : 0 ≤ rbQ rs cap
  · obtain ⟨st3, h3⟩ := setAttrAt_isSome_of_getAttrAt pb st2 "cap" "bytes" _
      (Val.ofIntList (inp.take (rbK rs cap inp).toNat)) (by rw [fpb2]; exact inv.hcap)
    obtain ⟨st4, h4⟩ := setAttrAt_isSome_of_getAttrAt pb st3 "bytes" "len" _
      (.lit (.int (rbK rs cap inp))) (setAttrAt_same _ _ _ _ _ h3)
    have fr4 : ∀ a, a ≠ "reads" → a ≠ "read_calls" →
        getAttrAt .here st4 a = getAttrAt .here st a := fun a ha hb => by
      rw [setAttrAt_frame _ _ _ _ _ h4 .here a (Or.inl (Ne.symm inv.hpb)),
        setAttrAt_frame _ _ _ _ _ h3 .here a (Or.inl (Ne.symm inv.hpb)), fr2 a ha hb]
    obtain ⟨st5, h5⟩ := setAttrAt_isSome_of_getAttrAt .here st4 "input" "input" _
      (Val.ofIntList (inp.drop (rbK rs cap inp).toNat))
      (by rw [fr4 "input" (by decide) (by decide)]; exact inv.hinp)
    have fr5 : ∀ a, a ≠ "reads" → a ≠ "read_calls" → a ≠ "input" →
        getAttrAt .here st5 a = getAttrAt .here st a := fun a ha hb hc => by
      rw [setAttrAt_frame _ _ _ _ _ h5 .here a (Or.inr hc), fr4 a ha hb]
    have fpb5 : ∀ a, a ≠ "bytes" → a ≠ "len" → getAttrAt pb st5 a = getAttrAt pb st a :=
      fun a ha hb => by
      rw [setAttrAt_frame _ _ _ _ _ h5 pb a (Or.inl inv.hpb),
        setAttrAt_frame _ _ _ _ _ h4 pb a (Or.inr hb),
        setAttrAt_frame _ _ _ _ _ h3 pb a (Or.inr ha), fpb2]
    obtain ⟨e, he⟩ := read_block_body_ret actDef (fuel + 2 * cap.toNat + 7) (calleeEnv (.sref pb))
      st st1 st2 st3 st4 st5 pb .here cap rc rs inp hcall_env_ι hcall_env_σ inv.hpb inv.hcap hcap0
      inv.hcapmax hrs hrc hrc1 inv.hinp inv.hinpb hq h1 h2 h3 h4 h5
    have he' : interp actDef (fuel + 2 * cap.toNat + 31) readBlockBody (calleeEnv (.sref pb)) st =
        .ret (.lit (.int (rbK rs cap inp))) e st5 := he
    have hk0 : 0 ≤ rbK rs cap inp := by unfold rbK; omega
    have hkcap : rbK rs cap inp ≤ cap := by unfold rbK; omega
    have hkinp : rbK rs cap inp ≤ (inp.length : Int) := by unfold rbK; omega
    have hkl : ((inp.take (rbK rs cap inp).toNat).length : Int) = rbK rs cap inp := by
      simp only [List.length_take]; omega
    by_cases hkz : rbK rs cap inp = 0
    · -- EOF: return 0
      refine Or.inr (Or.inl ⟨?e0, st5, ?h0⟩)
      case h0 =>
      show interp actDef (fuel + 2 * cap.toNat + 36 + 1) raisingOuterLoop env st = _
      rw [raisingOuterLoop, interp_while_true actDef _ env st _ raisingOuterBody hctrue]
      unfold raisingOuterBody
      simp only [interp_succ_seq, interp_succ_action, interp_succ_assign, interp_succ_cond,
        interp_succ_ret, interp_succ_pass, evalExpr, lookup_assocSet_same,
        inv.hb, hrb, he', funcDef_lt, funcDef_eq_int, Option.map_some,
        decide_true, decide_false, hkz, Int.lt_irrefl]
      rfl
    · have hkpos : 0 < rbK rs cap inp := by omega
      have hklt : ¬ (rbK rs cap inp < 0) := by omega
      have hbs5 : (inp.take (rbK rs cap inp).toNat).all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true :=
        all_take_of_all _ _ inv.hinpb
      have innerInv : InnerInv pb (rbK rs cap inp) cap (inp.take (rbK rs cap inp).toNat)
          (fun a => getAttrAt .here st5 a) (wc + rbK rs cap inp)
          (assocSet (assocSet (assocSet env "$t21" (.v (.lit (.int (rbK rs cap inp)))))
            "r" (.v (.lit (.int (rbK rs cap inp))))) "off" (.v (.lit (.int 0))))
          st5 0 (rbK rs cap inp) :=
        { hb := by simp [lookup_assocSet_other, inv.hb]
          hσ := by simp [lookup_assocSet_other, inv.hσ]
          hoff := lookup_assocSet_same _ _ _
          hr := by simp [lookup_assocSet_other, lookup_assocSet_same]
          hpb := inv.hpb
          hlen := by
            rw [setAttrAt_frame _ _ _ _ _ h5 pb "len" (Or.inl inv.hpb)]
            exact setAttrAt_same _ _ _ _ _ h4
          hcap := by rw [fpb5 "cap" (by decide) (by decide)]; exact inv.hcap
          hbytes := by
            rw [setAttrAt_frame _ _ _ _ _ h5 pb "bytes" (Or.inl inv.hpb),
              setAttrAt_frame _ _ _ _ _ h4 pb "bytes" (Or.inr (by decide))]
            exact setAttrAt_same _ _ _ _ _ h3
          hbs := hbs5
          hbslen := hkl
          hws := ⟨ws, by rw [fr5 "writes" (by decide) (by decide) (by decide)]; exact hws⟩
          hwc := ⟨wc, by rw [fr5 "write_calls" (by decide) (by decide) (by decide)]; exact hwc,
            hwc0, by omega⟩
          hwcmax := by omega
          hother := fun a _ _ _ _ => rfl
          hdv := ⟨dv, by rw [fr5 "delivered" (by decide) (by decide) (by decide)]; exact hdv, hdvb⟩
          hlost := ⟨ls, by rw [fr5 "lost" (by decide) (by decide) (by decide)]; exact hlost, hls⟩
          h0 := Int.le_refl 0
          hor := hk0
          hrl := Int.le_refl _
          hlc := hkcap
          hrmax := by have := inv.hcapmax; omega }
      rcases raising_inner_loop_terminates_any_fuel actDef hwb (fuel + 2 * cap.toNat + 30) _ st5 pb
          (rbK rs cap inp) cap (inp.take (rbK rs cap inp).toNat) (fun a => getAttrAt .here st5 a)
          (wc + rbK rs cap inp) 0 (rbK rs cap inp) innerInv (by omega)
        with ⟨e2, s2, hrun, inv2⟩ | ⟨e2, s2, hrun⟩
      · left
        refine ⟨e2, s2, inp.drop (rbK rs cap inp).toNat, ?_, ?_, ?_⟩
        · show interp actDef (fuel + 2 * cap.toNat + 36 + 1) raisingOuterLoop env st = _
          rw [raisingOuterLoop, interp_while_true actDef _ env st _ raisingOuterBody hctrue]
          unfold raisingOuterBody
          simp only [interp_succ_seq, interp_succ_action, interp_succ_assign, interp_succ_cond,
            interp_succ_pass, evalExpr, lookup_assocSet_same,
            inv.hb, hrb, he', funcDef_lt, funcDef_eq_int, Option.map_some,
            decide_false, hklt, hkz, hrun]
        · obtain ⟨wc2, hwc2, hwc20, hwc2b⟩ := inv2.hwc
          exact {
            hb := inv2.hb
            hσ := inv2.hσ
            hpb := inv.hpb
            hcap := inv2.hcap
            hcap1 := inv.hcap1
            hcapmax := inv.hcapmax
            hrs := ⟨rs.tail, by
              rw [inv2.hother "reads" (by decide) (by decide) (by decide) (by decide)]
              show getAttrAt .here st5 "reads" = _
              rw [setAttrAt_frame _ _ _ _ _ h5 .here "reads" (Or.inr (by decide)),
                setAttrAt_frame _ _ _ _ _ h4 .here "reads" (Or.inl (Ne.symm inv.hpb)),
                setAttrAt_frame _ _ _ _ _ h3 .here "reads" (Or.inl (Ne.symm inv.hpb)),
                setAttrAt_frame _ _ _ _ _ h2 .here "reads" (Or.inr (by decide))]
              exact setAttrAt_same _ _ _ _ _ h1⟩
            hrc := ⟨rc + 1, by
              rw [inv2.hother "read_calls" (by decide) (by decide) (by decide) (by decide)]
              show getAttrAt .here st5 "read_calls" = _
              rw [setAttrAt_frame _ _ _ _ _ h5 .here "read_calls" (Or.inr (by decide)),
                setAttrAt_frame _ _ _ _ _ h4 .here "read_calls" (Or.inl (Ne.symm inv.hpb)),
                setAttrAt_frame _ _ _ _ _ h3 .here "read_calls" (Or.inl (Ne.symm inv.hpb))]
              exact setAttrAt_same _ _ _ _ _ h2, by omega, by
              simp only [List.length_drop]; omega⟩
            hinp := by
              rw [inv2.hother "input" (by decide) (by decide) (by decide) (by decide)]
              exact setAttrAt_same _ _ _ _ _ h5
            hinpb := all_drop_of_all _ _ inv.hinpb
            hws := inv2.hws
            hwc := ⟨wc2, hwc2, hwc20, by simp only [List.length_drop]; omega⟩
            hdv := inv2.hdv
            hlost := inv2.hlost }
        · simp only [List.length_drop]; omega
      · refine Or.inr (Or.inr (Or.inr ⟨e2, s2, ?_⟩))
        show interp actDef (fuel + 2 * cap.toNat + 36 + 1) raisingOuterLoop env st = _
        rw [raisingOuterLoop, interp_while_true actDef _ env st _ raisingOuterBody hctrue]
        unfold raisingOuterBody
        simp only [interp_succ_seq, interp_succ_action, interp_succ_assign, interp_succ_cond,
          interp_succ_pass, evalExpr, lookup_assocSet_same,
          inv.hb, hrb, he', funcDef_lt, funcDef_eq_int, Option.map_some,
          decide_false, hklt, hkz, hrun]
  · obtain ⟨e, he⟩ := read_block_body_neg actDef (fuel + 2 * cap.toNat + 7) (calleeEnv (.sref pb))
      st st1 st2 pb .here cap rc rs hcall_env_ι hcall_env_σ inv.hcap hrs hrc hrc1 (by omega) h1 h2
    have he' : interp actDef (fuel + 2 * cap.toNat + 31) readBlockBody (calleeEnv (.sref pb)) st =
        .ret (.lit (.int (-1))) e st2 := he
    have hneg : (-1 : Int) < 0 := by decide
    refine Or.inr (Or.inr (Or.inl ⟨?e1, st2, ?h1⟩))
    case h1 =>
    show interp actDef (fuel + 2 * cap.toNat + 36 + 1) raisingOuterLoop env st = _
    rw [raisingOuterLoop, interp_while_true actDef _ env st _ raisingOuterBody hctrue]
    unfold raisingOuterBody
    simp only [interp_succ_seq, interp_succ_action, interp_succ_assign, interp_succ_cond,
      interp_succ_raise, evalExpr, lookup_assocSet_same,
      inv.hb, hrb, he', funcDef_lt, Option.map_some, hneg, decide_true]
    rfl

/-- Input-bounded run of `raisingOuterLoop`: with `m ≥ |input|`, the loop
    returns 0, raises `ReadError(-1)`, or returns 2. -/
theorem raising_outer_loop_run (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody) (pb : Path) (cap : Int) :
    ∀ (m fuel : Nat) (env : Env) (st : St) (inp : List Int), OuterInv pb cap inp env st →
      inp.length ≤ m →
      (∃ (env' : Env) (st' : St),
          interp actDef (fuel + 2 * m + 2 * cap.toNat + 37) raisingOuterLoop env st =
            .ret (.lit (.int 0)) env' st') ∨
      (∃ (env' : Env) (st' : St),
          interp actDef (fuel + 2 * m + 2 * cap.toNat + 37) raisingOuterLoop env st =
            .raise (.pair (.lit (.str "ReadError")) (.lit (.int (-1)))) env' st') ∨
      (∃ (env' : Env) (st' : St),
          interp actDef (fuel + 2 * m + 2 * cap.toNat + 37) raisingOuterLoop env st =
            .ret (.lit (.int 2)) env' st') := by
  intro m
  induction m with
  | zero =>
    intro fuel env st inp inv hm
    rcases raising_outer_step actDef hwb hrb (fuel + 2 * 0) env st pb cap inp inv
      with ⟨_, _, inp', _, _, hlt⟩ | h0 | hneg | h2
    · omega
    · exact Or.inl h0
    · exact Or.inr (Or.inl hneg)
    · exact Or.inr (Or.inr h2)
  | succ m ih =>
    intro fuel env st inp inv hm
    rcases raising_outer_step actDef hwb hrb (fuel + 2 * m + 2) env st pb cap inp inv
      with ⟨env', st', inp', hstep, inv', hlt⟩ | h0 | hneg | h2
    · rw [show fuel + 2 * (m + 1) + 2 * cap.toNat + 37 = (fuel + 2 * m + 2) + 2 * cap.toNat + 37
        by omega, hstep, show fuel + 2 * m + 2 + 2 * cap.toNat + 35 = fuel + 2 * m + 2 * cap.toNat + 37
        by omega]
      exact ih fuel env' st' inp' inv' (by omega)
    · rw [show fuel + 2 * (m + 1) + 2 * cap.toNat + 37 = (fuel + 2 * m + 2) + 2 * cap.toNat + 37
        by omega]
      exact Or.inl h0
    · rw [show fuel + 2 * (m + 1) + 2 * cap.toNat + 37 = (fuel + 2 * m + 2) + 2 * cap.toNat + 37
        by omega]
      exact Or.inr (Or.inl hneg)
    · rw [show fuel + 2 * (m + 1) + 2 * cap.toNat + 37 = (fuel + 2 * m + 2) + 2 * cap.toNat + 37
        by omega]
      exact Or.inr (Or.inr h2)

theorem raising_outer_loop_terminates (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody) (fuel : Nat) (env : Env) (st : St)
    (pb : Path) (cap : Int) (inp : List Int) (inv : OuterInv pb cap inp env st) :
    (∃ (env' : Env) (st' : St),
        interp actDef (fuel + 2 * inp.length + 2 * cap.toNat + 37) raisingOuterLoop env st =
          .ret (.lit (.int 0)) env' st') ∨
    (∃ (env' : Env) (st' : St),
        interp actDef (fuel + 2 * inp.length + 2 * cap.toNat + 37) raisingOuterLoop env st =
          .raise (.pair (.lit (.str "ReadError")) (.lit (.int (-1)))) env' st') ∨
    (∃ (env' : Env) (st' : St),
        interp actDef (fuel + 2 * inp.length + 2 * cap.toNat + 37) raisingOuterLoop env st =
          .ret (.lit (.int 2)) env' st') :=
  raising_outer_loop_run actDef hwb hrb pb cap inp.length fuel env st inp inv (Nat.le_refl _)

set_option maxHeartbeats 1000000

/-- Same six-statement prologue as `relay`; `relayRaisingBody_eq` is the export identity. -/
theorem raising_prologue (actDef : String → Stmt String) (n : Nat) (st : St) :
    interp actDef (n + 7) relayRaisingBody (calleeEnv (.v (.lit .unit))) st =
      interp actDef (n + 1) raisingOuterLoop relayPrologueEnv (relayPrologueState st) := by
  rw [relayRaisingBody_eq]
  simp only [interp_succ_seq, interp_succ_removeElem, interp_succ_addElem, interp_succ_assign,
    interp_succ_setAttr, evalExpr, calleeEnv, lookup, lookup_assocSet_same,
    removeElemAt, addElemAt, setAttrAt, Path.snoc, St.mk_attrs, St.mk_elems, St.empty,
    lookup_assocRemove_same, assocSet_assocSet_same, funcDef, Val.ofIntList, Option.map_some,
    String.reduceEq, ↓reduceIte, relayPrologueEnv, relayPrologueState,
    relayBlockInit, blockPath, assocSet]


/-- `OuterInv` on the prologue post-state (cap 32, `blockPath`). -/
theorem raising_outerInv_prologue (st : St)
    (inp rs ws dv ls : List Int) (rc wc : Int)
    (hinp : lookup st.attrs "input" = some (Val.ofIntList inp))
    (hinpb : inp.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hrs : lookup st.attrs "reads" = some (Val.ofIntList rs))
    (hrc : lookup st.attrs "read_calls" = some (.lit (.int rc)))
    (hrc0 : minInt ≤ rc) (hrcb : rc + ((inp.length : Int) + 1) ≤ maxInt)
    (hws : lookup st.attrs "writes" = some (Val.ofIntList ws))
    (hwc : lookup st.attrs "write_calls" = some (.lit (.int wc)))
    (hwc0 : minInt ≤ wc) (hwcb : wc + (inp.length : Int) ≤ maxInt)
    (hdv : lookup st.attrs "delivered" = some (Val.ofIntList dv))
    (hdvb : dv.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hls : lookup st.attrs "lost" = some (Val.ofIntList ls))
    (hlsb : ls.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true) :
    OuterInv blockPath 32 inp relayPrologueEnv (relayPrologueState st) :=
  { hb := lookup_assocSet_same _ _ _
    hσ := by simp [relayPrologueEnv, calleeEnv, lookup_assocSet_other, lookup]
    hpb := by decide
    hcap := by
      simp [blockPath, relayPrologueState, relayBlockInit, getAttrAt, lookup_assocSet_same, lookup]
    hcap1 := by decide
    hcapmax := by decide
    hrs := ⟨rs, by simp [relayPrologueState, getAttrAt]; exact hrs⟩
    hrc := ⟨rc, by simp [relayPrologueState, getAttrAt]; exact hrc, hrc0, hrcb⟩
    hinp := by simp [relayPrologueState, getAttrAt]; exact hinp
    hinpb := hinpb
    hws := ⟨ws, by simp [relayPrologueState, getAttrAt]; exact hws⟩
    hwc := ⟨wc, by simp [relayPrologueState, getAttrAt]; exact hwc, hwc0, hwcb⟩
    hdv := ⟨dv, by simp [relayPrologueState, getAttrAt]; exact hdv, hdvb⟩
    hlost := ⟨ls, by simp [relayPrologueState, getAttrAt]; exact hls, hlsb⟩ }

/-- `runEntry "relay_raising"`: termination/result-shape only
    (continue rc=0 | raise ReadError(-1) at `initEnv` | continue rc=2). -/
theorem raising_runEntry (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody)
    (hraising : actDef "relay_raising" = relayRaisingBody) (fuel : Nat) (st : St)
    (inp rs ws dv ls : List Int) (rc wc : Int)
    (hinp : lookup st.attrs "input" = some (Val.ofIntList inp))
    (hinpb : inp.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hrs : lookup st.attrs "reads" = some (Val.ofIntList rs))
    (hrc : lookup st.attrs "read_calls" = some (.lit (.int rc)))
    (hrc0 : minInt ≤ rc) (hrcb : rc + ((inp.length : Int) + 1) ≤ maxInt)
    (hws : lookup st.attrs "writes" = some (Val.ofIntList ws))
    (hwc : lookup st.attrs "write_calls" = some (.lit (.int wc)))
    (hwc0 : minInt ≤ wc) (hwcb : wc + (inp.length : Int) ≤ maxInt)
    (hdv : lookup st.attrs "delivered" = some (Val.ofIntList dv))
    (hdvb : dv.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hls : lookup st.attrs "lost" = some (Val.ofIntList ls))
    (hlsb : ls.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true) :
    (∃ st', runEntry actDef (fuel + 2 * inp.length + 108) "relay_raising" st =
        .continue (assocSet initEnv "rc" (.v (.lit (.int 0)))) st') ∨
    (∃ st', runEntry actDef (fuel + 2 * inp.length + 108) "relay_raising" st =
        .raise (.pair (.lit (.str "ReadError")) (.lit (.int (-1)))) initEnv st') ∨
    (∃ st', runEntry actDef (fuel + 2 * inp.length + 108) "relay_raising" st =
        .continue (assocSet initEnv "rc" (.v (.lit (.int 2)))) st') := by
  have outerInv := raising_outerInv_prologue st inp rs ws dv ls rc wc
    hinp hinpb hrs hrc hrc0 hrcb hws hwc hwc0 hwcb hdv hdvb hls hlsb
  have hstep : interp actDef (fuel + 2 * inp.length + 107) relayRaisingBody
      (calleeEnv (.v (.lit .unit))) st =
      interp actDef (fuel + 2 * inp.length + 101) raisingOuterLoop relayPrologueEnv
        (relayPrologueState st) := by
    have h := raising_prologue actDef (fuel + 2 * inp.length + 100) st
    rw [show fuel + 2 * inp.length + 100 + 7 = fuel + 2 * inp.length + 107 by omega,
      show fuel + 2 * inp.length + 100 + 1 = fuel + 2 * inp.length + 101 by omega] at h
    exact h
  have hentry : runEntry actDef (fuel + 2 * inp.length + 108) "relay_raising" st =
      match interp actDef (fuel + 2 * inp.length + 107) relayRaisingBody
          (calleeEnv (.v (.lit .unit))) st with
      | .ret res _ st' => .continue (assocSet initEnv "rc" (.v res)) st'
      | .raise x _ st' => .raise x initEnv st'
      | _ => .failure := by
    unfold runEntry
    rw [show fuel + 2 * inp.length + 108 = (fuel + 2 * inp.length + 107) + 1 by omega,
      interp_succ_action]
    simp only [evalExpr, hraising]
    rfl
  rcases raising_outer_loop_terminates actDef hwb hrb fuel relayPrologueEnv
      (relayPrologueState st) blockPath 32 inp outerInv with h0 | hneg | h2
  · obtain ⟨env', st', hrun⟩ := h0
    have hrun' : interp actDef (fuel + 2 * inp.length + 101) raisingOuterLoop relayPrologueEnv
        (relayPrologueState st) = .ret (.lit (.int 0)) env' st' := by
      rw [show (32 : Int).toNat = 32 from rfl,
        show fuel + 2 * inp.length + 2 * 32 + 37 = fuel + 2 * inp.length + 101 by omega] at hrun
      exact hrun
    refine Or.inl ⟨st', ?_⟩
    rw [hentry, hstep, hrun']
  · obtain ⟨env', st', hrun⟩ := hneg
    have hrun' : interp actDef (fuel + 2 * inp.length + 101) raisingOuterLoop relayPrologueEnv
        (relayPrologueState st) =
        .raise (.pair (.lit (.str "ReadError")) (.lit (.int (-1)))) env' st' := by
      rw [show (32 : Int).toNat = 32 from rfl,
        show fuel + 2 * inp.length + 2 * 32 + 37 = fuel + 2 * inp.length + 101 by omega] at hrun
      exact hrun
    refine Or.inr (Or.inl ⟨st', ?_⟩)
    rw [hentry, hstep, hrun']
  · obtain ⟨env', st', hrun⟩ := h2
    have hrun' : interp actDef (fuel + 2 * inp.length + 101) raisingOuterLoop relayPrologueEnv
        (relayPrologueState st) = .ret (.lit (.int 2)) env' st' := by
      rw [show (32 : Int).toNat = 32 from rfl,
        show fuel + 2 * inp.length + 2 * 32 + 37 = fuel + 2 * inp.length + 101 by omega] at hrun
      exact hrun
    refine Or.inr (Or.inr ⟨st', ?_⟩)
    rw [hentry, hstep, hrun']

theorem raising_body_shape (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody)
    (hraising : actDef "relay_raising" = relayRaisingBody) (fuel : Nat) (st : St)
    (inp rs ws dv ls : List Int) (rc wc : Int)
    (hinp : lookup st.attrs "input" = some (Val.ofIntList inp))
    (hinpb : inp.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hrs : lookup st.attrs "reads" = some (Val.ofIntList rs))
    (hrc : lookup st.attrs "read_calls" = some (.lit (.int rc)))
    (hrc0 : minInt ≤ rc) (hrcb : rc + ((inp.length : Int) + 1) ≤ maxInt)
    (hws : lookup st.attrs "writes" = some (Val.ofIntList ws))
    (hwc : lookup st.attrs "write_calls" = some (.lit (.int wc)))
    (hwc0 : minInt ≤ wc) (hwcb : wc + (inp.length : Int) ≤ maxInt)
    (hdv : lookup st.attrs "delivered" = some (Val.ofIntList dv))
    (hdvb : dv.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hls : lookup st.attrs "lost" = some (Val.ofIntList ls))
    (hlsb : ls.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true) :
    (∃ e st', interp actDef (fuel + 2 * inp.length + 107) (actDef "relay_raising")
        (calleeEnv (.v (.lit .unit))) st = .ret (.lit (.int 0)) e st') ∨
    (∃ e st', interp actDef (fuel + 2 * inp.length + 107) (actDef "relay_raising")
        (calleeEnv (.v (.lit .unit))) st =
        .raise (.pair (.lit (.str "ReadError")) (.lit (.int (-1)))) e st') ∨
    (∃ e st', interp actDef (fuel + 2 * inp.length + 107) (actDef "relay_raising")
        (calleeEnv (.v (.lit .unit))) st = .ret (.lit (.int 2)) e st') := by
  have outerInv := raising_outerInv_prologue st inp rs ws dv ls rc wc
    hinp hinpb hrs hrc hrc0 hrcb hws hwc hwc0 hwcb hdv hdvb hls hlsb
  have hstep : interp actDef (fuel + 2 * inp.length + 107) relayRaisingBody
      (calleeEnv (.v (.lit .unit))) st =
      interp actDef (fuel + 2 * inp.length + 101) raisingOuterLoop relayPrologueEnv
        (relayPrologueState st) := by
    have h := raising_prologue actDef (fuel + 2 * inp.length + 100) st
    rw [show fuel + 2 * inp.length + 100 + 7 = fuel + 2 * inp.length + 107 by omega,
      show fuel + 2 * inp.length + 100 + 1 = fuel + 2 * inp.length + 101 by omega] at h
    exact h
  rw [hraising]
  rcases raising_outer_loop_terminates actDef hwb hrb fuel relayPrologueEnv
      (relayPrologueState st) blockPath 32 inp outerInv with h0 | hneg | h2
  · obtain ⟨e, s, hrun⟩ := h0
    refine Or.inl ⟨e, s, ?_⟩
    rw [hstep]
    rw [show (32 : Int).toNat = 32 from rfl,
      show fuel + 2 * inp.length + 2 * 32 + 37 = fuel + 2 * inp.length + 101 by omega] at hrun
    exact hrun
  · obtain ⟨e, s, hrun⟩ := hneg
    refine Or.inr (Or.inl ⟨e, s, ?_⟩)
    rw [hstep]
    rw [show (32 : Int).toNat = 32 from rfl,
      show fuel + 2 * inp.length + 2 * 32 + 37 = fuel + 2 * inp.length + 101 by omega] at hrun
    exact hrun
  · obtain ⟨e, s, hrun⟩ := h2
    refine Or.inr (Or.inr ⟨e, s, ?_⟩)
    rw [hstep]
    rw [show (32 : Int).toNat = 32 from rfl,
      show fuel + 2 * inp.length + 2 * 32 + 37 = fuel + 2 * inp.length + 101 by omega] at hrun
    exact hrun

open CalculusTryCatch

/-- `relay_caught` composed with proved callee shape (no opaque assumed `hcall`).
    Result-shape only: ret 0 | ret 1 (caught ReadError(-1)) | ret 2. -/
theorem raising_caught_shape (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody)
    (hraising : actDef "relay_raising" = relayRaisingBody) (fuel : Nat) (env : Env) (st : St)
    (inp rs ws dv ls : List Int) (rc wc : Int)
    (hinp : lookup st.attrs "input" = some (Val.ofIntList inp))
    (hinpb : inp.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hrs : lookup st.attrs "reads" = some (Val.ofIntList rs))
    (hrc : lookup st.attrs "read_calls" = some (.lit (.int rc)))
    (hrc0 : minInt ≤ rc) (hrcb : rc + ((inp.length : Int) + 1) ≤ maxInt)
    (hws : lookup st.attrs "writes" = some (Val.ofIntList ws))
    (hwc : lookup st.attrs "write_calls" = some (.lit (.int wc)))
    (hwc0 : minInt ≤ wc) (hwcb : wc + (inp.length : Int) ≤ maxInt)
    (hdv : lookup st.attrs "delivered" = some (Val.ofIntList dv))
    (hdvb : dv.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hls : lookup st.attrs "lost" = some (Val.ofIntList ls))
    (hlsb : ls.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true) :
    (∃ e st', interp actDef (fuel + 2 * inp.length + 111) relayCaughtBody env st =
        .ret (.lit (.int 0)) e st') ∨
    (∃ e st', interp actDef (fuel + 2 * inp.length + 111) relayCaughtBody env st =
        .ret (.lit (.int 1)) e st') ∨
    (∃ e st', interp actDef (fuel + 2 * inp.length + 111) relayCaughtBody env st =
        .ret (.lit (.int 2)) e st') := by
  rcases raising_body_shape actDef hwb hrb hraising fuel st inp rs ws dv ls rc wc
      hinp hinpb hrs hrc hrc0 hrcb hws hwc hwc0 hwcb hdv hdvb hls hlsb with h0 | hneg | h2
  · obtain ⟨e, s, hcall⟩ := h0
    have h := relay_caught_of_ret actDef (fuel + 2 * inp.length + 107) env e st s
      (.lit (.int 0)) hcall
    exact Or.inl ⟨_, s, by rw [show fuel + 2 * inp.length + 111 = (fuel + 2 * inp.length + 107) + 4 by omega]; exact h⟩
  · obtain ⟨e, s, hcall⟩ := hneg
    have h := relay_caught_of_readError actDef (fuel + 2 * inp.length + 107) env e st s
      (.lit (.int (-1))) hcall
    exact Or.inr (Or.inl ⟨_, s, by rw [show fuel + 2 * inp.length + 111 = (fuel + 2 * inp.length + 107) + 4 by omega]; exact h⟩)
  · obtain ⟨e, s, hcall⟩ := h2
    have h := relay_caught_of_ret actDef (fuel + 2 * inp.length + 107) env e st s
      (.lit (.int 2)) hcall
    exact Or.inr (Or.inr ⟨_, s, by rw [show fuel + 2 * inp.length + 111 = (fuel + 2 * inp.length + 107) + 4 by omega]; exact h⟩)

theorem raising_caught_runEntry (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody)
    (hraising : actDef "relay_raising" = relayRaisingBody)
    (hcaught : actDef "relay_caught" = relayCaughtBody) (fuel : Nat) (st : St)
    (inp rs ws dv ls : List Int) (rc wc : Int)
    (hinp : lookup st.attrs "input" = some (Val.ofIntList inp))
    (hinpb : inp.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hrs : lookup st.attrs "reads" = some (Val.ofIntList rs))
    (hrc : lookup st.attrs "read_calls" = some (.lit (.int rc)))
    (hrc0 : minInt ≤ rc) (hrcb : rc + ((inp.length : Int) + 1) ≤ maxInt)
    (hws : lookup st.attrs "writes" = some (Val.ofIntList ws))
    (hwc : lookup st.attrs "write_calls" = some (.lit (.int wc)))
    (hwc0 : minInt ≤ wc) (hwcb : wc + (inp.length : Int) ≤ maxInt)
    (hdv : lookup st.attrs "delivered" = some (Val.ofIntList dv))
    (hdvb : dv.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hls : lookup st.attrs "lost" = some (Val.ofIntList ls))
    (hlsb : ls.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true) :
    (∃ st', runEntry actDef (fuel + 2 * inp.length + 112) "relay_caught" st =
        .continue (assocSet initEnv "rc" (.v (.lit (.int 0)))) st') ∨
    (∃ st', runEntry actDef (fuel + 2 * inp.length + 112) "relay_caught" st =
        .continue (assocSet initEnv "rc" (.v (.lit (.int 1)))) st') ∨
    (∃ st', runEntry actDef (fuel + 2 * inp.length + 112) "relay_caught" st =
        .continue (assocSet initEnv "rc" (.v (.lit (.int 2)))) st') := by
  have hwrap : runEntry actDef (fuel + 2 * inp.length + 112) "relay_caught" st =
      match interp actDef (fuel + 2 * inp.length + 111) relayCaughtBody
          (calleeEnv (.v (.lit .unit))) st with
      | .ret res _ st' => .continue (assocSet initEnv "rc" (.v res)) st'
      | .raise x _ st' => .raise x initEnv st'
      | _ => .failure := by
    unfold runEntry
    rw [show fuel + 2 * inp.length + 112 = (fuel + 2 * inp.length + 111) + 1 by omega,
      interp_succ_action]
    simp only [evalExpr, hcaught]
    rfl
  rcases raising_caught_shape actDef hwb hrb hraising fuel (calleeEnv (.v (.lit .unit))) st
      inp rs ws dv ls rc wc hinp hinpb hrs hrc hrc0 hrcb hws hwc hwc0 hwcb hdv hdvb hls hlsb
    with h0 | h1 | h2
  · obtain ⟨e, s, h⟩ := h0
    refine Or.inl ⟨s, ?_⟩
    rw [hwrap, h]
  · obtain ⟨e, s, h⟩ := h1
    refine Or.inr (Or.inl ⟨s, ?_⟩)
    rw [hwrap, h]
  · obtain ⟨e, s, h⟩ := h2
    refine Or.inr (Or.inr ⟨s, ?_⟩)
    rw [hwrap, h]


def raisingWitnessState (input reads writes : List Int) : St :=
  .mk [("input", Val.ofIntList input), ("delivered", Val.ofIntList []),
       ("lost", Val.ofIntList []), ("reads", Val.ofIntList reads),
       ("writes", Val.ofIntList writes), ("read_calls", .lit (.int 0)),
       ("write_calls", .lit (.int 0))] []

/-- `reads = [-1]`, empty input: catch returns 1 from proved callee `ReadError(-1)`. -/
theorem raising_caught_readError_one (actDef : String → Stmt String)
    (_hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody)
    (hraising : actDef "relay_raising" = relayRaisingBody) (fuel : Nat) (env : Env) :
    ∃ e st', interp actDef (fuel + 2 * (32 : Int).toNat + 47) relayCaughtBody env
        (raisingWitnessState [] [-1] []) = .ret (.lit (.int 1)) e st' := by
  let st0 := raisingWitnessState [] [-1] []
  let stP := relayPrologueState st0
  have hinp : lookup st0.attrs "input" = some (Val.ofIntList []) := rfl
  have hrsA : lookup st0.attrs "reads" = some (Val.ofIntList [-1]) := rfl
  have hws : lookup st0.attrs "writes" = some (Val.ofIntList []) := rfl
  have hrcA : lookup st0.attrs "read_calls" = some (.lit (.int 0)) := rfl
  have hwc : lookup st0.attrs "write_calls" = some (.lit (.int 0)) := rfl
  have hdv : lookup st0.attrs "delivered" = some (Val.ofIntList []) := rfl
  have hls : lookup st0.attrs "lost" = some (Val.ofIntList []) := rfl
  have hinpb : ([] : List Int).all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true := rfl
  have hdvb : ([] : List Int).all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true := rfl
  have hlsb : ([] : List Int).all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true := rfl
  have hrc0 : minInt ≤ (0 : Int) := by decide
  have hrcb : (0 : Int) + ((([] : List Int).length : Int) + 1) ≤ maxInt := by decide
  have hwc0 : minInt ≤ (0 : Int) := by decide
  have hwcb : (0 : Int) + (([] : List Int).length : Int) ≤ maxInt := by decide
  have outerInv := raising_outerInv_prologue st0 [] [-1] [] [] [] 0 0
    hinp hinpb hrsA hrcA hrc0 hrcb hws hwc hwc0 hwcb hdv hdvb hls hlsb
  have hrs : getAttrAt .here stP "reads" = some (Val.ofIntList [-1]) := by
    simp [stP, relayPrologueState, getAttrAt]; exact hrsA
  have hrc : getAttrAt .here stP "read_calls" = some (.lit (.int 0)) := by
    simp [stP, relayPrologueState, getAttrAt]; exact hrcA
  have hcap : getAttrAt blockPath stP "cap" = some (.lit (.int 32)) := by
    simp [stP, blockPath, relayPrologueState, relayBlockInit, getAttrAt, lookup_assocSet_same, lookup]
  have hrc1 : minInt ≤ (0 : Int) + 1 ∧ (0 : Int) + 1 ≤ maxInt := by decide
  have hq : rbQ [-1] (32 : Int) < 0 := by decide
  obtain ⟨st1, h1⟩ := setAttrAt_isSome_of_getAttrAt .here stP "reads" "reads" _
    (Val.ofIntList ([-1] : List Int).tail) hrs
  obtain ⟨st2, h2⟩ := setAttrAt_isSome_of_getAttrAt .here st1 "reads" "read_calls" _
    (.lit (.int (0 + 1))) (setAttrAt_same _ _ _ _ _ h1)
  have hι : lookup (calleeEnv (.sref blockPath)) "ι" = some (.sref blockPath) := by
    simp [calleeEnv, lookup]
  have hσ : lookup (calleeEnv (.sref blockPath)) "σ" = some (.sref .here) := by
    simp [calleeEnv, lookup]
  obtain ⟨eR, heR⟩ := read_block_body_neg actDef (fuel + 2 * (32 : Int).toNat + 7)
    (calleeEnv (.sref blockPath)) stP st1 st2 blockPath .here 32 0 [-1]
    hι hσ hcap hrs hrc hrc1 hq h1 h2
  have he' : interp actDef (fuel + 2 * (32 : Int).toNat + 31) readBlockBody
      (calleeEnv (.sref blockPath)) stP = .ret (.lit (.int (-1))) eR st2 := heR
  have hloop := raising_outer_of_neg_read_payload_neg1 actDef
    (fuel + 2 * (32 : Int).toNat + 31) relayPrologueEnv eR stP st2 blockPath
    outerInv.hb hrb he'
  have hloop' : interp actDef (fuel + 2 * (32 : Int).toNat + 37) raisingOuterLoop
      relayPrologueEnv stP =
      .raise (.pair (.lit (.str "ReadError")) (.lit (.int (-1))))
        (assocSet (assocSet relayPrologueEnv "$t21" (.v (.lit (.int (-1)))))
          "r" (.v (.lit (.int (-1))))) st2 := by
    rw [show fuel + 2 * (32 : Int).toNat + 37 = fuel + 2 * (32 : Int).toNat + 31 + 6 by omega]
    exact hloop
  have hstep : interp actDef (fuel + 2 * (32 : Int).toNat + 43) relayRaisingBody
      (calleeEnv (.v (.lit .unit))) st0 =
      interp actDef (fuel + 2 * (32 : Int).toNat + 37) raisingOuterLoop
        relayPrologueEnv stP := by
    have h := raising_prologue actDef (fuel + 2 * (32 : Int).toNat + 36) st0
    rw [show fuel + 2 * (32 : Int).toNat + 36 + 7 = fuel + 2 * (32 : Int).toNat + 43 by omega,
      show fuel + 2 * (32 : Int).toNat + 36 + 1 = fuel + 2 * (32 : Int).toNat + 37 by omega] at h
    exact h
  have hcall : interp actDef (fuel + 2 * (32 : Int).toNat + 43) (actDef "relay_raising")
      (calleeEnv (.v (.lit .unit))) st0 =
      .raise (.pair (.lit (.str "ReadError")) (.lit (.int (-1))))
        (assocSet (assocSet relayPrologueEnv "$t21" (.v (.lit (.int (-1)))))
          "r" (.v (.lit (.int (-1))))) st2 := by
    rw [hraising, hstep, hloop']
  have hc := relay_caught_of_readError actDef (fuel + 2 * (32 : Int).toNat + 43) env
    (assocSet (assocSet relayPrologueEnv "$t21" (.v (.lit (.int (-1)))))
      "r" (.v (.lit (.int (-1))))) st0 st2 (.lit (.int (-1))) hcall
  exact ⟨_, st2, by
    rw [show fuel + 2 * (32 : Int).toNat + 47 = (fuel + 2 * (32 : Int).toNat + 43) + 4 by omega]
    exact hc⟩

/-- Empty schedule + empty input: `rbK = 0`. -/
theorem raising_eof_rbK : rbK ([] : List Int) (32 : Int) [] = 0 := by
  simp [rbK, rbQ]; decide

/-- Same `read_block` ret-0 callee: raising and ordinary outer loops share post-state `s`
    (the seven root fields live in `s`). Temps differ (`$t21` vs `$t17`). -/
theorem raising_relay_zero_read_same_post (actDef : String → Stmt String) (fuel : Nat)
    (env e : Env) (st s : St) (pb : Path)
    (hb : lookup env "b" = some (.sref pb))
    (hrb : actDef "read_block" = readBlockBody)
    (hcall : interp actDef fuel readBlockBody (calleeEnv (.sref pb)) st =
      .ret (.lit (.int 0)) e s) :
    (∃ eR, interp actDef (fuel + 6) raisingOuterLoop env st =
        .ret (.lit (.int 0)) eR s) ∧
    (∃ eO, interp actDef (fuel + 6) relayOuterLoop env st =
        .ret (.lit (.int 0)) eO s) :=
  ⟨⟨_, raising_outer_of_zero_read actDef fuel env e st s pb hb hrb hcall⟩,
   ⟨_, relay_outer_of_zero_read actDef fuel env e st s pb hb hrb hcall⟩⟩

/-- Status-1 mapping at one outer iteration, same post-state `s` (seven root fields live
    in `s`; temps `$t21` vs `$t17`). No whole-callee `h_sim`. -/
theorem raising_relay_neg_read_same_post
    (actDef : String → Stmt String) (fuel : Nat) (env e : Env) (st s : St) (pb : Path)
    (hb : lookup env "b" = some (.sref pb))
    (hrb : actDef "read_block" = readBlockBody)
    (hcall : interp actDef fuel readBlockBody (calleeEnv (.sref pb)) st =
      .ret (.lit (.int (-1))) e s) :
    (∃ eR, interp actDef (fuel + 6) raisingOuterLoop env st =
        .raise (.pair (.lit (.str "ReadError")) (.lit (.int (-1)))) eR s) ∧
    (∃ eO, interp actDef (fuel + 6) relayOuterLoop env st =
        .ret (.lit (.int 1)) eO s) :=
  ⟨⟨_, raising_outer_of_neg_read_payload_neg1 actDef fuel env e st s pb hb hrb hcall⟩,
   ⟨_, relay_outer_of_neg_read actDef fuel env e st s pb (-1) hb hrb hcall (by decide)⟩⟩

/-- Catch restores 1 on that same `s`. `hwrap` is the already-proved prologue identity
    (`raising_prologue`) that the callee body is the outer loop at this fuel; not a
    whole-program simulation. Ordinary outer returns 1 on the same `s`. -/
theorem raising_caught_of_neg_read_same_s
    (actDef : String → Stmt String) (fuel : Nat) (env envC e : Env) (st s : St) (pb : Path)
    (hb : lookup env "b" = some (.sref pb))
    (hrb : actDef "read_block" = readBlockBody)
    (_hraising : actDef "relay_raising" = relayRaisingBody)
    (hwrap : interp actDef (fuel + 6) (actDef "relay_raising")
        (calleeEnv (.v (.lit .unit))) st =
      interp actDef (fuel + 6) raisingOuterLoop env st)
    (hcall : interp actDef fuel readBlockBody (calleeEnv (.sref pb)) st =
      .ret (.lit (.int (-1))) e s) :
    (∃ eC, interp actDef (fuel + 10) relayCaughtBody envC st =
        .ret (.lit (.int 1)) eC s) ∧
    (∃ eO, interp actDef (fuel + 6) relayOuterLoop env st =
        .ret (.lit (.int 1)) eO s) := by
  have hneg := raising_relay_neg_read_same_post actDef fuel env e st s pb hb hrb hcall
  obtain ⟨⟨eR, heR⟩, hO⟩ := hneg
  have hraise : interp actDef (fuel + 6) (actDef "relay_raising")
      (calleeEnv (.v (.lit .unit))) st =
      .raise (.pair (.lit (.str "ReadError")) (.lit (.int (-1)))) eR s := by
    rw [hwrap, heR]
  have hc := relay_caught_of_readError actDef (fuel + 6) envC eR st s (.lit (.int (-1))) hraise
  exact ⟨⟨_, by
    rw [show fuel + 10 = (fuel + 6) + 4 by omega]
    exact hc⟩, hO⟩

/-- One positive inner write-step: raising and ordinary inner loops share post-state `st3`
    (root `writes`/`write_calls`/`delivered`). Temps `$t22` vs `$t18`. Reuses
    `raising_inner_step` / `relay_inner_step` (111/114, ordinary 67/70 callees). -/
theorem raising_relay_inner_step_same_post
    (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody) (fuel : Nat) (env : Env)
    (st st1 st2 st3 : St) (pb : Path) (off r len cap wc : Int) (bs ws dv req : List Int)
    (hb : lookup env "b" = some (.sref pb))
    (hσ : lookup env "σ" = some (.sref .here))
    (hoff : lookup env "off" = some (.v (.lit (.int off))))
    (hr : lookup env "r" = some (.v (.lit (.int r))))
    (hlen : getAttrAt pb st "len" = some (.lit (.int len)))
    (hcap : getAttrAt pb st "cap" = some (.lit (.int cap)))
    (hbytes : getAttrAt pb st "bytes" = some (Val.ofIntList bs))
    (hbs : bs.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hbslen : (bs.length : Int) = len)
    (hws : getAttrAt .here st "writes" = some (Val.ofIntList ws))
    (hwc : getAttrAt .here st "write_calls" = some (.lit (.int wc)))
    (hdv : getAttrAt .here st "delivered" = some (Val.ofIntList dv))
    (hdvb : dv.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (h0 : 0 ≤ off) (hor : off < r) (hrl : r ≤ len) (hlc : len ≤ cap)
    (hrmax : r ≤ 4611686018427387903)
    (hwc1 : minInt ≤ wc + 1 ∧ wc + 1 ≤ maxInt)
    (hreq : req = (bs.drop off.toNat).take (r - off).toNat)
    (hq : 0 ≤ wbQ ws req)
    (hkpos : 0 < min (wbQ ws req) (req.length : Int))
    (h1 : setAttrAt .here st "writes" (Val.ofIntList ws.tail) = some st1)
    (h2 : setAttrAt .here st1 "write_calls" (.lit (.int (wc + 1))) = some st2)
    (h3 : setAttrAt .here st2 "delivered"
      (Val.ofIntList (dv ++ req.take (min (wbQ ws req) (req.length : Int)).toNat)) = some st3) :
    (interp actDef (fuel + 30) raisingInnerLoop env st =
      interp actDef (fuel + 28) raisingInnerLoop
        (assocSet (assocSet (assocSet env "$t22" (.v (.lit (.int (min (wbQ ws req) (req.length : Int))))))
          "w" (.v (.lit (.int (min (wbQ ws req) (req.length : Int))))))
          "off" (.v (.lit (.int (off + min (wbQ ws req) (req.length : Int))))))
        st3) ∧
    (interp actDef (fuel + 30) relayInnerLoop env st =
      interp actDef (fuel + 28) relayInnerLoop
        (assocSet (assocSet (assocSet env "$t18" (.v (.lit (.int (min (wbQ ws req) (req.length : Int))))))
          "w" (.v (.lit (.int (min (wbQ ws req) (req.length : Int))))))
          "off" (.v (.lit (.int (off + min (wbQ ws req) (req.length : Int))))))
        st3) :=
  ⟨raising_inner_step actDef hwb fuel env st st1 st2 st3 pb off r len cap wc bs ws dv req
      hb hσ hoff hr hlen hcap hbytes hbs hbslen hws hwc hdv hdvb h0 hor hrl hlc hrmax
      hwc1 hreq hq hkpos h1 h2 h3,
   relay_inner_step actDef hwb fuel env st st1 st2 st3 pb off r len cap wc bs ws dv req
      hb hσ hoff hr hlen hcap hbytes hbs hbslen hws hwc hdv hdvb h0 hor hrl hlc hrmax
      hwc1 hreq hq hkpos h1 h2 h3⟩

/-- Empty input / empty `reads`: catch returns 0 from proved callee EOF (`rbK=0`). -/
theorem raising_caught_eof_zero (actDef : String → Stmt String)
    (_hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody)
    (hraising : actDef "relay_raising" = relayRaisingBody) (fuel : Nat) (env : Env) :
    ∃ e st', interp actDef (fuel + 2 * (32 : Int).toNat + 47) relayCaughtBody env
        (raisingWitnessState [] [] []) = .ret (.lit (.int 0)) e st' := by
  let st0 := raisingWitnessState [] [] []
  let stP := relayPrologueState st0
  have hinpA : lookup st0.attrs "input" = some (Val.ofIntList []) := rfl
  have hrsA : lookup st0.attrs "reads" = some (Val.ofIntList []) := rfl
  have hws : lookup st0.attrs "writes" = some (Val.ofIntList []) := rfl
  have hrcA : lookup st0.attrs "read_calls" = some (.lit (.int 0)) := rfl
  have hwc : lookup st0.attrs "write_calls" = some (.lit (.int 0)) := rfl
  have hdv : lookup st0.attrs "delivered" = some (Val.ofIntList []) := rfl
  have hls : lookup st0.attrs "lost" = some (Val.ofIntList []) := rfl
  have hinpb : ([] : List Int).all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true := rfl
  have hdvb : ([] : List Int).all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true := rfl
  have hlsb : ([] : List Int).all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true := rfl
  have hrc0 : minInt ≤ (0 : Int) := by decide
  have hrcb : (0 : Int) + ((([] : List Int).length : Int) + 1) ≤ maxInt := by decide
  have hwc0 : minInt ≤ (0 : Int) := by decide
  have hwcb : (0 : Int) + (([] : List Int).length : Int) ≤ maxInt := by decide
  have outerInv := raising_outerInv_prologue st0 [] [] [] [] [] 0 0
    hinpA hinpb hrsA hrcA hrc0 hrcb hws hwc hwc0 hwcb hdv hdvb hls hlsb
  have hrs : getAttrAt .here stP "reads" = some (Val.ofIntList []) := by
    simp [stP, relayPrologueState, getAttrAt]; exact hrsA
  have hrc : getAttrAt .here stP "read_calls" = some (.lit (.int 0)) := by
    simp [stP, relayPrologueState, getAttrAt]; exact hrcA
  have hinp : getAttrAt .here stP "input" = some (Val.ofIntList []) := by
    simp [stP, relayPrologueState, getAttrAt]; exact hinpA
  have hcap : getAttrAt blockPath stP "cap" = some (.lit (.int 32)) := by
    simp [stP, blockPath, relayPrologueState, relayBlockInit, getAttrAt, lookup_assocSet_same, lookup]
  have hrc1 : minInt ≤ (0 : Int) + 1 ∧ (0 : Int) + 1 ≤ maxInt := by decide
  have hq : 0 ≤ rbQ ([] : List Int) (32 : Int) := by
    simp [rbQ]
  have hpb : blockPath ≠ Path.here := by decide
  have hcap0 : (0 : Int) ≤ 32 := by decide
  have hcapmax : (32 : Int) ≤ 4611686018427387903 := by decide
  obtain ⟨st1, h1⟩ := setAttrAt_isSome_of_getAttrAt .here stP "reads" "reads" _
    (Val.ofIntList ([] : List Int).tail) hrs
  obtain ⟨st2, h2⟩ := setAttrAt_isSome_of_getAttrAt .here st1 "reads" "read_calls" _
    (.lit (.int (0 + 1))) (setAttrAt_same _ _ _ _ _ h1)
  have fpb2 : getAttrAt blockPath st2 "cap" = some (.lit (.int 32)) := by
    rw [setAttrAt_frame _ _ _ _ _ h2 blockPath "cap" (Or.inl hpb),
      setAttrAt_frame _ _ _ _ _ h1 blockPath "cap" (Or.inl hpb)]; exact hcap
  obtain ⟨st3, h3⟩ := setAttrAt_isSome_of_getAttrAt blockPath st2 "cap" "bytes" _
    (Val.ofIntList (([] : List Int).take (rbK [] 32 []).toNat)) fpb2
  obtain ⟨st4, h4⟩ := setAttrAt_isSome_of_getAttrAt blockPath st3 "bytes" "len" _
    (.lit (.int (rbK [] 32 []))) (setAttrAt_same _ _ _ _ _ h3)
  have hinp4 : getAttrAt .here st4 "input" = some (Val.ofIntList []) := by
    rw [setAttrAt_frame _ _ _ _ _ h4 .here "input" (Or.inl (Ne.symm hpb)),
      setAttrAt_frame _ _ _ _ _ h3 .here "input" (Or.inl (Ne.symm hpb)),
      setAttrAt_frame _ _ _ _ _ h2 .here "input" (Or.inr (by decide)),
      setAttrAt_frame _ _ _ _ _ h1 .here "input" (Or.inr (by decide))]; exact hinp
  obtain ⟨st5, h5⟩ := setAttrAt_isSome_of_getAttrAt .here st4 "input" "input" _
    (Val.ofIntList (([] : List Int).drop (rbK [] 32 []).toNat)) hinp4
  have hι : lookup (calleeEnv (.sref blockPath)) "ι" = some (.sref blockPath) := by
    simp [calleeEnv, lookup]
  have hσ : lookup (calleeEnv (.sref blockPath)) "σ" = some (.sref .here) := by
    simp [calleeEnv, lookup]
  obtain ⟨eR, heR⟩ := read_block_body_ret actDef (fuel + 2 * (32 : Int).toNat + 7)
    (calleeEnv (.sref blockPath)) stP st1 st2 st3 st4 st5 blockPath .here 32 0 [] []
    hι hσ hpb hcap hcap0 hcapmax hrs hrc hrc1 hinp hinpb hq h1 h2 h3 h4 h5
  have he' : interp actDef (fuel + 2 * (32 : Int).toNat + 31) readBlockBody
      (calleeEnv (.sref blockPath)) stP = .ret (.lit (.int 0)) eR st5 := by
    rw [show fuel + 2 * (32 : Int).toNat + 7 + 24 = fuel + 2 * (32 : Int).toNat + 31 by omega]
    rw [raising_eof_rbK] at heR; exact heR
  have hloop := raising_outer_of_zero_read actDef
    (fuel + 2 * (32 : Int).toNat + 31) relayPrologueEnv eR stP st5 blockPath
    outerInv.hb hrb he'
  have hloop' : interp actDef (fuel + 2 * (32 : Int).toNat + 37) raisingOuterLoop
      relayPrologueEnv stP =
      .ret (.lit (.int 0))
        (assocSet (assocSet relayPrologueEnv "$t21" (.v (.lit (.int 0))))
          "r" (.v (.lit (.int 0)))) st5 := by
    rw [show fuel + 2 * (32 : Int).toNat + 37 = fuel + 2 * (32 : Int).toNat + 31 + 6 by omega]
    exact hloop
  have hstep : interp actDef (fuel + 2 * (32 : Int).toNat + 43) relayRaisingBody
      (calleeEnv (.v (.lit .unit))) st0 =
      interp actDef (fuel + 2 * (32 : Int).toNat + 37) raisingOuterLoop
        relayPrologueEnv stP := by
    have h := raising_prologue actDef (fuel + 2 * (32 : Int).toNat + 36) st0
    rw [show fuel + 2 * (32 : Int).toNat + 36 + 7 = fuel + 2 * (32 : Int).toNat + 43 by omega,
      show fuel + 2 * (32 : Int).toNat + 36 + 1 = fuel + 2 * (32 : Int).toNat + 37 by omega] at h
    exact h
  have hcall : interp actDef (fuel + 2 * (32 : Int).toNat + 43) (actDef "relay_raising")
      (calleeEnv (.v (.lit .unit))) st0 =
      .ret (.lit (.int 0))
        (assocSet (assocSet relayPrologueEnv "$t21" (.v (.lit (.int 0))))
          "r" (.v (.lit (.int 0)))) st5 := by
    rw [hraising, hstep, hloop']
  have hc := relay_caught_of_ret actDef (fuel + 2 * (32 : Int).toNat + 43) env
    (assocSet (assocSet relayPrologueEnv "$t21" (.v (.lit (.int 0))))
      "r" (.v (.lit (.int 0)))) st0 st5 (.lit (.int 0)) hcall
  exact ⟨_, st5, by
    rw [show fuel + 2 * (32 : Int).toNat + 47 = (fuel + 2 * (32 : Int).toNat + 43) + 4 by omega]
    exact hc⟩


/-- Two InnerInv environments on the same `St`/`off`. One inner iteration: raising from
    `envR` and ordinary from `envO` share the actual post-`St` (continue `st3` or ret-2 `st4`). -/
theorem raising_relay_inner_step_inv_same_post_envs
    (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody) (fuel : Nat)
    (envR envO : Env) (st : St)
    (pb : Path) (len cap : Int) (bs : List Int) (other : String → Option Val) (wcmax : Int)
    (off r : Int)
    (invR : InnerInv pb len cap bs other wcmax envR st off r)
    (invO : InnerInv pb len cap bs other wcmax envO st off r)
    (hor : off < r) :
    (∃ envR' envO' st' off',
      interp actDef (fuel + 30) raisingInnerLoop envR st =
        interp actDef (fuel + 28) raisingInnerLoop envR' st' ∧
      interp actDef (fuel + 30) relayInnerLoop envO st =
        interp actDef (fuel + 28) relayInnerLoop envO' st' ∧
      InnerInv pb len cap bs other wcmax envR' st' off' r ∧
      InnerInv pb len cap bs other wcmax envO' st' off' r ∧
      off < off' ∧ off' ≤ r) ∨
    (∃ envR' envO' st',
      interp actDef (fuel + 30) raisingInnerLoop envR st = .ret (.lit (.int 2)) envR' st' ∧
      interp actDef (fuel + 30) relayInnerLoop envO st = .ret (.lit (.int 2)) envO' st') := by
  obtain ⟨ws, hws⟩ := invR.hws
  obtain ⟨wc, hwc, hwc0, hwcb⟩ := invR.hwc
  obtain ⟨dv, hdv, hdvb⟩ := invR.hdv
  obtain ⟨ls, hlost, hls⟩ := invR.hlost
  have hwcmax := invR.hwcmax
  have hwc1 : minInt ≤ wc + 1 ∧ wc + 1 ≤ maxInt := ⟨by omega, by omega⟩
  have hrb : r ≤ (bs.length : Int) := by have := invR.hrl; have := invR.hbslen; omega
  have hreqlen : (((bs.drop off.toNat).take (r - off).toNat).length : Int) ≤ r - off := by
    simp only [List.length_take, List.length_drop]; omega
  obtain ⟨st1, h1⟩ := setAttrAt_isSome_of_getAttrAt .here st "writes" "writes" _
    (Val.ofIntList ws.tail) hws
  obtain ⟨st2, h2⟩ := setAttrAt_isSome_of_getAttrAt .here st1 "writes" "write_calls" _
    (.lit (.int (wc + 1))) (setAttrAt_same _ _ _ _ _ h1)
  have fpb1 : ∀ a, getAttrAt pb st1 a = getAttrAt pb st a := fun a =>
    setAttrAt_frame _ _ _ _ _ h1 pb a (Or.inl invR.hpb)
  have fpb2 : ∀ a, getAttrAt pb st2 a = getAttrAt pb st a := fun a => by
    rw [setAttrAt_frame _ _ _ _ _ h2 pb a (Or.inl invR.hpb), fpb1]
  have fr1 : ∀ a, a ≠ "writes" → getAttrAt .here st1 a = getAttrAt .here st a := fun a ha =>
    setAttrAt_frame _ _ _ _ _ h1 .here a (Or.inr ha)
  have fr2 : ∀ a, a ≠ "writes" → a ≠ "write_calls" →
      getAttrAt .here st2 a = getAttrAt .here st a := fun a ha hb => by
    rw [setAttrAt_frame _ _ _ _ _ h2 .here a (Or.inr hb), fr1 a ha]
  by_cases hq : 0 ≤ wbQ ws ((bs.drop off.toNat).take (r - off).toNat)
  · obtain ⟨st3, h3⟩ := setAttrAt_isSome_of_getAttrAt .here st2 "write_calls" "delivered" _
      (Val.ofIntList (dv ++ ((bs.drop off.toNat).take (r - off).toNat).take
        (min (wbQ ws ((bs.drop off.toNat).take (r - off).toNat))
          ((((bs.drop off.toNat).take (r - off).toNat).length : Int))).toNat))
      (setAttrAt_same _ _ _ _ _ h2)
    have fpb3 : ∀ a, getAttrAt pb st3 a = getAttrAt pb st a := fun a => by
      rw [setAttrAt_frame _ _ _ _ _ h3 pb a (Or.inl invR.hpb), fpb2]
    have fr3 : ∀ a, a ≠ "writes" → a ≠ "write_calls" → a ≠ "delivered" →
        getAttrAt .here st3 a = getAttrAt .here st a := fun a ha hb hc => by
      rw [setAttrAt_frame _ _ _ _ _ h3 .here a (Or.inr hc), fr2 a ha hb]
    by_cases hk : 0 < min (wbQ ws ((bs.drop off.toNat).take (r - off).toNat))
        ((((bs.drop off.toNat).take (r - off).toNat).length : Int))
    · have hstepR := raising_inner_step actDef hwb fuel envR st st1 st2 st3 pb off r len cap wc bs ws
        dv _ invR.hb invR.hσ invR.hoff invR.hr invR.hlen invR.hcap invR.hbytes invR.hbs invR.hbslen
        hws hwc hdv hdvb invR.h0 hor invR.hrl invR.hlc invR.hrmax hwc1 rfl hq hk h1 h2 h3
      have hstepO := relay_inner_step actDef hwb fuel envO st st1 st2 st3 pb off r len cap wc bs ws
        dv _ invO.hb invO.hσ invO.hoff invO.hr invO.hlen invO.hcap invO.hbytes invO.hbs invO.hbslen
        hws hwc hdv hdvb invO.h0 hor invO.hrl invO.hlc invO.hrmax hwc1 rfl hq hk h1 h2 h3
      left
      refine ⟨_, _, st3, off + min (wbQ ws ((bs.drop off.toNat).take (r - off).toNat))
        ((((bs.drop off.toNat).take (r - off).toNat).length : Int)), hstepR, hstepO, ?_, ?_,
        by omega, by omega⟩
      · exact {
        hb := by simp [lookup_assocSet_other, invR.hb]
        hσ := by simp [lookup_assocSet_other, invR.hσ]
        hoff := lookup_assocSet_same _ _ _
        hr := by simp [lookup_assocSet_other, invR.hr]
        hpb := invR.hpb
        hlen := by rw [fpb3]; exact invR.hlen
        hcap := by rw [fpb3]; exact invR.hcap
        hbytes := by rw [fpb3]; exact invR.hbytes
        hbs := invR.hbs
        hbslen := invR.hbslen
        hws := ⟨ws.tail, by
          rw [setAttrAt_frame _ _ _ _ _ h3 .here "writes" (Or.inr (by decide)),
            setAttrAt_frame _ _ _ _ _ h2 .here "writes" (Or.inr (by decide))]
          exact setAttrAt_same _ _ _ _ _ h1⟩
        hwc := ⟨wc + 1, by
          rw [setAttrAt_frame _ _ _ _ _ h3 .here "write_calls" (Or.inr (by decide))]
          exact setAttrAt_same _ _ _ _ _ h2, by omega, by omega⟩
        hdv := ⟨_, setAttrAt_same _ _ _ _ _ h3, by
          rw [List.all_append, hdvb, all_take_of_all _ _
            (all_take_of_all _ _ (all_drop_of_all _ _ invR.hbs))]; rfl⟩
        hwcmax := invR.hwcmax
        hother := fun a ha hb hc hd => by rw [fr3 a ha hb hc]; exact invR.hother a ha hb hc hd
        hlost := ⟨ls, by rw [fr3 "lost" (by decide) (by decide) (by decide)]; exact hlost, hls⟩
        h0 := by have := invR.h0; omega
        hor := by have := invR.hor; omega
        hrl := invR.hrl
        hlc := invR.hlc
        hrmax := invR.hrmax }
      · exact {
        hb := by simp [lookup_assocSet_other, invO.hb]
        hσ := by simp [lookup_assocSet_other, invO.hσ]
        hoff := lookup_assocSet_same _ _ _
        hr := by simp [lookup_assocSet_other, invO.hr]
        hpb := invO.hpb
        hlen := by rw [fpb3]; exact invO.hlen
        hcap := by rw [fpb3]; exact invO.hcap
        hbytes := by rw [fpb3]; exact invO.hbytes
        hbs := invO.hbs
        hbslen := invO.hbslen
        hws := ⟨ws.tail, by
          rw [setAttrAt_frame _ _ _ _ _ h3 .here "writes" (Or.inr (by decide)),
            setAttrAt_frame _ _ _ _ _ h2 .here "writes" (Or.inr (by decide))]
          exact setAttrAt_same _ _ _ _ _ h1⟩
        hwc := ⟨wc + 1, by
          rw [setAttrAt_frame _ _ _ _ _ h3 .here "write_calls" (Or.inr (by decide))]
          exact setAttrAt_same _ _ _ _ _ h2, by omega, by omega⟩
        hdv := ⟨_, setAttrAt_same _ _ _ _ _ h3, by
          rw [List.all_append, hdvb, all_take_of_all _ _
            (all_take_of_all _ _ (all_drop_of_all _ _ invO.hbs))]; rfl⟩
        hwcmax := invO.hwcmax
        hother := fun a ha hb hc hd => by rw [fr3 a ha hb hc]; exact invO.hother a ha hb hc hd
        hlost := ⟨ls, by rw [fr3 "lost" (by decide) (by decide) (by decide)]; exact hlost, hls⟩
        h0 := by have := invO.h0; omega
        hor := by have := invO.hor; omega
        hrl := invO.hrl
        hlc := invO.hlc
        hrmax := invO.hrmax }
    · obtain ⟨e, he⟩ := write_block_body_ret actDef fuel
        (calleeEnv (.rpair (.sref pb) (.v (.pair (.lit (.int off)) (.lit (.int r))))))
        st st1 st2 st3 pb .here off r len cap wc bs ws dv _
        (by simp [calleeEnv, lookup]) (by simp [calleeEnv, lookup])
        invR.hlen invR.hcap invR.hbytes invR.hbs invR.hbslen hws hwc hdv hdvb invR.h0 (by omega)
        invR.hrl invR.hlc invR.hrmax hwc1 rfl h1 h2 hq h3
      obtain ⟨st4, h4⟩ := setAttrAt_isSome_of_getAttrAt .here st3 "delivered" "lost" _
        (Val.ofIntList (ls ++ (bs.drop off.toNat).take (r - off).toNat))
        (setAttrAt_same _ _ _ _ _ h3)
      right
      obtain ⟨envR', hretR⟩ := raising_inner_lost actDef hwb fuel envR e st st3 st4 pb off r _ bs ls
        invR.hb invR.hσ invR.hoff invR.hr invR.h0 hor invR.hrmax he (by omega)
        (by rw [fr3 "lost" (by decide) (by decide) (by decide)]; exact hlost) hls
        (by rw [fpb3]; exact invR.hbytes) invR.hbs hrb h4
      obtain ⟨envO', hretO⟩ := relay_inner_lost actDef hwb fuel envO e st st3 st4 pb off r _ bs ls
        invO.hb invO.hσ invO.hoff invO.hr invO.h0 hor invO.hrmax he (by omega)
        (by rw [fr3 "lost" (by decide) (by decide) (by decide)]; exact hlost) hls
        (by rw [fpb3]; exact invO.hbytes) invO.hbs hrb h4
      exact ⟨envR', envO', st4, hretR, hretO⟩
  · obtain ⟨e, he⟩ := write_block_body_neg actDef fuel
      (calleeEnv (.rpair (.sref pb) (.v (.pair (.lit (.int off)) (.lit (.int r))))))
      st st1 st2 pb .here off r len cap wc bs ws _
      (by simp [calleeEnv, lookup]) (by simp [calleeEnv, lookup])
      invR.hlen invR.hcap invR.hbytes invR.hbs invR.hbslen hws hwc invR.h0 (by omega)
      invR.hrl invR.hlc invR.hrmax hwc1 rfl h1 h2 (by omega)
    obtain ⟨st4, h4⟩ := setAttrAt_isSome_of_getAttrAt .here st2 "write_calls" "lost" _
      (Val.ofIntList (ls ++ (bs.drop off.toNat).take (r - off).toNat))
      (setAttrAt_same _ _ _ _ _ h2)
    right
    obtain ⟨envR', hretR⟩ := raising_inner_lost actDef hwb fuel envR e st st2 st4 pb off r (-1) bs ls
      invR.hb invR.hσ invR.hoff invR.hr invR.h0 hor invR.hrmax he (by omega)
      (by rw [fr2 "lost" (by decide) (by decide)]; exact hlost) hls
      (by rw [fpb2]; exact invR.hbytes) invR.hbs hrb h4
    obtain ⟨envO', hretO⟩ := relay_inner_lost actDef hwb fuel envO e st st2 st4 pb off r (-1) bs ls
      invO.hb invO.hσ invO.hoff invO.hr invO.h0 hor invO.hrmax he (by omega)
      (by rw [fr2 "lost" (by decide) (by decide)]; exact hlost) hls
      (by rw [fpb2]; exact invO.hbytes) invO.hbs hrb h4
    exact ⟨envR', envO', st4, hretR, hretO⟩

/-- Structural induction: raising from `envR` and ordinary from `envO` (same `St`/`off`)
    finish on the same post-`St` (continue at `off = r`, or ret-2). -/
theorem raising_relay_inner_loop_run_same_post_envs
    (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody) (pb : Path) (len cap : Int) (bs : List Int)
    (other : String → Option Val) (wcmax : Int)
    (r : Int) : ∀ (m fuel : Nat) (envR envO : Env) (st : St) (off : Int),
    InnerInv pb len cap bs other wcmax envR st off r →
    InnerInv pb len cap bs other wcmax envO st off r →
    (r - off).toNat ≤ m →
    (∃ envR' envO' st',
      interp actDef (fuel + 2 * m + 30) raisingInnerLoop envR st = .continue envR' st' ∧
      interp actDef (fuel + 2 * m + 30) relayInnerLoop envO st = .continue envO' st' ∧
      InnerInv pb len cap bs other wcmax envR' st' r r ∧
      InnerInv pb len cap bs other wcmax envO' st' r r) ∨
    (∃ envR' envO' st',
      interp actDef (fuel + 2 * m + 30) raisingInnerLoop envR st =
        .ret (.lit (.int 2)) envR' st' ∧
      interp actDef (fuel + 2 * m + 30) relayInnerLoop envO st =
        .ret (.lit (.int 2)) envO' st') := by
  intro m
  induction m with
  | zero =>
    intro fuel envR envO st off invR invO hm
    have hoffr : off = r := by have := invR.hor; omega
    subst hoffr
    have hcR : evalExpr envR (.fn .lt (.pair (.var "off") (.var "r"))) =
        some (.v (.lit (.bool false))) := by
      simp only [evalExpr, invR.hoff, invR.hr, funcDef_lt, Int.lt_irrefl, decide_false,
        Option.map_some]
    have hcO : evalExpr envO (.fn .lt (.pair (.var "off") (.var "r"))) =
        some (.v (.lit (.bool false))) := by
      simp only [evalExpr, invO.hoff, invO.hr, funcDef_lt, Int.lt_irrefl, decide_false,
        Option.map_some]
    left
    refine ⟨envR, envO, st, ?_, ?_, invR, invO⟩
    · rw [show fuel + 2 * 0 + 30 = (fuel + 29) + 1 by omega, raisingInnerLoop,
        interp_while_false actDef (fuel + 29) envR st _ raisingInnerBody hcR]
    · rw [show fuel + 2 * 0 + 30 = (fuel + 29) + 1 by omega, relayInnerLoop,
        interp_while_false actDef (fuel + 29) envO st _ relayInnerBody hcO]
  | succ m ih =>
    intro fuel envR envO st off invR invO hm
    by_cases hlt : off < r
    · rcases raising_relay_inner_step_inv_same_post_envs actDef hwb (fuel + 2 * m + 2)
        envR envO st pb len cap bs other wcmax off r invR invO hlt
        with ⟨envR', envO', st', off', hstepR, hstepO, invR', invO', hlt', hle'⟩
        | ⟨envR', envO', st', hretR, hretO⟩
      · rw [show fuel + 2 * (m + 1) + 30 = (fuel + 2 * m + 2) + 30 by omega, hstepR, hstepO,
          show fuel + 2 * m + 2 + 28 = fuel + 2 * m + 30 by omega]
        exact ih fuel envR' envO' st' off' invR' invO' (by omega)
      · right
        rw [show fuel + 2 * (m + 1) + 30 = (fuel + 2 * m + 2) + 30 by omega, hretR, hretO]
        exact ⟨envR', envO', st', rfl, rfl⟩
    · have hoffr : off = r := by have := invR.hor; omega
      subst hoffr
      have hcR : evalExpr envR (.fn .lt (.pair (.var "off") (.var "r"))) =
          some (.v (.lit (.bool false))) := by
        simp only [evalExpr, invR.hoff, invR.hr, funcDef_lt, Int.lt_irrefl, decide_false,
          Option.map_some]
      have hcO : evalExpr envO (.fn .lt (.pair (.var "off") (.var "r"))) =
          some (.v (.lit (.bool false))) := by
        simp only [evalExpr, invO.hoff, invO.hr, funcDef_lt, Int.lt_irrefl, decide_false,
          Option.map_some]
      left
      refine ⟨envR, envO, st, ?_, ?_, invR, invO⟩
      · rw [show fuel + 2 * (m + 1) + 30 = (fuel + 2 * m + 31) + 1 by omega, raisingInnerLoop,
          interp_while_false actDef (fuel + 2 * m + 31) envR st _ raisingInnerBody hcR]
      · rw [show fuel + 2 * (m + 1) + 30 = (fuel + 2 * m + 31) + 1 by omega, relayInnerLoop,
          interp_while_false actDef (fuel + 2 * m + 31) envO st _ relayInnerBody hcO]

/-- Same starting env: full inner loop, same actual post-`St` on success or ret-2. -/
theorem raising_relay_inner_loop_run_same_post
    (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody) (pb : Path) (len cap : Int) (bs : List Int)
    (other : String → Option Val) (wcmax : Int)
    (r : Int) (m fuel : Nat) (env : Env) (st : St) (off : Int)
    (inv : InnerInv pb len cap bs other wcmax env st off r)
    (hm : (r - off).toNat ≤ m) :
    (∃ envR envO st',
      interp actDef (fuel + 2 * m + 30) raisingInnerLoop env st = .continue envR st' ∧
      interp actDef (fuel + 2 * m + 30) relayInnerLoop env st = .continue envO st' ∧
      InnerInv pb len cap bs other wcmax envR st' r r ∧
      InnerInv pb len cap bs other wcmax envO st' r r) ∨
    (∃ envR envO st',
      interp actDef (fuel + 2 * m + 30) raisingInnerLoop env st =
        .ret (.lit (.int 2)) envR st' ∧
      interp actDef (fuel + 2 * m + 30) relayInnerLoop env st =
        .ret (.lit (.int 2)) envO st') :=
  raising_relay_inner_loop_run_same_post_envs actDef hwb pb len cap bs other wcmax r
    m fuel env env st off inv inv hm

/-- Two `OuterInv` environments on the same `St`/`inp`. One outer iteration:
    raising (`$t21`) and ordinary (`$t17`) share the actual post-`St`. Continue
    with the same strictly shorter input, ret-0, ret-2, or raising
    `ReadError(-1)` vs ordinary ret-1. Does not assume whole-callee `h_sim`. -/
theorem raising_relay_outer_step_same_post_envs
    (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody) (fuel : Nat)
    (envR envO : Env) (st : St)
    (pb : Path) (cap : Int) (inp : List Int)
    (invR : OuterInv pb cap inp envR st)
    (invO : OuterInv pb cap inp envO st) :
    (∃ envR' envO' st' inp',
      interp actDef (fuel + 2 * cap.toNat + 37) raisingOuterLoop envR st =
        interp actDef (fuel + 2 * cap.toNat + 35) raisingOuterLoop envR' st' ∧
      interp actDef (fuel + 2 * cap.toNat + 37) relayOuterLoop envO st =
        interp actDef (fuel + 2 * cap.toNat + 35) relayOuterLoop envO' st' ∧
      OuterInv pb cap inp' envR' st' ∧
      OuterInv pb cap inp' envO' st' ∧ inp'.length < inp.length) ∨
    (∃ envR' envO' st',
      interp actDef (fuel + 2 * cap.toNat + 37) raisingOuterLoop envR st =
        .ret (.lit (.int 0)) envR' st' ∧
      interp actDef (fuel + 2 * cap.toNat + 37) relayOuterLoop envO st =
        .ret (.lit (.int 0)) envO' st') ∨
    (∃ envR' envO' st',
      interp actDef (fuel + 2 * cap.toNat + 37) raisingOuterLoop envR st =
        .raise (.pair (.lit (.str "ReadError")) (.lit (.int (-1)))) envR' st' ∧
      interp actDef (fuel + 2 * cap.toNat + 37) relayOuterLoop envO st =
        .ret (.lit (.int 1)) envO' st') ∨
    (∃ envR' envO' st',
      interp actDef (fuel + 2 * cap.toNat + 37) raisingOuterLoop envR st =
        .ret (.lit (.int 2)) envR' st' ∧
      interp actDef (fuel + 2 * cap.toNat + 37) relayOuterLoop envO st =
        .ret (.lit (.int 2)) envO' st') := by
  obtain ⟨rs, hrs⟩ := invR.hrs
  obtain ⟨rc, hrc, hrc0, hrcb⟩ := invR.hrc
  obtain ⟨ws, hws⟩ := invR.hws
  obtain ⟨wc, hwc, hwc0, hwcb⟩ := invR.hwc
  obtain ⟨dv, hdv, hdvb⟩ := invR.hdv
  obtain ⟨ls, hlost, hls⟩ := invR.hlost
  have hcap0 : 0 ≤ cap := by have := invR.hcap1; omega
  have hrc1 : minInt ≤ rc + 1 ∧ rc + 1 ≤ maxInt := ⟨by omega, by omega⟩
  obtain ⟨st1, h1⟩ := setAttrAt_isSome_of_getAttrAt .here st "reads" "reads" _
    (Val.ofIntList rs.tail) hrs
  obtain ⟨st2, h2⟩ := setAttrAt_isSome_of_getAttrAt .here st1 "reads" "read_calls" _
    (.lit (.int (rc + 1))) (setAttrAt_same _ _ _ _ _ h1)
  have fpb1 : ∀ a, getAttrAt pb st1 a = getAttrAt pb st a := fun a =>
    setAttrAt_frame _ _ _ _ _ h1 pb a (Or.inl invR.hpb)
  have fpb2 : ∀ a, getAttrAt pb st2 a = getAttrAt pb st a := fun a => by
    rw [setAttrAt_frame _ _ _ _ _ h2 pb a (Or.inl invR.hpb), fpb1]
  have fr2 : ∀ a, a ≠ "reads" → a ≠ "read_calls" →
      getAttrAt .here st2 a = getAttrAt .here st a := fun a ha hb => by
    rw [setAttrAt_frame _ _ _ _ _ h2 .here a (Or.inr hb),
      setAttrAt_frame _ _ _ _ _ h1 .here a (Or.inr ha)]
  have hcall_env_ι : lookup (calleeEnv (.sref pb)) "ι" = some (.sref pb) := by
    simp [calleeEnv, lookup]
  have hcall_env_σ : lookup (calleeEnv (.sref pb)) "σ" = some (.sref .here) := by
    simp [calleeEnv, lookup]
  have hctrueR : evalExpr envR (.lit (.bool true)) = some (.v (.lit (.bool true))) := rfl
  have hctrueO : evalExpr envO (.lit (.bool true)) = some (.v (.lit (.bool true))) := rfl
  by_cases hq : 0 ≤ rbQ rs cap
  · obtain ⟨st3, h3⟩ := setAttrAt_isSome_of_getAttrAt pb st2 "cap" "bytes" _
      (Val.ofIntList (inp.take (rbK rs cap inp).toNat)) (by rw [fpb2]; exact invR.hcap)
    obtain ⟨st4, h4⟩ := setAttrAt_isSome_of_getAttrAt pb st3 "bytes" "len" _
      (.lit (.int (rbK rs cap inp))) (setAttrAt_same _ _ _ _ _ h3)
    have fr4 : ∀ a, a ≠ "reads" → a ≠ "read_calls" →
        getAttrAt .here st4 a = getAttrAt .here st a := fun a ha hb => by
      rw [setAttrAt_frame _ _ _ _ _ h4 .here a (Or.inl (Ne.symm invR.hpb)),
        setAttrAt_frame _ _ _ _ _ h3 .here a (Or.inl (Ne.symm invR.hpb)), fr2 a ha hb]
    obtain ⟨st5, h5⟩ := setAttrAt_isSome_of_getAttrAt .here st4 "input" "input" _
      (Val.ofIntList (inp.drop (rbK rs cap inp).toNat))
      (by rw [fr4 "input" (by decide) (by decide)]; exact invR.hinp)
    have fr5 : ∀ a, a ≠ "reads" → a ≠ "read_calls" → a ≠ "input" →
        getAttrAt .here st5 a = getAttrAt .here st a := fun a ha hb hc => by
      rw [setAttrAt_frame _ _ _ _ _ h5 .here a (Or.inr hc), fr4 a ha hb]
    have fpb5 : ∀ a, a ≠ "bytes" → a ≠ "len" → getAttrAt pb st5 a = getAttrAt pb st a :=
      fun a ha hb => by
      rw [setAttrAt_frame _ _ _ _ _ h5 pb a (Or.inl invR.hpb),
        setAttrAt_frame _ _ _ _ _ h4 pb a (Or.inr hb),
        setAttrAt_frame _ _ _ _ _ h3 pb a (Or.inr ha), fpb2]
    obtain ⟨e, he⟩ := read_block_body_ret actDef (fuel + 2 * cap.toNat + 7) (calleeEnv (.sref pb))
      st st1 st2 st3 st4 st5 pb .here cap rc rs inp hcall_env_ι hcall_env_σ invR.hpb invR.hcap hcap0
      invR.hcapmax hrs hrc hrc1 invR.hinp invR.hinpb hq h1 h2 h3 h4 h5
    have he' : interp actDef (fuel + 2 * cap.toNat + 31) readBlockBody (calleeEnv (.sref pb)) st =
        .ret (.lit (.int (rbK rs cap inp))) e st5 := he
    have hk0 : 0 ≤ rbK rs cap inp := by unfold rbK; omega
    have hkcap : rbK rs cap inp ≤ cap := by unfold rbK; omega
    have hkinp : rbK rs cap inp ≤ (inp.length : Int) := by unfold rbK; omega
    have hkl : ((inp.take (rbK rs cap inp).toNat).length : Int) = rbK rs cap inp := by
      simp only [List.length_take]; omega
    by_cases hkz : rbK rs cap inp = 0
    · have hEofR :
          interp actDef (fuel + 2 * cap.toNat + 37) raisingOuterLoop envR st =
            .ret (.lit (.int 0))
              (assocSet (assocSet envR "$t21" (.v (.lit (.int 0)))) "r" (.v (.lit (.int 0)))) st5 := by
        rw [show fuel + 2 * cap.toNat + 37 = fuel + 2 * cap.toNat + 36 + 1 from rfl]
        rw [raisingOuterLoop, interp_while_true actDef _ envR st _ raisingOuterBody hctrueR]
        unfold raisingOuterBody
        simp only [interp_succ_seq, interp_succ_action, interp_succ_assign, interp_succ_cond,
          interp_succ_ret, interp_succ_pass, evalExpr, lookup_assocSet_same,
          invR.hb, hrb, he', funcDef_lt, funcDef_eq_int, Option.map_some,
          decide_true, decide_false, hkz, Int.lt_irrefl]
      have hEofO :
          interp actDef (fuel + 2 * cap.toNat + 37) relayOuterLoop envO st =
            .ret (.lit (.int 0))
              (assocSet (assocSet envO "$t17" (.v (.lit (.int 0)))) "r" (.v (.lit (.int 0)))) st5 := by
        rw [show fuel + 2 * cap.toNat + 37 = fuel + 2 * cap.toNat + 36 + 1 from rfl]
        rw [relayOuterLoop, interp_while_true actDef _ envO st _ relayOuterBody hctrueO]
        unfold relayOuterBody
        simp only [interp_succ_seq, interp_succ_action, interp_succ_assign, interp_succ_cond,
          interp_succ_ret, interp_succ_pass, evalExpr, lookup_assocSet_same,
          invO.hb, hrb, he', funcDef_lt, funcDef_eq_int, Option.map_some,
          decide_true, decide_false, hkz, Int.lt_irrefl]
      exact Or.inr (Or.inl ⟨_, _, st5, hEofR, hEofO⟩)
    · have hklt : ¬ (rbK rs cap inp < 0) := by omega
      have hbs5 : (inp.take (rbK rs cap inp).toNat).all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true :=
        all_take_of_all _ _ invR.hinpb
      have innerInvR : InnerInv pb (rbK rs cap inp) cap (inp.take (rbK rs cap inp).toNat)
          (fun a => getAttrAt .here st5 a) (wc + rbK rs cap inp)
          (assocSet (assocSet (assocSet envR "$t21" (.v (.lit (.int (rbK rs cap inp)))))
            "r" (.v (.lit (.int (rbK rs cap inp))))) "off" (.v (.lit (.int 0))))
          st5 0 (rbK rs cap inp) :=
        { hb := by simp [lookup_assocSet_other, invR.hb]
          hσ := by simp [lookup_assocSet_other, invR.hσ]
          hoff := lookup_assocSet_same _ _ _
          hr := by simp [lookup_assocSet_other, lookup_assocSet_same]
          hpb := invR.hpb
          hlen := by
            rw [setAttrAt_frame _ _ _ _ _ h5 pb "len" (Or.inl invR.hpb)]
            exact setAttrAt_same _ _ _ _ _ h4
          hcap := by rw [fpb5 "cap" (by decide) (by decide)]; exact invR.hcap
          hbytes := by
            rw [setAttrAt_frame _ _ _ _ _ h5 pb "bytes" (Or.inl invR.hpb),
              setAttrAt_frame _ _ _ _ _ h4 pb "bytes" (Or.inr (by decide))]
            exact setAttrAt_same _ _ _ _ _ h3
          hbs := hbs5
          hbslen := hkl
          hws := ⟨ws, by rw [fr5 "writes" (by decide) (by decide) (by decide)]; exact hws⟩
          hwc := ⟨wc, by rw [fr5 "write_calls" (by decide) (by decide) (by decide)]; exact hwc,
            hwc0, by omega⟩
          hwcmax := by omega
          hother := fun a _ _ _ _ => rfl
          hdv := ⟨dv, by rw [fr5 "delivered" (by decide) (by decide) (by decide)]; exact hdv, hdvb⟩
          hlost := ⟨ls, by rw [fr5 "lost" (by decide) (by decide) (by decide)]; exact hlost, hls⟩
          h0 := Int.le_refl 0
          hor := hk0
          hrl := Int.le_refl _
          hlc := hkcap
          hrmax := by have := invR.hcapmax; omega }
      have innerInvO : InnerInv pb (rbK rs cap inp) cap (inp.take (rbK rs cap inp).toNat)
          (fun a => getAttrAt .here st5 a) (wc + rbK rs cap inp)
          (assocSet (assocSet (assocSet envO "$t17" (.v (.lit (.int (rbK rs cap inp)))))
            "r" (.v (.lit (.int (rbK rs cap inp))))) "off" (.v (.lit (.int 0))))
          st5 0 (rbK rs cap inp) :=
        { hb := by simp [lookup_assocSet_other, invO.hb]
          hσ := by simp [lookup_assocSet_other, invO.hσ]
          hoff := lookup_assocSet_same _ _ _
          hr := by simp [lookup_assocSet_other, lookup_assocSet_same]
          hpb := invO.hpb
          hlen := by
            rw [setAttrAt_frame _ _ _ _ _ h5 pb "len" (Or.inl invO.hpb)]
            exact setAttrAt_same _ _ _ _ _ h4
          hcap := by rw [fpb5 "cap" (by decide) (by decide)]; exact invO.hcap
          hbytes := by
            rw [setAttrAt_frame _ _ _ _ _ h5 pb "bytes" (Or.inl invO.hpb),
              setAttrAt_frame _ _ _ _ _ h4 pb "bytes" (Or.inr (by decide))]
            exact setAttrAt_same _ _ _ _ _ h3
          hbs := hbs5
          hbslen := hkl
          hws := ⟨ws, by rw [fr5 "writes" (by decide) (by decide) (by decide)]; exact hws⟩
          hwc := ⟨wc, by rw [fr5 "write_calls" (by decide) (by decide) (by decide)]; exact hwc,
            hwc0, by omega⟩
          hwcmax := by omega
          hother := fun a _ _ _ _ => rfl
          hdv := ⟨dv, by rw [fr5 "delivered" (by decide) (by decide) (by decide)]; exact hdv, hdvb⟩
          hlost := ⟨ls, by rw [fr5 "lost" (by decide) (by decide) (by decide)]; exact hlost, hls⟩
          h0 := Int.le_refl 0
          hor := hk0
          hrl := Int.le_refl _
          hlc := hkcap
          hrmax := by have := invO.hcapmax; omega }
      have hm : (rbK rs cap inp - (0 : Int)).toNat ≤ cap.toNat := by
        have := hkcap; have := hk0; omega
      rcases raising_relay_inner_loop_run_same_post_envs actDef hwb pb (rbK rs cap inp) cap
          (inp.take (rbK rs cap inp).toNat) (fun a => getAttrAt .here st5 a)
          (wc + rbK rs cap inp) (rbK rs cap inp) cap.toNat fuel
          (assocSet (assocSet (assocSet envR "$t21" (.v (.lit (.int (rbK rs cap inp)))))
            "r" (.v (.lit (.int (rbK rs cap inp))))) "off" (.v (.lit (.int 0))))
          (assocSet (assocSet (assocSet envO "$t17" (.v (.lit (.int (rbK rs cap inp)))))
            "r" (.v (.lit (.int (rbK rs cap inp))))) "off" (.v (.lit (.int 0))))
          st5 0 innerInvR innerInvO hm
        with ⟨e2R, e2O, s2, hrunR, hrunO, inv2R, inv2O⟩ | ⟨e2R, e2O, s2, hrunR, hrunO⟩
      · left
        refine ⟨e2R, e2O, s2, inp.drop (rbK rs cap inp).toNat, ?_, ?_, ?_, ?_, ?_⟩
        · show interp actDef (fuel + 2 * cap.toNat + 36 + 1) raisingOuterLoop envR st = _
          rw [raisingOuterLoop, interp_while_true actDef _ envR st _ raisingOuterBody hctrueR]
          unfold raisingOuterBody
          simp only [interp_succ_seq, interp_succ_action, interp_succ_assign, interp_succ_cond,
            interp_succ_pass, evalExpr, lookup_assocSet_same,
            invR.hb, hrb, he', funcDef_lt, funcDef_eq_int, Option.map_some,
            decide_false, hklt, hkz, hrunR]
        · show interp actDef (fuel + 2 * cap.toNat + 36 + 1) relayOuterLoop envO st = _
          rw [relayOuterLoop, interp_while_true actDef _ envO st _ relayOuterBody hctrueO]
          unfold relayOuterBody
          simp only [interp_succ_seq, interp_succ_action, interp_succ_assign, interp_succ_cond,
            interp_succ_pass, evalExpr, lookup_assocSet_same,
            invO.hb, hrb, he', funcDef_lt, funcDef_eq_int, Option.map_some,
            decide_false, hklt, hkz, hrunO]
        · obtain ⟨wc2, hwc2, hwc20, hwc2b⟩ := inv2R.hwc
          exact {
            hb := inv2R.hb
            hσ := inv2R.hσ
            hpb := invR.hpb
            hcap := inv2R.hcap
            hcap1 := invR.hcap1
            hcapmax := invR.hcapmax
            hrs := ⟨rs.tail, by
              rw [inv2R.hother "reads" (by decide) (by decide) (by decide) (by decide)]
              show getAttrAt .here st5 "reads" = _
              rw [setAttrAt_frame _ _ _ _ _ h5 .here "reads" (Or.inr (by decide)),
                setAttrAt_frame _ _ _ _ _ h4 .here "reads" (Or.inl (Ne.symm invR.hpb)),
                setAttrAt_frame _ _ _ _ _ h3 .here "reads" (Or.inl (Ne.symm invR.hpb)),
                setAttrAt_frame _ _ _ _ _ h2 .here "reads" (Or.inr (by decide))]
              exact setAttrAt_same _ _ _ _ _ h1⟩
            hrc := ⟨rc + 1, by
              rw [inv2R.hother "read_calls" (by decide) (by decide) (by decide) (by decide)]
              show getAttrAt .here st5 "read_calls" = _
              rw [setAttrAt_frame _ _ _ _ _ h5 .here "read_calls" (Or.inr (by decide)),
                setAttrAt_frame _ _ _ _ _ h4 .here "read_calls" (Or.inl (Ne.symm invR.hpb)),
                setAttrAt_frame _ _ _ _ _ h3 .here "read_calls" (Or.inl (Ne.symm invR.hpb))]
              exact setAttrAt_same _ _ _ _ _ h2, by omega, by
              simp only [List.length_drop]; omega⟩
            hinp := by
              rw [inv2R.hother "input" (by decide) (by decide) (by decide) (by decide)]
              exact setAttrAt_same _ _ _ _ _ h5
            hinpb := all_drop_of_all _ _ invR.hinpb
            hws := inv2R.hws
            hwc := ⟨wc2, hwc2, hwc20, by simp only [List.length_drop]; omega⟩
            hdv := inv2R.hdv
            hlost := inv2R.hlost }
        · obtain ⟨wc2, hwc2, hwc20, hwc2b⟩ := inv2O.hwc
          exact {
            hb := inv2O.hb
            hσ := inv2O.hσ
            hpb := invO.hpb
            hcap := inv2O.hcap
            hcap1 := invO.hcap1
            hcapmax := invO.hcapmax
            hrs := ⟨rs.tail, by
              rw [inv2O.hother "reads" (by decide) (by decide) (by decide) (by decide)]
              show getAttrAt .here st5 "reads" = _
              rw [setAttrAt_frame _ _ _ _ _ h5 .here "reads" (Or.inr (by decide)),
                setAttrAt_frame _ _ _ _ _ h4 .here "reads" (Or.inl (Ne.symm invO.hpb)),
                setAttrAt_frame _ _ _ _ _ h3 .here "reads" (Or.inl (Ne.symm invO.hpb)),
                setAttrAt_frame _ _ _ _ _ h2 .here "reads" (Or.inr (by decide))]
              exact setAttrAt_same _ _ _ _ _ h1⟩
            hrc := ⟨rc + 1, by
              rw [inv2O.hother "read_calls" (by decide) (by decide) (by decide) (by decide)]
              show getAttrAt .here st5 "read_calls" = _
              rw [setAttrAt_frame _ _ _ _ _ h5 .here "read_calls" (Or.inr (by decide)),
                setAttrAt_frame _ _ _ _ _ h4 .here "read_calls" (Or.inl (Ne.symm invO.hpb)),
                setAttrAt_frame _ _ _ _ _ h3 .here "read_calls" (Or.inl (Ne.symm invO.hpb))]
              exact setAttrAt_same _ _ _ _ _ h2, by omega, by
              simp only [List.length_drop]; omega⟩
            hinp := by
              rw [inv2O.hother "input" (by decide) (by decide) (by decide) (by decide)]
              exact setAttrAt_same _ _ _ _ _ h5
            hinpb := all_drop_of_all _ _ invO.hinpb
            hws := inv2O.hws
            hwc := ⟨wc2, hwc2, hwc20, by simp only [List.length_drop]; omega⟩
            hdv := inv2O.hdv
            hlost := inv2O.hlost }
        · simp only [List.length_drop]; omega
      · refine Or.inr (Or.inr (Or.inr ⟨e2R, e2O, s2, ?_, ?_⟩))
        · show interp actDef (fuel + 2 * cap.toNat + 36 + 1) raisingOuterLoop envR st = _
          rw [raisingOuterLoop, interp_while_true actDef _ envR st _ raisingOuterBody hctrueR]
          unfold raisingOuterBody
          simp only [interp_succ_seq, interp_succ_action, interp_succ_assign, interp_succ_cond,
            interp_succ_pass, evalExpr, lookup_assocSet_same,
            invR.hb, hrb, he', funcDef_lt, funcDef_eq_int, Option.map_some,
            decide_false, hklt, hkz, hrunR]
        · show interp actDef (fuel + 2 * cap.toNat + 36 + 1) relayOuterLoop envO st = _
          rw [relayOuterLoop, interp_while_true actDef _ envO st _ relayOuterBody hctrueO]
          unfold relayOuterBody
          simp only [interp_succ_seq, interp_succ_action, interp_succ_assign, interp_succ_cond,
            interp_succ_pass, evalExpr, lookup_assocSet_same,
            invO.hb, hrb, he', funcDef_lt, funcDef_eq_int, Option.map_some,
            decide_false, hklt, hkz, hrunO]
  · obtain ⟨e, he⟩ := read_block_body_neg actDef (fuel + 2 * cap.toNat + 7) (calleeEnv (.sref pb))
      st st1 st2 pb .here cap rc rs hcall_env_ι hcall_env_σ invR.hcap hrs hrc hrc1 (by omega) h1 h2
    have he' : interp actDef (fuel + 2 * cap.toNat + 31) readBlockBody (calleeEnv (.sref pb)) st =
        .ret (.lit (.int (-1))) e st2 := he
    have hneg : (-1 : Int) < 0 := by decide
    have hNegR :
        interp actDef (fuel + 2 * cap.toNat + 37) raisingOuterLoop envR st =
          .raise (.pair (.lit (.str "ReadError")) (.lit (.int (-1))))
            (assocSet (assocSet envR "$t21" (.v (.lit (.int (-1))))) "r" (.v (.lit (.int (-1))))) st2 := by
      rw [show fuel + 2 * cap.toNat + 37 = fuel + 2 * cap.toNat + 36 + 1 from rfl]
      rw [raisingOuterLoop, interp_while_true actDef _ envR st _ raisingOuterBody hctrueR]
      unfold raisingOuterBody
      simp only [interp_succ_seq, interp_succ_action, interp_succ_assign, interp_succ_cond,
        interp_succ_raise, evalExpr, lookup_assocSet_same,
        invR.hb, hrb, he', funcDef_lt, Option.map_some, hneg, decide_true]
    have hNegO :
        interp actDef (fuel + 2 * cap.toNat + 37) relayOuterLoop envO st =
          .ret (.lit (.int 1))
            (assocSet (assocSet envO "$t17" (.v (.lit (.int (-1))))) "r" (.v (.lit (.int (-1))))) st2 := by
      rw [show fuel + 2 * cap.toNat + 37 = fuel + 2 * cap.toNat + 36 + 1 from rfl]
      rw [relayOuterLoop, interp_while_true actDef _ envO st _ relayOuterBody hctrueO]
      unfold relayOuterBody
      simp only [interp_succ_seq, interp_succ_action, interp_succ_assign, interp_succ_cond,
        interp_succ_ret, evalExpr, lookup_assocSet_same,
        invO.hb, hrb, he', funcDef_lt, Option.map_some, hneg, decide_true]
    exact Or.inr (Or.inr (Or.inl ⟨_, _, st2, hNegR, hNegO⟩))

/-- Structural induction on remaining input length: raising and ordinary outer
    loops on two `OuterInv` envs sharing `St` finish on the same post-`St`.
    Ordinary ret-1 corresponds to raising `ReadError(-1)`. -/
theorem raising_relay_outer_loop_run_same_post_envs
    (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody) (pb : Path) (cap : Int) :
    ∀ (m fuel : Nat) (envR envO : Env) (st : St) (inp : List Int),
      OuterInv pb cap inp envR st → OuterInv pb cap inp envO st → inp.length ≤ m →
      (∃ envR' envO' st',
          interp actDef (fuel + 2 * m + 2 * cap.toNat + 37) raisingOuterLoop envR st =
            .ret (.lit (.int 0)) envR' st' ∧
          interp actDef (fuel + 2 * m + 2 * cap.toNat + 37) relayOuterLoop envO st =
            .ret (.lit (.int 0)) envO' st') ∨
      (∃ envR' envO' st',
          interp actDef (fuel + 2 * m + 2 * cap.toNat + 37) raisingOuterLoop envR st =
            .raise (.pair (.lit (.str "ReadError")) (.lit (.int (-1)))) envR' st' ∧
          interp actDef (fuel + 2 * m + 2 * cap.toNat + 37) relayOuterLoop envO st =
            .ret (.lit (.int 1)) envO' st') ∨
      (∃ envR' envO' st',
          interp actDef (fuel + 2 * m + 2 * cap.toNat + 37) raisingOuterLoop envR st =
            .ret (.lit (.int 2)) envR' st' ∧
          interp actDef (fuel + 2 * m + 2 * cap.toNat + 37) relayOuterLoop envO st =
            .ret (.lit (.int 2)) envO' st') := by
  intro m
  induction m with
  | zero =>
    intro fuel envR envO st inp invR invO hm
    rcases raising_relay_outer_step_same_post_envs actDef hwb hrb (fuel + 2 * 0)
        envR envO st pb cap inp invR invO
      with ⟨_, _, _, inp', _, _, _, _, hlt⟩ | h0 | hneg | h2
    · omega
    · exact Or.inl h0
    · exact Or.inr (Or.inl hneg)
    · exact Or.inr (Or.inr h2)
  | succ m ih =>
    intro fuel envR envO st inp invR invO hm
    rcases raising_relay_outer_step_same_post_envs actDef hwb hrb (fuel + 2 * m + 2)
        envR envO st pb cap inp invR invO
      with ⟨envR', envO', st', inp', hstepR, hstepO, invR', invO', hlt⟩ | h0 | hneg | h2
    · rw [show fuel + 2 * (m + 1) + 2 * cap.toNat + 37 = (fuel + 2 * m + 2) + 2 * cap.toNat + 37
        by omega, hstepR, hstepO,
        show fuel + 2 * m + 2 + 2 * cap.toNat + 35 = fuel + 2 * m + 2 * cap.toNat + 37
        by omega]
      exact ih fuel envR' envO' st' inp' invR' invO' (by omega)
    · rw [show fuel + 2 * (m + 1) + 2 * cap.toNat + 37 = (fuel + 2 * m + 2) + 2 * cap.toNat + 37
        by omega]
      exact Or.inl h0
    · rw [show fuel + 2 * (m + 1) + 2 * cap.toNat + 37 = (fuel + 2 * m + 2) + 2 * cap.toNat + 37
        by omega]
      exact Or.inr (Or.inl hneg)
    · rw [show fuel + 2 * (m + 1) + 2 * cap.toNat + 37 = (fuel + 2 * m + 2) + 2 * cap.toNat + 37
        by omega]
      exact Or.inr (Or.inr h2)

theorem raising_relay_outer_loop_run_same_post
    (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody) (pb : Path) (cap : Int)
    (m fuel : Nat) (env : Env) (st : St) (inp : List Int)
    (inv : OuterInv pb cap inp env st) (hm : inp.length ≤ m) :
    (∃ envR envO st',
        interp actDef (fuel + 2 * m + 2 * cap.toNat + 37) raisingOuterLoop env st =
          .ret (.lit (.int 0)) envR st' ∧
        interp actDef (fuel + 2 * m + 2 * cap.toNat + 37) relayOuterLoop env st =
          .ret (.lit (.int 0)) envO st') ∨
    (∃ envR envO st',
        interp actDef (fuel + 2 * m + 2 * cap.toNat + 37) raisingOuterLoop env st =
          .raise (.pair (.lit (.str "ReadError")) (.lit (.int (-1)))) envR st' ∧
        interp actDef (fuel + 2 * m + 2 * cap.toNat + 37) relayOuterLoop env st =
          .ret (.lit (.int 1)) envO st') ∨
    (∃ envR envO st',
        interp actDef (fuel + 2 * m + 2 * cap.toNat + 37) raisingOuterLoop env st =
          .ret (.lit (.int 2)) envR st' ∧
        interp actDef (fuel + 2 * m + 2 * cap.toNat + 37) relayOuterLoop env st =
          .ret (.lit (.int 2)) envO st') :=
  raising_relay_outer_loop_run_same_post_envs actDef hwb hrb pb cap m fuel env env st inp inv inv hm

/-- Prologue identities send both callees onto the same `relayPrologueEnv` /
    `relayPrologueState`, then the outer-loop same-post theorem. Fuel: body at
    `n+7` equals outer loop at `n+1`; choose `n = fuel + 2*|inp| + 100` so the
    loop theorem's `fuel + 2*|inp| + 101` matches. No whole-callee `h_sim`. -/
theorem raising_relay_body_same_post
    (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody) (fuel : Nat) (st : St)
    (inp rs ws dv ls : List Int) (rc wc : Int)
    (hinp : lookup st.attrs "input" = some (Val.ofIntList inp))
    (hinpb : inp.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hrs : lookup st.attrs "reads" = some (Val.ofIntList rs))
    (hrc : lookup st.attrs "read_calls" = some (.lit (.int rc)))
    (hrc0 : minInt ≤ rc) (hrcb : rc + ((inp.length : Int) + 1) ≤ maxInt)
    (hws : lookup st.attrs "writes" = some (Val.ofIntList ws))
    (hwc : lookup st.attrs "write_calls" = some (.lit (.int wc)))
    (hwc0 : minInt ≤ wc) (hwcb : wc + (inp.length : Int) ≤ maxInt)
    (hdv : lookup st.attrs "delivered" = some (Val.ofIntList dv))
    (hdvb : dv.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hls : lookup st.attrs "lost" = some (Val.ofIntList ls))
    (hlsb : ls.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true) :
    (∃ envR envO st',
        interp actDef (fuel + 2 * inp.length + 107) relayRaisingBody
          (calleeEnv (.v (.lit .unit))) st = .ret (.lit (.int 0)) envR st' ∧
        interp actDef (fuel + 2 * inp.length + 107) relayBody
          (calleeEnv (.v (.lit .unit))) st = .ret (.lit (.int 0)) envO st') ∨
    (∃ envR envO st',
        interp actDef (fuel + 2 * inp.length + 107) relayRaisingBody
          (calleeEnv (.v (.lit .unit))) st =
          .raise (.pair (.lit (.str "ReadError")) (.lit (.int (-1)))) envR st' ∧
        interp actDef (fuel + 2 * inp.length + 107) relayBody
          (calleeEnv (.v (.lit .unit))) st = .ret (.lit (.int 1)) envO st') ∨
    (∃ envR envO st',
        interp actDef (fuel + 2 * inp.length + 107) relayRaisingBody
          (calleeEnv (.v (.lit .unit))) st = .ret (.lit (.int 2)) envR st' ∧
        interp actDef (fuel + 2 * inp.length + 107) relayBody
          (calleeEnv (.v (.lit .unit))) st = .ret (.lit (.int 2)) envO st') := by
  have outerInv := raising_outerInv_prologue st inp rs ws dv ls rc wc
    hinp hinpb hrs hrc hrc0 hrcb hws hwc hwc0 hwcb hdv hdvb hls hlsb
  have hR : interp actDef (fuel + 2 * inp.length + 107) relayRaisingBody
      (calleeEnv (.v (.lit .unit))) st =
      interp actDef (fuel + 2 * inp.length + 101) raisingOuterLoop relayPrologueEnv
        (relayPrologueState st) := by
    have h := raising_prologue actDef (fuel + 2 * inp.length + 100) st
    rw [show fuel + 2 * inp.length + 100 + 7 = fuel + 2 * inp.length + 107 by omega,
      show fuel + 2 * inp.length + 100 + 1 = fuel + 2 * inp.length + 101 by omega] at h
    exact h
  have hO : interp actDef (fuel + 2 * inp.length + 107) relayBody
      (calleeEnv (.v (.lit .unit))) st =
      interp actDef (fuel + 2 * inp.length + 101) relayOuterLoop relayPrologueEnv
        (relayPrologueState st) := by
    have h := relay_prologue actDef (fuel + 2 * inp.length + 100) st
    rw [show fuel + 2 * inp.length + 100 + 7 = fuel + 2 * inp.length + 107 by omega,
      show fuel + 2 * inp.length + 100 + 1 = fuel + 2 * inp.length + 101 by omega] at h
    exact h
  rcases raising_relay_outer_loop_run_same_post actDef hwb hrb blockPath 32
      inp.length fuel relayPrologueEnv (relayPrologueState st) inp outerInv (Nat.le_refl _)
    with h0 | hneg | h2
  · obtain ⟨envR, envO, st', hrunR, hrunO⟩ := h0
    have hrunR' : interp actDef (fuel + 2 * inp.length + 101) raisingOuterLoop
        relayPrologueEnv (relayPrologueState st) = .ret (.lit (.int 0)) envR st' := by
      rw [show (32 : Int).toNat = 32 from rfl,
        show fuel + 2 * inp.length + 2 * 32 + 37 = fuel + 2 * inp.length + 101 by omega] at hrunR
      exact hrunR
    have hrunO' : interp actDef (fuel + 2 * inp.length + 101) relayOuterLoop
        relayPrologueEnv (relayPrologueState st) = .ret (.lit (.int 0)) envO st' := by
      rw [show (32 : Int).toNat = 32 from rfl,
        show fuel + 2 * inp.length + 2 * 32 + 37 = fuel + 2 * inp.length + 101 by omega] at hrunO
      exact hrunO
    exact Or.inl ⟨envR, envO, st', by rw [hR, hrunR'], by rw [hO, hrunO']⟩
  · obtain ⟨envR, envO, st', hrunR, hrunO⟩ := hneg
    have hrunR' : interp actDef (fuel + 2 * inp.length + 101) raisingOuterLoop
        relayPrologueEnv (relayPrologueState st) =
        .raise (.pair (.lit (.str "ReadError")) (.lit (.int (-1)))) envR st' := by
      rw [show (32 : Int).toNat = 32 from rfl,
        show fuel + 2 * inp.length + 2 * 32 + 37 = fuel + 2 * inp.length + 101 by omega] at hrunR
      exact hrunR
    have hrunO' : interp actDef (fuel + 2 * inp.length + 101) relayOuterLoop
        relayPrologueEnv (relayPrologueState st) = .ret (.lit (.int 1)) envO st' := by
      rw [show (32 : Int).toNat = 32 from rfl,
        show fuel + 2 * inp.length + 2 * 32 + 37 = fuel + 2 * inp.length + 101 by omega] at hrunO
      exact hrunO
    exact Or.inr (Or.inl ⟨envR, envO, st', by rw [hR, hrunR'], by rw [hO, hrunO']⟩)
  · obtain ⟨envR, envO, st', hrunR, hrunO⟩ := h2
    have hrunR' : interp actDef (fuel + 2 * inp.length + 101) raisingOuterLoop
        relayPrologueEnv (relayPrologueState st) = .ret (.lit (.int 2)) envR st' := by
      rw [show (32 : Int).toNat = 32 from rfl,
        show fuel + 2 * inp.length + 2 * 32 + 37 = fuel + 2 * inp.length + 101 by omega] at hrunR
      exact hrunR
    have hrunO' : interp actDef (fuel + 2 * inp.length + 101) relayOuterLoop
        relayPrologueEnv (relayPrologueState st) = .ret (.lit (.int 2)) envO st' := by
      rw [show (32 : Int).toNat = 32 from rfl,
        show fuel + 2 * inp.length + 2 * 32 + 37 = fuel + 2 * inp.length + 101 by omega] at hrunO
      exact hrunO
    exact Or.inr (Or.inr ⟨envR, envO, st', by rw [hR, hrunR'], by rw [hO, hrunO']⟩)

/-- `runEntry "relay_raising"` vs `runEntry "relay"`: same post-`St`; raise
    `ReadError(-1)` ↔ ordinary continue rc=1. Uses the two prologues, not `hwrap`. -/
theorem raising_relay_runEntry_same_post
    (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody)
    (hraising : actDef "relay_raising" = relayRaisingBody)
    (hrelay : actDef "relay" = relayBody) (fuel : Nat) (st : St)
    (inp rs ws dv ls : List Int) (rc wc : Int)
    (hinp : lookup st.attrs "input" = some (Val.ofIntList inp))
    (hinpb : inp.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hrs : lookup st.attrs "reads" = some (Val.ofIntList rs))
    (hrc : lookup st.attrs "read_calls" = some (.lit (.int rc)))
    (hrc0 : minInt ≤ rc) (hrcb : rc + ((inp.length : Int) + 1) ≤ maxInt)
    (hws : lookup st.attrs "writes" = some (Val.ofIntList ws))
    (hwc : lookup st.attrs "write_calls" = some (.lit (.int wc)))
    (hwc0 : minInt ≤ wc) (hwcb : wc + (inp.length : Int) ≤ maxInt)
    (hdv : lookup st.attrs "delivered" = some (Val.ofIntList dv))
    (hdvb : dv.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hls : lookup st.attrs "lost" = some (Val.ofIntList ls))
    (hlsb : ls.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true) :
    (∃ st',
        runEntry actDef (fuel + 2 * inp.length + 108) "relay_raising" st =
          .continue (assocSet initEnv "rc" (.v (.lit (.int 0)))) st' ∧
        runEntry actDef (fuel + 2 * inp.length + 108) "relay" st =
          .continue (assocSet initEnv "rc" (.v (.lit (.int 0)))) st') ∨
    (∃ st',
        runEntry actDef (fuel + 2 * inp.length + 108) "relay_raising" st =
          .raise (.pair (.lit (.str "ReadError")) (.lit (.int (-1)))) initEnv st' ∧
        runEntry actDef (fuel + 2 * inp.length + 108) "relay" st =
          .continue (assocSet initEnv "rc" (.v (.lit (.int 1)))) st') ∨
    (∃ st',
        runEntry actDef (fuel + 2 * inp.length + 108) "relay_raising" st =
          .continue (assocSet initEnv "rc" (.v (.lit (.int 2)))) st' ∧
        runEntry actDef (fuel + 2 * inp.length + 108) "relay" st =
          .continue (assocSet initEnv "rc" (.v (.lit (.int 2)))) st') := by
  have hentryR : runEntry actDef (fuel + 2 * inp.length + 108) "relay_raising" st =
      match interp actDef (fuel + 2 * inp.length + 107) relayRaisingBody
          (calleeEnv (.v (.lit .unit))) st with
      | .ret res _ st' => .continue (assocSet initEnv "rc" (.v res)) st'
      | .raise x _ st' => .raise x initEnv st'
      | _ => .failure := by
    unfold runEntry
    rw [show fuel + 2 * inp.length + 108 = (fuel + 2 * inp.length + 107) + 1 by omega,
      interp_succ_action]
    simp only [evalExpr, hraising]
    rfl
  have hentryO : runEntry actDef (fuel + 2 * inp.length + 108) "relay" st =
      match interp actDef (fuel + 2 * inp.length + 107) relayBody
          (calleeEnv (.v (.lit .unit))) st with
      | .ret res _ st' => .continue (assocSet initEnv "rc" (.v res)) st'
      | .raise x _ st' => .raise x initEnv st'
      | _ => .failure := by
    unfold runEntry
    rw [show fuel + 2 * inp.length + 108 = (fuel + 2 * inp.length + 107) + 1 by omega,
      interp_succ_action]
    simp only [evalExpr, hrelay]
    rfl
  rcases raising_relay_body_same_post actDef hwb hrb fuel st inp rs ws dv ls rc wc
      hinp hinpb hrs hrc hrc0 hrcb hws hwc hwc0 hwcb hdv hdvb hls hlsb with h0 | hneg | h2
  · obtain ⟨_, _, st', hR, hO⟩ := h0
    exact Or.inl ⟨st', by rw [hentryR, hR], by rw [hentryO, hO]⟩
  · obtain ⟨_, _, st', hR, hO⟩ := hneg
    exact Or.inr (Or.inl ⟨st', by rw [hentryR, hR], by rw [hentryO, hO]⟩)
  · obtain ⟨_, _, st', hR, hO⟩ := h2
    exact Or.inr (Or.inr ⟨st', by rw [hentryR, hR], by rw [hentryO, hO]⟩)

/-- Catch of the raising callee restores status 1 on the same post-`St` as
    ordinary `relay` ret-1. Uses `raising_prologue` (fuel `n+7` vs `n+1`), not
    the undischarged 128 `hwrap` (whole callee = outer loop at equal fuel). -/
theorem raising_caught_body_same_post
    (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody)
    (hraising : actDef "relay_raising" = relayRaisingBody)
    (fuel : Nat) (env : Env) (st : St)
    (inp rs ws dv ls : List Int) (rc wc : Int)
    (hinp : lookup st.attrs "input" = some (Val.ofIntList inp))
    (hinpb : inp.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hrs : lookup st.attrs "reads" = some (Val.ofIntList rs))
    (hrc : lookup st.attrs "read_calls" = some (.lit (.int rc)))
    (hrc0 : minInt ≤ rc) (hrcb : rc + ((inp.length : Int) + 1) ≤ maxInt)
    (hws : lookup st.attrs "writes" = some (Val.ofIntList ws))
    (hwc : lookup st.attrs "write_calls" = some (.lit (.int wc)))
    (hwc0 : minInt ≤ wc) (hwcb : wc + (inp.length : Int) ≤ maxInt)
    (hdv : lookup st.attrs "delivered" = some (Val.ofIntList dv))
    (hdvb : dv.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hls : lookup st.attrs "lost" = some (Val.ofIntList ls))
    (hlsb : ls.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true) :
    (∃ envC envO st',
        interp actDef (fuel + 2 * inp.length + 111) relayCaughtBody env st =
          .ret (.lit (.int 0)) envC st' ∧
        interp actDef (fuel + 2 * inp.length + 107) relayBody
          (calleeEnv (.v (.lit .unit))) st = .ret (.lit (.int 0)) envO st') ∨
    (∃ envC envO st',
        interp actDef (fuel + 2 * inp.length + 111) relayCaughtBody env st =
          .ret (.lit (.int 1)) envC st' ∧
        interp actDef (fuel + 2 * inp.length + 107) relayBody
          (calleeEnv (.v (.lit .unit))) st = .ret (.lit (.int 1)) envO st') ∨
    (∃ envC envO st',
        interp actDef (fuel + 2 * inp.length + 111) relayCaughtBody env st =
          .ret (.lit (.int 2)) envC st' ∧
        interp actDef (fuel + 2 * inp.length + 107) relayBody
          (calleeEnv (.v (.lit .unit))) st = .ret (.lit (.int 2)) envO st') := by
  rcases raising_relay_body_same_post actDef hwb hrb fuel st inp rs ws dv ls rc wc
      hinp hinpb hrs hrc hrc0 hrcb hws hwc hwc0 hwcb hdv hdvb hls hlsb with h0 | hneg | h2
  · obtain ⟨envR, envO, st', hR, hO⟩ := h0
    have hcall : interp actDef (fuel + 2 * inp.length + 107) (actDef "relay_raising")
        (calleeEnv (.v (.lit .unit))) st = .ret (.lit (.int 0)) envR st' := by
      rw [hraising, hR]
    have hc := relay_caught_of_ret actDef (fuel + 2 * inp.length + 107) env envR st st'
      (.lit (.int 0)) hcall
    exact Or.inl ⟨_, envO, st', by
      rw [show fuel + 2 * inp.length + 111 = (fuel + 2 * inp.length + 107) + 4 by omega]
      exact hc, hO⟩
  · obtain ⟨envR, envO, st', hR, hO⟩ := hneg
    have hcall : interp actDef (fuel + 2 * inp.length + 107) (actDef "relay_raising")
        (calleeEnv (.v (.lit .unit))) st =
        .raise (.pair (.lit (.str "ReadError")) (.lit (.int (-1)))) envR st' := by
      rw [hraising, hR]
    have hc := relay_caught_of_readError actDef (fuel + 2 * inp.length + 107) env envR st st'
      (.lit (.int (-1))) hcall
    exact Or.inr (Or.inl ⟨_, envO, st', by
      rw [show fuel + 2 * inp.length + 111 = (fuel + 2 * inp.length + 107) + 4 by omega]
      exact hc, hO⟩)
  · obtain ⟨envR, envO, st', hR, hO⟩ := h2
    have hcall : interp actDef (fuel + 2 * inp.length + 107) (actDef "relay_raising")
        (calleeEnv (.v (.lit .unit))) st = .ret (.lit (.int 2)) envR st' := by
      rw [hraising, hR]
    have hc := relay_caught_of_ret actDef (fuel + 2 * inp.length + 107) env envR st st'
      (.lit (.int 2)) hcall
    exact Or.inr (Or.inr ⟨_, envO, st', by
      rw [show fuel + 2 * inp.length + 111 = (fuel + 2 * inp.length + 107) + 4 by omega]
      exact hc, hO⟩)

/-- `runEntry "relay_caught"` vs `runEntry "relay"`: same post-`St` and status
    0/1/2 (catch maps the raising `ReadError` arm to continue rc=1). -/
theorem raising_caught_runEntry_same_post
    (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody)
    (hraising : actDef "relay_raising" = relayRaisingBody)
    (hcaught : actDef "relay_caught" = relayCaughtBody)
    (hrelay : actDef "relay" = relayBody) (fuel : Nat) (st : St)
    (inp rs ws dv ls : List Int) (rc wc : Int)
    (hinp : lookup st.attrs "input" = some (Val.ofIntList inp))
    (hinpb : inp.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hrs : lookup st.attrs "reads" = some (Val.ofIntList rs))
    (hrc : lookup st.attrs "read_calls" = some (.lit (.int rc)))
    (hrc0 : minInt ≤ rc) (hrcb : rc + ((inp.length : Int) + 1) ≤ maxInt)
    (hws : lookup st.attrs "writes" = some (Val.ofIntList ws))
    (hwc : lookup st.attrs "write_calls" = some (.lit (.int wc)))
    (hwc0 : minInt ≤ wc) (hwcb : wc + (inp.length : Int) ≤ maxInt)
    (hdv : lookup st.attrs "delivered" = some (Val.ofIntList dv))
    (hdvb : dv.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hls : lookup st.attrs "lost" = some (Val.ofIntList ls))
    (hlsb : ls.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true) :
    (∃ st',
        runEntry actDef (fuel + 2 * inp.length + 112) "relay_caught" st =
          .continue (assocSet initEnv "rc" (.v (.lit (.int 0)))) st' ∧
        runEntry actDef (fuel + 2 * inp.length + 108) "relay" st =
          .continue (assocSet initEnv "rc" (.v (.lit (.int 0)))) st') ∨
    (∃ st',
        runEntry actDef (fuel + 2 * inp.length + 112) "relay_caught" st =
          .continue (assocSet initEnv "rc" (.v (.lit (.int 1)))) st' ∧
        runEntry actDef (fuel + 2 * inp.length + 108) "relay" st =
          .continue (assocSet initEnv "rc" (.v (.lit (.int 1)))) st') ∨
    (∃ st',
        runEntry actDef (fuel + 2 * inp.length + 112) "relay_caught" st =
          .continue (assocSet initEnv "rc" (.v (.lit (.int 2)))) st' ∧
        runEntry actDef (fuel + 2 * inp.length + 108) "relay" st =
          .continue (assocSet initEnv "rc" (.v (.lit (.int 2)))) st') := by
  have hentryC : runEntry actDef (fuel + 2 * inp.length + 112) "relay_caught" st =
      match interp actDef (fuel + 2 * inp.length + 111) relayCaughtBody
          (calleeEnv (.v (.lit .unit))) st with
      | .ret res _ st' => .continue (assocSet initEnv "rc" (.v res)) st'
      | .raise x _ st' => .raise x initEnv st'
      | _ => .failure := by
    unfold runEntry
    rw [show fuel + 2 * inp.length + 112 = (fuel + 2 * inp.length + 111) + 1 by omega,
      interp_succ_action]
    simp only [evalExpr, hcaught]
    rfl
  have hentryO : runEntry actDef (fuel + 2 * inp.length + 108) "relay" st =
      match interp actDef (fuel + 2 * inp.length + 107) relayBody
          (calleeEnv (.v (.lit .unit))) st with
      | .ret res _ st' => .continue (assocSet initEnv "rc" (.v res)) st'
      | .raise x _ st' => .raise x initEnv st'
      | _ => .failure := by
    unfold runEntry
    rw [show fuel + 2 * inp.length + 108 = (fuel + 2 * inp.length + 107) + 1 by omega,
      interp_succ_action]
    simp only [evalExpr, hrelay]
    rfl
  rcases raising_caught_body_same_post actDef hwb hrb hraising fuel
      (calleeEnv (.v (.lit .unit))) st inp rs ws dv ls rc wc
      hinp hinpb hrs hrc hrc0 hrcb hws hwc hwc0 hwcb hdv hdvb hls hlsb with h0 | h1 | h2
  · obtain ⟨_, _, st', hC, hO⟩ := h0
    exact Or.inl ⟨st', by rw [hentryC, hC], by rw [hentryO, hO]⟩
  · obtain ⟨_, _, st', hC, hO⟩ := h1
    exact Or.inr (Or.inl ⟨st', by rw [hentryC, hC], by rw [hentryO, hO]⟩)
  · obtain ⟨_, _, st', hC, hO⟩ := h2
    exact Or.inr (Or.inr ⟨st', by rw [hentryC, hC], by rw [hentryO, hO]⟩)


/-- Extra fuel reproduces a successful `runEntry` (specialization of `interp_fuel_mono_le`). -/
theorem runEntry_fuel_mono_le (actDef : String → Stmt String) (f g : Nat) (a : String) (st : St)
    (hle : f ≤ g) (h : runEntry actDef f a st ≠ .failure) :
    runEntry actDef g a st = runEntry actDef f a st :=
  interp_fuel_mono_le actDef f g (.action "rc" a (.lit .unit)) initEnv st hle h

/-- `runEntry "relay_raising"` vs accepted `BufferRelay.run` / `runDetailed` on
    `compare-run`'s `initialState`: same seven root fields as
    `relay_matches_phase3_schedules`; raise `ReadError(-1)` ↔ ordinary status 1.
    Fuel is the accepted ordinary bound `fuel + 2*|inp| + 110` (143 runEntry used
    `+108`; instantiate 143 at `fuel+2`). No whole-callee `h_sim`. -/
theorem raising_matches_phase3_schedules
    (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody)
    (hraising : actDef "relay_raising" = relayRaisingBody)
    (hrelay : actDef "relay" = relayBody) (fuel : Nat) (inp : List UInt8) (rs ws : List Int)
    (hlen : (inp.length : Int) + 1 ≤ maxInt) :
    (∃ st',
        runEntry actDef (fuel + 2 * inp.length + 110) "relay_raising"
          (initialState (toInts inp) rs ws) =
          .continue (assocSet initEnv "rc" (.v (.lit (.int 0)))) st' ∧
        (BufferRelay.run inp rs ws).status = 0 ∧
        OuterExactSchedules st' ((BufferRelay.run inp rs ws).readCalls : Int)
          ((BufferRelay.run inp rs ws).writeCalls : Int)
          (toInts (BufferRelay.run inp rs ws).output)
          (toInts (BufferRelay.runDetailed inp rs ws).pending)
          (BufferRelay.run inp rs ws).remaining
          (ScheduleConsumption.executeI (fun _ => 0) inp rs ws).reads
          (ScheduleConsumption.executeI (fun _ => 0) inp rs ws).writes) ∨
    (∃ st',
        runEntry actDef (fuel + 2 * inp.length + 110) "relay_raising"
          (initialState (toInts inp) rs ws) =
          .raise (.pair (.lit (.str "ReadError")) (.lit (.int (-1)))) initEnv st' ∧
        (BufferRelay.run inp rs ws).status = 1 ∧
        OuterExactSchedules st' ((BufferRelay.run inp rs ws).readCalls : Int)
          ((BufferRelay.run inp rs ws).writeCalls : Int)
          (toInts (BufferRelay.run inp rs ws).output)
          (toInts (BufferRelay.runDetailed inp rs ws).pending)
          (BufferRelay.run inp rs ws).remaining
          (ScheduleConsumption.executeI (fun _ => 0) inp rs ws).reads
          (ScheduleConsumption.executeI (fun _ => 0) inp rs ws).writes) ∨
    (∃ st',
        runEntry actDef (fuel + 2 * inp.length + 110) "relay_raising"
          (initialState (toInts inp) rs ws) =
          .continue (assocSet initEnv "rc" (.v (.lit (.int 2)))) st' ∧
        (BufferRelay.run inp rs ws).status = 2 ∧
        OuterExactSchedules st' ((BufferRelay.run inp rs ws).readCalls : Int)
          ((BufferRelay.run inp rs ws).writeCalls : Int)
          (toInts (BufferRelay.run inp rs ws).output)
          (toInts (BufferRelay.runDetailed inp rs ws).pending)
          (BufferRelay.run inp rs ws).remaining
          (ScheduleConsumption.executeI (fun _ => 0) inp rs ws).reads
          (ScheduleConsumption.executeI (fun _ => 0) inp rs ws).writes) := by
  have hminInt : minInt ≤ (0 : Int) := by decide
  have hlenI : (toInts inp).length = inp.length := toInts_length inp
  have hlook_in : lookup (initialState (toInts inp) rs ws).attrs "input" =
      some (Val.ofIntList (toInts inp)) := by simp [initialState, lookup]
  have hlook_rs : lookup (initialState (toInts inp) rs ws).attrs "reads" =
      some (Val.ofIntList rs) := by simp [initialState, lookup]
  have hlook_rc : lookup (initialState (toInts inp) rs ws).attrs "read_calls" =
      some (.lit (.int 0)) := by simp [initialState, lookup]
  have hlook_ws : lookup (initialState (toInts inp) rs ws).attrs "writes" =
      some (Val.ofIntList ws) := by simp [initialState, lookup]
  have hlook_wc : lookup (initialState (toInts inp) rs ws).attrs "write_calls" =
      some (.lit (.int 0)) := by simp [initialState, lookup]
  have hlook_dv : lookup (initialState (toInts inp) rs ws).attrs "delivered" =
      some (Val.ofIntList []) := by simp [initialState, lookup]
  have hlook_ls : lookup (initialState (toInts inp) rs ws).attrs "lost" =
      some (Val.ofIntList []) := by simp [initialState, lookup]
  have hs := raising_relay_runEntry_same_post actDef hwb hrb hraising hrelay (fuel + 2)
      (initialState (toInts inp) rs ws) (toInts inp) rs ws [] [] 0 0
      hlook_in (toInts_bytes inp) hlook_rs hlook_rc hminInt (by
        rw [hlenI]; omega) hlook_ws hlook_wc hminInt (by
        rw [hlenI]; omega) hlook_dv rfl hlook_ls rfl
  have hf : fuel + 2 + 2 * (toInts inp).length + 108 = fuel + 2 * inp.length + 110 := by
    rw [hlenI]; omega
  simp [hf] at hs
  obtain ⟨stO, hOexact, ox⟩ :=
    relay_matches_phase3_schedules actDef hwb hrb hrelay fuel inp rs ws hlen
  have hstat : ∀ {k : Int} {st' : St},
      runEntry actDef (fuel + 2 * inp.length + 110) "relay" (initialState (toInts inp) rs ws) =
        Res.continue (assocSet initEnv "rc" (.v (.lit (.int k)))) st' →
      st' = stO ∧ (BufferRelay.run inp rs ws).status = k.toNat := by
    intro k st' hk
    have hsame := hk.symm.trans hOexact
    injection hsame with henv hst
    have hv := congrArg (fun e => lookup e "rc") henv
    simp [lookup_assocSet_same] at hv
    exact ⟨hst, by omega⟩
  rcases hs with h0 | hneg | h2
  · obtain ⟨st', hR, hO⟩ := h0
    have hs0 := (hstat hO).2
    exact Or.inl ⟨st', hR, hs0, (hstat hO).1.symm ▸ ox⟩
  · obtain ⟨st', hR, hO⟩ := hneg
    have hs1 := (hstat hO).2
    exact Or.inr (Or.inl ⟨st', hR, hs1, (hstat hO).1.symm ▸ ox⟩)
  · obtain ⟨st', hR, hO⟩ := h2
    have hs2 := (hstat hO).2
    exact Or.inr (Or.inr ⟨st', hR, hs2, (hstat hO).1.symm ▸ ox⟩)

/-- `runEntry "relay_caught"` vs `BufferRelay.run`: catch restores status 1 on the
    same seven-field post-state. Caught fuel is `+114` (try/catch + 143's `+112`
    at `fuel+2`); ordinary side is the accepted `+110`. -/
theorem raising_caught_matches_phase3_schedules
    (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody)
    (hraising : actDef "relay_raising" = relayRaisingBody)
    (hcaught : actDef "relay_caught" = relayCaughtBody)
    (hrelay : actDef "relay" = relayBody) (fuel : Nat) (inp : List UInt8) (rs ws : List Int)
    (hlen : (inp.length : Int) + 1 ≤ maxInt) :
    ∃ st',
      runEntry actDef (fuel + 2 * inp.length + 114) "relay_caught"
        (initialState (toInts inp) rs ws) =
        .continue (assocSet initEnv "rc"
          (.v (.lit (.int ((BufferRelay.run inp rs ws).status : Int))))) st' ∧
      OuterExactSchedules st' ((BufferRelay.run inp rs ws).readCalls : Int)
        ((BufferRelay.run inp rs ws).writeCalls : Int)
        (toInts (BufferRelay.run inp rs ws).output)
        (toInts (BufferRelay.runDetailed inp rs ws).pending)
        (BufferRelay.run inp rs ws).remaining
        (ScheduleConsumption.executeI (fun _ => 0) inp rs ws).reads
        (ScheduleConsumption.executeI (fun _ => 0) inp rs ws).writes := by
  have hminInt : minInt ≤ (0 : Int) := by decide
  have hlenI : (toInts inp).length = inp.length := toInts_length inp
  have hlook_in : lookup (initialState (toInts inp) rs ws).attrs "input" =
      some (Val.ofIntList (toInts inp)) := by simp [initialState, lookup]
  have hlook_rs : lookup (initialState (toInts inp) rs ws).attrs "reads" =
      some (Val.ofIntList rs) := by simp [initialState, lookup]
  have hlook_rc : lookup (initialState (toInts inp) rs ws).attrs "read_calls" =
      some (.lit (.int 0)) := by simp [initialState, lookup]
  have hlook_ws : lookup (initialState (toInts inp) rs ws).attrs "writes" =
      some (Val.ofIntList ws) := by simp [initialState, lookup]
  have hlook_wc : lookup (initialState (toInts inp) rs ws).attrs "write_calls" =
      some (.lit (.int 0)) := by simp [initialState, lookup]
  have hlook_dv : lookup (initialState (toInts inp) rs ws).attrs "delivered" =
      some (Val.ofIntList []) := by simp [initialState, lookup]
  have hlook_ls : lookup (initialState (toInts inp) rs ws).attrs "lost" =
      some (Val.ofIntList []) := by simp [initialState, lookup]
  have hs := raising_caught_runEntry_same_post actDef hwb hrb hraising hcaught hrelay (fuel + 2)
      (initialState (toInts inp) rs ws) (toInts inp) rs ws [] [] 0 0
      hlook_in (toInts_bytes inp) hlook_rs hlook_rc hminInt (by
        rw [hlenI]; omega) hlook_ws hlook_wc hminInt (by
        rw [hlenI]; omega) hlook_dv rfl hlook_ls rfl
  have hfC : fuel + 2 + 2 * (toInts inp).length + 112 = fuel + 2 * inp.length + 114 := by
    rw [hlenI]; omega
  have hfO : fuel + 2 + 2 * (toInts inp).length + 108 = fuel + 2 * inp.length + 110 := by
    rw [hlenI]; omega
  simp [hfC, hfO] at hs
  obtain ⟨stO, hOexact, ox⟩ :=
    relay_matches_phase3_schedules actDef hwb hrb hrelay fuel inp rs ws hlen
  have hstat : ∀ {k : Int} {st' : St},
      runEntry actDef (fuel + 2 * inp.length + 110) "relay" (initialState (toInts inp) rs ws) =
        Res.continue (assocSet initEnv "rc" (.v (.lit (.int k)))) st' →
      st' = stO ∧ (BufferRelay.run inp rs ws).status = k.toNat := by
    intro k st' hk
    have hsame := hk.symm.trans hOexact
    injection hsame with henv hst
    have hv := congrArg (fun e => lookup e "rc") henv
    simp [lookup_assocSet_same] at hv
    exact ⟨hst, by omega⟩
  rcases hs with h0 | h1 | h2
  · obtain ⟨st', hC, hO⟩ := h0
    have hs0 := (hstat hO).2
    refine ⟨st', ?_, (hstat hO).1.symm ▸ ox⟩
    simpa [hs0] using hC
  · obtain ⟨st', hC, hO⟩ := h1
    have hs1 := (hstat hO).2
    refine ⟨st', ?_, (hstat hO).1.symm ▸ ox⟩
    simpa [hs1] using hC
  · obtain ⟨st', hC, hO⟩ := h2
    have hs2 := (hstat hO).2
    refine ⟨st', ?_, (hstat hO).1.symm ▸ ox⟩
    simpa [hs2] using hC

end CalculusRelayRaising
