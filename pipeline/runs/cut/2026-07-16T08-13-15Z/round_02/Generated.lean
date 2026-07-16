namespace Pipeline.Generated

def digitValue (c : Char) : Nat :=
  if 48 ≤ c.toNat ∧ c.toNat ≤ 57 then c.toNat - 48 else 0

def parseRangeAux : List Char → Nat → Nat → Bool → Nat × Nat
  | [], a, b, seen => (a, b)
  | c :: cs, a, b, seen =>
      if c = '-' then
        parseRangeAux cs a b true
      else if seen then
        parseRangeAux cs a (b * 10 + digitValue c) seen
      else
        parseRangeAux cs (a * 10 + digitValue c) b seen

def parseRange (s : String) : Nat × Nat :=
  parseRangeAux s.toList 0 0 false

def selectAux (a b i : Nat) : List Char → List Char
  | [] => []
  | c :: cs =>
      if a ≤ i ∧ i ≤ b then
        c :: selectAux a b (i + 1) cs
      else
        selectAux a b (i + 1) cs

def cutLine (a b : Nat) (s : String) : String :=
  String.ofList (selectAux a b 1 s.toList)

def cutSpec (spec : String) (s : String) : String :=
  let p := parseRange spec
  cutLine p.1 p.2 s

def run (args stdin : List String) : List String × UInt32 :=
  match args with
  | ["-c", spec] => (stdin.map (fun s => cutSpec spec s), 0)
  | _ => ([], 1)

theorem select_length_le (a b i : Nat) (xs : List Char) :
    (selectAux a b i xs).length ≤ xs.length := by
  induction xs generalizing i with
  | nil => simp [selectAux]
  | cons x xs ih =>
      by_cases h : a ≤ i ∧ i ≤ b
      · simpa [selectAux, h] using Nat.succ_le_succ (ih (i + 1))
      · simpa [selectAux, h] using
          Nat.le_trans (ih (i + 1)) (Nat.le_succ xs.length)

theorem select_mem (a b i : Nat) (xs : List Char) :
    ∀ {c : Char}, c ∈ selectAux a b i xs → c ∈ xs := by
  induction xs generalizing i with
  | nil =>
      intro c h
      simp [selectAux] at h
  | cons x xs ih =>
      intro c hmem
      by_cases h : a ≤ i ∧ i ≤ b
      · simp [selectAux, h] at hmem
        rcases hmem with hmem | hmem
        · simp [hmem]
        · have ht : c ∈ xs := ih (i + 1) hmem
          simp [ht]
      · simp [selectAux, h] at hmem
        have ht : c ∈ xs := ih (i + 1) hmem
        simp [ht]

theorem run_valid_shape (spec : String) (lines : List String) :
    run ["-c", spec] lines =
      (lines.map (fun s => cutSpec spec s), 0) := by
  rfl

theorem run_preserves_line_count (spec : String) (lines : List String) :
    (run ["-c", spec] lines).1.length = lines.length := by
  simp [run]

theorem cutSpec_length_bound (spec : String) (s : String) :
    (cutSpec spec s).toList.length ≤ s.toList.length := by
  unfold cutSpec
  simpa [cutLine] using
    (select_length_le (parseRange spec).1 (parseRange spec).2 1 s.toList)

theorem cutSpec_content_preserved (spec : String) (s : String) {c : Char} :
    c ∈ (cutSpec spec s).toList → c ∈ s.toList := by
  unfold cutSpec
  simpa [cutLine] using
    (select_mem (parseRange spec).1 (parseRange spec).2 1 s.toList)

theorem run_exit_code_on_valid_input (spec : String) (lines : List String) :
    (run ["-c", spec] lines).2 = 0 := by
  rfl

end Pipeline.Generated