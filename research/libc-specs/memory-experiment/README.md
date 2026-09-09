# Finite byte memory and bounded prefix-transfer experiment

This private, independent experiment supplies the memory step absent from the existing
`WcFromC.lean`: a finite allocated buffer, pointer range checks, a bounded input transfer,
and observable output obtained by loading the bytes back from memory. It uses Lean 4.31.0
and `import Std`, with no Mathlib, custom axioms, `sorry`, or native proof evaluation.
It does not modify or build the shared pipeline.

## Model

`Memory size = Fin size → UInt8` represents the bytes in one finite allocated object.
Pointers carry an abstract block identity and a natural-number byte offset.
`Valid block size p n` requires the right block and `p.offset + n ≤ size`.
The checked `read` operation validates the *whole requested range*, then returns one of:

* `.ub`, for invalid ranges or foreign block identities;
* `.error e s`, preserving state under the chosen no-effect error model;
* `.ok k t`, transferring `k = min request (min quota input.length)` bytes from input to
  memory and consuming exactly that input prefix. Output is unchanged.

The environment chooses an error or a quota, so arbitrary bounded short transfers are
represented. Zero quotas can stall with nonempty input. `emit` appends bytes loaded from
the resulting memory to the observable output. This output operation is idealized and
infallible; it is not a specification of the POSIX `write` system call.

The total internal `store` clips updates to the finite memory domain; public `read`
checks validity first. `load` requires a proof that its requested range is in bounds.
Same-block one-past pointers are accepted for zero bytes; other one-past accesses fail.

## General kernel-checked results

| Declaration | Quantified result |
| --- | --- |
| `store_frame` | Every byte outside an arbitrary written interval is unchanged. |
| `load_store` | Reading back any fitting stored list yields exactly that list. |
| `load_store_disjoint` | Every separately located in-object range retains its complete byte contents. |
| `invalid_is_ub` | An invalid requested range yields UB for every environment choice. |
| `error_preserves_state` | Every valid no-effect error returns the exact initial state. |
| `success_bounds` | Every successful checked call has a valid requested range and count bounded by request and input length. |
| `success_contract` | Every successful checked call loads back the transferred input prefix, consumes precisely it, leaves output untouched, and preserves every byte outside the returned-count interval. |
| `read_emit_observation` / `relay_contract` | Emitting bytes loaded from the resulting memory appends precisely the consumed input prefix. |
| `ready_relay_exists` | Every valid ready call has a successful relay witness; the trace relation is not vacuous. |
| `relays_observation` | **Any finite successful relay trace**, with arbitrary pointers, quotas, short reads, and buffer reuse, appends exactly the original input prefix whose length is the sum of returned counts, leaves precisely the suffix, and cannot consume beyond the input. |
| `relays_conservation` | The sum of returned counts equals bytes appended and bytes consumed; occurrence counts compose for every UInt8, including NUL, newline, and non-ASCII bytes. |

These are general propositions, not finite tests or definitional equalities. The memory
proofs reason about arbitrary indices/ranges; the trace theorem uses induction and
prefix/drop composition. Eight additional concrete kernel-checked regression witnesses
cover binary short reads, input exhaustion, foreign pointers, requested overruns even
when a short transfer would fit, zero/nonzero one-past accesses, and error/UB distinction.

## Reproduce and audit

From the repository root, run:

```sh
uv run --no-project python research/libc-specs/check_experiments.py --only memory
```

This sequentially stages source and compiled dependencies outside the repository, checks all
printed axiom declarations, and records source hashes, toolchain, elapsed time and peak RSS.
See `../data/phase1_results.json` for the integrated run record. The eight concrete memory
regression theorems depend on no axioms.

The proof's trusted boundary is the Lean kernel and definitions supplied here. No
differential test against C or an OS has been performed. There is no C companion yet.

## Boundaries and next experiments

This is a mathematical model of one allocated byte object, **not C semantics**, a C
frontend, a verified translation, or a libc/POSIX conformance proof. The frame is within
one allocation, not a general separation-logic heap frame. Block identities detect
foreign pointers but do not model allocation, deallocation, dangling pointers, alias
provenance, permissions, multiple live objects, or object representations. Natural
offsets/counts do not model machine-integer wraparound. There are no file descriptors,
signals, concurrency, host faults, or real error codes. UB is diagnosed in the model;
this does not assign operational behavior to C UB. Full-request validity before error
selection and unchanged state on errors are deliberate modeling choices.

The trace theorem applies only to finite successful traces. It proves neither progress,
termination, recovery from errors, nor that a C utility cannot reach UB. The quota-zero
case is intentionally visible rather than hidden in a termination assumption.

Next useful steps: (1) bind `read` and `emit` to an explicitly interpreted buffer-using C
subset and prove the utility maintains buffer validity; (2) add a finite multi-block
heap and prove disjoint-allocation framing; (3) replace natural counts with a stated
machine-width overflow policy; (4) build a C differential companion for concrete byte
states and controlled short reads, while preserving the distinction between that
evidence and the kernel-checked model theorems; (5) give output transfers their own
partial-count/error behavior and prove a retry-loop invariant under an explicit progress
assumption.

## Modular-counter refinement companion

`CounterRefinement.lean` is self-contained apart from `import Std`. It represents an
unsigned-style counter as `Fin modulus`, with an arbitrary **positive** modulus. The
executable transition increments modulo that modulus exactly when the next UInt8 is
10, and otherwise preserves the counter. Structural recursion executes this transition
over any finite byte list.

`run_value` proves the final value is `(initial + newlineCount input) % modulus` for
all representable initial counters and all finite inputs. `run_from_nat` establishes
the same formula for any natural initial value normalized to the counter range.
`run_append` proves chunked and whole-input execution reach the same bounded state.
`no_overflow_refinement` and `zero_start_refinement` give equality with unbounded
counting under the explicit condition `initial + newlineCount input < modulus`.

Kernel-checked 8-bit illustrations (`modulus = 256`, initial zero) give 255 after 255
newlines, 0 after 256 newlines, and a theorem that the latter differs from the unbounded
count. These witnesses use the general theorem and the general replicated-list count
lemma, avoiding expensive expansion of the entire interpreted trace. The 8-bit width
is illustrative and is **not** a claim about the width of `size_t` on the host.

`MemoryCounterComposition.lean` imports the two models and proves that any successful
finite memory relay trace has the corresponding modular newline count on its emitted
bytes. With empty initial output and a fitting count, this equals the unbounded count
of the consumed input prefix. This composes byte-memory/stream correctness with the
arithmetic abstraction; it does not extract a C loop or prove C instructions implement
the modular transition.

The same replay command checks the counter and composition modules after the memory module.
The arithmetic proofs use at most `propext`; concrete wrap witnesses additionally use
`Quot.sound`; composition inherits the memory model's permitted standard axioms.

The refinement exposes a remaining condition for relating the earlier unbounded
Int/Nat utility model to an actual unsigned C counter: either a no-overflow precondition
must be proved, or the specification must retain modular behavior. It does not by
itself supply a verified C frontend, prove an ABI width, or verify the semantics of
`size_t` increment instructions. No C differential test was added in this companion.
