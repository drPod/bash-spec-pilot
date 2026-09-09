import ShellObservation
import LeanFinal
import ScheduleConsumption

/- Stateful protocol composition. Does not overwrite LeanFinal.

   World threads BufferRelay.runDetailed residual input and read/write
   schedules after each direct or nonempty redirect. `advanceUnread` drops
   the reported call counts from the schedules; ScheduleConsumption proves
   these drops equal the residual schedules of executeI, whose Detailed
   result projects to BufferRelay.execute. Exhausted schedules remain empty
   even when subsequent calls use the model's default action.

   `mark` does not consume protocol. Empty-path redirect: identity, status 1.

   Honest gap: not a Coq-to-Lean import, not C-final/OS. `WState`/`stepPrim`
   are restated independently in Lean, standing for what the Coq side
   (`shell-expansion/fd/FdTable.v`, `shell-expansion/Redirect.v`) is
   accepted to establish; no mechanized bridge exists or is claimed. -/
namespace StatefulFinal

open ShellObservation
open LeanFinal (Atom)

structure WState where
  input : List UInt8
  reads : List Int
  writes : List Int
  delivered : List UInt8
  fileStore : String → List UInt8

def detailed (s : WState) : BufferRelay.Detailed :=
  BufferRelay.runDetailed s.input s.reads s.writes

def updateFile (path : String) (content : List UInt8) (fs : String → List UInt8) :
    String → List UInt8 :=
  fun p => if p = path then content else fs p

/-- Advances ALL of the protocol state a `direct`/nonempty-`redirect` atom
    consumes: the unread input (`remaining`) AND the read/write schedules,
    each dropped by exactly the call count the SAME `detailed s` run
    reports. `ScheduleConsumption.runDetailed_reads_drop`/`_writes_drop`
    (proved by induction on an instrumented executor projecting onto the
    real `BufferRelay.execute`) are the justification that this closed-form
    `.drop` formula is the ACTUAL residual, not an invented one. -/
def advanceUnread (s : WState) : WState :=
  let d := detailed s
  { input := d.remaining, reads := s.reads.drop d.readCalls, writes := s.writes.drop d.writeCalls,
    delivered := s.delivered, fileStore := s.fileStore }

theorem advanceUnread_reads (s : WState) :
    (advanceUnread s).reads = s.reads.drop (detailed s).readCalls := rfl

theorem advanceUnread_writes (s : WState) :
    (advanceUnread s).writes = s.writes.drop (detailed s).writeCalls := rfl

/-- The residual schedules `advanceUnread` computes are exactly what the
    instrumented executor (`ScheduleConsumption.executeI`) itself leaves
    behind, connecting the closed-form `.drop` formula to a structural
    execution, not merely asserting it. -/
theorem advanceUnread_reads_structural (s : WState) :
    (advanceUnread s).reads =
      (ScheduleConsumption.executeI (fun _ => 0) s.input s.reads s.writes).reads := by
  rw [advanceUnread_reads, detailed,
    ScheduleConsumption.runDetailed_reads_drop]

theorem advanceUnread_writes_structural (s : WState) :
    (advanceUnread s).writes =
      (ScheduleConsumption.executeI (fun _ => 0) s.input s.reads s.writes).writes := by
  rw [advanceUnread_writes, detailed,
    ScheduleConsumption.runDetailed_writes_drop]

def divertFile (path : String) (append : Bool) (extra : List UInt8) (s : WState) :
    WState :=
  { input := s.input, reads := s.reads, writes := s.writes, delivered := s.delivered,
    fileStore := updateFile path
      ((if append then s.fileStore path else []) ++ extra) s.fileStore }

def stepFn (a : Atom) (s : WState) : Nat × WState :=
  match a with
  | .mark b =>
      (0, { input := s.input, reads := s.reads, writes := s.writes,
            delivered := s.delivered ++ [b], fileStore := s.fileStore })
  | .direct =>
      let d := detailed s
      let s' := advanceUnread s
      (d.status, { input := s'.input, reads := s'.reads, writes := s'.writes,
                   delivered := s.delivered ++ d.output, fileStore := s'.fileStore })
  | .redirect path append =>
      if path = "" then
        (1, s)
      else
        let d := detailed s
        (d.status, divertFile path append d.output (advanceUnread s))

def stepPrim : ShellObservation.Primitive Atom WState :=
  fun a s rc t => stepFn a s = (rc, t)

theorem stepPrim_empty_path (append : Bool) (s rc t) :
    stepPrim (.redirect "" append) s rc t → rc = 1 ∧ t = s := by
  intro h
  simp [stepPrim, stepFn] at h
  exact ⟨h.1.symm, h.2.symm⟩

/-- A second command after `redirect path append` sees the FULL residual
    protocol state left by the first: unread input, AND unconsumed
    read/write schedule entries, all via the SAME `advanceUnread`. -/
theorem redirect_then_direct_uses_residual
    (path : String) (append : Bool) (hp : path ≠ "")
    (s u : WState) (rc2 : Nat)
    (he : Exec stepPrim (Command.seq (.call (Atom.redirect path append))
        (.call Atom.direct)) s rc2 u) :
    u.delivered = s.delivered ++
      (BufferRelay.runDetailed (advanceUnread s).input (advanceUnread s).reads
        (advanceUnread s).writes).output ∧
    u.input =
      (BufferRelay.runDetailed (advanceUnread s).input (advanceUnread s).reads
        (advanceUnread s).writes).remaining ∧
    u.reads =
      (advanceUnread s).reads.drop
        (BufferRelay.runDetailed (advanceUnread s).input (advanceUnread s).reads
          (advanceUnread s).writes).readCalls ∧
    u.writes =
      (advanceUnread s).writes.drop
        (BufferRelay.runDetailed (advanceUnread s).input (advanceUnread s).reads
          (advanceUnread s).writes).writeCalls ∧
    u.fileStore path =
      (if append then s.fileStore path else []) ++ (detailed s).output := by
  cases he with
  | seq h1 h2 =>
    cases h1 with
    | call hc =>
      cases h2 with
      | call hd =>
        simp [stepPrim, stepFn, hp, advanceUnread, divertFile, detailed] at hc hd
        obtain ⟨_, ht⟩ := hc
        subst ht
        obtain ⟨_, hu⟩ := hd
        subst hu
        refine ⟨by simp [detailed, advanceUnread],
          by simp [detailed, advanceUnread], by simp [detailed, advanceUnread],
          by simp [detailed, advanceUnread], by simp [detailed, updateFile]⟩

theorem redirect_then_mark_success
    (path : String) (append : Bool) (hp : path ≠ "") (b0 : UInt8)
    (s t : WState)
    (he : Exec stepPrim (Command.andThen (.call (Atom.redirect path append))
        (.call (Atom.mark b0))) s 0 t) :
    t.delivered = s.delivered ++ [b0] ∧
    t.input = (detailed s).remaining ∧
    t.reads = s.reads.drop (detailed s).readCalls ∧
    t.writes = s.writes.drop (detailed s).writeCalls ∧
    t.fileStore path =
      (if append then s.fileStore path else []) ++ (detailed s).output := by
  cases he with
  | andZero h1 h2 =>
    cases h1 with
    | call hc =>
      cases h2 with
      | call hm =>
        simp [stepPrim, stepFn, hp, advanceUnread, divertFile] at hc
        obtain ⟨hrc0, ht⟩ := hc
        subst ht
        simp [stepPrim, stepFn] at hm
        cases hm
        simp [updateFile]
  | andNonzero _ hn => exact absurd rfl hn

theorem empty_path_andThen_preserves
    (append : Bool) (b0 : UInt8) (s t : WState) (rc : Nat)
    (he : Exec stepPrim (Command.andThen (.call (Atom.redirect "" append))
        (.call (Atom.mark b0))) s rc t) :
    t = s ∧ rc = 1 := by
  cases he with
  | andZero h1 h2 =>
    cases h1 with
    | call hc =>
      simp [stepPrim, stepFn] at hc
  | andNonzero h1 _ =>
    cases h1 with
    | call hc =>
      simp [stepPrim, stepFn] at hc
      exact ⟨hc.2.symm, hc.1.symm⟩

/-- The OLD (rejected) model: every atom re-runs `BufferRelay.run` against
    the FIXED original `input0/reads0/writes0`, ignoring any state already
    consumed. Kept only as the explicit point of CONTRAST for
    `read_error_then_recovers`/`reset_repeats_error` below -- this is not
    used anywhere in the accepted `stepPrim` model above. -/
def resetPrim (input0 : List UInt8) (reads0 writes0 : List Int) :
    ShellObservation.Primitive Atom WState
  | .direct, s, rc, t =>
      let o := BufferRelay.run input0 reads0 writes0
      rc = o.status ∧ t.delivered = s.delivered ++ o.output ∧
        t.fileStore = s.fileStore ∧ t.input = s.input ∧
        t.reads = s.reads ∧ t.writes = s.writes
  | .redirect path append, s, rc, t =>
      if path = "" then
        rc = 1 ∧ t = s
      else
        let o := BufferRelay.run input0 reads0 writes0
        rc = o.status ∧ t.delivered = s.delivered ∧
          t.fileStore = updateFile path
            ((if append then s.fileStore path else []) ++ o.output) s.fileStore ∧
          t.input = s.input ∧ t.reads = s.reads ∧ t.writes = s.writes
  | .mark b, s, rc, t =>
      rc = 0 ∧ t.delivered = s.delivered ++ [b] ∧ t.fileStore = s.fileStore ∧
        t.input = s.input ∧ t.reads = s.reads ∧ t.writes = s.writes

def abc : List UInt8 := [97, 98, 99]
def s0 : WState :=
  { input := abc, reads := [3], writes := [], delivered := [],
    fileStore := fun _ => [] }

theorem abc_status : (BufferRelay.runDetailed abc [3] []).status = 0 := by
  simp [BufferRelay.runDetailed, BufferRelay.execute, BufferRelay.drain,
    BufferRelay.loaded_eq, BufferRelay.readAmount, BufferRelay.action, abc]

theorem abc_output : (BufferRelay.runDetailed abc [3] []).output = abc := by
  simp [BufferRelay.runDetailed, BufferRelay.execute, BufferRelay.drain,
    BufferRelay.loaded_eq, BufferRelay.readAmount, BufferRelay.action, abc]

theorem abc_remaining : (BufferRelay.runDetailed abc [3] []).remaining = [] := by
  simp [BufferRelay.runDetailed, BufferRelay.execute, BufferRelay.drain,
    BufferRelay.loaded_eq, BufferRelay.readAmount, BufferRelay.action, abc]

theorem abc_readCalls : (BufferRelay.runDetailed abc [3] []).readCalls = 2 := by
  simp [BufferRelay.runDetailed, BufferRelay.execute, BufferRelay.drain,
    BufferRelay.loaded_eq, BufferRelay.readAmount, BufferRelay.action, abc]

theorem empty_status : (BufferRelay.runDetailed [] [3] []).status = 0 := by
  simp [BufferRelay.runDetailed, BufferRelay.execute, BufferRelay.action]

theorem empty_output : (BufferRelay.runDetailed [] [3] []).output = ([] : List UInt8) := by
  simp [BufferRelay.runDetailed, BufferRelay.execute, BufferRelay.action]

theorem empty_remaining : (BufferRelay.runDetailed [] [3] []).remaining = [] := by
  simp [BufferRelay.runDetailed, BufferRelay.execute, BufferRelay.action]

theorem consumed_two_directs :
    ∃ t, Exec stepPrim (Command.seq (.call Atom.direct) (.call Atom.direct)) s0 0 t ∧
      t.delivered = abc ∧ t.input = [] := by
  let t1 : WState :=
    { input := [], reads := [], writes := [], delivered := abc,
      fileStore := fun _ => [] }
  refine ⟨t1, ?_, rfl, rfl⟩
  apply Exec.seq (rc₁ := 0) (t := t1)
  · apply Exec.call (a := Atom.direct)
    change stepFn Atom.direct s0 = (0, t1)
    simp [stepFn, advanceUnread, detailed, s0, t1, abc_status, abc_remaining, abc_readCalls, abc_output]
  · apply Exec.call (a := Atom.direct)
    change stepFn Atom.direct t1 = (0, t1)
    simp [stepFn, advanceUnread, detailed, t1, BufferRelay.runDetailed,
      BufferRelay.execute, BufferRelay.action]

theorem reset_two_directs :
    ∃ t, Exec (resetPrim abc [3] [])
        (Command.seq (.call Atom.direct) (.call Atom.direct)) s0 0 t ∧
      t.delivered = abc ++ abc ∧ t.input = abc := by
  have ho : (BufferRelay.run abc [3] []).output = abc := by
    simp [BufferRelay.run, abc_output]
  have hs : (BufferRelay.run abc [3] []).status = 0 := by
    simp [BufferRelay.run, abc_status]
  let t1 : WState :=
    { input := abc, reads := [3], writes := [], delivered := abc,
      fileStore := fun _ => [] }
  let t2 : WState :=
    { input := abc, reads := [3], writes := [], delivered := abc ++ abc,
      fileStore := fun _ => [] }
  refine ⟨t2, ?_, rfl, rfl⟩
  apply Exec.seq (t := t1)
  · exact Exec.call (a := Atom.direct)
      ⟨hs.symm, by simp [t1, s0, ho], rfl, rfl, rfl, rfl⟩
  · exact Exec.call (a := Atom.direct)
      ⟨hs.symm, by simp [t2, t1, ho], rfl, rfl, rfl, rfl⟩

theorem reset_and_consumed_differ :
    (∃ t, Exec stepPrim (Command.seq (.call Atom.direct) (.call Atom.direct)) s0 0 t ∧
        t.delivered = abc) ∧
    (∃ t, Exec (resetPrim abc [3] [])
        (Command.seq (.call Atom.direct) (.call Atom.direct)) s0 0 t ∧
        t.delivered = abc ++ abc) ∧
    abc ≠ abc ++ abc := by
  refine ⟨?_, ?_, by decide⟩
  · obtain ⟨t, he, hd, _⟩ := consumed_two_directs
    exact ⟨t, he, hd⟩
  · obtain ⟨t, he, hd, _⟩ := reset_two_directs
    exact ⟨t, he, hd⟩

theorem general_redirect_then_direct
    (path : String) (append : Bool) (hp : path ≠ "")
    (s u : WState) (rc2 : Nat)
    (he : Exec stepPrim (Command.seq (.call (Atom.redirect path append))
        (.call Atom.direct)) s rc2 u) :
    u.delivered = s.delivered ++
      (BufferRelay.runDetailed (advanceUnread s).input (advanceUnread s).reads
        (advanceUnread s).writes).output :=
  (redirect_then_direct_uses_residual path append hp s u rc2 he).1

/- ---- Read-error recovery: a second `direct` after a FAILED read consumes
   the NEXT schedule entry, not the same one again -- the exact scenario
   the accepted `advanceUnread` fix is FOR. `abcReads := [-1, 3]`: the first
   `direct` call's read action is -1 (a read error, `BufferRelay.execute`'s
   `q < 0` branch: status 1, `remaining = input` UNCHANGED, one `readCalls`
   consumed, no bytes produced); the SECOND `direct` call then sees
   `reads = [3]` (the `-1` already dropped) against the SAME still-unread
   `abc`, and succeeds. Contrasted with `resetPrim`, which always re-runs
   `BufferRelay.run abc abcReads []` from scratch and so reports the SAME
   read error on every atom, forever -- it cannot recover, by construction,
   because it never advances past the schedule's head. ---- -/

def abcReads : List Int := [-1, 3]
def sErr : WState :=
  { input := abc, reads := abcReads, writes := [], delivered := [],
    fileStore := fun _ => [] }

theorem abcReads_first_status : (BufferRelay.runDetailed abc abcReads []).status = 1 := by
  simp [BufferRelay.runDetailed, BufferRelay.execute, BufferRelay.action, abc, abcReads]

theorem abcReads_first_remaining :
    (BufferRelay.runDetailed abc abcReads []).remaining = abc := by
  simp [BufferRelay.runDetailed, BufferRelay.execute, BufferRelay.action, abc, abcReads]

theorem abcReads_first_output :
    (BufferRelay.runDetailed abc abcReads []).output = ([] : List UInt8) := by
  simp [BufferRelay.runDetailed, BufferRelay.execute, BufferRelay.action, abc, abcReads]

theorem abcReads_first_readCalls :
    (BufferRelay.runDetailed abc abcReads []).readCalls = 1 := by
  simp [BufferRelay.runDetailed, BufferRelay.execute, BufferRelay.action, abc, abcReads]

/-- The stateful model recovers: the first `direct` errors (status 1, no
    bytes), and the SECOND `direct`, now on the residual schedule `[3]`
    against the still-unread `abc`, succeeds and delivers `abc`. -/
theorem read_error_then_recovers :
    ∃ t, Exec stepPrim (Command.seq (.call Atom.direct) (.call Atom.direct)) sErr 0 t ∧
      t.delivered = abc ∧ t.input = [] ∧ t.reads = [] := by
  let t1 : WState :=
    { input := abc, reads := [3], writes := [], delivered := [],
      fileStore := fun _ => [] }
  let t2 : WState :=
    { input := [], reads := [], writes := [], delivered := abc,
      fileStore := fun _ => [] }
  refine ⟨t2, ?_, rfl, rfl, rfl⟩
  apply Exec.seq (rc₁ := 1) (t := t1)
  · apply Exec.call (a := Atom.direct)
    change stepFn Atom.direct sErr = (1, t1)
    simp [stepFn, advanceUnread, detailed, sErr, t1, abcReads_first_status,
      abcReads_first_remaining, abcReads_first_readCalls, abcReads_first_output]
    rfl
  · apply Exec.call (a := Atom.direct)
    change stepFn Atom.direct t1 = (0, t2)
    simp [stepFn, advanceUnread, detailed, t1, t2, abc_status, abc_remaining, abc_readCalls, abc_output]

/-- The REJECTED reset model cannot recover: EVERY atom re-runs
    `BufferRelay.run abc abcReads []` from scratch, so both the first and
    second `direct` report the SAME read error (status 1, no bytes) --
    literally repeating the failure rather than advancing past it. -/
theorem reset_repeats_error :
    ∃ t, Exec (resetPrim abc abcReads [])
        (Command.seq (.call Atom.direct) (.call Atom.direct)) sErr 1 t ∧
      t.delivered = [] := by
  have hs : (BufferRelay.run abc abcReads []).status = 1 := by
    simp [BufferRelay.run, abcReads_first_status]
  have ho : (BufferRelay.run abc abcReads []).output = ([] : List UInt8) := by
    simp [BufferRelay.run, abcReads_first_output]
  refine ⟨sErr, ?_, by simp [sErr]⟩
  apply Exec.seq (rc₁ := 1) (t := sErr)
  · exact Exec.call (a := Atom.direct) ⟨hs.symm, by simp [sErr, ho], rfl, rfl, rfl, rfl⟩
  · exact Exec.call (a := Atom.direct) ⟨hs.symm, by simp [sErr, ho], rfl, rfl, rfl, rfl⟩

end StatefulFinal
