import MemoryTransfer

/- Restricted relay model. The C-to-Lean boundary is not verified.
   Finite input; actions below -1 and read action 0 are excluded by the CLI.
   Invalid read quotas are totalized to 1; every negative action means error.
   Errors are fail-stop, including EINTR; write zero exits immediately.
   Memory is the phase1 finite allocation, reused across read calls. -/
namespace BufferRelay
abbrev Byte := UInt8

structure Outcome where
  output : List UInt8
  remaining : List UInt8
  status : Nat
  readCalls : Nat
  writeCalls : Nat
  deriving Repr, DecidableEq

def ValidReads (xs : List Int) : Prop := ∀ a ∈ xs, a = -1 ∨ 0 < a
def ValidWrites (xs : List Int) : Prop := ∀ a ∈ xs, -1 ≤ a

/-- Every call consumes an action, with the requested amount as default. -/
def action (request : Nat) : List Int → Int × List Int
  | [] => (Int.ofNat request, [])
  | a :: rest => (a, rest)

structure DrainResult where
  output : List Byte
  pending : List Byte
  writes : List Int
  calls : Nat
  failed : Bool
  deriving Repr, DecidableEq

/-- `view` is the loaded initialized buffer range. Dropping its prefix advances
    the C buffer pointer; see `retry_pointer_load` below. -/
def drain (view : List Byte) (writes : List Int) : DrainResult :=
  if _hz : view = [] then
    ⟨[], [], writes, 0, false⟩
  else
    let (q, rest) := action view.length writes
    if q ≤ 0 then
      ⟨[], view, rest, 1, true⟩
    else
      let k := min q.toNat view.length
      let d := drain (view.drop k) rest
      ⟨view.take k ++ d.output, d.pending, d.writes, d.calls + 1, d.failed⟩
termination_by view.length
decreasing_by
  have hp : 0 < q.toNat := by omega
  have hl : 0 < view.length := List.length_pos_iff.mpr _hz
  simp only [List.length_drop]
  omega

def readAmount (input : List Byte) (q : Int) : Nat :=
  min 32 (min (max 1 q.toNat) input.length)

theorem readAmount_bounds (input : List Byte) (q : Int) :
    readAmount input q ≤ 32 ∧ readAmount input q ≤ input.length := by
  unfold readAmount; omega

theorem readAmount_positive (input : List Byte) (q : Int) (h : input ≠ []) :
    0 < readAmount input q := by
  have := List.length_pos_iff.mpr h
  unfold readAmount; omega

theorem readAmount_valid (input : List Byte) (q : Int) (h : 0 < q) :
    readAmount input q = min 32 (min q.toNat input.length) := by
  have : 0 < q.toNat := by omega
  simp [readAmount, Nat.max_eq_right (by omega : 1 ≤ q.toNat)]

structure Detailed where
  output : List Byte
  remaining : List Byte
  pending : List Byte
  status : Nat
  readCalls : Nat
  writeCalls : Nat
  deriving Repr, DecidableEq

def fill (mem : MemoryTransfer.Memory 32) (input : List Byte) (q : Int) :
    MemoryTransfer.Memory 32 :=
  MemoryTransfer.store mem 0 (input.take (readAmount input q))

def loaded (mem : MemoryTransfer.Memory 32) (input : List Byte) (q : Int) : List Byte :=
  MemoryTransfer.load (fill mem input q) 0 (readAmount input q)
    (by have := (readAmount_bounds input q).1; omega)

theorem loaded_eq (mem : MemoryTransfer.Memory 32) (input : List Byte) (q : Int) :
    loaded mem input q = input.take (readAmount input q) := by
  have hl : (input.take (readAmount input q)).length = readAmount input q := by
    simp [List.length_take, Nat.min_eq_left (readAmount_bounds input q).2]
  simpa only [loaded, fill, hl] using
    MemoryTransfer.load_store mem 0 (input.take (readAmount input q))
      (by rw [hl]; have := (readAmount_bounds input q).1; omega)

/-- Connects the list retry view to a pointer load in the same allocation. -/
theorem retry_pointer_load (mem : MemoryTransfer.Memory size)
    (off n j k : Nat) (hn : off + n ≤ size) (hjk : j + k ≤ n) :
    ((MemoryTransfer.load mem off n hn).drop j).take k =
      MemoryTransfer.load mem (off + j) k (by omega) := by
  apply List.ext_getElem
  · simp only [MemoryTransfer.load, List.length_take, List.length_drop,
      List.length_ofFn]
    omega
  · intro i hi hj
    simp only [MemoryTransfer.load, List.getElem_take, List.getElem_drop,
      List.getElem_ofFn]
    apply congrArg mem
    apply Fin.ext
    simp [Nat.add_assoc]

def execute (mem : MemoryTransfer.Memory 32) (input : List Byte)
    (reads writes : List Int) : Detailed :=
  let (q, rest) := action 32 reads
  if q < 0 then
    ⟨[], input, [], 1, 1, 0⟩
  else if _hz : input = [] then
    ⟨[], [], [], 0, 1, 0⟩
  else
    let k := readAmount input q
    let nextMem := fill mem input q
    let d := drain (loaded mem input q) writes
    if d.failed then
      ⟨d.output, input.drop k, d.pending, 2, 1, d.calls⟩
    else
      let r := execute nextMem (input.drop k) rest d.writes
      ⟨d.output ++ r.output, r.remaining, r.pending, r.status,
        r.readCalls + 1, d.calls + r.writeCalls⟩
termination_by input.length
decreasing_by
  have hp := readAmount_positive input q _hz
  have hl := List.length_pos_iff.mpr _hz
  simp only [List.length_drop]
  omega

def runDetailed (input : List Byte) (reads writes : List Int) : Detailed :=
  execute (fun _ => 0) input reads writes

def run (input : List Byte) (reads writes : List Int) : Outcome :=
  let r := runDetailed input reads writes
  ⟨r.output, r.remaining, r.status, r.readCalls, r.writeCalls⟩

theorem drain_contract (view : List Byte) (writes : List Int) :
    let d := drain view writes
    d.output ++ d.pending = view ∧
    (d.failed = false ↔ d.pending = []) ∧
    d.calls ≤ view.length := by
  induction view, writes using drain.induct with
  | case1 writes => simp [drain]
  | case2 view writes hn q rest ha hq =>
      simp [drain, hn, ha, hq]
      exact List.length_pos_iff.mpr hn
  | case3 view writes hn q rest ha hq k ih =>
      dsimp only [k] at ih
      rw [drain]
      simp only [hn, ↓reduceDIte, ha, hq, ↓reduceIte]
      obtain ⟨hc, hf, hb⟩ := ih
      refine ⟨?_, hf, ?_⟩
      · rw [List.append_assoc, hc, List.take_append_drop]
      · have hp : 0 < q.toNat := by omega
        have hl := List.length_pos_iff.mpr hn
        simp only [List.length_drop] at hb
        omega

theorem drain_success (view : List Byte) (writes : List Int)
    (h : (drain view writes).failed = false) :
    (drain view writes).output = view ∧ (drain view writes).pending = [] := by
  obtain ⟨hc, hf, _⟩ := drain_contract view writes
  have he := hf.mp h
  exact ⟨by simpa [he] using hc, he⟩

theorem drain_failure_pending (view : List Byte) (writes : List Int)
    (h : (drain view writes).failed = true) :
    (drain view writes).pending ≠ [] := by
  intro he
  have := (drain_contract view writes).2.1.mpr he
  simp [h] at this

/-- Whole-execution invariant includes pending memory, which cannot be counted
    as delivered when a later write returns zero or error. -/
theorem execute_contract (mem : MemoryTransfer.Memory 32) (input : List Byte)
    (reads writes : List Int) :
    let r := execute mem input reads writes
    r.output ++ (r.pending ++ r.remaining) = input ∧
    (r.status = 0 → r.pending = [] ∧ r.remaining = []) ∧
    (r.status = 1 → r.pending = []) ∧
    (r.status = 2 → r.pending ≠ []) ∧
    r.status ≤ 2 ∧
    r.readCalls ≤ input.length + 1 ∧ r.writeCalls ≤ input.length := by
  induction mem, input, reads, writes using execute.induct with
  | case1 mem input reads writes q rest ha hq => simp [execute, ha, hq]
  | case2 mem reads writes q rest ha hq => simp [execute, ha, hq]
  | case3 mem input reads writes q rest ha hq hn d hf =>
      dsimp only [d] at hf
      rw [execute]
      simp only [ha, hq, ↓reduceIte, hn, ↓reduceDIte, hf]
      obtain ⟨hc, _, hb⟩ := drain_contract (loaded mem input q) writes
      have hl := loaded_eq mem input q
      refine ⟨?_, by simp, by simp, ?_, by decide, by omega, ?_⟩
      · rw [← List.append_assoc, hc, hl, List.take_append_drop]
      · intro _
        exact drain_failure_pending _ _ hf
      · have hlen : (loaded mem input q).length ≤ input.length := by
          rw [hl, List.length_take]; omega
        omega
  | case4 mem input reads writes q rest ha hq hn k nextMem d hf ih =>
      dsimp only [d, k, nextMem] at hf ih
      rw [execute]
      simp only [ha, hq, ↓reduceIte, hn, ↓reduceDIte, hf, Bool.false_eq_true]
      obtain ⟨hc, h0, h1, h2, hs, hr, hw⟩ := ih
      have hfalse : (drain (loaded mem input q) writes).failed = false := by
        cases hh : (drain (loaded mem input q) writes).failed <;> simp_all
      obtain ⟨hd, _⟩ := drain_success _ _ hfalse
      have hb := (drain_contract (loaded mem input q) writes).2.2
      have hl := loaded_eq mem input q
      refine ⟨?_, h0, h1, h2, hs, ?_, ?_⟩
      · rw [List.append_assoc, hc, hd, hl, List.take_append_drop]
      · have hp := readAmount_positive input q hn
        have hp' := List.length_pos_iff.mpr hn
        simp only [List.length_drop] at hr
        omega
      · have hlen : (loaded mem input q).length ≤ readAmount input q := by
          rw [hl, List.length_take]; omega
        have hk := (readAmount_bounds input q).2
        simp only [List.length_drop] at hw
        omega

/-- Prefix safety holds on every exit, including read errors, write errors, and
    zero writes. It even holds for the explicitly totalized invalid schedules. -/
theorem run_prefix (input : List Byte) (reads writes : List Int) :
    (run input reads writes).output.IsPrefix input := by
  have hc := (execute_contract (fun _ => 0) input reads writes).1
  exact ⟨(runDetailed input reads writes).pending ++
    (runDetailed input reads writes).remaining, hc⟩

theorem run_output_eq_take (input : List Byte) (reads writes : List Int) :
    (run input reads writes).output =
      input.take (run input reads writes).output.length := by
  obtain ⟨suffix, hs⟩ := run_prefix input reads writes
  have ht := congrArg (List.take (run input reads writes).output.length) hs
  simpa only [List.take_append_length] using ht

theorem run_success_exact (input : List Byte) (reads writes : List Int)
    (h : (run input reads writes).status = 0) :
    (run input reads writes).output = input ∧
    (run input reads writes).remaining = [] := by
  obtain ⟨hc, h0, _⟩ := execute_contract (fun _ => 0) input reads writes
  obtain ⟨hp, hr⟩ := h0 h
  exact ⟨by simpa [run, runDetailed, hp, hr] using hc, hr⟩

theorem run_status (input : List Byte) (reads writes : List Int) :
    (run input reads writes).status ≤ 2 :=
  (execute_contract (fun _ => 0) input reads writes).2.2.2.2.1

theorem run_call_bounds (input : List Byte) (reads writes : List Int) :
    (run input reads writes).readCalls ≤ input.length + 1 ∧
    (run input reads writes).writeCalls ≤ input.length :=
  (execute_contract (fun _ => 0) input reads writes).2.2.2.2.2

theorem read_request_valid : MemoryTransfer.Valid 0 32 ⟨0, 0⟩ 32 := by decide

theorem fill_frame (mem : MemoryTransfer.Memory 32) (input : List Byte) (q : Int)
    (i : Fin 32) (h : readAmount input q ≤ i.val) :
    fill mem input q i = mem i := by
  apply MemoryTransfer.store_frame
  right
  simp only [List.length_take]
  omega

theorem write_bounds (n off : Nat) (q : Int) (hn : n ≤ 32) (ho : off < n)
    (hq : 0 < q) :
    let k := min q.toNat (n - off)
    0 < k ∧ k ≤ n - off ∧ off + k ≤ n ∧
    MemoryTransfer.Valid 0 32 ⟨0, off⟩ (n - off) ∧
    n - (off + k) < n - off := by
  have hp : 0 < q.toNat := by omega
  dsimp only [MemoryTransfer.Valid]
  omega

theorem drain_stop (view : List Byte) (writes : List Int) (q : Int)
    (rest : List Int) (hn : view ≠ [])
    (ha : action view.length writes = (q, rest)) (hq : q ≤ 0) :
    drain view writes = ⟨[], view, rest, 1, true⟩ := by
  rw [drain]
  simp [hn, ha, hq]

theorem drain_retry (view : List Byte) (writes : List Int) (q : Int)
    (rest : List Int) (hn : view ≠ [])
    (ha : action view.length writes = (q, rest)) (hq : 0 < q) :
    let k := min q.toNat view.length
    let d := drain (view.drop k) rest
    drain view writes =
      ⟨view.take k ++ d.output, d.pending, d.writes, d.calls + 1, d.failed⟩ := by
  rw [drain]
  simp only [hn, ↓reduceDIte, ha, show ¬q ≤ 0 by omega, ↓reduceIte]

theorem execute_read_error (mem : MemoryTransfer.Memory 32) (input : List Byte)
    (reads writes : List Int) (q : Int) (rest : List Int)
    (ha : action 32 reads = (q, rest)) (hq : q < 0) :
    execute mem input reads writes = ⟨[], input, [], 1, 1, 0⟩ := by
  rw [execute]
  simp [ha, hq]

/-- The final EOF call consumes its action and counts once; a scheduled error
    still wins over EOF, as specified by the adapter. -/
theorem execute_eof (mem : MemoryTransfer.Memory 32) (reads writes : List Int)
    (q : Int) (rest : List Int) (ha : action 32 reads = (q, rest)) (hq : 0 ≤ q) :
    execute mem [] reads writes = ⟨[], [], [], 0, 1, 0⟩ := by
  rw [execute]
  simp [ha, show ¬q < 0 by omega]

theorem execute_write_failure (mem : MemoryTransfer.Memory 32) (input : List Byte)
    (reads writes : List Int) (q : Int) (rest : List Int)
    (ha : action 32 reads = (q, rest)) (hq : 0 ≤ q) (hn : input ≠ [])
    (hf : (drain (loaded mem input q) writes).failed = true) :
    let d := drain (loaded mem input q) writes
    execute mem input reads writes =
      ⟨d.output, input.drop (readAmount input q), d.pending, 2, 1, d.calls⟩ := by
  rw [execute]
  simp only [ha, show ¬q < 0 by omega, ↓reduceIte, hn, ↓reduceDIte, hf]

theorem run_conservation (input : List Byte) (reads writes : List Int) :
    let r := runDetailed input reads writes
    r.output ++ (r.pending ++ r.remaining) = input :=
  (execute_contract (fun _ => 0) input reads writes).1


theorem run_write_failure_residual (input : List Byte) (reads writes : List Int)
    (h : (run input reads writes).status = 2) :
    (runDetailed input reads writes).pending ≠ [] ∧
    (run input reads writes).output.length <
      input.length - (run input reads writes).remaining.length :=

end BufferRelay
