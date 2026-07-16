namespace Pipeline.Generated

def decimalCount (stdin : List String) : String :=
  toString stdin.length

def run (args stdin : List String) : List String × UInt32 :=
  ([decimalCount stdin], 0)

theorem run_stdout_eq_count (args stdin : List String) :
    (run args stdin).1 = [toString stdin.length] := by
  rfl

theorem run_exit_success (args stdin : List String) :
    (run args stdin).2 = 0 := by
  rfl

theorem run_stdout_has_one_line (args stdin : List String) :
    (run args stdin).1.length = 1 := by
  rfl

theorem run_independent_of_args (args₁ args₂ stdin : List String) :
    run args₁ stdin = run args₂ stdin := by
  rfl

theorem run_append_counts_all_input_lines (args xs ys : List String) :
    (run args (xs ++ ys)).1 = [toString (xs.length + ys.length)] := by
  simp [run, decimalCount]

end Pipeline.Generated
