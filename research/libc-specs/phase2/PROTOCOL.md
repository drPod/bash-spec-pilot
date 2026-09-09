# Buffer relay protocol and proof boundary

Define the scheduled I/O protocol and Lean proof boundary for a 32-byte relay loop.

The model retries positive short writes until the current read chunk is drained, then reads again. Status 1 is read error; status 2 is a nonpositive write; status 0 is EOF after draining previous chunks.

`relay.c` is a small local-stage experiment, not GNU cat. C translation, native runtime, and later script composition (see [`../phase5/evaluation/DRAFT-PAPER.md`](../phase5/evaluation/DRAFT-PAPER.md)) are outside this protocol.

## Deterministic primitive environment

Input is a finite immutable `List UInt8`; logical input and output channels are independent.
Each call consumes the next scheduled action. Exhausted schedules default to the full request.

| Operation | Action | Result/effect |
|---|---|---|
| read of 32 bytes | -1 | Error, no transfer; precedes the EOF test |
| read of 32 bytes | positive q | Store and consume min(q,32,unread length); zero only at EOF |
| write of residual bytes | -1 | Error, no delivery |
| write of residual bytes | 0 | No delivery; relay exits status 2 |
| write of residual bytes | positive q | Deliver min(q,residual length) bytes; retry residual |

Read action 0 and values below -1 are invalid external schedules. The mathematical function
is total on arbitrary integer lists: it maps read 0 to quota 1 and all negatives to error.
No C/CLI correspondence is claimed for those totalized invalid inputs. `ValidReads` and
`ValidWrites` record the valid domain; `readAmount_valid` proves the positive quota formula.

These assumptions deliberately specialize [POSIX.1-2024 read](https://pubs.opengroup.org/onlinepubs/9799919799/functions/read.html)
and [write](https://pubs.opengroup.org/onlinepubs/9799919799/functions/write.html). Those interfaces
allow positive short transfers and distinguish interruption before versus after transfer.
Here all errors fail immediately, including an abstracted EINTR; no errno or retry policy
is modeled. POSIX does not warrant universal no-effect failures (its rationale leaves
post-error offsets unspecified). Blocking, SIGPIPE, descriptor aliasing/types/flags,
concurrent writers, mutable or infinite input, delayed errors and durability are omitted.
A zero write result is treated defensively as failure, not as EOF or EAGAIN. Arbitrary
quota schedules are not asserted to be realizable by every kind of POSIX descriptor.

## Checked model

`BufferRelay.execute` reuses a `Fin 32 → UInt8` allocation from phase1 `MemoryTransfer`.
A successful read stores into it; output originates in a load of the initialized range.
The inner drain operates on that loaded immutable byte list. Theorems establish:

- `run_conservation`: delivered ++ pending ++ unread = original input on every exit.
- `run_prefix` / `run_output_eq_take`: output is precisely an original-input prefix.
- `run_success_exact`: status 0 implies full output and empty unread input.
- `run_positive_success`: every finite input and positive schedules terminate successfully;
  empty schedules satisfy this premise. The success claim is therefore not vacuous.
- `run_write_failure_residual`: status 2 retains a nonempty pending suffix; read consumption
  strictly exceeds delivered length. Status 1 has no pending buffer residual.
- `run_call_bounds`: reads ≤ input length + 1 and writes ≤ input length, including terminal
  calls. Well-founded recursion decreases unread or pending length; there is no fuel failure.
- `read_matches_phase1`, `loaded_eq`, `fill_frame`, `retry_pointer_load`, and `write_bounds`:
  positive-read, memory readback/frame, local slice-to-pointer-load and range/progress lemmas.

The pointer bridge is **local**. There is no execution-indexed trace refinement proving that
every list-drain step implements a pointer-machine write step (that is a later phase3 obligation).
There is no C memory, cast, compiler or runtime preservation theorem. The full array request is checked locally, and
untouched cells are preserved; uninitialized-cell tags, allocation lifetime/provenance,
shared memory and a full descriptor table are absent. A reader must not infer these missing
properties from an axiom audit of the model's theorems.

## Observation and test-driver interface

Both controlled C and Lean drivers accept raw binary stdin, and separate `--reads LIST` /
`--writes LIST` flags (either order, either alone, or none). Lists are comma-separated -1 or
canonical decimal values ≤ 1048576, at most 4096 entries; writes also allow 0. No whitespace,
leading zeros, plus signs or empty items. C-only convenience options are outside the common
interface. Invalid configuration returns 64. Safety aborts and OS resource failures are not
relay outcomes. Input acceptance is at most 16 MiB; tests use bounded smaller inputs, and
process limits can stop large computations inside that syntactic domain.

Stdout is the modeled delivered byte sequence. Stderr is exactly:

```text
consumed=N
read_calls=R
write_calls=W
```

`consumed` means modeled read consumption, not bytes delivered and not host stdin ingestion.
Both drivers load a finite test input before running its scheduled model; even a scheduled
first-read error therefore differs from actual host input consumption. The bounded readers
stop after at most cap+1 bytes, but a host read can still block. The Lean driver computes a
pure outcome then performs actual stdout IO; real stdout delivery failure is outside its
pure proof and diagnostic protocol. Process deadlines supply operational test bounds.

| Input | Reads | Writes | Output | Status | consumed | reads | writes | Notes |
|---|---|---|---|---:|---:|---:|---:|---|
| `abc` | `[3,-1]` | default | `abc` | 1 | 3 | 2 | 1 | output=input does not imply success |
| `abcdef` | `[4]` | `[2,0]` | `ab` | 2 | 4 | 1 | 2 | pending `cd`, unread `ef` |

These are independent hand-calculated test vectors.

## Research interpretation

The phase1 [I/O prior-art review](../04_io_prior_art.md) identifies compositional I/O
verification, buffered VeriFast examples, DeepWeb's C/ITree refinement and Interaction Trees.
This phase adopts their general lesson of separating memory, protocol and observation.
It does not claim novelty or reproduce their historical builds. Primary papers and pinned sources remain the citation authority.

This protocol does not itself contain a State Calculus or Bash composition theorem.
