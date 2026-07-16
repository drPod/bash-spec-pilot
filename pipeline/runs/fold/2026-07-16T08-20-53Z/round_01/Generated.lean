namespace Pipeline.Generated

/-- Take at most `n` elements from a list.  Defined here so the model and
proofs depend only on total structural recursion. -/
def takeN {α : Type} : Nat → List α → List α
  | 0, _ => []
  | Nat.succ n, [] => []
  | Nat.succ n, x :: xs => x :: takeN n xs

/-- Drop at most `n` elements from a list. -/
def dropN {α : Type} : Nat → List α → List α
  | 0, xs => xs
  | Nat.succ n, [] => []
  | Nat.succ n, _ :: xs => dropN n xs

/-- Concatenate a list of lists. -/
def concatLists {α : Type} : List (List α) → List α
  | [] => []
  | x :: xs => x ++ concatLists xs

/-- Repeatedly take chunks of width `w`, with a fuel argument for totality. -/
def chunksFuel {α : Type} (w fuel : Nat) (xs : List α) : List (List α) :=
  match fuel with
  | 0 => []
  | Nat.succ fuel' =>
      match xs with
      | [] => []
      | _ :: _ => takeN w xs :: chunksFuel w fuel' (dropN w xs)

/-- Fold one line represented as characters.  An empty input line produces one
empty output line, matching the line-level stdin/stdout convention. -/
def foldChars {α : Type} (w : Nat) (xs : List α) : List (List α) :=
  match xs with
  | [] => [[]]
  | _ :: _ => chunksFuel w (Nat.succ xs.length) xs

/-- Parse the scoped `-w WIDTH` argument; invalid or zero widths are mapped to
1 only to keep `run` total outside the modeled valid-input scope. -/
def positiveNatFromString (s : String) : Nat :=
  match s.toNat? with
  | some n => if n = 0 then 1 else n
  | none => 1

/-- Width selection for the modeled invocation form. -/
def widthFromArgs (args : List String) : Nat :=
  match args with
  | "-w" :: w :: _ => positiveNatFromString w
  | _ => 80

/-- Fold one line of stdin, counting plain Lean characters. -/
def foldLine (w : Nat) (s : String) : List String :=
  (foldChars w s.toList).map String.mk

/-- Model of the scoped `fold -w WIDTH` behavior: read stdin lines, split each
line into maximal fixed-width chunks, write the resulting lines, and succeed. -/
def run (args stdin : List String) : List String × UInt32 :=
  (stdin.bind (foldLine (widthFromArgs args)), (0 : UInt32))

 theorem takeN_length_le {α : Type} (n : Nat) (xs : List α) :
    (takeN n xs).length ≤ n := by
  induction n generalizing xs with
  | zero =>
      simp [takeN]
  | succ n ih =>
      cases xs with
      | nil =>
          simp [takeN]
      | cons x xs =>
          simp [takeN]
          exact Nat.succ_le_succ (ih xs)

 theorem dropN_length_le {α : Type} (n : Nat) (xs : List α) :
    (dropN n xs).length ≤ xs.length := by
  induction n generalizing xs with
  | zero =>
      simp [dropN]
  | succ n ih =>
      cases xs with
      | nil =>
          simp [dropN]
      | cons x xs =>
          simp [dropN]
          exact Nat.le_trans (ih xs) (Nat.le_succ xs.length)

 theorem dropN_length_lt {α : Type} (n : Nat) (xs : List α)
    (hpos : 0 < n) (hne : xs ≠ []) :
    (dropN n xs).length < xs.length := by
  cases n with
  | zero =>
      exact False.elim ((Nat.not_lt_zero 0) hpos)
  | succ n =>
      cases xs with
      | nil =>
          exact False.elim (hne rfl)
      | cons x xs =>
          simp [dropN]
          exact Nat.lt_succ_of_le (dropN_length_le n xs)

 theorem takeN_append_dropN {α : Type} (n : Nat) (xs : List α) :
    takeN n xs ++ dropN n xs = xs := by
  induction n generalizing xs with
  | zero =>
      simp [takeN, dropN]
  | succ n ih =>
      cases xs with
      | nil =>
          simp [takeN, dropN]
      | cons x xs =>
          simp [takeN, dropN, ih xs]

/-- Predicate saying every output segment has length at most `w`. -/
def SegmentsBound {α : Type} (w : Nat) (segs : List (List α)) : Prop :=
  ∀ seg, seg ∈ segs → seg.length ≤ w

 theorem chunksFuel_segments_length_le {α : Type} (w fuel : Nat) (xs : List α) :
    SegmentsBound w (chunksFuel w fuel xs) := by
  induction fuel generalizing xs with
  | zero =>
      intro seg h
      cases h
  | succ fuel ih =>
      cases xs with
      | nil =>
          intro seg h
          simp [chunksFuel] at h
      | cons x xs =>
          intro seg h
          simp [chunksFuel] at h
          cases h with
          | inl hhead =>
              cases hhead
              exact takeN_length_le w (x :: xs)
          | inr htail =>
              exact ih (dropN w (x :: xs)) seg htail

/-- SPEC: Every segment produced from a line has at most the requested width. -/
theorem foldChars_segments_length_le {α : Type} (w : Nat) (xs : List α) :
    SegmentsBound w (foldChars w xs) := by
  cases xs with
  | nil =>
      intro seg h
      simp [foldChars] at h
      cases h
      exact Nat.zero_le w
  | cons x xs =>
      change SegmentsBound w (chunksFuel w (Nat.succ (x :: xs).length) (x :: xs))
      exact chunksFuel_segments_length_le w (Nat.succ (x :: xs).length) (x :: xs)

 theorem chunksFuel_concat {α : Type} (w fuel : Nat) (xs : List α)
    (hpos : 0 < w) (hlen : xs.length < fuel) :
    concatLists (chunksFuel w fuel xs) = xs := by
  induction fuel generalizing xs with
  | zero =>
      exact False.elim ((Nat.not_lt_zero xs.length) hlen)
  | succ fuel ih =>
      cases xs with
      | nil =>
          simp [chunksFuel, concatLists]
      | cons x xs =>
          simp [chunksFuel, concatLists]
          have hdrop_lt : (dropN w (x :: xs)).length < (x :: xs).length :=
            dropN_length_lt w (x :: xs) hpos (by intro h; cases h)
          have hx_le_fuel : (x :: xs).length ≤ fuel := Nat.le_of_lt_succ hlen
          have hdrop_fuel : (dropN w (x :: xs)).length < fuel :=
            Nat.lt_of_lt_of_le hdrop_lt hx_le_fuel
          rw [ih (dropN w (x :: xs)) hdrop_fuel]
          exact takeN_append_dropN w (x :: xs)

/-- SPEC: For positive widths, folding preserves the characters of each input
line in order; only line breaks are inserted. -/
theorem foldChars_content_preserved {α : Type} (w : Nat) (xs : List α)
    (hpos : 0 < w) :
    concatLists (foldChars w xs) = xs := by
  cases xs with
  | nil =>
      simp [foldChars, concatLists]
  | cons x xs =>
      change concatLists (chunksFuel w (Nat.succ (x :: xs).length) (x :: xs)) = x :: xs
      exact chunksFuel_concat w (Nat.succ (x :: xs).length) (x :: xs) hpos
        (Nat.lt_succ_self (x :: xs).length)

/-- SPEC: Standard input lines are processed successfully in the modeled scope. -/
theorem run_exit_zero (args stdin : List String) :
    (run args stdin).2 = (0 : UInt32) := by
  rfl

/-- SPEC: The stdout of `run` is exactly the concatenation of the folded
segments of each stdin line, using the selected width. -/
theorem run_stdout_is_folded_stdin (args stdin : List String) :
    (run args stdin).1 = stdin.bind (foldLine (widthFromArgs args)) := by
  rfl

end Pipeline.Generated
