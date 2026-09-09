/-
CalculusTryCatch.lean (calculus-guards-79, 2026-09-08)

The exported `relay_caught` body — the one `try/catch` in the fixture — as a functional theorem
over an ABSTRACT result of its callee `relay_raising`. `relayCaughtBody` (generated from the
export in -61, lowered from the machine-produced AST in -75) is

    try { s := relay_raising(); return s }
    catch ReadError(code) { return 1 }

lowered to `tryCatch (seq (seq (action $t25 relay_raising ()) (assign s $t25)) (ret s)) $t26
(cond (exc-is:ReadError $t26) (seq (assign code (snd $t26)) (ret 1)) (raise $t26))`.

The four lemmas are exhaustive over the callee's `Res` and are the first functional statements
about a real exported `try/catch` (`interp_succ_tryCatch` on a real program):
return passes through; a `ReadError` raise is caught and becomes `return 1` with `code` bound to
the payload; any OTHER raise is re-raised unchanged; failure is failure. Nothing here says what
`relay_raising` itself returns — that whole-body theorem (the `relay` machinery with `raise`
instead of `return 1`) remains open and is stated in NEXT.
-/
import CalculusLowering
open CalculusNested CalculusBody CalculusSimulation CalculusLowering

set_option linter.unusedSimpArgs false

namespace CalculusTryCatch

/-- `exc-is:t` on an exception value `(tag, payload)` is the tag comparison. -/
theorem funcDef_excTag (t s : String) (x : Val) :
    funcDef (.excTag t) (.pair (.lit (.str s)) x) = some (.lit (.bool (decide (s = t)))) := by
  simp [funcDef]

/-- The callee returns `v`: `relay_caught` returns `v` (state: the callee's). -/
theorem relay_caught_of_ret (actDef : String → Stmt String) (fuel : Nat) (env e : Env)
    (st s : St) (v : Val)
    (hcall : interp actDef fuel (actDef "relay_raising") (calleeEnv (.v (.lit .unit))) st =
      .ret v e s) :
    interp actDef (fuel + 4) relayCaughtBody env st =
      .ret v (assocSet (assocSet env "$t25" (.v v)) "s" (.v v)) s := by
  simp only [relayCaughtBody, interp_succ_tryCatch, interp_succ_seq, interp_succ_action,
    interp_succ_assign, interp_succ_ret, evalExpr, hcall, lookup_assocSet_same]

/-- The callee raises `ReadError(x)`: caught; `relay_caught` returns `1` with `code := x`. -/
theorem relay_caught_of_readError (actDef : String → Stmt String) (fuel : Nat) (env e : Env)
    (st s : St) (x : Val)
    (hcall : interp actDef fuel (actDef "relay_raising") (calleeEnv (.v (.lit .unit))) st =
      .raise (.pair (.lit (.str "ReadError")) x) e s) :
    interp actDef (fuel + 4) relayCaughtBody env st =
      .ret (.lit (.int 1))
        (assocSet (assocSet env "$t26" (.v (.pair (.lit (.str "ReadError")) x))) "code" (.v x)) s := by
  simp only [relayCaughtBody, interp_succ_tryCatch, interp_succ_seq, interp_succ_action,
    interp_succ_assign, interp_succ_ret, interp_succ_cond, evalExpr, hcall, lookup_assocSet_same,
    funcDef_excTag, funcDef_snd, decide_true, Option.map]

/-- The callee raises any OTHER exception: re-raised unchanged (the handler's `raise $t26`). -/
theorem relay_caught_of_other (actDef : String → Stmt String) (fuel : Nat) (env e : Env)
    (st s : St) (t : String) (x : Val) (hne : t ≠ "ReadError")
    (hcall : interp actDef fuel (actDef "relay_raising") (calleeEnv (.v (.lit .unit))) st =
      .raise (.pair (.lit (.str t)) x) e s) :
    interp actDef (fuel + 4) relayCaughtBody env st =
      .raise (.pair (.lit (.str t)) x) (assocSet env "$t26" (.v (.pair (.lit (.str t)) x))) s := by
  simp only [relayCaughtBody, interp_succ_tryCatch, interp_succ_seq, interp_succ_action,
    interp_succ_assign, interp_succ_ret, interp_succ_cond, interp_succ_raise, evalExpr, hcall,
    lookup_assocSet_same, funcDef_excTag, hne, decide_false, Option.map]

/-- The callee fails: `relay_caught` fails (`try/catch` does not catch `.failure`). -/
theorem relay_caught_of_failure (actDef : String → Stmt String) (fuel : Nat) (env : Env)
    (st : St)
    (hcall : interp actDef fuel (actDef "relay_raising") (calleeEnv (.v (.lit .unit))) st =
      .failure) :
    interp actDef (fuel + 4) relayCaughtBody env st = .failure := by
  simp only [relayCaughtBody, interp_succ_tryCatch, interp_succ_seq, interp_succ_action,
    evalExpr, hcall]

end CalculusTryCatch
