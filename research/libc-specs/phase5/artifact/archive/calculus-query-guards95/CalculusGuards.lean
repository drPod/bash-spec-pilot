/-
CalculusGuards.lean (calculus-correspondence-75, 2026-09-08)

What the v2 lowering's GUARDS establish when execution passes them, and — for the exported
`write_block` body — which hypotheses of the whole-body theorem `write_block_body_ret`
(`CalculusBody`) are CONSEQUENCES of those guards versus IMPORTED state invariants that no guard
checks.

The two guard forms `calculus-bytes/adapter/lower.ml` actually emits (both visible in the
exported bodies, `CalculusBody.writeBlockBody`):

* `range:lo:hi(e)` (`Func.range`), wrapped around every value bound to a declared-int sink
  (`coerce`); `funcDef` returns `none` — hence `interp` returns `.failure` — unless the value is
  an int in `[lo, hi]`.  `range-list:lo:hi` (`Func.rangeList`) is the list counterpart.
* `assert c`, lowered to `cond c pass (raise ("AssertionFailure", ()))`: continues only when `c`
  evaluates to `true`, otherwise `.raise`s with the state unchanged.

What this module does NOT claim: a general no-failure theorem. `.failure` remains reachable
through fuel exhaustion, `funcDef` traps that are NOT lowering guards (checked arithmetic, list
bounds inside `slice`/`take`/`drop`, byte-list shape checks of `append`/`slice`), and absent
attributes. Typing (`CalculusTyping.preservation`) does not exclude those either; these lemmas
say only what holds AFTER a guard has been passed.
-/
import CalculusBody
import CalculusSimulation
open CalculusNested CalculusBody CalculusSimulation

set_option linter.unusedSimpArgs false

namespace CalculusGuards

/-- `lower.ml`'s lowering of `assert c` (`lstmt`, `P.Assert`). -/
def assertStmt (c : Expr) : Stmt String :=
  .cond c .pass (.raise (.pair (.lit (.str "AssertionFailure")) (.lit .unit)))

/-- The exception value a failed assertion raises: `("AssertionFailure", ())`. -/
def assertionFailure : Val := .pair (.lit (.str "AssertionFailure")) (.lit .unit)

/-! ## A. The `range:lo:hi` guard -/

/-- On an int the guard is exactly the interval test. -/
theorem range_guard_int (lo hi n : Int) :
    funcDef (.range lo hi) (.lit (.int n)) =
      if lo ≤ n ∧ n ≤ hi then some (.lit (.int n)) else none := by
  simp [funcDef]

/-- Consequence of passing a `range:lo:hi` guard: the value WAS an int, it is returned unchanged,
    and it lies in `[lo, hi]`. -/
theorem range_guard_some (lo hi : Int) (v r : Val) (h : funcDef (.range lo hi) v = some r) :
    ∃ n, v = .lit (.int n) ∧ r = .lit (.int n) ∧ lo ≤ n ∧ n ≤ hi := by
  cases v with
  | pair a b => simp [funcDef] at h
  | lit l =>
    cases l with
    | int n =>
      by_cases hr : lo ≤ n ∧ n ≤ hi
      · rw [range_guard_int, if_pos hr] at h
        exact ⟨n, rfl, (Option.some.inj h).symm, hr.1, hr.2⟩
      · rw [range_guard_int, if_neg hr] at h
        cases h
    | unit => simp [funcDef] at h
    | bool b => simp [funcDef] at h
    | str s => simp [funcDef] at h

/-- Failing a `range:lo:hi` guard is `none`, i.e. `.failure` at the enclosing statement — never a
    silent wrap and never a raise. -/
theorem range_guard_fail (lo hi n : Int) (h : ¬ (lo ≤ n ∧ n ≤ hi)) :
    funcDef (.range lo hi) (.lit (.int n)) = none := by
  rw [range_guard_int, if_neg h]

/-- Consequence of passing a `range-list:lo:hi` guard: the value is returned unchanged, it IS an
    int list, and every element lies in `[lo, hi]`. -/
theorem rangeList_guard_some (lo hi : Int) (v r : Val) (h : funcDef (.rangeList lo hi) v = some r) :
    r = v ∧ ∃ xs, Val.asIntList? v = some xs ∧
      xs.all (fun i => decide (lo ≤ i ∧ i ≤ hi)) = true := by
  simp only [funcDef] at h
  generalize hxs : Val.asIntList? v = o at h
  cases o with
  | none => cases h
  | some xs =>
    dsimp only at h
    by_cases hall : xs.all (fun i => decide (lo ≤ i ∧ i ≤ hi)) = true
    · rw [if_pos hall] at h
      exact ⟨(Option.some.inj h).symm, xs, rfl, hall⟩
    · rw [if_neg hall] at h
      cases h

/-- The statement form the lowering emits for a declared-int sink, `x := range:lo:hi(e)`: it
    either fails or continues with `x` bound to an in-range int and the state untouched. -/
theorem assign_range_cases (actDef : String → Stmt String) (fuel : Nat) (x : String) (lo hi : Int)
    (e : Expr) (env : Env) (st : St) :
    interp actDef (fuel + 1) (.assign x (.fn (.range lo hi) e)) env st = .failure ∨
    ∃ n, lo ≤ n ∧ n ≤ hi ∧ evalExpr env e = some (.v (.lit (.int n))) ∧
      interp actDef (fuel + 1) (.assign x (.fn (.range lo hi) e)) env st =
        .continue (assocSet env x (.v (.lit (.int n)))) st := by
  rw [interp_succ_assign]
  have hev : evalExpr env (.fn (.range lo hi) e) =
      match evalExpr env e with
      | some (.v x) => (funcDef (.range lo hi) x).map RVal.v
      | _ => none := rfl
  rw [hev]
  generalize hsub : evalExpr env e = o
  cases o with
  | none => left; rfl
  | some rv =>
    cases rv with
    | sref p => left; rfl
    | rpair a b => left; rfl
    | v x =>
      dsimp only
      cases hfd : funcDef (.range lo hi) x with
      | none => left; rfl
      | some r =>
        obtain ⟨n, hx, hr, h1, h2⟩ := range_guard_some lo hi x r hfd
        right
        refine ⟨n, h1, h2, ?_, ?_⟩
        · rw [hx]
        · rw [hr]; rfl

/-! ## B. The `assert c` guard -/

/-- Exact semantics of a lowered assertion with any fuel `≥ 2`. -/
theorem assert_guard (actDef : String → Stmt String) (fuel : Nat) (c : Expr) (env : Env) (st : St) :
    interp actDef (fuel + 2) (assertStmt c) env st =
      match evalExpr env c with
      | some (.v (.lit (.bool true))) => .continue env st
      | some (.v (.lit (.bool false))) => .raise assertionFailure env st
      | _ => .failure := by
  rfl

/-- Consequence of CONTINUING past an assertion: the condition evaluated to `true`, and nothing
    else happened (same environment, same state). -/
theorem assert_guard_continue (actDef : String → Stmt String) (fuel : Nat) (c : Expr)
    (env env' : Env) (st st' : St)
    (h : interp actDef (fuel + 2) (assertStmt c) env st = .continue env' st') :
    env' = env ∧ st' = st ∧ evalExpr env c = some (.v (.lit (.bool true))) := by
  rw [assert_guard] at h
  generalize hev : evalExpr env c = o at h
  cases o with
  | none => cases h
  | some rv =>
    cases rv with
    | sref p => cases h
    | rpair a b => cases h
    | v x =>
      cases x with
      | pair a b => cases h
      | lit l =>
        cases l with
        | unit => cases h
        | int n => cases h
        | str s => cases h
        | bool b =>
          cases b with
          | false => cases h
          | true =>
            dsimp only at h
            cases h
            exact ⟨rfl, rfl, rfl⟩

/-- The concrete shape every `write_block` assertion has, `a <= b` on two int-valued variables:
    continuing past it yields the inequality itself. -/
theorem assert_le_continue (actDef : String → Stmt String) (fuel : Nat) (x y : String) (a b : Int)
    (env env' : Env) (st st' : St)
    (hx : lookup env x = some (.v (.lit (.int a)))) (hy : lookup env y = some (.v (.lit (.int b))))
    (h : interp actDef (fuel + 2) (assertStmt (.fn .le (.pair (.var x) (.var y)))) env st =
      .continue env' st') :
    a ≤ b := by
  obtain ⟨_, _, hc⟩ := assert_guard_continue actDef fuel _ env env' st st' h
  simp only [evalExpr, hx, hy, funcDef_le, Option.map, Option.some.injEq, RVal.v.injEq,
    Val.lit.injEq, Lit.bool.injEq, decide_eq_true_eq] at hc
  exact hc

/-! ## C. The exported `write_block` body: guard-derived hypotheses vs imported invariants

`writeBlockBody` (kernel-identified with the exporter's token stream, -13) begins with the
GUARD PREFIX below — two `range:0:rangeMax` sinks (`off`, `n`) and the three assertions of the
source (`off <= n`, `n <= b.len`, `l <= b.cap`) — followed by `wbRest` (the slice, the
schedule bookkeeping, the write). `write_block_guard_gate` shows that the whole-body theorem's
hypotheses

    h0 : 0 ≤ off      hnmax : n ≤ rangeMax      hon : off ≤ n      hnl : n ≤ len      hlc : len ≤ cap

are exactly what the prefix ESTABLISHES: whenever execution reaches `wbRest`, they hold; when
they do not hold, the body fails (range) or raises `AssertionFailure` (assert) with the state
unchanged, before touching anything.

The REMAINING hypotheses of `write_block_body_ret` are NOT guard consequences and stay imported:

* `hbslen : bs.length = len` — a state invariant (the block's `len` is its byte count) that no
  statement of the body checks; if violated, `slice` may trap (`.failure`) even after the guards.
* `hbs`, `hdvb` (byte-valued `bytes`/`delivered`) — enforced only by `funcDef`'s own shape checks
  (`asByteList?` inside `slice`/`take`/`append`, a trap not a guard) and by the `range-list:0:255`
  sink on `req`, which checks the SLICE, not the stored lists.
* `hwc1 : minInt ≤ wc + 1 ≤ maxInt` — checked-arithmetic headroom (trap, not guard).
* `hq : 0 ≤ wbQ ws req` — a property of the write SCHEDULE, not of the state; the `q < 0` case is
  `write_block_body_neg`.
* `h1 h2 h3` — existence of the written states (always satisfiable, `setAttrAt_isSome_of_getAttrAt`).
-/

/-- The guard prefix of the exported `write_block`, exactly as in `writeBlockBody`, with the
    continuation abstracted. -/
def wbGuardPrefix (rest : Stmt String) : Stmt String :=
  (.seq
    (.assign "b" (.fn .fst (.var "ι")))
    (.seq
      (.assign "off" (.fn (.range 0 4611686018427387903) (.fn .fst (.fn .snd (.var "ι")))))
      (.seq
        (.assign "n" (.fn (.range 0 4611686018427387903) (.fn .snd (.fn .snd (.var "ι")))))
        (.seq
          (assertStmt (.fn .le (.pair (.var "off") (.var "n"))))
          (.seq
            (.seq
              (.get "$t9" (.var "b") "len")
              (assertStmt (.fn .le (.pair (.var "n") (.var "$t9")))))
            (.seq
              (.seq
                (.get "$t10" (.var "b") "len")
                (.assign "l" (.var "$t10")))
              (.seq
                (.seq
                  (.get "$t11" (.var "b") "cap")
                  (assertStmt (.fn .le (.pair (.var "l") (.var "$t11")))))
                rest)))))))

/-- Everything after the guard prefix, read off `writeBlockBody` itself (so nothing is retyped). -/
def wbRest : Stmt String :=
  match writeBlockBody with
  | .seq _ (.seq _ (.seq _ (.seq _ (.seq _ (.seq _ (.seq _ rest)))))) => rest
  | _ => .pass

/-- The exported body IS the guard prefix followed by `wbRest` (definitional identity). -/
theorem writeBlockBody_eq_prefix : writeBlockBody = wbGuardPrefix wbRest := by
  rfl

/-- The environment at the end of the guard prefix. -/
def wbGuardEnv (env : Env) (pb : Path) (off n len cap : Int) : Env :=
  assocSet (assocSet (assocSet (assocSet (assocSet (assocSet (assocSet env
    "b" (.sref pb)) "off" (.v (.lit (.int off)))) "n" (.v (.lit (.int n))))
    "$t9" (.v (.lit (.int len)))) "$t10" (.v (.lit (.int len)))) "l" (.v (.lit (.int len))))
    "$t11" (.v (.lit (.int cap)))

/-- **The gate.** For the real call shape (`hι`) and a block whose `len`/`cap` are ints, running
    the exported `write_block` either (i) reaches `wbRest` with all five range/assert facts
    established and the state untouched, (ii) fails at a `range:` guard, or (iii) raises
    `AssertionFailure` with the state untouched. No other outcome exists. -/
theorem write_block_guard_gate (actDef : String → Stmt String) (fuel : Nat) (env : Env) (st : St)
    (pb : Path) (off n len cap : Int)
    (hι : lookup env "ι" = some (.rpair (.sref pb) (.v (.pair (.lit (.int off)) (.lit (.int n))))))
    (hlen : getAttrAt pb st "len" = some (.lit (.int len)))
    (hcap : getAttrAt pb st "cap" = some (.lit (.int cap))) :
    (0 ≤ off ∧ off ≤ n ∧ n ≤ len ∧ len ≤ cap ∧ n ≤ rangeMax ∧
      interp actDef (fuel + 10) writeBlockBody env st =
        interp actDef (fuel + 3) wbRest (wbGuardEnv env pb off n len cap) st)
    ∨ interp actDef (fuel + 10) writeBlockBody env st = .failure
    ∨ ∃ env', interp actDef (fuel + 10) writeBlockBody env st = .raise assertionFailure env' st := by
  rw [writeBlockBody_eq_prefix]
  generalize wbRest = R
  by_cases hoff : 0 ≤ off ∧ off ≤ 4611686018427387903
  · by_cases hn : 0 ≤ n ∧ n ≤ 4611686018427387903
    · by_cases hon : off ≤ n
      · by_cases hnl : n ≤ len
        · by_cases hlc : len ≤ cap
          · left
            refine ⟨hoff.1, hon, hnl, hlc, hn.2, ?_⟩
            simp only [wbGuardPrefix, assertStmt, wbGuardEnv, interp_succ_seq, interp_succ_assign,
              interp_succ_cond, interp_succ_pass, interp_succ_get, evalExpr, hι, hlen, hcap,
              funcDef_fst, funcDef_snd, funcDef_le, range_guard_int, if_pos hoff, if_pos hn,
              Option.map, lookup_assocSet_same, lookup_assocSet_other, ne_eq, not_false_eq_true,
              String.reduceEq, hon, hnl, hlc, decide_true]
          · right; right
            refine ⟨wbGuardEnv env pb off n len cap, ?_⟩
            simp only [wbGuardPrefix, assertStmt, assertionFailure, wbGuardEnv, interp_succ_seq,
              interp_succ_assign, interp_succ_cond, interp_succ_pass, interp_succ_get,
              interp_succ_raise, evalExpr, hι, hlen, hcap,
              funcDef_fst, funcDef_snd, funcDef_le, range_guard_int, if_pos hoff, if_pos hn,
              Option.map, lookup_assocSet_same, lookup_assocSet_other, ne_eq, not_false_eq_true,
              String.reduceEq, hon, hnl, hlc, decide_true, decide_false]
        · right; right
          refine ⟨(assocSet (assocSet (assocSet (assocSet env "b" (.sref pb)) "off" (.v (.lit (.int off)))) "n" (.v (.lit (.int n)))) "$t9" (.v (.lit (.int len)))), ?_⟩
          simp only [wbGuardPrefix, assertStmt, assertionFailure, interp_succ_seq,
            interp_succ_assign, interp_succ_cond, interp_succ_pass, interp_succ_get,
            interp_succ_raise, evalExpr, hι, hlen, hcap,
            funcDef_fst, funcDef_snd, funcDef_le, range_guard_int, if_pos hoff, if_pos hn,
            Option.map, lookup_assocSet_same, lookup_assocSet_other, ne_eq, not_false_eq_true,
            String.reduceEq, hon, hnl, decide_true, decide_false]
      · right; right
        refine ⟨(assocSet (assocSet (assocSet env "b" (.sref pb)) "off" (.v (.lit (.int off)))) "n" (.v (.lit (.int n)))), ?_⟩
        simp only [wbGuardPrefix, assertStmt, assertionFailure, interp_succ_seq,
          interp_succ_assign, interp_succ_cond, interp_succ_pass, interp_succ_get,
          interp_succ_raise, evalExpr, hι,
          funcDef_fst, funcDef_snd, funcDef_le, range_guard_int, if_pos hoff, if_pos hn,
          Option.map, lookup_assocSet_same, lookup_assocSet_other, ne_eq, not_false_eq_true,
          String.reduceEq, hon, decide_false]
    · right; left
      simp only [wbGuardPrefix, interp_succ_seq, interp_succ_assign, evalExpr, hι,
        funcDef_fst, funcDef_snd, range_guard_int, if_pos hoff, if_neg hn, Option.map,
        lookup_assocSet_same, lookup_assocSet_other, ne_eq, not_false_eq_true, String.reduceEq]
  · right; left
    simp only [wbGuardPrefix, interp_succ_seq, interp_succ_assign, evalExpr, hι,
      funcDef_fst, funcDef_snd, range_guard_int, if_neg hoff, Option.map,
      lookup_assocSet_same, lookup_assocSet_other, ne_eq, not_false_eq_true, String.reduceEq]

/-- `write_block_body_ret` with its five guard-derived hypotheses REMOVED: under the imported
    state invariants alone, the body fails at a `range:` guard, raises `AssertionFailure` with
    the state untouched, or — with all five facts now DERIVED — returns exactly as
    `write_block_body_ret` says. -/
theorem write_block_guarded (actDef : String → Stmt String) (fuel : Nat) (env : Env)
    (st st1 st2 st3 : St) (pb pσ : Path) (off n len cap wc : Int) (bs ws dv req : List Int)
    (hι : lookup env "ι" = some (.rpair (.sref pb) (.v (.pair (.lit (.int off)) (.lit (.int n))))))
    (hσ : lookup env "σ" = some (.sref pσ))
    (hlen : getAttrAt pb st "len" = some (.lit (.int len)))
    (hcap : getAttrAt pb st "cap" = some (.lit (.int cap)))
    (hbytes : getAttrAt pb st "bytes" = some (Val.ofIntList bs))
    (hbs : bs.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hbslen : (bs.length : Int) = len)
    (hws : getAttrAt pσ st "writes" = some (Val.ofIntList ws))
    (hwc : getAttrAt pσ st "write_calls" = some (.lit (.int wc)))
    (hdv : getAttrAt pσ st "delivered" = some (Val.ofIntList dv))
    (hdvb : dv.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hwc1 : minInt ≤ wc + 1 ∧ wc + 1 ≤ maxInt)
    (hreq : req = (bs.drop off.toNat).take (n - off).toNat)
    (h1 : setAttrAt pσ st "writes" (Val.ofIntList ws.tail) = some st1)
    (h2 : setAttrAt pσ st1 "write_calls" (.lit (.int (wc + 1))) = some st2)
    (hq : 0 ≤ wbQ ws req)
    (h3 : setAttrAt pσ st2 "delivered"
      (Val.ofIntList (dv ++ req.take (min (wbQ ws req) (req.length : Int)).toNat)) = some st3) :
    interp actDef (fuel + 24) writeBlockBody env st = .failure
    ∨ (∃ env', interp actDef (fuel + 24) writeBlockBody env st = .raise assertionFailure env' st)
    ∨ (0 ≤ off ∧ off ≤ n ∧ n ≤ len ∧ len ≤ cap ∧ n ≤ rangeMax ∧
        ∃ env', interp actDef (fuel + 24) writeBlockBody env st =
          .ret (.lit (.int (min (wbQ ws req) (req.length : Int)))) env' st3) := by
  have hgate := write_block_guard_gate actDef (fuel + 14) env st pb off n len cap hι hlen hcap
  rw [show fuel + 14 + 10 = fuel + 24 by omega] at hgate
  rcases hgate with ⟨h0, hon, hnl, hlc, hnmax, _⟩ | hf | hr
  · right; right
    refine ⟨h0, hon, hnl, hlc, hnmax, ?_⟩
    exact write_block_body_ret actDef fuel env st st1 st2 st3 pb pσ off n len cap wc bs ws dv req
      hι hσ hlen hcap hbytes hbs hbslen hws hwc hdv hdvb h0 hon hnl hlc hnmax hwc1 hreq h1 h2 hq h3
  · left; exact hf
  · right; left; exact hr

end CalculusGuards
