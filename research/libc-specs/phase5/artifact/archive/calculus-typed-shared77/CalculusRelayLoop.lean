import CalculusBody
import CalculusSimulation
open CalculusNested CalculusExport CalculusBody CalculusSimulation

/-!
# CalculusRelayLoop: `relay`'s inner `while` loop — invariant, progress, fuel-bounded run
# (calculus-correspondence-14, 2026-09-08)

Builds on the accepted `CalculusBody` (whole `write_block` body, `relay_inner_step`). Everything
here is about the REAL exported inner loop `relayInnerLoop` (kernel-identified with the export
through `relay_parse`), for every fuel/environment/state satisfying the explicit invariant
`InnerInv` — not about the OCaml program, and not about the OUTER `(while true ...)` loop, whose
iteration calls `read_block` (a second exported body with no whole-body theorem yet; see the
README's "Exact remaining theorem obligations").

* `relay_inner_lost`: the `w <= 0` path — `lost` is extended by the unwritten slice and the
  loop (hence `relay`) returns `2`.
* `InnerInv`: the loop invariant — `b`/`σ`/`off`/`r` bindings, a well-formed block at a
  NON-root path, well-formed root schedule/counter/byte lists, `0 ≤ off ≤ r ≤ len ≤ cap`,
  and enough headroom on `write_calls` for the remaining iterations.
* `relay_inner_step_inv`: preservation + progress — one iteration either continues the same
  loop (two fuel levels lower) in a state satisfying `InnerInv` with `off` strictly larger and
  still `≤ r`, or returns `2`.
* `relay_inner_loop_run` / `relay_inner_loop_terminates`: the fuel-bounded invariant — with
  `2 · (r - off) + 30` fuel above any base, the loop either exits with `off = r` (the block is
  fully written) and `InnerInv` still holding, or returns `2`. No `.failure`, no `.raise`: the
  invariant excludes every `write_block` precondition failure, and the fuel bound excludes
  exhaustion.
-/

namespace CalculusRelayLoop

/-- The `w <= 0` iteration of the inner loop: `lost := lost ++ bytes[off, r)`, then `return 2`.
    `hcall` is whatever the callee did (`write_block_body_neg` gives `w = -1`,
    `write_block_body_ret` gives `w = 0` when the schedule entry is `0`); the theorem only
    needs its return value and post-state. -/
theorem relay_inner_lost (actDef : String → Stmt String)
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
    ∃ env', interp actDef (fuel + 30) relayInnerLoop env st = .ret (.lit (.int 2)) env' st'' := by
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
  show interp actDef (fuel + 29 + 1) relayInnerLoop env st = _
  rw [relayInnerLoop, interp_while_true actDef (fuel + 29) env st _ relayInnerBody hc]
  unfold relayInnerBody
  simp only [iseq, iact, iasg, icnd, iget, iset, iret, hwb, hcall, evalExpr,
    lookup_assocSet_same, lookup_assocSet_other, hb, hσ, hoff, hr, hlost, hbytes, hset,
    funcDef_le, funcDef_range off 0 _ hoff0, funcDef_range r 0 _ hr0,
    funcDef_slice bs off r hbs hslice, funcDef_append ls _ hls hsl, hw, decide_true,
    Option.map_some, ne_eq, not_false_eq_true, String.reduceEq]
  rfl

/-- The inner-loop invariant. `hwc` carries the headroom `write_calls` needs for the remaining
    `r - off` iterations (each does one checked `+ 1`). -/
structure InnerInv (pb : Path) (len cap : Int) (bs : List Int) (other : String → Option Val)
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
  /-- every root attribute the loop does not write keeps its value `other a` -/
  hother : ∀ a, a ≠ "writes" → a ≠ "write_calls" → a ≠ "delivered" → a ≠ "lost" →
    getAttrAt .here st a = other a
  hdv : ∃ dv : List Int, getAttrAt .here st "delivered" = some (Val.ofIntList dv) ∧
    dv.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true
  hlost : ∃ ls : List Int, getAttrAt .here st "lost" = some (Val.ofIntList ls) ∧
    ls.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true
  h0 : 0 ≤ off
  hor : off ≤ r
  hrl : r ≤ len
  hlc : len ≤ cap
  hrmax : r ≤ 4611686018427387903

/-- Preservation and progress for one iteration. -/
theorem relay_inner_step_inv (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody) (fuel : Nat) (env : Env) (st : St)
    (pb : Path) (len cap : Int) (bs : List Int) (other : String → Option Val) (wcmax : Int)
    (off r : Int)
    (inv : InnerInv pb len cap bs other wcmax env st off r) (hor : off < r) :
    (∃ env' st' off', interp actDef (fuel + 30) relayInnerLoop env st =
        interp actDef (fuel + 28) relayInnerLoop env' st' ∧
      InnerInv pb len cap bs other wcmax env' st' off' r ∧ off < off' ∧ off' ≤ r) ∨
    (∃ env' st', interp actDef (fuel + 30) relayInnerLoop env st = .ret (.lit (.int 2)) env' st') := by
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
  -- frames through the two bookkeeping writes
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
  · -- the schedule entry is non-negative: `write_block` returns `k = min q |req|`
    obtain ⟨st3, h3⟩ := setAttrAt_isSome_of_getAttrAt .here st2 "write_calls" "delivered" _
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
    · -- positive write: progress
      have hstep := relay_inner_step actDef hwb fuel env st st1 st2 st3 pb off r len cap wc bs ws
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
    · -- zero write (`k = 0`): the lost path
      obtain ⟨e, he⟩ := write_block_body_ret actDef fuel
        (calleeEnv (.rpair (.sref pb) (.v (.pair (.lit (.int off)) (.lit (.int r))))))
        st st1 st2 st3 pb .here off r len cap wc bs ws dv _
        (by simp [calleeEnv, lookup]) (by simp [calleeEnv, lookup])
        inv.hlen inv.hcap inv.hbytes inv.hbs inv.hbslen hws hwc hdv hdvb inv.h0 (by omega)
        inv.hrl inv.hlc inv.hrmax hwc1 rfl h1 h2 hq h3
      obtain ⟨st4, h4⟩ := setAttrAt_isSome_of_getAttrAt .here st3 "delivered" "lost" _
        (Val.ofIntList (ls ++ (bs.drop off.toNat).take (r - off).toNat))
        (setAttrAt_same _ _ _ _ _ h3)
      right
      obtain ⟨env', hret⟩ := relay_inner_lost actDef hwb fuel env e st st3 st4 pb off r _ bs ls
        inv.hb inv.hσ inv.hoff inv.hr inv.h0 hor inv.hrmax he (by omega)
        (by rw [fr3 "lost" (by decide) (by decide) (by decide)]; exact hlost) hls
        (by rw [fpb3]; exact inv.hbytes) inv.hbs hrb h4
      exact ⟨env', st4, hret⟩
  · -- negative schedule entry: `write_block` returns `-1`, the lost path
    obtain ⟨e, he⟩ := write_block_body_neg actDef fuel
      (calleeEnv (.rpair (.sref pb) (.v (.pair (.lit (.int off)) (.lit (.int r))))))
      st st1 st2 pb .here off r len cap wc bs ws _
      (by simp [calleeEnv, lookup]) (by simp [calleeEnv, lookup])
      inv.hlen inv.hcap inv.hbytes inv.hbs inv.hbslen hws hwc inv.h0 (by omega)
      inv.hrl inv.hlc inv.hrmax hwc1 rfl h1 h2 (by omega)
    obtain ⟨st4, h4⟩ := setAttrAt_isSome_of_getAttrAt .here st2 "write_calls" "lost" _
      (Val.ofIntList (ls ++ (bs.drop off.toNat).take (r - off).toNat))
      (setAttrAt_same _ _ _ _ _ h2)
    right
    obtain ⟨env', hret⟩ := relay_inner_lost actDef hwb fuel env e st st2 st4 pb off r (-1) bs ls
      inv.hb inv.hσ inv.hoff inv.hr inv.h0 hor inv.hrmax he (by omega)
      (by rw [fr2 "lost" (by decide) (by decide)]; exact hlost) hls
      (by rw [fpb2]; exact inv.hbytes) inv.hbs hrb h4
    exact ⟨env', st4, hret⟩

/-- The fuel-bounded invariant: `m` bounds the remaining iterations, two fuel levels each. -/
theorem relay_inner_loop_run (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody) (pb : Path) (len cap : Int) (bs : List Int)
    (other : String → Option Val) (wcmax : Int)
    (r : Int) : ∀ (m fuel : Nat) (env : Env) (st : St) (off : Int),
    InnerInv pb len cap bs other wcmax env st off r → (r - off).toNat ≤ m →
    (∃ env' st', interp actDef (fuel + 2 * m + 30) relayInnerLoop env st = .continue env' st' ∧
      InnerInv pb len cap bs other wcmax env' st' r r) ∨
    (∃ env' st', interp actDef (fuel + 2 * m + 30) relayInnerLoop env st =
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
    rw [show fuel + 2 * 0 + 30 = (fuel + 29) + 1 by omega, relayInnerLoop,
      interp_while_false actDef (fuel + 29) env st _ relayInnerBody hc]
  | succ m ih =>
    intro fuel env st off inv hm
    by_cases hlt : off < r
    · rcases relay_inner_step_inv actDef hwb (fuel + 2 * m + 2) env st pb len cap bs other wcmax
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
      rw [show fuel + 2 * (m + 1) + 30 = (fuel + 2 * m + 31) + 1 by omega, relayInnerLoop,
        interp_while_false actDef (fuel + 2 * m + 31) env st _ relayInnerBody hc]

/-- Termination, stated directly: `r - off` iterations suffice. -/
theorem relay_inner_loop_terminates (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody) (fuel : Nat) (env : Env) (st : St)
    (pb : Path) (len cap : Int) (bs : List Int) (other : String → Option Val) (wcmax : Int)
    (off r : Int) (inv : InnerInv pb len cap bs other wcmax env st off r) :
    (∃ env' st', interp actDef (fuel + 2 * (r - off).toNat + 30) relayInnerLoop env st =
        .continue env' st' ∧ InnerInv pb len cap bs other wcmax env' st' r r) ∨
    (∃ env' st', interp actDef (fuel + 2 * (r - off).toNat + 30) relayInnerLoop env st =
      .ret (.lit (.int 2)) env' st') :=
  relay_inner_loop_run actDef hwb pb len cap bs other wcmax r (r - off).toNat fuel env st off inv
    (Nat.le_refl _)

/-- Fuel-independent form (via `interp_fuel_mono_le`): EVERY fuel at or above the bound
    `2 · (r - off) + 30` yields the same outcome — the inner loop's result is not an artifact of
    picking a particular budget. -/
theorem relay_inner_loop_terminates_any_fuel (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody) (g : Nat) (env : Env) (st : St)
    (pb : Path) (len cap : Int) (bs : List Int) (other : String → Option Val) (wcmax : Int)
    (off r : Int) (inv : InnerInv pb len cap bs other wcmax env st off r)
    (hg : 2 * (r - off).toNat + 30 ≤ g) :
    (∃ env' st', interp actDef g relayInnerLoop env st = .continue env' st' ∧
      InnerInv pb len cap bs other wcmax env' st' r r) ∨
    (∃ env' st', interp actDef g relayInnerLoop env st = .ret (.lit (.int 2)) env' st') := by
  rcases relay_inner_loop_terminates actDef hwb 0 env st pb len cap bs other wcmax off r inv
    with ⟨env', st', hrun, inv'⟩ | ⟨env', st', hrun⟩
  · left
    refine ⟨env', st', ?_, inv'⟩
    rw [interp_fuel_mono_le actDef (0 + 2 * (r - off).toNat + 30) g relayInnerLoop env st
      (by omega) (by rw [hrun]; exact Res.noConfusion), hrun]
  · right
    refine ⟨env', st', ?_⟩
    rw [interp_fuel_mono_le actDef (0 + 2 * (r - off).toNat + 30) g relayInnerLoop env st
      (by omega) (by rw [hrun]; exact Res.noConfusion), hrun]

end CalculusRelayLoop
