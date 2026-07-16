namespace Pipeline.Generated

def lineCount (stdin : List String) : Nat :=
  stdin.length

def renderCount (n : Nat) : String :=
  toString n

def run (args stdin : List String) : List String × UInt32 :=
  ([renderCount (lineCount stdin)], (0 : UInt32))

theorem run_output_shape (args stdin : List String) :
    (run args stdin).1.length = 1 := by
  rfl

theorem run_output_bound (args stdin : List String) :
    (run args stdin).1.length ≤ 1 := by
  simp [run]

theorem run_output_content (args stdin : List String) :
    (run args stdin).1 = [toString stdin.length] := by
  rfl

theorem run_exit_code (args stdin : List String) :
    (run args stdin).2 = (0 : UInt32) := by
  rfl

theorem run_idempotent_empty_append (args stdin : List String) :
    run args (stdin ++ []) = run args stdin := by
  simp [run, lineCount, renderCount]

end Pipeline.Generated