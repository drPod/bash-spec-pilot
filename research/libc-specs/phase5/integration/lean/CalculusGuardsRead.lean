/-
CalculusGuardsRead.lean (calculus-guards-79, 2026-09-08)

The `read_block` gate: what the exported `read_block` body's guards establish, and — unlike
`write_block` — WHERE they sit.

`readBlockBody` (kernel-identified with the export, -14) has no assertions. Its only guards are
the three `range:0:rangeMax(k)` sinks around the read count `k = rbK rs cap inp =
min (max 1 q) (min cap |input|)`, and they come AFTER the two schedule-bookkeeping writes
(`reads := tail reads`, `read_calls := read_calls + 1`). So:

* the guard fires exactly when `k < 0`, i.e. (given `cap ≤ rangeMax`) exactly when `cap < 0`
  (`rbK_nonneg_iff`): the read-count guard is really a guard on the block's declared-`u64`
  capacity;
* when it fires the result is `.failure` — but the bookkeeping writes have ALREADY happened
  (`read_block_guard_fail` is stated after `st1`/`st2`). `read_block`'s range guard is therefore
  NOT a pre-guard in the sense of `write_block_guard_gate` ("state untouched"); `Res.failure`
  carries no state, so this is only visible in the theorem's hypotheses, and it is recorded here
  because a "guards fail before any write" claim would be FALSE for `read_block`.
* `read_block_body_ret`'s `hcap0 : 0 ≤ cap` is guard-derived (`read_block_guard_gate` drops it);
  `hcapmax : cap ≤ rangeMax` is the declared-width invariant of the `u64` attribute and stays
  imported, as do the counter headroom (`hrc1`, a checked-arithmetic trap, not a guard) and the
  byte-valuedness of `input` (`funcDef` shape traps in `take`/`drop`).

No general no-failure claim.
-/
import CalculusGuards
import CalculusRelayOuter
open CalculusNested CalculusBody CalculusSimulation CalculusRelayOuter CalculusGuards

set_option linter.unusedSimpArgs false

namespace CalculusGuardsRead

/-- The read count is non-negative exactly when the capacity is. -/
theorem rbK_nonneg_iff (rs : List Int) (cap : Int) (inp : List Int) :
    0 ≤ rbK rs cap inp ↔ 0 ≤ cap := by
  unfold rbK; constructor <;> intro h <;> omega

/-- Under the declared width of `cap`, the read count never exceeds `rangeMax`. -/
theorem rbK_le_rangeMax (rs : List Int) (cap : Int) (inp : List Int)
    (hcapmax : cap ≤ 4611686018427387903) : rbK rs cap inp ≤ 4611686018427387903 := by
  unfold rbK; omega

/-- The failing case of `read_block`'s only guard: a non-negative schedule entry, then `k` out of
    `[0, rangeMax]` (which, by `rbK_nonneg_iff`/`rbK_le_rangeMax`, means `cap < 0` for a
    declared-width `cap`). The result is `.failure`, AFTER `reads` and `read_calls` were written
    (`h1`, `h2`). -/
theorem read_block_guard_fail (actDef : String → Stmt String) (fuel : Nat) (env : Env)
    (st st1 st2 : St) (pb pσ : Path) (cap rc : Int) (rs inp : List Int)
    (hι : lookup env "ι" = some (.sref pb))
    (hσ : lookup env "σ" = some (.sref pσ))
    (hpb : pb ≠ pσ)
    (hcap : getAttrAt pb st "cap" = some (.lit (.int cap)))
    (hrs : getAttrAt pσ st "reads" = some (Val.ofIntList rs))
    (hrc : getAttrAt pσ st "read_calls" = some (.lit (.int rc)))
    (hrc1 : minInt ≤ rc + 1 ∧ rc + 1 ≤ maxInt)
    (hinp : getAttrAt pσ st "input" = some (Val.ofIntList inp))
    (hq : 0 ≤ rbQ rs cap)
    (h1 : setAttrAt pσ st "reads" (Val.ofIntList rs.tail) = some st1)
    (h2 : setAttrAt pσ st1 "read_calls" (.lit (.int (rc + 1))) = some st2)
    (hk : ¬ (0 ≤ rbK rs cap inp ∧ rbK rs cap inp ≤ 4611686018427387903)) :
    interp actDef (fuel + 24) readBlockBody env st = .failure := by
  have hcap2 : getAttrAt pb st2 "cap" = some (.lit (.int cap)) := by
    rw [setAttrAt_frame _ _ _ _ _ h2 pb "cap" (Or.inl hpb),
      setAttrAt_frame _ _ _ _ _ h1 pb "cap" (Or.inl hpb)]; exact hcap
  have hrc1' : getAttrAt pσ st1 "read_calls" = some (.lit (.int rc)) := by
    rw [setAttrAt_frame _ _ _ _ _ h1 pσ "read_calls" (Or.inr (by decide))]; exact hrc
  have hinp2 : getAttrAt pσ st2 "input" = some (Val.ofIntList inp) := by
    rw [setAttrAt_frame _ _ _ _ _ h2 pσ "input" (Or.inr (by decide)),
      setAttrAt_frame _ _ _ _ _ h1 pσ "input" (Or.inr (by decide))]; exact hinp
  have hqnn : ¬ (rbQ rs cap < 0) := by omega
  have hK : min (max 1 (rbQ rs cap)) (min cap (inp.length : Int)) = rbK rs cap inp := rfl
  simp only [readBlockBody, interp, evalExpr, lookup_assocSet_same, lookup_assocSet_other,
    hι, hσ, hcap, hrs, h1, h2, hcap2, hrc1', hinp2,
    funcDef_headOr_ofIntList', funcDef_tail_ofIntList, funcDef_add rc 1 hrc1, funcDef_lt,
    funcDef_max, funcDef_min, funcDef_length, hK, range_guard_fail 0 _ (rbK rs cap inp) hk,
    hqnn, decide_false, Option.map, ne_eq, not_false_eq_true, String.reduceEq]

/-- **The `read_block` gate.** `read_block_body_ret` with `hcap0 : 0 ≤ cap` REMOVED: for a
    non-negative schedule entry, either the capacity is negative and the body fails (after the
    bookkeeping writes), or `0 ≤ cap` is DERIVED and the body returns exactly as
    `read_block_body_ret` says. `hcapmax` (declared `u64` width), `hrc1` (counter headroom) and
    `hinpb` (byte-valued input) stay imported: no guard establishes them. -/
theorem read_block_guard_gate (actDef : String → Stmt String) (fuel : Nat) (env : Env)
    (st st1 st2 st3 st4 st5 : St) (pb pσ : Path) (cap rc : Int) (rs inp : List Int)
    (hι : lookup env "ι" = some (.sref pb))
    (hσ : lookup env "σ" = some (.sref pσ))
    (hpb : pb ≠ pσ)
    (hcap : getAttrAt pb st "cap" = some (.lit (.int cap)))
    (hcapmax : cap ≤ 4611686018427387903)
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
    (cap < 0 ∧ interp actDef (fuel + 24) readBlockBody env st = .failure)
    ∨ (0 ≤ cap ∧ ∃ env', interp actDef (fuel + 24) readBlockBody env st =
        .ret (.lit (.int (rbK rs cap inp))) env' st5) := by
  by_cases hcap0 : 0 ≤ cap
  · right
    exact ⟨hcap0, read_block_body_ret actDef fuel env st st1 st2 st3 st4 st5 pb pσ cap rc rs inp
      hι hσ hpb hcap hcap0 hcapmax hrs hrc hrc1 hinp hinpb hq h1 h2 h3 h4 h5⟩
  · left
    refine ⟨by omega, ?_⟩
    apply read_block_guard_fail actDef fuel env st st1 st2 pb pσ cap rc rs inp hι hσ hpb hcap hrs
      hrc hrc1 hinp hq h1 h2
    intro hk
    exact hcap0 ((rbK_nonneg_iff rs cap inp).mp hk.1)

end CalculusGuardsRead
