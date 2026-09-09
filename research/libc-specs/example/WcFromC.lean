/- Hand-embedded C subset, not a verified C translation.
Streams use Char; printf appends decimal text. Scalars are unbounded and pointers
are not modeled. The pipeline supplies newline-free lines, each terminated by LF.
-/
namespace Pipeline.Generated

inductive Expr where
  | lit : Int → Expr
  | var : String → Expr
  | add : Expr → Expr → Expr
  | eq  : Expr → Expr → Expr   
  | ne  : Expr → Expr → Expr   

inductive LibCall where
  | getchar                     
  | printfNatLn (e : Expr)      

inductive Stmt where
  | skip
  | assign (x : String) (e : Expr)
  | call (x : String) (c : LibCall)   
  | seq (s₁ s₂ : Stmt)
  | ite (c : Expr) (t e : Stmt)
  | while (c : Expr) (body : Stmt)

structure State where
  env : String → Int
  stdin : List Char      
  stdout : List Char     

def State.set (σ : State) (x : String) (v : Int) : State :=
  { σ with env := fun y => if y = x then v else σ.env y }

def evalExpr (σ : State) : Expr → Int
  | .lit n => n
  | .var x => σ.env x
  | .add a b => evalExpr σ a + evalExpr σ b
  | .eq a b => if evalExpr σ a = evalExpr σ b then 1 else 0
  | .ne a b => if evalExpr σ a = evalExpr σ b then 0 else 1

/-- Library calls transform explicit stream contents and return a C result. -/

def EOF : Int := -1

def libc (σ : State) : LibCall → Int × State
  | .getchar =>
    match σ.stdin with
    | [] => (EOF, σ)
    | c :: rest => ((c.toNat : Int), { σ with stdin := rest })
  | .printfNatLn e =>
    let cs := (toString (evalExpr σ e).toNat).toList ++ ['\n']
    ((cs.length : Int), { σ with stdout := σ.stdout ++ cs })

/-- Fuel exhaustion returns none; concrete execution theorems prove sufficient fuel. -/

def exec : Nat → Stmt → State → Option State
  | 0, _, _ => none
  | _ + 1, .skip, σ => some σ
  | _ + 1, .assign x e, σ => some (σ.set x (evalExpr σ e))
  | _ + 1, .call x c, σ =>
    let r := libc σ c
    some (r.2.set x r.1)
  | n + 1, .seq s₁ s₂, σ =>
    match exec n s₁ σ with
    | some σ' => exec n s₂ σ'
    | none => none
  | n + 1, .ite c t e, σ =>
    if evalExpr σ c = 0 then exec n e σ else exec n t σ
  | n + 1, .while c b, σ =>
    if evalExpr σ c = 0 then some σ
    else
      match exec n b σ with
      | some σ' => exec n (.while c b) σ'
      | none => none

/-! ## The C program (the specification of `wc -l`)

    int main(void) {
      size_t nl = 0; int c;
      c = getchar();                       /* while ((c = getchar()) != EOF) ... */
      while (c != EOF) {                   /*   desugared: assignment hoisted     */
        if (c == '\n') nl = nl + 1;
        c = getchar();
      }
      printf("%zu\n", nl);
      return 0;
    }
-/

def loopBody : Stmt :=
  .seq (.ite (.eq (.var "c") (.lit 10))
             (.assign "nl" (.add (.var "nl") (.lit 1)))
             .skip)
       (.call "c" .getchar)

def wcLoop : Stmt := .while (.ne (.var "c") (.lit EOF)) loopBody

def wcProg : Stmt :=
  .seq (.assign "nl" (.lit 0))
  (.seq (.call "c" .getchar)
  (.seq wcLoop
  (.seq (.call "_" (.printfNatLn (.var "nl")))
        (.assign "ret" (.lit 0)))))

def bytesOf (stdin : List String) : List Char :=
  stdin.flatMap fun l => l.toList ++ ['\n']

def linesOfAux : List Char → List Char → List String
  | cur, [] =>
    match cur with
    | [] => []
    | _ => [String.ofList cur]
  | cur, c :: cs =>
    if c = '\n' then String.ofList cur :: linesOfAux [] cs
    else linesOfAux (cur ++ [c]) cs

def linesOf (cs : List Char) : List String := linesOfAux [] cs

def initState (stdin : List String) : State :=
  { env := fun _ => 0, stdin := bytesOf stdin, stdout := [] }

/-- Fuel: one unit per input byte plus a constant for the program's nesting depth. -/
def fuel (stdin : List String) : Nat := (bytesOf stdin).length + 16

def run (_args stdin : List String) : List String × UInt32 :=
  match exec (fuel stdin) wcProg (initState stdin) with
  | some σ => (linesOf σ.stdout, UInt32.ofNat (σ.env "ret").toNat)
  | none => ([], 1)

theorem set_same (σ : State) (x : String) (v : Int) : (σ.set x v).env x = v := by
  simp [State.set]

theorem set_other (σ : State) (x y : String) (v : Int) (h : y ≠ x) :
    (σ.set x v).env y = σ.env y := by
  simp [State.set, h]

theorem set_stdin (σ : State) (x : String) (v : Int) : (σ.set x v).stdin = σ.stdin := rfl
theorem set_stdout (σ : State) (x : String) (v : Int) : (σ.set x v).stdout = σ.stdout := rfl

theorem exec_seq_succ (n : Nat) (s₁ s₂ : Stmt) (σ : State) :
    exec (n + 1) (.seq s₁ s₂) σ =
      match exec n s₁ σ with
      | some σ' => exec n s₂ σ'
      | none => none := rfl

theorem exec_while_succ (n : Nat) (c : Expr) (b : Stmt) (σ : State) :
    exec (n + 1) (.while c b) σ =
      if evalExpr σ c = 0 then some σ
      else
        match exec n b σ with
        | some σ' => exec n (.while c b) σ'
        | none => none := rfl

theorem getchar_eof (σ : State) (h : σ.stdin = []) : libc σ .getchar = (EOF, σ) := by
  simp [libc, h]

theorem getchar_consumes (σ : State) (c : Char) (rest : List Char) (h : σ.stdin = c :: rest) :
    libc σ .getchar = ((c.toNat : Int), { σ with stdin := rest }) := by
  simp [libc, h]

/-- The value of `c` the loop expects when `pending` bytes remain to be processed
(the current one already read into `c`). -/
def codeOf : List Char → Int
  | [] => EOF
  | c :: _ => (c.toNat : Int)

theorem getchar_codeOf (σ : State) (rest : List Char) (h : σ.stdin = rest) :
    libc σ .getchar = (codeOf rest, { σ with stdin := rest.tail }) := by
  cases rest with
  | nil =>
    obtain ⟨env, si, so⟩ := σ
    have h' : si = [] := h
    subst h'
    simp [libc, codeOf]
  | cons d ds => simp [libc, h, codeOf]

theorem char_eq_newline_of_toNat (c : Char) (h : c.toNat = 10) : c = '\n' := by
  have := Char.ofNat_toNat c
  rw [h] at this
  exact this.symm

/-- The body needs k + 3 fuel because its statements nest three deep. -/
theorem loopBody_step (k : Nat) (σ σ₁ : State)
    (hσ₁ : (if σ.env "c" = 10 then σ.set "nl" (σ.env "nl" + 1) else σ) = σ₁) :
    exec (k + 3) loopBody σ = some ((libc σ₁ .getchar).2.set "c" (libc σ₁ .getchar).1) := by
  subst hσ₁
  by_cases h : σ.env "c" = 10 <;> simp [loopBody, exec, evalExpr, h]

/-- pending includes the current character already loaded into c. -/
theorem wcLoop_counts_newlines (pending : List Char) :
    ∀ (σ : State) (n : Nat), pending.length + 4 ≤ n →
      σ.env "c" = codeOf pending → σ.stdin = pending.tail →
      ∃ σ', exec n wcLoop σ = some σ' ∧
        σ'.env "nl" = σ.env "nl" + (List.count '\n' pending : Int) ∧
        σ'.stdout = σ.stdout ∧ σ'.stdin = [] := by
  induction pending with
  | nil =>
    intro σ n hn hc hs
    obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨n - 1, by omega⟩
    refine ⟨σ, ?_, by simp, rfl, hs⟩
    rw [wcLoop, exec_while_succ]
    simp [evalExpr, hc, codeOf]
  | cons ch rest ih =>
    intro σ n hn hc hs
    obtain ⟨m, rfl⟩ : ∃ m, n = m + 3 + 1 := ⟨n - 4, by omega⟩
    simp only [List.tail_cons] at hs
    have hcond : ¬ evalExpr σ (.ne (.var "c") (.lit EOF)) = 0 := by
      simp [evalExpr, hc, codeOf, EOF]

    obtain ⟨σ₁, hσ₁⟩ : ∃ σ₁, (if σ.env "c" = 10 then σ.set "nl" (σ.env "nl" + 1) else σ) = σ₁ :=
      ⟨_, rfl⟩
    have hbody := loopBody_step m σ σ₁ hσ₁
    have h₁stdin : σ₁.stdin = rest := by
      rw [← hσ₁]; split <;> simp [set_stdin, hs]
    have h₁stdout : σ₁.stdout = σ.stdout := by
      rw [← hσ₁]; split <;> simp [set_stdout]
    have h₁nl : σ₁.env "nl" = σ.env "nl" + (if ch = '\n' then 1 else 0) := by
      rw [← hσ₁]
      by_cases hch : ch = '\n'
      · have : σ.env "c" = 10 := by rw [hc]; simp [codeOf, hch]
        simp [this, set_same, hch]
      · have : ¬ σ.env "c" = 10 := by
          rw [hc]; simp only [codeOf]
          intro h10
          exact hch (char_eq_newline_of_toNat ch (by omega))
        simp [this, hch]

    rw [getchar_codeOf σ₁ rest h₁stdin] at hbody
    obtain ⟨σ₂, hσ₂⟩ :
        ∃ σ₂, ({ σ₁ with stdin := rest.tail } : State).set "c" (codeOf rest) = σ₂ := ⟨_, rfl⟩
    rw [hσ₂] at hbody
    have h₂c : σ₂.env "c" = codeOf rest := by rw [← hσ₂]; exact set_same _ _ _
    have h₂stdin : σ₂.stdin = rest.tail := by rw [← hσ₂]; rfl
    have h₂stdout : σ₂.stdout = σ.stdout := by rw [← hσ₂, set_stdout]; exact h₁stdout
    have h₂nl : σ₂.env "nl" = σ₁.env "nl" := by
      rw [← hσ₂]; exact set_other _ _ _ _ (by decide)

    obtain ⟨σ', hexec, hnl, hout, hin⟩ :=
      ih σ₂ (m + 3) (by simp at hn; omega) h₂c h₂stdin
    refine ⟨σ', ?_, ?_, by rw [hout, h₂stdout], hin⟩
    · rw [wcLoop, exec_while_succ, if_neg hcond, hbody]
      exact hexec
    · rw [hnl, h₂nl, h₁nl, List.count_cons]
      by_cases hch : ch = '\n'
      · simp [hch]; omega
      · simp [hch]

theorem wcProg_run (stdin : List String) :
    ∃ σ, exec (fuel stdin) wcProg (initState stdin) = some σ ∧
      σ.stdout = (toString (List.count '\n' (bytesOf stdin))).toList ++ ['\n'] ∧
      σ.env "ret" = 0 := by

  have hfuel : fuel stdin = ((bytesOf stdin).length + 11) + 5 := by simp [fuel]
  rw [hfuel]
  generalize hG : (bytesOf stdin).length + 11 = G

  obtain ⟨σ₁, hσ₁⟩ : ∃ σ₁, (initState stdin).set "nl" (evalExpr (initState stdin) (.lit 0)) = σ₁ :=
    ⟨_, rfl⟩
  have s1 : exec (G + 4) (.assign "nl" (.lit 0)) (initState stdin) = some σ₁ := by
    rw [← hσ₁]; rfl
  have h₁stdin : σ₁.stdin = bytesOf stdin := by rw [← hσ₁]; rfl
  have h₁out : σ₁.stdout = [] := by rw [← hσ₁]; rfl
  have h₁nl : σ₁.env "nl" = 0 := by rw [← hσ₁]; exact set_same _ _ _

  obtain ⟨σ₂, hσ₂⟩ :
      ∃ σ₂, ({ σ₁ with stdin := (bytesOf stdin).tail } : State).set "c" (codeOf (bytesOf stdin)) = σ₂ :=
    ⟨_, rfl⟩
  have s2 : exec (G + 3) (.call "c" .getchar) σ₁ = some σ₂ := by
    show some ((libc σ₁ .getchar).2.set "c" (libc σ₁ .getchar).1) = some σ₂
    rw [getchar_codeOf σ₁ _ h₁stdin, hσ₂]
  have h₂c : σ₂.env "c" = codeOf (bytesOf stdin) := by rw [← hσ₂]; exact set_same _ _ _
  have h₂stdin : σ₂.stdin = (bytesOf stdin).tail := by rw [← hσ₂]; rfl
  have h₂out : σ₂.stdout = [] := by rw [← hσ₂]; exact h₁out
  have h₂nl : σ₂.env "nl" = 0 := by
    rw [← hσ₂, set_other _ _ _ _ (by decide)]; exact h₁nl

  obtain ⟨σ₃, s3, hnl, hout, -⟩ :=
    wcLoop_counts_newlines (bytesOf stdin) σ₂ (G + 2) (by omega) h₂c h₂stdin

  obtain ⟨σ₄, hσ₄⟩ : ∃ σ₄, (libc σ₃ (.printfNatLn (.var "nl"))).2.set "_"
      (libc σ₃ (.printfNatLn (.var "nl"))).1 = σ₄ := ⟨_, rfl⟩
  have s4 : exec (G + 1) (.call "_" (.printfNatLn (.var "nl"))) σ₃ = some σ₄ := by
    rw [← hσ₄]; rfl
  have h₄out : σ₄.stdout = σ₃.stdout ++ ((toString (σ₃.env "nl").toNat).toList ++ ['\n']) := by
    rw [← hσ₄, set_stdout]; rfl

  obtain ⟨σ₅, hσ₅⟩ : ∃ σ₅, σ₄.set "ret" (evalExpr σ₄ (.lit 0)) = σ₅ := ⟨_, rfl⟩
  have s5 : exec (G + 1) (.assign "ret" (.lit 0)) σ₄ = some σ₅ := by
    rw [← hσ₅]; rfl
  refine ⟨σ₅, ?_, ?_, by rw [← hσ₅]; exact set_same _ _ _⟩
  · -- assemble: seq peels one fuel unit per nesting level
    simp only [wcProg, exec_seq_succ, s1, s2, s3, s4, s5]
  · rw [← hσ₅, set_stdout, h₄out, hout, h₂out, hnl, h₂nl]
    simp

/- Decimal output must contain no newline for line-shim round-tripping. -/

theorem digitChar_big (m : Nat) : Nat.digitChar (m + 16) = '*' := by
  simp [Nat.digitChar]

theorem digitChar_ne_newline (m : Nat) : Nat.digitChar m ≠ '\n' := by
  match m with
  | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 => decide
  | m + 16 => rw [digitChar_big]; decide

theorem toDigitsCore_no_newline : ∀ (f n : Nat) (acc : List Char),
    (∀ c ∈ acc, c ≠ '\n') → ∀ c ∈ Nat.toDigitsCore 10 f n acc, c ≠ '\n' := by
  intro f
  induction f with
  | zero => intro n acc h; simp only [Nat.toDigitsCore]; exact h
  | succ f ih =>
    intro n acc h
    simp only [Nat.toDigitsCore]
    split
    · intro c hc
      rw [List.mem_cons] at hc
      rcases hc with hc | hc
      · subst hc; exact digitChar_ne_newline _
      · exact h c hc
    · apply ih
      intro c hc
      rw [List.mem_cons] at hc
      rcases hc with hc | hc
      · subst hc; exact digitChar_ne_newline _
      · exact h c hc

theorem repr_no_newline (n : Nat) : '\n' ∉ (toString n).toList := by
  show '\n' ∉ (Nat.repr n).toList
  unfold Nat.repr
  rw [String.toList_ofList]
  intro h
  exact toDigitsCore_no_newline _ _ _ (by intro c hc; cases hc) '\n' h rfl

theorem linesOfAux_no_newline (l : List Char) :
    ∀ (cur rest : List Char), '\n' ∉ l →
      linesOfAux cur (l ++ '\n' :: rest) = String.ofList (cur ++ l) :: linesOfAux [] rest := by
  induction l with
  | nil => intro cur rest _; simp [linesOfAux]
  | cons c cs ih =>
    intro cur rest h
    have hc : c ≠ '\n' := fun e => h (by rw [e]; exact List.mem_cons_self)
    have hcs : '\n' ∉ cs := fun e => h (List.mem_cons_of_mem _ e)
    simp only [List.cons_append, linesOfAux, if_neg hc]
    rw [ih (cur ++ [c]) rest hcs]
    simp

theorem linesOf_single (l : List Char) (h : '\n' ∉ l) :
    linesOf (l ++ ['\n']) = [String.ofList l] := by
  unfold linesOf
  have := linesOfAux_no_newline l [] [] h
  simpa [linesOfAux] using this

theorem run_stdout_eq_newline_count (args stdin : List String) :
    (run args stdin).1 = [toString (List.count '\n' (bytesOf stdin))] := by
  obtain ⟨σ, hexec, hout, _⟩ := wcProg_run stdin
  simp only [run, hexec, hout]
  rw [linesOf_single _ (repr_no_newline _), String.ofList_toList]

theorem count_newline_bytesOf (stdin : List String) (h : ∀ l ∈ stdin, '\n' ∉ l.toList) :
    List.count '\n' (bytesOf stdin) = stdin.length := by
  induction stdin with
  | nil => simp [bytesOf]
  | cons l ls ih =>
    have hl : '\n' ∉ l.toList := h l (List.mem_cons_self)
    have hls : ∀ l' ∈ ls, '\n' ∉ l'.toList := fun l' hm => h l' (List.mem_cons_of_mem _ hm)
    simp only [bytesOf, List.flatMap_cons, List.count_append, List.length_cons]
    rw [List.count_eq_zero.mpr hl]
    simp only [bytesOf] at ih
    rw [ih hls]
    simp
    omega

theorem run_stdout_eq_line_count (args stdin : List String)
    (h : ∀ l ∈ stdin, '\n' ∉ l.toList) :
    (run args stdin).1 = [toString stdin.length] := by
  rw [run_stdout_eq_newline_count, count_newline_bytesOf stdin h]

theorem run_exit_success (args stdin : List String) : (run args stdin).2 = 0 := by
  obtain ⟨σ, hexec, _, hret⟩ := wcProg_run stdin
  simp only [run, hexec, hret]
  rfl

theorem run_independent_of_args (a₁ a₂ stdin : List String) : run a₁ stdin = run a₂ stdin := rfl

theorem run_append (args xs ys : List String) :
    (run args (xs ++ ys)).1 =
      [toString (List.count '\n' (bytesOf xs) + List.count '\n' (bytesOf ys))] := by
  rw [run_stdout_eq_newline_count]
  simp [bytesOf, List.flatMap_append, List.count_append]

end Pipeline.Generated
