/- Buildable placeholder; the checker overwrites it with each candidate. -/
namespace Pipeline.Generated

def run (_args _stdin : List String) : List String × UInt32 :=
  ([], 0)

theorem run_stub_no_output (a s : List String) : (run a s).1 = [] := rfl

end Pipeline.Generated
