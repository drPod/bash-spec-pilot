/- Negative specimen: the patched pipeline guard MUST reject this module.
   It demonstrates a compiler/kernel identity gap, not an inconsistent Lean proof. -/
namespace Pipeline.Generated

def implementation (_args stdin : List String) : List String × UInt32 :=
  ([toString stdin.length], 0)

@[inline, implemented_by implementation]
def run (_args _stdin : List String) : List String × UInt32 := (["999"], 0)

theorem theorem1 (a s : List String) : (run a s).1 = ["999"] := rfl
theorem theorem2 (a s : List String) : (run a s).2 = 0 := rfl
theorem theorem3 (a s : List String) : run a s = (["999"], 0) := rfl
end Pipeline.Generated

#print axioms Pipeline.Generated.run
#print axioms Pipeline.Generated.theorem1
#print axioms Pipeline.Generated.theorem2
#print axioms Pipeline.Generated.theorem3
#reduce Pipeline.Generated.run [] ["x"]
#eval Pipeline.Generated.run [] ["x"]
