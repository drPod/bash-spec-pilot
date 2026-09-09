import CalculusRelaySchedules
open CalculusNested CalculusExport CalculusBody CalculusSimulation CalculusRelayLoop
  CalculusRelayOuter CalculusRelaySpec CalculusRelaySchedules

/- Exact shared root state for repeated calculus relay calls. No fresh-state reset,
   C/Coq import, file-store semantics or interpreter simulation assumption. -/
namespace CalculusRelayShared

structure QueryWorld where
  input : List UInt8
  reads : List Int
  writes : List Int
  delivered : List UInt8
  lost : List UInt8
  readCalls : Int
  writeCalls : Int

def Related (st : St) (w : QueryWorld) : Prop :=
  OuterExactSchedules st w.readCalls w.writeCalls (toInts w.delivered)
    (toInts w.lost) w.input w.reads w.writes

structure Headroom (w : QueryWorld) : Prop where
  read_min : minInt ≤ w.readCalls
  read_max : w.readCalls + ((w.input.length : Int) + 1) ≤ maxInt
  write_min : minInt ≤ w.writeCalls
  write_max : w.writeCalls + (w.input.length : Int) ≤ maxInt

def result (w : QueryWorld) : BufferRelay.Detailed :=
  BufferRelay.runDetailed w.input w.reads w.writes

def advance (w : QueryWorld) : QueryWorld :=
  let d := result w
  { input := d.remaining
    reads := w.reads.drop d.readCalls
    writes := w.writes.drop d.writeCalls
    delivered := w.delivered ++ d.output
    lost := w.lost ++ d.pending
    readCalls := w.readCalls + (d.readCalls : Int)
    writeCalls := w.writeCalls + (d.writeCalls : Int) }

/-- Prologue preserves every root attribute; prior block scratch is intentionally replaced. -/
theorem related_prologue (st : St) (w : QueryWorld) (h : Related st w) :
    Related (relayPrologueState st) w := by
  exact { hinp := h.hinp, hrc := h.hrc, hwc := h.hwc, hdv := h.hdv, hls := h.hls,
          hrs := h.hrs, hws := h.hws }

/-- Real relay body on an arbitrary related root state; all seven fields and exact
    status are preserved, including prior counters/delivered/lost prefixes. -/
theorem relay_body_shared (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody)
    (fuel : Nat) (st : St) (w : QueryWorld)
    (hr : Related st w) (hb : Headroom w) :
    ∃ env' st',
      interp actDef (fuel + 2 * w.input.length + 109) relayBody
        (calleeEnv (.v (.lit .unit))) st =
        .ret (.lit (.int ((result w).status : Int))) env' st' ∧
      Related st' (advance w) := by
  have hp := related_prologue st w hr
  obtain ⟨env', st', he, hx⟩ := relay_outer_schedules actDef hwb hrb blockPath (by decide)
    w.input.length fuel (fun _ => 0) relayPrologueEnv (relayPrologueState st)
    w.input w.reads w.writes w.readCalls w.writeCalls (toInts w.delivered) (toInts w.lost)
    (Nat.le_refl _) (lookup_assocSet_same _ _ _)
    (by simp [relayPrologueEnv, calleeEnv, lookup_assocSet_other, lookup])
    (by simp [blockPath, relayPrologueState, relayBlockInit, getAttrAt, lookup_assocSet_same, lookup])
    hp.hrs hp.hws hp.toOuterExact (toInts_bytes _) (toInts_bytes _)
    hb.read_min hb.read_max hb.write_min hb.write_max
  refine ⟨env', st', ?_, ?_⟩
  · have h := relay_prologue actDef (fuel + 2 * w.input.length + 102) st
    rw [show fuel + 2 * w.input.length + 102 + 7 = fuel + 2 * w.input.length + 109 by omega,
      show fuel + 2 * w.input.length + 102 + 1 = fuel + 2 * w.input.length + 103 by omega] at h
    rw [h]
    exact he
  · have hs := OuterExactSchedules.residuals_drop st'
      (w.readCalls + ((BufferRelay.execute (fun _ => 0) w.input w.reads w.writes).readCalls : Int))
      (w.writeCalls + ((BufferRelay.execute (fun _ => 0) w.input w.reads w.writes).writeCalls : Int))
      (toInts w.delivered ++ toInts (BufferRelay.execute (fun _ => 0) w.input w.reads w.writes).output)
      (toInts w.lost ++ toInts (BufferRelay.execute (fun _ => 0) w.input w.reads w.writes).pending)
      (BufferRelay.execute (fun _ => 0) w.input w.reads w.writes).remaining
      (fun _ => 0) w.input w.reads w.writes hx
    refine { hinp := hx.hinp, hrc := hx.hrc, hwc := hx.hwc, hdv := ?_, hls := ?_, hrs := hs.1, hws := hs.2 }
    · simpa only [advance, result, BufferRelay.runDetailed, toInts_append] using hx.hdv
    · simpa only [advance, result, BufferRelay.runDetailed, toInts_append] using hx.hls

/-- An action call preserves the actual caller environment except its result variable.
    This is the compositional form, stronger than a fresh initEnv invocation. -/
theorem relay_action_shared (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody)
    (hrelay : actDef "relay" = relayBody)
    (fuel : Nat) (env : Env) (name : String) (st : St) (w : QueryWorld)
    (hr : Related st w) (hb : Headroom w) :
    ∃ st', interp actDef (fuel + 2 * w.input.length + 110)
      (.action name "relay" (.lit .unit)) env st =
      .continue (assocSet env name (.v (.lit (.int ((result w).status : Int))))) st' ∧
      Related st' (advance w) := by
  obtain ⟨env', st', he, hx⟩ := relay_body_shared actDef hwb hrb fuel st w hr hb
  refine ⟨st', ?_, hx⟩
  rw [show fuel + 2 * w.input.length + 110 = (fuel + 2 * w.input.length + 109) + 1 by omega,
    interp_succ_action]
  simp only [evalExpr, hrelay, he]

theorem relay_entry_shared (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody)
    (hrelay : actDef "relay" = relayBody)
    (fuel : Nat) (st : St) (w : QueryWorld)
    (hr : Related st w) (hb : Headroom w) :
    ∃ st', runEntry actDef (fuel + 2 * w.input.length + 110) "relay" st =
      .continue (assocSet initEnv "rc" (.v (.lit (.int ((result w).status : Int))))) st' ∧
      Related st' (advance w) :=
  relay_action_shared actDef hwb hrb hrelay fuel initEnv "rc" st w hr hb

#print axioms related_prologue
#print axioms relay_body_shared
#print axioms relay_action_shared
#print axioms relay_entry_shared
end CalculusRelayShared
