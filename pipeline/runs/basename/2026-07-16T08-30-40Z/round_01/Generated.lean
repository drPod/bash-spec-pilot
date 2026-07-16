namespace Pipeline.Generated

def slash : Char := '/'

def allSlashes : List Char → Bool
  | [] => true
  | c :: cs => if c = slash then allSlashes cs else false

def dropLeadingSlashes : List Char → List Char
  | [] => []
  | c :: cs => if c = slash then dropLeadingSlashes cs else c :: cs

def dropTrailingSlashes (cs : List Char) : List Char :=
  (dropLeadingSlashes cs.reverse).reverse

def lastComponentAux : List Char → List Char → List Char
  | [], acc => acc
  | c :: cs, acc =>
      if c = slash then
        lastComponentAux cs []
      else
        lastComponentAux cs (acc ++ [c])

def lastComponent (cs : List Char) : List Char :=
  lastComponentAux cs []

def basenameChars : List Char → List Char
  | [] => []
  | cs =>
      if allSlashes cs then
        [slash]
      else
        lastComponent (dropTrailingSlashes cs)

def basename (s : String) : String :=
  String.mk (basenameChars s.toList)

def run (args stdin : List String) : List String × UInt32 :=
  match args with
  | [s] => ([basename s], (0 : UInt32))
  | _ => ([], (1 : UInt32))

theorem run_one_stdout_exact (s : String) (input : List String) :
    (run [s] input).1 = [basename s] := by
  rfl

theorem run_one_exit_success (s : String) (input : List String) :
    (run [s] input).2 = (0 : UInt32) := by
  rfl

theorem run_stdin_not_used (args input₁ input₂ : List String) :
    run args input₁ = run args input₂ := by
  cases args with
  | nil => rfl
  | cons a rest =>
      cases rest with
      | nil => rfl
      | cons b more => rfl

theorem basename_chars_empty_is_empty :
    basenameChars [] = [] := by
  rfl

theorem basename_chars_all_slashes_nonempty (c : Char) (cs : List Char)
    (h : allSlashes (c :: cs) = true) :
    basenameChars (c :: cs) = [slash] := by
  simp [basenameChars, h]

theorem basename_chars_nonempty_not_all (c : Char) (cs : List Char)
    (h : allSlashes (c :: cs) = false) :
    basenameChars (c :: cs) = lastComponent (dropTrailingSlashes (c :: cs)) := by
  simp [basenameChars, h]

end Pipeline.Generated
