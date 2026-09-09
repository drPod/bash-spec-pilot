import WcFromC
namespace RawWc
open Pipeline.Generated

def rawInit (bs : List Char) : State :=
  { env := fun _ => 0, stdin := bs, stdout := [] }
def rawFuel (bs : List Char) : Nat := bs.length + 16

theorem wcProg_raw (bs : List Char) :
    ∃ σ, exec (rawFuel bs) wcProg (rawInit bs) = some σ ∧
      σ.stdout = (toString (List.count '\n' bs)).toList ++ ['\n'] ∧
      σ.env "ret" = 0 := by

  have hfuel : rawFuel bs = (bs.length + 11) + 5 := by simp [rawFuel]
  rw [hfuel]
  generalize hG : bs.length + 11 = G

  obtain ⟨σ₁, hσ₁⟩ : ∃ σ₁, (rawInit bs).set "nl" (evalExpr (rawInit bs) (.lit 0)) = σ₁ :=
    ⟨_, rfl⟩
  have s1 : exec (G + 4) (.assign "nl" (.lit 0)) (rawInit bs) = some σ₁ := by
    rw [← hσ₁]; rfl
  have h₁stdin : σ₁.stdin = bs := by rw [← hσ₁]; rfl
  have h₁out : σ₁.stdout = [] := by rw [← hσ₁]; rfl
  have h₁nl : σ₁.env "nl" = 0 := by rw [← hσ₁]; exact set_same _ _ _

  obtain ⟨σ₂, hσ₂⟩ :
      ∃ σ₂, ({ σ₁ with stdin := bs.tail } : State).set "c" (codeOf bs) = σ₂ :=
    ⟨_, rfl⟩
  have s2 : exec (G + 3) (.call "c" .getchar) σ₁ = some σ₂ := by
    show some ((libc σ₁ .getchar).2.set "c" (libc σ₁ .getchar).1) = some σ₂
    rw [getchar_codeOf σ₁ _ h₁stdin, hσ₂]
  have h₂c : σ₂.env "c" = codeOf bs := by rw [← hσ₂]; exact set_same _ _ _
  have h₂stdin : σ₂.stdin = bs.tail := by rw [← hσ₂]; rfl
  have h₂out : σ₂.stdout = [] := by rw [← hσ₂]; exact h₁out
  have h₂nl : σ₂.env "nl" = 0 := by
    rw [← hσ₂, set_other _ _ _ _ (by decide)]; exact h₁nl

  obtain ⟨σ₃, s3, hnl, hout, -⟩ :=
    wcLoop_counts_newlines bs σ₂ (G + 2) (by omega) h₂c h₂stdin

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

-- Each UInt8 is injected separately; this is not UTF-8 decoding.
def liftByte (b : UInt8) : Char := Char.ofNat b.toNat
def liftBytes (bs : List UInt8) : List Char := bs.map liftByte

theorem liftByte_newline (b : UInt8) : liftByte b = '\n' ↔ b = 10 := by
  have hb := b.toNat_lt
  have hv : b.toNat.isValidChar := Or.inl (by omega)
  have hn : (liftByte b).toNat = b.toNat := by
    simp [liftByte, Char.ofNat, hv, Char.ofNatAux, Char.toNat]
  constructor
  · intro h
    have he := congrArg Char.toNat h
    rw [hn] at he
    apply UInt8.toNat_inj.mp
    exact he
  · intro h
    subst b
    rfl

theorem count_liftBytes (bs : List UInt8) :
    List.count '\n' (liftBytes bs) = List.count 10 bs := by
  induction bs with
  | nil => rfl
  | cons b bs ih =>
    simp only [liftBytes, List.map_cons, List.count_cons] at *
    rw [ih]
    simp [liftByte_newline]

def runBytes (bs : List UInt8) : List Char × UInt32 :=
  match exec (rawFuel (liftBytes bs)) wcProg (rawInit (liftBytes bs)) with
  | some σ => (σ.stdout, UInt32.ofNat (σ.env "ret").toNat)
  | none => ([], 1)

theorem runBytes_correct (bs : List UInt8) :
    runBytes bs = ((toString (List.count 10 bs)).toList ++ ['\n'], 0) := by
  obtain ⟨σ, he, ho, hr⟩ := wcProg_raw (liftBytes bs)
  simp [runBytes, he, ho, hr, count_liftBytes]

theorem runBytes_append (xs ys : List UInt8) :
    runBytes (xs ++ ys) =
      ((toString (List.count 10 xs + List.count 10 ys)).toList ++ ['\n'], 0) := by
  rw [runBytes_correct, List.count_append]

/-- Actual pure input conversion used by pipeline/lean/Main.lean. -/
def oldAbstract (s : String) : List String :=
  let parts := s.splitOn "\n"
  if parts.getLast? = some "" then parts.dropLast else parts

/-- Information loss makes a universally correct wc factorization impossible. -/
theorem no_line_factorization :
    ¬ ∃ f : List String → Nat, ∀ s : String,
      f (oldAbstract s) = List.count '\n' s.toList := by
  intro ⟨f, h⟩
  have hx := h "x"
  have hxn := h "x\n"
  have ha : oldAbstract "x" = ["x"] := by cbv
  have hb : oldAbstract "x\n" = ["x"] := by cbv
  rw [ha] at hx
  rw [hb] at hxn
  have hc : List.count '\n' "x".toList = 0 := by cbv
  have hd : List.count '\n' "x\n".toList = 1 := by cbv
  rw [hc] at hx
  rw [hd] at hxn
  omega

#print axioms wcProg_raw
#print axioms liftByte_newline
#print axioms count_liftBytes
#print axioms runBytes_correct
#print axioms runBytes_append
#print axioms no_line_factorization
end RawWc
