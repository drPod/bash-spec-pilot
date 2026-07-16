namespace Pipeline.Generated

def digitVal? (c : Char) : Option Nat :=
  if c = '0' then some 0 else
  if c = '1' then some 1 else
  if c = '2' then some 2 else
  if c = '3' then some 3 else
  if c = '4' then some 4 else
  if c = '5' then some 5 else
  if c = '6' then some 6 else
  if c = '7' then some 7 else
  if c = '8' then some 8 else
  if c = '9' then some 9 else
  none

def parseNatAux : List Char -> Nat -> Option Nat
  | [], acc => some acc
  | c :: cs, acc =>
      match digitVal? c with
      | some d => parseNatAux cs (acc * 10 + d)
      | none => none

def parsePositiveNat (s : String) : Option Nat :=
  match parseNatAux s.toList 0 with
  | some n => if n = 0 then none else some n
  | none => none

def splitHyphenAux : List Char -> List Char -> Option (List Char × List Char)
  | _acc, [] => none
  | acc, c :: cs =>
      if c = '-' then
        some (acc.reverse, cs)
      else
        splitHyphenAux (c :: acc) cs

def parseRange (s : String) : Option (Nat × Nat) :=
  match splitHyphenAux [] s.toList with
  | some (lo, hi) =>
      match parsePositiveNat (String.ofList lo), parsePositiveNat (String.ofList hi) with
      | some a, some b => if a <= b then some (a, b) else none
      | _, _ => none
  | none => none

def allStdinOperands : List String -> Bool
  | [] => true
  | x :: xs =>
      if x = "-" then allStdinOperands xs else false

def parseArgs (args : List String) : Option (Nat × Nat) :=
  match args with
  | [] => none
  | flag :: rest =>
      if flag = "-c" then
        match rest with
        | r :: files => if allStdinOperands files then parseRange r else none
        | [] => none
      else
        match flag.toList with
        | '-' :: 'c' :: rangeChars =>
            if allStdinOperands rest then parseRange (String.ofList rangeChars) else none
        | _ => none

def takeN {α : Type} : Nat -> List α -> List α
  | 0, _ => []
  | Nat.succ _n, [] => []
  | Nat.succ n, x :: xs => x :: takeN n xs

def dropN {α : Type} : Nat -> List α -> List α
  | 0, xs => xs
  | Nat.succ _n, [] => []
  | Nat.succ n, _x :: xs => dropN n xs

def selectedChars (a b : Nat) (s : String) : List Char :=
  takeN (b - a + 1) (dropN (a - 1) s.toList)

def cutLine (a b : Nat) (s : String) : String :=
  String.ofList (selectedChars a b s)

def run (args stdin : List String) : List String × UInt32 :=
  match parseArgs args with
  | some (a, b) => (stdin.map (cutLine a b), (0 : UInt32))
  | none => ([], (1 : UInt32))

private theorem length_takeN_le {α : Type} (n : Nat) (xs : List α) :
    (takeN n xs).length <= n := by
  induction n generalizing xs with
  | zero =>
      cases xs with
      | nil => exact Nat.le_refl 0
      | cons _ _ => exact Nat.le_refl 0
  | succ n ih =>
      cases xs with
      | nil => exact Nat.zero_le (Nat.succ n)
      | cons _ xs =>
          change Nat.succ ((takeN n xs).length) <= Nat.succ n
          exact Nat.succ_le_succ (ih xs)

private theorem dropN_eq_nil_of_length_le {α : Type} (n : Nat) (xs : List α)
    (h : xs.length <= n) : dropN n xs = [] := by
  induction n generalizing xs with
  | zero =>
      cases xs with
      | nil => rfl
      | cons _ _ => cases h
  | succ n ih =>
      cases xs with
      | nil => rfl
      | cons _ xs =>
          simpa [dropN] using ih xs (Nat.le_of_succ_le_succ h)

private theorem length_map_cutLine (a b : Nat) (xs : List String) :
    (xs.map (cutLine a b)).length = xs.length := by
  induction xs with
  | nil => rfl
  | cons x xs ih =>
      change Nat.succ ((xs.map (cutLine a b)).length) = Nat.succ xs.length
      exact congrArg Nat.succ ih

theorem cutLine_is_closed_range (a b : Nat) (s : String) :
    cutLine a b s = String.ofList (takeN (b - a + 1) (dropN (a - 1) s.toList)) := by
  rfl

theorem selected_length_le_range_width (a b : Nat) (s : String) :
    (selectedChars a b s).length <= b - a + 1 := by
  unfold selectedChars
  exact length_takeN_le (b - a + 1) (dropN (a - 1) s.toList)

theorem selected_empty_when_short (a b : Nat) (s : String)
    (h : s.toList.length <= a - 1) :
    selectedChars a b s = [] := by
  unfold selectedChars
  rw [dropN_eq_nil_of_length_le (a - 1) s.toList h]
  cases (b - a + 1) with
  | zero => rfl
  | succ _ => rfl

theorem run_valid_stdout (args stdin : List String) (a b : Nat)
    (h : parseArgs args = some (a, b)) :
    (run args stdin).1 = stdin.map (cutLine a b) := by
  simp [run, h]

theorem run_valid_exit (args stdin : List String) (a b : Nat)
    (h : parseArgs args = some (a, b)) :
    (run args stdin).2 = (0 : UInt32) := by
  simp [run, h]

theorem run_valid_line_count (args stdin : List String) (a b : Nat)
    (h : parseArgs args = some (a, b)) :
    ((run args stdin).1).length = stdin.length := by
  simpa [run, h] using length_map_cutLine a b stdin

end Pipeline.Generated
