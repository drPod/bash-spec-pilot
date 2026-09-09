import CalculusCommands
open CalculusNested CalculusExport CalculusBody CalculusSimulation CalculusRelayLoop
  CalculusRelayOuter CalculusRelaySpec CalculusRelaySchedules CalculusRelayShared
  ShellObservation CalculusCommands

set_option linter.unusedSimpArgs false

/-!
# CalculusQuery: a bounded query AST compiled to actual Nested statements

Queries are a small Lean AST over the exit status, the two cumulative call counters and the
lengths of the five root lists, with integer comparisons and `and`/`or`/`not`. A query is
compiled to a Nested statement (`get`s of the seven root attributes, then `assign`/`cond`
on a result variable `q`) and its semantics preservation against `Query.eval` on the exact
world is proved for the actual `CalculusNested.interp`. The script/query connection is one
Nested program `.seq (encodeCmd cmd) q.program` executed from `initEnv`.

Not claimed: a query-text parser (the AST is Lean data), exact-byte queries (only lengths
of the byte lists are expressible in this fragment), or anything about the OCaml program. -/

namespace CalculusQuery

/-! ## Query AST and its meaning on the exact world -/

inductive QAtom where
  | status
  | readCalls
  | writeCalls
  | inputLen
  | deliveredLen
  | lostLen
  | readsLen
  | writesLen
  | const (n : Int)
  deriving DecidableEq, Repr

def QAtom.eval (rc : Nat) (w : QueryWorld) : QAtom → Int
  | .status => rc
  | .readCalls => w.readCalls
  | .writeCalls => w.writeCalls
  | .inputLen => w.input.length
  | .deliveredLen => w.delivered.length
  | .lostLen => w.lost.length
  | .readsLen => w.reads.length
  | .writesLen => w.writes.length
  | .const n => n

inductive Query where
  | eq (a b : QAtom)
  | lt (a b : QAtom)
  | le (a b : QAtom)
  | and (p q : Query)
  | or (p q : Query)
  | not (p : Query)
  deriving DecidableEq, Repr

def Query.eval (rc : Nat) (w : QueryWorld) : Query → Bool
  | .eq a b => decide (a.eval rc w = b.eval rc w)
  | .lt a b => decide (a.eval rc w < b.eval rc w)
  | .le a b => decide (a.eval rc w ≤ b.eval rc w)
  | .and p q => p.eval rc w && q.eval rc w
  | .or p q => p.eval rc w || q.eval rc w
  | .not p => !p.eval rc w

/-! ## Compilation to Nested statements -/

def QAtom.expr : QAtom → Expr
  | .status => .var "rc"
  | .readCalls => .var "$qrc"
  | .writeCalls => .var "$qwc"
  | .inputLen => .fn .length (.var "$qi")
  | .deliveredLen => .fn .length (.var "$qd")
  | .lostLen => .fn .length (.var "$ql")
  | .readsLen => .fn .length (.var "$qrs")
  | .writesLen => .fn .length (.var "$qws")
  | .const n => .lit (.int n)

/-- Load the seven root attributes into query variables. -/
def queryPrologue : Stmt String :=
  .seq (.get "$qi" (.var "σ") "input")
    (.seq (.get "$qd" (.var "σ") "delivered")
      (.seq (.get "$ql" (.var "σ") "lost")
        (.seq (.get "$qrs" (.var "σ") "reads")
          (.seq (.get "$qws" (.var "σ") "writes")
            (.seq (.get "$qrc" (.var "σ") "read_calls")
              (.get "$qwc" (.var "σ") "write_calls"))))))

/-- The v2 short-circuit shape for `and`/`or`; comparisons are builtin `eq`/`lt`/`le`. -/
def Query.compile : Query → Stmt String
  | .eq a b => .assign "q" (.fn .eq (.pair a.expr b.expr))
  | .lt a b => .assign "q" (.fn .lt (.pair a.expr b.expr))
  | .le a b => .assign "q" (.fn .le (.pair a.expr b.expr))
  | .and p q => .seq p.compile (.cond (.var "q") q.compile .pass)
  | .or p q => .seq p.compile (.cond (.var "q") .pass q.compile)
  | .not p => .seq p.compile (.assign "q" (.fn .lnot (.var "q")))

def Query.program (q : Query) : Stmt String := .seq queryPrologue q.compile

/-- Structural fuel bound of the compiled query (prologue needs 7, `program` adds one seq). -/
def Query.fuelCost : Query → Nat
  | .eq _ _ => 1
  | .lt _ _ => 1
  | .le _ _ => 1
  | .and p q => p.fuelCost + q.fuelCost + 3
  | .or p q => p.fuelCost + q.fuelCost + 3
  | .not p => p.fuelCost + 2

/-! ## Semantics preservation -/

/-- The query variables hold the exact world; `rc` holds the status. -/
structure QEnv (env : Env) (rc : Nat) (w : QueryWorld) : Prop where
  hrc : lookup env "rc" = some (.v (.lit (.int rc)))
  hi : lookup env "$qi" = some (.v (Val.ofIntList (toInts w.input)))
  hd : lookup env "$qd" = some (.v (Val.ofIntList (toInts w.delivered)))
  hl : lookup env "$ql" = some (.v (Val.ofIntList (toInts w.lost)))
  hrs : lookup env "$qrs" = some (.v (Val.ofIntList w.reads))
  hws : lookup env "$qws" = some (.v (Val.ofIntList w.writes))
  hqrc : lookup env "$qrc" = some (.v (.lit (.int w.readCalls)))
  hqwc : lookup env "$qwc" = some (.v (.lit (.int w.writeCalls)))

theorem QEnv.setq {env : Env} {rc : Nat} {w : QueryWorld} (h : QEnv env rc w) (v : RVal) :
    QEnv (assocSet env "q" v) rc w :=
  { hrc := by rw [lookup_assocSet_other env "q" "rc" v (by decide)]; exact h.hrc,
    hi := by rw [lookup_assocSet_other env "q" "$qi" v (by decide)]; exact h.hi,
    hd := by rw [lookup_assocSet_other env "q" "$qd" v (by decide)]; exact h.hd,
    hl := by rw [lookup_assocSet_other env "q" "$ql" v (by decide)]; exact h.hl,
    hrs := by rw [lookup_assocSet_other env "q" "$qrs" v (by decide)]; exact h.hrs,
    hws := by rw [lookup_assocSet_other env "q" "$qws" v (by decide)]; exact h.hws,
    hqrc := by rw [lookup_assocSet_other env "q" "$qrc" v (by decide)]; exact h.hqrc,
    hqwc := by rw [lookup_assocSet_other env "q" "$qwc" v (by decide)]; exact h.hqwc }

theorem funcDef_lnot (b : Bool) : funcDef .lnot (.lit (.bool b)) = some (.lit (.bool (!b))) := by
  first | rfl | simp [funcDef]

theorem QAtom.expr_eval (env : Env) (rc : Nat) (w : QueryWorld) (h : QEnv env rc w) :
    ∀ a : QAtom, evalExpr env a.expr = some (.v (.lit (.int (a.eval rc w)))) := by
  intro a
  cases a with
  | status => simp only [QAtom.expr, QAtom.eval, evalExpr, h.hrc]
  | readCalls => simp only [QAtom.expr, QAtom.eval, evalExpr, h.hqrc]
  | writeCalls => simp only [QAtom.expr, QAtom.eval, evalExpr, h.hqwc]
  | inputLen =>
    simp only [QAtom.expr, QAtom.eval, evalExpr, h.hi, funcDef_length, Option.map_some,
      toInts_length, ne_eq, not_false_eq_true]
  | deliveredLen =>
    simp only [QAtom.expr, QAtom.eval, evalExpr, h.hd, funcDef_length, Option.map_some,
      toInts_length, ne_eq, not_false_eq_true]
  | lostLen =>
    simp only [QAtom.expr, QAtom.eval, evalExpr, h.hl, funcDef_length, Option.map_some,
      toInts_length, ne_eq, not_false_eq_true]
  | readsLen =>
    simp only [QAtom.expr, QAtom.eval, evalExpr, h.hrs, funcDef_length, Option.map_some,
      ne_eq, not_false_eq_true]
  | writesLen =>
    simp only [QAtom.expr, QAtom.eval, evalExpr, h.hws, funcDef_length, Option.map_some,
      ne_eq, not_false_eq_true]
  | const n => simp only [QAtom.expr, QAtom.eval, evalExpr]

/-- The compiled query computes exactly `Query.eval` into `q`, leaves the state untouched and
    keeps the query environment. -/
theorem compile_eval (actDef : String → Stmt String) :
    ∀ (q : Query) (fuel : Nat) (env : Env) (st : St) (rc : Nat) (w : QueryWorld),
      QEnv env rc w →
      ∃ env', interp actDef (fuel + q.fuelCost) q.compile env st = .continue env' st ∧
        QEnv env' rc w ∧ lookup env' "q" = some (.v (.lit (.bool (q.eval rc w)))) := by
  intro q
  induction q with
  | eq a b =>
    intro fuel env st rc w h
    refine ⟨assocSet env "q" (.v (.lit (.bool (decide (a.eval rc w = b.eval rc w))))), ?_,
      h.setq _, lookup_assocSet_same _ _ _⟩
    simp only [Query.compile, Query.fuelCost, interp_succ_assign, evalExpr,
      QAtom.expr_eval env rc w h, funcDef_eq_int, Option.map_some, ne_eq, not_false_eq_true]
  | lt a b =>
    intro fuel env st rc w h
    refine ⟨assocSet env "q" (.v (.lit (.bool (decide (a.eval rc w < b.eval rc w))))), ?_,
      h.setq _, lookup_assocSet_same _ _ _⟩
    simp only [Query.compile, Query.fuelCost, interp_succ_assign, evalExpr,
      QAtom.expr_eval env rc w h, funcDef_lt, Option.map_some, ne_eq, not_false_eq_true]
  | le a b =>
    intro fuel env st rc w h
    refine ⟨assocSet env "q" (.v (.lit (.bool (decide (a.eval rc w ≤ b.eval rc w))))), ?_,
      h.setq _, lookup_assocSet_same _ _ _⟩
    simp only [Query.compile, Query.fuelCost, interp_succ_assign, evalExpr,
      QAtom.expr_eval env rc w h, funcDef_le, Option.map_some, ne_eq, not_false_eq_true]
  | and p q ihp ihq =>
    intro fuel env st rc w h
    obtain ⟨env1, h1, hq1, hl1⟩ := ihp fuel env st rc w h
    have e : fuel + Query.fuelCost (.and p q) = ((fuel + p.fuelCost + q.fuelCost + 1) + 1) + 1 := by
      simp only [Query.fuelCost]; omega
    have hmono : interp actDef ((fuel + p.fuelCost + q.fuelCost + 1) + 1) p.compile env st =
        interp actDef (fuel + p.fuelCost) p.compile env st :=
      interp_fuel_mono_le actDef _ _ _ _ _ (by omega) (by rw [h1]; intro h; cases h)
    have hqv : evalExpr env1 (.var "q") = some (.v (.lit (.bool (p.eval rc w)))) := hl1
    cases hpe : p.eval rc w with
    | true =>
      obtain ⟨env2, h2, hq2, hl2⟩ := ihq (fuel + p.fuelCost + 1) env1 st rc w hq1
      have h2' : interp actDef (fuel + p.fuelCost + q.fuelCost + 1) q.compile env1 st =
          .continue env2 st := by
        rw [show fuel + p.fuelCost + q.fuelCost + 1 = fuel + p.fuelCost + 1 + q.fuelCost by omega]
        exact h2
      refine ⟨env2, ?_, hq2, ?_⟩
      · rw [e]
        simp only [Query.compile, interp_succ_seq, interp_succ_cond, hmono, h1, hqv, hpe, h2']
      · rw [hl2]
        show _ = some (RVal.v (Val.lit (Lit.bool (p.eval rc w && q.eval rc w))))
        rw [hpe]
        try rfl
    | false =>
      refine ⟨env1, ?_, hq1, ?_⟩
      · rw [e]
        simp only [Query.compile, interp_succ_seq, interp_succ_cond, interp_succ_pass, hmono, h1,
          hqv, hpe]
      · rw [hl1]
        show _ = some (RVal.v (Val.lit (Lit.bool (p.eval rc w && q.eval rc w))))
        rw [hpe]
        try rfl
  | or p q ihp ihq =>
    intro fuel env st rc w h
    obtain ⟨env1, h1, hq1, hl1⟩ := ihp fuel env st rc w h
    have e : fuel + Query.fuelCost (.or p q) = ((fuel + p.fuelCost + q.fuelCost + 1) + 1) + 1 := by
      simp only [Query.fuelCost]; omega
    have hmono : interp actDef ((fuel + p.fuelCost + q.fuelCost + 1) + 1) p.compile env st =
        interp actDef (fuel + p.fuelCost) p.compile env st :=
      interp_fuel_mono_le actDef _ _ _ _ _ (by omega) (by rw [h1]; intro h; cases h)
    have hqv : evalExpr env1 (.var "q") = some (.v (.lit (.bool (p.eval rc w)))) := hl1
    cases hpe : p.eval rc w with
    | true =>
      refine ⟨env1, ?_, hq1, ?_⟩
      · rw [e]
        simp only [Query.compile, interp_succ_seq, interp_succ_cond, interp_succ_pass, hmono, h1,
          hqv, hpe]
      · rw [hl1]
        show _ = some (RVal.v (Val.lit (Lit.bool (p.eval rc w || q.eval rc w))))
        rw [hpe]
        try rfl
    | false =>
      obtain ⟨env2, h2, hq2, hl2⟩ := ihq (fuel + p.fuelCost + 1) env1 st rc w hq1
      have h2' : interp actDef (fuel + p.fuelCost + q.fuelCost + 1) q.compile env1 st =
          .continue env2 st := by
        rw [show fuel + p.fuelCost + q.fuelCost + 1 = fuel + p.fuelCost + 1 + q.fuelCost by omega]
        exact h2
      refine ⟨env2, ?_, hq2, ?_⟩
      · rw [e]
        simp only [Query.compile, interp_succ_seq, interp_succ_cond, hmono, h1, hqv, hpe, h2']
      · rw [hl2]
        show _ = some (RVal.v (Val.lit (Lit.bool (p.eval rc w || q.eval rc w))))
        rw [hpe]
        try rfl
  | not p ihp =>
    intro fuel env st rc w h
    obtain ⟨env1, h1, hq1, hl1⟩ := ihp fuel env st rc w h
    have e : fuel + Query.fuelCost (.not p) = ((fuel + p.fuelCost) + 1) + 1 := by
      simp only [Query.fuelCost]; omega
    have hmono : interp actDef ((fuel + p.fuelCost) + 1) p.compile env st =
        interp actDef (fuel + p.fuelCost) p.compile env st :=
      interp_fuel_mono_le actDef _ _ _ _ _ (by omega) (by rw [h1]; intro h; cases h)
    refine ⟨assocSet env1 "q" (.v (.lit (.bool (!p.eval rc w)))), ?_, hq1.setq _,
      lookup_assocSet_same _ _ _⟩
    rw [e]
    simp only [Query.compile, interp_succ_seq, interp_succ_assign, hmono, h1, evalExpr, hl1,
      funcDef_lnot, Option.map_some, ne_eq, not_false_eq_true]

/-- Environment after the prologue. -/
def prologueEnv (env : Env) (w : QueryWorld) : Env :=
  assocSet (assocSet (assocSet (assocSet (assocSet (assocSet (assocSet env
    "$qi" (.v (Val.ofIntList (toInts w.input))))
    "$qd" (.v (Val.ofIntList (toInts w.delivered))))
    "$ql" (.v (Val.ofIntList (toInts w.lost))))
    "$qrs" (.v (Val.ofIntList w.reads)))
    "$qws" (.v (Val.ofIntList w.writes)))
    "$qrc" (.v (.lit (.int w.readCalls))))
    "$qwc" (.v (.lit (.int w.writeCalls)))

theorem prologue_run (actDef : String → Stmt String) (fuel : Nat) (env : Env) (st : St)
    (rc : Nat) (w : QueryWorld) (hσ : lookup env "σ" = some (.sref .here))
    (hrc : lookup env "rc" = some (.v (.lit (.int rc)))) (hr : Related st w) :
    interp actDef (fuel + 7) queryPrologue env st = .continue (prologueEnv env w) st ∧
      QEnv (prologueEnv env w) rc w := by
  constructor
  · simp only [queryPrologue, prologueEnv, interp_succ_seq, interp_succ_get, evalExpr, hσ,
      lookup_assocSet_other, ne_eq, not_false_eq_true, String.reduceEq, hr.hinp, hr.hdv, hr.hls,
      hr.hrs, hr.hws, hr.hrc, hr.hwc]
  · refine { hrc := ?_, hi := ?_, hd := ?_, hl := ?_, hrs := ?_, hws := ?_, hqrc := ?_, hqwc := ?_ }
      <;> simp only [prologueEnv, lookup_assocSet_same, lookup_assocSet_other, ne_eq,
        not_false_eq_true, String.reduceEq, hrc]

/-- The whole compiled query program: reads the related state, computes `Query.eval` of the
    status in `rc` and the exact world into `q`, state unchanged. -/
theorem program_run (actDef : String → Stmt String) (fuel : Nat) (q : Query) (env : Env)
    (st : St) (rc : Nat) (w : QueryWorld) (hσ : lookup env "σ" = some (.sref .here))
    (hrc : lookup env "rc" = some (.v (.lit (.int rc)))) (hr : Related st w) :
    ∃ env', interp actDef (fuel + q.fuelCost + 8) q.program env st = .continue env' st ∧
      QEnv env' rc w ∧ lookup env' "q" = some (.v (.lit (.bool (q.eval rc w)))) := by
  obtain ⟨hp, hq⟩ := prologue_run actDef (fuel + q.fuelCost) env st rc w hσ hrc hr
  obtain ⟨env', hc, hq', hl⟩ := compile_eval actDef q (fuel + 7) (prologueEnv env w) st rc w hq
  have hmono : interp actDef (fuel + q.fuelCost + 7) q.compile (prologueEnv env w) st =
      interp actDef (fuel + 7 + q.fuelCost) q.compile (prologueEnv env w) st :=
    interp_fuel_mono_le actDef _ _ _ _ _ (by omega) (by rw [hc]; intro h; cases h)
  refine ⟨env', ?_, hq', hl⟩
  rw [show fuel + q.fuelCost + 8 = (fuel + q.fuelCost + 7) + 1 by omega]
  simp only [Query.program, interp_succ_seq, hp, hmono, hc]

/-! ## Script and query in one Nested program -/

theorem lookup_initEnv_rc_σ (v : RVal) : lookup (assocSet initEnv "rc" v) "σ" = some (.sref .here) := by
  rw [lookup_assocSet_other initEnv "rc" "σ" v (by decide)]
  first | rfl | simp [initEnv, lookup]

/-- The encoded command followed by the compiled query, from the driver's `initEnv`, on any
    related state with budget: the exact world after the command is reached, `rc` is the exact
    status and `q` is the query's value on that status and world. -/
theorem script_query_run (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody)
    (hrelay : actDef "relay" = relayBody)
    (hmark : actDef "mark" = markBody) (L : Nat) (cmd : Command Atom) (q : Query)
    (k fuel : Nat) (st : St) (w : QueryWorld)
    (hr : Related st w) (hb : Budget (k + relayBudget cmd) L w) :
    ∃ env' st', interp actDef (fuel + fuelCost cmd + q.fuelCost + 2 * L + 119)
        (.seq (encodeCmd cmd) q.program) initEnv st = .continue env' st' ∧
      Related st' (runCmd cmd w).2 ∧ Budget k L (runCmd cmd w).2 ∧
      lookup env' "rc" = some (.v (.lit (.int ((runCmd cmd w).1 : Int)))) ∧
      lookup env' "q" = some (.v (.lit (.bool (q.eval (runCmd cmd w).1 (runCmd cmd w).2)))) := by
  obtain ⟨st', h1, hr', hb'⟩ := encode_run actDef hwb hrb hrelay hmark L cmd k
    (fuel + q.fuelCost + 8) initEnv st w hr hb
  obtain ⟨env', h2, hq', hl⟩ := program_run actDef (fuel + fuelCost cmd + 2 * L + 110) q
    (assocSet initEnv "rc" (.v (.lit (.int ((runCmd cmd w).1 : Int))))) st'
    (runCmd cmd w).1 (runCmd cmd w).2 (lookup_initEnv_rc_σ _) (lookup_assocSet_same _ _ _) hr'
  have e1 : fuel + q.fuelCost + 8 + fuelCost cmd + 2 * L + 110 =
      fuel + fuelCost cmd + q.fuelCost + 2 * L + 118 := by omega
  have e2 : fuel + fuelCost cmd + 2 * L + 110 + q.fuelCost + 8 =
      fuel + fuelCost cmd + q.fuelCost + 2 * L + 118 := by omega
  rw [e1] at h1
  rw [e2] at h2
  refine ⟨env', st', ?_, hr', hb', hq'.hrc, hl⟩
  rw [show fuel + fuelCost cmd + q.fuelCost + 2 * L + 119 =
    (fuel + fuelCost cmd + q.fuelCost + 2 * L + 118) + 1 by omega]
  simp only [interp_succ_seq, h1, h2]

/-- A query that holds of every abstract execution is computed as `true` by the actual
    interpreter on every related state with budget. -/
theorem script_query_universal (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody)
    (hrelay : actDef "relay" = relayBody)
    (hmark : actDef "mark" = markBody) (L : Nat) (cmd : Command Atom) (q : Query)
    (k fuel : Nat) (st : St) (w : QueryWorld)
    (hr : Related st w) (hb : Budget (k + relayBudget cmd) L w)
    (hq : ∀ rc w', Exec atomPrim cmd w rc w' → q.eval rc w' = true) :
    ∃ env' st', interp actDef (fuel + fuelCost cmd + q.fuelCost + 2 * L + 119)
        (.seq (encodeCmd cmd) q.program) initEnv st = .continue env' st' ∧
      Related st' (runCmd cmd w).2 ∧ lookup env' "q" = some (.v (.lit (.bool true))) := by
  obtain ⟨env', st', h, hr', _, _, hl⟩ :=
    script_query_run actDef hwb hrb hrelay hmark L cmd q k fuel st w hr hb
  refine ⟨env', st', h, hr', ?_⟩
  rw [hl, hq _ _ (runCmd_sound cmd w _ _ rfl)]

/-! ## Witness queries -/

/-- `status ≠ 0 ∨ 1 ≤ deliveredLen`: "if the command succeeded, something was delivered". -/
def markedOrFailed : Query := .or (.not (.eq .status (.const 0))) (.le (.const 1) .deliveredLen)
/-- `status = 0`. -/
def statusZero : Query := .eq .status (.const 0)

theorem fuelCost_relayAndMark : fuelCost relayAndMark = 2 := by first | rfl | decide
theorem fuelCost_relayOrMark : fuelCost relayOrMark = 2 := by first | rfl | decide
theorem markedOrFailed_fuelCost : markedOrFailed.fuelCost = 7 := by first | rfl | decide
theorem statusZero_fuelCost : statusZero.fuelCost = 1 := by first | rfl | decide

/-- `markedOrFailed` holds of every execution of `relay && mark`. -/
theorem relayAndMark_markedOrFailed (w : QueryWorld) (rc : Nat) (w' : QueryWorld)
    (h : Exec atomPrim relayAndMark w rc w') : markedOrFailed.eval rc w' = true := by
  obtain ⟨hz, hnz⟩ := relayAndMark_query w rc w' h
  simp only [markedOrFailed, Query.eval, QAtom.eval, Bool.or_eq_true, Bool.not_eq_true',
    decide_eq_false_iff_not, decide_eq_true_eq]
  by_cases h0 : rc = 0
  · obtain ⟨_, hd⟩ := hz h0
    have hlen : w.delivered.length + w.input.length + 1 = w'.delivered.length := by
      rw [hd]; simp only [List.length_append, List.length_cons, List.length_nil]
    right
    omega
  · left
    omega

/-- ... but not of `relay` alone: the empty-input, fresh-counter world succeeds with nothing
    delivered. So the query separates `relay && mark` from `relay`. -/
def w0 : QueryWorld := ⟨[], [], [], [], [], 0, 0⟩

theorem relay_alone_not_marked :
    ∃ rc w', Exec atomPrim (.call .relay) w0 rc w' ∧ markedOrFailed.eval rc w' = false := by
  have hex : result w0 = ⟨[], [], [], 0, 1, 0⟩ :=
    BufferRelay.execute_eof (fun _ => 0) [] [] 32 [] rfl (by decide)
  have hadv : advance w0 = ⟨[], [], [], [], [], 1, 0⟩ := by
    simp only [advance, hex]
    rfl
  refine ⟨0, advance w0, ?_, ?_⟩
  · apply runCmd_sound
    show ((result w0).status, advance w0) = _
    rw [hex]
  · rw [hadv]
    decide

/-- `statusZero` holds of every execution of `relay || mark` (recovery). -/
theorem relayOrMark_statusZero (w : QueryWorld) (rc : Nat) (w' : QueryWorld)
    (h : Exec atomPrim relayOrMark w rc w') : statusZero.eval rc w' = true := by
  have h0 := relayOrMark_status w rc w' h
  subst h0
  first | decide | simp [statusZero, Query.eval, QAtom.eval]

/-- Lean-final witness 1: the Nested program `relay && mark ; markedOrFailed` computes
    `q = true` from every related state with one relay of headroom, for every fuel of the
    form `fuel + 2 * L + 128`. -/
theorem relayAndMark_markedOrFailed_nested (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody)
    (hrelay : actDef "relay" = relayBody)
    (hmark : actDef "mark" = markBody) (L k fuel : Nat) (st : St) (w : QueryWorld)
    (hr : Related st w) (hb : Budget (k + 1) L w) :
    ∃ env' st', interp actDef (fuel + 2 * L + 128)
        (.seq (encodeCmd relayAndMark) markedOrFailed.program) initEnv st = .continue env' st' ∧
      Related st' (runCmd relayAndMark w).2 ∧ lookup env' "q" = some (.v (.lit (.bool true))) := by
  have hb' : Budget (k + relayBudget relayAndMark) L w := by
    simp only [relayAndMark, relayBudget]; exact hb
  have h := script_query_universal actDef hwb hrb hrelay hmark L relayAndMark markedOrFailed k
    fuel st w hr hb' (relayAndMark_markedOrFailed w)
  rw [fuelCost_relayAndMark, markedOrFailed_fuelCost,
    show fuel + 2 + 7 + 2 * L + 119 = fuel + 2 * L + 128 by omega] at h
  exact h

/-- Lean-final witness 2: `relay || mark ; statusZero` computes `q = true` from every related
    state with one relay of headroom (error-then-recovery, any schedule). -/
theorem relayOrMark_statusZero_nested (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody)
    (hrelay : actDef "relay" = relayBody)
    (hmark : actDef "mark" = markBody) (L k fuel : Nat) (st : St) (w : QueryWorld)
    (hr : Related st w) (hb : Budget (k + 1) L w) :
    ∃ env' st', interp actDef (fuel + 2 * L + 122)
        (.seq (encodeCmd relayOrMark) statusZero.program) initEnv st = .continue env' st' ∧
      Related st' (runCmd relayOrMark w).2 ∧ lookup env' "q" = some (.v (.lit (.bool true))) := by
  have hb' : Budget (k + relayBudget relayOrMark) L w := by
    simp only [relayOrMark, relayBudget]; exact hb
  have h := script_query_universal actDef hwb hrb hrelay hmark L relayOrMark statusZero k
    fuel st w hr hb' (relayOrMark_statusZero w)
  rw [fuelCost_relayOrMark, statusZero_fuelCost,
    show fuel + 2 + 1 + 2 * L + 119 = fuel + 2 * L + 122 by omega] at h
  exact h


/-! ## Bridge to the exported `mark` body

`CalculusCommands.markBody` was written by hand; the peer's `CalculusLowering.markBody`
(exported `mark`, 32 tokens, generated from the TSV) is the same get / setAttr / ret program
with temp `$t27` and left-nested seqs. `exportMarkBody` below is a verbatim copy of that
definition (CalculusLowering.lean sha256 5a994b4b…, line 715); its identity with the peer's
constant is a `rfl` once that module is in the same build. Everything about commands is
restated once more against an abstract `MarkSpec` that both bodies satisfy, so the accepted
command theorems transfer to the exported body without touching the accepted module. -/

def exportMarkBody : Stmt String :=
  (.seq (.seq (.get "$t27" (.var "σ") "delivered") (.setAttr (.var "σ") "delivered" (.fn .append (.pair (.var "$t27") (.fn .single (.lit (.int 33))))))) (.ret (.lit (.int 0))))

theorem export_mark_body (actDef : String → Stmt String) (fuel : Nat) (env : Env)
    (hσ : lookup env "σ" = some (.sref .here)) (st : St) (w : QueryWorld) (hr : Related st w) :
    ∃ st', interp actDef (fuel + 3) exportMarkBody env st =
        .ret (.lit (.int 0)) (assocSet env "$t27" (.v (Val.ofIntList (toInts w.delivered)))) st' ∧
      Related st' (markAdvance w) := by
  obtain ⟨st', hset⟩ := setAttrAt_isSome_of_getAttrAt .here st "delivered" "delivered" _
    (Val.ofIntList (toInts w.delivered ++ [33])) hr.hdv
  have hσ' : lookup (assocSet env "$t27" (.v (Val.ofIntList (toInts w.delivered)))) "σ" =
      some (.sref .here) := by
    rw [lookup_assocSet_other env "$t27" "σ" _ (by decide)]; exact hσ
  have h33 : funcDef .single (.lit (.int 33)) = some (Val.ofIntList [33]) := by
    first | rfl | decide | simp [funcDef]
  have h33b : [(33 : Int)].all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true := by decide
  have happ := funcDef_append (toInts w.delivered) [33] (toInts_bytes w.delivered) h33b
  have hval : evalExpr (assocSet env "$t27" (.v (Val.ofIntList (toInts w.delivered))))
      (.fn .append (.pair (.var "$t27") (.fn .single (.lit (.int 33))))) =
      some (.v (Val.ofIntList (toInts w.delivered ++ [33]))) := by
    simp only [evalExpr, lookup_assocSet_same, h33, Option.map_some, happ, ne_eq, not_false_eq_true]
  refine ⟨st', ?_, ?_⟩
  · simp only [exportMarkBody, interp_succ_seq, interp_succ_get, interp_succ_setAttr,
      interp_succ_ret, evalExpr, hσ, hr.hdv, hσ', hval, lookup_assocSet_same, h33,
      Option.map_some, happ, hset, ne_eq, not_false_eq_true]
  · refine { hinp := ?_, hrc := ?_, hwc := ?_, hdv := ?_, hls := ?_, hrs := ?_, hws := ?_ }
    · rw [setAttrAt_frame _ _ _ _ _ hset .here "input" (Or.inr (by decide))]; exact hr.hinp
    · rw [setAttrAt_frame _ _ _ _ _ hset .here "read_calls" (Or.inr (by decide))]; exact hr.hrc
    · rw [setAttrAt_frame _ _ _ _ _ hset .here "write_calls" (Or.inr (by decide))]; exact hr.hwc
    · show getAttrAt .here st' "delivered" =
        some (Val.ofIntList (toInts (w.delivered ++ [markByte])))
      rw [toInts_append, toInts_markByte]
      exact setAttrAt_same _ _ _ _ _ hset
    · rw [setAttrAt_frame _ _ _ _ _ hset .here "lost" (Or.inr (by decide))]; exact hr.hls
    · rw [setAttrAt_frame _ _ _ _ _ hset .here "reads" (Or.inr (by decide))]; exact hr.hrs
    · rw [setAttrAt_frame _ _ _ _ _ hset .here "writes" (Or.inr (by decide))]; exact hr.hws

/-- The action-level contract of a `mark` body: the only thing the command theorems use. -/
def MarkSpec (actDef : String → Stmt String) : Prop :=
  ∀ (fuel : Nat) (env : Env) (name : String) (st : St) (w : QueryWorld), Related st w →
    ∃ st', interp actDef (fuel + 4) (.action name "mark" (.lit .unit)) env st =
        .continue (assocSet env name (.v (.lit (.int 0)))) st' ∧ Related st' (markAdvance w)

theorem markSpec_of_commands (actDef : String → Stmt String)
    (hmark : actDef "mark" = CalculusCommands.markBody) : MarkSpec actDef :=
  fun fuel env name st w hr => mark_action actDef hmark fuel env name st w hr

theorem markSpec_of_export (actDef : String → Stmt String)
    (hmark : actDef "mark" = exportMarkBody) : MarkSpec actDef := by
  intro fuel env name st w hr
  obtain ⟨st', he, hx⟩ := export_mark_body actDef fuel (calleeEnv (.v (.lit .unit)))
    (by simp [calleeEnv, lookup]) st w hr
  refine ⟨st', ?_, hx⟩
  rw [show fuel + 4 = (fuel + 3) + 1 by omega, interp_succ_action]
  simp only [evalExpr, hmark, he]

set_option maxHeartbeats 1000000 in
/-- `CalculusCommands.encode_run` with the mark body abstracted to its contract. -/
theorem encode_run_spec (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody)
    (hrelay : actDef "relay" = relayBody)
    (hmark : MarkSpec actDef) (L : Nat) :
    ∀ (cmd : Command Atom) (k fuel : Nat) (env : Env) (st : St) (w : QueryWorld),
      Related st w → Budget (k + relayBudget cmd) L w →
      ∃ st', interp actDef (fuel + fuelCost cmd + 2 * L + 110) (encodeCmd cmd) env st =
          .continue (assocSet env "rc" (.v (.lit (.int ((runCmd cmd w).1 : Int))))) st' ∧
        Related st' (runCmd cmd w).2 ∧ Budget k L (runCmd cmd w).2 := by
  intro cmd
  induction cmd with
  | call a =>
    intro k fuel env st w hr hb
    cases a with
    | relay =>
      simp only [relayBudget] at hb
      have hlen := hb.len
      obtain ⟨st', he, hx⟩ := relay_action_shared actDef hwb hrb hrelay
        (fuel + 2 * (L - w.input.length)) env "rc" st w hr hb.headroom
      refine ⟨st', ?_, hx, hb.relay_step⟩
      have e : fuel + fuelCost (.call .relay) + 2 * L + 110 =
          fuel + 2 * (L - w.input.length) + 2 * w.input.length + 110 := by
        simp only [fuelCost]; omega
      rw [e]
      exact he
    | mark =>
      simp only [relayBudget] at hb
      obtain ⟨st', he, hx⟩ := hmark (fuel + fuelCost (.call .mark) + 2 * L + 106) env "rc" st w hr
      refine ⟨st', ?_, hx, hb.mark_step⟩
      have e : fuel + fuelCost (.call .mark) + 2 * L + 110 =
          fuel + fuelCost (.call .mark) + 2 * L + 106 + 4 := by omega
      rw [e]
      exact he
  | seq a b iha ihb =>
    intro k fuel env st w hr hb
    have hba : Budget ((k + relayBudget b) + relayBudget a) L w := by
      have e : (k + relayBudget b) + relayBudget a = k + relayBudget (.seq a b) := by
        simp only [relayBudget]; omega
      rw [e]; exact hb
    obtain ⟨st1, h1, hr1, hb1⟩ := iha (k + relayBudget b) fuel env st w hr hba
    obtain ⟨st2, h2, hr2, hb2⟩ := ihb k fuel
      (assocSet env "rc" (.v (.lit (.int ((runCmd a w).1 : Int))))) st1 (runCmd a w).2 hr1 hb1
    have hma := Nat.le_max_left (fuelCost a) (fuelCost b)
    have hmb := Nat.le_max_right (fuelCost a) (fuelCost b)
    have e : fuel + fuelCost (.seq a b) + 2 * L + 110 =
        (fuel + max (fuelCost a) (fuelCost b) + 2 * L + 110) + 1 := by
      simp only [fuelCost]; omega
    have hmono_a : interp actDef (fuel + max (fuelCost a) (fuelCost b) + 2 * L + 110)
        (encodeCmd a) env st =
        interp actDef (fuel + fuelCost a + 2 * L + 110) (encodeCmd a) env st :=
      interp_fuel_mono_le actDef _ _ _ _ _ (by omega) (by rw [h1]; intro h; cases h)
    have hmono_b : interp actDef (fuel + max (fuelCost a) (fuelCost b) + 2 * L + 110)
        (encodeCmd b) (assocSet env "rc" (.v (.lit (.int ((runCmd a w).1 : Int))))) st1 =
        interp actDef (fuel + fuelCost b + 2 * L + 110) (encodeCmd b)
          (assocSet env "rc" (.v (.lit (.int ((runCmd a w).1 : Int))))) st1 :=
      interp_fuel_mono_le actDef _ _ _ _ _ (by omega) (by rw [h2]; intro h; cases h)
    have hrun : runCmd (.seq a b) w = runCmd b (runCmd a w).2 := rfl
    rw [hrun]
    refine ⟨st2, ?_, hr2, hb2⟩
    rw [e]
    simp only [encodeCmd, interp_succ_seq, hmono_a, h1, hmono_b, h2, assocSet_assocSet_same]
  | andThen a b iha ihb =>
    intro k fuel env st w hr hb
    have hba : Budget ((k + relayBudget b) + relayBudget a) L w := by
      have e : (k + relayBudget b) + relayBudget a = k + relayBudget (.andThen a b) := by
        simp only [relayBudget]; omega
      rw [e]; exact hb
    obtain ⟨st1, h1, hr1, hb1⟩ := iha (k + relayBudget b) fuel env st w hr hba
    have hma := Nat.le_max_left (fuelCost a) (fuelCost b + 1)
    have hmb := Nat.le_max_right (fuelCost a) (fuelCost b + 1)
    have e : fuel + fuelCost (.andThen a b) + 2 * L + 110 =
        (fuel + max (fuelCost a) (fuelCost b + 1) + 2 * L + 109) + 1 + 1 := by
      simp only [fuelCost]; omega
    have hmono_a : interp actDef (fuel + max (fuelCost a) (fuelCost b + 1) + 2 * L + 109 + 1)
        (encodeCmd a) env st =
        interp actDef (fuel + fuelCost a + 2 * L + 110) (encodeCmd a) env st :=
      interp_fuel_mono_le actDef _ _ _ _ _ (by omega) (by rw [h1]; intro h; cases h)
    have hrc : evalExpr (assocSet env "rc" (.v (.lit (.int ((runCmd a w).1 : Int))))) rcZero =
        some (.v (.lit (.bool (decide ((runCmd a w).1 = 0))))) :=
      evalExpr_rcZero _ _ (lookup_assocSet_same _ _ _)
    by_cases hz : (runCmd a w).1 = 0
    · have hdec : decide ((runCmd a w).1 = 0) = true := decide_eq_true hz
      have hrun : runCmd (.andThen a b) w = runCmd b (runCmd a w).2 := by
        rw [runCmd, if_pos hz]
      obtain ⟨st2, h2, hr2, hb2⟩ := ihb k fuel
        (assocSet env "rc" (.v (.lit (.int ((runCmd a w).1 : Int))))) st1 (runCmd a w).2 hr1 hb1
      have hmono_b : interp actDef (fuel + max (fuelCost a) (fuelCost b + 1) + 2 * L + 109)
          (encodeCmd b) (assocSet env "rc" (.v (.lit (.int ((runCmd a w).1 : Int))))) st1 =
          interp actDef (fuel + fuelCost b + 2 * L + 110) (encodeCmd b)
            (assocSet env "rc" (.v (.lit (.int ((runCmd a w).1 : Int))))) st1 :=
        interp_fuel_mono_le actDef _ _ _ _ _ (by omega) (by rw [h2]; intro h; cases h)
      rw [hrun]
      refine ⟨st2, ?_, hr2, hb2⟩
      rw [e]
      simp only [encodeCmd, interp_succ_seq, interp_succ_cond, hmono_a, h1, hrc, hdec, hmono_b,
        h2, assocSet_assocSet_same]
    · have hdec : decide ((runCmd a w).1 = 0) = false := decide_eq_false hz
      have hrun : runCmd (.andThen a b) w = runCmd a w := by
        rw [runCmd, if_neg hz]
      rw [hrun]
      refine ⟨st1, ?_, hr1, hb1.mono (Nat.le_add_right _ _)⟩
      rw [e]
      simp only [encodeCmd, interp_succ_seq, interp_succ_cond, interp_succ_pass, hmono_a, h1,
        hrc, hdec]
  | orElse a b iha ihb =>
    intro k fuel env st w hr hb
    have hba : Budget ((k + relayBudget b) + relayBudget a) L w := by
      have e : (k + relayBudget b) + relayBudget a = k + relayBudget (.orElse a b) := by
        simp only [relayBudget]; omega
      rw [e]; exact hb
    obtain ⟨st1, h1, hr1, hb1⟩ := iha (k + relayBudget b) fuel env st w hr hba
    have hma := Nat.le_max_left (fuelCost a) (fuelCost b + 1)
    have hmb := Nat.le_max_right (fuelCost a) (fuelCost b + 1)
    have e : fuel + fuelCost (.orElse a b) + 2 * L + 110 =
        (fuel + max (fuelCost a) (fuelCost b + 1) + 2 * L + 109) + 1 + 1 := by
      simp only [fuelCost]; omega
    have hmono_a : interp actDef (fuel + max (fuelCost a) (fuelCost b + 1) + 2 * L + 109 + 1)
        (encodeCmd a) env st =
        interp actDef (fuel + fuelCost a + 2 * L + 110) (encodeCmd a) env st :=
      interp_fuel_mono_le actDef _ _ _ _ _ (by omega) (by rw [h1]; intro h; cases h)
    have hrc : evalExpr (assocSet env "rc" (.v (.lit (.int ((runCmd a w).1 : Int))))) rcZero =
        some (.v (.lit (.bool (decide ((runCmd a w).1 = 0))))) :=
      evalExpr_rcZero _ _ (lookup_assocSet_same _ _ _)
    by_cases hz : (runCmd a w).1 = 0
    · have hdec : decide ((runCmd a w).1 = 0) = true := decide_eq_true hz
      have hrun : runCmd (.orElse a b) w = runCmd a w := by
        rw [runCmd, if_pos hz]
      rw [hrun]
      refine ⟨st1, ?_, hr1, hb1.mono (Nat.le_add_right _ _)⟩
      rw [e]
      simp only [encodeCmd, interp_succ_seq, interp_succ_cond, interp_succ_pass, hmono_a, h1,
        hrc, hdec]
    · have hdec : decide ((runCmd a w).1 = 0) = false := decide_eq_false hz
      have hrun : runCmd (.orElse a b) w = runCmd b (runCmd a w).2 := by
        rw [runCmd, if_neg hz]
      obtain ⟨st2, h2, hr2, hb2⟩ := ihb k fuel
        (assocSet env "rc" (.v (.lit (.int ((runCmd a w).1 : Int))))) st1 (runCmd a w).2 hr1 hb1
      have hmono_b : interp actDef (fuel + max (fuelCost a) (fuelCost b + 1) + 2 * L + 109)
          (encodeCmd b) (assocSet env "rc" (.v (.lit (.int ((runCmd a w).1 : Int))))) st1 =
          interp actDef (fuel + fuelCost b + 2 * L + 110) (encodeCmd b)
            (assocSet env "rc" (.v (.lit (.int ((runCmd a w).1 : Int))))) st1 :=
        interp_fuel_mono_le actDef _ _ _ _ _ (by omega) (by rw [h2]; intro h; cases h)
      rw [hrun]
      refine ⟨st2, ?_, hr2, hb2⟩
      rw [e]
      simp only [encodeCmd, interp_succ_seq, interp_succ_cond, hmono_a, h1, hrc, hdec, hmono_b,
        h2, assocSet_assocSet_same]

/-- Script + query, mark body abstracted: a query true of every abstract execution is computed
    as `true` by the actual interpreter. -/
theorem script_query_universal_spec (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody)
    (hrelay : actDef "relay" = relayBody)
    (hmark : MarkSpec actDef) (L : Nat) (cmd : Command Atom) (q : Query)
    (k fuel : Nat) (st : St) (w : QueryWorld)
    (hr : Related st w) (hb : Budget (k + relayBudget cmd) L w)
    (hq : ∀ rc w', Exec atomPrim cmd w rc w' → q.eval rc w' = true) :
    ∃ env' st', interp actDef (fuel + fuelCost cmd + q.fuelCost + 2 * L + 119)
        (.seq (encodeCmd cmd) q.program) initEnv st = .continue env' st' ∧
      Related st' (runCmd cmd w).2 ∧ Budget k L (runCmd cmd w).2 ∧
      lookup env' "rc" = some (.v (.lit (.int ((runCmd cmd w).1 : Int)))) ∧
      lookup env' "q" = some (.v (.lit (.bool true))) := by
  obtain ⟨st', h1, hr', hb'⟩ := encode_run_spec actDef hwb hrb hrelay hmark L cmd k
    (fuel + q.fuelCost + 8) initEnv st w hr hb
  obtain ⟨env', h2, hq', hl⟩ := program_run actDef (fuel + fuelCost cmd + 2 * L + 110) q
    (assocSet initEnv "rc" (.v (.lit (.int ((runCmd cmd w).1 : Int))))) st'
    (runCmd cmd w).1 (runCmd cmd w).2 (lookup_initEnv_rc_σ _) (lookup_assocSet_same _ _ _) hr'
  have e1 : fuel + q.fuelCost + 8 + fuelCost cmd + 2 * L + 110 =
      fuel + fuelCost cmd + q.fuelCost + 2 * L + 118 := by omega
  have e2 : fuel + fuelCost cmd + 2 * L + 110 + q.fuelCost + 8 =
      fuel + fuelCost cmd + q.fuelCost + 2 * L + 118 := by omega
  rw [e1] at h1
  rw [e2] at h2
  refine ⟨env', st', ?_, hr', hb', hq'.hrc, ?_⟩
  · rw [show fuel + fuelCost cmd + q.fuelCost + 2 * L + 119 =
      (fuel + fuelCost cmd + q.fuelCost + 2 * L + 118) + 1 by omega]
    simp only [interp_succ_seq, h1, h2]
  · rw [hl, hq _ _ (runCmd_sound cmd w _ _ rfl)]

/-- Witness 1 with the EXPORTED mark body. -/
theorem relayAndMark_markedOrFailed_export (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody)
    (hrelay : actDef "relay" = relayBody)
    (hmark : actDef "mark" = exportMarkBody) (L k fuel : Nat) (st : St) (w : QueryWorld)
    (hr : Related st w) (hb : Budget (k + 1) L w) :
    ∃ env' st', interp actDef (fuel + 2 * L + 128)
        (.seq (encodeCmd relayAndMark) markedOrFailed.program) initEnv st = .continue env' st' ∧
      Related st' (runCmd relayAndMark w).2 ∧ lookup env' "q" = some (.v (.lit (.bool true))) := by
  have hb' : Budget (k + relayBudget relayAndMark) L w := by
    simp only [relayAndMark, relayBudget]; exact hb
  obtain ⟨env', st', h, hr', _, _, hl⟩ := script_query_universal_spec actDef hwb hrb hrelay
    (markSpec_of_export actDef hmark) L relayAndMark markedOrFailed k fuel st w hr hb'
    (relayAndMark_markedOrFailed w)
  rw [fuelCost_relayAndMark, markedOrFailed_fuelCost,
    show fuel + 2 + 7 + 2 * L + 119 = fuel + 2 * L + 128 by omega] at h
  exact ⟨env', st', h, hr', hl⟩

/-- Witness 2 with the EXPORTED mark body. -/
theorem relayOrMark_statusZero_export (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody)
    (hrelay : actDef "relay" = relayBody)
    (hmark : actDef "mark" = exportMarkBody) (L k fuel : Nat) (st : St) (w : QueryWorld)
    (hr : Related st w) (hb : Budget (k + 1) L w) :
    ∃ env' st', interp actDef (fuel + 2 * L + 122)
        (.seq (encodeCmd relayOrMark) statusZero.program) initEnv st = .continue env' st' ∧
      Related st' (runCmd relayOrMark w).2 ∧ lookup env' "q" = some (.v (.lit (.bool true))) := by
  have hb' : Budget (k + relayBudget relayOrMark) L w := by
    simp only [relayOrMark, relayBudget]; exact hb
  obtain ⟨env', st', h, hr', _, _, hl⟩ := script_query_universal_spec actDef hwb hrb hrelay
    (markSpec_of_export actDef hmark) L relayOrMark statusZero k fuel st w hr hb'
    (relayOrMark_statusZero w)
  rw [fuelCost_relayOrMark, statusZero_fuelCost,
    show fuel + 2 + 1 + 2 * L + 119 = fuel + 2 * L + 122 by omega] at h
  exact ⟨env', st', h, hr', hl⟩

#print axioms compile_eval
#print axioms prologue_run
#print axioms program_run
#print axioms script_query_run
#print axioms script_query_universal
#print axioms relayAndMark_markedOrFailed
#print axioms relay_alone_not_marked
#print axioms relayOrMark_statusZero
#print axioms relayAndMark_markedOrFailed_nested
#print axioms relayOrMark_statusZero_nested
#print axioms export_mark_body
#print axioms markSpec_of_commands
#print axioms markSpec_of_export
#print axioms encode_run_spec
#print axioms script_query_universal_spec
#print axioms relayAndMark_markedOrFailed_export
#print axioms relayOrMark_statusZero_export

end CalculusQuery
