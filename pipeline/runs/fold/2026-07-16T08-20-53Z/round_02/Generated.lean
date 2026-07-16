namespace Pipeline.Generated

def takeN {α : Type} : Nat → List α → List α
  | 0, _ => []
  | Nat.succ _, [] => []
  | Nat.succ n, x :: xs => x :: takeN n xs

def dropN {α : Type} : Nat → List α → List α
  | 0, xs => xs
  | Nat.succ _, [] => []
  | Nat.succ n, _ :: xs => dropN n xs

def concatLists {α : Type} : List (List α) → List α
  | [] => []
  | x :: xs => x ++ concatLists xs

def flatMapList {α β : Type} (f : α → List β) : List α → List β
  | [] => []
  | x :: xs => f x ++ flatMapList f xs

def chunksFuel {α : Type} (w fuel : Nat) (xs : List α) : List (List α) :=
  match fuel with
  | 0 => []
  | Nat.succ fuel' =>
      match xs with
      | [] => []
      | _ :: _ => takeN w xs :: chunksFuel w fuel' (dropN w xs)

def foldChars {α : Type} (w : Nat) (xs : List α) : List (List α) :=
  match xs with
  | [] => [[]]
  | _ :: _ => chunksFuel w (Nat.succ xs.length) xs

def positiveNatFromString (s : String) : Nat :=
  match s.toNat? with
  | some n => if n = 0 then 1 else n
  | none => 1

def widthFromArgs (args : List String) : Nat :=
  match args with
  | "-w" :: w :: _ => positiveNatFromString w
  | _ => 80

def foldLine (w : Nat) (s : String) : List String :=
  (foldChars w s.toList).map String.ofList

def run (args stdin : List String) : List String × UInt32 :=
  (flatMapList (foldLine (widthFromArgs args)) stdin, (0 : UInt32))

theorem takeN_length_le {α : Type} (n : Nat) (xs : List α) :
    (takeN n xs).length ≤ n := by
  induction n generalizing xs with
  | zero =>
      change ([] : List α).length ≤ 0
      exact Nat.le_refl 0
  | succ n ih =>
      cases xs with
      | nil =>
          change ([] : List α).length ≤ Nat.succ n
          exact Nat.zero_le (Nat.succ n)
      | cons x xs =>
          change Nat.succ (takeN n xs).length ≤ Nat.succ n
          exact Nat.succ_le_succ (ih xs)

theorem dropN_length_le {α : Type} (n : Nat) (xs : List α) :
    (dropN n xs).length ≤ xs.length := by
  induction n generalizing xs with
  | zero =>
      change xs.length ≤ xs.length
      exact Nat.le_refl xs.length
  | succ n ih =>
      cases xs with
      | nil =>
          change ([] : List α).length ≤ ([] : List α).length
          exact Nat.le_refl 0
      | cons x xs =>
          change (dropN n xs).length ≤ Nat.succ xs.length
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
          change (dropN n xs).length < Nat.succ xs.length
          exact Nat.lt_succ_of_le (dropN_length_le n xs)

theorem takeN_append_dropN {α : Type} (n : Nat) (xs : List α) :
    takeN n xs ++ dropN n xs = xs := by
  induction n generalizing xs with
  | zero =>
      change ([] : List α) ++ xs = xs
      rfl
  | succ n ih =>
      cases xs with
      | nil =>
          change ([] : List α) ++ ([] : List α) = ([] : List α)
          rfl
      | cons x xs =>
          change x :: (takeN n xs ++ dropN n xs) = x :: xs
          rw [ih xs]

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
          cases h
      | cons x xs =>
          intro seg h
          simp [chunksFuel] at h
          cases h with
          | inl hhead =>
              subst seg
              exact takeN_length_le w (x :: xs)
          | inr htail =>
              exact ih (dropN w (x :: xs)) seg htail

theorem foldChars_segments_length_le {α : Type} (w : Nat) (xs : List α) :
    SegmentsBound w (foldChars w xs) := by
  cases xs with
  | nil =>
      intro seg h
      simp [SegmentsBound, foldChars] at h
      subst seg
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
          rfl
      | cons x xs =>
          have hdrop_lt : (dropN w (x :: xs)).length < (x :: xs).length :=
            dropN_length_lt w (x :: xs) hpos (by intro h; cases h)
          have hx_le_fuel : (x :: xs).length ≤ fuel := Nat.le_of_lt_succ hlen
          have hdrop_fuel : (dropN w (x :: xs)).length < fuel :=
            Nat.lt_of_lt_of_le hdrop_lt hx_le_fuel
          calc
            concatLists (chunksFuel w (Nat.succ fuel) (x :: xs))
                = takeN w (x :: xs) ++ concatLists (chunksFuel w fuel (dropN w (x :: xs))) := by rfl
            _ = takeN w (x :: xs) ++ dropN w (x :: xs) := by
                rw [ih (dropN w (x :: xs)) hdrop_fuel]
            _ = x :: xs := takeN_append_dropN w (x :: xs)

theorem foldChars_content_preserved {α : Type} (w : Nat) (xs : List α)
    (hpos : 0 < w) :
    concatLists (foldChars w xs) = xs := by
  cases xs with
  | nil =>
      rfl
  | cons x xs =>
      change concatLists (chunksFuel w (Nat.succ (x :: xs).length) (x :: xs)) = x :: xs
      exact chunksFuel_concat w (Nat.succ (x :: xs).length) (x :: xs) hpos
        (Nat.lt_succ_self (x :: xs).length)

theorem run_exit_zero (args stdin : List String) :
    (run args stdin).2 = (0 : UInt32) := by
  rfl

theorem run_stdout_is_folded_stdin (args stdin : List String) :
    (run args stdin).1 = flatMapList (foldLine (widthFromArgs args)) stdin := by
  rfl

end Pipeline.Generated
