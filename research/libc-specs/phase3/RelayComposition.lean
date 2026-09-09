import PointerRelay
import ShellObservation

/- A hand-authored finite command fragment over independent byte streams.
   Relay-private pending bytes are hidden only at process exit; unread stream
   contents, delivered bytes and status remain observable. No file descriptors,
   parser, actual processes, pipelines or host stdin ingestion are modeled. -/
namespace RelayComposition

structure Streams where
  input : List UInt8
  output : List UInt8
  deriving DecidableEq, Repr

inductive Atom where
  | relay (reads writes : List Int)
  | mark (byte : UInt8)

def applyOutcome (s : Streams) (o : BufferRelay.Detailed) : Nat × Streams :=
  (o.status, ⟨o.remaining, s.output ++ o.output⟩)

def concrete : Atom → Streams → Nat × Streams
  | .relay r w, s => applyOutcome s (PointerRelay.observe (PointerRelay.run s.input r w).state)
  | .mark b, s => (0, { s with output := s.output ++ [b] })

def abstract : Atom → Streams → Nat × Streams
  | .relay r w, s => applyOutcome s (BufferRelay.runDetailed s.input r w)
  | .mark b, s => (0, { s with output := s.output ++ [b] })

def graph (f : Atom → Streams → Nat × Streams) :
    ShellObservation.Primitive Atom Streams := fun a s rc t => f a s = (rc, t)

theorem primitive_eq (a : Atom) (s : Streams) : concrete a s = abstract a s := by
  cases a with
  | relay r w => simp only [concrete, abstract, PointerRelay.run_detailed_eq]
  | mark b => rfl

theorem primitive_refines :
    ShellObservation.PrimitiveRefines (graph concrete) (graph abstract) Eq := by
  intro a c s h rc c' he
  subst s
  exact ⟨c', by simpa only [graph, primitive_eq] using he, rfl⟩

theorem fragment_refines (cmd : ShellObservation.Command Atom) (s t : Streams)
    (rc : Nat) (h : ShellObservation.Exec (graph concrete) cmd s rc t) :
    ShellObservation.Exec (graph abstract) cmd s rc t := by
  obtain ⟨t', he, hr⟩ := ShellObservation.command_refines (graph concrete) (graph abstract)
    Eq primitive_refines cmd s t rc h s rfl
  simpa only [← hr] using he

/-- Total executable semantics of the finite fragment, for reachability rather
    than a premise that could silently exclude all executions. -/
def runFragment (f : Atom → Streams → Nat × Streams) :
    ShellObservation.Command Atom → Streams → Nat × Streams
  | .call a, s => f a s
  | .seq a b, s => runFragment f b (runFragment f a s).2
  | .andThen a b, s =>
      let t := runFragment f a s
      if t.1 = 0 then runFragment f b t.2 else t
  | .orElse a b, s =>
      let t := runFragment f a s
      if t.1 = 0 then t else runFragment f b t.2

theorem runFragment_reachable (f : Atom → Streams → Nat × Streams)
    (cmd : ShellObservation.Command Atom) (s : Streams) :
    ShellObservation.Exec (graph f) cmd s (runFragment f cmd s).1
      (runFragment f cmd s).2 := by
  induction cmd generalizing s with
  | call a => exact .call (by simp [graph, runFragment])
  | seq a b ih₁ ih₂ => exact .seq (ih₁ s) (ih₂ (runFragment f a s).2)
  | andThen a b ih₁ ih₂ =>
      dsimp only [runFragment]
      split
      next hz => exact .andZero (by simpa only [hz] using ih₁ s) (ih₂ _)
      next hn => exact .andNonzero (ih₁ s) hn
  | orElse a b ih₁ ih₂ =>
      dsimp only [runFragment]
      split
      next hz =>
        have hzero : ShellObservation.Exec (graph f) a s 0 (runFragment f a s).2 :=
          by simpa only [hz] using ih₁ s
        simpa only [hz] using (ShellObservation.Exec.orZero (b := b) hzero)
      next hn => exact .orNonzero (ih₁ s) hn (ih₂ _)

theorem runFragment_eq (cmd : ShellObservation.Command Atom) (s : Streams) :
    runFragment concrete cmd s = runFragment abstract cmd s := by
  have hf : concrete = abstract := funext fun a => funext fun s => primitive_eq a s
  rw [hf]

/-- The first relay read `abcd` but delivered only `ab`; its private `cd` is
    discarded on exit. A fresh relay starts from unread `ef`, so `;` yields `abef`.
    This is shared mathematical stream state, not eager-ingestion host drivers. -/
theorem pending_discarded_at_exit :
    runFragment concrete
      (.seq (.call (.relay [4] [2, 0])) (.call (.relay [] [])))
      ⟨[97, 98, 99, 100, 101, 102], []⟩ = (0, ⟨[], [97, 98, 101, 102]⟩) := by
  rw [runFragment_eq]
  simp [runFragment, abstract, applyOutcome, BufferRelay.runDetailed,
    BufferRelay.execute, BufferRelay.drain, BufferRelay.loaded_eq,
    BufferRelay.readAmount, BufferRelay.action]

end RelayComposition
