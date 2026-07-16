namespace Pipeline.Generated

def dropSlashes : List Char → List Char
  | [] => []
  | c :: cs => if c == '/' then dropSlashes cs else c :: cs

def allSlashes : List Char → Bool
  | [] => true
  | c :: cs => if c == '/' then allSlashes cs else false

def trimTrailingSlashes (xs : List Char) : List Char :=
  (dropSlashes xs.reverse).reverse

def lastComponent : List Char → List Char → List Char
  | [], acc => acc
  | c :: cs, acc => if c == '/' then lastComponent cs [] else lastComponent cs (acc ++ [c])

def basename (s : String) : String :=
  match s.toList with
  | [] => String.ofList ['.']
  | cs =>
      if allSlashes cs then
        String.ofList ['/']
      else
        String.ofList (lastComponent (trimTrailingSlashes cs) [])

def run (args stdin : List String) : List String × UInt32 :=
  match args with
  | [x] => ([basename x], 0)
  | _ => ([], 1)

 theorem run_one_output (x : String) (stdin : List String) :
    (run [x] stdin).1 = [basename x] := by
  rfl

 theorem run_one_output_length (x : String) (stdin : List String) :
    (run [x] stdin).1.length = 1 := by
  simp [run]

 theorem run_one_exit_success (x : String) (stdin : List String) :
    (run [x] stdin).2 = 0 := by
  rfl

 theorem run_one_stdin_ignored (x : String) (s₁ s₂ : List String) :
    run [x] s₁ = run [x] s₂ := by
  rfl

 theorem output_length_bound (args stdin : List String) :
    (run args stdin).1.length ≤ 1 := by
  cases args with
  | nil => simp [run]
  | cons a rest =>
      cases rest with
      | nil => simp [run]
      | cons b rest => simp [run]

end Pipeline.Generated