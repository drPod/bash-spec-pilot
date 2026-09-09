# Phase3 pointer-event validation of the frozen relay.c (`ptrcheck`)

Independent implementation/validation artifact (Claude Fable 5.1 worker, 2026-09-07) for
the phase3 pointer-machine direction. It checks that the **real compiled loop** of the
frozen phase2 `relay.c` (sha256 `c5abc06f…afe68`, never edited) performs exactly the
pointer/range/byte events that an independent pointer-machine reference predicts, on every
intercepted `read`/`write` call, not only in its final stdout/status. It is separate from
phase2's `validation/` (different filenames, symbols `probe_read`/`probe_write`, package
`ptrcheck`) and does **not** model C as a copy of `BufferRelay.lean`.

| Artifact | Role |
|---|---|
| `probe/pointer_probe.c` | Driver + tracing shims. relay.c compiled unmodified with `-Dread=probe_read -Dwrite=probe_write` (or plainly with `-Wl,--wrap=read,--wrap=write`). Logs per call: kind, fd, pointer offset from the first-read base, full request, action, canonical signed result, transferred raw bytes, chunk/defined lengths before/after, memory snapshot. Strict per-case call cap, 2 s alarm, fd isolation (fd 0 closed, fd 1 → `/dev/full`, never read). |
| `ptrcheck/pointer_model.py` | Independent pointer-machine reference: 32-cell array, defined prefix, `n`, `off`; reads STORE at the base, writes LOAD `min(action, n-off)` bytes from the array at `off`. |
| `ptrcheck/invariants.py` | Model-free rules R1–R10 re-derived from the trace itself: write pointer == delivered-since-read, request == `n-off`, range inside the initialized chunk, bytes == memory at the pointer == input slice, frame (reads replace a prefix, writes change nothing), fail-stop, read-before-drain, conservation. |
| `ptrcheck/judge.py` | Field-by-field event/final comparison; classifies mutant distinctions as `abort` / `final` / `event_only`. |
| `ptrcheck/trace_format.py`, `TRACE_SCHEMA.md` | The common JSON document, its validator, canonical hash, probe JSONL parser, hand-trace expander. |
| `ptrcheck/cases.py` | Deterministic bounded corpus (SHA-256 counter payloads, transitions at 31/32/33/64/65, directed retry/failure/loop cases, hand vectors, 9 rejects). `quick` 177 cases, `standard` 962 (< 1000), `full` 2301 (opt-in). |
| `ptrcheck/mutations.py` | 8 single-substitution mutants: wrong pointer, wrong residual request, request-one-byte, skipped short-write retry, read-before-drain (`while`→`if`), zero write retried, offset never advances, read request 31. |
| `ptrcheck/build_probe.py`, `ptrcheck/exec_bounded.py` | Serial bounded build (1 GiB / 60 s per compiler command) and execution (256 MiB AS, 3 s CPU, 3 s wall, core 0, 16 MiB fsize, 8 MiB capture, regular-file-only capture, one process at a time). |
| `hand_traces.json` | 12 hand-derived event traces (compact rows + column header) including the PROTOCOL.md examples and 31/32/33/65 transitions with stale-cell frames. |
| `tests/` | 30+ unit tests: reference == hand traces, schema/invariants on the quick corpus, probe JSONL round trip, injected-fault sensitivity for every mutant class, corpus budget/determinism, dry-run build plan, executor limits. |
| `validate_pointer.py` | The validation CLI (modes `selftest`, `dry-run`, `full`). |
| `reference_trace.py` | Print/validate one reference document (for the Lean adapter differential). |

## Invocation (from this directory; `uv` + Python 3.12 stdlib only)

```sh
# 1. Python-only self-test; no compiler, no tested program (safe while another worker owns the compiler slot)
uv run --no-project python -B validate_pointer.py --mode selftest --out ~/.cache/bash-spec-pilot/phase3-ptrcheck

# 2. Plan: corpus + reference traces + the exact bounded compiler commands, nothing compiled/executed
uv run --no-project python -B validate_pointer.py --mode dry-run --tier standard --out ~/.cache/bash-spec-pilot/phase3-ptrcheck

# 3. Full run (needs the compiler slot): serial build, 962-case corpus, ~12 bounded processes per case
uv run --no-project python -B validate_pointer.py --mode full --tier quick    --out ~/.cache/bash-spec-pilot/phase3-ptrcheck
uv run --no-project python -B validate_pointer.py --mode full --tier standard --out ~/.cache/bash-spec-pilot/phase3-ptrcheck --budget-seconds 600

# One reference document for the Lean trace adapter, or validation of any producer's document
uv run --no-project python -B reference_trace.py --input-hex 616263646566 --reads 4 --writes 2,0
uv run --no-project python -B reference_trace.py --check-doc /path/to/lean_or_c_trace.json
```

`--out` must be outside the repository (enforced). Outputs: `results.json` (checks, limits,
hashes of every source file, per-executable aggregates, mutant distinction classes),
`per_case.jsonl` (per case: expected final + trace hash, per executable status/stdout hash/
event count/trace hash/first problems), `traces/` (full common-schema documents for hand,
directed and no-flag cases from `orig_macro_O2`, the matching reference, and every mismatch;
capped at 600 files), `build.json`, `corpus_manifest.json`, `summary.md`. The run stops
gracefully and reports `INCOMPLETE` after `--budget-seconds` (default 600 s).

Per-case protocol: the probe receives `--max-calls` equal to the reference's
`read_calls + write_calls`; any extra call aborts with status 3 (this is how the zero-write
loop and the non-advancing-offset mutants are stopped without any timer), plus a 2 s alarm
and the external 3 s kill.

## Limits (all command-local; no host configuration is changed)

| scope | address space | CPU | wall | other |
|---|---:|---:|---:|---|
| each compiler command | 1 GiB | 60 s | 60 s (`timeout --kill-after=2s`) | strictly one at a time |
| each tested program | 256 MiB | 3 s | 3 s (process-group SIGKILL) | core 0, fsize 16 MiB, capture 8 MiB, regular files only |
| parent validator | 2 GiB | 900 s | `--budget-seconds` | fsize 256 MiB |

## Validation and integration

Main executed the independent harness after the authoring worker finished. The standard
replay passed all 962 cases against three C variants and the shared Lean event projection;
see [phase3 results](../RESULTS.md) for the final measured run and exact source hashes.
The authoring worker did not run compilers; the main orchestrator owns the serial build slot.

Review fixed an exit-record lifetime bug before any C evidence was reported: intercepted
calls copy the live defined prefix into a static shadow, and the exit record reads only
that shadow after `relay()` returns. A second review rejected an accidentally exposed
non-32 capacity argument; this reference supports exactly the frozen 32-byte allocation.

The Lean adapter emits a smaller JSON schema. [compare_lean.py](../compare_lean.py) compares
all event kind/block/offset/request/action/result/payload fields and final delivered,
pending, unread, status and call counts. C/Python initialization metadata and memory
snapshots are checked separately; they are not part of the Lean runtime projection.

Eight syntactic mutations include two with equivalent observations in this protocol:
`skipped_short_write_retry` and `read_before_drain`. Do not treat eight detected edits as
eight independent fault classes. `event_only` is the classifier name for a mismatch with
identical stdout, process status and diagnostic counters; inspect event, derived-final
and probe checks to determine its precise cause. Clamped invalid mutant accesses are
instrumentation behavior, not evidence of how undefined C would execute.

Per-process RSS comes from `wait4` over the launched child lifetime, including wrappers
and pre-exec overhead. It does not isolate memory used by the relay. Group measurements
include the validator and descendants. Neither timings nor mutation counts are a
performance/accuracy benchmark against another verification system.

## Interpretation

A `PASS` means: for every corpus case and each of three link/optimization variants of the
untouched relay object, the intercepted call sequence equals the reference event-for-event
(pointer offset, residual request, action, result, transferred bytes, chunk and defined
lengths, memory snapshot) and satisfies the model-free invariants; the unshimmed control
fails as predicted (fd isolation works); every mutant is distinguished, with the report
stating whether by abort, by wire-visible output, or **only by the event trace**
(`request_one_byte`, `wrong_residual_request` and `read_request_31` are expected to be
event-only on many cases: identical stdout/status/counters, different pointer events).
This is executable evidence about the compiled relay under a deterministic adapter; it is
not a C semantics theorem, not a libc/kernel claim, and does not exhaust byte strings or
schedules beyond the listed products.
