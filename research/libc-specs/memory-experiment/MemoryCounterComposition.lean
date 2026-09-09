import MemoryTransfer
import CounterRefinement

/- This bridges two mathematical models, not C or POSIX operational semantics. -/
namespace MemoryCounterComposition

theorem relay_modular_count (s t : MemoryTransfer.State size) (total : Nat)
    (trace : MemoryTransfer.Relays block s total t)
    (modulus : Nat) (positive : 0 < modulus) (initial : Fin modulus) :
    (CounterRefinement.run modulus positive initial t.output).val =
      (initial.val + CounterRefinement.newlineCount s.output +
        CounterRefinement.newlineCount (s.input.take total)) % modulus := by
  exact CounterRefinement.prefix_stream_refinement modulus positive initial
    s.input s.output t.output total
    (MemoryTransfer.relays_observation s t total trace).1

theorem relay_no_overflow_count (s t : MemoryTransfer.State size) (total : Nat)
    (trace : MemoryTransfer.Relays block s total t)
    (emptyOutput : s.output = [])
    (modulus : Nat) (positive : 0 < modulus)
    (noOverflow : CounterRefinement.newlineCount (s.input.take total) < modulus) :
    (CounterRefinement.run modulus positive ⟨0, positive⟩ t.output).val =
      CounterRefinement.newlineCount (s.input.take total) := by
  rw [relay_modular_count s t total trace modulus positive ⟨0, positive⟩]
  simpa [emptyOutput, CounterRefinement.newlineCount] using
    Nat.mod_eq_of_lt noOverflow

end MemoryCounterComposition

#print axioms MemoryCounterComposition.relay_modular_count
#print axioms MemoryCounterComposition.relay_no_overflow_count
