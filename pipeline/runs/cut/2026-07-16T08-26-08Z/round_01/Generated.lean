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
      match parsePositiveNat (String.mk lo), parsePositiveNat (String.mk hi) with
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
            if allStdinOperands rest then parseRange (String.mk rangeChars) else none
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
  String.mk (selectedChars a b s)

def run (args stdin : List String) : List String × UInt32 :=
  match parseArgs args with
  | some (a, b) => (stdin.map (cutLine a b), (0 : UInt32))
  | none => ([], (1 : UInt32))

theorem length_takeN_le {α : Type} (n : Nat) (xs : List α) :
    (takeN n xs).length <= n := by
  induction n generalizing xs with
  | zero =>
      cases xs with
      | nil => rfl
      | cons x xs => rfl
  | succ n ih =>
      cases xs with
      | nil => simp [takeN]
      | cons x xs =>
          simp [takeN, ih xs]

theorem dropN_eq_nil_of_length_le {α : Type} (n : Nat) (xs : List α)
    (h : xs.length <= n) : dropN n xs = [] := by
  induction n generalizing xs with
  | zero =>
      cases xs with
      | nil => rfl
      | cons x xs => cases h
  | succ n ih =>
      cases xs with
      | nil => rfl
      | cons x xs =>
          simpa [dropN] using ih xs (Nat.le_of_succ_le_succ h)

theorem length_map_cutLine (a b : Nat) (xs : List String) :
    (xs.map (cutLine a b)).length = xs.length := by
  induction xs with
  | nil => rfl
  | cons x xs ih => simp [ih]

theorem selected_chars_are_closed_range (a b : Nat) (s : String) :
    selectedChars a b s = takeN (b - a + 1) (dropN (a - 1) s.toList) := by
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
  | succ n => rfl

theorem run_valid_stdout (args stdin : List String) (a b : Nat)
    (h : parseArgs args = some (a, b)) :
    (run args stdin).1 = stdin.map (cutLine a b) := by
  unfold run
  rw [h]
  rfl

theorem run_valid_exit (args stdin : List String) (a b : Nat)
    (h : parseArgs args = some (a, b)) :
    (run args stdin).2 = (0 : UInt32) := by
  unfold run
  rw [h]
  rfl

theorem run_valid_line_count (args stdin : List String) (a b : Nat)
    (h : parseArgs args = some (a, b)) :
    ((run args stdin).1).length = stdin.length := by
  unfold run
  rw [h]
  exact length_map_cutLine a b stdin

end Pipeline.Generated
