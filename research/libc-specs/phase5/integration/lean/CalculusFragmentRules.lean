import CalculusSimulation
open CalculusNested CalculusSimulation

/-!
# CalculusFragmentRules: general rules over the supported fragment, not over one export
# (calculus-correspondence-15, 2026-09-08)

Two syntactic predicates and two general theorems, each quantified over EVERY `Stmt` in the
predicate (structural induction / fuel induction), so that they apply to any export the parser
accepts, not only to the three bodies proved individually.

* `Stmt.Pure`: the sub-fragment with no state writer (`setAttr`/`addElem`/`removeElem`) and no
  `action` (whose callee could write). `interp_pure_state`: a pure statement NEVER changes the
  state — whatever it returns (`continue`/`raise`/`ret`), the state component is the input
  state; `.failure` carries no state. This is preservation of the WHOLE state, for every
  environment and fuel.
* `Stmt.Supported`: exactly the constructors `CalculusNested.Stmt` has — i.e. the parser's
  image (`parseStmt` fails closed on `match`/`foreach`/`forelem`/`localize`/`yield`, see
  `CalculusExport.parseStmt_rejects_*`). `supported_of_stmt` records that every `Stmt` value is
  in it (the type IS the fragment), so "unsupported rejection" happens at parse time, never
  inside `interp`.

What these are NOT: a type-soundness theorem (that `range:`/`range-list:`/checked-arithmetic
assertions are satisfied by well-typed programs — the body theorems' explicit hypotheses remain
the exact open obligation), nor a lowering theorem. -/

namespace CalculusFragmentRules

/-- No state writer and no action call anywhere inside. -/
def _root_.CalculusNested.Stmt.Pure {Act : Type} : Stmt Act → Prop
  | .pass => True
  | .seq a b => a.Pure ∧ b.Pure
  | .action _ _ _ => False
  | .assign _ _ => True
  | .setAttr _ _ _ => False
  | .addElem _ _ _ => False
  | .removeElem _ _ _ => False
  | .get _ _ _ => True
  | .contains _ _ _ t f => t.Pure ∧ f.Pure
  | .cond _ t e => t.Pure ∧ e.Pure
  | .while _ body => body.Pure
  | .tryCatch body _ handler => body.Pure ∧ handler.Pure
  | .tryFinally body fin => body.Pure ∧ fin.Pure
  | .raise _ => True
  | .ret _ => True

/-- The state component of a result, if any. -/
def _root_.CalculusNested.Res.state? : Res → Option St
  | .continue _ st => some st
  | .raise _ _ st => some st
  | .ret _ _ st => some st
  | .failure => none

/-- Whole-state preservation for the pure sub-fragment: for every fuel, environment and state,
    a pure statement's result carries the input state (or is `.failure`). -/
theorem interp_pure_state {Act : Type} (actDef : Act → Stmt Act) :
    ∀ (f : Nat) (s : Stmt Act) (env : Env) (st : St), s.Pure →
      ∀ st', (interp actDef f s env st).state? = some st' → st' = st := by
  intro f
  induction f with
  | zero => intro s env st _ st' h; simp [interp, Res.state?] at h
  | succ f ih =>
    intro s env st hp st' h
    cases s with
    | pass => simp [interp, Res.state?] at h; exact h.symm
    | raise e =>
      simp only [interp_succ_raise] at h
      split at h <;> simp [Res.state?] at h; exact h.symm
    | ret e =>
      simp only [interp_succ_ret] at h
      split at h <;> simp [Res.state?] at h; exact h.symm
    | assign v e =>
      simp only [interp_succ_assign] at h
      split at h <;> simp [Res.state?] at h; exact h.symm
    | get v b a =>
      simp only [interp_succ_get] at h
      split at h
      · split at h <;> simp [Res.state?] at h; exact h.symm
      · simp [Res.state?] at h
    | action v a e => exact absurd hp id
    | setAttr b a e => exact absurd hp id
    | addElem b n e => exact absurd hp id
    | removeElem b n e => exact absurd hp id
    | seq a b =>
      obtain ⟨hpa, hpb⟩ := hp
      simp only [interp_succ_seq] at h
      generalize hra : interp actDef f a env st = ra at h
      cases ra with
      | «continue» e s =>
        have hs : st = s := (ih a env st hpa s (by rw [hra]; rfl)).symm
        subst hs
        exact ih b e st hpb st' h
      | raise x e s => (try dsimp only at h); simp only [Res.state?, Option.some.injEq] at h; rw [← h]; exact ih a env st hpa s (by rw [hra]; rfl)
      | ret x e s => (try dsimp only at h); simp only [Res.state?, Option.some.injEq] at h; rw [← h]; exact ih a env st hpa s (by rw [hra]; rfl)
      | failure => simp [Res.state?] at h
    | contains b n e t g =>
      obtain ⟨hpt, hpg⟩ := hp
      simp only [interp_succ_contains] at h
      split at h
      · split at h
        · exact ih t env st hpt st' h
        · exact ih g env st hpg st' h
      · simp [Res.state?] at h
    | cond c t g =>
      obtain ⟨hpt, hpg⟩ := hp
      simp only [interp_succ_cond] at h
      split at h
      · exact ih t env st hpt st' h
      · exact ih g env st hpg st' h
      · simp [Res.state?] at h
    | «while» c body =>
      simp only [interp_succ_while] at h
      split at h
      · simp [Res.state?] at h; exact h.symm
      · exact ih (.seq body (.while c body)) env st ⟨hp, hp⟩ st' h
      · simp [Res.state?] at h
    | tryCatch body v handler =>
      obtain ⟨hpb, hph⟩ := hp
      simp only [interp_succ_tryCatch] at h
      generalize hrb : interp actDef f body env st = rb at h
      cases rb with
      | «continue» e s => (try dsimp only at h); simp only [Res.state?, Option.some.injEq] at h; rw [← h]; exact ih body env st hpb s (by rw [hrb]; rfl)
      | raise x e s =>
        have hs : st = s := (ih body env st hpb s (by rw [hrb]; rfl)).symm
        subst hs
        exact ih handler (assocSet e v (.v x)) st hph st' h
      | ret x e s => (try dsimp only at h); simp only [Res.state?, Option.some.injEq] at h; rw [← h]; exact ih body env st hpb s (by rw [hrb]; rfl)
      | failure => simp [Res.state?] at h
    | tryFinally body fin =>
      obtain ⟨hpb, hpf⟩ := hp
      simp only [interp_succ_tryFinally] at h
      generalize hrb : interp actDef f body env st = rb at h
      cases rb with
      | «continue» e s =>
        have hs : st = s := (ih body env st hpb s (by rw [hrb]; rfl)).symm
        subst hs
        exact ih fin e st hpf st' h
      | raise x e s =>
        have hs : st = s := (ih body env st hpb s (by rw [hrb]; rfl)).symm
        subst hs
        (try dsimp only at h)
        cases hrf : interp actDef f fin e st with
        | «continue» e2 s2 => rw [hrf] at h; (try dsimp only at h); simp only [Res.state?, Option.some.injEq] at h; rw [← h]; exact ih fin e st hpf s2 (by rw [hrf]; rfl)
        | raise y e2 s2 => rw [hrf] at h; (try dsimp only at h); simp only [Res.state?, Option.some.injEq] at h; rw [← h]; exact ih fin e st hpf s2 (by rw [hrf]; rfl)
        | ret y e2 s2 => rw [hrf] at h; (try dsimp only at h); simp only [Res.state?, Option.some.injEq] at h; rw [← h]; exact ih fin e st hpf s2 (by rw [hrf]; rfl)
        | failure => rw [hrf] at h; simp [Res.state?] at h
      | ret x e s =>
        have hs : st = s := (ih body env st hpb s (by rw [hrb]; rfl)).symm
        subst hs
        (try dsimp only at h)
        cases hrf : interp actDef f fin e st with
        | «continue» e2 s2 => rw [hrf] at h; (try dsimp only at h); simp only [Res.state?, Option.some.injEq] at h; rw [← h]; exact ih fin e st hpf s2 (by rw [hrf]; rfl)
        | raise y e2 s2 => rw [hrf] at h; (try dsimp only at h); simp only [Res.state?, Option.some.injEq] at h; rw [← h]; exact ih fin e st hpf s2 (by rw [hrf]; rfl)
        | ret y e2 s2 => rw [hrf] at h; (try dsimp only at h); simp only [Res.state?, Option.some.injEq] at h; rw [← h]; exact ih fin e st hpf s2 (by rw [hrf]; rfl)
        | failure => rw [hrf] at h; simp [Res.state?] at h
      | failure => simp [Res.state?] at h

/-- The supported fragment is the datatype itself: every constructor the parser can produce. -/
def _root_.CalculusNested.Stmt.Supported {Act : Type} : Stmt Act → Prop := fun _ => True
theorem supported_of_stmt {Act : Type} (s : Stmt Act) : s.Supported := trivial

end CalculusFragmentRules
