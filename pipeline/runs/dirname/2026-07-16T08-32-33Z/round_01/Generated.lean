namespace Pipeline.Generated

def slash : Char := '/'

def hasSlashList : List Char → Bool
  | [] => false
  | c :: cs => if c = slash then true else hasSlashList cs

def rstripSlash : List Char → List Char
  | [] => []
  | c :: cs =>
      match rstripSlash cs with
      | [] => if c = slash then [] else [c]
      | d :: ds => c :: d :: ds

def rstripNonSlash : List Char → List Char
  | [] => []
  | c :: cs =>
      match rstripNonSlash cs with
      | [] => if c = slash then [c] else []
      | d :: ds => c :: d :: ds

def keepRoot (xs : List Char) : List Char :=
  match rstripSlash xs with
  | [] => [slash]
  | c :: cs => c :: cs

def dirnameChars (xs : List Char) : String :=
  match xs with
  | [] => "."
  | _ :: _ =>
      match rstripSlash xs with
      | [] => "/"
      | c :: cs =>
          match rstripNonSlash (c :: cs) with
          | [] => "."
          | d :: ds => String.mk (keepRoot (d :: ds))

def dirname (path : String) : String :=
  dirnameChars path.toList

def run (args stdin : List String) : List String × UInt32 :=
  match args with
  | [path] => ([dirname path], 0)
  | _ => ([], 1)

theorem hasSlashList_cons_false_left {c : Char} {cs : List Char}
    (h : hasSlashList (c :: cs) = false) : c ≠ slash := by
  unfold hasSlashList at h
  by_cases hc : c = slash
  · simp [hc] at h
  · exact hc

theorem hasSlashList_cons_false_tail {c : Char} {cs : List Char}
    (h : hasSlashList (c :: cs) = false) : hasSlashList cs = false := by
  unfold hasSlashList at h
  by_cases hc : c = slash
  · simp [hc] at h
  · simpa [hc] using h

theorem rstripSlash_no_slash :
    ∀ xs : List Char, hasSlashList xs = false → rstripSlash xs = xs
  | [], _ => rfl
  | c :: cs, h => by
      have hc : c ≠ slash := hasSlashList_cons_false_left h
      have ht : hasSlashList cs = false := hasSlashList_cons_false_tail h
      have ih : rstripSlash cs = cs := rstripSlash_no_slash cs ht
      unfold rstripSlash
      rw [ih]
      cases cs with
      | nil => simp [hc]
      | cons d ds => rfl

theorem rstripNonSlash_no_slash :
    ∀ xs : List Char, hasSlashList xs = false → rstripNonSlash xs = []
  | [], _ => rfl
  | c :: cs, h => by
      have hc : c ≠ slash := hasSlashList_cons_false_left h
      have ht : hasSlashList cs = false := hasSlashList_cons_false_tail h
      have ih : rstripNonSlash cs = [] := rstripNonSlash_no_slash cs ht
      unfold rstripNonSlash
      rw [ih]
      simp [hc]

theorem run_one_stdout_content (path : String) (stdin : List String) :
    (run [path] stdin).1 = [dirname path] := by
  rfl

theorem run_one_exit_success (path : String) (stdin : List String) :
    (run [path] stdin).2 = (0 : UInt32) := by
  rfl

theorem run_one_stdout_length (path : String) (stdin : List String) :
    (run [path] stdin).1.length = 1 := by
  rfl

theorem run_one_stdin_ignored (path : String) (stdin1 stdin2 : List String) :
    run [path] stdin1 = run [path] stdin2 := by
  rfl

theorem dirname_no_slash (path : String)
    (h : hasSlashList path.toList = false) : dirname path = "." := by
  unfold dirname
  cases hl : path.toList with
  | nil =>
      simp [dirnameChars, hl]
  | cons c cs =>
      have h' : hasSlashList (c :: cs) = false := by
        simpa [hl] using h
      have hrs : rstripSlash (c :: cs) = c :: cs :=
        rstripSlash_no_slash (c :: cs) h'
      have hrn : rstripNonSlash (c :: cs) = [] :=
        rstripNonSlash_no_slash (c :: cs) h'
      simp [dirnameChars, hl, hrs, hrn]

end Pipeline.Generated
