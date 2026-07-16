namespace Pipeline.Generated

def digitValue (c : Char) : Nat :=
  if c.val.toNat < 48 then 0 else c.val.toNat - 48

def decimalAux : Nat → List Char → Nat
  | n, [] => n
  | n, c :: cs => decimalAux (n * 10 + digitValue c) cs

def decimal (s : String) : Nat :=
  decimalAux 0 s.toList

def widthOf : List String → Nat
  | ["-w", s] => decimal s
  | _ => 80

def chunkGo (w : Nat) : List Char → Nat → List (List Char)
  | _, 0 => []
  | xs, n + 1 =>
      match xs with
      | [] => []
      | _ => xs.take w :: chunkGo w (xs.drop w) n

def chunks (w : Nat) (xs : List Char) : List (List Char) :=
  if w = 0 then [] else chunkGo w xs (xs.length + 1)

def foldLine (w : Nat) (s : String) : List String :=
  if s.toList = [] then [""] else
    (chunks w s.toList).map String.ofList

def run (args stdin : List String) : List String × UInt32 :=
  (stdin.flatMap (foldLine (widthOf args)), 0)

theorem run_output_shape (args stdin : List String) :
    (run args stdin).1 = stdin.flatMap (foldLine (widthOf args)) := by
  rfl

theorem run_exit_code (args stdin : List String) :
    (run args stdin).2 = 0 := by
  rfl

theorem foldLine_empty (w : Nat) :
    foldLine w "" = [""] := by
  simp [foldLine, chunks]

theorem run_cons_lines (args : List String) (line : String) (rest : List String) :
    (run args (line :: rest)).1 =
      foldLine (widthOf args) line ++ (run args rest).1 := by
  rfl

theorem run_single_line (args : List String) (line : String) :
    (run args [line]).1 = foldLine (widthOf args) line := by
  rfl

theorem width_option_is_used (s : String) :
    widthOf ["-w", s] = decimal s := by
  rfl

end Pipeline.Generated