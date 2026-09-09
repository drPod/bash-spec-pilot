import ShellObservation

/-!
# Calculus fragment: representation connection to the phase3 shell grammar

This file is a Lean transcription of the fragment of the pinned State Calculus
interpreter (`counc009/state_based`, branch `bash`, commit
`190dd8491b258d8a0ee29f79629908540236b332`, `bash-verifier/lib/calculus/interp.ml`)
that the OCaml fixture driver `sc_fixtures.ml interp` exercises: `Pass`, `Seq`,
`Cond`, `Action`, `Add (QualAttr σ …)`, `Get`, `Return`, expression evaluation of
literals, variables, pairs and the two builtin functions `Eq`, `ConcatStr`.

**Trust boundary.** Nothing here is extracted from or checked against the OCaml
source by a machine. The transcription is compared empirically: the fixture
driver runs the *actual* pinned interpreter on the same programs and its JSON
output is compared to `#eval` results of `CalculusFragment.runFixture` below by
`compare_interp.py`. The theorems relate this transcription to the phase3
`ShellObservation.Exec` grammar; they do not speak about the OCaml program.

Omitted from the transcription: `Raise`, `Yield`, `Match`, `ForEach`, `While`,
`ForElem`, `TryCatch`, `TryFinally`, `Localize`, nested state references,
elements, and the randomized state. Actions are given a fuel bound because
action bodies are looked up through a function rather than structurally.
-/

namespace CalculusFragment

inductive Lit where
  | unit
  | bool (b : Bool)
  | int (n : Int)
  | str (s : String)
  deriving DecidableEq, Repr

inductive Func where
  | eq
  | concatStr
  deriving DecidableEq, Repr

inductive Expr where
  | lit (l : Lit)
  | var (x : String)
  | pair (a b : Expr)
  | fn (f : Func) (e : Expr)
  deriving Repr

/-- Statements, parametric in the action alphabet as in the OCaml functor. -/
inductive Stmt (Act : Type) where
  | pass
  | seq (a b : Stmt Act)
  | action (v : String) (a : Act) (e : Expr)
  | cond (c : Expr) (t e : Stmt Act)
  | addAttr (attr : String) (e : Expr)
  | getAttr (v attr : String)
  | ret (e : Expr)
  deriving Repr

inductive Val where
  | lit (l : Lit)
  | pair (a b : Val)
  deriving DecidableEq, Repr

/-- Variable environment (OCaml `VarMap`); only lookups and insertions are used. -/
abbrev Env := String → Option Val

def Env.insert (env : Env) (x : String) (v : Val) : Env :=
  fun y => if y = x then some v else env y

/-- Root-level attributes of the concrete state (OCaml `ConcreteState` `attrs`
    at `Here`). Elements and nested states are not modelled. -/
abbrev State := String → Option Val

def State.setAttr (st : State) (attr : String) (v : Val) : State :=
  fun a => if a = attr then some v else st a

def funcDef : Func → Val → Option Val
  | .eq, .pair (.lit x) (.lit y) => some (.lit (.bool (decide (x = y))))
  | .eq, _ => none
  | .concatStr, .pair (.lit (.str x)) (.lit (.str y)) => some (.lit (.str (x ++ y)))
  | .concatStr, _ => none

def evalExpr (env : Env) : Expr → Option Val
  | .lit l => some (.lit l)
  | .var x => env x
  | .pair a b => do
      let a ← evalExpr env a
      let b ← evalExpr env b
      pure (.pair a b)
  | .fn f e => do
      let v ← evalExpr env e
      funcDef f v

inductive Res where
  | continue (env : Env) (st : State)
  | ret (v : Val) (env : Env) (st : State)
  | failure

/-- Callee environment built by the OCaml `Action` case: `init_env` (σ = Here) plus ι. -/
def mkCallee (arg : Val) : Env :=
  fun y => if y = "ι" then some arg else if y = "σ" then some (.lit .unit) else none

/-- Transcription of `interp` for the fragment. `fuel` bounds action nesting;
    `actDef` is the OCaml `I.act_def`. The callee environment is
    `init_env` plus `ι` as in the OCaml source. -/
def interp {Act : Type} (actDef : Act → Stmt Act) : Nat → Stmt Act → Env → State → Res
  | _, .pass, env, st => .continue env st
  | fuel, .seq a b, env, st =>
      match interp actDef fuel a env st with
      | .continue env st => interp actDef fuel b env st
      | r => r
  | fuel, .action v a e, env, st =>
      match evalExpr env e with
      | none => .failure
      | some arg =>
        match fuel with
        | 0 => .failure
        | fuel + 1 =>
          match interp actDef fuel (actDef a) (mkCallee arg) st with
          | .ret res _ st => .continue (env.insert v res) st
          | _ => .failure
  | fuel, .cond c t e, env, st =>
      match evalExpr env c with
      | some (.lit (.bool true)) => interp actDef fuel t env st
      | some (.lit (.bool false)) => interp actDef fuel e env st
      | _ => .failure
  | _, .addAttr attr e, env, st =>
      match evalExpr env e with
      | none => .failure
      | some v => .continue env (st.setAttr attr v)
  | _, .getAttr v attr, env, st =>
      match st attr with
      | none => .failure
      | some x => .continue (env.insert v x) st
  | _, .ret e, env, st =>
      match evalExpr env e with
      | none => .failure
      | some v => .ret v env st

/-! ## Encoding of the phase3 shell grammar -/

open ShellObservation

def rcZero : Expr := .fn .eq (.pair (.var "rc") (.lit (.int 0)))

def encode {Act : Type} : Command Act → Stmt Act
  | .call a => .action "rc" a (.lit .unit)
  | .seq a b => .seq (encode a) (encode b)
  | .andThen a b => .seq (encode a) (.cond rcZero (encode b) .pass)
  | .orElse a b => .seq (encode a) (.cond rcZero .pass (encode b))

/-- Deterministic primitive semantics read off an action definition: run the
    body in the callee environment the interpreter builds for `Action` with the
    unit argument, and require a non-negative integer `Return` value. -/
def primFn {Act : Type} (actDef : Act → Stmt Act) (fuel : Nat) (a : Act) (st : State) :
    Option (Nat × State) :=
  match interp actDef fuel (actDef a) (mkCallee (.lit .unit)) st with
  | .ret (.lit (.int n)) _ st' => if n < 0 then none else some (n.toNat, st')
  | _ => none

/-- The relational primitive used by `ShellObservation.Exec`. -/
def prim {Act : Type} (actDef : Act → Stmt Act) (fuel : Nat) : Primitive Act State :=
  fun a s rc t => primFn actDef fuel a s = some (rc, t)

/-- Functional evaluation of a command against the primitive. -/
def run {Act : Type} (actDef : Act → Stmt Act) (fuel : Nat) : Command Act → State → Option (Nat × State)
  | .call a, s => primFn actDef fuel a s
  | .seq a b, s => do
      let (_, t) ← run actDef fuel a s
      run actDef fuel b t
  | .andThen a b, s => do
      let (rc, t) ← run actDef fuel a s
      if rc = 0 then run actDef fuel b t else pure (rc, t)
  | .orElse a b, s => do
      let (rc, t) ← run actDef fuel a s
      if rc = 0 then pure (0, t) else run actDef fuel b t

theorem run_sound {Act : Type} (actDef : Act → Stmt Act) (fuel : Nat) :
    ∀ (cmd : Command Act) (s : State) (rc : Nat) (t : State),
      run actDef fuel cmd s = some (rc, t) → Exec (prim actDef fuel) cmd s rc t := by
  intro cmd
  induction cmd with
  | call a =>
      intro s rc t h
      exact .call h
  | seq a b iha ihb =>
      intro s rc t h
      simp only [run, Option.bind_eq_bind, Option.bind_eq_some_iff] at h
      obtain ⟨⟨rc₁, u⟩, ha, hb⟩ := h
      exact .seq (iha s rc₁ u ha) (ihb u rc t hb)
  | andThen a b iha ihb =>
      intro s rc t h
      simp only [run, Option.bind_eq_bind, Option.bind_eq_some_iff] at h
      obtain ⟨⟨rc₁, u⟩, ha, hb⟩ := h
      by_cases hz : rc₁ = 0
      · subst hz
        simp only [↓reduceIte] at hb
        exact .andZero (iha s 0 u ha) (ihb u rc t hb)
      · simp only [hz, ↓reduceIte, Option.pure_def, Option.some.injEq, Prod.mk.injEq] at hb
        obtain ⟨rfl, rfl⟩ := hb
        exact .andNonzero (iha s rc₁ u ha) hz
  | orElse a b iha ihb =>
      intro s rc t h
      simp only [run, Option.bind_eq_bind, Option.bind_eq_some_iff] at h
      obtain ⟨⟨rc₁, u⟩, ha, hb⟩ := h
      by_cases hz : rc₁ = 0
      · subst hz
        simp only [↓reduceIte, Option.pure_def, Option.some.injEq, Prod.mk.injEq] at hb
        obtain ⟨rfl, rfl⟩ := hb
        exact .orZero (iha s 0 u ha)
      · simp only [hz, ↓reduceIte] at hb
        exact .orNonzero (iha s rc₁ u ha) hz (ihb u rc t hb)

theorem run_complete {Act : Type} (actDef : Act → Stmt Act) (fuel : Nat)
    (cmd : Command Act) (s : State) (rc : Nat) (t : State)
    (h : Exec (prim actDef fuel) cmd s rc t) : run actDef fuel cmd s = some (rc, t) := by
  induction h with
  | call h => exact h
  | seq _ _ ih₁ ih₂ => simp [run, ih₁, ih₂]
  | andZero _ _ ih₁ ih₂ => simp [run, ih₁, ih₂]
  | andNonzero _ hn ih => simp [run, ih, hn]
  | orZero _ ih => simp [run, ih]
  | orNonzero _ hn _ ih₁ ih₂ => simp [run, ih₁, ih₂, hn]

/-- The functional evaluator and the phase3 relation agree exactly. -/
theorem run_iff_exec {Act : Type} (actDef : Act → Stmt Act) (fuel : Nat)
    (cmd : Command Act) (s : State) (rc : Nat) (t : State) :
    run actDef fuel cmd s = some (rc, t) ↔ Exec (prim actDef fuel) cmd s rc t :=
  ⟨run_sound actDef fuel cmd s rc t, run_complete actDef fuel cmd s rc t⟩

/-! ## The encoding is executed by the transcribed interpreter as `run` predicts -/

theorem Env.insert_insert (env : Env) (x : String) (v w : Val) :
    (env.insert x v).insert x w = env.insert x w := by
  funext y; simp only [Env.insert]; split <;> rfl

theorem Env.insert_same (env : Env) (x : String) (v : Val) : env.insert x v x = some v := by
  simp [Env.insert]

theorem evalExpr_rcZero (env : Env) (rc : Nat) (h : env "rc" = some (.lit (.int rc))) :
    evalExpr env rcZero = some (.lit (.bool (decide (rc = 0)))) := by
  simp [rcZero, evalExpr, h, funcDef]

/-- Whenever `run` yields a status and state, the transcribed interpreter, given one more
    unit of fuel for the action call, ends in `continue` with `rc` bound to that status and
    the same state, from any caller environment. -/
theorem encode_run {Act : Type} (actDef : Act → Stmt Act) (fuel : Nat) :
    ∀ (cmd : Command Act) (env : Env) (st : State) (rc : Nat) (t : State),
      run actDef fuel cmd st = some (rc, t) →
      interp actDef (fuel + 1) (encode cmd) env st = .continue (env.insert "rc" (.lit (.int rc))) t := by
  intro cmd
  induction cmd with
  | call a =>
      intro env st rc t h
      simp only [run, primFn] at h
      simp only [encode, interp, evalExpr]
      revert h
      rcases hres : interp actDef fuel (actDef a) (mkCallee (.lit .unit)) st with ⟨e, s⟩ | ⟨v, e, s⟩ | _
      · intro h; simp at h
      · intro h
        rcases v with ⟨l⟩ | ⟨_, _⟩
        · rcases l with _ | _ | n | _
          · simp at h
          · simp at h
          · by_cases hn : n < 0
            · simp [hn] at h
            · simp only [hn, ↓reduceIte, Option.some.injEq, Prod.mk.injEq] at h
              obtain ⟨rfl, rfl⟩ := h
              simp [Int.toNat_of_nonneg (Int.not_lt.mp hn)]
          · simp at h
        · simp at h
      · intro h; simp at h
  | seq a b iha ihb =>
      intro env st rc t h
      simp only [run, Option.bind_eq_bind, Option.bind_eq_some_iff] at h
      obtain ⟨⟨rc₁, u⟩, ha, hb⟩ := h
      simp only [encode, interp]
      rw [iha env st rc₁ u ha]
      simp only []
      rw [ihb _ u rc t hb, Env.insert_insert]
  | andThen a b iha ihb =>
      intro env st rc t h
      simp only [run, Option.bind_eq_bind, Option.bind_eq_some_iff] at h
      obtain ⟨⟨rc₁, u⟩, ha, hb⟩ := h
      simp only [encode, interp]
      rw [iha env st rc₁ u ha]
      simp only []
      rw [evalExpr_rcZero _ rc₁ (Env.insert_same _ _ _)]
      by_cases hz : rc₁ = 0
      · simp only [hz, ↓reduceIte] at hb
        simp only [hz, decide_true]
        rw [ihb _ u rc t hb, Env.insert_insert]
      · simp only [hz, ↓reduceIte, Option.pure_def, Option.some.injEq, Prod.mk.injEq] at hb
        obtain ⟨rfl, rfl⟩ := hb
        simp only [hz, decide_false]
  | orElse a b iha ihb =>
      intro env st rc t h
      simp only [run, Option.bind_eq_bind, Option.bind_eq_some_iff] at h
      obtain ⟨⟨rc₁, u⟩, ha, hb⟩ := h
      simp only [encode, interp]
      rw [iha env st rc₁ u ha]
      simp only []
      rw [evalExpr_rcZero _ rc₁ (Env.insert_same _ _ _)]
      by_cases hz : rc₁ = 0
      · simp only [hz, ↓reduceIte, Option.pure_def, Option.some.injEq, Prod.mk.injEq] at hb
        obtain ⟨rfl, rfl⟩ := hb
        simp only [hz, decide_true]
      · simp only [hz, ↓reduceIte] at hb
        simp only [hz, decide_false]
        rw [ihb _ u rc t hb, Env.insert_insert]

/-- Combined: a `run` result is a phase3 `Exec` derivation and is what the transcribed
    interpreter computes for the encoded command. -/
theorem encode_exec {Act : Type} (actDef : Act → Stmt Act) (fuel : Nat)
    (cmd : Command Act) (env : Env) (st : State) (rc : Nat) (t : State)
    (h : run actDef fuel cmd st = some (rc, t)) :
    Exec (prim actDef fuel) cmd st rc t ∧
      interp actDef (fuel + 1) (encode cmd) env st = .continue (env.insert "rc" (.lit (.int rc))) t :=
  ⟨run_sound actDef fuel cmd st rc t h, encode_run actDef fuel cmd env st rc t h⟩

/-! ## Fixture instance (mirrors `sc_fixtures.ml`, module `B`/`Defs`) -/

inductive FixAct where
  | relayOk
  | relayLateError
  | mark
  | noReturn
  deriving DecidableEq, Repr

def appendStdout (s : String) : Stmt FixAct :=
  .seq (.getAttr "cur" "stdout")
       (.addAttr "stdout" (.fn .concatStr (.pair (.var "cur") (.lit (.str s)))))

def fixActDef : FixAct → Stmt FixAct
  | .relayOk => .seq (appendStdout "abc") (.ret (.lit (.int 0)))
  | .relayLateError => .seq (appendStdout "abc") (.ret (.lit (.int 1)))
  | .mark => .seq (appendStdout "!") (.ret (.lit (.int 0)))
  | .noReturn => appendStdout "?"

def program (c : Command FixAct) : Stmt FixAct :=
  .seq (.addAttr "stdout" (.lit (.str ""))) (encode c)

def initEnv : Env := fun y => if y = "σ" then some (.lit .unit) else none
def emptyState : State := fun _ => none

/-- Observable summary of a fixture run: outcome, rc and stdout attribute. -/
structure Summary where
  outcome : String
  rc : Option Int
  stdout : Option String
  deriving Repr, DecidableEq

def summarize : Res → Summary
  | .continue env st =>
      { outcome := "continue"
        rc := match env "rc" with | some (.lit (.int n)) => some n | _ => none
        stdout := match st "stdout" with | some (.lit (.str s)) => some s | _ => none }
  | .ret _ _ _ => { outcome := "return", rc := none, stdout := none }
  | .failure => { outcome := "failure", rc := none, stdout := none }

def runFixture (c : Command FixAct) : Summary :=
  summarize (interp fixActDef 2 (program c) initEnv emptyState)

def ok : Command FixAct := .call .relayOk
def late : Command FixAct := .call .relayLateError
def mark : Command FixAct := .call .mark

/-- Same case list and names as `sc_fixtures.ml`. -/
def fixtures : List (String × Command FixAct) :=
  [ ("call_ok", ok), ("call_late_error", late),
    ("and_ok_mark", .andThen ok mark), ("and_late_mark", .andThen late mark),
    ("or_late_mark", .orElse late mark), ("or_ok_mark", .orElse ok mark),
    ("seq_late_mark", .seq late mark),
    ("and_or_nested", .andThen (.orElse late mark) ok),
    ("and_late_nested", .andThen late (.orElse mark ok)),
    ("seq_ok_late", .seq ok late),
    ("seq_seq_and", .seq (.seq ok late) (.andThen ok mark)) ]

def jsonString (s : String) : String :=
  "\"" ++ (s.replace "\\" "\\\\").replace "\"" "\\\"" ++ "\""

def Summary.toJson (name command : String) (s : Summary) : String :=
  "{\"mode\": \"lean\", \"name\": " ++ jsonString name ++ ", \"command\": " ++ jsonString command
    ++ ", \"outcome\": " ++ jsonString s.outcome
    ++ (match s.rc with | some n => ", \"rc\": " ++ toString n | none => "")
    ++ (match s.stdout with | some t => ", \"stdout\": " ++ jsonString t | none => "") ++ "}"

def commandText : Command FixAct → String
  | .call .relayOk => "relay_ok"
  | .call .relayLateError => "relay_late_error"
  | .call .mark => "mark"
  | .call .noReturn => "noreturn"
  | .seq a b => "(" ++ commandText a ++ " ; " ++ commandText b ++ ")"
  | .andThen a b => "(" ++ commandText a ++ " && " ++ commandText b ++ ")"
  | .orElse a b => "(" ++ commandText a ++ " || " ++ commandText b ++ ")"

/-- JSON lines for the empirical comparison with the OCaml interpreter run. -/
def fixtureJson : List String :=
  (fixtures.map fun (n, c) => (runFixture c).toJson n (commandText c))
    ++ [ (runFixture (.call .noReturn)).toJson "control_noreturn_action" "noreturn" ]

/-! The fixture-specific values (for example `relay_late_error && mark` giving rc 1 and
    stdout `abc`) are checked by `#eval` and the external comparison, not by `decide`:
    Lean 4.31 string literals do not reduce under `decide`/`rfl`. The general theorems above
    cover every fixture command; `FragmentMain` prints `fixtureJson`. -/

end CalculusFragment
