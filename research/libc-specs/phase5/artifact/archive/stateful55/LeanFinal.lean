import ShellObservation

/- Lean-final composed query, kernel-checked, reusing phase3 `ShellObservation`
   unchanged. Hypotheses stand for Coq/native-C facts; there is no Coq-to-Lean
   import and no C-final completion claim.

   REVISION 2026-09-08 (append/truncate + concrete BufferRelay instance).

   REVISION 2026-09-08 (open-failure): Coq `Redirect.v` `redirect_prim` on an
   EMPTY path is open failure (`rc = 1`, `r' = r`): ALL files are preserved,
   including a nonempty prior file, and the underlying atom does not run.
   The previous `H_redirect` concluded
   `t.fileStore path = (if append then prior else []) ++ extra` for EVERY
   `rc`, which on `append = false` FORCES truncation even when open fails --
   contradicting `redirect_open_failure` / `redirect_empty_path_rejected`.
   `H_redirect` is now split: empty path preserves the whole `fileStore`;
   nonempty path still truncates or appends the relay extra. `Concrete` is
   parameterized by `BufferRelay.run` input/reads/writes rather than a single
   abc-success recipe, and includes computed empty-path, append, truncate,
   and relay-error witnesses (nonempty prior file). -/
namespace LeanFinal

open ShellObservation

structure RState where
  delivered : List UInt8
  fileStore : String → List UInt8

inductive Atom where
  | direct
  | redirect (path : String) (append : Bool)
  | mark (b : UInt8)

/-- Empty-path open failure preserves every file; nonempty path writes
    `extra` after optional truncate. Terminal stream unchanged either way. -/
def RedirectOk (path : String) (append : Bool) (s t : RState) (rc : Nat) : Prop :=
  t.delivered = s.delivered ∧
    (path = "" → rc = 1 ∧ t.fileStore = s.fileStore) ∧
    (path ≠ "" → ∃ extra,
      t.fileStore path = (if append then s.fileStore path else []) ++ extra)

theorem redirect_then_mark_success
    (basePrim : Atom → RState → Nat → RState → Prop) (path : String) (append : Bool) (b0 : UInt8)
    (H_mark : ∀ s rc t, basePrim (.mark b0) s rc t →
      rc = 0 ∧ t.delivered = s.delivered ++ [b0] ∧ t.fileStore = s.fileStore)
    (H_redirect : ∀ s rc t, basePrim (.redirect path append) s rc t →
      RedirectOk path append s t rc)
    (s t : RState)
    (he : Exec basePrim (Command.andThen (.call (Atom.redirect path append)) (.call (Atom.mark b0))) s 0 t) :
    t.delivered = s.delivered ++ [b0] ∧
      path ≠ "" ∧
      ∃ extra, t.fileStore path = (if append then s.fileStore path else []) ++ extra := by
  cases he with
  | andZero h1 h2 =>
    cases h1 with
    | call hc =>
      obtain ⟨hdel, hemp, hne⟩ := H_redirect s 0 _ hc
      have hp : path ≠ "" := by
        intro heq
        cases (hemp heq).1
      cases h2 with
      | call hm =>
        obtain ⟨_, hdel2, hfile2⟩ := H_mark _ _ _ hm
        obtain ⟨extra, hfile⟩ := hne hp
        exact ⟨by rw [hdel2, hdel], hp, extra, by rw [hfile2, hfile]⟩
  | andNonzero _ hn => exact absurd rfl hn

theorem redirect_then_mark_error
    (basePrim : Atom → RState → Nat → RState → Prop) (path : String) (append : Bool) (b0 : UInt8)
    (H_mark : ∀ s rc t, basePrim (.mark b0) s rc t →
      rc = 0 ∧ t.delivered = s.delivered ++ [b0] ∧ t.fileStore = s.fileStore)
    (H_redirect : ∀ s rc t, basePrim (.redirect path append) s rc t →
      RedirectOk path append s t rc)
    (s t : RState) (rc : Nat) (hrc : rc ≠ 0)
    (he : Exec basePrim (Command.andThen (.call (Atom.redirect path append)) (.call (Atom.mark b0))) s rc t) :
    t.delivered = s.delivered ∧
      (path = "" → t.fileStore = s.fileStore) := by
  cases he with
  | andZero h1 h2 =>
    cases h2 with
    | call hm =>
      obtain ⟨hrc0, _, _⟩ := H_mark _ _ _ hm
      exact absurd hrc0 hrc
  | andNonzero h1 _ =>
    cases h1 with
    | call hc =>
      obtain ⟨hdel, hemp, _⟩ := H_redirect s rc t hc
      exact ⟨hdel, fun hp => (hemp hp).2⟩

theorem redirect_then_direct_restored
    (basePrim : Atom → RState → Nat → RState → Prop) (path : String) (append : Bool)
    (H_direct : ∀ s rc t, basePrim .direct s rc t →
      ∃ extra, t.delivered = s.delivered ++ extra ∧ t.fileStore = s.fileStore)
    (H_redirect : ∀ s rc t, basePrim (.redirect path append) s rc t →
      RedirectOk path append s t rc)
    (s u : RState) (rc2 : Nat)
    (he : Exec basePrim (Command.seq (.call (Atom.redirect path append)) (.call Atom.direct)) s rc2 u) :
    ∃ extra, u.delivered = s.delivered ++ extra := by
  cases he with
  | seq h1 h2 =>
    cases h1 with
    | call hc =>
      obtain ⟨hdel1, _, _⟩ := H_redirect s _ _ hc
      cases h2 with
      | call hd =>
        obtain ⟨extra2, hdel2, _⟩ := H_direct _ _ _ hd
        exact ⟨extra2, by rw [hdel2, hdel1]⟩

namespace Concrete

def relayOf (input : List UInt8) (reads writes : List Int) : BufferRelay.Outcome :=
  BufferRelay.run input reads writes

def updateFile (path : String) (content : List UInt8) (fs : String → List UInt8) :
    String → List UInt8 :=
  fun p => if p = path then content else fs p

def diverted (input : List UInt8) (reads writes : List Int)
    (path : String) (append : Bool) (s : RState) : RState :=
  let o := relayOf input reads writes
  { delivered := s.delivered
    fileStore := updateFile path
      ((if append then s.fileStore path else []) ++ o.output) s.fileStore }

/-- Parameterized primitive: empty path is open-failure (rc=1, identity on
    state, relay not run); nonempty path diverts `relayOf` output into the
    named file under append/truncate. -/
def concreteBase (input : List UInt8) (reads writes : List Int) :
    Atom → RState → Nat → RState → Prop
  | .direct, s, rc, t =>
      let o := relayOf input reads writes
      rc = o.status ∧ t.delivered = s.delivered ++ o.output ∧ t.fileStore = s.fileStore
  | .redirect path append, s, rc, t =>
      if path = "" then
        rc = 1 ∧ t.delivered = s.delivered ∧ t.fileStore = s.fileStore
      else
        rc = (relayOf input reads writes).status ∧ t = diverted input reads writes path append s
  | .mark b, s, rc, t =>
      rc = 0 ∧ t.delivered = s.delivered ++ [b] ∧ t.fileStore = s.fileStore

theorem concreteBase_H_direct (input : List UInt8) (reads writes : List Int) :
    ∀ s rc t, concreteBase input reads writes .direct s rc t →
      ∃ extra, t.delivered = s.delivered ++ extra ∧ t.fileStore = s.fileStore :=
  fun _ _ _ h => ⟨(relayOf input reads writes).output, h.2.1, h.2.2⟩

theorem concreteBase_H_mark (input : List UInt8) (reads writes : List Int) (b0 : UInt8) :
    ∀ s rc t, concreteBase input reads writes (.mark b0) s rc t →
      rc = 0 ∧ t.delivered = s.delivered ++ [b0] ∧ t.fileStore = s.fileStore :=
  fun _ _ _ h => h

theorem updateFile_at (path : String) (content : List UInt8) (fs : String → List UInt8) :
    updateFile path content fs path = content := by
  simp [updateFile]

theorem concreteBase_H_redirect (input : List UInt8) (reads writes : List Int)
    (path0 : String) (append0 : Bool) :
    ∀ s rc t, concreteBase input reads writes (.redirect path0 append0) s rc t →
      RedirectOk path0 append0 s t rc := by
  intro s rc t h
  by_cases hp : path0 = ""
  · simp [concreteBase, hp] at h
    exact ⟨h.2.1, fun _ => ⟨h.1, h.2.2⟩, fun hne => False.elim (hne hp)⟩
  · simp [concreteBase, hp] at h
    obtain ⟨hrc, ht⟩ := h
    subst ht
    refine ⟨rfl, fun heq => False.elim (hp heq), ?_⟩
    intro _
    exact ⟨(relayOf input reads writes).output, updateFile_at path0 _ s.fileStore⟩

theorem concreteBase_satisfiable (input : List UInt8) (reads writes : List Int)
    (path0 : String) (append0 : Bool) (b0 : UInt8) :
    (∀ s rc t, concreteBase input reads writes .direct s rc t →
        ∃ extra, t.delivered = s.delivered ++ extra ∧ t.fileStore = s.fileStore) ∧
    (∀ s rc t, concreteBase input reads writes (.mark b0) s rc t →
        rc = 0 ∧ t.delivered = s.delivered ++ [b0] ∧ t.fileStore = s.fileStore) ∧
    (∀ s rc t, concreteBase input reads writes (.redirect path0 append0) s rc t →
        RedirectOk path0 append0 s t rc) :=
  ⟨concreteBase_H_direct input reads writes,
    concreteBase_H_mark input reads writes b0,
    concreteBase_H_redirect input reads writes path0 append0⟩

def abc : List UInt8 := [97, 98, 99]
def priorXY : List UInt8 := [120, 121]
def sPrior : RState :=
  { delivered := []
    fileStore := fun p => if p = "out" then priorXY else [] }

theorem abc_status_zero : (relayOf abc [3] []).status = 0 := by
  simp [relayOf, abc, BufferRelay.run, BufferRelay.runDetailed,
    BufferRelay.execute, BufferRelay.drain, BufferRelay.loaded_eq,
    BufferRelay.readAmount, BufferRelay.action]

theorem abc_output : (relayOf abc [3] []).output = abc := by
  simp [relayOf, abc, BufferRelay.run, BufferRelay.runDetailed,
    BufferRelay.execute, BufferRelay.drain, BufferRelay.loaded_eq,
    BufferRelay.readAmount, BufferRelay.action]

theorem abc_read_error_status : (relayOf abc [-1] []).status = 1 := by
  simp [relayOf, abc, BufferRelay.run, BufferRelay.runDetailed,
    BufferRelay.execute, BufferRelay.action]

theorem abc_read_error_output : (relayOf abc [-1] []).output = [] := by
  simp [relayOf, abc, BufferRelay.run, BufferRelay.runDetailed,
    BufferRelay.execute, BufferRelay.action]

/-- Truncating `>` over a nonempty prior file: prior `xy` is dropped. -/
theorem truncate_over_existing_witness :
    ∃ t, Exec (concreteBase abc [3] [])
        (Command.andThen (.call (Atom.redirect "out" false)) (.call (Atom.mark 33)))
        sPrior 0 t ∧
      t.delivered = [33] ∧ t.fileStore "out" = abc := by
  let tMid := diverted abc [3] [] "out" false sPrior
  let tFin : RState := { delivered := [33], fileStore := tMid.fileStore }
  refine ⟨tFin, ?_, rfl, ?_⟩
  · apply Exec.andZero (b := Command.call (Atom.mark 33))
    · exact Exec.call (a := Atom.redirect "out" false)
        (And.intro abc_status_zero.symm rfl)
    · exact Exec.call (a := Atom.mark 33) ⟨rfl, rfl, rfl⟩
  · simp [tFin, tMid, diverted, updateFile, sPrior]
    rw [abc_output]

/-- Appending `>>` over the same nonempty prior: `xy` is kept. -/
theorem append_over_existing_witness :
    ∃ t, Exec (concreteBase abc [3] [])
        (Command.call (Atom.redirect "out" true)) sPrior 0 t ∧
      t.fileStore "out" = priorXY ++ abc := by
  let tFin := diverted abc [3] [] "out" true sPrior
  refine ⟨tFin, Exec.call (a := Atom.redirect "out" true) (And.intro abc_status_zero.symm rfl), ?_⟩
  simp [tFin, diverted, updateFile, sPrior]
  rw [abc_output]

/-- Empty-path open failure: rc=1, prior nonempty file UNCHANGED (not truncated). -/
theorem empty_path_open_failure_witness :
    ∃ t, Exec (concreteBase abc [3] [])
        (Command.andThen (.call (Atom.redirect "" false)) (.call (Atom.mark 33)))
        sPrior 1 t ∧
      t.delivered = sPrior.delivered ∧ t.fileStore "out" = priorXY := by
  refine ⟨sPrior, ?_, rfl, by simp [sPrior, priorXY]⟩
  refine Exec.andNonzero ?_ (Nat.succ_ne_zero 0)
  exact Exec.call (a := Atom.redirect "" false) ⟨rfl, rfl, rfl⟩

/-- Relay read-error on a nonempty path still records the (empty) extra. -/
theorem relay_error_nonempty_path_witness :
    ∃ t, concreteBase abc [-1] [] (.redirect "out" false) sPrior 1 t ∧
      t.delivered = [] ∧ t.fileStore "out" = [] := by
  let tFin := diverted abc [-1] [] "out" false sPrior
  refine ⟨tFin, And.intro abc_read_error_status.symm rfl, rfl, ?_⟩
  simp [tFin, diverted, updateFile, sPrior]
  rw [abc_read_error_output]

/-- General composed success theorem applied to the parameterized reference. -/
theorem parameterized_success_applied :
    ∃ t, Exec (concreteBase abc [3] [])
        (Command.andThen (.call (Atom.redirect "out" false)) (.call (Atom.mark 33)))
        sPrior 0 t ∧
      t.delivered = sPrior.delivered ++ [33] ∧
      ∃ extra, t.fileStore "out" = extra := by
  obtain ⟨t, he, _, _⟩ := truncate_over_existing_witness
  have h := redirect_then_mark_success (concreteBase abc [3] []) "out" false 33
    (concreteBase_H_mark abc [3] [] 33)
    (concreteBase_H_redirect abc [3] [] "out" false) sPrior t he
  exact ⟨t, he, h.1, h.2.2⟩

/-- General composed error theorem on empty-path open failure: files kept. -/
theorem parameterized_empty_path_error_applied :
    ∃ t, Exec (concreteBase abc [3] [])
        (Command.andThen (.call (Atom.redirect "" false)) (.call (Atom.mark 33)))
        sPrior 1 t ∧
      t.delivered = sPrior.delivered ∧ t.fileStore = sPrior.fileStore := by
  obtain ⟨t, he, hdel, _⟩ := empty_path_open_failure_witness
  have h := redirect_then_mark_error (concreteBase abc [3] []) "" false 33
    (concreteBase_H_mark abc [3] [] 33)
    (concreteBase_H_redirect abc [3] [] "" false) sPrior t 1 (Nat.succ_ne_zero 0) he
  exact ⟨t, he, h.1, h.2 rfl⟩

end Concrete

end LeanFinal
