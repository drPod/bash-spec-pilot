import CalculusNested
open CalculusNested

/-!
# CalculusSimulation: one-layer `interp` equations and fuel monotonicity
# (calculus-correspondence-14, 2026-09-08)

`interp` is fuel-indexed (the OCaml recursion is unbounded through `Action`/`While`), so every
statement-level theorem so far has been stated at a specific `fuel + k`. The theorem
`interp_fuel_mono` below is the general simulation fact that makes those statements
fuel-independent in the only way that matters: a run that does NOT exhaust its fuel (result
`≠ .failure`) is reproduced exactly, same result, same environment, same state, by every
larger fuel (`interp_fuel_mono_le`). So "there exists enough fuel" statements (e.g.
`relay_inner_loop_terminates`'s `fuel + 2·(r-off) + 30`) transfer to every larger budget, and a
`.failure` at some fuel never masks a different outcome at a larger one — it can only turn into
a non-`.failure` outcome, never change one.

The `interp_succ_*` equations are `interp`'s own definition, one constructor at a time, stated
so that `simp`/`rw` can unfold exactly one layer without unfolding an abstract sub-statement
(the failure mode that made the first `relay_inner_step` attempt exceed simp's step limit).
All are `rfl`. -/

namespace CalculusSimulation

variable {Act : Type} (actDef : Act → Stmt Act)

theorem interp_succ_pass (n : Nat) (env : Env) (st : St) :
    interp actDef (n + 1) .pass env st = .continue env st := rfl
theorem interp_succ_seq (n : Nat) (a b : Stmt Act) (env : Env) (st : St) :
    interp actDef (n + 1) (.seq a b) env st =
      match interp actDef n a env st with
      | .continue e s => interp actDef n b e s
      | r => r := rfl
theorem interp_succ_raise (n : Nat) (e : Expr) (env : Env) (st : St) :
    interp actDef (n + 1) (.raise e) env st =
      match evalExpr env e with
      | some (.v x) => .raise x env st
      | _ => .failure := rfl
theorem interp_succ_ret (n : Nat) (e : Expr) (env : Env) (st : St) :
    interp actDef (n + 1) (.ret e) env st =
      match evalExpr env e with
      | some x => .ret (match x with | .v x => x | .sref _ => .lit .unit | .rpair _ _ => .lit .unit) env st
      | none => .failure := rfl
theorem interp_succ_assign (n : Nat) (v : String) (e : Expr) (env : Env) (st : St) :
    interp actDef (n + 1) (.assign v e) env st =
      match evalExpr env e with
      | some x => .continue (assocSet env v x) st
      | none => .failure := rfl
theorem interp_succ_action (n : Nat) (v : String) (a : Act) (e : Expr) (env : Env) (st : St) :
    interp actDef (n + 1) (.action v a e) env st =
      match evalExpr env e with
      | none => .failure
      | some arg =>
        match interp actDef n (actDef a) (calleeEnv arg) st with
        | .ret res _ st => .continue (assocSet env v (.v res)) st
        | .raise x _ st => .raise x env st
        | _ => .failure := rfl
theorem interp_succ_setAttr (n : Nat) (base : Expr) (attr : String) (e : Expr) (env : Env)
    (st : St) :
    interp actDef (n + 1) (.setAttr base attr e) env st =
      match evalExpr env base, evalExpr env e with
      | some (.sref p), some (.v x) =>
        match setAttrAt p st attr x with
        | some st => .continue env st
        | none => .failure
      | _, _ => .failure := rfl
theorem interp_succ_addElem (n : Nat) (base : Expr) (nm : String) (e : Expr) (env : Env)
    (st : St) :
    interp actDef (n + 1) (.addElem base nm e) env st =
      match evalExpr env base, evalExpr env e with
      | some (.sref p), some (.v x) =>
        match addElemAt p st nm x with
        | some st => .continue env st
        | none => .failure
      | _, _ => .failure := rfl
theorem interp_succ_removeElem (n : Nat) (base : Expr) (nm : String) (e : Expr) (env : Env)
    (st : St) :
    interp actDef (n + 1) (.removeElem base nm e) env st =
      match evalExpr env base, evalExpr env e with
      | some (.sref p), some (.v x) =>
        match removeElemAt p st nm x with
        | some st => .continue env st
        | none => .failure
      | _, _ => .failure := rfl
theorem interp_succ_get (n : Nat) (v : String) (base : Expr) (attr : String) (env : Env)
    (st : St) :
    interp actDef (n + 1) (.get v base attr) env st =
      match evalExpr env base with
      | some (.sref p) =>
        match getAttrAt p st attr with
        | some x => .continue (assocSet env v (.v x)) st
        | none => .failure
      | _ => .failure := rfl
theorem interp_succ_contains (n : Nat) (base : Expr) (nm : String) (e : Expr) (t f : Stmt Act)
    (env : Env) (st : St) :
    interp actDef (n + 1) (.contains base nm e t f) env st =
      match evalExpr env base, evalExpr env e with
      | some (.sref p), some (.v x) =>
        if hasElemAt p st nm x then interp actDef n t env st else interp actDef n f env st
      | _, _ => .failure := rfl
theorem interp_succ_cond (n : Nat) (c : Expr) (t e : Stmt Act) (env : Env) (st : St) :
    interp actDef (n + 1) (.cond c t e) env st =
      match evalExpr env c with
      | some (.v (.lit (.bool true))) => interp actDef n t env st
      | some (.v (.lit (.bool false))) => interp actDef n e env st
      | _ => .failure := rfl
theorem interp_succ_while (n : Nat) (c : Expr) (body : Stmt Act) (env : Env) (st : St) :
    interp actDef (n + 1) (.while c body) env st =
      match evalExpr env c with
      | some (.v (.lit (.bool false))) => .continue env st
      | some (.v (.lit (.bool true))) => interp actDef n (.seq body (.while c body)) env st
      | _ => .failure := rfl
theorem interp_succ_tryCatch (n : Nat) (body : Stmt Act) (v : String) (handler : Stmt Act)
    (env : Env) (st : St) :
    interp actDef (n + 1) (.tryCatch body v handler) env st =
      match interp actDef n body env st with
      | .raise x env st => interp actDef n handler (assocSet env v (.v x)) st
      | r => r := rfl
theorem interp_succ_tryFinally (n : Nat) (body fin : Stmt Act) (env : Env) (st : St) :
    interp actDef (n + 1) (.tryFinally body fin) env st =
      match interp actDef n body env st with
      | .continue env st => interp actDef n fin env st
      | .raise x env st =>
        match interp actDef n fin env st with
        | .continue env st => .raise x env st
        | r => r
      | .ret x env st =>
        match interp actDef n fin env st with
        | .continue env st => .ret x env st
        | r => r
      | .failure => .failure := rfl

/-- A hypothesis `h : M ≠ .failure` whose `M` reduces to `.failure` closes any goal. -/
macro "dead_case" h:ident : tactic =>
  `(tactic| exact absurd (by (try dsimp only) <;> rfl) $h)

/-- Fuel monotonicity (simulation): a run that does not exhaust its fuel is reproduced exactly
    by one more unit of fuel — every statement form, every environment and state. -/
theorem interp_fuel_mono :
    ∀ (f : Nat) (s : Stmt Act) (env : Env) (st : St),
      interp actDef f s env st ≠ .failure →
      interp actDef (f + 1) s env st = interp actDef f s env st := by
  intro f
  induction f with
  | zero => intro s env st h; exact absurd rfl h
  | succ f ih =>
    intro s env st h
    cases s with
    | pass => rfl
    | raise e => rfl
    | ret e => rfl
    | assign v e => rfl
    | setAttr b a e => rfl
    | addElem b n e => rfl
    | removeElem b n e => rfl
    | get v b a => rfl
    | seq a b =>
      simp only [interp_succ_seq] at h ⊢
      have ha : interp actDef f a env st ≠ .failure := by
        intro hfa; rw [hfa] at h; exact h rfl
      rw [ih a env st ha]
      generalize hfa : interp actDef f a env st = ra at h ha ⊢
      cases ra with
      | «continue» e s => (try dsimp only at h ⊢); exact ih b e s h
      | raise x e s => rfl
      | ret x e s => rfl
      | failure => exact absurd rfl ha
    | action v a e =>
      simp only [interp_succ_action] at h ⊢
      generalize hev : evalExpr env e = oe at h ⊢
      cases oe with
      | none => dead_case h
      | some arg =>
        (try dsimp only at h ⊢)
        have hc : interp actDef f (actDef a) (calleeEnv arg) st ≠ .failure := by
          intro hfa; rw [hfa] at h; exact h rfl
        rw [ih (actDef a) (calleeEnv arg) st hc]
    | contains b n e t g =>
      simp only [interp_succ_contains] at h ⊢
      generalize hb : evalExpr env b = ob at h ⊢
      generalize he : evalExpr env e = oe at h ⊢
      cases ob with
      | none => dead_case h
      | some rb =>
        cases rb with
        | v x => dead_case h
        | rpair ra rb => dead_case h
        | sref p =>
          cases oe with
          | none => dead_case h
          | some re =>
            cases re with
            | sref q => dead_case h
            | rpair rc rd => dead_case h
            | v y =>
              (try dsimp only at h ⊢)
              by_cases hh : hasElemAt p st n y = true
              · rw [if_pos hh] at h; rw [if_pos hh, if_pos hh]; exact ih t env st h
              · rw [if_neg hh] at h; rw [if_neg hh, if_neg hh]; exact ih g env st h
    | cond c t g =>
      simp only [interp_succ_cond] at h ⊢
      generalize hc : evalExpr env c = oc at h ⊢
      cases oc with
      | none => dead_case h
      | some rc =>
        cases rc with
        | sref p => dead_case h
        | rpair ra rb => dead_case h
        | v x =>
          cases x with
          | pair a b => dead_case h
          | lit l =>
            cases l with
            | unit => dead_case h
            | int n => dead_case h
            | str s => dead_case h
            | bool bb =>
              cases bb with
              | false => (try dsimp only at h ⊢); exact ih g env st h
              | true => (try dsimp only at h ⊢); exact ih t env st h
    | «while» c body =>
      simp only [interp_succ_while] at h ⊢
      generalize hc : evalExpr env c = oc at h ⊢
      cases oc with
      | none => dead_case h
      | some rc =>
        cases rc with
        | sref p => dead_case h
        | rpair ra rb => dead_case h
        | v x =>
          cases x with
          | pair a b => dead_case h
          | lit l =>
            cases l with
            | unit => dead_case h
            | int n => dead_case h
            | str s => dead_case h
            | bool bb =>
              cases bb with
              | false => rfl
              | true => (try dsimp only at h ⊢); exact ih (.seq body (.while c body)) env st h
    | tryCatch body v handler =>
      simp only [interp_succ_tryCatch] at h ⊢
      have hb : interp actDef f body env st ≠ .failure := by
        intro hfa; rw [hfa] at h; exact h rfl
      rw [ih body env st hb]
      generalize hfa : interp actDef f body env st = rb at h hb ⊢
      cases rb with
      | «continue» e s => rfl
      | raise x e s => (try dsimp only at h ⊢); exact ih handler (assocSet e v (.v x)) s h
      | ret x e s => rfl
      | failure => exact absurd rfl hb
    | tryFinally body fin =>
      simp only [interp_succ_tryFinally] at h ⊢
      have hb : interp actDef f body env st ≠ .failure := by
        intro hfa; rw [hfa] at h; exact h rfl
      rw [ih body env st hb]
      generalize hfa : interp actDef f body env st = rb at h hb ⊢
      cases rb with
      | «continue» e s => (try dsimp only at h ⊢); exact ih fin e s h
      | raise x e s =>
        (try dsimp only at h ⊢)
        have hf : interp actDef f fin e s ≠ .failure := by
          intro hff; rw [hff] at h; exact h rfl
        rw [ih fin e s hf]
      | ret x e s =>
        (try dsimp only at h ⊢)
        have hf : interp actDef f fin e s ≠ .failure := by
          intro hff; rw [hff] at h; exact h rfl
        rw [ih fin e s hf]
      | failure => exact absurd rfl hb

/-- Any larger fuel reproduces a non-failing run. -/
theorem interp_fuel_mono_le (f g : Nat) (s : Stmt Act) (env : Env) (st : St)
    (hle : f ≤ g) (h : interp actDef f s env st ≠ .failure) :
    interp actDef g s env st = interp actDef f s env st := by
  induction g with
  | zero =>
    have : f = 0 := by omega
    subst this; rfl
  | succ g ih =>
    rcases Nat.lt_or_eq_of_le hle with hlt | heq
    · have hg := ih (by omega)
      rw [interp_fuel_mono actDef g s env st (by rw [hg]; exact h), hg]
    · subst heq; rfl

end CalculusSimulation
