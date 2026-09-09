import BufferRelay

namespace PointerRelay
abbrev Byte := UInt8
abbrev Memory := MemoryTransfer.Memory 32

inductive Control where
  | read | drain | stopped (status : Nat)
  deriving DecidableEq, Repr

structure State where
  buffer : Memory
  initialized : List Byte
  n : Nat
  off : Nat
  input : List Byte
  output : List Byte
  reads : List Int
  writes : List Int
  readCalls : Nat
  writeCalls : Nat
  control : Control

def WellFormed (s : State) : Prop := s.off ≤ s.n ∧ s.n ≤ 32

def slice (m : Memory) (off len : Nat) : List Byte :=
  ((List.ofFn m).drop off).take len

def pending (s : State) : List Byte := slice s.buffer s.off (s.n - s.off)

theorem slice_load (m : Memory) (off len : Nat) (h : off + len ≤ 32) :
    slice m off len = MemoryTransfer.load m off len h := by
  apply List.ext_getElem
  · simp [slice, MemoryTransfer.load]; omega
  · intro i hi hj
    simp only [slice, MemoryTransfer.load, List.getElem_take, List.getElem_drop,
      List.getElem_ofFn]

theorem slice_length (m : Memory) (off len : Nat) (h : off + len ≤ 32) :
    (slice m off len).length = len := by
  simp [slice]; omega

theorem pending_length (s : State) (h : WellFormed s) :
    (pending s).length = s.n - s.off := by
  apply slice_length
  unfold WellFormed at h
  omega

theorem pending_take (s : State) (k : Nat) (hk : k ≤ s.n - s.off) :
    (pending s).take k = slice s.buffer s.off k := by
  simp [pending, slice, List.take_take, Nat.min_eq_left hk]

theorem pending_advance (s : State) (k : Nat) (_hk : k ≤ s.n - s.off) :
    slice s.buffer (s.off + k) (s.n - (s.off + k)) = (pending s).drop k := by
  simp only [pending, slice, List.drop_take, List.drop_drop]
  congr 1
  omega

inductive Kind where
  | read | write
  deriving DecidableEq, Repr

/-- Full requested range and actual transferred bytes are distinct fields.
    The action retains the scheduled error/zero/positive quota. -/
structure Event where
  kind : Kind
  pointer : MemoryTransfer.Pointer
  request : Nat
  action : Int
  bytes : List Byte
  deriving DecidableEq, Repr

def readEvent (s : State) (q : Int) : Event :=
  ⟨.read, ⟨0, 0⟩, 32, q, if q < 0 then [] else s.input.take (BufferRelay.readAmount s.input q)⟩

def writeEvent (s : State) (q : Int) : Event :=
  ⟨.write, ⟨0, s.off⟩, s.n - s.off, q,
    if q ≤ 0 then [] else slice s.buffer s.off (min q.toNat (s.n - s.off))⟩

def readStop (s : State) (rest : List Int) (status : Nat) : State :=
  { s with reads := rest, readCalls := s.readCalls + 1, control := .stopped status }

def readNext (s : State) (q : Int) (rest : List Int) : State :=
  { s with
    buffer := BufferRelay.fill s.buffer s.input q,
    initialized := s.input.take (BufferRelay.readAmount s.input q),
    n := BufferRelay.readAmount s.input q, off := 0,
    input := s.input.drop (BufferRelay.readAmount s.input q), reads := rest,
    readCalls := s.readCalls + 1, control := .drain }

def drainDone (s : State) : State := { s with control := .read }

def writeStop (s : State) (rest : List Int) : State :=
  { s with writes := rest, writeCalls := s.writeCalls + 1, control := .stopped 2 }

def writeNext (s : State) (q : Int) (rest : List Int) : State :=
  let k := min q.toNat (s.n - s.off)
  { s with
    off := s.off + k, output := s.output ++ slice s.buffer s.off k,
    writes := rest, writeCalls := s.writeCalls + 1 }

/-- One actual machine transition. None is the drain-to-read control step. -/
inductive Step : State → Option Event → State → Prop where
  | readError (s q rest) : s.control = .read → BufferRelay.action 32 s.reads = (q, rest) →
      q < 0 → Step s (some (readEvent s q)) (readStop s rest 1)
  | eof (s q rest) : s.control = .read → BufferRelay.action 32 s.reads = (q, rest) →
      0 ≤ q → s.input = [] → Step s (some (readEvent s q)) (readStop s rest 0)
  | readData (s q rest) : s.control = .read → BufferRelay.action 32 s.reads = (q, rest) →
      0 ≤ q → s.input ≠ [] → Step s (some (readEvent s q)) (readNext s q rest)
  | done (s) : s.control = .drain → s.off = s.n → Step s none (drainDone s)
  | writeError (s q rest) : s.control = .drain → s.off < s.n →
      BufferRelay.action (s.n - s.off) s.writes = (q, rest) → q ≤ 0 →
      Step s (some (writeEvent s q)) (writeStop s rest)
  | writeData (s q rest) : s.control = .drain → s.off < s.n →
      BufferRelay.action (s.n - s.off) s.writes = (q, rest) → 0 < q →
      Step s (some (writeEvent s q)) (writeNext s q rest)

inductive Steps : State → List Event → State → Prop where
  | refl (s) : Steps s [] s
  | cons {s t u e es} : Step s e t → Steps t es u → Steps s (e.toList ++ es) u

def RequestSafe (s : State) (e : Event) : Prop :=
  MemoryTransfer.Valid 0 32 e.pointer e.request ∧ e.bytes.length ≤ e.request ∧
  (e.kind = .write → e.pointer.offset + e.request ≤ s.n)

theorem step_preserves {s t : State} {e : Option Event}
    (h : Step s e t) (hw : WellFormed s) : WellFormed t := by
  cases h <;> simp_all [WellFormed, readStop, readNext, drainDone, writeStop, writeNext]
  · exact (BufferRelay.readAmount_bounds _ _).1
  · omega

theorem read_event_safe (s : State) (q : Int) : RequestSafe s (readEvent s q) := by
  have := (BufferRelay.readAmount_bounds s.input q).1
  simp only [RequestSafe, readEvent, MemoryTransfer.Valid]
  split <;> simp <;> omega

theorem write_event_safe (s : State) (q : Int) (hw : WellFormed s) :
    RequestSafe s (writeEvent s q) := by
  unfold WellFormed at hw
  unfold RequestSafe writeEvent
  split <;> simp [MemoryTransfer.Valid, slice] <;> omega

theorem step_request_safe {s t : State} {e : Option Event}
    (h : Step s e t) (hw : WellFormed s) : ∀ ev ∈ e.toList, RequestSafe s ev := by
  cases h <;> simp only [Option.toList_some, Option.toList_none, List.mem_singleton,
    List.not_mem_nil, forall_eq, false_implies, implies_true]
  all_goals first | exact read_event_safe _ _ | exact write_event_safe _ _ hw

theorem steps_preserve {s t : State} {es : List Event}
    (h : Steps s es t) (hw : WellFormed s) : WellFormed t := by
  induction h with
  | refl => exact hw
  | cons hs _ ih => exact ih (step_preserves hs hw)

structure Execution where
  state : State
  trace : List Event

def drain (s : State) : Execution :=
  if _hd : s.off < s.n then
    let (q, rest) := BufferRelay.action (s.n - s.off) s.writes
    if q ≤ 0 then ⟨writeStop s rest, [writeEvent s q]⟩
    else
      let r := drain (writeNext s q rest)
      ⟨r.state, writeEvent s q :: r.trace⟩
  else ⟨drainDone s, []⟩
termination_by s.n - s.off
decreasing_by
  have : 0 < q.toNat := by omega
  simp only [writeNext]
  omega

def execute (s : State) : Execution :=
  let (q, rest) := BufferRelay.action 32 s.reads
  if q < 0 then ⟨readStop s rest 1, [readEvent s q]⟩
  else if _he : s.input = [] then ⟨readStop s rest 0, [readEvent s q]⟩
  else
    let d := drain (readNext s q rest)
    if d.state.control = .stopped 2 then
      ⟨d.state, readEvent s q :: d.trace⟩
    else
      let r := execute { d.state with input := s.input.drop (BufferRelay.readAmount s.input q) }
      ⟨r.state, readEvent s q :: (d.trace ++ r.trace)⟩
termination_by s.input.length
decreasing_by
  have := BufferRelay.readAmount_positive s.input q _he
  have := List.length_pos_iff.mpr _he
  simp only [List.length_drop]
  omega

/-- Observation retains unread AND initialized, undelivered memory on failures. -/
def observe (s : State) : BufferRelay.Detailed :=
  ⟨s.output, s.input, pending s,
    match s.control with | .stopped k => k | _ => 3,
    s.readCalls, s.writeCalls⟩

def initial (input : List Byte) (reads writes : List Int) : State :=
  ⟨fun _ => 0, [], 0, 0, input, [], reads, writes, 0, 0, .read⟩

def run (input : List Byte) (reads writes : List Int) : Execution :=
  execute (initial input reads writes)

def drained (s : State) (d : BufferRelay.DrainResult) : State :=
  { s with
    off := s.n - d.pending.length
    output := s.output ++ d.output
    writes := d.writes
    writeCalls := s.writeCalls + d.calls
    control := if d.failed then .stopped 2 else .read }

theorem drain_refines (s : State) (hw : WellFormed s) :
    (drain s).state = drained s (BufferRelay.drain (pending s) s.writes) := by
  induction s using drain.induct with
  | case1 s hd q rest ha hq =>
      have hl := pending_length s hw
      have hp : pending s ≠ [] := by intro h; rw [h] at hl; simp at hl; omega
      rw [drain]
      simp only [hd, ↓reduceDIte, ha, hq, ↓reduceIte]
      rw [BufferRelay.drain_stop _ _ q rest hp (by simpa [hl] using ha) hq]
      simp only [drained, writeStop, List.append_nil, ↓reduceIte]
      congr 1
      unfold WellFormed at hw
      omega
  | case2 s hd q rest ha hq ih =>
      have hl := pending_length s hw
      have hp : pending s ≠ [] := by intro h; rw [h] at hl; simp at hl; omega
      have hw' : WellFormed (writeNext s q rest) := by
        unfold WellFormed writeNext at *; dsimp; omega
      have hadv : pending (writeNext s q rest) =
          (pending s).drop (min q.toNat (s.n - s.off)) := by
        exact pending_advance s _ (Nat.min_le_right _ _)
      rw [drain]
      simp only [hd, ↓reduceDIte, ha, hq, ↓reduceIte]
      rw [ih hw', hadv]
      rw [BufferRelay.drain_retry _ _ q rest hp (by simpa [hl] using ha) (by omega)]
      simp only [hl, drained, writeNext]
      rw [pending_take s _ (Nat.min_le_right _ _)]
      simp [List.append_assoc, Nat.add_assoc, Nat.add_comm 1]
  | case3 s hd =>
      have he : s.off = s.n := by unfold WellFormed at hw; omega
      have hp : pending s = [] := by simp [pending, he, slice]
      simp [drain, BufferRelay.drain, hp, drained, drainDone, he]

theorem drain_pending (s : State) (hw : WellFormed s) :
    pending (drain s).state = (BufferRelay.drain (pending s) s.writes).pending := by
  induction s using drain.induct with
  | case1 s hd q rest ha hq =>
      have hl := pending_length s hw
      have hp : pending s ≠ [] := by intro h; rw [h] at hl; simp at hl; omega
      rw [drain]
      simp only [hd, ↓reduceDIte, ha, hq, ↓reduceIte]
      rw [BufferRelay.drain_stop _ _ q rest hp (by simpa [hl] using ha) hq]
      rfl
  | case2 s hd q rest ha hq ih =>
      have hl := pending_length s hw
      have hp : pending s ≠ [] := by intro h; rw [h] at hl; simp at hl; omega
      have hw' : WellFormed (writeNext s q rest) := by
        unfold WellFormed writeNext at *; dsimp; omega
      have hadv : pending (writeNext s q rest) =
          (pending s).drop (min q.toNat (s.n - s.off)) :=
        pending_advance s _ (Nat.min_le_right _ _)
      rw [drain]
      simp only [hd, ↓reduceDIte, ha, hq, ↓reduceIte]
      rw [ih hw', hadv]
      rw [BufferRelay.drain_retry _ _ q rest hp (by simpa [hl] using ha) (by omega)]
      simp only [hl, writeNext]
  | case3 s hd =>
      have he : s.off = s.n := by unfold WellFormed at hw; omega
      have hp : pending s = [] := by simp [pending, he, slice]
      simp [drain, BufferRelay.drain, drainDone, pending, slice, he]

theorem drain_reachable (s : State) (hw : WellFormed s) (hc : s.control = .drain) :
    Steps s (drain s).trace (drain s).state := by
  induction s using drain.induct with
  | case1 s hd q rest ha hq =>
      rw [drain]
      simp only [hd, ↓reduceDIte, ha, hq, ↓reduceIte]
      exact Steps.cons (Step.writeError s q rest hc hd ha hq) (Steps.refl _)
  | case2 s hd q rest ha hq ih =>
      have hs := Step.writeData s q rest hc hd ha (by omega)
      have hr := ih (step_preserves hs hw) (by simpa [writeNext] using hc)
      rw [drain]
      simp only [hd, ↓reduceDIte, ha, hq, ↓reduceIte]
      exact Steps.cons hs hr
  | case3 s hd =>
      have he : s.off = s.n := by unfold WellFormed at hw; omega
      rw [drain]
      simp only [hd, ↓reduceDIte]
      exact Steps.cons (Step.done s hc he) (Steps.refl _)

theorem drain_wf (s : State) (hw : WellFormed s) : WellFormed (drain s).state := by
  rw [drain_refines s hw]
  simp only [WellFormed, drained]
  exact ⟨Nat.sub_le _ _, hw.2⟩

theorem drain_finished (s : State) (hw : WellFormed s)
    (hf : (drain s).state.control ≠ .stopped 2) :
    (drain s).state.control = .read ∧ (drain s).state.off = (drain s).state.n := by
  have hr := drain_refines s hw
  have hd : (BufferRelay.drain (pending s) s.writes).failed = false := by
    rw [hr] at hf
    cases hh : (BufferRelay.drain (pending s) s.writes).failed <;> simp_all [drained]
  have hp := (BufferRelay.drain_contract (pending s) s.writes).2.1.mp hd
  rw [hr]
  simp [drained, hd, hp]

theorem readNext_wf (s : State) (q : Int) (rest : List Int) :
    WellFormed (readNext s q rest) := by
  exact ⟨Nat.zero_le _, (BufferRelay.readAmount_bounds _ _).1⟩

theorem readNext_pending (s : State) (q : Int) (rest : List Int) :
    pending (readNext s q rest) = BufferRelay.loaded s.buffer s.input q := by
  unfold pending readNext
  simp only [Nat.sub_zero]
  exact slice_load _ _ _ (by have := (BufferRelay.readAmount_bounds s.input q).1; omega)

theorem drain_failed_iff (s : State) (hw : WellFormed s) :
    (drain s).state.control = .stopped 2 ↔
      (BufferRelay.drain (pending s) s.writes).failed = true := by
  rw [drain_refines s hw]
  simp [drained]

theorem observe_drain (s : State) (hw : WellFormed s) :
    observe (drain s).state =
      let d := BufferRelay.drain (pending s) s.writes
      ⟨s.output ++ d.output, s.input, d.pending, if d.failed then 2 else 3,
        s.readCalls, s.writeCalls + d.calls⟩ := by
  unfold observe
  rw [drain_pending s hw, drain_refines s hw]
  dsimp only [drained]
  cases hh : (BufferRelay.drain (pending s) s.writes).failed <;> simp

end PointerRelay
