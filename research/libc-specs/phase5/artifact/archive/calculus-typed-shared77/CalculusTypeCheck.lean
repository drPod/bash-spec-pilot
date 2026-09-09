import CalculusTyping
import CalculusLowering
open CalculusNested CalculusTyping CalculusBody CalculusRelayOuter CalculusLowering

/-!
# CalculusTypeCheck: a decidable type checker for `CalculusTyping`, its soundness, and the
# concrete derivations for the nine exported bodies (calculus-correspondence-61)

`inferE`/`checkE`/`checkS` compute types; `inferE_sound`/`checkE_sound`/`checkS_sound` turn a
successful check into an `ETy`/`STy` derivation. `relaySchema` is the CONCRETE attribute schema
of `byte_relay_exec.sc` (`input`/`delivered`/`lost`/`bytes` : bytes, `reads`/`writes` : int list,
`read_calls`/`write_calls`/`cap`/`len` : int — not `top`), `relaySig` the action signatures the
lowering declares. `*_typed` are kernel-evaluated checks of the nine bodies (with `if`/`return`/
`while`/`try`-`catch` cases exercised), `relayActs_typed` packages them into `ActsTyped`, and
`writeBlock_preserves` applies `preservation`: every run of `write_block` from a well-typed
argument and a well-shaped state ends well-typed or fails. Range/non-failure remains a separate
question (the whole-body theorems' explicit hypotheses in `CalculusBody`). -/

namespace CalculusTypeCheck

abbrev CtxL := List (String × RTy)
def toCtx (Γ : CtxL) : Ctx := fun x => lookup Γ x

theorem toCtx_cons (Γ : CtxL) (x : String) (ρ : RTy) : toCtx ((x, ρ) :: Γ) = (toCtx Γ).set x ρ := by
  funext y
  simp only [toCtx, lookup, Ctx.set]
  by_cases h : x = y
  · subst h; simp
  · simp [h, Ne.symm h]

/-! ## Decidable subtyping -/

def subB : Ty → Ty → Bool
  | .int, .scalar | .bool, .scalar | .str, .scalar | .unit, .scalar => true
  | .bytes, .list => true
  | .pair a1 b1, .pair a2 b2 => subB a1 a2 && subB b1 b2
  | a, b => a = b || b = .top

theorem subB_sound : ∀ (a b : Ty), subB a b = true → Sub a b := by
  intro a
  induction a with
  | pair a1 b1 iha ihb =>
    intro b h
    cases b with
    | pair a2 b2 =>
      simp only [subB, Bool.and_eq_true] at h
      exact Sub.pair (iha a2 h.1) (ihb b2 h.2)
    | top => exact Sub.top _
    | int => simp [subB] at h
    | bool => simp [subB] at h
    | str => simp [subB] at h
    | unit => simp [subB] at h
    | scalar => simp [subB] at h
    | bytes => simp [subB] at h
    | list => simp [subB] at h
  | int | bool | str | unit | scalar | bytes | list | top =>
    intro b h
    cases b <;> simp [subB] at h <;>
      (first
        | exact Sub.refl _
        | exact Sub.top _
        | exact Sub.bytesList
        | exact Sub.intScalar
        | exact Sub.boolScalar
        | exact Sub.strScalar
        | exact Sub.unitScalar)

/-! ## Expressions -/

def inferE (Γ : CtxL) : Expr → Option RTy
  | .lit l => some (.data (litTy l))
  | .var x => lookup Γ x
  | .pair a b =>
    match inferE Γ a, inferE Γ b with
    | some ρa, some ρb => some (pairR ρa ρb)
    | _, _ => none
  | .fn .fst e =>
    match inferE Γ e with
    | some (.data (.pair a _)) => some (.data a)
    | some (.rpair ρa _) => some ρa
    | _ => none
  | .fn .snd e =>
    match inferE Γ e with
    | some (.data (.pair _ b)) => some (.data b)
    | some (.rpair _ ρb) => some ρb
    | _ => none
  | .fn f e =>
    match inferE Γ e with
    | some (.data τ) => if subB τ (funcArg f) then some (.data (funcRet f)) else none
    | _ => none
  | .elem base _ arg =>
    match inferE Γ base, inferE Γ arg with
    | some .ref, some (.data τ) => if subB τ .scalar then some .ref else none
    | _, _ => none

/-- `checkE Γ e ρ`: `e` has type `ρ`, up to data subtyping. -/
def checkE (Γ : CtxL) (e : Expr) (ρ : RTy) : Bool :=
  match inferE Γ e, ρ with
  | some (.data τ), .data τ' => subB τ τ'
  | some ρ', ρ => decide (ρ' = ρ)
  | none, _ => false

theorem inferE_sound (Γ : CtxL) : ∀ (e : Expr) (ρ : RTy), inferE Γ e = some ρ → ETy (toCtx Γ) e ρ := by
  intro e
  induction e with
  | lit l => intro ρ h; simp only [inferE, Option.some.injEq] at h; subst h; exact ETy.lit l
  | var x => intro ρ h; exact ETy.var h
  | pair a b iha ihb =>
    intro ρ h
    simp only [inferE] at h
    split at h
    · rename_i ρa ρb ha hb
      simp only [Option.some.injEq] at h; subst h
      exact ETy.pair (iha ρa ha) (ihb ρb hb)
    · cases h
  | fn f e ih =>
    intro ρ h
    cases f with
    | fst =>
      simp only [inferE] at h
      split at h
      · rename_i a b hb; simp only [Option.some.injEq] at h; subst h; exact ETy.fst_data (ih _ hb)
      · rename_i ρa ρb hb; simp only [Option.some.injEq] at h; subst h; exact ETy.fst_ref (ih _ hb)
      · cases h
    | snd =>
      simp only [inferE] at h
      split at h
      · rename_i a b hb; simp only [Option.some.injEq] at h; subst h; exact ETy.snd_data (ih _ hb)
      · rename_i ρa ρb hb; simp only [Option.some.injEq] at h; subst h; exact ETy.snd_ref (ih _ hb)
      · cases h
    | _ =>
      simp only [inferE] at h
      split at h
      · rename_i τ hτ
        split at h
        · rename_i hsub
          simp only [Option.some.injEq] at h; subst h
          exact ETy.fn (by intro h; cases h) (by intro h; cases h) (ih _ hτ) (subB_sound _ _ hsub)
        · cases h
      · cases h
  | elem base n arg ihb iha =>
    intro ρ h
    simp only [inferE] at h
    split at h
    · rename_i τ hb ha
      split at h
      · rename_i hsub
        simp only [Option.some.injEq] at h; subst h
        exact ETy.elem (ihb _ hb) (iha _ ha) (subB_sound _ _ hsub)
      · cases h
    · cases h

theorem checkE_sound (Γ : CtxL) (e : Expr) (ρ : RTy) (h : checkE Γ e ρ = true) : ETy (toCtx Γ) e ρ := by
  unfold checkE at h
  split at h
  · rename_i τ τ' hi
    exact ETy.sub (inferE_sound Γ e _ hi) (subB_sound _ _ h)
  · rename_i ρ' ρ hi _
    simp only [decide_eq_true_eq] at h; subst h
    exact inferE_sound Γ e _ hi
  · cases h

/-! ## Statements -/

abbrev SchemaL := List (String × Ty)
def toSchema (sch : SchemaL) : Schema := fun a => lookup sch a
abbrev SigL := List (String × (RTy × Ty))
def toSig (sig : SigL) : ActSig := fun a => (lookup sig a).getD (.data .unit, .unit)

/-- a re-binding must keep the variable's type -/
def rebindOk (Γ : CtxL) (x : String) (ρ : RTy) : Bool :=
  match lookup Γ x with
  | none => true
  | some ρ0 => decide (ρ0 = ρ)

theorem rebindOk_sound (Γ : CtxL) (x : String) (ρ : RTy) (h : rebindOk Γ x ρ = true) :
    ∀ ρ0, toCtx Γ x = some ρ0 → ρ0 = ρ := by
  intro ρ0 h0
  unfold rebindOk at h
  simp only [toCtx] at h0
  rw [h0] at h
  simpa using h

def checkS (sch : SchemaL) (sig : SigL) (ρret : Ty) : CtxL → Stmt String → Option CtxL
  | Γ, .pass => some Γ
  | Γ, .seq a b =>
    match checkS sch sig ρret Γ a with
    | some Γ1 => checkS sch sig ρret Γ1 b
    | none => none
  | Γ, .assign x e =>
    match inferE Γ e with
    | some ρ => if rebindOk Γ x ρ then some ((x, ρ) :: Γ) else none
    | none => none
  | Γ, .action v a e =>
    match lookup sig a with
    | some (ρarg, τret) =>
      if checkE Γ e ρarg && rebindOk Γ v (.data τret) then some ((v, .data τret) :: Γ) else none
    | none => none
  | Γ, .setAttr b a e =>
    match lookup sch a with
    | some τ => if checkE Γ b .ref && checkE Γ e (.data τ) then some Γ else none
    | none => none
  | Γ, .addElem b _ e =>
    match inferE Γ e with
    | some (.data τ) => if checkE Γ b .ref && subB τ .scalar then some Γ else none
    | _ => none
  | Γ, .removeElem b _ e =>
    match inferE Γ e with
    | some (.data τ) => if checkE Γ b .ref && subB τ .scalar then some Γ else none
    | _ => none
  | Γ, .get x b a =>
    match lookup sch a with
    | some τ => if checkE Γ b .ref && rebindOk Γ x (.data τ) then some ((x, .data τ) :: Γ) else none
    | none => none
  | Γ, .contains b _ e t f =>
    match inferE Γ e with
    | some (.data τ) =>
      if checkE Γ b .ref && subB τ .scalar && (checkS sch sig ρret Γ t).isSome && (checkS sch sig ρret Γ f).isSome
      then some Γ else none
    | _ => none
  | Γ, .cond c t e =>
    if checkE Γ c (.data .bool) && (checkS sch sig ρret Γ t).isSome && (checkS sch sig ρret Γ e).isSome
    then some Γ else none
  | Γ, .while c body =>
    if checkE Γ c (.data .bool) && (checkS sch sig ρret Γ body).isSome then some Γ else none
  | Γ, .tryCatch body v handler =>
    if (checkS sch sig ρret Γ body).isSome && rebindOk Γ v (.data excTy) &&
        (checkS sch sig ρret ((v, .data excTy) :: Γ) handler).isSome
    then some Γ else none
  | Γ, .tryFinally body fin =>
    if (checkS sch sig ρret Γ body).isSome && (checkS sch sig ρret Γ fin).isSome then some Γ else none
  | Γ, .raise e => if checkE Γ e (.data excTy) then some Γ else none
  | Γ, .ret e => if checkE Γ e (.data ρret) then some Γ else none

theorem isSome_exists {α : Type} {o : Option α} (h : o.isSome = true) : ∃ a, o = some a := by
  cases o with
  | none => simp at h
  | some a => exact ⟨a, rfl⟩

theorem checkS_sound (sch : SchemaL) (sig : SigL) (ρret : Ty) :
    ∀ (s : Stmt String) (Γ Γ' : CtxL), checkS sch sig ρret Γ s = some Γ' →
      STy (toSchema sch) (toSig sig) ρret (toCtx Γ) s (toCtx Γ') := by
  intro s
  induction s with
  | pass => intro Γ Γ' h; simp only [checkS, Option.some.injEq] at h; subst h; exact STy.pass
  | seq a b iha ihb =>
    intro Γ Γ' h
    simp only [checkS] at h
    split at h
    · rename_i Γ1 ha; exact STy.seq (iha Γ Γ1 ha) (ihb Γ1 Γ' h)
    · cases h
  | action v a e =>
    intro Γ Γ' h
    simp only [checkS] at h
    split at h
    · rename_i ρarg τret hsig
      split at h
      · rename_i hc
        simp only [Bool.and_eq_true] at hc
        simp only [Option.some.injEq] at h; subst h
        rw [toCtx_cons]
        have hsig' : toSig sig a = (ρarg, τret) := by simp [toSig, hsig]
        have := STy.action (Sch := toSchema sch) (sig := toSig sig) (ρret := ρret) (Γ := toCtx Γ)
          (v := v) (a := a) (e := e) (by rw [hsig']; exact checkE_sound Γ e ρarg hc.1)
          (by rw [hsig']; exact rebindOk_sound Γ v _ hc.2)
        rw [hsig'] at this
        exact this
      · cases h
    · cases h
  | assign x e =>
    intro Γ Γ' h
    simp only [checkS] at h
    split at h
    · rename_i ρ hi
      split at h
      · rename_i hr
        simp only [Option.some.injEq] at h; subst h
        rw [toCtx_cons]
        exact STy.assign (inferE_sound Γ e ρ hi) (rebindOk_sound Γ x ρ hr)
      · cases h
    · cases h
  | setAttr b a e =>
    intro Γ Γ' h
    simp only [checkS] at h
    split at h
    · rename_i τ hs
      split at h
      · rename_i hc
        simp only [Bool.and_eq_true] at hc
        simp only [Option.some.injEq] at h; subst h
        exact STy.setAttr (checkE_sound Γ b .ref hc.1) (by simp [toSchema, hs]) (checkE_sound Γ e _ hc.2)
      · cases h
    · cases h
  | addElem b n e =>
    intro Γ Γ' h
    simp only [checkS] at h
    split at h
    · rename_i τ hi
      split at h
      · rename_i hc
        simp only [Bool.and_eq_true] at hc
        simp only [Option.some.injEq] at h; subst h
        exact STy.addElem (checkE_sound Γ b .ref hc.1) (inferE_sound Γ e _ hi) (subB_sound _ _ hc.2)
      · cases h
    · cases h
  | removeElem b n e =>
    intro Γ Γ' h
    simp only [checkS] at h
    split at h
    · rename_i τ hi
      split at h
      · rename_i hc
        simp only [Bool.and_eq_true] at hc
        simp only [Option.some.injEq] at h; subst h
        exact STy.removeElem (checkE_sound Γ b .ref hc.1) (inferE_sound Γ e _ hi) (subB_sound _ _ hc.2)
      · cases h
    · cases h
  | get x b a =>
    intro Γ Γ' h
    simp only [checkS] at h
    split at h
    · rename_i τ hs
      split at h
      · rename_i hc
        simp only [Bool.and_eq_true] at hc
        simp only [Option.some.injEq] at h; subst h
        rw [toCtx_cons]
        exact STy.get (checkE_sound Γ b .ref hc.1) (by simp [toSchema, hs]) (rebindOk_sound Γ x _ hc.2)
      · cases h
    · cases h
  | contains b n e t f iht ihf =>
    intro Γ Γ' h
    simp only [checkS] at h
    split at h
    · rename_i τ hi
      split at h
      · rename_i hc
        simp only [Bool.and_eq_true] at hc
        obtain ⟨⟨⟨hb, hsub⟩, ht⟩, hf⟩ := hc
        obtain ⟨Γt, ht'⟩ := isSome_exists ht
        obtain ⟨Γf, hf'⟩ := isSome_exists hf
        simp only [Option.some.injEq] at h; subst h
        exact STy.contains (checkE_sound Γ b .ref hb) (inferE_sound Γ e _ hi) (subB_sound _ _ hsub)
          (iht Γ Γt ht') (ihf Γ Γf hf')
      · cases h
    · cases h
  | cond c t e iht ihe =>
    intro Γ Γ' h
    simp only [checkS] at h
    split at h
    · rename_i hc
      simp only [Bool.and_eq_true] at hc
      obtain ⟨⟨hcc, ht⟩, he⟩ := hc
      obtain ⟨Γt, ht'⟩ := isSome_exists ht
      obtain ⟨Γe, he'⟩ := isSome_exists he
      simp only [Option.some.injEq] at h; subst h
      exact STy.cond (checkE_sound Γ c _ hcc) (iht Γ Γt ht') (ihe Γ Γe he')
    · cases h
  | «while» c body ih =>
    intro Γ Γ' h
    simp only [checkS] at h
    split at h
    · rename_i hc
      simp only [Bool.and_eq_true] at hc
      obtain ⟨Γb, hb'⟩ := isSome_exists hc.2
      simp only [Option.some.injEq] at h; subst h
      exact STy.while (checkE_sound Γ c _ hc.1) (ih Γ Γb hb')
    · cases h
  | tryCatch body v handler ihb ihh =>
    intro Γ Γ' h
    simp only [checkS] at h
    split at h
    · rename_i hc
      simp only [Bool.and_eq_true] at hc
      obtain ⟨⟨hb, hv⟩, hh⟩ := hc
      obtain ⟨Γb, hb'⟩ := isSome_exists hb
      obtain ⟨Γh, hh'⟩ := isSome_exists hh
      simp only [Option.some.injEq] at h; subst h
      have := ihh _ Γh hh'
      rw [toCtx_cons] at this
      exact STy.tryCatch (ihb Γ Γb hb') (rebindOk_sound Γ v _ hv) this
    · cases h
  | tryFinally body fin ihb ihf =>
    intro Γ Γ' h
    simp only [checkS] at h
    split at h
    · rename_i hc
      simp only [Bool.and_eq_true] at hc
      obtain ⟨Γb, hb'⟩ := isSome_exists hc.1
      obtain ⟨Γf, hf'⟩ := isSome_exists hc.2
      simp only [Option.some.injEq] at h; subst h
      exact STy.tryFinally (ihb Γ Γb hb') (ihf Γ Γf hf')
    · cases h
  | raise e =>
    intro Γ Γ' h
    simp only [checkS] at h
    split at h
    · rename_i hc; simp only [Option.some.injEq] at h; subst h; exact STy.raise (checkE_sound Γ e _ hc)
    · cases h
  | ret e =>
    intro Γ Γ' h
    simp only [checkS] at h
    split at h
    · rename_i hc; simp only [Option.some.injEq] at h; subst h; exact STy.ret (checkE_sound Γ e _ hc)
    · cases h

/-! ## The concrete instantiation: `byte_relay_exec.sc`'s schema and signatures -/

def relaySchema : SchemaL :=
  [("input", .bytes), ("delivered", .bytes), ("lost", .bytes), ("reads", .list), ("writes", .list),
   ("read_calls", .int), ("write_calls", .int), ("cap", .int), ("len", .int), ("bytes", .bytes)]

def unitSig : RTy × Ty := (.data .unit, .int)
def relaySig : SigL :=
  [("read_block", (.ref, .int)), ("write_block", (.rpair .ref (.data (.pair .int .int)), .int)),
   ("relay", unitSig), ("relay_raising", unitSig), ("relay_caught", unitSig), ("mark", unitSig),
   ("relay_seq_relay", unitSig), ("relay_and_mark", unitSig), ("relay_or_mark", unitSig)]

def calleeCtxL (ρ : RTy) : CtxL := [("ι", ρ), ("σ", .ref)]

theorem toCtx_callee (ρ : RTy) : toCtx (calleeCtxL ρ) = calleeCtx ρ := by
  funext x
  simp only [toCtx, calleeCtxL, calleeCtx, lookup]
  by_cases h1 : x = "ι"
  · subst h1; simp
  · by_cases h2 : x = "σ"
    · subst h2; simp
    · simp [Ne.symm h1, Ne.symm h2, h1, h2]

/-- The nine bodies, type-checked under the concrete schema (kernel evaluation). -/
theorem readBlock_typed :
    (checkS relaySchema relaySig .int (calleeCtxL .ref) readBlockBody).isSome = true := by decide +kernel
theorem writeBlock_typed :
    (checkS relaySchema relaySig .int (calleeCtxL (.rpair .ref (.data (.pair .int .int)))) writeBlockBody).isSome = true := by
  decide +kernel
theorem relay_typed :
    (checkS relaySchema relaySig .int (calleeCtxL (.data .unit)) relayBody).isSome = true := by decide +kernel
theorem relayRaising_typed :
    (checkS relaySchema relaySig .int (calleeCtxL (.data .unit)) relayRaisingBody).isSome = true := by decide +kernel
theorem relayCaught_typed :
    (checkS relaySchema relaySig .int (calleeCtxL (.data .unit)) relayCaughtBody).isSome = true := by decide +kernel
theorem mark_typed :
    (checkS relaySchema relaySig .int (calleeCtxL (.data .unit)) markBody).isSome = true := by decide +kernel
theorem relaySeqRelay_typed :
    (checkS relaySchema relaySig .int (calleeCtxL (.data .unit)) relaySeqRelayBody).isSome = true := by decide +kernel
theorem relayAndMark_typed :
    (checkS relaySchema relaySig .int (calleeCtxL (.data .unit)) relayAndMarkBody).isSome = true := by decide +kernel
theorem relayOrMark_typed :
    (checkS relaySchema relaySig .int (calleeCtxL (.data .unit)) relayOrMarkBody).isSome = true := by decide +kernel

/-- The action table with the exported bodies (unknown names map to `pass`, which is typed;
    `compare-run`'s `actDefOf` differs only on names that are never called). -/
def relayActDef : String → Stmt String := fun a =>
  (lookup [("read_block", readBlockBody), ("write_block", writeBlockBody), ("relay", relayBody),
    ("relay_raising", relayRaisingBody), ("relay_caught", relayCaughtBody), ("mark", markBody),
    ("relay_seq_relay", relaySeqRelayBody), ("relay_and_mark", relayAndMarkBody),
    ("relay_or_mark", relayOrMarkBody)] a).getD .pass

theorem typed_of_check {ρ : RTy} {body : Stmt String} {τ : Ty}
    (h : (checkS relaySchema relaySig τ (calleeCtxL ρ) body).isSome = true) :
    ∃ Γ', STy (toSchema relaySchema) (toSig relaySig) τ (calleeCtx ρ) body Γ' := by
  obtain ⟨Γ', hΓ'⟩ := isSome_exists h
  refine ⟨toCtx Γ', ?_⟩
  rw [← toCtx_callee]
  exact checkS_sound relaySchema relaySig τ body _ Γ' hΓ'

/-- Every action body of the relay program is well-typed against its signature. -/
theorem relayActs_typed : ActsTyped (toSchema relaySchema) (toSig relaySig) relayActDef := by
  intro a
  -- the nine declared names, then the default
  by_cases h1 : a = "read_block"
  · subst h1; exact typed_of_check readBlock_typed
  by_cases h2 : a = "write_block"
  · subst h2; exact typed_of_check writeBlock_typed
  by_cases h3 : a = "relay"
  · subst h3; exact typed_of_check relay_typed
  by_cases h4 : a = "relay_raising"
  · subst h4; exact typed_of_check relayRaising_typed
  by_cases h5 : a = "relay_caught"
  · subst h5; exact typed_of_check relayCaught_typed
  by_cases h6 : a = "mark"
  · subst h6; exact typed_of_check mark_typed
  by_cases h7 : a = "relay_seq_relay"
  · subst h7; exact typed_of_check relaySeqRelay_typed
  by_cases h8 : a = "relay_and_mark"
  · subst h8; exact typed_of_check relayAndMark_typed
  by_cases h9 : a = "relay_or_mark"
  · subst h9; exact typed_of_check relayOrMark_typed
  · have hd : relayActDef a = .pass := by
      simp [relayActDef, lookup, Ne.symm h1, Ne.symm h2, Ne.symm h3, Ne.symm h4, Ne.symm h5,
        Ne.symm h6, Ne.symm h7, Ne.symm h8, Ne.symm h9]
    rw [hd]
    exact ⟨_, STy.pass⟩

/-- Applicability: any run of the exported `write_block` from a well-typed argument and a
    well-shaped state (all present attributes carry `relaySchema`'s types) ends well-typed or
    fails: `.ret` carries an `int`, `.raise` an exception pair, `.continue` a well-typed env, and
    the state stays well-shaped in every case. -/
theorem writeBlock_preserves (f : Nat) (arg : RVal) (st : St)
    (harg : RVTy (.rpair .ref (.data (.pair .int .int))) arg) (hst : StTy (toSchema relaySchema) st) :
    ∃ Γ', ResTy (toSchema relaySchema) .int (calleeCtx (.rpair .ref (.data (.pair .int .int)))) Γ'
      (interp relayActDef f writeBlockBody (calleeEnv arg) st) := by
  obtain ⟨Γ', hty⟩ := typed_of_check writeBlock_typed
  exact ⟨Γ', preservation relayActDef _ _ relayActs_typed f writeBlockBody _ Γ' .int _ st hty
    (GTy_callee harg) hst⟩

end CalculusTypeCheck
