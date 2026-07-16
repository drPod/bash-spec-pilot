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
  simp [foldLine]

theorem run_cons_lines (args : List String) (line : String) (rest : List String) :
    (run args (line :: rest)).1 =
      foldLine (widthOf args) line ++ (run args rest).1 := by
  rfl

theorem run_single_line (args : List String) (line : String) :
    (run args [line]).1 = foldLine (widthOf args) line := by
  simp [run]

theorem chunkGo_length_bound (w : Nat) (xs : List Char) (n : Nat) :
    ∀ c, c ∈ chunkGo w xs n → c.length ≤ w := by
  induction n generalizing xs with
  | zero =>
      intro c hc
      simp [chunkGo] at hc
  | succ n ih =>
      intro c hc
      cases xs with
      | nil =>
          simp [chunkGo] at hc
      | cons a xs =>
          simp only [chunkGo] at hc
          rw [List.mem_append] at hc
          rcases hc with hc | hc
          · exact List.length_take_le
          · exact ih xs c hc

theorem segment_length_bound (w : Nat) (s : String) :
    ∀ t, t ∈ foldLine w s → t.toList.length ≤ w := by
  intro t ht
  by_cases h : s.toList = []
  · have he : t = "" := by
      simpa [foldLine, h] using ht
    subst t
    simp
  · simp only [foldLine, h] at ht
    rcases List.mem_map.mp ht with ⟨c, hc, rfl⟩
    simpa using (chunkGo_length_bound w s.toList (s.toList.length + 1) c (by
      by_cases hw : w = 0
      · simp [chunks, hw]
      · exact (by
          simp only [chunks, hw]
          exact hc)))

end Pipeline.Generated