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


theorem fragment_refines (cmd : ShellObservation.Command Atom) (s t : Streams)
    (rc : Nat) (h : ShellObservation.Exec (graph concrete) cmd s rc t) :
    ShellObservation.Exec (graph abstract) cmd s rc t :=

end RelayComposition
