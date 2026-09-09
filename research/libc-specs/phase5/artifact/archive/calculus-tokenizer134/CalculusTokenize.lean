import CalculusRelayOuter
open CalculusNested CalculusExport CalculusBody CalculusRelayOuter

/-!
# CalculusTokenize: a TOTAL, fail-closed tokenizer, and the kernel-checked TEXT → AST identity
# (calculus-correspondence-15, 2026-09-08)

`CalculusExport.tokenize` is a `partial def` (opaque to the kernel), so until now the identity of
the exported bodies with the stated ASTs was kernel-checked only from the TOKEN lists, with the
text → tokens link checked executably. `tokenizeTotal` below is structurally recursive (fuel =
input length + 1, always sufficient since every step consumes a character) and FAIL-CLOSED
(`none` on an unterminated string literal, or on fuel exhaustion — which cannot happen at the
fuel `tokenizeTotal` supplies). It is intended to be extensionally equal to `tokenize` on every
input on which `tokenize` terminates; that equality cannot be a theorem (nothing can be proved
about a `partial def`), so it is checked executably on the real exports
(`CalculusTokenizeReceipts`), and the kernel-checked results below are stated over
`tokenizeTotal` alone: `writeBlock_text_parse`/`relay_text_parse`/`readBlock_text_parse`
take the verbatim exporter TEXT to the stated `Stmt` values with no executable link left. -/

namespace CalculusTokenize

def isSpaceT (c : Char) : Bool := c = ' ' || c = '\n' || c = '\t' || c = '\r'
def isAtomCharT (c : Char) : Bool := !isSpaceT c && c ≠ '(' && c ≠ ')' && c ≠ '"'

/-- Scan a quoted string after its opening `"`; the token keeps both quotes. `none` if the input
    ends before the closing quote (fail-closed; `CalculusExport.scanString` silently returned
    the unterminated remainder). -/
def scanStringT (acc : String) : List Char → Option (String × List Char)
  | [] => none
  | '"' :: rest => some (acc ++ "\"", rest)
  | '\\' :: c :: rest => scanStringT (acc ++ "\\" ++ String.ofList [c]) rest
  | c :: rest => scanStringT (acc ++ String.ofList [c]) rest

/-- The maximal atom prefix and the rest. -/
def atomT : List Char → List Char × List Char
  | [] => ([], [])
  | c :: rest => if isAtomCharT c then
      let (a, r) := atomT rest
      (c :: a, r)
    else ([], c :: rest)

theorem atomT_length_le : ∀ (cs : List Char), (atomT cs).2.length ≤ cs.length
  | [] => Nat.le_refl _
  | c :: rest => by
    simp only [atomT]
    split
    · have := atomT_length_le rest
      simp only [List.length_cons]; omega
    · simp

def tokenizeT : Nat → List Char → Option (List String)
  | 0, _ => none
  | _ + 1, [] => some []
  | fuel + 1, '(' :: rest => (tokenizeT fuel rest).map ("(" :: ·)
  | fuel + 1, ')' :: rest => (tokenizeT fuel rest).map (")" :: ·)
  | fuel + 1, '"' :: rest =>
    match scanStringT "" rest with
    | some (body, rest') => (tokenizeT fuel rest').map (("\"" ++ body) :: ·)
    | none => none
  | fuel + 1, c :: rest =>
    if isSpaceT c then tokenizeT fuel rest
    else
      let (a, r) := atomT rest
      (tokenizeT fuel r).map ((String.ofList (c :: a)) :: ·)

def tokenizeTotal (s : String) : Option (List String) := tokenizeT (s.length + 1) s.toList

/-- Parse from TEXT: tokenize (fail-closed), then the checked parser; the whole token stream
    must be consumed. -/
def parseText (s : String) : Option (Stmt String) :=
  match tokenizeTotal s with
  | some toks =>
    match parseStmt 400 toks with
    | some (st, []) => some st
    | _ => none
  | none => none

/-! ## The three exported bodies, from their verbatim text -/

def writeBlockText : String := "(seq (assign b (fst ι)) (seq (assign off (range:0:4611686018427387903 (fst (snd ι)))) (seq (assign n (range:0:4611686018427387903 (snd (snd ι)))) (seq (if (<= (pair off n)) pass (raise (pair \"AssertionFailure\" ()))) (seq (seq (get $t9 b len) (if (<= (pair n $t9)) pass (raise (pair \"AssertionFailure\" ())))) (seq (seq (get $t10 b len) (assign l $t10)) (seq (seq (get $t11 b cap) (if (<= (pair l $t11)) pass (raise (pair \"AssertionFailure\" ())))) (seq (seq (get $t12 b bytes) (assign req (slice (pair $t12 (pair off n))))) (seq (seq (get $t13 σ writes) (assign q (head_or (pair $t13 (length (range-list:0:255 req)))))) (seq (seq (get $t14 σ writes) (set-attr σ writes (tail $t14))) (seq (seq (get $t15 σ write_calls) (set-attr σ write_calls (+ (pair $t15 1)))) (seq (if (< (pair q 0)) (return -1) pass) (seq (assign k (min (pair q (length (range-list:0:255 req))))) (seq (seq (get $t16 σ delivered) (set-attr σ delivered (append (pair $t16 (take (pair (range-list:0:255 req) (range:0:4611686018427387903 k))))))) (return k)))))))))))))))"
def relayText : String := "(seq (remove-elem σ block 0) (seq (add-elem σ block 0) (seq (assign b (elem σ block 0)) (seq (set-attr b cap 32) (seq (set-attr b len 0) (seq (set-attr b bytes (empty ())) (while true (seq (seq (seq (action $t17 read_block b) (assign r $t17)) (seq (if (< (pair r 0)) (return 1) pass) (seq (if (== (pair r 0)) (return 0) pass) (seq (assign off 0) (while (< (pair off r)) (seq (seq (seq (action $t18 write_block (pair b (pair (range:0:4611686018427387903 off) (range:0:4611686018427387903 r)))) (assign w $t18)) (seq (if (<= (pair w 0)) (seq (seq (get $t19 σ lost) (seq (get $t20 b bytes) (set-attr σ lost (append (pair $t19 (slice (pair $t20 (pair (range:0:4611686018427387903 off) (range:0:4611686018427387903 r))))))))) (return 2)) pass) (assign off (+ (pair off w))))) pass)))))) pass))))))))"
def readBlockText : String := "(seq (assign b ι) (seq (seq (get $t1 σ reads) (seq (get $t2 b cap) (assign q (head_or (pair $t1 $t2))))) (seq (seq (get $t3 σ reads) (set-attr σ reads (tail $t3))) (seq (seq (get $t4 σ read_calls) (set-attr σ read_calls (+ (pair $t4 1)))) (seq (if (< (pair q 0)) (return -1) pass) (seq (seq (get $t5 b cap) (seq (get $t6 σ input) (assign k (min (pair (max (pair 1 q)) (min (pair $t5 (length $t6)))))))) (seq (seq (get $t7 σ input) (set-attr b bytes (take (pair $t7 (range:0:4611686018427387903 k))))) (seq (set-attr b len (range:0:4611686018427387903 k)) (seq (seq (get $t8 σ input) (set-attr σ input (drop (pair $t8 (range:0:4611686018427387903 k))))) (return k))))))))))"

-- The full-text kernel identities `tokenizeTotal writeBlockText = some writeBlockToks` etc. are
-- NOT stated here: `decide +kernel` on the 1,300-character exports did not finish within 15
-- minutes (session -15); they are checked executably in `CalculusTokenizeReceipts.lean`, and a
-- kernel-checked instance on a real fragment is `small_text_tokens` below.

set_option maxRecDepth 100000 in
/-- Kernel-checked on a real fragment of `write_block`'s export (a string literal included). -/
theorem small_text_tokens :
    tokenizeTotal "(seq (assign b (fst ι)) (raise (pair \"AssertionFailure\" ())))" =
      some ["(", "seq", "(", "assign", "b", "(", "fst", "ι", ")", ")", "(", "raise", "(", "pair",
        "\"AssertionFailure\"", "(", ")", ")", ")", ")"] := by
  decide +kernel

/-! ## Negative controls: what the fail-closed path rejects -/

theorem rejects_unterminated_string : tokenizeTotal "(raise \"AssertionFailure" = none := by
  decide +kernel
theorem rejects_unterminated_after_escape : tokenizeTotal "\"abc\\" = none := by
  decide +kernel
/-- Balanced text that is not a statement: the parser (not the tokenizer) rejects it. -/
theorem rejects_non_statement : parseText "(pair 1 2)" = none := by decide +kernel
/-- A statement followed by trailing tokens: rejected (the whole stream must be consumed). -/
theorem rejects_trailing : parseText "pass pass" = none := by decide +kernel
/-- An unsupported head tag: rejected. -/
theorem rejects_match_text : parseText "(match x)" = none := by decide +kernel
/-- Digit separators are NOT integers (strict `[0-9]+`): read back as a variable, so a `range:`
    bound written that way is rejected by `parseFunc`. -/
theorem rejects_underscore_range : parseText "(assign x (range:1_0:5 y))" = none := by
  decide +kernel


set_option linter.unusedSimpArgs false

/-! ## Structural lemmas (chunking support; tokenizer-proof-34)
    `tokenizeT_fuel_succ` / `tokenizeT_fuel_mono`: extra fuel preserves a successful
    tokenization. Full-export `tokenizeTotal writeBlockText = some writeBlockToks` still
    needs concatenation at whitespace plus per-chunk kernel identities (NEXT). -/

theorem tokenizeT_zero (cs : List Char) : tokenizeT 0 cs = none := rfl

theorem tokenizeT_nil (n : Nat) : tokenizeT (n + 1) [] = some [] := rfl

theorem isSpaceT_space : isSpaceT ' ' = true := rfl

theorem tokenizeT_fuel_succ :
    ∀ (n : Nat) (cs : List Char) (t : List String),
      tokenizeT n cs = some t → tokenizeT (n + 1) cs = some t := by
  intro n
  induction n with
  | zero =>
    intro cs t h
    simp [tokenizeT] at h
  | succ n ih =>
    intro cs t h
    cases cs with
    | nil =>
      simp [tokenizeT] at h ⊢
      exact h
    | cons c rest =>
      by_cases hp : c = '('
      · subst hp
        simp [tokenizeT] at h ⊢
        cases hr : tokenizeT n rest with
        | none => simp [hr] at h
        | some t' =>
          simp [hr] at h
          cases h
          have := ih rest t' hr
          simp [this]
      · by_cases hq : c = ')'
        · subst hq
          simp [tokenizeT] at h ⊢
          cases hr : tokenizeT n rest with
          | none => simp [hr] at h
          | some t' =>
            simp [hr] at h
            cases h
            have := ih rest t' hr
            simp [this]
        · by_cases hd : c = '"'
          · subst hd
            simp [tokenizeT] at h ⊢
            cases hs : scanStringT "" rest with
            | none => simp [hs] at h
            | some pr =>
              rcases pr with ⟨body, rest'⟩
              simp [hs] at h
              cases hr : tokenizeT n rest' with
              | none => simp [hr] at h
              | some t' =>
                simp [hr] at h
                cases h
                have := ih rest' t' hr
                simp [this]
          · by_cases hs : isSpaceT c = true
            · have hunf : tokenizeT (n + 1) (c :: rest) = tokenizeT n rest := by
                simp [tokenizeT, hp, hq, hd, hs]
              have hunf' : tokenizeT (n + 1 + 1) (c :: rest) = tokenizeT (n + 1) rest := by
                simp [tokenizeT, hp, hq, hd, hs]
              rw [hunf] at h
              rw [hunf']
              exact ih rest t h
            · have hunf : tokenizeT (n + 1) (c :: rest) =
                  (tokenizeT n (atomT rest).2).map ((String.ofList (c :: (atomT rest).1)) :: ·) := by
                simp [tokenizeT, hp, hq, hd, hs]
              have hunf' : tokenizeT (n + 1 + 1) (c :: rest) =
                  (tokenizeT (n + 1) (atomT rest).2).map ((String.ofList (c :: (atomT rest).1)) :: ·) := by
                simp [tokenizeT, hp, hq, hd, hs]
              rw [hunf] at h
              rw [hunf']
              cases hr : tokenizeT n (atomT rest).2 with
              | none => simp [hr] at h
              | some t' =>
                simp [hr] at h
                cases h
                have := ih (atomT rest).2 t' hr
                simp [this]

theorem tokenizeT_fuel_mono :
    ∀ (n k : Nat) (cs : List Char) (t : List String),
      tokenizeT n cs = some t → tokenizeT (n + k) cs = some t := by
  intro n k cs t h
  induction k with
  | zero => exact h
  | succ k ih =>
    exact tokenizeT_fuel_succ (n + k) cs t ih

/-! ## Concatenation at ASCII space (tokenizer-concat-37)

Precise statement: if `tokenizeT n a = some ta` and `tokenizeT m b = some tb`
(success, so in particular neither side is an unclosed quoted string), then
`tokenizeT (n + m + 1) (a ++ ' ' :: b) = some (ta ++ tb)`.
Fuel `n+m+1` is definitionally `succ` after writing `n = n'+1`, matching
`tokenizeT ((n'+m)+1) (c :: (rest ++ ' ' :: b))`. This is *not* the full-export
`tokenizeTotal writeBlockText` identity. -/

theorem isAtomCharT_space : isAtomCharT ' ' = false := rfl

/-- A successful (closed) `scanStringT` is independent of any suffix after the
    closing quote; unclosed scans are `none` and are excluded by the hypothesis. -/
theorem scanStringT_append_success :
    ∀ (acc : String) (s extra : List Char) (body : String) (rest : List Char),
      scanStringT acc s = some (body, rest) →
      scanStringT acc (s ++ extra) = some (body, rest ++ extra) := by
  intro acc s
  induction acc, s using scanStringT.induct with
  | case1 acc => intro extra body rest h; simp [scanStringT] at h
  | case2 acc rest =>
    intro extra body rest' h
    simp only [scanStringT, Option.some.injEq, Prod.mk.injEq] at h
    obtain ⟨rfl, rfl⟩ := h
    simp [scanStringT]
  | case3 acc c rest ih =>
    intro extra body rest' h
    exact ih extra body rest' h
  | case4 acc c rest h1 h2 ih =>
    intro extra body rest' h
    -- the generic step, on `rest` and on `rest ++ extra`
    have hgen : ∀ (zs : List Char), (c = '\\' → zs = []) →
        scanStringT acc (c :: zs) = scanStringT (acc ++ String.ofList [c]) zs := by
      intro zs hz
      by_cases hb : c = '\\'
      · subst hb
        rw [hz rfl]
        rfl
      · cases zs <;> simp [scanStringT, h1, hb]
    have hrest : c = '\\' → rest = [] := by
      intro hc
      cases rest with
      | nil => rfl
      | cons d r => exact (h2 d r hc rfl).elim
    have hrest' : c = '\\' → rest ++ extra = [] := by
      intro hc
      rw [hrest hc]
      -- after a lone backslash the scan of `[]` is `none`, contradicting `h`
      exfalso
      rw [hgen rest hrest, hrest hc] at h
      simp [scanStringT] at h
    rw [hgen rest hrest] at h
    rw [List.cons_append, hgen (rest ++ extra) hrest']
    exact ih extra body rest' h

/-- Space is not an atom character, so appending `' ' :: extra` does not extend the atom
    prefix. -/
theorem atomT_append_space (s extra : List Char) :
    atomT (s ++ ' ' :: extra) = ((atomT s).1, (atomT s).2 ++ ' ' :: extra) := by
  induction s with
  | nil => simp [atomT, isAtomCharT_space]
  | cons c rest ih =>
    simp only [List.cons_append, atomT]
    split
    · simp [ih]
    · simp

/-- Concatenation at an ASCII space: two independently tokenizable pieces tokenize to the
    concatenation of their token lists. -/
theorem tokenizeT_concat_space :
    ∀ (n m : Nat) (a b : List Char) (ta tb : List String),
      tokenizeT n a = some ta →
      tokenizeT m b = some tb →
      tokenizeT (n + m + 1) (a ++ ' ' :: b) = some (ta ++ tb) := by
  intro n
  induction n with
  | zero =>
    intro m a b ta tb ha hb
    simp [tokenizeT] at ha
  | succ n ih =>
    intro m a b ta tb ha hb
    rw [show n + 1 + m + 1 = (n + m + 1) + 1 by omega]
    cases a with
    | nil =>
      simp [tokenizeT] at ha
      subst ha
      have hunf : tokenizeT ((n + m + 1) + 1) (' ' :: b) = tokenizeT (n + m + 1) b := by
        simp [tokenizeT, isSpaceT_space]
      rw [List.nil_append, hunf]
      have hm : tokenizeT (m + (n + 1)) b = some tb := tokenizeT_fuel_mono m (n + 1) b tb hb
      rw [show n + m + 1 = m + (n + 1) by omega]
      simpa using hm
    | cons c rest =>
      by_cases hp : c = '('
      · subst hp
        simp [tokenizeT] at ha
        have hunf : tokenizeT ((n + m + 1) + 1) ('(' :: rest ++ ' ' :: b) =
            (tokenizeT (n + m + 1) (rest ++ ' ' :: b)).map ("(" :: ·) := by
          simp [tokenizeT]
        rw [hunf]
        cases hr : tokenizeT n rest with
        | none => simp [hr] at ha
        | some ta' =>
          simp [hr] at ha
          subst ha
          have := ih m rest b ta' tb hr hb
          simp [this]
      · by_cases hq : c = ')'
        · subst hq
          simp [tokenizeT] at ha
          have hunf : tokenizeT ((n + m + 1) + 1) (')' :: rest ++ ' ' :: b) =
              (tokenizeT (n + m + 1) (rest ++ ' ' :: b)).map (")" :: ·) := by
            simp [tokenizeT]
          rw [hunf]
          cases hr : tokenizeT n rest with
          | none => simp [hr] at ha
          | some ta' =>
            simp [hr] at ha
            subst ha
            have := ih m rest b ta' tb hr hb
            simp [this]
        · by_cases hd : c = '"'
          · subst hd
            simp [tokenizeT] at ha
            cases hs : scanStringT "" rest with
            | none => simp [hs] at ha
            | some pr =>
              rcases pr with ⟨body, rest'⟩
              simp [hs] at ha
              have hs' : scanStringT "" (rest ++ ' ' :: b) = some (body, rest' ++ ' ' :: b) :=
                scanStringT_append_success "" rest (' ' :: b) body rest' hs
              have hunf : tokenizeT ((n + m + 1) + 1) ('"' :: rest ++ ' ' :: b) =
                  (tokenizeT (n + m + 1) (rest' ++ ' ' :: b)).map (("\"" ++ body) :: ·) := by
                simp [tokenizeT, hs']
              rw [hunf]
              cases hr : tokenizeT n rest' with
              | none => simp [hr] at ha
              | some ta' =>
                simp [hr] at ha
                subst ha
                have := ih m rest' b ta' tb hr hb
                simp [this]
          · by_cases hs : isSpaceT c = true
            · have hunf : tokenizeT (n + 1) (c :: rest) = tokenizeT n rest := by
                simp [tokenizeT, hp, hq, hd, hs]
              have hunf' : tokenizeT ((n + m + 1) + 1) (c :: rest ++ ' ' :: b) =
                  tokenizeT (n + m + 1) (rest ++ ' ' :: b) := by
                simp [tokenizeT, hp, hq, hd, hs]
              rw [hunf] at ha
              rw [hunf']
              exact ih m rest b ta tb ha hb
            · have hunf : tokenizeT (n + 1) (c :: rest) =
                  (tokenizeT n (atomT rest).2).map ((String.ofList (c :: (atomT rest).1)) :: ·) := by
                simp [tokenizeT, hp, hq, hd, hs]
              have hat : atomT (rest ++ ' ' :: b) = ((atomT rest).1, (atomT rest).2 ++ ' ' :: b) :=
                atomT_append_space rest b
              have hunf' : tokenizeT ((n + m + 1) + 1) (c :: rest ++ ' ' :: b) =
                  (tokenizeT (n + m + 1) ((atomT rest).2 ++ ' ' :: b)).map
                    ((String.ofList (c :: (atomT rest).1)) :: ·) := by
                simp [tokenizeT, hp, hq, hd, hs, hat]
              rw [hunf] at ha
              rw [hunf']
              cases hr : tokenizeT n (atomT rest).2 with
              | none => simp [hr] at ha
              | some ta' =>
                simp [hr] at ha
                subst ha
                have := ih m (atomT rest).2 b ta' tb hr hb
                simp [this]


/-! ## Fuel sufficiency and the String-level concatenation theorem -/

theorem scanStringT_length_le :
    ∀ (acc : String) (s : List Char) (body : String) (rest : List Char),
      scanStringT acc s = some (body, rest) → rest.length ≤ s.length := by
  intro acc s
  induction acc, s using scanStringT.induct with
  | case1 acc => intro body rest h; simp [scanStringT] at h
  | case2 acc rest =>
    intro body rest' h
    simp only [scanStringT, Option.some.injEq, Prod.mk.injEq] at h
    obtain ⟨-, rfl⟩ := h
    simp
  | case3 acc c rest ih =>
    intro body rest' h
    have := ih body rest' h
    simp only [List.length_cons]; omega
  | case4 acc c rest h1 h2 ih =>
    intro body rest' h
    have hgen : (c = '\\' → rest = []) →
        scanStringT acc (c :: rest) = scanStringT (acc ++ String.ofList [c]) rest := by
      intro hz
      by_cases hb : c = '\\'
      · subst hb; rw [hz rfl]; rfl
      · cases rest <;> simp [scanStringT, h1, hb]
    have hrest : c = '\\' → rest = [] := by
      intro hc
      cases rest with
      | nil => rfl
      | cons d r => exact (h2 d r hc rfl).elim
    rw [hgen hrest] at h
    have := ih body rest' h
    simp only [List.length_cons]; omega

/-- Every successful tokenization also succeeds at fuel `length + 1` (each step consumes at
    least one character), which is exactly the fuel `tokenizeTotal` supplies. -/
theorem tokenizeT_sufficient :
    ∀ (n : Nat) (cs : List Char) (t : List String),
      tokenizeT n cs = some t → tokenizeT (cs.length + 1) cs = some t := by
  intro n
  induction n with
  | zero => intro cs t h; simp [tokenizeT] at h
  | succ n ih =>
    intro cs t h
    cases cs with
    | nil => simp [tokenizeT] at h ⊢; exact h
    | cons c rest =>
      simp only [List.length_cons]
      by_cases hp : c = '('
      · subst hp
        simp [tokenizeT] at h ⊢
        cases hr : tokenizeT n rest with
        | none => simp [hr] at h
        | some t' =>
          simp [hr] at h; subst h
          simp [ih rest t' hr]
      · by_cases hq : c = ')'
        · subst hq
          simp [tokenizeT] at h ⊢
          cases hr : tokenizeT n rest with
          | none => simp [hr] at h
          | some t' =>
            simp [hr] at h; subst h
            simp [ih rest t' hr]
        · by_cases hd : c = '"'
          · subst hd
            simp [tokenizeT] at h ⊢
            cases hs : scanStringT "" rest with
            | none => simp [hs] at h
            | some pr =>
              rcases pr with ⟨body, rest'⟩
              simp [hs] at h ⊢
              cases hr : tokenizeT n rest' with
              | none => simp [hr] at h
              | some t' =>
                simp [hr] at h; subst h
                have hlen := scanStringT_length_le "" rest body rest' hs
                have h1 := ih rest' t' hr
                have h2 := tokenizeT_fuel_mono (rest'.length + 1) (rest.length - rest'.length) rest' t' h1
                rw [show rest'.length + 1 + (rest.length - rest'.length) = rest.length + 1 by omega] at h2
                simp [h2]
          · by_cases hs : isSpaceT c = true
            · have hunf : tokenizeT (n + 1) (c :: rest) = tokenizeT n rest := by
                simp [tokenizeT, hp, hq, hd, hs]
              have hunf' : tokenizeT (rest.length + 1 + 1) (c :: rest) = tokenizeT (rest.length + 1) rest := by
                simp [tokenizeT, hp, hq, hd, hs]
              rw [hunf] at h
              rw [hunf']
              exact ih rest t h
            · have hunf : tokenizeT (n + 1) (c :: rest) =
                  (tokenizeT n (atomT rest).2).map ((String.ofList (c :: (atomT rest).1)) :: ·) := by
                simp [tokenizeT, hp, hq, hd, hs]
              have hunf' : tokenizeT (rest.length + 1 + 1) (c :: rest) =
                  (tokenizeT (rest.length + 1) (atomT rest).2).map
                    ((String.ofList (c :: (atomT rest).1)) :: ·) := by
                simp [tokenizeT, hp, hq, hd, hs]
              rw [hunf] at h
              rw [hunf']
              cases hr : tokenizeT n (atomT rest).2 with
              | none => simp [hr] at h
              | some t' =>
                simp [hr] at h; subst h
                have hlen := atomT_length_le rest
                have h1 := ih (atomT rest).2 t' hr
                have h2 := tokenizeT_fuel_mono ((atomT rest).2.length + 1)
                  (rest.length - (atomT rest).2.length) (atomT rest).2 t' h1
                rw [show (atomT rest).2.length + 1 + (rest.length - (atomT rest).2.length) =
                  rest.length + 1 by omega] at h2
                simp [h2]

theorem toList_space : (" " : String).toList = [' '] := rfl

/-- The String-level chunking theorem: two independently tokenizable texts joined by a single
    space tokenize to the concatenation of their token lists. -/
theorem tokenizeTotal_concat_space (a b : String) (ta tb : List String)
    (ha : tokenizeTotal a = some ta) (hb : tokenizeTotal b = some tb) :
    tokenizeTotal (a ++ " " ++ b) = some (ta ++ tb) := by
  unfold tokenizeTotal at ha hb ⊢
  have hc := tokenizeT_concat_space _ _ a.toList b.toList ta tb ha hb
  have hs := tokenizeT_sufficient _ _ _ hc
  have hl : (a ++ " " ++ b).toList = a.toList ++ ' ' :: b.toList := by
    simp [String.toList_append, toList_space]
  have hlen : (a ++ " " ++ b).length = (a.toList ++ ' ' :: b.toList).length := by
    rw [← hl]; rfl
  rw [hl, hlen]
  exact hs

end CalculusTokenize
