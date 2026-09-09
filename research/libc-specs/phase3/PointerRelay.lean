import PointerCore

namespace PointerRelay

def accumulate (s : State) (r : BufferRelay.Detailed) : BufferRelay.Detailed :=
  ⟨s.output ++ r.output, r.remaining, r.pending, r.status,
    s.readCalls + r.readCalls, s.writeCalls + r.writeCalls⟩

theorem execute_refines (s : State) (hw : WellFormed s) (ho : s.off = s.n) :
    observe (execute s).state =
      accumulate s (BufferRelay.execute s.buffer s.input s.reads s.writes) := by
  induction s using execute.induct with
  | case1 s q rest ha hq =>
      have hp : pending s = [] := by simp [pending, slice, ho]
      rw [execute, BufferRelay.execute_read_error _ _ _ _ q rest ha hq]
      simp [ha, hq, observe, readStop, accumulate, pending, slice, ho]
  | case2 s q rest ha hq he =>
      rw [execute]
      simp only [ha, hq, ↓reduceIte, he, ↓reduceDIte]
      rw [BufferRelay.execute_eof _ _ _ q rest ha (by omega)]
      simp [observe, readStop, accumulate, pending, slice, ho, he]
  | case3 s q rest ha hq he d hf =>
      dsimp only [d] at hf
      have hd := (drain_failed_iff (readNext s q rest) (readNext_wf s q rest)).mp hf
      rw [readNext_pending] at hd
      dsimp only [readNext] at hd
      rw [execute]
      simp only [ha, hq, ↓reduceIte, he, ↓reduceDIte, hf]
      rw [observe_drain _ (readNext_wf s q rest), readNext_pending]
      rw [BufferRelay.execute_write_failure _ _ _ _ q rest ha (by omega) he hd]
      simp [readNext, accumulate, hd]
  | case4 s q rest ha hq he d hf ih =>
      dsimp only [d] at hf ih
      have hd := drain_finished (readNext s q rest) (readNext_wf s q rest) hf
      have hw' := drain_wf (readNext s q rest) (readNext_wf s q rest)
      have hir := ih hw' hd.2
      rw [execute]
      simp only [ha, hq, ↓reduceIte, he, ↓reduceDIte, hf]
      rw [hir]
      rw [drain_refines _ (readNext_wf s q rest), readNext_pending]
      have hdf : (BufferRelay.drain (BufferRelay.loaded s.buffer s.input q) s.writes).failed = false := by
        have ht := (not_congr (drain_failed_iff (readNext s q rest) (readNext_wf s q rest))).mp hf
        rw [readNext_pending] at ht
        simpa only [readNext, Bool.not_eq_true] using ht
      conv => rhs; rw [BufferRelay.execute]
      simp only [ha, hq, ↓reduceIte, he, ↓reduceDIte, hdf, Bool.false_eq_true]
      simp [accumulate, drained, readNext, List.append_assoc, Nat.add_assoc,
        Nat.add_comm 1]

theorem Steps.trans {s t u : State} {xs ys : List Event}
    (h : Steps s xs t) (h' : Steps t ys u) : Steps s (xs ++ ys) u := by
  induction h with
  | refl => exact h'
  | cons hs _ ih => simpa only [List.append_assoc] using Steps.cons hs (ih h')

theorem drain_input (s : State) (hw : WellFormed s) : (drain s).state.input = s.input := by
  rw [drain_refines s hw]
  rfl

theorem execute_reachable (s : State) (hw : WellFormed s) (hc : s.control = .read) :
    Steps s (execute s).trace (execute s).state := by
  induction s using execute.induct with
  | case1 s q rest ha hq =>
      rw [execute]
      simp only [ha, hq, ↓reduceIte]
      exact Steps.cons (Step.readError s q rest hc ha hq) (Steps.refl _)
  | case2 s q rest ha hq he =>
      rw [execute]
      simp only [ha, hq, ↓reduceIte, he, ↓reduceDIte]
      exact Steps.cons (Step.eof s q rest hc ha (by omega) he) (Steps.refl _)
  | case3 s q rest ha hq he d hf =>
      dsimp only [d] at hf
      rw [execute]
      simp only [ha, hq, ↓reduceIte, he, ↓reduceDIte, hf]
      exact Steps.cons (Step.readData s q rest hc ha (by omega) he)
        (drain_reachable _ (readNext_wf s q rest) rfl)
  | case4 s q rest ha hq he d hf ih =>
      dsimp only [d] at hf ih
      have hi := drain_input (readNext s q rest) (readNext_wf s q rest)
      have heq : { (drain (readNext s q rest)).state with
          input := s.input.drop (BufferRelay.readAmount s.input q) } =
          (drain (readNext s q rest)).state := by
        dsimp only [readNext] at hi
        rw [← hi]
        rfl
      rw [heq] at ih
      have hr := ih (drain_wf _ (readNext_wf s q rest))
        (drain_finished _ (readNext_wf s q rest) hf).1
      rw [execute]
      simp only [ha, hq, ↓reduceIte, he, ↓reduceDIte, hf, heq]
      exact Steps.cons (Step.readData s q rest hc ha (by omega) he)
        ((drain_reachable _ (readNext_wf s q rest) rfl).trans hr)

theorem run_detailed_eq (input : List Byte) (reads writes : List Int) :
    observe (run input reads writes).state = BufferRelay.runDetailed input reads writes := by
  have h := execute_refines (initial input reads writes) (by simp [WellFormed, initial]) rfl
  simpa only [run, BufferRelay.runDetailed, initial, accumulate, List.nil_append,
    Nat.zero_add] using h

def observeOutcome (s : State) : BufferRelay.Outcome :=
  let d := observe s
  ⟨d.output, d.remaining, d.status, d.readCalls, d.writeCalls⟩

theorem run_outcome_eq (input : List Byte) (reads writes : List Int) :
    observeOutcome (run input reads writes).state = BufferRelay.run input reads writes := by
  unfold observeOutcome BufferRelay.run
  rw [run_detailed_eq]

theorem run_reachable (input : List Byte) (reads writes : List Int) :
    Steps (initial input reads writes) (run input reads writes).trace
      (run input reads writes).state :=
  execute_reachable _ (by simp [WellFormed, initial]) rfl

def Event.result (e : Event) : Int := if e.action < 0 then -1 else Int.ofNat e.bytes.length

/-- Ghost history only; execution loads writes from physical memory, never this payload. -/
def Initialized (s : State) : Prop :=
  s.initialized.length = s.n ∧ slice s.buffer 0 s.n = s.initialized

def Ready (s : State) : Prop := s.control = .read → s.off = s.n

def Invariant (s : State) : Prop := WellFormed s ∧ Ready s ∧ Initialized s

def conserved (s : State) : List Byte := s.output ++ (pending s ++ s.input)

theorem readNext_initialized (s : State) (q : Int) (rest : List Int) :
    Initialized (readNext s q rest) := by
  constructor
  · simp only [readNext, List.length_take]
    exact Nat.min_eq_left (BufferRelay.readAmount_bounds s.input q).2
  · have h := readNext_pending s q rest
    simpa only [pending, readNext, Nat.sub_zero, BufferRelay.loaded_eq] using h

theorem step_invariant {s t : State} {e : Option Event}
    (h : Step s e t) (hi : Invariant s) : Invariant t := by
  refine ⟨step_preserves h hi.1, ?_, ?_⟩
  · cases h <;> simp_all [Ready, readStop, readNext, drainDone, writeStop, writeNext]
  · cases h
    case readData => exact readNext_initialized _ _ _
    all_goals exact hi.2.2

theorem step_conservation {s t : State} {e : Option Event}
    (h : Step s e t) (hr : Ready s) : conserved t = conserved s := by
  cases h with
  | readError => rfl
  | eof => rfl
  | readData q rest hc ha hq hn =>
      have hp : pending s = [] := by simp [pending, slice, hr hc]
      unfold conserved
      rw [readNext_pending, BufferRelay.loaded_eq]
      simp only [readNext, hp, List.nil_append, List.take_append_drop]
  | done => rfl
  | writeError => rfl
  | writeData q rest hc ho ha hq =>
      have hp : pending (writeNext s q rest) =
          (pending s).drop (min q.toNat (s.n - s.off)) :=
        pending_advance s _ (Nat.min_le_right _ _)
      unfold conserved
      rw [hp]
      simp only [writeNext, ← pending_take s _ (Nat.min_le_right _ _),
        List.append_assoc]
      rw [← List.append_assoc _ _ s.input, List.take_append_drop]

theorem steps_invariant {s t : State} {es : List Event}
    (h : Steps s es t) (hi : Invariant s) : Invariant t := by
  induction h with
  | refl => exact hi
  | cons hs _ ih => exact ih (step_invariant hs hi)

theorem steps_conservation {s t : State} {es : List Event}
    (h : Steps s es t) (hi : Invariant s) : conserved t = conserved s := by
  induction h with
  | refl => rfl
  | cons hs _ ih => exact (ih (step_invariant hs hi)).trans (step_conservation hs hi.2.1)

theorem initial_invariant (input : List Byte) (reads writes : List Int) :
    Invariant (initial input reads writes) := by
  simp [Invariant, WellFormed, Ready, Initialized, initial, slice]

def Reachable (input : List Byte) (reads writes : List Int) (s : State) : Prop :=
  ∃ es, Steps (initial input reads writes) es s

theorem reachable_invariant {input : List Byte} {reads writes : List Int} {s : State}
    (h : Reachable input reads writes s) :
    Invariant s ∧ conserved s = input := by
  obtain ⟨es, ht⟩ := h
  exact ⟨steps_invariant ht (initial_invariant _ _ _), by
    simpa [conserved, initial, pending, slice] using
      steps_conservation ht (initial_invariant _ _ _)⟩

theorem reachable_request_safe {input : List Byte} {reads writes : List Int}
    {s t : State} {e : Event} (h : Reachable input reads writes s)
    (hs : Step s (some e) t) : RequestSafe s e :=
  step_request_safe hs (reachable_invariant h).1.1 e (by simp)

theorem initialized_write_bytes (s : State) (k : Nat) (hi : Initialized s)
    (hk : s.off + k ≤ s.n) :
    slice s.buffer s.off k = (s.initialized.drop s.off).take k := by
  rw [← hi.2]
  simp only [slice, List.drop_zero, List.drop_take, List.take_take]
  rw [Nat.min_eq_left (by omega : k ≤ s.n - s.off)]

theorem reachable_write_bytes {input : List Byte} {reads writes : List Int} {s : State}
    (h : Reachable input reads writes s) (q : Int) (hq : 0 < q) :
    (writeEvent s q).bytes =
      (s.initialized.drop s.off).take (min q.toNat (s.n - s.off)) := by
  simp only [writeEvent, show ¬q ≤ 0 by omega, ↓reduceIte]
  apply initialized_write_bytes s _ (reachable_invariant h).1.2.2
  have := (reachable_invariant h).1.1.1
  omega

def Stopped (s : State) : Prop := ∃ k, s.control = .stopped k

theorem step_deterministic {s t u : State} {e f : Option Event}
    (h : Step s e t) (h' : Step s f u) : e = f ∧ t = u := by
  cases h <;> cases h' <;> simp_all
  all_goals omega

theorem stopped_no_step {s t : State} {e : Option Event}
    (h : Stopped s) (hs : Step s e t) : False := by
  obtain ⟨k, hk⟩ := h
  cases hs <;> simp_all

theorem execute_stopped (s : State) : Stopped (execute s).state := by
  induction s using execute.induct with
  | case1 s q rest ha hq =>
      rw [execute]
      simp only [ha, hq, ↓reduceIte]
      exact ⟨1, rfl⟩
  | case2 s q rest ha hq he =>
      rw [execute]
      simp only [ha, hq, ↓reduceIte, he, ↓reduceDIte]
      exact ⟨0, rfl⟩
  | case3 s q rest ha hq he d hf =>
      dsimp only [d] at hf
      rw [execute]
      simp only [ha, hq, ↓reduceIte, he, ↓reduceDIte, hf]
      exact ⟨2, hf⟩
  | case4 s q rest ha hq he d hf ih =>
      dsimp only [d] at hf ih
      rw [execute]
      simp only [ha, hq, ↓reduceIte, he, ↓reduceDIte, hf]
      exact ih

theorem terminal_unique {s t u : State} {es fs : List Event}
    (h : Steps s es t) (h' : Steps s fs u) (ht : Stopped t) (hu : Stopped u) :
    t = u ∧ es = fs := by
  induction h generalizing u fs with
  | refl s =>
      cases h' with
      | refl => exact ⟨rfl, rfl⟩
      | cons hs _ => exact False.elim (stopped_no_step ht hs)
  | cons hs tail ih =>
      cases h' with
      | refl => exact False.elim (stopped_no_step hu hs)
      | cons hs' tail' =>
          obtain ⟨rfl, rfl⟩ := step_deterministic hs hs'
          obtain ⟨hstate, htrace⟩ := ih tail' ht hu
          exact ⟨hstate, by rw [htrace]⟩

theorem complete_execution_refines {input : List Byte} {reads writes : List Int}
    {s : State} {es : List Event} (h : Steps (initial input reads writes) es s)
    (hs : Stopped s) : observe s = BufferRelay.runDetailed input reads writes ∧
      es = (run input reads writes).trace := by
  obtain ⟨heq, htrace⟩ := terminal_unique h (run_reachable input reads writes) hs
    (execute_stopped _)
  exact ⟨by rw [heq, run_detailed_eq], htrace⟩

theorem terminal_execution_exists (input : List Byte) (reads writes : List Int) :
    ∃ s es, Steps (initial input reads writes) es s ∧ Stopped s ∧
      observe s = BufferRelay.runDetailed input reads writes :=
  ⟨(run input reads writes).state, (run input reads writes).trace,
    run_reachable _ _ _, execute_stopped _, run_detailed_eq _ _ _⟩

theorem Steps.event_source {s t : State} {es : List Event} (h : Steps s es t)
    {ev : Event} (he : ev ∈ es) :
    ∃ u v pre, Steps s pre u ∧ Step u (some ev) v := by
  induction h with
  | refl => simp at he
  | @cons s t u e es hs tail ih =>
      rcases List.mem_append.mp he with hh | hh
      · cases e with
        | none => simp at hh
        | some ev' =>
            have heq : ev = ev' := by simpa using hh
            subst ev'
            exact ⟨s, t, [], Steps.refl s, hs⟩
      · obtain ⟨a, b, pre, hp, hb⟩ := ih hh
        exact ⟨a, b, e.toList ++ pre, Steps.cons hs hp, hb⟩

theorem run_trace_safe (input : List Byte) (reads writes : List Int) (ev : Event)
    (he : ev ∈ (run input reads writes).trace) :
    ∃ s t, Reachable input reads writes s ∧ Step s (some ev) t ∧
      Invariant s ∧ RequestSafe s ev ∧ conserved s = input := by
  obtain ⟨s, t, pre, hp, hs⟩ := (run_reachable input reads writes).event_source he
  have hr : Reachable input reads writes s := ⟨pre, hp⟩
  exact ⟨s, t, hr, hs, (reachable_invariant hr).1, reachable_request_safe hr hs,
    (reachable_invariant hr).2⟩

def EventEffect (s : State) (e : Event) (t : State) : Prop :=
  match e.kind with
  | .read => t.output = s.output ∧ t.input = s.input.drop e.bytes.length ∧
      t.buffer = MemoryTransfer.store s.buffer e.pointer.offset e.bytes ∧
      t.readCalls = s.readCalls + 1 ∧ t.writeCalls = s.writeCalls
  | .write => t.input = s.input ∧ t.buffer = s.buffer ∧
      t.output = s.output ++ e.bytes ∧ t.off = s.off + e.bytes.length ∧
      t.writeCalls = s.writeCalls + 1 ∧ t.readCalls = s.readCalls

theorem store_nil (m : Memory) (off : Nat) : MemoryTransfer.store m off [] = m := by
  funext i
  simp [MemoryTransfer.store]

theorem step_event_effect {s t : State} {ev : Event} (h : Step s (some ev) t)
    (hw : WellFormed s) : EventEffect s ev t := by
  cases h with
  | readError q rest hc ha hq =>
      simp [EventEffect, readEvent, hq, readStop, store_nil]
  | eof q rest hc ha hq he =>
      simp [EventEffect, readEvent, readStop, he, store_nil]
  | readData q rest hc ha hq he =>
      have hl : (s.input.take (BufferRelay.readAmount s.input q)).length =
          BufferRelay.readAmount s.input q := by
        simp only [List.length_take, Nat.min_eq_left (BufferRelay.readAmount_bounds _ _).2]
      simp [EventEffect, readEvent, show ¬q < 0 by omega, readNext, hl, BufferRelay.fill]
  | writeError q rest hc ho ha hq =>
      simp [EventEffect, writeEvent, hq, writeStop]
  | writeData q rest hc ho ha hq =>
      have hk : s.off + min q.toNat (s.n - s.off) ≤ 32 := by
        unfold WellFormed at hw; omega
      simp [EventEffect, writeEvent, show ¬q ≤ 0 by omega, writeNext, slice_length _ _ _ hk]

theorem reachable_event_effect {input : List Byte} {reads writes : List Int}
    {s t : State} {ev : Event} (h : Reachable input reads writes s)
    (hs : Step s (some ev) t) : EventEffect s ev t :=
  step_event_effect hs (reachable_invariant h).1.1

theorem readNext_primitive (s : State) (q : Int) (rest : List Int) :
    MemoryTransfer.read 0 ⟨s.buffer, s.input, s.output⟩ ⟨0, 0⟩ 32
      (.ready (max 1 q.toNat)) =
      .ok (BufferRelay.readAmount s.input q)
        ⟨(readNext s q rest).buffer, (readNext s q rest).input, (readNext s q rest).output⟩ := by
  simp [MemoryTransfer.read, MemoryTransfer.Valid, MemoryTransfer.amount,
    MemoryTransfer.afterRead, readNext, BufferRelay.readAmount, BufferRelay.fill]

theorem writeNext_primitive (s : State) (q : Int) (rest : List Int) (hw : WellFormed s) :
    ∃ hk : s.off + min q.toNat (s.n - s.off) ≤ 32,
      (writeNext s q rest).output =
        (MemoryTransfer.emit ⟨s.buffer, s.input, s.output⟩ ⟨0, s.off⟩
          (min q.toNat (s.n - s.off)) hk).output := by
  have hk : s.off + min q.toNat (s.n - s.off) ≤ 32 := by
    unfold WellFormed at hw; omega
  exact ⟨hk, by simp only [writeNext, MemoryTransfer.emit, slice_load _ _ _ hk]⟩

theorem reachable_pointer_view {input : List Byte} {reads writes : List Int} {s : State}
    (h : Reachable input reads writes s) :
    ∃ hv : s.off + (s.n - s.off) ≤ 32,
      pending s = MemoryTransfer.load s.buffer s.off (s.n - s.off) hv ∧
      pending s = s.initialized.drop s.off := by
  have hw := (reachable_invariant h).1.1
  have hi := (reachable_invariant h).1.2.2
  have hv : s.off + (s.n - s.off) ≤ 32 := by unfold WellFormed at hw; omega
  refine ⟨hv, slice_load _ _ _ hv, ?_⟩
  have hs := initialized_write_bytes s (s.n - s.off) hi (by have := hw.1; omega)
  change slice s.buffer s.off (s.n - s.off) = _
  rw [hs]
  have hl : s.n - s.off = (s.initialized.drop s.off).length := by
    simp only [List.length_drop, hi.1]
  rw [hl, List.take_length]

namespace Examples

theorem short_then_zero :
    observe (run [97, 98, 99, 100, 101, 102] [4] [2, 0]).state =
      ⟨[97, 98], [101, 102], [99, 100], 2, 1, 2⟩ := by
  rw [run_detailed_eq]
  simp [BufferRelay.runDetailed, BufferRelay.execute, BufferRelay.drain,
    BufferRelay.loaded_eq, BufferRelay.readAmount, BufferRelay.action]

theorem retry_events :
    (run [97, 98, 99, 100, 101, 102] [4] [2, 0]).trace =
      [⟨.read, ⟨0, 0⟩, 32, 4, [97, 98, 99, 100]⟩,
       ⟨.write, ⟨0, 0⟩, 4, 2, [97, 98]⟩,
       ⟨.write, ⟨0, 2⟩, 2, 0, []⟩] := by
  simp [run, initial, execute, drain, readNext, writeNext, writeStop,
    readEvent, writeEvent, slice, BufferRelay.action, BufferRelay.readAmount,
    BufferRelay.fill, MemoryTransfer.store]

theorem error_before_eof :
    observe (run [97, 98, 99] [3, -1] []).state =
      ⟨[97, 98, 99], [], [], 1, 2, 1⟩ := by
  rw [run_detailed_eq]
  simp [BufferRelay.runDetailed, BufferRelay.execute, BufferRelay.drain,
    BufferRelay.loaded_eq, BufferRelay.readAmount, BufferRelay.action]

theorem reused_binary_buffer :
    observe (run [0, 255, 128, 10, 13] [3, 1] [1, 1, 1]).state =
      ⟨[0, 255, 128, 10, 13], [], [], 0, 4, 5⟩ := by
  rw [run_detailed_eq]
  simp [BufferRelay.runDetailed, BufferRelay.execute, BufferRelay.drain,
    BufferRelay.loaded_eq, BufferRelay.readAmount, BufferRelay.action]

theorem first_read_error :
    observe (run [0, 255] [-1] []).state = ⟨[], [0, 255], [], 1, 1, 0⟩ := by
  rw [run_detailed_eq]
  simp [BufferRelay.runDetailed, BufferRelay.execute, BufferRelay.action]

theorem first_write_error :
    observe (run [0, 255, 128] [2] [-1]).state =
      ⟨[], [128], [0, 255], 2, 1, 1⟩ := by
  rw [run_detailed_eq]
  simp [BufferRelay.runDetailed, BufferRelay.execute, BufferRelay.drain,
    BufferRelay.loaded_eq, BufferRelay.readAmount, BufferRelay.action]

end Examples

end PointerRelay
