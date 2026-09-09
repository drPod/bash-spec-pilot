import Std

/- Mathematical modular counter, not C instruction semantics.
No compiler, ABI, or type-width connection is proved; 256 illustrates an 8-bit counter, not size_t.
-/
namespace CounterRefinement

abbrev Byte := UInt8

def newlineCount (xs : List Byte) : Nat := xs.count 10

def step (modulus : Nat) (positive : 0 < modulus)
    (counter : Fin modulus) (byte : Byte) : Fin modulus :=
  if byte = 10 then
    ⟨(counter.val + 1) % modulus, Nat.mod_lt _ positive⟩
  else counter

def run (modulus : Nat) (positive : 0 < modulus) :
    Fin modulus → List Byte → Fin modulus
  | counter, [] => counter
  | counter, byte :: rest => run modulus positive (step modulus positive counter byte) rest

theorem run_value (modulus : Nat) (positive : 0 < modulus) (xs : List Byte) :
    ∀ initial : Fin modulus,
      (run modulus positive initial xs).val =
        (initial.val + newlineCount xs) % modulus := by
  induction xs with
  | nil =>
    intro initial
    simp [run, newlineCount, Nat.mod_eq_of_lt initial.isLt]
  | cons byte rest ih =>
    intro initial
    simp only [run, ih]
    by_cases hb : byte = 10
    · subst byte
      simp [step, newlineCount, Nat.mod_add_mod, Nat.add_assoc,
        Nat.add_comm]
    · simp [step, hb, newlineCount]

theorem run_append (modulus : Nat) (positive : 0 < modulus) (xs ys : List Byte) :
    ∀ initial : Fin modulus,
      run modulus positive initial (xs ++ ys) =
        run modulus positive (run modulus positive initial xs) ys := by
  induction xs with
  | nil => intro initial; rfl
  | cons byte rest ih =>
    intro initial
    simpa only [List.cons_append, run] using ih (step modulus positive initial byte)

def fromNat (modulus : Nat) (positive : 0 < modulus) (initial : Nat) : Fin modulus :=
  ⟨initial % modulus, Nat.mod_lt _ positive⟩

theorem run_from_nat (modulus : Nat) (positive : 0 < modulus)
    (initial : Nat) (xs : List Byte) :
    (run modulus positive (fromNat modulus positive initial) xs).val =
      (initial + newlineCount xs) % modulus := by
  rw [run_value]
  simp [fromNat]

theorem no_overflow_refinement (modulus : Nat) (positive : 0 < modulus)
    (initial : Fin modulus) (xs : List Byte)
    (noOverflow : initial.val + newlineCount xs < modulus) :
    (run modulus positive initial xs).val = initial.val + newlineCount xs := by
  rw [run_value, Nat.mod_eq_of_lt noOverflow]

theorem zero_start_refinement (modulus : Nat) (positive : 0 < modulus)
    (xs : List Byte) (noOverflow : newlineCount xs < modulus) :
    (run modulus positive ⟨0, positive⟩ xs).val = newlineCount xs := by
  simpa using no_overflow_refinement modulus positive ⟨0, positive⟩ xs
    (by simpa using noOverflow)

/-- A stream-prefix equation, as established by MemoryTransfer.relays_observation,
suffices to transport the modular count to an output byte stream. -/
theorem prefix_stream_refinement (modulus : Nat) (positive : 0 < modulus)
    (initial : Fin modulus) (input oldOutput newOutput : List Byte) (consumed : Nat)
    (h : newOutput = oldOutput ++ input.take consumed) :
    (run modulus positive initial newOutput).val =
      (initial.val + newlineCount oldOutput + newlineCount (input.take consumed)) %
        modulus := by
  rw [run_value, h]
  simp [newlineCount, Nat.add_assoc]

theorem counter8_255 :
    (run 256 (by decide) ⟨0, by decide⟩ (List.replicate 255 10)).val = 255 := by
  rw [run_value]
  simp only [newlineCount, List.count_replicate_self]

theorem counter8_256 :
    (run 256 (by decide) ⟨0, by decide⟩ (List.replicate 256 10)).val = 0 := by
  rw [run_value]
  simp only [newlineCount, List.count_replicate_self]

theorem counter8_wrap_gap :
    (run 256 (by decide) ⟨0, by decide⟩ (List.replicate 256 10)).val ≠
      newlineCount (List.replicate 256 10) := by
  rw [counter8_256]
  simp only [newlineCount, List.count_replicate_self]
  decide

end CounterRefinement

#print axioms CounterRefinement.step
#print axioms CounterRefinement.run
#print axioms CounterRefinement.run_value
#print axioms CounterRefinement.run_append
#print axioms CounterRefinement.run_from_nat
#print axioms CounterRefinement.no_overflow_refinement
#print axioms CounterRefinement.zero_start_refinement
#print axioms CounterRefinement.prefix_stream_refinement
#print axioms CounterRefinement.counter8_255
#print axioms CounterRefinement.counter8_256
#print axioms CounterRefinement.counter8_wrap_gap
