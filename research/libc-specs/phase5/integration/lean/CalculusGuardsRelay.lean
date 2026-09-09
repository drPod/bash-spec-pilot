/-
CalculusGuardsRelay.lean (calculus-guards-79, 2026-09-08)

Threading the `write_block` guard facts through `relay`'s ACTUAL inner-loop invariant.

`CalculusRelayLoop.InnerInv` carries five range facts as invariant fields — `0 ≤ off`,
`off ≤ r`, `r ≤ len`, `len ≤ cap`, `r ≤ rangeMax`. `CalculusGuards.write_block_guard_gate` showed
those five are exactly what `write_block`'s own guards ESTABLISH (two `range:0:rangeMax` sinks,
three assertions), and `relay`'s call site additionally wraps both arguments in
`range:0:rangeMax`. This module makes that precise for the loop:

* `InnerInvW` is `InnerInv` with the five range facts REMOVED — only bindings, block shape, the
  byte-valued lists, counter headroom and the frame of untouched root attributes remain; i.e.
  exactly the IMPORTED state invariants no guard checks.
* `relay_inner_step_guarded`: from `InnerInvW` and the loop test `off < r`, one iteration either
  (i) has all four remaining range facts (the fifth, `off ≤ r`, is the loop test) and then
  behaves exactly as `relay_inner_step_inv` says (the full `InnerInv` is re-established), or
  (ii) is `.failure` — a `range:` guard failed, at the call site or inside `write_block` — or
  (iii) is `.raise ("AssertionFailure", ())` with the STATE UNTOUCHED: an assertion inside
  `write_block` failed before any write.  There is no fourth outcome.
* `relay_inner_loop_run_guarded`: the same trichotomy for the whole fuel-bounded loop run.

Not claimed: that the range facts always hold. In the real `relay` they do (the outer loop sets
`off := 0`, `r := read_block(...)`, and `read_block` writes `len := k ≤ cap`; `OuterInv` in
`CalculusRelayOuter` carries them), and the point here is that even WITHOUT that knowledge the
loop cannot misbehave silently: guards convert every violation into `.failure` or a raise before
the state is touched. No general no-failure claim: fuel exhaustion and the non-guard `funcDef`
traps (checked `+ 1` on `write_calls`, `off + w`; list-shape checks) remain `.failure` sources and
are exactly the imported headroom/byte-valuedness fields of `InnerInvW`.
-/
import CalculusGuards
import CalculusRelayLoop
open CalculusNested CalculusBody CalculusSimulation CalculusRelayLoop CalculusGuards

set_option linter.unusedSimpArgs false

namespace CalculusGuardsRelay

/-- `InnerInv` without its five range facts: the imported state invariants only. -/
structure InnerInvW (pb : Path) (len cap : Int) (bs : List Int) (other : String → Option Val)
    (wcmax : Int) (env : Env) (st : St) (off r : Int) : Prop where
  hb : lookup env "b" = some (.sref pb)
  hσ : lookup env "σ" = some (.sref .here)
  hoff : lookup env "off" = some (.v (.lit (.int off)))
  hr : lookup env "r" = some (.v (.lit (.int r)))
  hpb : pb ≠ .here
  hlen : getAttrAt pb st "len" = some (.lit (.int len))
  hcap : getAttrAt pb st "cap" = some (.lit (.int cap))
  hbytes : getAttrAt pb st "bytes" = some (Val.ofIntList bs)
  hbs : bs.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true
  hbslen : (bs.length : Int) = len
  hws : ∃ ws : List Int, getAttrAt .here st "writes" = some (Val.ofIntList ws)
  hwc : ∃ wc : Int, getAttrAt .here st "write_calls" = some (.lit (.int wc)) ∧
    minInt ≤ wc ∧ wc + (r - off) ≤ wcmax
  hwcmax : wcmax ≤ maxInt
  hother : ∀ a, a ≠ "writes" → a ≠ "write_calls" → a ≠ "delivered" → a ≠ "lost" →
    getAttrAt .here st a = other a
  hdv : ∃ dv : List Int, getAttrAt .here st "delivered" = some (Val.ofIntList dv) ∧
    dv.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true
  hlost : ∃ ls : List Int, getAttrAt .here st "lost" = some (Val.ofIntList ls) ∧
    ls.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true

/-- Forgetting the range facts. -/
theorem InnerInvW.ofInv {pb : Path} {len cap : Int} {bs : List Int} {other : String → Option Val}
    {wcmax : Int} {env : Env} {st : St} {off r : Int}
    (inv : InnerInv pb len cap bs other wcmax env st off r) :
    InnerInvW pb len cap bs other wcmax env st off r :=
  ⟨inv.hb, inv.hσ, inv.hoff, inv.hr, inv.hpb, inv.hlen, inv.hcap, inv.hbytes, inv.hbs, inv.hbslen,
   inv.hws, inv.hwc, inv.hwcmax, inv.hother, inv.hdv, inv.hlost⟩

/-- Re-adding the range facts (the direction the guards supply). -/
theorem InnerInv.ofW {pb : Path} {len cap : Int} {bs : List Int} {other : String → Option Val}
    {wcmax : Int} {env : Env} {st : St} {off r : Int}
    (w : InnerInvW pb len cap bs other wcmax env st off r)
    (h0 : 0 ≤ off) (hor : off ≤ r) (hrl : r ≤ len) (hlc : len ≤ cap) (hrmax : r ≤ rangeMax) :
    InnerInv pb len cap bs other wcmax env st off r :=
  ⟨w.hb, w.hσ, w.hoff, w.hr, w.hpb, w.hlen, w.hcap, w.hbytes, w.hbs, w.hbslen, w.hws, w.hwc,
   w.hwcmax, w.hother, w.hdv, w.hlost, h0, hor, hrl, hlc, hrmax⟩

/-- The `write_block` call site of `relay`'s inner loop when the callee FAILS: the loop fails
    (`interp`'s `.action` rule). -/
theorem relay_inner_call_failure (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody) (fuel : Nat) (env : Env) (st : St)
    (pb : Path) (off r : Int)
    (hb : lookup env "b" = some (.sref pb))
    (hoff : lookup env "off" = some (.v (.lit (.int off))))
    (hr : lookup env "r" = some (.v (.lit (.int r))))
    (hor : off < r)
    (hoff0 : 0 ≤ off ∧ off ≤ 4611686018427387903) (hr0 : 0 ≤ r ∧ r ≤ 4611686018427387903)
    (hcall : interp actDef (fuel + 24) writeBlockBody
      (calleeEnv (.rpair (.sref pb) (.v (.pair (.lit (.int off)) (.lit (.int r)))))) st = .failure) :
    interp actDef (fuel + 30) relayInnerLoop env st = .failure := by
  have hc : evalExpr env (.fn .lt (.pair (.var "off") (.var "r"))) =
      some (.v (.lit (.bool true))) := by
    simp only [evalExpr, hoff, hr, funcDef_lt, hor, decide_true, Option.map]
  generalize hW : writeBlockBody = W at hcall hwb
  show interp actDef (fuel + 29 + 1) relayInnerLoop env st = _
  rw [relayInnerLoop, interp_succ_while, hc]
  simp only [relayInnerBody, interp_succ_seq, interp_succ_action, evalExpr, hb, hoff, hr,
    funcDef_range off 0 _ hoff0, funcDef_range r 0 _ hr0, Option.map, hwb, hcall]

/-- The `write_block` call site when the callee RAISES: the loop raises the same value with the
    CALLER's environment and the callee's state. -/
theorem relay_inner_call_raise (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody) (fuel : Nat) (env e : Env) (st s : St)
    (pb : Path) (off r : Int) (x : Val)
    (hb : lookup env "b" = some (.sref pb))
    (hoff : lookup env "off" = some (.v (.lit (.int off))))
    (hr : lookup env "r" = some (.v (.lit (.int r))))
    (hor : off < r)
    (hoff0 : 0 ≤ off ∧ off ≤ 4611686018427387903) (hr0 : 0 ≤ r ∧ r ≤ 4611686018427387903)
    (hcall : interp actDef (fuel + 24) writeBlockBody
      (calleeEnv (.rpair (.sref pb) (.v (.pair (.lit (.int off)) (.lit (.int r)))))) st =
        .raise x e s) :
    interp actDef (fuel + 30) relayInnerLoop env st = .raise x env s := by
  have hc : evalExpr env (.fn .lt (.pair (.var "off") (.var "r"))) =
      some (.v (.lit (.bool true))) := by
    simp only [evalExpr, hoff, hr, funcDef_lt, hor, decide_true, Option.map]
  generalize hW : writeBlockBody = W at hcall hwb
  show interp actDef (fuel + 29 + 1) relayInnerLoop env st = _
  rw [relayInnerLoop, interp_succ_while, hc]
  simp only [relayInnerBody, interp_succ_seq, interp_succ_action, evalExpr, hb, hoff, hr,
    funcDef_range off 0 _ hoff0, funcDef_range r 0 _ hr0, Option.map, hwb, hcall]

/-- **One iteration, guards threaded.** From the imported invariants and the loop test only. -/
theorem relay_inner_step_guarded (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody) (fuel : Nat) (env : Env) (st : St)
    (pb : Path) (len cap : Int) (bs : List Int) (other : String → Option Val) (wcmax : Int)
    (off r : Int)
    (w : InnerInvW pb len cap bs other wcmax env st off r) (hor : off < r) :
    (0 ≤ off ∧ r ≤ len ∧ len ≤ cap ∧ r ≤ rangeMax ∧
      ((∃ env' st' off', interp actDef (fuel + 30) relayInnerLoop env st =
          interp actDef (fuel + 28) relayInnerLoop env' st' ∧
        InnerInv pb len cap bs other wcmax env' st' off' r ∧ off < off' ∧ off' ≤ r) ∨
       (∃ env' st', interp actDef (fuel + 30) relayInnerLoop env st =
          .ret (.lit (.int 2)) env' st')))
    ∨ interp actDef (fuel + 30) relayInnerLoop env st = .failure
    ∨ ∃ env', interp actDef (fuel + 30) relayInnerLoop env st = .raise assertionFailure env' st := by
  by_cases hfacts : 0 ≤ off ∧ r ≤ len ∧ len ≤ cap ∧ r ≤ rangeMax
  · left
    obtain ⟨h0, hrl, hlc, hrmax⟩ := hfacts
    exact ⟨h0, hrl, hlc, hrmax,
      relay_inner_step_inv actDef hwb fuel env st pb len cap bs other wcmax off r
        (InnerInv.ofW w h0 (Int.le_of_lt hor) hrl hlc hrmax) hor⟩
  · have hc : evalExpr env (.fn .lt (.pair (.var "off") (.var "r"))) =
        some (.v (.lit (.bool true))) := by
      simp only [evalExpr, w.hoff, w.hr, funcDef_lt, hor, decide_true, Option.map]
    by_cases hoff0 : 0 ≤ off ∧ off ≤ 4611686018427387903
    · by_cases hr0 : 0 ≤ r ∧ r ≤ 4611686018427387903
      · -- both call-site range guards pass: the callee's own gate decides
        have hgate := write_block_guard_gate actDef (fuel + 14)
          (calleeEnv (.rpair (.sref pb) (.v (.pair (.lit (.int off)) (.lit (.int r)))))) st
          pb off r len cap (by simp [calleeEnv, lookup]) w.hlen w.hcap
        rw [show fuel + 14 + 10 = fuel + 24 by omega] at hgate
        rcases hgate with ⟨h0, _, hrl, hlc, hrmax, _⟩ | hf | ⟨e', hraise⟩
        · exact absurd ⟨h0, hrl, hlc, hrmax⟩ hfacts
        · right; left
          exact relay_inner_call_failure actDef hwb fuel env st pb off r w.hb w.hoff w.hr hor
            hoff0 hr0 hf
        · right; right
          exact ⟨env, relay_inner_call_raise actDef hwb fuel env e' st st pb off r _ w.hb w.hoff
            w.hr hor hoff0 hr0 hraise⟩
      · -- the call-site `range:0:rangeMax(r)` fails: the argument does not evaluate
        right; left
        show interp actDef (fuel + 29 + 1) relayInnerLoop env st = _
        rw [relayInnerLoop, interp_succ_while, hc]
        simp only [relayInnerBody, interp_succ_seq, interp_succ_action, evalExpr, w.hb, w.hoff,
          w.hr, funcDef_range off 0 _ hoff0, range_guard_fail 0 _ r hr0, Option.map]
    · -- the call-site `range:0:rangeMax(off)` fails
      right; left
      show interp actDef (fuel + 29 + 1) relayInnerLoop env st = _
      rw [relayInnerLoop, interp_succ_while, hc]
      simp only [relayInnerBody, interp_succ_seq, interp_succ_action, evalExpr, w.hb, w.hoff,
        w.hr, range_guard_fail 0 _ off hoff0, Option.map]

/-- **The whole fuel-bounded loop run, guards threaded**: `relay_inner_loop_run`'s conclusion
    when the range facts hold at entry, else the first iteration fails or raises with the state
    untouched. -/
theorem relay_inner_loop_run_guarded (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody) (pb : Path) (len cap : Int) (bs : List Int)
    (other : String → Option Val) (wcmax : Int) (r : Int) (m fuel : Nat) (env : Env) (st : St)
    (off : Int) (w : InnerInvW pb len cap bs other wcmax env st off r) (hor : off < r)
    (hm : (r - off).toNat ≤ m) :
    (0 ≤ off ∧ r ≤ len ∧ len ≤ cap ∧ r ≤ rangeMax ∧
      ((∃ env' st', interp actDef (fuel + 2 * m + 30) relayInnerLoop env st = .continue env' st' ∧
          InnerInv pb len cap bs other wcmax env' st' r r) ∨
       (∃ env' st', interp actDef (fuel + 2 * m + 30) relayInnerLoop env st =
          .ret (.lit (.int 2)) env' st')))
    ∨ interp actDef (fuel + 2 * m + 30) relayInnerLoop env st = .failure
    ∨ ∃ env', interp actDef (fuel + 2 * m + 30) relayInnerLoop env st =
        .raise assertionFailure env' st := by
  by_cases hfacts : 0 ≤ off ∧ r ≤ len ∧ len ≤ cap ∧ r ≤ rangeMax
  · left
    obtain ⟨h0, hrl, hlc, hrmax⟩ := hfacts
    exact ⟨h0, hrl, hlc, hrmax,
      relay_inner_loop_run actDef hwb pb len cap bs other wcmax r m fuel env st off
        (InnerInv.ofW w h0 (Int.le_of_lt hor) hrl hlc hrmax) hm⟩
  · rcases relay_inner_step_guarded actDef hwb (fuel + 2 * m) env st pb len cap bs other wcmax
        off r w hor with ⟨h0, hrl, hlc, hrmax, _⟩ | hf | hraise
    · exact absurd ⟨h0, hrl, hlc, hrmax⟩ hfacts
    · right; left; exact hf
    · right; right; exact hraise

end CalculusGuardsRelay
