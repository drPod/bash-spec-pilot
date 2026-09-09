import CalculusRelayLoop
open CalculusNested CalculusExport CalculusBody CalculusSimulation CalculusRelayLoop

/-!
# CalculusRelayOuter: the REAL exported `read_block` body and `relay`'s outer loop
# (calculus-correspondence-14, 2026-09-08)

Same method as `CalculusBody`: the token list is generated from the current export
(`export_input__byte_relay_exec.tsv`, sha256 `5b3af9ea…`), `readBlock_parse` kernel-checks that
the shared parser maps it to exactly `readBlockBody`, and the whole-body theorems state what
running it does for every fuel/env/state under explicit well-formedness hypotheses. -/

namespace CalculusRelayOuter

def readBlockToks : List String := ["(", "seq", "(", "assign", "b", "ι", ")", "(", "seq", "(", "seq", "(", "get", "$t1", "σ", "reads", ")", "(", "seq", "(", "get", "$t2", "b", "cap", ")", "(", "assign", "q", "(", "head_or", "(", "pair", "$t1", "$t2", ")", ")", ")", ")", ")", "(", "seq", "(", "seq", "(", "get", "$t3", "σ", "reads", ")", "(", "set-attr", "σ", "reads", "(", "tail", "$t3", ")", ")", ")", "(", "seq", "(", "seq", "(", "get", "$t4", "σ", "read_calls", ")", "(", "set-attr", "σ", "read_calls", "(", "+", "(", "pair", "$t4", "1", ")", ")", ")", ")", "(", "seq", "(", "if", "(", "<", "(", "pair", "q", "0", ")", ")", "(", "return", "-1", ")", "pass", ")", "(", "seq", "(", "seq", "(", "get", "$t5", "b", "cap", ")", "(", "seq", "(", "get", "$t6", "σ", "input", ")", "(", "assign", "k", "(", "min", "(", "pair", "(", "max", "(", "pair", "1", "q", ")", ")", "(", "min", "(", "pair", "$t5", "(", "length", "$t6", ")", ")", ")", ")", ")", ")", ")", ")", "(", "seq", "(", "seq", "(", "get", "$t7", "σ", "input", ")", "(", "set-attr", "b", "bytes", "(", "take", "(", "pair", "$t7", "(", "range:0:4611686018427387903", "k", ")", ")", ")", ")", ")", "(", "seq", "(", "set-attr", "b", "len", "(", "range:0:4611686018427387903", "k", ")", ")", "(", "seq", "(", "seq", "(", "get", "$t8", "σ", "input", ")", "(", "set-attr", "σ", "input", "(", "drop", "(", "pair", "$t8", "(", "range:0:4611686018427387903", "k", ")", ")", ")", ")", ")", "(", "return", "k", ")", ")", ")", ")", ")", ")", ")", ")", ")", ")"]

def readBlockBody : Stmt String :=
(.seq
  (.assign "b" (.var "ι"))
  (.seq
    (.seq
      (.get "$t1" (.var "σ") "reads")
      (.seq
        (.get "$t2" (.var "b") "cap")
        (.assign "q" (.fn .headOr (.pair (.var "$t1") (.var "$t2"))))))
    (.seq
      (.seq
        (.get "$t3" (.var "σ") "reads")
        (.setAttr (.var "σ") "reads" (.fn .tail (.var "$t3"))))
      (.seq
        (.seq
          (.get "$t4" (.var "σ") "read_calls")
          (.setAttr (.var "σ") "read_calls" (.fn .add (.pair (.var "$t4") (.lit (.int 1))))))
        (.seq
          (.cond (.fn .lt (.pair (.var "q") (.lit (.int 0))))
            (.ret (.lit (.int (-1))))
            .pass)
          (.seq
            (.seq
              (.get "$t5" (.var "b") "cap")
              (.seq
                (.get "$t6" (.var "σ") "input")
                (.assign "k" (.fn .min (.pair (.fn .max (.pair (.lit (.int 1)) (.var "q"))) (.fn .min (.pair (.var "$t5") (.fn .length (.var "$t6")))))))))
            (.seq
              (.seq
                (.get "$t7" (.var "σ") "input")
                (.setAttr (.var "b") "bytes" (.fn .take (.pair (.var "$t7") (.fn (.range 0 4611686018427387903) (.var "k"))))))
              (.seq
                (.setAttr (.var "b") "len" (.fn (.range 0 4611686018427387903) (.var "k")))
                (.seq
                  (.seq
                    (.get "$t8" (.var "σ") "input")
                    (.setAttr (.var "σ") "input" (.fn .drop (.pair (.var "$t8") (.fn (.range 0 4611686018427387903) (.var "k"))))))
                  (.ret (.var "k")))))))))))

theorem readBlock_parse : parseStmt 400 readBlockToks = some (readBlockBody, []) := by
  decide +kernel
theorem readBlock_render : renderStmtToks readBlockBody = readBlockToks := by
  decide +kernel

/-- `head_or rs d`: the next scheduled read count, or `d` (the block capacity) if none. -/
def rbQ (rs : List Int) (d : Int) : Int :=
  match rs with
  | [] => d
  | x :: _ => x

theorem funcDef_headOr_ofIntList' (rs : List Int) (d : Int) :
    funcDef .headOr (.pair (Val.ofIntList rs) (.lit (.int d))) = some (.lit (.int (rbQ rs d))) := by
  cases rs <;> simp [funcDef, Val.asIntList?_ofIntList, rbQ]
theorem funcDef_max (a b : Int) :
    funcDef .max (.pair (.lit (.int a)) (.lit (.int b))) = some (.lit (.int (max a b))) := by
  simp [funcDef]
theorem funcDef_drop (xs : List Int) (k : Int)
    (hb : xs.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hk : 0 ≤ k ∧ k ≤ (xs.length : Int)) :
    funcDef .drop (.pair (Val.ofIntList xs) (.lit (.int k))) =
      some (Val.ofIntList (xs.drop k.toNat)) := by
  simp [funcDef, Val.asByteList?_ofIntList _ hb, hk]

/-- The amount `read_block` reads: the scheduled count (at least 1), capped by the block
    capacity and by what is left of the input. -/
def rbK (rs : List Int) (cap : Int) (inp : List Int) : Int :=
  min (max 1 (rbQ rs cap)) (min cap (inp.length : Int))

/-- The whole `read_block` body, non-negative schedule entry: reads bookkeeping, then the block
    receives the next `k` input bytes (`bytes`, `len`), the input loses them, `k` is returned.
    The block path `pb` and the root path `pσ` must differ (`hpb`): `read_block` writes both. -/
theorem read_block_body_ret (actDef : String → Stmt String) (fuel : Nat) (env : Env)
    (st st1 st2 st3 st4 st5 : St) (pb pσ : Path) (cap rc : Int) (rs inp : List Int)
    (hι : lookup env "ι" = some (.sref pb))
    (hσ : lookup env "σ" = some (.sref pσ))
    (hpb : pb ≠ pσ)
    (hcap : getAttrAt pb st "cap" = some (.lit (.int cap)))
    (hcap0 : 0 ≤ cap) (hcapmax : cap ≤ 4611686018427387903)
    (hrs : getAttrAt pσ st "reads" = some (Val.ofIntList rs))
    (hrc : getAttrAt pσ st "read_calls" = some (.lit (.int rc)))
    (hrc1 : minInt ≤ rc + 1 ∧ rc + 1 ≤ maxInt)
    (hinp : getAttrAt pσ st "input" = some (Val.ofIntList inp))
    (hinpb : inp.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hq : 0 ≤ rbQ rs cap)
    (h1 : setAttrAt pσ st "reads" (Val.ofIntList rs.tail) = some st1)
    (h2 : setAttrAt pσ st1 "read_calls" (.lit (.int (rc + 1))) = some st2)
    (h3 : setAttrAt pb st2 "bytes" (Val.ofIntList (inp.take (rbK rs cap inp).toNat)) = some st3)
    (h4 : setAttrAt pb st3 "len" (.lit (.int (rbK rs cap inp))) = some st4)
    (h5 : setAttrAt pσ st4 "input" (Val.ofIntList (inp.drop (rbK rs cap inp).toNat)) = some st5) :
    ∃ env', interp actDef (fuel + 24) readBlockBody env st =
      .ret (.lit (.int (rbK rs cap inp))) env' st5 := by
  have hcap2 : getAttrAt pb st2 "cap" = some (.lit (.int cap)) := by
    rw [setAttrAt_frame _ _ _ _ _ h2 pb "cap" (Or.inl hpb),
      setAttrAt_frame _ _ _ _ _ h1 pb "cap" (Or.inl hpb)]; exact hcap
  have hrc1' : getAttrAt pσ st1 "read_calls" = some (.lit (.int rc)) := by
    rw [setAttrAt_frame _ _ _ _ _ h1 pσ "read_calls" (Or.inr (by decide))]; exact hrc
  have hinp2 : getAttrAt pσ st2 "input" = some (Val.ofIntList inp) := by
    rw [setAttrAt_frame _ _ _ _ _ h2 pσ "input" (Or.inr (by decide)),
      setAttrAt_frame _ _ _ _ _ h1 pσ "input" (Or.inr (by decide))]; exact hinp
  have hinp4 : getAttrAt pσ st4 "input" = some (Val.ofIntList inp) := by
    rw [setAttrAt_frame _ _ _ _ _ h4 pσ "input" (Or.inl (Ne.symm hpb)),
      setAttrAt_frame _ _ _ _ _ h3 pσ "input" (Or.inl (Ne.symm hpb))]; exact hinp2
  have hk0 : 0 ≤ rbK rs cap inp ∧ rbK rs cap inp ≤ 4611686018427387903 := by
    unfold rbK; constructor <;> omega
  have hkl : 0 ≤ rbK rs cap inp ∧ rbK rs cap inp ≤ (inp.length : Int) := by
    unfold rbK; constructor <;> omega
  have hqnn : ¬ (rbQ rs cap < 0) := by omega
  have hK : min (max 1 (rbQ rs cap)) (min cap (inp.length : Int)) = rbK rs cap inp := rfl
  refine ⟨?e, ?h⟩
  case h =>
  simp only [readBlockBody, interp, evalExpr, lookup_assocSet_same, lookup_assocSet_other,
    hι, hσ, hcap, hrs, h1, h2, h3, h4, h5, hcap2, hrc1', hinp2, hinp4,
    funcDef_headOr_ofIntList', funcDef_tail_ofIntList, funcDef_add rc 1 hrc1, funcDef_lt,
    funcDef_max, funcDef_min, funcDef_length, hK, funcDef_range (rbK rs cap inp) 0 _ hk0,
    funcDef_take inp _ hinpb hkl, funcDef_drop inp _ hinpb hkl, hqnn, decide_false,
    Option.map_some, ne_eq, not_false_eq_true, String.reduceEq]
  rfl

/-- Negative schedule entry: bookkeeping only, `-1` returned. -/
theorem read_block_body_neg (actDef : String → Stmt String) (fuel : Nat) (env : Env)
    (st st1 st2 : St) (pb pσ : Path) (cap rc : Int) (rs : List Int)
    (hι : lookup env "ι" = some (.sref pb))
    (hσ : lookup env "σ" = some (.sref pσ))
    (hcap : getAttrAt pb st "cap" = some (.lit (.int cap)))
    (hrs : getAttrAt pσ st "reads" = some (Val.ofIntList rs))
    (hrc : getAttrAt pσ st "read_calls" = some (.lit (.int rc)))
    (hrc1 : minInt ≤ rc + 1 ∧ rc + 1 ≤ maxInt)
    (hq : rbQ rs cap < 0)
    (h1 : setAttrAt pσ st "reads" (Val.ofIntList rs.tail) = some st1)
    (h2 : setAttrAt pσ st1 "read_calls" (.lit (.int (rc + 1))) = some st2) :
    ∃ env', interp actDef (fuel + 24) readBlockBody env st = .ret (.lit (.int (-1))) env' st2 := by
  have hrc1' : getAttrAt pσ st1 "read_calls" = some (.lit (.int rc)) := by
    rw [setAttrAt_frame _ _ _ _ _ h1 pσ "read_calls" (Or.inr (by decide))]; exact hrc
  refine ⟨?e, ?h⟩
  case h =>
  simp only [readBlockBody, interp, evalExpr, lookup_assocSet_same, lookup_assocSet_other,
    hι, hσ, hcap, hrs, h1, h2, hrc1',
    funcDef_headOr_ofIntList', funcDef_tail_ofIntList, funcDef_add rc 1 hrc1, funcDef_lt,
    hq, decide_true, Option.map_some, ne_eq, not_false_eq_true, String.reduceEq]
  rfl

/-! ## The outer loop -/

/-- The body of `relay`'s outer `(while true ...)`, exactly as exported (with the inner loop
    as the already-identified `relayInnerLoop`). -/
def relayOuterBody : Stmt String :=
(.seq
                (.seq
                  (.seq
                    (.action "$t17" "read_block" (.var "b"))
                    (.assign "r" (.var "$t17")))
                  (.seq
                    (.cond (.fn .lt (.pair (.var "r") (.lit (.int 0))))
                      (.ret (.lit (.int 1)))
                      .pass)
                    (.seq
                      (.cond (.fn .eq (.pair (.var "r") (.lit (.int 0))))
                        (.ret (.lit (.int 0)))
                        .pass)
                      (.seq
                        (.assign "off" (.lit (.int 0)))
                        relayInnerLoop))))
                .pass)

def relayOuterLoop : Stmt String := .while (.lit (.bool true)) relayOuterBody

/-- `relayBody` (kernel-identified with the export by `relay_parse`) IS the six-statement
    prologue followed by `relayOuterLoop`: definitional. -/
theorem relayBody_eq : relayBody =
(.seq
  (.removeElem (.var "σ") "block" (.lit (.int 0)))
  (.seq
    (.addElem (.var "σ") "block" (.lit (.int 0)))
    (.seq
      (.assign "b" (.elem (.var "σ") "block" (.lit (.int 0))))
      (.seq
        (.setAttr (.var "b") "cap" (.lit (.int 32)))
        (.seq
          (.setAttr (.var "b") "len" (.lit (.int 0)))
          (.seq
            (.setAttr (.var "b") "bytes" (.fn .empty (.lit .unit)))
            relayOuterLoop)))))) := rfl

theorem funcDef_eq_int (a b : Int) :
    funcDef .eq (.pair (.lit (.int a)) (.lit (.int b))) = some (.lit (.bool (decide (a = b)))) := by
  simp [funcDef]

/-- The outer-loop invariant, parameterized by the CURRENT input `inp` (the termination
    measure). `read_calls`/`write_calls` carry the headroom the remaining iterations need. -/
structure OuterInv (pb : Path) (cap : Int) (inp : List Int) (env : Env) (st : St) : Prop where
  hb : lookup env "b" = some (.sref pb)
  hσ : lookup env "σ" = some (.sref .here)
  hpb : pb ≠ .here
  hcap : getAttrAt pb st "cap" = some (.lit (.int cap))
  hcap1 : 1 ≤ cap
  hcapmax : cap ≤ 4611686018427387903
  hrs : ∃ rs : List Int, getAttrAt .here st "reads" = some (Val.ofIntList rs)
  hrc : ∃ rc : Int, getAttrAt .here st "read_calls" = some (.lit (.int rc)) ∧
    minInt ≤ rc ∧ rc + ((inp.length : Int) + 1) ≤ maxInt
  hinp : getAttrAt .here st "input" = some (Val.ofIntList inp)
  hinpb : inp.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true
  hws : ∃ ws : List Int, getAttrAt .here st "writes" = some (Val.ofIntList ws)
  hwc : ∃ wc : Int, getAttrAt .here st "write_calls" = some (.lit (.int wc)) ∧
    minInt ≤ wc ∧ wc + (inp.length : Int) ≤ maxInt
  hdv : ∃ dv : List Int, getAttrAt .here st "delivered" = some (Val.ofIntList dv) ∧
    dv.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true
  hlost : ∃ ls : List Int, getAttrAt .here st "lost" = some (Val.ofIntList ls) ∧
    ls.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true

/-- One outer iteration: either the input strictly shrinks and the loop continues (two fuel
    levels lower) with `OuterInv` re-established, or `relay` returns `0` (end of input), `1`
    (negative read schedule entry) or `2` (a non-positive write). Fuel: `read_block` runs at
    `+31`, the inner loop at `+30` with `2·cap` levels of headroom for its `≤ cap` iterations. -/
theorem relay_outer_step (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody) (fuel : Nat) (env : Env) (st : St)
    (pb : Path) (cap : Int) (inp : List Int) (inv : OuterInv pb cap inp env st) :
    (∃ env' st' inp', interp actDef (fuel + 2 * cap.toNat + 37) relayOuterLoop env st =
        interp actDef (fuel + 2 * cap.toNat + 35) relayOuterLoop env' st' ∧
      OuterInv pb cap inp' env' st' ∧ inp'.length < inp.length) ∨
    (∃ (v : Int) (env' : Env) (st' : St), interp actDef (fuel + 2 * cap.toNat + 37) relayOuterLoop env st =
        .ret (.lit (.int v)) env' st' ∧ (v = 0 ∨ v = 1 ∨ v = 2)) := by
  obtain ⟨rs, hrs⟩ := inv.hrs
  obtain ⟨rc, hrc, hrc0, hrcb⟩ := inv.hrc
  obtain ⟨ws, hws⟩ := inv.hws
  obtain ⟨wc, hwc, hwc0, hwcb⟩ := inv.hwc
  obtain ⟨dv, hdv, hdvb⟩ := inv.hdv
  obtain ⟨ls, hlost, hls⟩ := inv.hlost
  have hcap0 : 0 ≤ cap := by have := inv.hcap1; omega
  have hrc1 : minInt ≤ rc + 1 ∧ rc + 1 ≤ maxInt := ⟨by omega, by omega⟩
  obtain ⟨st1, h1⟩ := setAttrAt_isSome_of_getAttrAt .here st "reads" "reads" _
    (Val.ofIntList rs.tail) hrs
  obtain ⟨st2, h2⟩ := setAttrAt_isSome_of_getAttrAt .here st1 "reads" "read_calls" _
    (.lit (.int (rc + 1))) (setAttrAt_same _ _ _ _ _ h1)
  have fpb1 : ∀ a, getAttrAt pb st1 a = getAttrAt pb st a := fun a =>
    setAttrAt_frame _ _ _ _ _ h1 pb a (Or.inl inv.hpb)
  have fpb2 : ∀ a, getAttrAt pb st2 a = getAttrAt pb st a := fun a => by
    rw [setAttrAt_frame _ _ _ _ _ h2 pb a (Or.inl inv.hpb), fpb1]
  have fr2 : ∀ a, a ≠ "reads" → a ≠ "read_calls" →
      getAttrAt .here st2 a = getAttrAt .here st a := fun a ha hb => by
    rw [setAttrAt_frame _ _ _ _ _ h2 .here a (Or.inr hb),
      setAttrAt_frame _ _ _ _ _ h1 .here a (Or.inr ha)]
  have hcall_env_ι : lookup (calleeEnv (.sref pb)) "ι" = some (.sref pb) := by
    simp [calleeEnv, lookup]
  have hcall_env_σ : lookup (calleeEnv (.sref pb)) "σ" = some (.sref .here) := by
    simp [calleeEnv, lookup]
  have hctrue : evalExpr env (.lit (.bool true)) = some (.v (.lit (.bool true))) := rfl
  by_cases hq : 0 ≤ rbQ rs cap
  · -- non-negative read schedule entry
    obtain ⟨st3, h3⟩ := setAttrAt_isSome_of_getAttrAt pb st2 "cap" "bytes" _
      (Val.ofIntList (inp.take (rbK rs cap inp).toNat)) (by rw [fpb2]; exact inv.hcap)
    obtain ⟨st4, h4⟩ := setAttrAt_isSome_of_getAttrAt pb st3 "bytes" "len" _
      (.lit (.int (rbK rs cap inp))) (setAttrAt_same _ _ _ _ _ h3)
    have fr4 : ∀ a, a ≠ "reads" → a ≠ "read_calls" →
        getAttrAt .here st4 a = getAttrAt .here st a := fun a ha hb => by
      rw [setAttrAt_frame _ _ _ _ _ h4 .here a (Or.inl (Ne.symm inv.hpb)),
        setAttrAt_frame _ _ _ _ _ h3 .here a (Or.inl (Ne.symm inv.hpb)), fr2 a ha hb]
    obtain ⟨st5, h5⟩ := setAttrAt_isSome_of_getAttrAt .here st4 "input" "input" _
      (Val.ofIntList (inp.drop (rbK rs cap inp).toNat))
      (by rw [fr4 "input" (by decide) (by decide)]; exact inv.hinp)
    have fr5 : ∀ a, a ≠ "reads" → a ≠ "read_calls" → a ≠ "input" →
        getAttrAt .here st5 a = getAttrAt .here st a := fun a ha hb hc => by
      rw [setAttrAt_frame _ _ _ _ _ h5 .here a (Or.inr hc), fr4 a ha hb]
    have fpb5 : ∀ a, a ≠ "bytes" → a ≠ "len" → getAttrAt pb st5 a = getAttrAt pb st a :=
      fun a ha hb => by
      rw [setAttrAt_frame _ _ _ _ _ h5 pb a (Or.inl inv.hpb),
        setAttrAt_frame _ _ _ _ _ h4 pb a (Or.inr hb),
        setAttrAt_frame _ _ _ _ _ h3 pb a (Or.inr ha), fpb2]
    obtain ⟨e, he⟩ := read_block_body_ret actDef (fuel + 2 * cap.toNat + 7) (calleeEnv (.sref pb))
      st st1 st2 st3 st4 st5 pb .here cap rc rs inp hcall_env_ι hcall_env_σ inv.hpb inv.hcap hcap0
      inv.hcapmax hrs hrc hrc1 inv.hinp inv.hinpb hq h1 h2 h3 h4 h5
    have he' : interp actDef (fuel + 2 * cap.toNat + 31) readBlockBody (calleeEnv (.sref pb)) st =
        .ret (.lit (.int (rbK rs cap inp))) e st5 := he
    have hk0 : 0 ≤ rbK rs cap inp := by unfold rbK; omega
    have hkcap : rbK rs cap inp ≤ cap := by unfold rbK; omega
    have hkinp : rbK rs cap inp ≤ (inp.length : Int) := by unfold rbK; omega
    have hkl : ((inp.take (rbK rs cap inp).toNat).length : Int) = rbK rs cap inp := by
      simp only [List.length_take]; omega
    by_cases hkz : rbK rs cap inp = 0
    · -- end of input (or a zero-capacity read): `return 0`
      right
      refine ⟨0, ?e0, st5, ?h0, Or.inl rfl⟩
      case h0 =>
      show interp actDef (fuel + 2 * cap.toNat + 36 + 1) relayOuterLoop env st = _
      rw [relayOuterLoop, interp_while_true actDef _ env st _ relayOuterBody hctrue]
      unfold relayOuterBody
      simp only [interp_succ_seq, interp_succ_action, interp_succ_assign, interp_succ_cond,
        interp_succ_ret, interp_succ_pass, evalExpr, lookup_assocSet_same,
        inv.hb, hrb, he', funcDef_lt, funcDef_eq_int, Option.map_some,
        decide_true, decide_false, hkz, Int.lt_irrefl]
      rfl
    · -- a positive read: run the inner loop on the freshly filled block
      have hkpos : 0 < rbK rs cap inp := by omega
      have hklt : ¬ (rbK rs cap inp < 0) := by omega
      have hbs5 : (inp.take (rbK rs cap inp).toNat).all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true :=
        all_take_of_all _ _ inv.hinpb
      have innerInv : InnerInv pb (rbK rs cap inp) cap (inp.take (rbK rs cap inp).toNat)
          (fun a => getAttrAt .here st5 a) (wc + rbK rs cap inp)
          (assocSet (assocSet (assocSet env "$t17" (.v (.lit (.int (rbK rs cap inp)))))
            "r" (.v (.lit (.int (rbK rs cap inp))))) "off" (.v (.lit (.int 0))))
          st5 0 (rbK rs cap inp) :=
        { hb := by simp [lookup_assocSet_other, inv.hb]
          hσ := by simp [lookup_assocSet_other, inv.hσ]
          hoff := lookup_assocSet_same _ _ _
          hr := by simp [lookup_assocSet_other, lookup_assocSet_same]
          hpb := inv.hpb
          hlen := by
            rw [setAttrAt_frame _ _ _ _ _ h5 pb "len" (Or.inl inv.hpb)]
            exact setAttrAt_same _ _ _ _ _ h4
          hcap := by rw [fpb5 "cap" (by decide) (by decide)]; exact inv.hcap
          hbytes := by
            rw [setAttrAt_frame _ _ _ _ _ h5 pb "bytes" (Or.inl inv.hpb),
              setAttrAt_frame _ _ _ _ _ h4 pb "bytes" (Or.inr (by decide))]
            exact setAttrAt_same _ _ _ _ _ h3
          hbs := hbs5
          hbslen := hkl
          hws := ⟨ws, by rw [fr5 "writes" (by decide) (by decide) (by decide)]; exact hws⟩
          hwc := ⟨wc, by rw [fr5 "write_calls" (by decide) (by decide) (by decide)]; exact hwc,
            hwc0, by omega⟩
          hwcmax := by omega
          hother := fun a _ _ _ _ => rfl
          hdv := ⟨dv, by rw [fr5 "delivered" (by decide) (by decide) (by decide)]; exact hdv, hdvb⟩
          hlost := ⟨ls, by rw [fr5 "lost" (by decide) (by decide) (by decide)]; exact hlost, hls⟩
          h0 := Int.le_refl 0
          hor := hk0
          hrl := Int.le_refl _
          hlc := hkcap
          hrmax := by have := inv.hcapmax; omega }
      rcases relay_inner_loop_terminates_any_fuel actDef hwb (fuel + 2 * cap.toNat + 30) _ st5 pb
          (rbK rs cap inp) cap (inp.take (rbK rs cap inp).toNat) (fun a => getAttrAt .here st5 a)
          (wc + rbK rs cap inp) 0 (rbK rs cap inp) innerInv (by omega)
        with ⟨e2, s2, hrun, inv2⟩ | ⟨e2, s2, hrun⟩
      · -- the block was fully written: the outer loop continues with the shorter input
        left
        refine ⟨e2, s2, inp.drop (rbK rs cap inp).toNat, ?_, ?_, ?_⟩
        · show interp actDef (fuel + 2 * cap.toNat + 36 + 1) relayOuterLoop env st = _
          rw [relayOuterLoop, interp_while_true actDef _ env st _ relayOuterBody hctrue]
          unfold relayOuterBody
          simp only [interp_succ_seq, interp_succ_action, interp_succ_assign, interp_succ_cond,
            interp_succ_pass, evalExpr, lookup_assocSet_same,
            inv.hb, hrb, he', funcDef_lt, funcDef_eq_int, Option.map_some,
            decide_false, hklt, hkz, hrun]
        · obtain ⟨wc2, hwc2, hwc20, hwc2b⟩ := inv2.hwc
          exact {
            hb := inv2.hb
            hσ := inv2.hσ
            hpb := inv.hpb
            hcap := inv2.hcap
            hcap1 := inv.hcap1
            hcapmax := inv.hcapmax
            hrs := ⟨rs.tail, by
              rw [inv2.hother "reads" (by decide) (by decide) (by decide) (by decide)]
              show getAttrAt .here st5 "reads" = _
              rw [setAttrAt_frame _ _ _ _ _ h5 .here "reads" (Or.inr (by decide)),
                setAttrAt_frame _ _ _ _ _ h4 .here "reads" (Or.inl (Ne.symm inv.hpb)),
                setAttrAt_frame _ _ _ _ _ h3 .here "reads" (Or.inl (Ne.symm inv.hpb)),
                setAttrAt_frame _ _ _ _ _ h2 .here "reads" (Or.inr (by decide))]
              exact setAttrAt_same _ _ _ _ _ h1⟩
            hrc := ⟨rc + 1, by
              rw [inv2.hother "read_calls" (by decide) (by decide) (by decide) (by decide)]
              show getAttrAt .here st5 "read_calls" = _
              rw [setAttrAt_frame _ _ _ _ _ h5 .here "read_calls" (Or.inr (by decide)),
                setAttrAt_frame _ _ _ _ _ h4 .here "read_calls" (Or.inl (Ne.symm inv.hpb)),
                setAttrAt_frame _ _ _ _ _ h3 .here "read_calls" (Or.inl (Ne.symm inv.hpb))]
              exact setAttrAt_same _ _ _ _ _ h2, by omega, by
              simp only [List.length_drop]; omega⟩
            hinp := by
              rw [inv2.hother "input" (by decide) (by decide) (by decide) (by decide)]
              exact setAttrAt_same _ _ _ _ _ h5
            hinpb := all_drop_of_all _ _ inv.hinpb
            hws := inv2.hws
            hwc := ⟨wc2, hwc2, hwc20, by simp only [List.length_drop]; omega⟩
            hdv := inv2.hdv
            hlost := inv2.hlost }
        · simp only [List.length_drop]; omega
      · right
        refine ⟨2, e2, s2, ?_, Or.inr (Or.inr rfl)⟩
        show interp actDef (fuel + 2 * cap.toNat + 36 + 1) relayOuterLoop env st = _
        rw [relayOuterLoop, interp_while_true actDef _ env st _ relayOuterBody hctrue]
        unfold relayOuterBody
        simp only [interp_succ_seq, interp_succ_action, interp_succ_assign, interp_succ_cond,
          interp_succ_pass, evalExpr, lookup_assocSet_same,
          inv.hb, hrb, he', funcDef_lt, funcDef_eq_int, Option.map_some,
          decide_false, hklt, hkz, hrun]
  · -- negative read schedule entry: `read_block` returns `-1`, `relay` returns `1`
    obtain ⟨e, he⟩ := read_block_body_neg actDef (fuel + 2 * cap.toNat + 7) (calleeEnv (.sref pb))
      st st1 st2 pb .here cap rc rs hcall_env_ι hcall_env_σ inv.hcap hrs hrc hrc1 (by omega) h1 h2
    have he' : interp actDef (fuel + 2 * cap.toNat + 31) readBlockBody (calleeEnv (.sref pb)) st =
        .ret (.lit (.int (-1))) e st2 := he
    have hneg : (-1 : Int) < 0 := by decide
    right
    refine ⟨1, ?e1, st2, ?h1, Or.inr (Or.inl rfl)⟩
    case h1 =>
    show interp actDef (fuel + 2 * cap.toNat + 36 + 1) relayOuterLoop env st = _
    rw [relayOuterLoop, interp_while_true actDef _ env st _ relayOuterBody hctrue]
    unfold relayOuterBody
    simp only [interp_succ_seq, interp_succ_action, interp_succ_assign, interp_succ_cond,
      interp_succ_ret, evalExpr, lookup_assocSet_same,
      inv.hb, hrb, he', funcDef_lt, Option.map_some, hneg, decide_true]
    rfl

/-- The input-bounded run of the outer loop: with `m ≥ |input|`, `relay`'s loop returns `0`,
    `1` or `2` within `2·m + 2·cap + 37` fuel above any base. -/
theorem relay_outer_loop_run (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody) (pb : Path) (cap : Int) :
    ∀ (m fuel : Nat) (env : Env) (st : St) (inp : List Int), OuterInv pb cap inp env st →
      inp.length ≤ m →
      ∃ (v : Int) (env' : Env) (st' : St), interp actDef (fuel + 2 * m + 2 * cap.toNat + 37) relayOuterLoop env st =
        .ret (.lit (.int v)) env' st' ∧ (v = 0 ∨ v = 1 ∨ v = 2) := by
  intro m
  induction m with
  | zero =>
    intro fuel env st inp inv hm
    rcases relay_outer_step actDef hwb hrb (fuel + 2 * 0) env st pb cap inp inv
      with ⟨_, _, inp', _, _, hlt⟩ | ⟨v, env', st', hret, hv⟩
    · omega
    · exact ⟨v, env', st', hret, hv⟩
  | succ m ih =>
    intro fuel env st inp inv hm
    rcases relay_outer_step actDef hwb hrb (fuel + 2 * m + 2) env st pb cap inp inv
      with ⟨env', st', inp', hstep, inv', hlt⟩ | ⟨v, env', st', hret, hv⟩
    · rw [show fuel + 2 * (m + 1) + 2 * cap.toNat + 37 = (fuel + 2 * m + 2) + 2 * cap.toNat + 37
        by omega, hstep, show fuel + 2 * m + 2 + 2 * cap.toNat + 35 = fuel + 2 * m + 2 * cap.toNat + 37
        by omega]
      exact ih fuel env' st' inp' inv' (by omega)
    · rw [show fuel + 2 * (m + 1) + 2 * cap.toNat + 37 = (fuel + 2 * m + 2) + 2 * cap.toNat + 37
        by omega, hret]
      exact ⟨v, env', st', rfl, hv⟩

/-- Termination of `relay`'s outer loop, stated directly: `|input|` iterations suffice. -/
theorem relay_outer_loop_terminates (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody) (fuel : Nat) (env : Env) (st : St)
    (pb : Path) (cap : Int) (inp : List Int) (inv : OuterInv pb cap inp env st) :
    ∃ (v : Int) (env' : Env) (st' : St),
      interp actDef (fuel + 2 * inp.length + 2 * cap.toNat + 37) relayOuterLoop env st =
        .ret (.lit (.int v)) env' st' ∧ (v = 0 ∨ v = 1 ∨ v = 2) :=
  relay_outer_loop_run actDef hwb hrb pb cap inp.length fuel env st inp inv (Nat.le_refl _)

/-! ## `relay` from its entry point

`runEntry actDef fuel "relay" st` (the very call `compare-run`/`export-run` make) runs the real
six-statement prologue — clear/create the `block` element, bind `b`, set `cap := 32`,
`len := 0`, `bytes := []` — and then `relayOuterLoop`. The state is only required to carry the
seven root attributes `cb_main.ml`'s `initial_state` builds (`input`, `delivered`, `lost`,
`reads`, `writes`, `read_calls`, `write_calls`), with byte-valued lists where the program reads
bytes and counter headroom for the run; `initialState` in `CompareMain.lean` satisfies all of it
with counters `0`. -/

theorem assocSet_assocSet_same {α β : Type} [DecidableEq α] (l : List (α × β)) (k : α) (x y : β) :
    assocSet (assocSet l k x) k y = assocSet l k y := by
  induction l with
  | nil => simp [assocSet]
  | cons kx rest ih =>
    obtain ⟨k', x'⟩ := kx
    by_cases h : k' = k
    · subst h; simp [assocSet]
    · simp [assocSet, h, ih]

/-- `b` after the prologue: the fresh `block(0)` element of the root. -/
def blockPath : Path := .nested "block" (.lit (.int 0)) .here
/-- The block as the prologue initializes it. -/
def relayBlockInit : St :=
  .mk [("cap", .lit (.int 32)), ("len", .lit (.int 0)), ("bytes", .lit .unit)] []
/-- The state after the prologue: root attributes untouched, `block(0)` re-created and
    initialized (any previous `block(0)` element is dropped first, as the export says). -/
def relayPrologueState (st : St) : St :=
  .mk st.attrs (assocSet (assocRemove st.elems ("block", .lit (.int 0))) ("block", .lit (.int 0))
    relayBlockInit)
def relayPrologueEnv : Env := assocSet (calleeEnv (.v (.lit .unit))) "b" (.sref blockPath)

set_option maxHeartbeats 1000000 in
/-- The prologue, evaluated symbolically over the state's own attribute/element lists. -/
theorem relay_prologue (actDef : String → Stmt String) (n : Nat) (st : St) :
    interp actDef (n + 7) relayBody (calleeEnv (.v (.lit .unit))) st =
      interp actDef (n + 1) relayOuterLoop relayPrologueEnv (relayPrologueState st) := by
  rw [relayBody_eq]
  simp only [interp_succ_seq, interp_succ_removeElem, interp_succ_addElem, interp_succ_assign,
    interp_succ_setAttr, evalExpr, calleeEnv, lookup, lookup_assocSet_same,
    removeElemAt, addElemAt, setAttrAt, Path.snoc, St.mk_attrs, St.mk_elems, St.empty,
    lookup_assocRemove_same, assocSet_assocSet_same, funcDef, Val.ofIntList, Option.map_some,
    String.reduceEq, ↓reduceIte, relayPrologueEnv, relayPrologueState,
    relayBlockInit, blockPath, assocSet]

set_option maxHeartbeats 1000000 in
theorem relay_terminates (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody)
    (hrelay : actDef "relay" = relayBody) (fuel : Nat) (st : St)
    (inp rs ws dv ls : List Int) (rc wc : Int)
    (hinp : lookup st.attrs "input" = some (Val.ofIntList inp))
    (hinpb : inp.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hrs : lookup st.attrs "reads" = some (Val.ofIntList rs))
    (hrc : lookup st.attrs "read_calls" = some (.lit (.int rc)))
    (hrc0 : minInt ≤ rc) (hrcb : rc + ((inp.length : Int) + 1) ≤ maxInt)
    (hws : lookup st.attrs "writes" = some (Val.ofIntList ws))
    (hwc : lookup st.attrs "write_calls" = some (.lit (.int wc)))
    (hwc0 : minInt ≤ wc) (hwcb : wc + (inp.length : Int) ≤ maxInt)
    (hdv : lookup st.attrs "delivered" = some (Val.ofIntList dv))
    (hdvb : dv.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hls : lookup st.attrs "lost" = some (Val.ofIntList ls))
    (hlsb : ls.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true) :
    ∃ (v : Int) (st' : St),
      runEntry actDef (fuel + 2 * inp.length + 108) "relay" st =
        .continue (assocSet initEnv "rc" (.v (.lit (.int v)))) st' ∧ (v = 0 ∨ v = 1 ∨ v = 2) := by
  have hroot : ∀ a, getAttrAt .here (relayPrologueState st) a = lookup st.attrs a := fun a => rfl
  have outerInv : OuterInv blockPath 32 inp relayPrologueEnv (relayPrologueState st) :=
    { hb := lookup_assocSet_same _ _ _
      hσ := by simp [relayPrologueEnv, calleeEnv, lookup_assocSet_other, lookup]
      hpb := by decide
      hcap := by
        simp [blockPath, relayPrologueState, relayBlockInit, getAttrAt, lookup_assocSet_same, lookup]
      hcap1 := by decide
      hcapmax := by decide
      hrs := ⟨rs, by rw [hroot]; exact hrs⟩
      hrc := ⟨rc, by rw [hroot]; exact hrc, hrc0, hrcb⟩
      hinp := by rw [hroot]; exact hinp
      hinpb := hinpb
      hws := ⟨ws, by rw [hroot]; exact hws⟩
      hwc := ⟨wc, by rw [hroot]; exact hwc, hwc0, hwcb⟩
      hdv := ⟨dv, by rw [hroot]; exact hdv, hdvb⟩
      hlost := ⟨ls, by rw [hroot]; exact hls, hlsb⟩ }
  obtain ⟨v, env', st', hrun, hv⟩ := relay_outer_loop_terminates actDef hwb hrb
    fuel relayPrologueEnv (relayPrologueState st) blockPath 32 inp outerInv
  have hrun' : interp actDef (fuel + 2 * inp.length + 101) relayOuterLoop relayPrologueEnv
      (relayPrologueState st) = .ret (.lit (.int v)) env' st' := by
    rw [show (32 : Int).toNat = 32 from rfl,
      show fuel + 2 * inp.length + 2 * 32 + 37 = fuel + 2 * inp.length + 101 by omega] at hrun
    exact hrun
  have hstep : interp actDef (fuel + 2 * inp.length + 107) relayBody (calleeEnv (.v (.lit .unit))) st =
      interp actDef (fuel + 2 * inp.length + 101) relayOuterLoop relayPrologueEnv
        (relayPrologueState st) := by
    have h := relay_prologue actDef (fuel + 2 * inp.length + 100) st
    rw [show fuel + 2 * inp.length + 100 + 7 = fuel + 2 * inp.length + 107 by omega,
      show fuel + 2 * inp.length + 100 + 1 = fuel + 2 * inp.length + 101 by omega] at h
    exact h
  have heq : runEntry actDef (fuel + 2 * inp.length + 108) "relay" st =
      .continue (assocSet initEnv "rc" (.v (.lit (.int v)))) st' := by
    unfold runEntry
    rw [show fuel + 2 * inp.length + 108 = (fuel + 2 * inp.length + 107) + 1 by omega,
      interp_succ_action]
    simp only [evalExpr]
    rw [hrelay, hstep, hrun']
  exact ⟨v, st', heq, hv⟩

/-! ## The syntactic `Stmt.WF` predicate, instantiated on the real exports

`CalculusExport.Stmt.WF` is the well-formedness side condition of the general parse/render
round-trip theorems (`parseStmt_render`/`round_trip_stmt`). Until now it had only been used
abstractly. The three theorems below establish it for the exported bodies themselves (kernel
evaluation of the ~300 decidable atoms each), so the GENERAL round-trip theorem applies to
these concrete programs — a second, independent route to the parse identities
`writeBlock_parse`/`relay_parse`/`readBlock_parse`, this time through the ∀-quantified theorem
rather than direct evaluation. What this does NOT do: give a `Stmt.WF`-style precondition under
which the whole-body/loop theorems above apply to an ARBITRARY export — that remains open (see
the README's obligations). -/

set_option synthInstance.maxSize 2000000 in
set_option synthInstance.maxHeartbeats 2000000 in
set_option maxHeartbeats 4000000 in
theorem writeBlockBody_WF : writeBlockBody.WF := by
  unfold writeBlockBody; simp only [Stmt.WF, Expr.WF]; decide +kernel

set_option synthInstance.maxSize 2000000 in
set_option synthInstance.maxHeartbeats 2000000 in
set_option maxHeartbeats 4000000 in
theorem readBlockBody_WF : readBlockBody.WF := by
  unfold readBlockBody; simp only [Stmt.WF, Expr.WF]; decide +kernel

set_option synthInstance.maxSize 2000000 in
set_option synthInstance.maxHeartbeats 2000000 in
set_option maxHeartbeats 4000000 in
theorem relayBody_WF : relayBody.WF := by
  rw [relayBody_eq]; unfold relayOuterLoop relayOuterBody relayInnerLoop relayInnerBody
  simp only [Stmt.WF, Expr.WF]; decide +kernel

theorem writeBlock_round_trip :
    parseStmt (fuelOfStmt writeBlockBody) (renderStmtToks writeBlockBody) =
      some (writeBlockBody, []) :=
  round_trip_stmt writeBlockBody writeBlockBody_WF
theorem readBlock_round_trip :
    parseStmt (fuelOfStmt readBlockBody) (renderStmtToks readBlockBody) =
      some (readBlockBody, []) :=
  round_trip_stmt readBlockBody readBlockBody_WF
theorem relay_round_trip :
    parseStmt (fuelOfStmt relayBody) (renderStmtToks relayBody) = some (relayBody, []) :=
  round_trip_stmt relayBody relayBody_WF

end CalculusRelayOuter
