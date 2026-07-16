namespace Pipeline.Generated

def allSlashNonempty : List Char → Bool
  | [] => true
  | c :: cs => if c = '/' then allSlashNonempty cs else false

def allSlash : List Char → Bool
  | [] => false
  | c :: cs => allSlashNonempty (c :: cs)

def dropTrailingRev : List Char → List Char
  | [] => []
  | c :: cs => if c = '/' then dropTrailingRev cs else c :: cs

def trimTrailingSlashes (xs : List Char) : List Char :=
  (dropTrailingRev xs.reverse).reverse

def scanLastSlash : List Char → List Char → Option (List Char) → Option (List Char)
  | [], _, best => best
  | c :: cs, seen, best =>
      if c = '/' then
        scanLastSlash cs (seen ++ ['/']) (some (seen ++ ['/']))
      else
        scanLastSlash cs (seen ++ [c]) best

def dirnameChars (xs : List Char) : List Char :=
  if allSlash xs then
    ['/']
  else
    let trimmed := trimTrailingSlashes xs
    match scanLastSlash trimmed [] none with
    | none => ['.']
    | some pfx =>
        match pfx with
        | [] => ['/']
        | _ => if allSlash pfx then ['/'] else pfx

def dirname (s : String) : String :=
  String.mk (dirnameChars s.toList)

def run (args stdin : List String) : List String × UInt32 :=
  match args with
  | [s] => ([dirname s], 0)
  | _ => ([], 1)

theorem run_single_operand (s : String) (stdin : List String) :
    run [s] stdin = ([dirname s], 0) := by
  rfl

theorem output_has_one_line (s : String) (stdin : List String) :
    (run [s] stdin).1.length = 1 := by
  rfl

theorem output_length_bound (s : String) (stdin : List String) :
    (run [s] stdin).1.length ≤ 1 := by
  change 1 ≤ 1
  exact Nat.le_refl 1

theorem output_is_documented_parent (s : String) (stdin : List String) :
    (run [s] stdin).1 = [String.mk (dirnameChars s.toList)] := by
  rfl

theorem successful_exit_code (s : String) (stdin : List String) :
    (run [s] stdin).2 = 0 := by
  rfl

theorem stdin_is_ignored (s : String) (a b : List String) :
    run [s] a = run [s] b := by
  rfl

end Pipeline.Generated