import CalculusRelaySpec
import ScheduleConsumption
open CalculusNested CalculusExport CalculusBody CalculusSimulation CalculusRelayLoop
  CalculusRelayOuter CalculusRelaySpec

/- Source-only candidate: accepted outer proof extended to retain final schedules.
   Existing repository proof files are unchanged. No acceptance before compiler/audit. -/
namespace CalculusRelaySchedules

structure OuterExactSchedules (st : St) (rc wc : Int) (dv ls : List Int)
    (inp : List UInt8) (rs ws : List Int) : Prop extends
    CalculusRelaySpec.OuterExact st rc wc dv ls inp where
  hrs : getAttrAt .here st "reads" = some (Val.ofIntList rs)
  hws : getAttrAt .here st "writes" = some (Val.ofIntList ws)

set_option maxHeartbeats 4000000 in
/-- One outer iteration, exactly, given the continuation for strictly shorter inputs. -/
theorem relay_outer_schedules_step (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody) (pb : Path) (hpb : pb ≠ .here) (m fuel : Nat)
    (inp : List UInt8)
    (ih : ∀ (mem : MemoryTransfer.Memory 32) (env : Env) (st : St) (inp' : List UInt8)
      (rs ws : List Int) (rc wc : Int) (dv ls : List Int),
      inp'.length < inp.length →
      lookup env "b" = some (.sref pb) → lookup env "σ" = some (.sref .here) →
      getAttrAt pb st "cap" = some (.lit (.int 32)) →
      getAttrAt .here st "reads" = some (Val.ofIntList rs) →
      getAttrAt .here st "writes" = some (Val.ofIntList ws) →
      OuterExact st rc wc dv ls inp' →
      dv.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true →
      ls.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true →
      minInt ≤ rc → rc + ((inp'.length : Int) + 1) ≤ maxInt →
      minInt ≤ wc → wc + (inp'.length : Int) ≤ maxInt →
      ∃ env' st', interp actDef (fuel + 2 * m + 101) relayOuterLoop env st =
          .ret (.lit (.int ((BufferRelay.execute mem inp' rs ws).status : Int))) env' st' ∧
        OuterExactSchedules st' (rc + ((BufferRelay.execute mem inp' rs ws).readCalls : Int))
          (wc + ((BufferRelay.execute mem inp' rs ws).writeCalls : Int))
          (dv ++ toInts (BufferRelay.execute mem inp' rs ws).output)
          (ls ++ toInts (BufferRelay.execute mem inp' rs ws).pending)
          (BufferRelay.execute mem inp' rs ws).remaining
          (ScheduleConsumption.executeI mem inp' rs ws).reads
          (ScheduleConsumption.executeI mem inp' rs ws).writes)
    (mem : MemoryTransfer.Memory 32) (env : Env) (st : St)
    (rs ws : List Int) (rc wc : Int) (dv ls : List Int)
    (hb : lookup env "b" = some (.sref pb)) (hσ : lookup env "σ" = some (.sref .here))
    (hcap : getAttrAt pb st "cap" = some (.lit (.int 32)))
    (hrs : getAttrAt .here st "reads" = some (Val.ofIntList rs))
    (hws : getAttrAt .here st "writes" = some (Val.ofIntList ws))
    (ox : OuterExact st rc wc dv ls inp)
    (hdvb : dv.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hlsb : ls.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true)
    (hrc0 : minInt ≤ rc) (hrcb : rc + ((inp.length : Int) + 1) ≤ maxInt)
    (hwc0 : minInt ≤ wc) (hwcb : wc + (inp.length : Int) ≤ maxInt) :
    ∃ env' st', interp actDef (fuel + 2 * (m + 1) + 101) relayOuterLoop env st =
        .ret (.lit (.int ((BufferRelay.execute mem inp rs ws).status : Int))) env' st' ∧
      OuterExactSchedules st' (rc + ((BufferRelay.execute mem inp rs ws).readCalls : Int))
        (wc + ((BufferRelay.execute mem inp rs ws).writeCalls : Int))
        (dv ++ toInts (BufferRelay.execute mem inp rs ws).output)
        (ls ++ toInts (BufferRelay.execute mem inp rs ws).pending)
        (BufferRelay.execute mem inp rs ws).remaining
        (ScheduleConsumption.executeI mem inp rs ws).reads
        (ScheduleConsumption.executeI mem inp rs ws).writes := by
  have hrc1 : minInt ≤ rc + 1 ∧ rc + 1 ≤ maxInt := ⟨by omega, by omega⟩
  obtain ⟨st1, h1⟩ := setAttrAt_isSome_of_getAttrAt .here st "reads" "reads" _
    (Val.ofIntList rs.tail) hrs
  obtain ⟨st2, h2⟩ := setAttrAt_isSome_of_getAttrAt .here st1 "reads" "read_calls" _
    (.lit (.int (rc + 1))) (setAttrAt_same _ _ _ _ _ h1)
  have fpb2 : ∀ a, getAttrAt pb st2 a = getAttrAt pb st a := fun a => by
    rw [setAttrAt_frame _ _ _ _ _ h2 pb a (Or.inl hpb), setAttrAt_frame _ _ _ _ _ h1 pb a (Or.inl hpb)]
  have fr2 : ∀ a, a ≠ "reads" → a ≠ "read_calls" →
      getAttrAt .here st2 a = getAttrAt .here st a := fun a ha hb => by
    rw [setAttrAt_frame _ _ _ _ _ h2 .here a (Or.inr hb), setAttrAt_frame _ _ _ _ _ h1 .here a (Or.inr ha)]
  have hcall_env_ι : lookup (calleeEnv (.sref pb)) "ι" = some (.sref pb) := by simp [calleeEnv, lookup]
  have hcall_env_σ : lookup (calleeEnv (.sref pb)) "σ" = some (.sref .here) := by simp [calleeEnv, lookup]
  have hctrue : evalExpr env (.lit (.bool true)) = some (.v (.lit (.bool true))) := rfl
  -- the scheduled read count and the rest of the schedule, in `execute`'s vocabulary
  obtain ⟨⟨q, rest⟩, hact⟩ : ∃ p, BufferRelay.action 32 rs = p := ⟨_, rfl⟩
  have hqq : rbQ rs 32 = q := by cases rs <;> simp_all [rbQ, BufferRelay.action]
  have hrest : rs.tail = rest := by cases rs <;> simp_all [BufferRelay.action]
  have hneg : (-1 : Int) < 0 := by decide
  by_cases hq : 0 ≤ q
  · -- non-negative read schedule entry
    have hqneg : ¬ q < 0 := by omega
    have hq' : 0 ≤ rbQ rs 32 := by rw [hqq]; exact hq
    obtain ⟨st3, h3⟩ := setAttrAt_isSome_of_getAttrAt pb st2 "cap" "bytes" _
      (Val.ofIntList ((toInts inp).take (rbK rs 32 (toInts inp)).toNat)) (by rw [fpb2]; exact hcap)
    obtain ⟨st4, h4⟩ := setAttrAt_isSome_of_getAttrAt pb st3 "bytes" "len" _
      (.lit (.int (rbK rs 32 (toInts inp)))) (setAttrAt_same _ _ _ _ _ h3)
    have fr4 : ∀ a, a ≠ "reads" → a ≠ "read_calls" →
        getAttrAt .here st4 a = getAttrAt .here st a := fun a ha hb => by
      rw [setAttrAt_frame _ _ _ _ _ h4 .here a (Or.inl (Ne.symm hpb)),
        setAttrAt_frame _ _ _ _ _ h3 .here a (Or.inl (Ne.symm hpb)), fr2 a ha hb]
    obtain ⟨st5, h5⟩ := setAttrAt_isSome_of_getAttrAt .here st4 "input" "input" _
      (Val.ofIntList ((toInts inp).drop (rbK rs 32 (toInts inp)).toNat))
      (by rw [fr4 "input" (by decide) (by decide)]; exact ox.hinp)
    have fr5 : ∀ a, a ≠ "reads" → a ≠ "read_calls" → a ≠ "input" →
        getAttrAt .here st5 a = getAttrAt .here st a := fun a ha hb hc => by
      rw [setAttrAt_frame _ _ _ _ _ h5 .here a (Or.inr hc), fr4 a ha hb]
    have fpb5 : ∀ a, a ≠ "bytes" → a ≠ "len" → getAttrAt pb st5 a = getAttrAt pb st a :=
      fun a ha hb => by
      rw [setAttrAt_frame _ _ _ _ _ h5 pb a (Or.inl hpb), setAttrAt_frame _ _ _ _ _ h4 pb a (Or.inr hb),
        setAttrAt_frame _ _ _ _ _ h3 pb a (Or.inr ha), fpb2]
    obtain ⟨e, he⟩ := read_block_body_ret actDef (fuel + 2 * m + 2 + 64 + 7) (calleeEnv (.sref pb))
      st st1 st2 st3 st4 st5 pb .here 32 rc rs (toInts inp) hcall_env_ι hcall_env_σ hpb hcap
      (by decide) (by decide) hrs ox.hrc hrc1 ox.hinp (toInts_bytes inp) hq' h1 h2 h3 h4 h5
    have he' : interp actDef (fuel + 2 * (m + 1) + 95) readBlockBody (calleeEnv (.sref pb)) st =
        .ret (.lit (.int (rbK rs 32 (toInts inp)))) e st5 := by
      rw [show fuel + 2 * (m + 1) + 95 = fuel + 2 * m + 2 + 64 + 7 + 24 by omega]; exact he
    -- the read amount as a `Nat`
    have hkN := rbK_eq_readAmount rs inp q (by rw [hact]) hq
    obtain ⟨kN, hkNdef⟩ : ∃ kN : Nat, BufferRelay.readAmount inp q = kN := ⟨_, rfl⟩
    rw [hkNdef] at hkN
    have hkbounds := BufferRelay.readAmount_bounds inp q
    rw [hkNdef] at hkbounds
    have hk0 : 0 ≤ rbK rs 32 (toInts inp) := by rw [hkN]; omega
    -- unfold `execute` one step
    have hex : BufferRelay.execute mem inp rs ws =
        (if _hz : inp = [] then (⟨[], [], [], 0, 1, 0⟩ : BufferRelay.Detailed)
         else
          if (BufferRelay.drain (inp.take kN) ws).failed then
            ⟨(BufferRelay.drain (inp.take kN) ws).output, inp.drop kN,
              (BufferRelay.drain (inp.take kN) ws).pending, 2, 1, (BufferRelay.drain (inp.take kN) ws).calls⟩
          else
            ⟨(BufferRelay.drain (inp.take kN) ws).output ++
                (BufferRelay.execute (BufferRelay.fill mem inp q) (inp.drop kN) rest
                  (BufferRelay.drain (inp.take kN) ws).writes).output,
              (BufferRelay.execute (BufferRelay.fill mem inp q) (inp.drop kN) rest
                (BufferRelay.drain (inp.take kN) ws).writes).remaining,
              (BufferRelay.execute (BufferRelay.fill mem inp q) (inp.drop kN) rest
                (BufferRelay.drain (inp.take kN) ws).writes).pending,
              (BufferRelay.execute (BufferRelay.fill mem inp q) (inp.drop kN) rest
                (BufferRelay.drain (inp.take kN) ws).writes).status,
              (BufferRelay.execute (BufferRelay.fill mem inp q) (inp.drop kN) rest
                (BufferRelay.drain (inp.take kN) ws).writes).readCalls + 1,
              (BufferRelay.drain (inp.take kN) ws).calls +
                (BufferRelay.execute (BufferRelay.fill mem inp q) (inp.drop kN) rest
                  (BufferRelay.drain (inp.take kN) ws).writes).writeCalls⟩) := by
      rw [BufferRelay.execute]
      simp only [hact, show ¬ (q < 0) by omega, if_false, BufferRelay.loaded_eq, hkNdef]
    by_cases hz : inp = []
    · -- end of input: `read_block` returns 0, `relay` returns 0
      subst hz
      have hkz : rbK rs 32 (toInts []) = 0 := by unfold rbK; simp [toInts]; omega
      rw [hex]; simp only [dite_true]
      refine ⟨?e0, st5, ?h0, ?o0⟩
      case h0 =>
        show interp actDef (fuel + 2 * (m + 1) + 100 + 1) relayOuterLoop env st = _
        rw [relayOuterLoop, interp_while_true actDef _ env st _ relayOuterBody hctrue]
        unfold relayOuterBody
        have he'' : interp actDef (fuel + 2 * (m + 1) + 95) readBlockBody (calleeEnv (.sref pb)) st =
            .ret (.lit (.int 0)) e st5 := by rw [← hkz]; exact he'
        simp only [interp_succ_seq, interp_succ_action, interp_succ_assign, interp_succ_cond,
          interp_succ_ret, interp_succ_pass, evalExpr, lookup_assocSet_same,
          hb, hrb, he'', funcDef_lt, funcDef_eq_int, Option.map_some, Int.lt_irrefl,
          decide_true, decide_false]
        rfl
      case o0 =>
        refine { hinp := ?_, hrc := ?_, hwc := ?_, hdv := ?_, hls := ?_, hrs := ?_, hws := ?_ }
        · have := setAttrAt_same _ _ _ _ _ h5; simpa [toInts] using this
        · rw [setAttrAt_frame _ _ _ _ _ h5 .here "read_calls" (Or.inr (by decide)),
            setAttrAt_frame _ _ _ _ _ h4 .here "read_calls" (Or.inl (Ne.symm hpb)),
            setAttrAt_frame _ _ _ _ _ h3 .here "read_calls" (Or.inl (Ne.symm hpb)),
            setAttrAt_same _ _ _ _ _ h2]
          simp
        · rw [fr5 "write_calls" (by decide) (by decide) (by decide), ox.hwc]; simp
        · rw [fr5 "delivered" (by decide) (by decide) (by decide), ox.hdv]; simp [toInts]
        · rw [fr5 "lost" (by decide) (by decide) (by decide), ox.hls]; simp [toInts]
        · rw [ScheduleConsumption.executeI]
          simp only [hact, hqneg, if_false, dite_true]
          rw [setAttrAt_frame _ _ _ _ _ h5 .here "reads" (Or.inr (by decide)),
            setAttrAt_frame _ _ _ _ _ h4 .here "reads" (Or.inl (Ne.symm hpb)),
            setAttrAt_frame _ _ _ _ _ h3 .here "reads" (Or.inl (Ne.symm hpb)),
            setAttrAt_frame _ _ _ _ _ h2 .here "reads" (Or.inr (by decide)), ← hrest]
          exact setAttrAt_same _ _ _ _ _ h1
        · rw [ScheduleConsumption.executeI]
          simp only [hact, hqneg, if_false, dite_true]
          rw [fr5 "writes" (by decide) (by decide) (by decide)]
          exact hws

    · -- a positive read: the inner loop is `drain` on the freshly filled block
      have hkpos : 0 < kN := BufferRelay.readAmount_positive inp q hz |> fun h => by rw [hkNdef] at h; exact h
      have hkposI : 0 < rbK rs 32 (toInts inp) := by rw [hkN]; omega
      have hkz : ¬ (rbK rs 32 (toInts inp) = 0) := by omega
      have hklt : ¬ (rbK rs 32 (toInts inp) < 0) := by omega
      have hblk : (toInts inp).take (rbK rs 32 (toInts inp)).toNat = toInts (inp.take kN) := by
        rw [hkN, Int.toNat_natCast, toInts_take]
      have hblklen : ((inp.take kN).length : Int) = rbK rs 32 (toInts inp) := by
        rw [hkN]; simp only [List.length_take]; omega
      rw [hex]; simp only [hz, dite_false]
      -- inner loop, exactly
      have hinner := relay_inner_exact actDef hwb pb 32 (inp.take kN) (rbK rs 32 (toInts inp))
        hblklen (by rw [hkN]; omega) (by decide) hpb 32 (fuel + 2 * m + 2)
        (assocSet (assocSet (assocSet env "$t17" (.v (.lit (.int (rbK rs 32 (toInts inp))))))
          "r" (.v (.lit (.int (rbK rs 32 (toInts inp)))))) "off" (.v (.lit (.int 0))))
        st5 0 ws dv ls wc
        (by simp [lookup_assocSet_other, hb]) (by simp [lookup_assocSet_other, hσ])
        (lookup_assocSet_same _ _ _) (by simp [lookup_assocSet_other, lookup_assocSet_same])
        (by rw [setAttrAt_frame _ _ _ _ _ h5 pb "len" (Or.inl hpb)]; exact setAttrAt_same _ _ _ _ _ h4)
        (by rw [fpb5 "cap" (by decide) (by decide)]; exact hcap)
        (by rw [setAttrAt_frame _ _ _ _ _ h5 pb "bytes" (Or.inl hpb),
              setAttrAt_frame _ _ _ _ _ h4 pb "bytes" (Or.inr (by decide)), ← hblk]
            exact setAttrAt_same _ _ _ _ _ h3)
        ⟨by rw [fr5 "writes" (by decide) (by decide) (by decide)]; exact hws,
         by rw [fr5 "write_calls" (by decide) (by decide) (by decide)]; exact ox.hwc,
         by rw [fr5 "delivered" (by decide) (by decide) (by decide)]; exact ox.hdv,
         by rw [fr5 "lost" (by decide) (by decide) (by decide)]; exact ox.hls⟩
        hdvb hlsb hwc0 (by rw [hkN]; omega) (Int.le_refl 0) hk0 (by rw [hkN]; omega)
      simp only [Int.toNat_zero, List.drop_zero] at hinner
      obtain ⟨hcont, hfail⟩ := hinner
      -- root attributes read after the inner loop, through `Frame`
      have hrc5 : getAttrAt .here st5 "read_calls" = some (.lit (.int (rc + 1))) := by
        rw [setAttrAt_frame _ _ _ _ _ h5 .here "read_calls" (Or.inr (by decide)),
          setAttrAt_frame _ _ _ _ _ h4 .here "read_calls" (Or.inl (Ne.symm hpb)),
          setAttrAt_frame _ _ _ _ _ h3 .here "read_calls" (Or.inl (Ne.symm hpb))]
        exact setAttrAt_same _ _ _ _ _ h2
      have hrs5 : getAttrAt .here st5 "reads" = some (Val.ofIntList rest) := by
        rw [setAttrAt_frame _ _ _ _ _ h5 .here "reads" (Or.inr (by decide)),
          setAttrAt_frame _ _ _ _ _ h4 .here "reads" (Or.inl (Ne.symm hpb)),
          setAttrAt_frame _ _ _ _ _ h3 .here "reads" (Or.inl (Ne.symm hpb)),
          setAttrAt_frame _ _ _ _ _ h2 .here "reads" (Or.inr (by decide)), ← hrest]
        exact setAttrAt_same _ _ _ _ _ h1
      have hinp5 : getAttrAt .here st5 "input" = some (Val.ofIntList (toInts (inp.drop kN))) := by
        have := setAttrAt_same _ _ _ _ _ h5
        rw [hkN, Int.toNat_natCast] at this; rw [toInts_drop]; exact this
      by_cases hf : (BufferRelay.drain (inp.take kN) ws).failed = true
      · -- write failure: `return 2`
        obtain ⟨e2, s2, hrun, fr, rx'⟩ := hfail hf
        rw [if_pos hf]
        refine ⟨e2, s2, ?_, ?_⟩
        · show interp actDef (fuel + 2 * (m + 1) + 100 + 1) relayOuterLoop env st = _
          rw [relayOuterLoop, interp_while_true actDef _ env st _ relayOuterBody hctrue]
          unfold relayOuterBody
          have hrun' : interp actDef (fuel + 2 * (m + 1) + 94) relayInnerLoop
              (assocSet (assocSet (assocSet env "$t17" (.v (.lit (.int (rbK rs 32 (toInts inp))))))
                "r" (.v (.lit (.int (rbK rs 32 (toInts inp)))))) "off" (.v (.lit (.int 0)))) st5 =
              .ret (.lit (.int 2)) e2 s2 := by
            rw [show fuel + 2 * (m + 1) + 94 = fuel + 2 * m + 2 + 2 * 32 + 30 by omega]; exact hrun
          simp only [interp_succ_seq, interp_succ_action, interp_succ_assign, interp_succ_cond,
            interp_succ_pass, evalExpr, lookup_assocSet_same, hb, hrb, he', funcDef_lt,
            funcDef_eq_int, Option.map_some, decide_false, hklt, hkz, hrun']
          rfl
        · refine { hinp := ?_, hrc := ?_, hwc := ?_, hdv := ?_, hls := ?_, hrs := ?_, hws := ?_ }
          · rw [fr.hother "input" (by decide) (by decide) (by decide) (by decide)]; exact hinp5
          · rw [fr.hother "read_calls" (by decide) (by decide) (by decide) (by decide), hrc5]; simp
          · exact rx'.hwc
          · exact rx'.hdv
          · exact rx'.hls
          · rw [ScheduleConsumption.executeI]
            simp only [hact, hqneg, if_false, hz, dite_false, BufferRelay.loaded_eq,
              hkNdef, hf, if_true]
            rw [fr.hother "reads" (by decide) (by decide) (by decide) (by decide)]
            exact hrs5
          · rw [ScheduleConsumption.executeI]
            simp only [hact, hqneg, if_false, hz, dite_false, BufferRelay.loaded_eq,
              hkNdef, hf, if_true]
            exact rx'.hws

      · -- the block was fully written: continue with the shorter input
        have hf' : (BufferRelay.drain (inp.take kN) ws).failed = false := by
          cases h : (BufferRelay.drain (inp.take kN) ws).failed <;> simp_all
        obtain ⟨e2, s2, hrun, ek, fr, rx'⟩ := hcont hf'
        rw [if_neg hf]
        have hlen_drop : (inp.drop kN).length < inp.length := by
          have := List.length_pos_iff.mpr hz
          simp only [List.length_drop]; omega
        obtain ⟨e3, s3, hrun3, ox3⟩ := ih (BufferRelay.fill mem inp q) e2 s2 (inp.drop kN) rest
          (BufferRelay.drain (inp.take kN) ws).writes (rc + 1)
          (wc + ((BufferRelay.drain (inp.take kN) ws).calls : Int))
          (dv ++ toInts (BufferRelay.drain (inp.take kN) ws).output) ls hlen_drop
          (by rw [ek.hb]; simp [lookup_assocSet_other, hb]) (by rw [ek.hσ]; simp [lookup_assocSet_other, hσ])
          (by rw [fr.hpb, fpb5 "cap" (by decide) (by decide)]; exact hcap)
          (by rw [fr.hother "reads" (by decide) (by decide) (by decide) (by decide)]; exact hrs5)
          rx'.hws
          ⟨by rw [fr.hother "input" (by decide) (by decide) (by decide) (by decide)]; exact hinp5,
           by rw [fr.hother "read_calls" (by decide) (by decide) (by decide) (by decide)]; exact hrc5,
           rx'.hwc, rx'.hdv, rx'.hls⟩
          (by rw [List.all_append, hdvb, toInts_bytes]; rfl) hlsb (by omega)
          (by simp only [List.length_drop]; push_cast; omega) (by omega)
          (by have := (BufferRelay.drain_contract (inp.take kN) ws).2.2
              simp only [List.length_take, List.length_drop] at this ⊢; push_cast; omega)
        refine ⟨e3, s3, ?_, ?_⟩
        · have hrun' : interp actDef (fuel + 2 * (m + 1) + 94) relayInnerLoop
              (assocSet (assocSet (assocSet env "$t17" (.v (.lit (.int (rbK rs 32 (toInts inp))))))
                "r" (.v (.lit (.int (rbK rs 32 (toInts inp)))))) "off" (.v (.lit (.int 0)))) st5 =
              .continue e2 s2 := by
            rw [show fuel + 2 * (m + 1) + 94 = fuel + 2 * m + 2 + 2 * 32 + 30 by omega]; exact hrun
          have hrun3' : interp actDef (fuel + 2 * (m + 1) + 99) relayOuterLoop e2 s2 =
              .ret (.lit (.int ((BufferRelay.execute (BufferRelay.fill mem inp q) (inp.drop kN) rest
                (BufferRelay.drain (inp.take kN) ws).writes).status : Int))) e3 s3 := by
            rw [show fuel + 2 * (m + 1) + 99 = fuel + 2 * m + 101 by omega]; exact hrun3
          -- the body alone continues with `(e2, s2)`; then one more loop unfolding
          have hbody : interp actDef (fuel + 2 * (m + 1) + 99) relayOuterBody env st =
              .continue e2 s2 := by
            unfold relayOuterBody
            simp only [interp_succ_seq, interp_succ_action, interp_succ_assign, interp_succ_cond,
              interp_succ_pass, evalExpr, lookup_assocSet_same, hb, hrb, he', funcDef_lt,
              funcDef_eq_int, Option.map_some, decide_false, hklt, hkz, hrun']
          show interp actDef (fuel + 2 * (m + 1) + 100 + 1) (.while (.lit (.bool true)) relayOuterBody)
            env st = _
          rw [interp_while_true actDef _ env st _ relayOuterBody hctrue]
          show interp actDef (fuel + 2 * (m + 1) + 99 + 1)
            (.seq relayOuterBody (.while (.lit (.bool true)) relayOuterBody)) env st = _
          rw [interp_succ_seq, hbody]
          exact hrun3'
        · refine { hinp := ox3.hinp, hrc := ?_, hwc := ?_, hdv := ?_, hls := ox3.hls, hrs := ?_, hws := ?_ }
          · rw [ox3.hrc]; congr 3; push_cast; omega
          · rw [ox3.hwc]; congr 3; push_cast; omega
          · rw [ox3.hdv, toInts_append, List.append_assoc]
          · rw [ScheduleConsumption.executeI]
            simp only [hact, hqneg, if_false, hz, dite_false, BufferRelay.loaded_eq,
              hkNdef, hf, if_false]
            exact ox3.hrs
          · rw [ScheduleConsumption.executeI]
            simp only [hact, hqneg, if_false, hz, dite_false, BufferRelay.loaded_eq,
              hkNdef, hf, if_false]
            exact ox3.hws

  · -- negative read schedule entry: `read_block` returns `-1`, `relay` returns `1`
    have hq' : rbQ rs 32 < 0 := by rw [hqq]; omega
    obtain ⟨e, he⟩ := read_block_body_neg actDef (fuel + 2 * m + 2 + 64 + 7) (calleeEnv (.sref pb))
      st st1 st2 pb .here 32 rc rs hcall_env_ι hcall_env_σ hcap hrs ox.hrc hrc1 hq' h1 h2
    have he' : interp actDef (fuel + 2 * (m + 1) + 95) readBlockBody (calleeEnv (.sref pb)) st =
        .ret (.lit (.int (-1))) e st2 := by
      rw [show fuel + 2 * (m + 1) + 95 = fuel + 2 * m + 2 + 64 + 7 + 24 by omega]; exact he
    have hex : BufferRelay.execute mem inp rs ws = ⟨[], inp, [], 1, 1, 0⟩ := by
      rw [BufferRelay.execute]; simp only [hact, show q < 0 by omega, if_true]
    rw [hex]
    refine ⟨?e1, st2, ?h1, ?o1⟩
    case h1 =>
      show interp actDef (fuel + 2 * (m + 1) + 100 + 1) relayOuterLoop env st = _
      rw [relayOuterLoop, interp_while_true actDef _ env st _ relayOuterBody hctrue]
      unfold relayOuterBody
      simp only [interp_succ_seq, interp_succ_action, interp_succ_assign, interp_succ_cond,
        interp_succ_ret, evalExpr, lookup_assocSet_same, hb, hrb, he', funcDef_lt, Option.map_some,
        hneg, decide_true]
      rfl
    case o1 =>
      refine { hinp := ?_, hrc := ?_, hwc := ?_, hdv := ?_, hls := ?_, hrs := ?_, hws := ?_ }
      · rw [fr2 "input" (by decide) (by decide)]; exact ox.hinp
      · rw [setAttrAt_same _ _ _ _ _ h2]; simp
      · rw [fr2 "write_calls" (by decide) (by decide), ox.hwc]; simp
      · rw [fr2 "delivered" (by decide) (by decide), ox.hdv]; simp [toInts]
      · rw [fr2 "lost" (by decide) (by decide), ox.hls]; simp [toInts]
      · rw [ScheduleConsumption.executeI]
        simp only [hact, show q < 0 by omega, if_true]
        rw [setAttrAt_frame _ _ _ _ _ h2 .here "reads" (Or.inr (by decide)), ← hrest]
        exact setAttrAt_same _ _ _ _ _ h1
      · rw [ScheduleConsumption.executeI]
        simp only [hact, show q < 0 by omega, if_true]
        rw [fr2 "writes" (by decide) (by decide)]
        exact hws


/-- The outer loop IS `BufferRelay.execute`, for every model memory and every input bound. -/
theorem relay_outer_schedules (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody) (pb : Path) (hpb : pb ≠ .here) :
    ∀ (m fuel : Nat) (mem : MemoryTransfer.Memory 32) (env : Env) (st : St) (inp : List UInt8)
      (rs ws : List Int) (rc wc : Int) (dv ls : List Int),
      inp.length ≤ m →
      lookup env "b" = some (.sref pb) → lookup env "σ" = some (.sref .here) →
      getAttrAt pb st "cap" = some (.lit (.int 32)) →
      getAttrAt .here st "reads" = some (Val.ofIntList rs) →
      getAttrAt .here st "writes" = some (Val.ofIntList ws) →
      OuterExact st rc wc dv ls inp →
      dv.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true →
      ls.all (fun b => decide (0 ≤ b ∧ b ≤ 255)) = true →
      minInt ≤ rc → rc + ((inp.length : Int) + 1) ≤ maxInt →
      minInt ≤ wc → wc + (inp.length : Int) ≤ maxInt →
      ∃ env' st', interp actDef (fuel + 2 * m + 103) relayOuterLoop env st =
          .ret (.lit (.int ((BufferRelay.execute mem inp rs ws).status : Int))) env' st' ∧
        OuterExactSchedules st' (rc + ((BufferRelay.execute mem inp rs ws).readCalls : Int))
          (wc + ((BufferRelay.execute mem inp rs ws).writeCalls : Int))
          (dv ++ toInts (BufferRelay.execute mem inp rs ws).output)
          (ls ++ toInts (BufferRelay.execute mem inp rs ws).pending)
          (BufferRelay.execute mem inp rs ws).remaining
        (ScheduleConsumption.executeI mem inp rs ws).reads
        (ScheduleConsumption.executeI mem inp rs ws).writes := by
  intro m
  induction m with
  | zero =>
    intro fuel mem env st inp rs ws rc wc dv ls hm hb hσ hcap hrs hws ox hdvb hlsb hrc0 hrcb hwc0 hwcb
    -- no strictly shorter input exists: the continuation is vacuous
    have h := relay_outer_schedules_step actDef hwb hrb pb hpb 0 fuel inp
      (fun _ _ _ inp' _ _ _ _ _ _ h => by omega) mem env st rs ws rc wc dv ls
      hb hσ hcap hrs hws ox hdvb hlsb hrc0 hrcb hwc0 hwcb
    rw [show fuel + 2 * 0 + 103 = fuel + 2 * (0 + 1) + 101 by omega]
    exact h
  | succ m ih =>
    intro fuel mem env st inp rs ws rc wc dv ls hm hb hσ hcap hrs hws ox hdvb hlsb hrc0 hrcb hwc0 hwcb
    have h := relay_outer_schedules_step actDef hwb hrb pb hpb (m + 1) fuel inp
      (fun mem' env' st' inp' rs' ws' rc' wc' dv' ls' hm' => by
        have := ih fuel mem' env' st' inp' rs' ws' rc' wc' dv' ls' (by omega)
        rw [show fuel + 2 * m + 103 = fuel + 2 * (m + 1) + 101 by omega] at this
        exact this)
      mem env st rs ws rc wc dv ls hb hσ hcap hrs hws ox hdvb hlsb hrc0 hrcb hwc0 hwcb
    rw [show fuel + 2 * (m + 1) + 103 = fuel + 2 * (m + 1 + 1) + 101 by omega]
    exact h

/-! ## `relay` from `compare-run`'s own initial state, against `BufferRelay.run` -/

/-- `compare-run` builds `initialState (toInts inp) rs ws`; `relay` on it returns exactly
    `BufferRelay.run inp rs ws`'s status and leaves its `output`/`remaining`/counters (and
    `runDetailed`'s `pending` as `lost`) in the state. Premises: only the counter headroom the
    calculus' checked `+ 1` needs. -/
theorem relay_matches_phase3_schedules (actDef : String → Stmt String)
    (hwb : actDef "write_block" = writeBlockBody)
    (hrb : actDef "read_block" = readBlockBody)
    (hrelay : actDef "relay" = relayBody) (fuel : Nat) (inp : List UInt8) (rs ws : List Int)
    (hlen : (inp.length : Int) + 1 ≤ maxInt) :
    ∃ st', runEntry actDef (fuel + 2 * inp.length + 110) "relay" (initialState (toInts inp) rs ws) =
        .continue (assocSet initEnv "rc" (.v (.lit (.int ((BufferRelay.run inp rs ws).status : Int)))))
          st' ∧
      OuterExactSchedules st' ((BufferRelay.run inp rs ws).readCalls : Int)
        ((BufferRelay.run inp rs ws).writeCalls : Int)
        (toInts (BufferRelay.run inp rs ws).output)
        (toInts (BufferRelay.runDetailed inp rs ws).pending)
        (BufferRelay.run inp rs ws).remaining
        (ScheduleConsumption.executeI (fun _ => 0) inp rs ws).reads
        (ScheduleConsumption.executeI (fun _ => 0) inp rs ws).writes := by
  have hminInt : minInt ≤ 0 := by decide
  have hroot : ∀ a, getAttrAt .here (relayPrologueState (initialState (toInts inp) rs ws)) a =
      lookup (initialState (toInts inp) rs ws).attrs a := fun a => rfl
  obtain ⟨env', st', hrun, ox⟩ := relay_outer_schedules actDef hwb hrb blockPath (by decide)
    inp.length fuel (fun _ => 0) relayPrologueEnv
    (relayPrologueState (initialState (toInts inp) rs ws)) inp rs ws 0 0 [] []
    (Nat.le_refl _) (lookup_assocSet_same _ _ _)
    (by simp [relayPrologueEnv, calleeEnv, lookup_assocSet_other, lookup])
    (by simp [blockPath, relayPrologueState, relayBlockInit, getAttrAt, lookup_assocSet_same, lookup])
    (by rw [hroot]; simp [initialState, lookup])
    (by rw [hroot]; simp [initialState, lookup])
    ⟨by rw [hroot]; simp [initialState, lookup], by rw [hroot]; simp [initialState, lookup],
     by rw [hroot]; simp [initialState, lookup], by rw [hroot]; simp [initialState, lookup, Val.ofIntList],
     by rw [hroot]; simp [initialState, lookup, Val.ofIntList]⟩
    rfl rfl hminInt (by omega) hminInt (by omega)
  have hstep : interp actDef (fuel + 2 * inp.length + 109) relayBody (calleeEnv (.v (.lit .unit)))
      (initialState (toInts inp) rs ws) =
      interp actDef (fuel + 2 * inp.length + 103) relayOuterLoop relayPrologueEnv
        (relayPrologueState (initialState (toInts inp) rs ws)) := by
    have h := relay_prologue actDef (fuel + 2 * inp.length + 102) (initialState (toInts inp) rs ws)
    rw [show fuel + 2 * inp.length + 102 + 7 = fuel + 2 * inp.length + 109 by omega,
      show fuel + 2 * inp.length + 102 + 1 = fuel + 2 * inp.length + 103 by omega] at h
    exact h
  refine ⟨st', ?_, ?_⟩
  · unfold runEntry
    rw [show fuel + 2 * inp.length + 110 = (fuel + 2 * inp.length + 109) + 1 by omega,
      interp_succ_action]
    simp only [evalExpr]
    rw [hrelay, hstep, hrun]
    rfl
  · have e1 : ((BufferRelay.run inp rs ws).readCalls : Int) =
        0 + ((BufferRelay.execute (fun _ => 0) inp rs ws).readCalls : Int) := by
      simp [BufferRelay.run, BufferRelay.runDetailed]
    have e2 : ((BufferRelay.run inp rs ws).writeCalls : Int) =
        0 + ((BufferRelay.execute (fun _ => 0) inp rs ws).writeCalls : Int) := by
      simp [BufferRelay.run, BufferRelay.runDetailed]
    have e3 : toInts (BufferRelay.run inp rs ws).output =
        [] ++ toInts (BufferRelay.execute (fun _ => 0) inp rs ws).output := by
      simp [BufferRelay.run, BufferRelay.runDetailed]
    have e4 : toInts (BufferRelay.runDetailed inp rs ws).pending =
        [] ++ toInts (BufferRelay.execute (fun _ => 0) inp rs ws).pending := by
      simp [BufferRelay.runDetailed]
    have e5 : (BufferRelay.run inp rs ws).remaining =
        (BufferRelay.execute (fun _ => 0) inp rs ws).remaining := by
      simp [BufferRelay.run, BufferRelay.runDetailed]
    rw [e1, e2, e3, e4, e5]
    exact ox

/-- Re-express instrumented residual fields using the checked call-count drop laws. -/
theorem OuterExactSchedules.residuals_drop
    (st : St) (rc wc : Int) (dv ls : List Int) (inp : List UInt8)
    (mem : MemoryTransfer.Memory 32) (initial : List UInt8) (rs ws : List Int)
    (h : OuterExactSchedules st rc wc dv ls inp
      (ScheduleConsumption.executeI mem initial rs ws).reads
      (ScheduleConsumption.executeI mem initial rs ws).writes) :
    getAttrAt .here st "reads" = some (Val.ofIntList
      (rs.drop (BufferRelay.execute mem initial rs ws).readCalls)) ∧
    getAttrAt .here st "writes" = some (Val.ofIntList
      (ws.drop (BufferRelay.execute mem initial rs ws).writeCalls)) := by
  constructor
  · simpa only [ScheduleConsumption.executeI_reads_drop, ScheduleConsumption.executeI_proj] using h.hrs
  · simpa only [ScheduleConsumption.executeI_writes_drop, ScheduleConsumption.executeI_proj] using h.hws

#print axioms relay_outer_schedules_step
#print axioms relay_outer_schedules
#print axioms relay_matches_phase3_schedules
#print axioms OuterExactSchedules.residuals_drop

end CalculusRelaySchedules
