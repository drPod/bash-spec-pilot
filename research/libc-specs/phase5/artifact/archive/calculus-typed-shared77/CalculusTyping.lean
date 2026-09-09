import CalculusBody
import CalculusSimulation
open CalculusNested CalculusSimulation

/-!
# CalculusTyping: a type system for the supported calculus fragment, with type preservation
# over `interp` (calculus-correspondence-61, 2026-09-08 — DRAFT, written without a compiler
# turn; every proof below is to be checked when the shared compiler is granted)

This is the general typing / shape preservation obligation stated honestly:

* `Ty` / `RTy`: data types (int, bool, str, unit, scalar-literal, byte list, int list, top,
  pairs) and runtime types (data, state reference, reference-bearing pair). `VTy`/`RVTy` type
  values. `Sub` is the (small) subtyping relation the builtins need: `bytes ≤ list`, every
  literal type `≤ scalar`, everything `≤ top`, pairs covariant.
* `funcArg`/`funcRet`: one signature per `Func` (the byte-list builtins take BYTE lists where
  `funcDef` requires `asByteList?`, INT lists where it requires `asIntList?`; `range-list:lo:hi`
  produces `bytes` when `[lo,hi] ⊆ [0,255]`). `funcDef_sound`: a well-typed argument never
  yields an ill-typed result — `funcDef` may still return `none` (a RANGE or arithmetic TRAP):
  typing does not, and is not claimed to, discharge range assertions.
* `ETy` (expressions under a context `Ctx`), `STy` (statements, threading the context, with an
  attribute schema `Sch : String → Option Ty` and the current function's return type).
  Re-assignment must keep a variable's type, so contexts only grow (`STy_extends`), which is
  what lets branch/loop bodies be typed against the pre-state context.
* `preservation`: for EVERY fuel, well-typed statement, well-typed environment and well-shaped
  state (all present attributes carry their schema type at every path), the result is again
  well-typed: `.continue` with a well-typed env and well-shaped state; `.raise`/`.ret` with a
  well-shaped state and (for `.ret`) a value of the declared return type; or `.failure`.

What `preservation` does NOT say: that `.failure` is impossible. Failures arise from fuel
exhaustion, `funcDef` traps (`range:`/`range-list:`/checked arithmetic/division by zero/list
bounds), and reads of attributes or elements that are absent at the addressed path. Those are
the semantics of the program's own assertions, not type errors; they remain exactly the
explicit hypotheses of the whole-body theorems in `CalculusBody`/`CalculusRelayOuter`.

Supported scope: exactly `CalculusNested.Stmt`/`Expr`/`Func` (the parser's image); anything
the lowering rejects never reaches `interp` (see `CalculusFragmentRules.Stmt.Supported`). -/

namespace CalculusTyping

/-! ## Types -/

inductive Ty where
  | int | bool | str | unit
  /-- any literal (the argument shape `funcDef` needs for `==`/`!=`) -/
  | scalar
  /-- an int list all of whose elements are in `[0, 255]` (`Val.asByteList?` succeeds) -/
  | bytes
  /-- an int list (`Val.asIntList?` succeeds) -/
  | list
  | top
  | pair (a b : Ty)
  deriving DecidableEq, Repr

inductive RTy where
  | data (t : Ty)
  | ref
  | rpair (a b : RTy)
  deriving DecidableEq, Repr

/-- Value typing. -/
def VTy : Ty → Val → Prop
  | .int, .lit (.int _) => True
  | .int, _ => False
  | .bool, .lit (.bool _) => True
  | .bool, _ => False
  | .str, .lit (.str _) => True
  | .str, _ => False
  | .unit, .lit .unit => True
  | .unit, _ => False
  | .scalar, .lit _ => True
  | .scalar, _ => False
  | .bytes, v => (Val.asByteList? v).isSome
  | .list, v => (Val.asIntList? v).isSome
  | .top, _ => True
  | .pair a b, .pair x y => VTy a x ∧ VTy b y
  | .pair _ _, _ => False

/-- Runtime-value typing. -/
def RVTy : RTy → RVal → Prop
  | .data t, .v x => VTy t x
  | .data _, _ => False
  | .ref, .sref _ => True
  | .ref, _ => False
  | .rpair a b, .rpair x y => RVTy a x ∧ RVTy b y
  | .rpair _ _, _ => False

/-- Subtyping, exactly what the builtins need. -/
inductive Sub : Ty → Ty → Prop where
  | refl (t) : Sub t t
  | bytesList : Sub .bytes .list
  | intScalar : Sub .int .scalar
  | boolScalar : Sub .bool .scalar
  | strScalar : Sub .str .scalar
  | unitScalar : Sub .unit .scalar
  | top (t) : Sub t .top
  | pair {a a' b b'} : Sub a a' → Sub b b' → Sub (.pair a b) (.pair a' b')

theorem asIntList?_of_asByteList? (v : Val) (h : (Val.asByteList? v).isSome) :
    (Val.asIntList? v).isSome := by
  unfold Val.asByteList? at h
  generalize hl : Val.asIntList? v = ol at h ⊢
  cases ol with
  | none => simp at h
  | some ys => simp

theorem Sub_sound : ∀ {a b : Ty}, Sub a b → ∀ v, VTy a v → VTy b v := by
  intro a b h
  induction h with
  | refl t => intro v hv; exact hv
  | bytesList => intro v hv; exact asIntList?_of_asByteList? v hv
  | intScalar => intro v hv; cases v with
    | lit l => cases l <;> simp_all [VTy]
    | pair _ _ => simp [VTy] at hv
  | boolScalar => intro v hv; cases v with
    | lit l => cases l <;> simp_all [VTy]
    | pair _ _ => simp [VTy] at hv
  | strScalar => intro v hv; cases v with
    | lit l => cases l <;> simp_all [VTy]
    | pair _ _ => simp [VTy] at hv
  | unitScalar => intro v hv; cases v with
    | lit l => cases l <;> simp_all [VTy]
    | pair _ _ => simp [VTy] at hv
  | top t => intro v _; trivial
  | pair _ _ iha ihb =>
    intro v hv
    cases v with
    | lit _ => simp [VTy] at hv
    | pair x y => exact ⟨iha x hv.1, ihb y hv.2⟩

/-! ## Builtin signatures -/

/-- Argument type of each builtin (`fst`/`snd` are polymorphic and typed by their own rule). -/
def funcArg : Func → Ty
  | .add | .sub | .mul | .div | .mod | .min | .max => .pair .int .int
  | .lt | .le | .gt | .ge => .pair .int .int
  | .eq | .ne => .pair .scalar .scalar
  | .neg => .int
  | .lnot => .bool
  | .fst | .snd => .top
  | .excTag _ => .pair .str .top
  | .range _ _ => .int
  | .rangeList _ _ => .list
  | .length => .list
  | .empty => .unit
  | .single => .int
  | .append => .pair .bytes .bytes
  | .take | .drop => .pair .bytes .int
  | .slice => .pair .bytes (.pair .int .int)
  | .headOr => .pair .list .int
  | .tail => .list

def funcRet : Func → Ty
  | .add | .sub | .mul | .div | .mod | .min | .max | .neg => .int
  | .lt | .le | .gt | .ge | .eq | .ne | .lnot | .excTag _ => .bool
  | .fst | .snd => .top
  | .range _ _ => .int
  | .rangeList lo hi => if 0 ≤ lo ∧ hi ≤ 255 then .bytes else .list
  | .length => .int
  | .empty | .single | .append | .take | .drop | .slice => .bytes
  | .headOr => .int
  | .tail => .list

theorem asByteList?_ofIntList_of_all (xs : List Int)
    (h : xs.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true) :
    (Val.asByteList? (Val.ofIntList xs)).isSome := by
  simp only [Val.asByteList?, Val.asIntList?_ofIntList, h]
  rfl

theorem asIntList?_ofIntList_isSome (xs : List Int) :
    (Val.asIntList? (Val.ofIntList xs)).isSome := by
  simp [Val.asIntList?_ofIntList]

theorem bytes_of_asByteList? (v : Val) (xs : List Int) (h : Val.asByteList? v = some xs) :
    Val.asIntList? v = some xs ∧ xs.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true := by
  unfold Val.asByteList? at h
  generalize hl : Val.asIntList? v = ol at h
  cases ol with
  | none => simp at h
  | some ys =>
    dsimp only at h
    split at h
    · rename_i hall
      simp only [Option.some.injEq] at h
      subst h
      exact ⟨rfl, hall⟩
    · cases h

theorem all_sub_of_all {p : Int → Bool} (xs : List Int) (i j : Nat) (h : xs.all p = true) :
    ((xs.drop i).take j).all p = true :=
  CalculusBody.all_take_of_all _ _ (CalculusBody.all_drop_of_all _ _ h)

/-! ### Value shapes forced by a type -/

theorem VTy_int {v : Val} (h : VTy .int v) : ∃ n, v = .lit (.int n) := by
  cases v with
  | lit l => cases l with
    | int n => exact ⟨n, rfl⟩
    | unit => simp [VTy] at h
    | bool _ => simp [VTy] at h
    | str _ => simp [VTy] at h
  | pair _ _ => simp [VTy] at h
theorem VTy_bool {v : Val} (h : VTy .bool v) : ∃ b, v = .lit (.bool b) := by
  cases v with
  | lit l => cases l with
    | bool b => exact ⟨b, rfl⟩
    | unit => simp [VTy] at h
    | int _ => simp [VTy] at h
    | str _ => simp [VTy] at h
  | pair _ _ => simp [VTy] at h
theorem VTy_str {v : Val} (h : VTy .str v) : ∃ t, v = .lit (.str t) := by
  cases v with
  | lit l => cases l with
    | str t => exact ⟨t, rfl⟩
    | unit => simp [VTy] at h
    | int _ => simp [VTy] at h
    | bool _ => simp [VTy] at h
  | pair _ _ => simp [VTy] at h
theorem VTy_unit {v : Val} (h : VTy .unit v) : v = .lit .unit := by
  cases v with
  | lit l => cases l with
    | unit => rfl
    | str _ => simp [VTy] at h
    | int _ => simp [VTy] at h
    | bool _ => simp [VTy] at h
  | pair _ _ => simp [VTy] at h
theorem VTy_scalar {v : Val} (h : VTy .scalar v) : ∃ l, v = .lit l := by
  cases v with
  | lit l => exact ⟨l, rfl⟩
  | pair _ _ => simp [VTy] at h
theorem VTy_pair {a b : Ty} {v : Val} (h : VTy (.pair a b) v) :
    ∃ x y, v = .pair x y ∧ VTy a x ∧ VTy b y := by
  cases v with
  | lit _ => simp [VTy] at h
  | pair x y => exact ⟨x, y, rfl, h.1, h.2⟩
theorem VTy_bytes {v : Val} (h : VTy .bytes v) : ∃ xs, Val.asByteList? v = some xs := by
  simp only [VTy] at h
  cases hx : Val.asByteList? v with
  | none => rw [hx] at h; simp at h
  | some xs => exact ⟨xs, rfl⟩
theorem VTy_list {v : Val} (h : VTy .list v) : ∃ xs, Val.asIntList? v = some xs := by
  simp only [VTy] at h
  cases hx : Val.asIntList? v with
  | none => rw [hx] at h; simp at h
  | some xs => exact ⟨xs, rfl⟩

/-- A well-typed builtin argument never produces an ill-typed result (it may trap: `none`). -/
theorem funcDef_sound (f : Func) (v r : Val) (hv : VTy (funcArg f) v) (h : funcDef f v = some r) :
    VTy (funcRet f) r := by
  cases f with
  | add | sub | mul =>
    obtain ⟨x, y, rfl, hx, hy⟩ := VTy_pair hv
    obtain ⟨a, rfl⟩ := VTy_int hx
    obtain ⟨b, rfl⟩ := VTy_int hy
    simp only [funcDef, checked] at h
    split at h
    · simp only [Option.some.injEq] at h; subst h; simp [funcRet, VTy]
    · cases h
  | div =>
    obtain ⟨x, y, rfl, hx, hy⟩ := VTy_pair hv
    obtain ⟨a, rfl⟩ := VTy_int hx
    obtain ⟨b, rfl⟩ := VTy_int hy
    simp only [funcDef, checked] at h
    split at h
    · cases h
    · split at h
      · simp only [Option.some.injEq] at h; subst h; simp [funcRet, VTy]
      · cases h
  | mod =>
    obtain ⟨x, y, rfl, hx, hy⟩ := VTy_pair hv
    obtain ⟨a, rfl⟩ := VTy_int hx
    obtain ⟨b, rfl⟩ := VTy_int hy
    simp only [funcDef] at h
    split at h
    · cases h
    · simp only [Option.some.injEq] at h; subst h; simp [funcRet, VTy]
  | min | max | lt | le | gt | ge =>
    obtain ⟨x, y, rfl, hx, hy⟩ := VTy_pair hv
    obtain ⟨a, rfl⟩ := VTy_int hx
    obtain ⟨b, rfl⟩ := VTy_int hy
    simp only [funcDef, Option.some.injEq] at h
    subst h; simp [funcRet, VTy]
  | eq | ne =>
    obtain ⟨x, y, rfl, hx, hy⟩ := VTy_pair hv
    obtain ⟨l1, rfl⟩ := VTy_scalar hx
    obtain ⟨l2, rfl⟩ := VTy_scalar hy
    simp only [funcDef, Option.some.injEq] at h
    subst h; simp [funcRet, VTy]
  | neg =>
    obtain ⟨a, rfl⟩ := VTy_int hv
    simp only [funcDef, checked] at h
    split at h
    · simp only [Option.some.injEq] at h; subst h; simp [funcRet, VTy]
    · cases h
  | lnot =>
    obtain ⟨b, rfl⟩ := VTy_bool hv
    simp only [funcDef, Option.some.injEq] at h
    subst h; simp [funcRet, VTy]
  | fst | snd => simp [funcRet, VTy]
  | excTag t =>
    obtain ⟨x, y, rfl, hx, _⟩ := VTy_pair hv
    obtain ⟨s, rfl⟩ := VTy_str hx
    simp only [funcDef, Option.some.injEq] at h
    subst h; simp [funcRet, VTy]
  | range lo hi =>
    obtain ⟨a, rfl⟩ := VTy_int hv
    simp only [funcDef] at h
    split at h
    · simp only [Option.some.injEq] at h; subst h; simp [funcRet, VTy]
    · cases h
  | rangeList lo hi =>
    obtain ⟨xs, hxs⟩ := VTy_list hv
    simp only [funcDef, hxs] at h
    split at h
    · rename_i hall
      simp only [Option.some.injEq] at h
      subst h
      simp only [funcRet]
      split
      · rename_i hb
        have : (xs.all fun b => decide (0 ≤ b ∧ b ≤ 255)) = true := by
          rw [List.all_eq_true] at hall ⊢
          intro x hx
          have := hall x hx
          simp only [decide_eq_true_eq] at this ⊢
          omega
        simp only [VTy, Val.asByteList?, hxs]
        rw [if_pos this]
        rfl
      · simp [VTy, hxs]
    · cases h
  | length =>
    obtain ⟨xs, hxs⟩ := VTy_list hv
    simp only [funcDef, hxs, Option.map_some, Option.some.injEq] at h
    subst h; simp [funcRet, VTy]
  | empty =>
    have := VTy_unit hv; subst this
    simp only [funcDef, Option.some.injEq] at h
    subst h
    simp only [funcRet]
    exact asByteList?_ofIntList_of_all [] rfl
  | single =>
    obtain ⟨b, rfl⟩ := VTy_int hv
    simp only [funcDef] at h
    split at h
    · rename_i hb
      simp only [Option.some.injEq] at h
      subst h
      simp only [funcRet]
      exact asByteList?_ofIntList_of_all [b] (by simpa using hb)
    · cases h
  | append =>
    obtain ⟨x, y, rfl, hx, hy⟩ := VTy_pair hv
    obtain ⟨xs, hxs⟩ := VTy_bytes hx
    obtain ⟨ys, hys⟩ := VTy_bytes hy
    simp only [funcDef, hxs, hys, Option.some.injEq] at h
    subst h
    simp only [funcRet]
    apply asByteList?_ofIntList_of_all
    rw [List.all_append, (bytes_of_asByteList? _ _ hxs).2, (bytes_of_asByteList? _ _ hys).2]; rfl
  | take =>
    obtain ⟨x, y, rfl, hx, hy⟩ := VTy_pair hv
    obtain ⟨xs, hxs⟩ := VTy_bytes hx
    obtain ⟨k, rfl⟩ := VTy_int hy
    simp only [funcDef, hxs] at h
    split at h
    · simp only [Option.some.injEq] at h; subst h
      simp only [funcRet]
      exact asByteList?_ofIntList_of_all _ (CalculusBody.all_take_of_all _ _ (bytes_of_asByteList? _ _ hxs).2)
    · cases h
  | drop =>
    obtain ⟨x, y, rfl, hx, hy⟩ := VTy_pair hv
    obtain ⟨xs, hxs⟩ := VTy_bytes hx
    obtain ⟨k, rfl⟩ := VTy_int hy
    simp only [funcDef, hxs] at h
    split at h
    · simp only [Option.some.injEq] at h; subst h
      simp only [funcRet]
      exact asByteList?_ofIntList_of_all _ (CalculusBody.all_drop_of_all _ _ (bytes_of_asByteList? _ _ hxs).2)
    · cases h
  | slice =>
    obtain ⟨x, y, rfl, hx, hy⟩ := VTy_pair hv
    obtain ⟨xs, hxs⟩ := VTy_bytes hx
    obtain ⟨o, n, rfl, ho, hn⟩ := VTy_pair hy
    obtain ⟨off, rfl⟩ := VTy_int ho
    obtain ⟨k, rfl⟩ := VTy_int hn
    simp only [funcDef, hxs] at h
    split at h
    · simp only [Option.some.injEq] at h; subst h
      simp only [funcRet]
      exact asByteList?_ofIntList_of_all _ (all_sub_of_all xs _ _ (bytes_of_asByteList? _ _ hxs).2)
    · cases h
  | headOr =>
    obtain ⟨x, y, rfl, hx, hy⟩ := VTy_pair hv
    obtain ⟨xs, hxs⟩ := VTy_list hx
    obtain ⟨d, rfl⟩ := VTy_int hy
    simp only [funcDef, hxs] at h
    cases xs with
    | nil => simp only [Option.some.injEq] at h; subst h; simp [funcRet, VTy]
    | cons z zs => simp only [Option.some.injEq] at h; subst h; simp [funcRet, VTy]
  | tail =>
    obtain ⟨xs, hxs⟩ := VTy_list hv
    simp only [funcDef, hxs, Option.map_some, Option.some.injEq] at h
    subst h; simp [funcRet, VTy, Val.asIntList?_ofIntList]

/-! ## Contexts and expression typing -/

abbrev Ctx := String → Option RTy

def Ctx.set (Γ : Ctx) (x : String) (ρ : RTy) : Ctx := fun y => if y = x then some ρ else Γ y

/-- Environment typing: every context binding is present with a value of that type. -/
def GTy (Γ : Ctx) (env : Env) : Prop :=
  ∀ x ρ, Γ x = some ρ → ∃ v, lookup env x = some v ∧ RVTy ρ v

/-- The runtime type of a `pair` expression: data pair when both sides are data, otherwise a
    reference-bearing pair (exactly `evalExpr`'s two `pair` cases). -/
def pairR : RTy → RTy → RTy
  | .data a, .data b => .data (.pair a b)
  | a, b => .rpair a b

def litTy : Lit → Ty
  | .unit => .unit
  | .bool _ => .bool
  | .int _ => .int
  | .str _ => .str

inductive ETy (Γ : Ctx) : Expr → RTy → Prop where
  | lit (l) : ETy Γ (.lit l) (.data (litTy l))
  | var {x ρ} : Γ x = some ρ → ETy Γ (.var x) ρ
  | pair {a b ρa ρb} : ETy Γ a ρa → ETy Γ b ρb → ETy Γ (.pair a b) (pairR ρa ρb)
  | fst_data {e a b} : ETy Γ e (.data (.pair a b)) → ETy Γ (.fn .fst e) (.data a)
  | snd_data {e a b} : ETy Γ e (.data (.pair a b)) → ETy Γ (.fn .snd e) (.data b)
  | fst_ref {e ρa ρb} : ETy Γ e (.rpair ρa ρb) → ETy Γ (.fn .fst e) ρa
  | snd_ref {e ρa ρb} : ETy Γ e (.rpair ρa ρb) → ETy Γ (.fn .snd e) ρb
  | fn {f e τ} : f ≠ .fst → f ≠ .snd → ETy Γ e (.data τ) → Sub τ (funcArg f) →
      ETy Γ (.fn f e) (.data (funcRet f))
  | elem {base n arg τ} : ETy Γ base .ref → ETy Γ arg (.data τ) → Sub τ .scalar →
      ETy Γ (.elem base n arg) .ref
  | sub {e τ τ'} : ETy Γ e (.data τ) → Sub τ τ' → ETy Γ e (.data τ')

theorem pairR_sound {ρa ρb : RTy} {x y : RVal} (hx : RVTy ρa x) (hy : RVTy ρb y) :
    RVTy (pairR ρa ρb) (match x, y with
      | .v a, .v b => RVal.v (.pair a b)
      | ra, rb => RVal.rpair ra rb) := by
  cases ρa with
  | data a =>
    cases x with
    | v xa =>
      cases ρb with
      | data b =>
        cases y with
        | v yb => exact ⟨hx, hy⟩
        | sref _ => simp [RVTy] at hy
        | rpair _ _ => simp [RVTy] at hy
      | ref =>
        cases y with
        | v _ => simp [RVTy] at hy
        | sref _ => exact ⟨hx, hy⟩
        | rpair _ _ => simp [RVTy] at hy
      | rpair _ _ =>
        cases y with
        | v _ => simp [RVTy] at hy
        | sref _ => simp [RVTy] at hy
        | rpair _ _ => exact ⟨hx, hy⟩
    | sref _ => simp [RVTy] at hx
    | rpair _ _ => simp [RVTy] at hx
  | ref =>
    cases x with
    | v _ => simp [RVTy] at hx
    | sref _ =>
      cases ρb <;> cases y <;> first | exact ⟨hx, hy⟩ | simp [RVTy] at hy
    | rpair _ _ => simp [RVTy] at hx
  | rpair _ _ =>
    cases x with
    | v _ => simp [RVTy] at hx
    | sref _ => simp [RVTy] at hx
    | rpair _ _ =>
      cases ρb <;> cases y <;> first | exact ⟨hx, hy⟩ | simp [RVTy] at hy

/-- Expression soundness: a well-typed expression that evaluates yields a value of its type. -/
theorem ETy_sound {Γ : Ctx} {env : Env} (hΓ : GTy Γ env) :
    ∀ {e : Expr} {ρ : RTy}, ETy Γ e ρ → ∀ v, evalExpr env e = some v → RVTy ρ v := by
  intro e ρ h
  induction h with
  | lit l =>
    intro v hv
    simp only [evalExpr, Option.some.injEq] at hv
    subst hv
    cases l <;> simp [RVTy, VTy, litTy]
  | var hx =>
    intro v hv
    obtain ⟨w, hw, hwt⟩ := hΓ _ _ hx
    simp only [evalExpr] at hv
    rw [hw] at hv
    cases hv
    exact hwt
  | pair _ _ iha ihb =>
    intro v hv
    simp only [evalExpr] at hv
    cases hea : evalExpr env _ with
    | none => rw [hea] at hv; simp at hv
    | some ra =>
      rename_i a b _ _ _ _
      cases heb : evalExpr env b with
      | none => rw [hea, heb] at hv; cases ra <;> simp at hv
      | some rb =>
        rw [hea, heb] at hv
        have ha := iha ra hea
        have hb := ihb rb heb
        have := pairR_sound ha hb
        cases ra <;> cases rb <;> simp only [Option.some.injEq] at hv <;> subst hv <;> exact this
  | fst_data _ ih =>
    intro v hv
    simp only [evalExpr] at hv
    rename_i e a b _
    cases he : evalExpr env e with
    | none => rw [he] at hv; simp at hv
    | some r =>
      rw [he] at hv
      have hr := ih r he
      cases r with
      | v x =>
        cases x with
        | lit _ => simp [RVTy, VTy] at hr
        | pair xa xb =>
          simp only [funcDef, Option.map_some, Option.some.injEq] at hv
          subst hv
          exact hr.1
      | sref _ => simp [RVTy] at hr
      | rpair _ _ => simp [RVTy] at hr
  | snd_data _ ih =>
    intro v hv
    simp only [evalExpr] at hv
    rename_i e a b _
    cases he : evalExpr env e with
    | none => rw [he] at hv; simp at hv
    | some r =>
      rw [he] at hv
      have hr := ih r he
      cases r with
      | v x =>
        cases x with
        | lit _ => simp [RVTy, VTy] at hr
        | pair xa xb =>
          simp only [funcDef, Option.map_some, Option.some.injEq] at hv
          subst hv
          exact hr.2
      | sref _ => simp [RVTy] at hr
      | rpair _ _ => simp [RVTy] at hr
  | fst_ref _ ih =>
    intro v hv
    simp only [evalExpr] at hv
    rename_i e ρa ρb _
    cases he : evalExpr env e with
    | none => rw [he] at hv; simp at hv
    | some r =>
      rw [he] at hv
      have hr := ih r he
      cases r with
      | v _ => simp [RVTy] at hr
      | sref _ => simp [RVTy] at hr
      | rpair ra rb =>
        simp only [Option.some.injEq] at hv
        subst hv
        exact hr.1
  | snd_ref _ ih =>
    intro v hv
    simp only [evalExpr] at hv
    rename_i e ρa ρb _
    cases he : evalExpr env e with
    | none => rw [he] at hv; simp at hv
    | some r =>
      rw [he] at hv
      have hr := ih r he
      cases r with
      | v _ => simp [RVTy] at hr
      | sref _ => simp [RVTy] at hr
      | rpair ra rb =>
        simp only [Option.some.injEq] at hv
        subst hv
        exact hr.2
  | fn hf1 hf2 _ hsub ih =>
    intro v hv
    rename_i f e τ _
    -- `evalExpr`'s generic `.fn f e` case (f is neither fst nor snd)
    have hev : evalExpr env (.fn f e) =
        match evalExpr env e with
        | some (.v x) => (funcDef f x).map RVal.v
        | _ => none := by
      cases f <;> first | exact absurd rfl hf1 | exact absurd rfl hf2 | rfl
    rw [hev] at hv
    cases he : evalExpr env e with
    | none => rw [he] at hv; simp at hv
    | some r =>
      rw [he] at hv
      have hr := ih r he
      cases r with
      | v x =>
        change Option.map RVal.v (funcDef f x) = some v at hv
        cases hd : funcDef f x with
        | none => rw [hd] at hv; simp at hv
        | some y =>
          rw [hd] at hv
          simp only [Option.map_some, Option.some.injEq] at hv
          subst hv
          exact funcDef_sound f x y (Sub_sound hsub x hr) hd
      | sref _ => simp [RVTy] at hr
      | rpair _ _ => simp [RVTy] at hr
  | elem _ _ hsub ihb iha =>
    intro v hv
    simp only [evalExpr] at hv
    rename_i base n arg τ _ _
    cases hb : evalExpr env base with
    | none => rw [hb] at hv; simp at hv
    | some rb =>
      cases ha : evalExpr env arg with
      | none => rw [hb, ha] at hv; cases rb <;> simp at hv
      | some ra =>
        rw [hb, ha] at hv
        have hrb := ihb rb hb
        cases rb with
        | v _ => simp [RVTy] at hrb
        | rpair _ _ => simp [RVTy] at hrb
        | sref p =>
          cases ra with
          | v x => simp only [Option.some.injEq] at hv; subst hv; trivial
          | sref _ => simp at hv
          | rpair _ _ => simp at hv
  | sub _ hsub ih =>
    intro v hv
    have := ih v hv
    cases v with
    | v x => exact Sub_sound hsub x this
    | sref _ => simp [RVTy] at this
    | rpair _ _ => simp [RVTy] at this

/-! ## Statement typing -/

/-- Attribute schema: the declared type of each attribute name (the same at every path, as in
    the source language where attributes are declared globally). -/
abbrev Schema := String → Option Ty

/-- Well-shaped state: every attribute present anywhere carries its schema type. -/
def StTy (Sch : Schema) (st : St) : Prop :=
  ∀ (p : Path) (a : String) (τ : Ty) (v : Val), Sch a = some τ → getAttrAt p st a = some v → VTy τ v

/-- Action signatures: argument runtime type and return type. -/
abbrev ActSig := String → RTy × Ty

/-- Every raised value the lowering produces is `(pair "Tag" payload)`; `catch` binds it at
    this type, which is what `exc-is:Tag` (`Func.excTag`) needs. -/
def excTy : Ty := .pair .str .top

def calleeCtx (ρ : RTy) : Ctx :=
  fun x => if x = "ι" then some ρ else if x = "σ" then some .ref else none

inductive STy (Sch : Schema) (sig : ActSig) (ρret : Ty) : Ctx → Stmt String → Ctx → Prop where
  | pass {Γ} : STy Sch sig ρret Γ .pass Γ
  | seq {Γ Γ1 Γ2 a b} : STy Sch sig ρret Γ a Γ1 → STy Sch sig ρret Γ1 b Γ2 → STy Sch sig ρret Γ (.seq a b) Γ2
  | assign {Γ x e ρ} : ETy Γ e ρ → (∀ ρ0, Γ x = some ρ0 → ρ0 = ρ) →
      STy Sch sig ρret Γ (.assign x e) (Γ.set x ρ)
  | action {Γ v a e} : ETy Γ e (sig a).1 → (∀ ρ0, Γ v = some ρ0 → ρ0 = .data (sig a).2) →
      STy Sch sig ρret Γ (.action v a e) (Γ.set v (.data (sig a).2))
  | setAttr {Γ b a e τ} : ETy Γ b .ref → Sch a = some τ → ETy Γ e (.data τ) →
      STy Sch sig ρret Γ (.setAttr b a e) Γ
  | addElem {Γ b n e τ} : ETy Γ b .ref → ETy Γ e (.data τ) → Sub τ .scalar →
      STy Sch sig ρret Γ (.addElem b n e) Γ
  | removeElem {Γ b n e τ} : ETy Γ b .ref → ETy Γ e (.data τ) → Sub τ .scalar →
      STy Sch sig ρret Γ (.removeElem b n e) Γ
  | get {Γ x b a τ} : ETy Γ b .ref → Sch a = some τ → (∀ ρ0, Γ x = some ρ0 → ρ0 = .data τ) →
      STy Sch sig ρret Γ (.get x b a) (Γ.set x (.data τ))
  | contains {Γ b n e τ t f Γt Γf} : ETy Γ b .ref → ETy Γ e (.data τ) → Sub τ .scalar →
      STy Sch sig ρret Γ t Γt → STy Sch sig ρret Γ f Γf → STy Sch sig ρret Γ (.contains b n e t f) Γ
  | cond {Γ c t e Γt Γe} : ETy Γ c (.data .bool) → STy Sch sig ρret Γ t Γt → STy Sch sig ρret Γ e Γe →
      STy Sch sig ρret Γ (.cond c t e) Γ
  | «while» {Γ c body Γb} : ETy Γ c (.data .bool) → STy Sch sig ρret Γ body Γb →
      STy Sch sig ρret Γ (.while c body) Γ
  | tryCatch {Γ body v handler Γb Γh} : STy Sch sig ρret Γ body Γb →
      (∀ ρ0, Γ v = some ρ0 → ρ0 = .data excTy) →
      STy Sch sig ρret (Γ.set v (.data excTy)) handler Γh →
      STy Sch sig ρret Γ (.tryCatch body v handler) Γ
  | tryFinally {Γ body fin Γb Γf} : STy Sch sig ρret Γ body Γb → STy Sch sig ρret Γ fin Γf →
      STy Sch sig ρret Γ (.tryFinally body fin) Γ
  | raise {Γ e} : ETy Γ e (.data excTy) → STy Sch sig ρret Γ (.raise e) Γ
  | ret {Γ e} : ETy Γ e (.data ρret) → STy Sch sig ρret Γ (.ret e) Γ

/-- Contexts only grow along a statement. -/
def CtxLe (Γ Γ' : Ctx) : Prop := ∀ x ρ, Γ x = some ρ → Γ' x = some ρ

theorem CtxLe.refl (Γ : Ctx) : CtxLe Γ Γ := fun _ _ h => h
theorem CtxLe.trans {Γ1 Γ2 Γ3 : Ctx} (h12 : CtxLe Γ1 Γ2) (h23 : CtxLe Γ2 Γ3) : CtxLe Γ1 Γ3 :=
  fun x ρ h => h23 x ρ (h12 x ρ h)

theorem CtxLe.set {Γ : Ctx} {x : String} {ρ : RTy} (h : ∀ ρ0, Γ x = some ρ0 → ρ0 = ρ) :
    CtxLe Γ (Γ.set x ρ) := by
  intro y ρ' hy
  unfold Ctx.set
  by_cases hyx : y = x
  · subst hyx; rw [h ρ' hy]; simp
  · simp [hyx, hy]

theorem STy_extends {Sch : Schema} {sig : ActSig} {ρret : Ty} :
    ∀ {Γ s Γ'}, STy Sch sig ρret Γ s Γ' → CtxLe Γ Γ' := by
  intro Γ s Γ' h
  induction h with
  | pass => exact CtxLe.refl _
  | seq _ _ ih1 ih2 => exact CtxLe.trans ih1 ih2
  | assign _ hx => exact CtxLe.set hx
  | action _ hx => exact CtxLe.set hx
  | setAttr _ _ _ => exact CtxLe.refl _
  | addElem _ _ _ => exact CtxLe.refl _
  | removeElem _ _ _ => exact CtxLe.refl _
  | get _ _ hx => exact CtxLe.set hx
  | contains _ _ _ _ _ _ _ => exact CtxLe.refl _
  | cond _ _ _ _ _ => exact CtxLe.refl _
  | «while» _ _ _ => exact CtxLe.refl _
  | tryCatch _ _ _ _ _ => exact CtxLe.refl _
  | tryFinally _ _ _ _ => exact CtxLe.refl _
  | raise _ => exact CtxLe.refl _
  | ret _ => exact CtxLe.refl _

theorem GTy_anti {Γ Γ' : Ctx} {env : Env} (hle : CtxLe Γ Γ') (h : GTy Γ' env) : GTy Γ env :=
  fun x ρ hx => h x ρ (hle x ρ hx)

theorem GTy_set {Γ : Ctx} {env : Env} {x : String} {ρ : RTy} {v : RVal}
    (h : GTy Γ env) (hv : RVTy ρ v) : GTy (Γ.set x ρ) (assocSet env x v) := by
  intro y ρ' hy
  unfold Ctx.set at hy
  by_cases hyx : y = x
  · subst hyx
    simp only [if_true] at hy
    cases hy
    exact ⟨v, lookup_assocSet_same _ _ _, hv⟩
  · simp only [hyx, if_false] at hy
    obtain ⟨w, hw, hwt⟩ := h y ρ' hy
    exact ⟨w, by rw [lookup_assocSet_other _ _ _ _ hyx]; exact hw, hwt⟩

/-! ## State-shape lemmas for the mutators -/

theorem StTy_setAttrAt {Sch : Schema} {st st' : St} {p : Path} {a : String} {x : Val} {τ : Ty}
    (hst : StTy Sch st) (hSch : Sch a = some τ) (hx : VTy τ x) (h : setAttrAt p st a x = some st') :
    StTy Sch st' := by
  intro q b τ' v hb hv
  by_cases hqb : q = p ∧ b = a
  · obtain ⟨rfl, rfl⟩ := hqb
    rw [setAttrAt_same _ _ _ _ _ h] at hv
    cases hv
    rw [hSch] at hb; cases hb
    exact hx
  · have hne : q ≠ p ∨ b ≠ a := by
      by_cases hq : q = p
      · right; intro hb'; exact hqb ⟨hq, hb'⟩
      · left; exact hq
    rw [setAttrAt_frame _ _ _ _ _ h q b hne] at hv
    exact hst q b τ' v hb hv

theorem StTy_addElemAt {Sch : Schema} {st st' : St} {p : Path} {n : String} {x : Val}
    (hst : StTy Sch st) (h : addElemAt p st n x = some st') : StTy Sch st' := by
  intro q b τ v hb hv
  rw [addElemAt_attrs _ _ _ _ _ h q b] at hv
  exact hst q b τ v hb hv

/-- Removal never creates an attribute: whatever is readable afterwards was readable before. -/
theorem removeElemAt_getAttrAt : ∀ (p : Path) (st st' : St) (n : String) (x : Val),
    removeElemAt p st n x = some st' →
    ∀ (q : Path) (b : String) (v : Val), getAttrAt q st' b = some v → getAttrAt q st b = some v := by
  intro p
  induction p with
  | here =>
    intro st st' n x h q b v hv
    simp only [removeElemAt, Option.some.injEq] at h
    subst h
    cases q with
    | here => simpa [getAttrAt] using hv
    | nested m w rest =>
      simp only [getAttrAt, St.mk_elems] at hv ⊢
      by_cases hk : (m, w) = (n, x)
      · rw [hk, lookup_assocRemove_same] at hv; cases hv
      · rw [lookup_assocRemove_other _ _ _ hk] at hv
        exact hv
  | nested m0 w0 rest ih =>
    intro st st' n x h q b v hv
    simp only [removeElemAt] at h
    split at h
    · cases h
    · rename_i sub hsub
      split at h
      · cases h
      · rename_i sub' hsub'
        simp only [Option.some.injEq] at h
        subst h
        cases q with
        | here => simpa [getAttrAt] using hv
        | nested m w rest' =>
          simp only [getAttrAt, St.mk_elems] at hv ⊢
          by_cases hk : (m, w) = (m0, w0)
          · obtain ⟨rfl, rfl⟩ := Prod.mk.inj hk
            rw [lookup_assocSet_same] at hv
            rw [hsub]
            exact ih sub sub' n x hsub' rest' b v hv
          · rw [lookup_assocSet_other _ _ _ _ hk] at hv
            exact hv

theorem StTy_removeElemAt {Sch : Schema} {st st' : St} {p : Path} {n : String} {x : Val}
    (hst : StTy Sch st) (h : removeElemAt p st n x = some st') : StTy Sch st' := by
  intro q b τ v hb hv
  exact hst q b τ v hb (removeElemAt_getAttrAt _ _ _ _ _ h q b v hv)

/-! ## Preservation -/

/-- What a well-typed run may produce. `Γ` is the INPUT context (a raise may happen before the
    statement's bindings are complete, so its environment is typed by `Γ` — through some
    extension — not by the output context `Γ'`); `.continue` is typed by the output context. -/
@[reducible] def ResTy (Sch : Schema) (ρret : Ty) (Γ Γ' : Ctx) : Res → Prop
  | .continue env st => GTy Γ' env ∧ StTy Sch st
  | .raise x env st => VTy excTy x ∧ GTy Γ env ∧ StTy Sch st
  | .ret v env st => VTy ρret v ∧ GTy Γ env ∧ StTy Sch st
  | .failure => True

theorem ResTy_weaken {Sch : Schema} {ρret : Ty} {Γ Γt : Ctx} (hle : CtxLe Γ Γt) {r : Res}
    (h : ResTy Sch ρret Γ Γt r) : ResTy Sch ρret Γ Γ r := by
  cases r with
  | «continue» e s => exact ⟨GTy_anti hle h.1, h.2⟩
  | raise x e s => exact h
  | ret x e s => exact h
  | failure => trivial

/-- Every action body is well-typed against its signature, starting from the callee context. -/
def ActsTyped (Sch : Schema) (sig : ActSig) (actDef : String → Stmt String) : Prop :=
  ∀ a, ∃ Γ', STy Sch sig (sig a).2 (calleeCtx (sig a).1) (actDef a) Γ'

theorem GTy_callee {ρ : RTy} {arg : RVal} (h : RVTy ρ arg) : GTy (calleeCtx ρ) (calleeEnv arg) := by
  intro x ρ' hx
  unfold calleeCtx at hx
  by_cases h1 : x = "ι"
  · subst h1; simp at hx; cases hx; exact ⟨arg, rfl, h⟩
  · simp only [h1, if_false] at hx
    by_cases h2 : x = "σ"
    · subst h2; simp at hx; cases hx; exact ⟨.sref .here, rfl, trivial⟩
    · simp [h2] at hx

/-- Type preservation over `interp`, for every fuel, statement form, environment and state. -/
theorem preservation (actDef : String → Stmt String) (Sch : Schema) (sig : ActSig)
    (hacts : ActsTyped Sch sig actDef) :
    ∀ (f : Nat) (s : Stmt String) (Γ Γ' : Ctx) (ρret : Ty) (env : Env) (st : St),
      STy Sch sig ρret Γ s Γ' → GTy Γ env → StTy Sch st →
      ResTy Sch ρret Γ Γ' (interp actDef f s env st) := by
  intro f
  induction f using Nat.strongRecOn with
  | _ f ih =>
  intro s Γ Γ' ρret env st hs hΓ hst
  cases f with
  | zero => simp [interp, ResTy]
  | succ f =>
  have ihf := ih f (Nat.lt_succ_self f)
  cases hs with
  | pass => exact ⟨hΓ, hst⟩
  | @seq _ Γ1 _ a b ha hb =>
    rw [interp_succ_seq]
    have iha := ihf a Γ Γ1 ρret env st ha hΓ hst
    cases hra : interp actDef f a env st with
    | «continue» e s =>
      rw [hra] at iha
      dsimp only
      obtain ⟨hΓ1, hst1⟩ := iha
      have ihb := ihf b Γ1 Γ' ρret e s hb hΓ1 hst1
      cases hrb : interp actDef f b e s with
      | «continue» e2 s2 => rw [hrb] at ihb; exact ihb
      | raise x e2 s2 => rw [hrb] at ihb; exact ⟨ihb.1, GTy_anti (STy_extends ha) ihb.2.1, ihb.2.2⟩
      | ret x e2 s2 => rw [hrb] at ihb; exact ⟨ihb.1, GTy_anti (STy_extends ha) ihb.2.1, ihb.2.2⟩
      | failure => trivial
    | raise x e s => rw [hra] at iha; exact iha
    | ret x e s => rw [hra] at iha; exact iha
    | failure => trivial
  | @assign _ x e ρ he _ =>
    rw [interp_succ_assign]
    cases hv : evalExpr env e with
    | none => trivial
    | some v => exact ⟨GTy_set hΓ (ETy_sound hΓ he v hv), hst⟩
  | @action _ v a e he _ =>
    rw [interp_succ_action]
    cases hv : evalExpr env e with
    | none => trivial
    | some arg =>
      dsimp only
      have harg := ETy_sound hΓ he arg hv
      obtain ⟨Γc, hbody⟩ := hacts a
      have hc := ihf (actDef a) (calleeCtx (sig a).1) Γc (sig a).2 (calleeEnv arg) st hbody
        (GTy_callee harg) hst
      cases hr : interp actDef f (actDef a) (calleeEnv arg) st with
      | ret res e s =>
        rw [hr] at hc
        obtain ⟨hres, _, hs'⟩ := hc
        exact ⟨GTy_set hΓ hres, hs'⟩
      | raise x e s => rw [hr] at hc; exact ⟨hc.1, hΓ, hc.2.2⟩
      | «continue» _ _ => trivial
      | failure => trivial
  | @setAttr _ b a e τ hb hS he =>
    rw [interp_succ_setAttr]
    cases hvb : evalExpr env b with
    | none => trivial
    | some rb =>
      cases hve : evalExpr env e with
      | none => cases rb <;> trivial
      | some re =>
        have hrb := ETy_sound hΓ hb rb hvb
        have hre := ETy_sound hΓ he re hve
        cases rb with
        | v _ => simp [RVTy] at hrb
        | rpair _ _ => simp [RVTy] at hrb
        | sref p =>
          cases re with
          | sref _ => simp [RVTy] at hre
          | rpair _ _ => simp [RVTy] at hre
          | v x =>
            dsimp only
            cases hset : setAttrAt p st a x with
            | none => trivial
            | some st' => exact ⟨hΓ, StTy_setAttrAt hst hS hre hset⟩
  | @addElem _ b n e τ hb he _ =>
    rw [interp_succ_addElem]
    cases hvb : evalExpr env b with
    | none => trivial
    | some rb =>
      cases hve : evalExpr env e with
      | none => cases rb <;> trivial
      | some re =>
        have hrb := ETy_sound hΓ hb rb hvb
        have hre := ETy_sound hΓ he re hve
        cases rb with
        | v _ => simp [RVTy] at hrb
        | rpair _ _ => simp [RVTy] at hrb
        | sref p =>
          cases re with
          | sref _ => simp [RVTy] at hre
          | rpair _ _ => simp [RVTy] at hre
          | v x =>
            dsimp only
            cases hadd : addElemAt p st n x with
            | none => trivial
            | some st' => exact ⟨hΓ, StTy_addElemAt hst hadd⟩
  | @removeElem _ b n e τ hb he _ =>
    rw [interp_succ_removeElem]
    cases hvb : evalExpr env b with
    | none => trivial
    | some rb =>
      cases hve : evalExpr env e with
      | none => cases rb <;> trivial
      | some re =>
        have hrb := ETy_sound hΓ hb rb hvb
        have hre := ETy_sound hΓ he re hve
        cases rb with
        | v _ => simp [RVTy] at hrb
        | rpair _ _ => simp [RVTy] at hrb
        | sref p =>
          cases re with
          | sref _ => simp [RVTy] at hre
          | rpair _ _ => simp [RVTy] at hre
          | v x =>
            dsimp only
            cases hrem : removeElemAt p st n x with
            | none => trivial
            | some st' => exact ⟨hΓ, StTy_removeElemAt hst hrem⟩
  | @get _ x b a τ hb hS _ =>
    rw [interp_succ_get]
    cases hvb : evalExpr env b with
    | none => trivial
    | some rb =>
      have hrb := ETy_sound hΓ hb rb hvb
      cases rb with
      | v _ => simp [RVTy] at hrb
      | rpair _ _ => simp [RVTy] at hrb
      | sref p =>
        dsimp only
        cases hget : getAttrAt p st a with
        | none => trivial
        | some y => exact ⟨GTy_set hΓ (hst p a τ y hS hget), hst⟩
  | @contains _ b n e τ t g Γt Γg hb he _ ht hg =>
    rw [interp_succ_contains]
    cases hvb : evalExpr env b with
    | none => trivial
    | some rb =>
      cases hve : evalExpr env e with
      | none => cases rb <;> trivial
      | some re =>
        have hrb := ETy_sound hΓ hb rb hvb
        have hre := ETy_sound hΓ he re hve
        cases rb with
        | v _ => simp [RVTy] at hrb
        | rpair _ _ => simp [RVTy] at hrb
        | sref p =>
          cases re with
          | sref _ => simp [RVTy] at hre
          | rpair _ _ => simp [RVTy] at hre
          | v x =>
            dsimp only
            by_cases hh : hasElemAt p st n x = true
            · rw [if_pos hh]
              exact ResTy_weaken (STy_extends ht) (ihf t Γ Γt ρret env st ht hΓ hst)
            · rw [if_neg hh]
              exact ResTy_weaken (STy_extends hg) (ihf g Γ Γg ρret env st hg hΓ hst)
  | @cond _ c t e Γt Γe hc ht he =>
    rw [interp_succ_cond]
    cases hvc : evalExpr env c with
    | none => trivial
    | some rc =>
      have hrc := ETy_sound hΓ hc rc hvc
      cases rc with
      | sref _ => simp [RVTy] at hrc
      | rpair _ _ => simp [RVTy] at hrc
      | v x =>
        cases x with
        | pair _ _ => simp [RVTy, VTy] at hrc
        | lit l =>
          cases l with
          | unit => simp [RVTy, VTy] at hrc
          | int _ => simp [RVTy, VTy] at hrc
          | str _ => simp [RVTy, VTy] at hrc
          | bool bb =>
            cases bb with
            | true => exact ResTy_weaken (STy_extends ht) (ihf t Γ Γt ρret env st ht hΓ hst)
            | false => exact ResTy_weaken (STy_extends he) (ihf e Γ Γe ρret env st he hΓ hst)
  | @«while» _ c body Γb hc hbody =>
    rw [interp_succ_while]
    cases hvc : evalExpr env c with
    | none => trivial
    | some rc =>
      have hrc := ETy_sound hΓ hc rc hvc
      cases rc with
      | sref _ => simp [RVTy] at hrc
      | rpair _ _ => simp [RVTy] at hrc
      | v x =>
        cases x with
        | pair _ _ => simp [RVTy, VTy] at hrc
        | lit l =>
          cases l with
          | unit => simp [RVTy, VTy] at hrc
          | int _ => simp [RVTy, VTy] at hrc
          | str _ => simp [RVTy, VTy] at hrc
          | bool bb =>
            cases bb with
            | false => exact ⟨hΓ, hst⟩
            | true =>
              dsimp only
              cases f with
              | zero => simp [interp, ResTy]
              | succ f' =>
                rw [interp_succ_seq]
                have ihb := ih f' (by omega) body Γ Γb ρret env st hbody hΓ hst
                cases hrb : interp actDef f' body env st with
                | «continue» e s =>
                  rw [hrb] at ihb
                  dsimp only
                  obtain ⟨hΓe, hs⟩ := ihb
                  exact ih f' (by omega) (.while c body) Γ Γ ρret e s (STy.while hc hbody)
                    (GTy_anti (STy_extends hbody) hΓe) hs
                | raise x e s => rw [hrb] at ihb; exact ihb
                | ret x e s => rw [hrb] at ihb; exact ihb
                | failure => trivial
  | @tryCatch _ body v handler Γb Γh hbody hv hhandler =>
    rw [interp_succ_tryCatch]
    have ihb := ihf body Γ Γb ρret env st hbody hΓ hst
    cases hrb : interp actDef f body env st with
    | «continue» e s => rw [hrb] at ihb; exact ResTy_weaken (STy_extends hbody) ihb
    | raise x e s =>
      rw [hrb] at ihb
      dsimp only
      obtain ⟨hx, hΓe, hs⟩ := ihb
      have hΓh : GTy (Γ.set v (.data excTy)) (assocSet e v (.v x)) := GTy_set hΓe hx
      have ihh := ihf handler (Γ.set v (.data excTy)) Γh ρret (assocSet e v (.v x)) s hhandler hΓh hs
      have hle : CtxLe Γ (Γ.set v (.data excTy)) := CtxLe.set hv
      cases hrh : interp actDef f handler (assocSet e v (.v x)) s with
      | «continue» e2 s2 =>
        rw [hrh] at ihh
        exact ⟨GTy_anti (CtxLe.trans hle (STy_extends hhandler)) ihh.1, ihh.2⟩
      | raise y e2 s2 => rw [hrh] at ihh; exact ⟨ihh.1, GTy_anti hle ihh.2.1, ihh.2.2⟩
      | ret y e2 s2 => rw [hrh] at ihh; exact ⟨ihh.1, GTy_anti hle ihh.2.1, ihh.2.2⟩
      | failure => trivial
    | ret x e s => rw [hrb] at ihb; exact ihb
    | failure => trivial
  | @tryFinally _ body fin Γb Γf hbody hfin =>
    rw [interp_succ_tryFinally]
    have ihb := ihf body Γ Γb ρret env st hbody hΓ hst
    cases hrb : interp actDef f body env st with
    | «continue» e s =>
      rw [hrb] at ihb
      dsimp only
      obtain ⟨hΓe, hs⟩ := ihb
      have := ihf fin Γ Γf ρret e s hfin (GTy_anti (STy_extends hbody) hΓe) hs
      exact ResTy_weaken (STy_extends hfin) this
    | raise x e s =>
      rw [hrb] at ihb
      dsimp only
      obtain ⟨hx, hΓe, hs⟩ := ihb
      have ihfin := ihf fin Γ Γf ρret e s hfin hΓe hs
      cases hrf : interp actDef f fin e s with
      | «continue» e2 s2 => rw [hrf] at ihfin; exact ⟨hx, GTy_anti (STy_extends hfin) ihfin.1, ihfin.2⟩
      | raise y e2 s2 => rw [hrf] at ihfin; exact ihfin
      | ret y e2 s2 => rw [hrf] at ihfin; exact ihfin
      | failure => trivial
    | ret x e s =>
      rw [hrb] at ihb
      dsimp only
      obtain ⟨hx, hΓe, hs⟩ := ihb
      have ihfin := ihf fin Γ Γf ρret e s hfin hΓe hs
      cases hrf : interp actDef f fin e s with
      | «continue» e2 s2 =>
        rw [hrf] at ihfin
        exact ⟨hx, GTy_anti (STy_extends hfin) ihfin.1, ihfin.2⟩
      | raise y e2 s2 => rw [hrf] at ihfin; exact ihfin
      | ret y e2 s2 => rw [hrf] at ihfin; exact ihfin
      | failure => trivial
    | failure => trivial
  | @raise _ e he =>
    rw [interp_succ_raise]
    cases hv : evalExpr env e with
    | none => trivial
    | some r =>
      have hr := ETy_sound hΓ he r hv
      cases r with
      | v x => exact ⟨hr, hΓ, hst⟩
      | sref _ => trivial
      | rpair _ _ => trivial
  | @ret _ e he =>
    rw [interp_succ_ret]
    cases hv : evalExpr env e with
    | none => trivial
    | some r =>
      have hr := ETy_sound hΓ he r hv
      cases r with
      | v x => exact ⟨hr, hΓ, hst⟩
      | sref _ => simp [RVTy] at hr
      | rpair _ _ => simp [RVTy] at hr

end CalculusTyping
