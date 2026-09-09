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

theorem command_refines (concrete : Primitive Atom C) (abstract : Primitive Atom A)
    (R : C → A → Prop) (hp : PrimitiveRefines concrete abstract R)
    (cmd : Command Atom) (c c' : C) (rc : Nat)
    (he : Exec concrete cmd c rc c') :
    ∀ a, R c a → ∃ a', Exec abstract cmd a rc a' ∧ R c' a' := by
  induction he with
  | call h =>
      intro a hr
      obtain ⟨a', ha, hr'⟩ := hp _ _ a hr _ _ h
      exact ⟨a', .call ha, hr'⟩
  | seq _ _ ih₁ ih₂ =>
      intro a hr
      obtain ⟨t, ht, hrt⟩ := ih₁ a hr
      obtain ⟨u, hu, hru⟩ := ih₂ t hrt
      exact ⟨u, .seq ht hu, hru⟩
  | andZero _ _ ih₁ ih₂ =>
      intro a hr
      obtain ⟨t, ht, hrt⟩ := ih₁ a hr
      obtain ⟨u, hu, hru⟩ := ih₂ t hrt
      exact ⟨u, .andZero ht hu, hru⟩
  | andNonzero _ hn ih =>
      intro a hr
      obtain ⟨t, ht, hrt⟩ := ih a hr
      exact ⟨t, .andNonzero ht hn, hrt⟩
  | orZero _ ih =>
      intro a hr
      obtain ⟨t, ht, hrt⟩ := ih a hr
      exact ⟨t, .orZero ht, hrt⟩
  | orNonzero _ hn _ ih₁ ih₂ =>
      intro a hr
      obtain ⟨t, ht, hrt⟩ := ih₁ a hr
      obtain ⟨u, hu, hru⟩ := ih₂ t hrt
      exact ⟨u, .orNonzero ht hn hu, hru⟩

/-- All terminating concrete behaviors satisfy an abstract query when primitive
    simulation and query preservation are proved. This does not imply termination. -/
theorem query_transfer (concrete : Primitive Atom C) (abstract : Primitive Atom A)
    (R : C → A → Prop) (hp : PrimitiveRefines concrete abstract R)
    (cmd : Command Atom) (c : C) (a : A) (hr : R c a)
    (Q : Nat → A → Prop) (P : Nat → C → Prop)
    (hq : ∀ rc a', Exec abstract cmd a rc a' → Q rc a')
    (hobs : ∀ rc c' a', R c' a' → Q rc a' → P rc c') :
    ∀ rc c', Exec concrete cmd c rc c' → P rc c' := by
  intro rc c' he
  obtain ⟨a', ha', hr'⟩ := command_refines concrete abstract R hp cmd c c' rc he a hr
  exact hobs rc c' a' hr' (hq rc a' ha')

/-- The stdout observation of `command && printf '!'` in a finite, successful
    marker-output adapter. Real marker write failures are outside this function. -/
def andMark (r : BufferRelay.Outcome) : List UInt8 :=
  if r.status = 0 then r.output ++ [33] else r.output

def success : BufferRelay.Outcome := BufferRelay.run [97, 98, 99] [3] []
def lateError : BufferRelay.Outcome := BufferRelay.run [97, 98, 99] [3, -1] []

theorem same_bytes : success.output = lateError.output := by
  simp [success, lateError, BufferRelay.run, BufferRelay.runDetailed,
    BufferRelay.execute, BufferRelay.drain, BufferRelay.loaded_eq,
    BufferRelay.readAmount, BufferRelay.action]

theorem different_context_bytes : andMark success ≠ andMark lateError := by
  simp [andMark, success, lateError, BufferRelay.run, BufferRelay.runDetailed,
    BufferRelay.execute, BufferRelay.drain, BufferRelay.loaded_eq,
    BufferRelay.readAmount, BufferRelay.action]

theorem no_stdout_only_context :
    ¬ ∃ f : List UInt8 → List UInt8,
      f success.output = andMark success ∧ f lateError.output = andMark lateError := by
  rintro ⟨f, hs, he⟩
  apply different_context_bytes
  rw [← hs, ← he, same_bytes]

end ShellObservation
