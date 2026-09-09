import CalculusTokenize
import CalculusTokenizeTotal

/-!
Kernel-checked copy-equality: CLI `CalculusTokenizeTotal` vs accepted `CalculusTokenize`.
-/

namespace CalculusTokenizeCopyEq

theorem isSpaceT_eq (c : Char) :
    CalculusTokenizeTotal.isSpaceT c = CalculusTokenize.isSpaceT c :=
  rfl

theorem isAtomCharT_eq (c : Char) :
    CalculusTokenizeTotal.isAtomCharT c = CalculusTokenize.isAtomCharT c := by
  simp [CalculusTokenizeTotal.isAtomCharT, CalculusTokenize.isAtomCharT, isSpaceT_eq]

theorem scanStringT_eq (acc : String) (cs : List Char) :
    CalculusTokenizeTotal.scanStringT acc cs = CalculusTokenize.scanStringT acc cs := by
  induction acc, cs using CalculusTokenizeTotal.scanStringT.induct with
  | case1 acc => rfl
  | case2 acc rest => rfl
  | case3 acc c rest ih =>
      simpa [CalculusTokenizeTotal.scanStringT, CalculusTokenize.scanStringT] using ih
  | case4 acc c rest h1 h2 ih =>
      simpa [CalculusTokenizeTotal.scanStringT, CalculusTokenize.scanStringT] using ih

theorem atomT_eq (cs : List Char) :
    CalculusTokenizeTotal.atomT cs = CalculusTokenize.atomT cs := by
  induction cs using CalculusTokenizeTotal.atomT.induct with
  | case1 => rfl
  | case2 c rest htrue a r hpair ih =>
      have hA : CalculusTokenize.isAtomCharT c = true := by
        simpa [isAtomCharT_eq] using htrue
      simp only [CalculusTokenizeTotal.atomT, CalculusTokenize.atomT, htrue, hA]
      exact congrArg (fun p => (c :: p.1, p.2)) ih
  | case3 c rest hfalse =>
      have hT : CalculusTokenizeTotal.isAtomCharT c = false :=
        Bool.eq_false_iff.mpr hfalse
      have hA : CalculusTokenize.isAtomCharT c = false := by
        simpa [isAtomCharT_eq] using hT
      simp only [CalculusTokenizeTotal.atomT, CalculusTokenize.atomT, hT, hA]
      rfl

theorem tokenizeT_eq (fuel : Nat) (cs : List Char) :
    CalculusTokenizeTotal.tokenizeT fuel cs = CalculusTokenize.tokenizeT fuel cs := by
  induction fuel, cs using CalculusTokenizeTotal.tokenizeT.induct with
  | case1 cs => rfl
  | case2 n => rfl
  | case3 fuel rest ih =>
      simpa [CalculusTokenizeTotal.tokenizeT, CalculusTokenize.tokenizeT] using
        congrArg (Option.map (fun x => "(" :: x)) ih
  | case4 fuel rest ih =>
      simpa [CalculusTokenizeTotal.tokenizeT, CalculusTokenize.tokenizeT] using
        congrArg (Option.map (fun x => ")" :: x)) ih
  | case5 fuel rest body rest' hscan ih =>
      have hscan' : CalculusTokenize.scanStringT "" rest = some (body, rest') := by
        simpa [scanStringT_eq] using hscan
      simp only [CalculusTokenizeTotal.tokenizeT, CalculusTokenize.tokenizeT, hscan, hscan']
      exact congrArg (Option.map (fun x => ("\"" ++ body) :: x)) ih
  | case6 fuel rest hscan =>
      have hscan' : CalculusTokenize.scanStringT "" rest = none := by
        simpa [scanStringT_eq] using hscan
      simp only [CalculusTokenizeTotal.tokenizeT, CalculusTokenize.tokenizeT, hscan, hscan']
  | case7 fuel c rest hn1 hn2 hn3 hsp ih =>
      have hspA : CalculusTokenize.isSpaceT c = true := by
        simpa [isSpaceT_eq] using hsp
      simp only [CalculusTokenizeTotal.tokenizeT, CalculusTokenize.tokenizeT]
      simp [hsp, hspA]
      exact ih
  | case8 fuel c rest hn1 hn2 hn3 hnsp a r hatom ih =>
      have hnspA : CalculusTokenize.isSpaceT c = false :=
        Bool.eq_false_iff.mpr (by simpa [isSpaceT_eq] using hnsp)
      have hatomA : CalculusTokenize.atomT rest = (a, r) := by
        simpa [atomT_eq] using hatom
      have hnspT : CalculusTokenizeTotal.isSpaceT c = false :=
        Bool.eq_false_iff.mpr hnsp
      simp only [CalculusTokenizeTotal.tokenizeT, CalculusTokenize.tokenizeT]
      simp [hnspT, hnspA, hatom, hatomA]
      exact congrArg (Option.map (fun x => (String.singleton c ++ String.ofList a) :: x)) ih

theorem tokenizeTotal_eq (s : String) :
    CalculusTokenizeTotal.tokenizeTotal s = CalculusTokenize.tokenizeTotal s := by
  simp [CalculusTokenizeTotal.tokenizeTotal, CalculusTokenize.tokenizeTotal, tokenizeT_eq]

theorem parseText_eq (s : String) :
    CalculusTokenizeTotal.parseText s = CalculusTokenize.parseText s := by
  unfold CalculusTokenizeTotal.parseText CalculusTokenize.parseText
  rw [tokenizeTotal_eq]
  rfl

end CalculusTokenizeCopyEq
