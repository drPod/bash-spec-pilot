import BufferRelay

/- A relational interface for a hand-authored, terminating command fragment.
   This is not Bash parsing, process, pipe, or State Calculus semantics.
   The transfer theorem preserves states AND exit statuses. It accommodates
   nondeterministic primitive relations, but only finite terminating executions. -/
namespace ShellObservation

inductive Command (Atom : Type) where
  | call (name : Atom)
  | seq (left right : Command Atom)
  | andThen (left right : Command Atom)
  | orElse (left right : Command Atom)

abbrev Primitive (Atom State : Type) := Atom → State → Nat → State → Prop

inductive Exec (prim : Primitive Atom State) :
    Command Atom → State → Nat → State → Prop where
  | call : prim a s rc t → Exec prim (.call a) s rc t
  | seq : Exec prim a s rc₁ t → Exec prim b t rc₂ u →
      Exec prim (.seq a b) s rc₂ u
  | andZero : Exec prim a s 0 t → Exec prim b t rc u →
      Exec prim (.andThen a b) s rc u
  | andNonzero : Exec prim a s rc t → rc ≠ 0 →
      Exec prim (.andThen a b) s rc t
  | orZero : Exec prim a s 0 t → Exec prim (.orElse a b) s 0 t
  | orNonzero : Exec prim a s rc₁ t → rc₁ ≠ 0 → Exec prim b t rc₂ u →
      Exec prim (.orElse a b) s rc₂ u

/-- A forward simulation must preserve the exit code and relate the successor
    state. Keeping only stdout equality does not meet this premise. -/
def PrimitiveRefines (concrete : Primitive Atom C) (abstract : Primitive Atom A)
    (R : C → A → Prop) : Prop :=
  ∀ name c a, R c a → ∀ rc c', concrete name c rc c' →
    ∃ a', abstract name a rc a' ∧ R c' a'


/-- All terminating concrete behaviors satisfy an abstract query when primitive
    simulation and query preservation are proved. This does not imply termination. -/
theorem query_transfer (concrete : Primitive Atom C) (abstract : Primitive Atom A)
    (R : C → A → Prop) (hp : PrimitiveRefines concrete abstract R)
    (cmd : Command Atom) (c : C) (a : A) (hr : R c a)
    (Q : Nat → A → Prop) (P : Nat → C → Prop)
    (hq : ∀ rc a', Exec abstract cmd a rc a' → Q rc a')
    (hobs : ∀ rc c' a', R c' a' → Q rc a' → P rc c') :
    ∀ rc c', Exec concrete cmd c rc c' → P rc c' :=

end ShellObservation
