import Std

/-
An executable mathematical model, NOT a semantics or translation of C/POSIX.
One finite allocated object, 8-bit bytes, abstract block identity and natural
offsets. Allocation, lifetime, alias provenance, integer overflow, permissions,
concurrency, signals, fd state, and partial effects on error are out of scope.

The entire requested buffer must be valid, even on an error/short-read path.
Zero-size access allows one-past in the same allocation; null is not represented.
UB is a distinct diagnostic result, not a claim that C UB has defined behavior.
The environment selects an error or a quota; success transfers the shortest
of request, quota, and available input. Quota zero may stall even before EOF.
-/
namespace MemoryTransfer

abbrev Byte := UInt8
abbrev Memory (size : Nat) := Fin size → Byte

structure Pointer where
  block : Nat
  offset : Nat
  deriving DecidableEq, Repr

def Valid (block size : Nat) (p : Pointer) (n : Nat) : Prop :=
  p.block = block ∧ p.offset + n ≤ size

instance (block size : Nat) (p : Pointer) (n : Nat) :
    Decidable (Valid block size p n) := inferInstanceAs (Decidable (_ ∧ _))

/-- Internal total update. The public operation checks the full requested range. -/
def store (m : Memory size) (off : Nat) (xs : List Byte) : Memory size :=
  fun i => if h : off ≤ i.val ∧ i.val - off < xs.length then
    xs[i.val - off]'h.2 else m i

def load (m : Memory size) (off n : Nat) (h : off + n ≤ size) : List Byte :=
  List.ofFn fun i : Fin n => m ⟨off + i.val, by omega⟩

theorem store_frame (m : Memory size) (off : Nat) (xs : List Byte)
    (i : Fin size) (h : i.val < off ∨ off + xs.length ≤ i.val) :
    store m off xs i = m i := by
  simp only [store]
  split
  · omega
  · rfl

theorem store_at (m : Memory size) (off : Nat) (xs : List Byte)
    (i : Fin size) (hlo : off ≤ i.val) (hhi : i.val - off < xs.length) :
    store m off xs i = xs[i.val - off] := by
  simp [store, hlo, hhi]

theorem load_store (m : Memory size) (off : Nat) (xs : List Byte)
    (h : off + xs.length ≤ size) :
    load (store m off xs) off xs.length h = xs := by
  apply List.ext_getElem
  · simp [load]
  · intro i hi hj
    simp only [load, List.getElem_ofFn]
    simp [store, hj]

theorem load_store_disjoint (m : Memory size) (off : Nat) (xs : List Byte)
    (other n : Nat) (h : other + n ≤ size)
    (sep : other + n ≤ off ∨ off + xs.length ≤ other) :
    load (store m off xs) other n h = load m other n h := by
  apply List.ext_getElem
  · simp [load]
  · intro i hi hj
    simp only [load, List.length_ofFn] at hi
    simp only [load, List.getElem_ofFn]
    apply store_frame
    change other + i < off ∨ off + xs.length ≤ other + i
    omega

inductive IOError where
  | interrupted | unavailable | device
  deriving DecidableEq, Repr

inductive Environment where
  | fail (e : IOError)
  | ready (quota : Nat)
  deriving DecidableEq, Repr

structure State (size : Nat) where
  mem : Memory size
  input : List Byte
  output : List Byte

inductive Result (size : Nat) where
  | ok (count : Nat) (state : State size)
  | error (e : IOError) (state : State size)
  | ub

def amount (request quota : Nat) (input : List Byte) : Nat :=
  min request (min quota input.length)

def afterRead (s : State size) (p : Pointer) (k : Nat) : State size :=
  { s with mem := store s.mem p.offset (s.input.take k), input := s.input.drop k }

def read (block : Nat) (s : State size) (p : Pointer) (request : Nat)
    (env : Environment) : Result size :=
  if Valid block size p request then
    match env with
    | .fail e => .error e s
    | .ready quota =>
      let k := amount request quota s.input
      .ok k (afterRead s p k)
  else .ub

theorem invalid_is_ub (s : State size) (p : Pointer) (request : Nat)
    (h : ¬ Valid block size p request) (env : Environment) :
    read block s p request env = .ub := by simp [read, h]

theorem error_preserves_state (s : State size) (p : Pointer) (request : Nat)
    (h : Valid block size p request) (e : IOError) :
    read block s p request (.fail e) = .error e s := by simp [read, h]

theorem amount_bounds (request quota : Nat) (input : List Byte) :
    amount request quota input ≤ request ∧
    amount request quota input ≤ quota ∧
    amount request quota input ≤ input.length := by
  simp only [amount]
  omega

theorem success_bounds (s t : State size) (p : Pointer) (request : Nat)
    (env : Environment) (k : Nat)
    (h : read block s p request env = .ok k t) :
    Valid block size p request ∧ k ≤ request ∧ k ≤ s.input.length := by
  unfold read at h
  split at h
  next hv =>
    cases env with
    | fail e => contradiction
    | ready quota =>
      cases h
      exact ⟨hv, (amount_bounds _ _ _).1, (amount_bounds _ _ _).2.2⟩
  next => contradiction

theorem success_contract (s t : State size) (p : Pointer) (request : Nat)
    (env : Environment) (k : Nat)
    (h : read block s p request env = .ok k t) :
    ∃ hk : p.offset + k ≤ size,
      load t.mem p.offset k hk = s.input.take k ∧
      t.input = s.input.drop k ∧ t.output = s.output ∧
      (∀ i : Fin size, i.val < p.offset ∨ p.offset + k ≤ i.val →
        t.mem i = s.mem i) := by
  have hb := success_bounds s t p request env k h
  have hk : p.offset + k ≤ size := by have := hb.1.2; omega
  unfold read at h
  split at h
  next hv =>
    cases env with
    | fail e => contradiction
    | ready quota =>
      cases h
      have hl : (s.input.take (amount request quota s.input)).length =
          amount request quota s.input := by
        simp [List.length_take, Nat.min_eq_left (amount_bounds _ _ _).2.2]
      refine ⟨hk, ?_, rfl, rfl, ?_⟩
      · simpa only [afterRead, hl] using
          load_store s.mem p.offset (s.input.take (amount request quota s.input))
            (by simpa only [hl] using hk)
      · intro i hi
        apply store_frame
        simpa only [hl] using hi
  next => contradiction

def emit (s : State size) (p : Pointer) (k : Nat) (h : p.offset + k ≤ size) :
    State size := { s with output := s.output ++ load s.mem p.offset k h }

theorem read_emit_observation (s t : State size) (p : Pointer) (request : Nat)
    (env : Environment) (k : Nat)
    (h : read block s p request env = .ok k t) :
    ∃ hk : p.offset + k ≤ size,
      (emit t p k hk).output = s.output ++ s.input.take k ∧
      (emit t p k hk).input = s.input.drop k := by
  obtain ⟨hk, hm, hi, ho, _⟩ := success_contract s t p request env k h
  exact ⟨hk, by simp [emit, hm, ho], hi⟩

def Relay (block : Nat) (s : State size) (p : Pointer) (request : Nat)
    (env : Environment) (k : Nat) (t : State size) : Prop :=
  ∃ middle : State size, ∃ hk : p.offset + k ≤ size,
    read block s p request env = .ok k middle ∧ t = emit middle p k hk

theorem relay_contract (s t : State size) (p : Pointer) (request : Nat)
    (env : Environment) (k : Nat) (h : Relay block s p request env k t) :
    t.output = s.output ++ s.input.take k ∧
    t.input = s.input.drop k ∧ k ≤ s.input.length := by
  obtain ⟨middle, hk, hr, rfl⟩ := h
  obtain ⟨_, ho, hi⟩ := read_emit_observation s middle p request env k hr
  exact ⟨ho, hi, (success_bounds s middle p request env k hr).2.2⟩

theorem ready_relay_exists (s : State size) (p : Pointer) (request quota : Nat)
    (h : Valid block size p request) :
    ∃ t, Relay block s p request (.ready quota) (amount request quota s.input) t := by
  have hk : p.offset + amount request quota s.input ≤ size := by
    have := h.2
    have := (amount_bounds request quota s.input).1
    omega
  refine ⟨emit (afterRead s p (amount request quota s.input)) p _ hk,
    afterRead s p (amount request quota s.input), hk, ?_, rfl⟩
  simp [read, h]

/-- Any finite sequence of successful relays. Pointers, requests and quotas may
change on every call, buffers may overlap/reuse storage, and reads may be short.
This relation does not assert termination or eventual progress. -/
inductive Relays (block : Nat) : State size → Nat → State size → Prop where
  | nil (s) : Relays block s 0 s
  | snoc {s t u total k p request env} : Relays block s total t →
      Relay block t p request env k u → Relays block s (total + k) u

theorem relays_observation (s t : State size) (total : Nat)
    (h : Relays block s total t) :
    t.output = s.output ++ s.input.take total ∧
    t.input = s.input.drop total ∧ total ≤ s.input.length := by
  induction h with
  | nil => simp
  | @snoc t u total k p request env hist step ih =>
    obtain ⟨ho, hi, hb⟩ := ih
    obtain ⟨uo, ui, ub⟩ := relay_contract t u p request env k step
    refine ⟨?_, ?_, ?_⟩
    · rw [uo, ho, hi, List.append_assoc, ← List.take_add]
    · rw [ui, hi, List.drop_drop]
    · rw [hi, List.length_drop] at ub
      omega

theorem relays_conservation (s t : State size) (total : Nat)
    (h : Relays block s total t) :
    t.output.length = s.output.length + total ∧
    t.input.length + total = s.input.length ∧
    (∀ b : Byte, t.output.count b =
      s.output.count b + (s.input.take total).count b) := by
  obtain ⟨ho, hi, hb⟩ := relays_observation s t total h
  refine ⟨?_, ?_, ?_⟩
  · simp [ho, List.length_take, Nat.min_eq_left hb]
  · rw [hi, List.length_drop]
    omega
  · intro b
    simp [ho]

namespace Examples

def initial : State 6 :=
  { mem := fun _ => 170, input := [0, 255, 10, 13, 128], output := [42] }

inductive Observation where
  | ub
  | error (e : IOError) (memory input output : List Byte)
  | ok (count : Nat) (memory input output : List Byte)
  deriving DecidableEq, Repr

def observe : Result size → Observation
  | .ub => .ub
  | .error e s => .error e (List.ofFn s.mem) s.input s.output
  | .ok k s => .ok k (List.ofFn s.mem) s.input s.output

theorem short_binary_read :
    observe (read 7 initial ⟨7, 1⟩ 4 (.ready 2)) =
      .ok 2 [170, 0, 255, 170, 170, 170] [10, 13, 128] [42] := by decide

theorem exhausted_input_read :
    observe (read 7 initial ⟨7, 0⟩ 6 (.ready 100)) =
      .ok 5 [0, 255, 10, 13, 128, 170] [] [42] := by decide

theorem foreign_pointer_ub :
    observe (read 7 initial ⟨8, 0⟩ 1 (.ready 1)) = .ub := by decide

theorem overrun_ub_even_when_short :
    observe (read 7 initial ⟨7, 5⟩ 2 (.ready 1)) = .ub := by decide

theorem one_past_zero :
    observe (read 7 initial ⟨7, 6⟩ 0 (.ready 10)) =
      .ok 0 [170, 170, 170, 170, 170, 170] [0, 255, 10, 13, 128] [42] := by decide

theorem one_past_nonzero_ub :
    observe (read 7 initial ⟨7, 6⟩ 1 (.ready 10)) = .ub := by decide

theorem error_has_no_effect :
    observe (read 7 initial ⟨7, 1⟩ 4 (.fail .interrupted)) =
      .error .interrupted [170, 170, 170, 170, 170, 170]
        [0, 255, 10, 13, 128] [42] := by decide

theorem invalid_error_path_is_ub :
    observe (read 7 initial ⟨8, 1⟩ 4 (.fail .interrupted)) = .ub := by decide

end Examples

end MemoryTransfer

#print axioms MemoryTransfer.load_store
#print axioms MemoryTransfer.load_store_disjoint
#print axioms MemoryTransfer.success_bounds
#print axioms MemoryTransfer.success_contract
#print axioms MemoryTransfer.read_emit_observation

#print axioms MemoryTransfer.relay_contract
#print axioms MemoryTransfer.relays_observation
#print axioms MemoryTransfer.relays_conservation
#print axioms MemoryTransfer.ready_relay_exists
#print axioms MemoryTransfer.store_frame
#print axioms MemoryTransfer.invalid_is_ub
#print axioms MemoryTransfer.error_preserves_state
#print axioms MemoryTransfer.Examples.short_binary_read
#print axioms MemoryTransfer.Examples.exhausted_input_read
#print axioms MemoryTransfer.Examples.foreign_pointer_ub
#print axioms MemoryTransfer.Examples.overrun_ub_even_when_short
#print axioms MemoryTransfer.Examples.one_past_zero
#print axioms MemoryTransfer.Examples.one_past_nonzero_ub
#print axioms MemoryTransfer.Examples.error_has_no_effect
#print axioms MemoryTransfer.Examples.invalid_error_path_is_ub
#print axioms MemoryTransfer.store_at
#print axioms MemoryTransfer.amount_bounds
#print axioms MemoryTransfer.read
#print axioms MemoryTransfer.emit
