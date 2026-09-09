import CalculusRelayShared
import ShellObservation
open CalculusNested CalculusExport CalculusBody CalculusSimulation CalculusRelayLoop
  CalculusRelayOuter CalculusRelaySpec CalculusRelaySchedules CalculusRelayShared
  ShellObservation

set_option linter.unusedSimpArgs false

/-!
# CalculusCommands: the phase3 command grammar executed by the actual Nested calculus

The command grammar is the accepted `ShellObservation.Command` over a two-letter alphabet:
the real exported `relay` action and a `mark` action whose body is an actual Nested
statement (append one byte to the root `delivered` list, return 0). Commands are encoded
into `CalculusNested.Stmt String` (action / seq / cond on the caller's `rc`) and executed by
the actual `CalculusNested.interp`. The exact world model is the accepted seven-field
`CalculusRelayShared.QueryWorld`; every relay call goes through the accepted
`relay_action_shared`, so no interpreter behaviour is assumed.

Explicit premises of every theorem: the four action-body identities (`write_block`,
`read_block`, `relay` are the exported bodies; `mark` is `markBody`), a syntactic relay
budget with cumulative integer headroom (`Budget`), and a structural fuel bound.
Not claimed: anything about the OCaml program, query text, redirections, or file stores. -/

namespace CalculusCommands

/-! ## Alphabet, mark body, exact world step -/

inductive Atom where
  | relay
  | mark
  deriving DecidableEq, Repr

def markByte : UInt8 := 33

/-- The `mark` action, as a Nested body: `$m := σ.delivered; σ.delivered := $m ++ [33];
    return 0`. -/
def markBody : Stmt String :=
  .seq (.get "$m" (.var "σ") "delivered")
    (.seq (.setAttr (.var "σ") "delivered"
        (.fn .append (.pair (.var "$m") (.fn .single (.lit (.int 33))))))
      (.ret (.lit (.int 0))))

def atomName : Atom → String
  | .relay => "relay"
  | .mark => "mark"

def markAdvance (w : QueryWorld) : QueryWorld := { w with delivered := w.delivered ++ [markByte] }

/-- Exact per-atom world step: `relay` is `BufferRelay.runDetailed` on the current input and
    schedules (accumulating counters/delivered/lost), `mark` appends one byte. -/
def atomStep : Atom → QueryWorld → Nat × QueryWorld
  | .relay, w => ((result w).status, advance w)
  | .mark, w => (0, markAdvance w)

def atomPrim : Primitive Atom QueryWorld := fun a w rc w' => atomStep a w = (rc, w')

theorem toInts_markByte : toInts [markByte] = [33] := by
  first | rfl | decide

/-! ## The mark body on any related state -/

theorem mark_body (actDef : String → Stmt String) (fuel : Nat) (env : Env)
    (hσ : lookup env "σ" = some (.sref .here)) (st : St) (w : QueryWorld) (hr : Related st w) :
    ∃ st', interp actDef (fuel + 3) markBody env st =
        .ret (.lit (.int 0)) (assocSet env "$m" (.v (Val.ofIntList (toInts w.delivered)))) st' ∧
      Related st' (markAdvance w) := by
  obtain ⟨st', hset⟩ := setAttrAt_isSome_of_getAttrAt .here st "delivered" "delivered" _
    (Val.ofIntList (toInts w.delivered ++ [33])) hr.hdv
  have hσ' : lookup (assocSet env "$m" (.v (Val.ofIntList (toInts w.delivered)))) "σ" =
      some (.sref .here) := by
    rw [lookup_assocSet_other env "$m" "σ" _ (by decide)]; exact hσ
  have h33 : funcDef .single (.lit (.int 33)) = some (Val.ofIntList [33]) := by
    first | rfl | decide | simp [funcDef]
  have h33b : [(33 : Int)].all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true := by decide
  have happ := funcDef_append (toInts w.delivered) [33] (toInts_bytes w.delivered) h33b
  have hval : evalExpr (assocSet env "$m" (.v (Val.ofIntList (toInts w.delivered))))
      (.fn .append (.pair (.var "$m") (.fn .single (.lit (.int 33))))) =
      some (.v (Val.ofIntList (toInts w.delivered ++ [33]))) := by
    simp only [evalExpr, lookup_assocSet_same, h33, Option.map_some, happ, ne_eq, not_false_eq_true]
  refine ⟨st', ?_, ?_⟩
  · simp only [markBody, interp_succ_seq, interp_succ_get, interp_succ_setAttr, interp_succ_ret,
      evalExpr, hσ, hr.hdv, hσ', hval, lookup_assocSet_same, h33, Option.map_some, happ, hset,
      ne_eq, not_false_eq_true]
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

/-- The `mark` action call: caller environment preserved except the result variable. -/
theorem mark_action (actDef : String → Stmt String) (hmark : actDef "mark" = markBody)
    (fuel : Nat) (env : Env) (name : String) (st : St) (w : QueryWorld) (hr : Related st w) :
    ∃ st', interp actDef (fuel + 4) (.action name "mark" (.lit .unit)) env st =
        .continue (assocSet env name (.v (.lit (.int 0)))) st' ∧ Related st' (markAdvance w) := by
  obtain ⟨st', he, hx⟩ := mark_body actDef fuel (calleeEnv (.v (.lit .unit)))
    (by simp [calleeEnv, lookup]) st w hr
  refine ⟨st', ?_, hx⟩
  rw [show fuel + 4 = (fuel + 3) + 1 by omega, interp_succ_action]
  simp only [evalExpr, hmark, he]

/-! ## Functional command evaluation and the phase3 `Exec` relation -/

def runCmd : Command Atom → QueryWorld → Nat × QueryWorld
  | .call a, w => atomStep a w
  | .seq a b, w => runCmd b (runCmd a w).2
  | .andThen a b, w => if (runCmd a w).1 = 0 then runCmd b (runCmd a w).2 else runCmd a w
  | .orElse a b, w => if (runCmd a w).1 = 0 then runCmd a w else runCmd b (runCmd a w).2

theorem runCmd_sound : ∀ (cmd : Command Atom) (w : QueryWorld) (rc : Nat) (w' : QueryWorld),
    runCmd cmd w = (rc, w') → Exec atomPrim cmd w rc w' := by
  intro cmd
  induction cmd with
  | call a =>
    intro w rc w' h
    exact .call h
  | seq a b iha ihb =>
    intro w rc w' h
    rcases hra : runCmd a w with ⟨rc₁, u⟩
    simp only [runCmd, hra] at h
    exact .seq (iha w rc₁ u hra) (ihb u rc w' h)
  | andThen a b iha ihb =>
    intro w rc w' h
    rcases hra : runCmd a w with ⟨rc₁, u⟩
    simp only [runCmd, hra] at h
    by_cases hz : rc₁ = 0
    · subst hz
      simp only [↓reduceIte] at h
      exact .andZero (iha w 0 u hra) (ihb u rc w' h)
    · simp only [hz, ↓reduceIte, Prod.mk.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      exact .andNonzero (iha w rc₁ u hra) hz
  | orElse a b iha ihb =>
    intro w rc w' h
    rcases hra : runCmd a w with ⟨rc₁, u⟩
    simp only [runCmd, hra] at h
    by_cases hz : rc₁ = 0
    · subst hz
      simp only [↓reduceIte, Prod.mk.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      exact .orZero (iha w 0 u hra)
    · simp only [hz, ↓reduceIte] at h
      exact .orNonzero (iha w rc₁ u hra) hz (ihb u rc w' h)

theorem runCmd_complete (cmd : Command Atom) (w : QueryWorld) (rc : Nat) (w' : QueryWorld)
    (h : Exec atomPrim cmd w rc w') : runCmd cmd w = (rc, w') := by
  induction h with
  | call h => exact h
  | seq _ _ ih₁ ih₂ => simp [runCmd, ih₁, ih₂]
  | andZero _ _ ih₁ ih₂ => simp [runCmd, ih₁, ih₂]
  | andNonzero _ hn ih => simp [runCmd, ih, hn]
  | orZero _ ih => simp [runCmd, ih]
  | orNonzero _ hn _ ih₁ ih₂ => simp [runCmd, ih₁, ih₂, hn]

/-- The functional evaluator and the phase3 relation agree exactly (so every command has
    exactly one execution: `Exec` here is total and deterministic). -/
theorem runCmd_iff_exec (cmd : Command Atom) (w : QueryWorld) (rc : Nat) (w' : QueryWorld) :
    runCmd cmd w = (rc, w') ↔ Exec atomPrim cmd w rc w' :=
  ⟨runCmd_sound cmd w rc w', runCmd_complete cmd w rc w'⟩

/-! ## Syntactic relay budget and the cumulative headroom invariant -/

/-- Number of `relay` calls in the command, counting both branches (an upper bound on the
    number of relay calls any execution makes). -/
def relayBudget : Command Atom → Nat
  | .call .relay => 1
  | .call .mark => 0
  | .seq a b => relayBudget a + relayBudget b
  | .andThen a b => relayBudget a + relayBudget b
  | .orElse a b => relayBudget a + relayBudget b

/-- Headroom for `b` more relay calls, each on an input of at most `L` bytes: every relay
    call consumes at most `input.length + 1` reads and `input.length` writes (including the
    EOF and read-error calls, which consume one read on empty/unchanged input). -/
structure Budget (b L : Nat) (w : QueryWorld) : Prop where
  len : w.input.length ≤ L
  read_min : minInt ≤ w.readCalls
  read_max : w.readCalls + ((b * (L + 1) : Nat) : Int) ≤ maxInt
  write_min : minInt ≤ w.writeCalls
  write_max : w.writeCalls + ((b * L : Nat) : Int) ≤ maxInt

theorem remaining_length_le (w : QueryWorld) :
    (result w).remaining.length ≤ w.input.length := by
  have h := (BufferRelay.execute_contract (fun _ => 0) w.input w.reads w.writes).1
  have h' := congrArg List.length h
  simp only [List.length_append] at h'
  show (BufferRelay.execute (fun _ => 0) w.input w.reads w.writes).remaining.length ≤ _
  omega

theorem call_bounds (w : QueryWorld) :
    (result w).readCalls ≤ w.input.length + 1 ∧ (result w).writeCalls ≤ w.input.length :=
  (BufferRelay.execute_contract (fun _ => 0) w.input w.reads w.writes).2.2.2.2.2

theorem Budget.headroom {b L : Nat} {w : QueryWorld} (h : Budget (b + 1) L w) : Headroom w := by
  have h1 : (b + 1) * (L + 1) = b * (L + 1) + (L + 1) := Nat.succ_mul _ _
  have h2 : (b + 1) * L = b * L + L := Nat.succ_mul _ _
  have hge1 : L + 1 ≤ (b + 1) * (L + 1) := by rw [h1]; exact Nat.le_add_left _ _
  have hge2 : L ≤ (b + 1) * L := by rw [h2]; exact Nat.le_add_left _ _
  have hl := h.len
  have hr := h.read_max
  have hw := h.write_max
  exact { read_min := h.read_min, read_max := by omega,
          write_min := h.write_min, write_max := by omega }

theorem Budget.relay_step {b L : Nat} {w : QueryWorld} (h : Budget (b + 1) L w) :
    Budget b L (advance w) := by
  have h1 : (b + 1) * (L + 1) = b * (L + 1) + (L + 1) := Nat.succ_mul _ _
  have h2 : (b + 1) * L = b * L + L := Nat.succ_mul _ _
  have hl := h.len
  have hr := h.read_max
  have hw := h.write_max
  have hrm := h.read_min
  have hwm := h.write_min
  have hrem := remaining_length_le w
  have hc := call_bounds w
  exact { len := by show (result w).remaining.length ≤ L; omega,
          read_min := by show minInt ≤ w.readCalls + ((result w).readCalls : Int); omega,
          read_max := by
            show w.readCalls + ((result w).readCalls : Int) + ((b * (L + 1) : Nat) : Int) ≤ maxInt
            omega,
          write_min := by show minInt ≤ w.writeCalls + ((result w).writeCalls : Int); omega,
          write_max := by
            show w.writeCalls + ((result w).writeCalls : Int) + ((b * L : Nat) : Int) ≤ maxInt
            omega }

theorem Budget.mark_step {b L : Nat} {w : QueryWorld} (h : Budget b L w) :
    Budget b L (markAdvance w) :=
  { len := h.len, read_min := h.read_min, read_max := h.read_max,
    write_min := h.write_min, write_max := h.write_max }

theorem Budget.mono {b b' L : Nat} {w : QueryWorld} (hb : b ≤ b') (h : Budget b' L w) :
    Budget b L w := by
  have h1 : b * (L + 1) ≤ b' * (L + 1) := Nat.mul_le_mul_right _ hb
  have h2 : b * L ≤ b' * L := Nat.mul_le_mul_right _ hb
  have hr := h.read_max
  have hw := h.write_max
  exact { len := h.len, read_min := h.read_min, read_max := by omega,
          write_min := h.write_min, write_max := by omega }

/-! ## The Nested encoder and its structural fuel bound -/

def rcZero : Expr := .fn .eq (.pair (.var "rc") (.lit (.int 0)))

def encodeCmd : Command Atom → Stmt String
  | .call a => .action "rc" (atomName a) (.lit .unit)
  | .seq a b => .seq (encodeCmd a) (encodeCmd b)
  | .andThen a b => .seq (encodeCmd a) (.cond rcZero (encodeCmd b) .pass)
  | .orElse a b => .seq (encodeCmd a) (.cond rcZero .pass (encodeCmd b))

/-- Structural fuel overhead of the encoding (Nested decrements at every syntax layer; both
    `seq` children get the same decremented fuel, so the bound is a max, not a sum). Total
    fuel used below: `fuelCost cmd + 2 * L + 110`. -/
def fuelCost : Command Atom → Nat
  | .call _ => 0
  | .seq a b => max (fuelCost a) (fuelCost b) + 1
  | .andThen a b => max (fuelCost a) (fuelCost b + 1) + 1
  | .orElse a b => max (fuelCost a) (fuelCost b + 1) + 1

theorem evalExpr_rcZero (env : Env) (rc : Nat)
    (h : lookup env "rc" = some (.v (.lit (.int rc)))) :
    evalExpr env rcZero = some (.v (.lit (.bool (decide (rc = 0))))) := by
  have hiff : ((rc : Int) = 0 ↔ rc = 0) := by omega
  simp only [rcZero, evalExpr, h, funcDef_eq_int, Option.map_some, decide_eq_decide.mpr hiff]

set_option maxHeartbeats 1000000 in
/-- Every encoded command, on every related state with budget, is executed by the actual
    Nested interpreter to exactly the functional evaluation: same status in the caller's
    result variable (rest of the caller environment untouched), final state related to the
    exact world, remaining budget preserved. -/
theorem encode_run (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody)
    (hrelay : actDef "relay" = relayBody)
    (hmark : actDef "mark" = markBody) (L : Nat) :
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
      obtain ⟨st', he, hx⟩ := mark_action actDef hmark (fuel + fuelCost (.call .mark) + 2 * L + 106)
        env "rc" st w hr
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

/-! ## Inversion: every successful interpreter run, at ANY fuel, is the exact evaluation -/

/-- Determinism plus fuel monotonicity: whatever fuel the interpreter was given, a
    `.continue` result of an encoded command is the functional evaluation. -/
theorem encode_sound (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody)
    (hrelay : actDef "relay" = relayBody)
    (hmark : actDef "mark" = markBody) (L : Nat)
    (cmd : Command Atom) (k F : Nat) (env : Env) (st : St) (w : QueryWorld)
    (hr : Related st w) (hb : Budget (k + relayBudget cmd) L w) (env' : Env) (st' : St)
    (he : interp actDef F (encodeCmd cmd) env st = .continue env' st') :
    env' = assocSet env "rc" (.v (.lit (.int ((runCmd cmd w).1 : Int)))) ∧
      Related st' (runCmd cmd w).2 ∧ Budget k L (runCmd cmd w).2 := by
  obtain ⟨st'', h, hr', hb'⟩ := encode_run actDef hwb hrb hrelay hmark L cmd k F env st w hr hb
  have hm := interp_fuel_mono_le actDef F (F + fuelCost cmd + 2 * L + 110) (encodeCmd cmd)
    env st (by omega) (by rw [he]; intro h; cases h)
  rw [h, he] at hm
  injection hm with h1 h2
  subst h1
  subst h2
  exact ⟨rfl, hr', hb'⟩

/-- Query transfer with the proved bridge in place of an assumed primitive simulation: a
    Lean predicate `Q` that holds of every abstract execution holds of the state and status
    the actual interpreter produced. -/
theorem encoded_query_sound (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody)
    (hrelay : actDef "relay" = relayBody)
    (hmark : actDef "mark" = markBody) (L : Nat)
    (cmd : Command Atom) (k F : Nat) (env : Env) (st : St) (w : QueryWorld)
    (hr : Related st w) (hb : Budget (k + relayBudget cmd) L w)
    (Q : Nat → QueryWorld → Prop)
    (hq : ∀ rc w', Exec atomPrim cmd w rc w' → Q rc w') (env' : Env) (st' : St)
    (he : interp actDef F (encodeCmd cmd) env st = .continue env' st') :
    ∃ (rc : Nat) (w' : QueryWorld), Related st' w' ∧ Budget k L w' ∧ Q rc w' ∧
      env' = assocSet env "rc" (.v (.lit (.int (rc : Int)))) := by
  obtain ⟨h1, h2, h3⟩ := encode_sound actDef hwb hrb hrelay hmark L cmd k F env st w hr hb env' st' he
  exact ⟨(runCmd cmd w).1, (runCmd cmd w).2, h2, h3, hq _ _ (runCmd_sound cmd w _ _ rfl), h1⟩

/-! ## Witnesses: `relay && mark` and the error-then-recovery `relay || mark` -/

def relayAndMark : Command Atom := .andThen (.call .relay) (.call .mark)
def relayOrMark : Command Atom := .orElse (.call .relay) (.call .mark)

theorem runCmd_relayAndMark (w : QueryWorld) :
    runCmd relayAndMark w =
      if (result w).status = 0 then (0, markAdvance (advance w))
      else ((result w).status, advance w) := by
  first | rfl | simp only [relayAndMark, runCmd, atomStep]

theorem runCmd_relayOrMark (w : QueryWorld) :
    runCmd relayOrMark w =
      if (result w).status = 0 then ((result w).status, advance w)
      else (0, markAdvance (advance w)) := by
  first | rfl | simp only [relayOrMark, runCmd, atomStep]

/-- Exact effect of `relay && mark`: on success the whole input is delivered, then the mark;
    on failure exactly the relay's own status and byte/schedule effects, no mark. -/
theorem relayAndMark_exact (w : QueryWorld) :
    ((result w).status = 0 →
      runCmd relayAndMark w =
        (0, { advance w with delivered := w.delivered ++ w.input ++ [markByte] }) ∧
      (advance w).input = []) ∧
    ((result w).status ≠ 0 → runCmd relayAndMark w = ((result w).status, advance w)) := by
  constructor
  · intro h0
    have hx := BufferRelay.run_success_exact w.input w.reads w.writes h0
    have ho : (result w).output = w.input := hx.1
    have hrem : (result w).remaining = [] := hx.2
    have hd : (advance w).delivered = w.delivered ++ w.input := by
      show w.delivered ++ (result w).output = _
      rw [ho]
    rw [runCmd_relayAndMark, if_pos h0]
    refine ⟨?_, hrem⟩
    show (0, { advance w with delivered := (advance w).delivered ++ [markByte] }) = _
    rw [hd]
  · intro h0
    rw [runCmd_relayAndMark, if_neg h0]

/-- Universal query over every execution of `relay && mark` (exact bytes, not just lengths). -/
theorem relayAndMark_query (w : QueryWorld) (rc : Nat) (w' : QueryWorld)
    (h : Exec atomPrim relayAndMark w rc w') :
    (rc = 0 → w'.input = [] ∧ w'.delivered = w.delivered ++ w.input ++ [markByte]) ∧
    (rc ≠ 0 → rc = (result w).status ∧ w'.delivered = w.delivered ++ (result w).output) := by
  have hr := runCmd_complete _ _ _ _ h
  by_cases h0 : (result w).status = 0
  · obtain ⟨hrun, hinp⟩ := (relayAndMark_exact w).1 h0
    rw [hrun] at hr
    injection hr with h1 h2
    subst h1
    subst h2
    exact ⟨fun _ => ⟨hinp, rfl⟩, fun hne => absurd rfl hne⟩
  · have hrun := (relayAndMark_exact w).2 h0
    rw [hrun] at hr
    injection hr with h1 h2
    subst h1
    subst h2
    exact ⟨fun hz => absurd hz h0, fun _ => ⟨rfl, rfl⟩⟩

/-- `relay || mark` always ends with status 0: recovery after any relay failure. -/
theorem relayOrMark_status (w : QueryWorld) (rc : Nat) (w' : QueryWorld)
    (h : Exec atomPrim relayOrMark w rc w') : rc = 0 := by
  have hr := runCmd_complete _ _ _ _ h
  rw [runCmd_relayOrMark] at hr
  by_cases h0 : (result w).status = 0
  · rw [if_pos h0] at hr
    injection hr with h1 _
    omega
  · rw [if_neg h0] at hr
    injection hr with h1 _
    exact h1.symm

/-- Error-then-recovery, exactly: a scheduled read error makes `relay` return 1 consuming one
    read call and nothing else; `mark` then recovers with one appended byte and status 0. -/
theorem relayOrMark_read_error (w : QueryWorld) (rs : List Int) (hrs : w.reads = -1 :: rs) :
    runCmd relayOrMark w =
      (0, { w with reads := rs, readCalls := w.readCalls + 1,
                   delivered := w.delivered ++ [markByte] }) := by
  have hex : result w = ⟨[], w.input, [], 1, 1, 0⟩ := by
    show BufferRelay.execute (fun _ => 0) w.input w.reads w.writes = _
    rw [hrs]
    exact BufferRelay.execute_read_error _ _ _ _ (-1) rs rfl (by decide)
  have h0 : (result w).status ≠ 0 := by rw [hex]; show (1 : Nat) ≠ 0; decide
  have hadv : advance w = { w with reads := rs, readCalls := w.readCalls + 1 } := by
    simp only [advance, hex, hrs, List.drop_succ_cons, List.drop_zero, List.append_nil,
      Int.ofNat_one, Int.ofNat_zero, Int.add_zero]
  rw [runCmd_relayOrMark, if_neg h0]
  show (0, markAdvance (advance w)) =
    (0, markAdvance { w with reads := rs, readCalls := w.readCalls + 1 })
  rw [hadv]

/-- The same, at the interpreter: from any related state, the encoded `relay || mark` on a
    read-error schedule returns `rc = 0` and leaves a state related to that exact world. -/
theorem relayOrMark_read_error_nested (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody)
    (hrelay : actDef "relay" = relayBody)
    (hmark : actDef "mark" = markBody) (L k F : Nat) (env : Env) (st : St) (w : QueryWorld)
    (hr : Related st w) (hb : Budget (k + 1) L w) (rs : List Int) (hrs : w.reads = -1 :: rs)
    (env' : Env) (st' : St)
    (he : interp actDef F (encodeCmd relayOrMark) env st = .continue env' st') :
    env' = assocSet env "rc" (.v (.lit (.int 0))) ∧
      Related st' { w with reads := rs, readCalls := w.readCalls + 1,
                           delivered := w.delivered ++ [markByte] } := by
  have hb' : Budget (k + relayBudget relayOrMark) L w := by
    simp only [relayOrMark, relayBudget]; exact hb
  obtain ⟨h1, h2, _⟩ := encode_sound actDef hwb hrb hrelay hmark L relayOrMark k F env st w hr hb'
    env' st' he
  rw [relayOrMark_read_error w rs hrs] at h1 h2
  exact ⟨h1, h2⟩

/-- `relay && mark` at the interpreter: the universal byte-exact query holds of the
    produced state, for every fuel and every related state with one relay of headroom. -/
theorem relayAndMark_nested (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody)
    (hrelay : actDef "relay" = relayBody)
    (hmark : actDef "mark" = markBody) (L k F : Nat) (env : Env) (st : St) (w : QueryWorld)
    (hr : Related st w) (hb : Budget (k + 1) L w) (env' : Env) (st' : St)
    (he : interp actDef F (encodeCmd relayAndMark) env st = .continue env' st') :
    ∃ (rc : Nat) (w' : QueryWorld), Related st' w' ∧ Budget k L w' ∧
      env' = assocSet env "rc" (.v (.lit (.int (rc : Int)))) ∧
      (rc = 0 → w'.input = [] ∧ w'.delivered = w.delivered ++ w.input ++ [markByte]) ∧
      (rc ≠ 0 → rc = (result w).status ∧ w'.delivered = w.delivered ++ (result w).output) := by
  have hb' : Budget (k + relayBudget relayAndMark) L w := by
    simp only [relayAndMark, relayBudget]; exact hb
  obtain ⟨rc, w', hrel, hbud, hq, henv⟩ := encoded_query_sound actDef hwb hrb hrelay hmark L
    relayAndMark k F env st w hr hb' _ (relayAndMark_query w) env' st' he
  exact ⟨rc, w', hrel, hbud, henv, hq.1, hq.2⟩

#print axioms mark_body
#print axioms mark_action
#print axioms runCmd_iff_exec
#print axioms Budget.relay_step
#print axioms encode_run
#print axioms encode_sound
#print axioms encoded_query_sound
#print axioms relayAndMark_query
#print axioms relayOrMark_read_error
#print axioms relayOrMark_read_error_nested
#print axioms relayAndMark_nested

end CalculusCommands
