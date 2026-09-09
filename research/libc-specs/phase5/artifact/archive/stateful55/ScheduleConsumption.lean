import BufferRelay

/- Residual protocol schedules. Does not edit BufferRelay.

   Each `action` consumes one supplied event (exhausted lists stay empty).
   `drain.writes = writes.drop drain.calls`. Instrumented `executeI` projects
   to `BufferRelay.execute`; remaining reads/writes are the initial lists
   dropped by the corresponding call counts. -/
namespace ScheduleConsumption

open BufferRelay

theorem action_tail (request : Nat) (xs : List Int) :
    (action request xs).2 = xs.drop 1 := by
  cases xs <;> simp [action]

theorem drain_writes_drop (view : List Byte) (writes : List Int) :
    (drain view writes).writes = writes.drop (drain view writes).calls := by
  induction view, writes using drain.induct with
  | case1 writes => simp [drain]
  | case2 view writes hn q rest ha hq =>
      have ht : rest = writes.drop 1 := by
        have h := action_tail view.length writes
        rw [ha] at h
        exact h
      simp [drain, hn, ha, hq, ht]
  | case3 view writes hn q rest ha hq k ih =>
      have ht : rest = writes.drop 1 := by
        have h := action_tail view.length writes
        rw [ha] at h
        exact h
      rw [drain]
      simp only [hn, ↓reduceDIte, ha, hq, ↓reduceIte]
      dsimp only [k] at ih ⊢
      rw [ih, ht, List.drop_drop, Nat.add_comm]

structure Instrumented where
  d : Detailed
  reads : List Int
  writes : List Int
  deriving Repr, DecidableEq

def executeI (mem : MemoryTransfer.Memory 32) (input : List Byte)
    (reads writes : List Int) : Instrumented :=
  let (q, rest) := action 32 reads
  if q < 0 then
    ⟨⟨[], input, [], 1, 1, 0⟩, rest, writes⟩
  else if _hz : input = [] then
    ⟨⟨[], [], [], 0, 1, 0⟩, rest, writes⟩
  else
    let k := readAmount input q
    let nextMem := fill mem input q
    let dr := drain (loaded mem input q) writes
    if dr.failed then
      ⟨⟨dr.output, input.drop k, dr.pending, 2, 1, dr.calls⟩, rest, dr.writes⟩
    else
      let r := executeI nextMem (input.drop k) rest dr.writes
      ⟨⟨dr.output ++ r.d.output, r.d.remaining, r.d.pending, r.d.status,
          r.d.readCalls + 1, dr.calls + r.d.writeCalls⟩, r.reads, r.writes⟩
termination_by input.length
decreasing_by
  have hp := readAmount_positive input q _hz
  have hl := List.length_pos_iff.mpr _hz
  simp only [List.length_drop]
  omega

theorem executeI_proj (mem : MemoryTransfer.Memory 32) (input : List Byte)
    (reads writes : List Int) :
    (executeI mem input reads writes).d = execute mem input reads writes := by
  induction mem, input, reads, writes using execute.induct with
  | case1 mem input reads writes q rest ha hq =>
      rw [executeI, execute]; simp [ha, hq]
  | case2 mem reads writes q rest ha hq =>
      rw [executeI, execute]; simp [ha, hq]
  | case3 mem input reads writes q rest ha hq hn dr hf =>
      dsimp only [dr] at hf
      rw [executeI, execute]
      simp only [ha, hq, ↓reduceIte, hn, ↓reduceDIte, hf]
  | case4 mem input reads writes q rest ha hq hn k nextMem dr hf ih =>
      dsimp only [dr, k, nextMem] at hf ih
      have hfalse : (drain (loaded mem input q) writes).failed = false := by
        cases hh : (drain (loaded mem input q) writes).failed <;> simp_all
      rw [executeI, execute]
      simp only [ha, hq, ↓reduceIte, hn, ↓reduceDIte, hfalse, Bool.false_eq_true]
      simp [ih]

theorem executeI_reads_drop (mem : MemoryTransfer.Memory 32) (input : List Byte)
    (reads writes : List Int) :
    let r := executeI mem input reads writes
    r.reads = reads.drop r.d.readCalls := by
  induction mem, input, reads, writes using executeI.induct with
  | case1 mem input reads writes q rest ha hq =>
      have ht := action_tail 32 reads
      rw [ha] at ht
      change rest = reads.drop 1 at ht
      simp [executeI, ha, hq, ht]
  | case2 mem reads writes q rest ha hq =>
      have ht := action_tail 32 reads
      rw [ha] at ht
      change rest = reads.drop 1 at ht
      simp [executeI, ha, hq, ht]
  | case3 mem input reads writes q rest ha hq hn dr hf =>
      dsimp only [dr] at hf
      have ht := action_tail 32 reads
      rw [ha] at ht
      change rest = reads.drop 1 at ht
      rw [executeI]
      simp only [ha, hq, ↓reduceIte, hn, ↓reduceDIte, hf]
      simp [ht]
  | case4 mem input reads writes q rest ha hq hn k nextMem dr hf ih =>
      have ht := action_tail 32 reads
      rw [ha] at ht
      change rest = reads.drop 1 at ht
      dsimp only [dr, k, nextMem] at hf ih
      have hfalse : (drain (loaded mem input q) writes).failed = false := by
        cases hh : (drain (loaded mem input q) writes).failed <;> simp_all
      rw [executeI]
      simp only [ha, hq, ↓reduceIte, hn, ↓reduceDIte, hfalse, Bool.false_eq_true]
      rw [ih, ht, List.drop_drop, Nat.add_comm]

theorem executeI_writes_drop (mem : MemoryTransfer.Memory 32) (input : List Byte)
    (reads writes : List Int) :
    let r := executeI mem input reads writes
    r.writes = writes.drop r.d.writeCalls := by
  induction mem, input, reads, writes using executeI.induct with
  | case1 mem input reads writes q rest ha hq =>
      simp [executeI, ha, hq]
  | case2 mem reads writes q rest ha hq =>
      simp [executeI, ha, hq]
  | case3 mem input reads writes q rest ha hq hn dr hf =>
      dsimp only [dr] at hf
      have hw := drain_writes_drop (loaded mem input q) writes
      rw [executeI]
      simp only [ha, hq, ↓reduceIte, hn, ↓reduceDIte, hf]
      simpa using hw
  | case4 mem input reads writes q rest ha hq hn k nextMem dr hf ih =>
      dsimp only [dr, k, nextMem] at hf ih
      have hfalse : (drain (loaded mem input q) writes).failed = false := by
        cases hh : (drain (loaded mem input q) writes).failed <;> simp_all
      have hw := drain_writes_drop (loaded mem input q) writes
      rw [executeI]
      simp only [ha, hq, ↓reduceIte, hn, ↓reduceDIte, hfalse, Bool.false_eq_true]
      rw [ih, hw, List.drop_drop, Nat.add_comm]

theorem execute_reads_drop (mem : MemoryTransfer.Memory 32) (input : List Byte)
    (reads writes : List Int) :
    (executeI mem input reads writes).reads =
      reads.drop (execute mem input reads writes).readCalls := by
  have hp := executeI_proj mem input reads writes
  have hr := executeI_reads_drop mem input reads writes
  simp [hp] at hr
  simpa [hp] using hr

theorem execute_writes_drop (mem : MemoryTransfer.Memory 32) (input : List Byte)
    (reads writes : List Int) :
    (executeI mem input reads writes).writes =
      writes.drop (execute mem input reads writes).writeCalls := by
  have hp := executeI_proj mem input reads writes
  have hw := executeI_writes_drop mem input reads writes
  simp [hp] at hw
  simpa [hp] using hw

theorem runDetailed_reads_drop (input : List Byte) (reads writes : List Int) :
    (executeI (fun _ => 0) input reads writes).reads =
      reads.drop (runDetailed input reads writes).readCalls :=
  execute_reads_drop (fun _ => 0) input reads writes

theorem runDetailed_writes_drop (input : List Byte) (reads writes : List Int) :
    (executeI (fun _ => 0) input reads writes).writes =
      writes.drop (runDetailed input reads writes).writeCalls :=
  execute_writes_drop (fun _ => 0) input reads writes

end ScheduleConsumption
