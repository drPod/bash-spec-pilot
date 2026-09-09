# Phase2: bounded buffer relay

This experiment extends the phase1 byte and memory work with a concrete 32-byte C relay,
a full-unit restricted frontend, a well-founded Lean buffer-view model, short-write/error
semantics and independent executable validation. The intended result is a checked model
plus evidence about its correspondence to C. **C translation, native runtime, libc/kernel
and Bash composition remain unverified.** No novelty or full-verifier claim is made.

Read [the protocol and proof boundary](PROTOCOL.md), [frontend scope](FRONTEND.md), and
[measured results](RESULTS.md). The original phase1 sources and reports are preserved.

| Artifact | Role |
|---|---|
| `relay.c` | Frozen concrete loop: read32, retry positive short writes, fail on nonpositive write |
| `frontend.py` | Parse the entire unit and compare against one independently constructed AST schema |
| `BufferRelay.lean` | Finite-memory store/load path, list-drain model, conservation, success, residual and call bounds |
| `Axioms.lean` | Explicit audit of 47 phase2 definitions/theorems/examples |
| `Main.lean` / `InputBoundTests.lean` | Raw-byte test driver, bounded ingestion and runtime regressions |
| `validation/` | Recovered Claude Fable5.1 C driver, independent Python oracle/corpus; Astra integration and safety fixes |
| `test_frontend.py` / `test_replay_guard.py` | Acceptance, rejection, precedence and stale-binding regressions |
| `reproduce.py` | Serial bounded proof/build and differential replay with artifact identity checks |

## Reproduce on OVH/Linux

Prerequisites: Python via uv, Lean4.31.0/elan, a C compiler, binutils, GNU time, GNU timeout
and prlimit. Strace supplies two optional tracing checks; missing tracing is explicitly
reported as skipped. No model API, OpenScience OAuth, Docker, Delphi or Mac connection is
needed for checking these artifacts. Delphi was used for research navigation, not proof.

From the repository root:

```sh
uv run --no-project python -B research/libc-specs/phase2/reproduce.py --tier standard
```

For a smaller integration check use `--tier quick`. The default output is
`~/.cache/bash-spec-pilot/phase2-replay/result.json`, with underlying logs and records in
that same local cache. `--cache PATH` must name a directory outside the repository. Never
run two replays against the same cache, and use only one compiler/build at a time on this
host. The command itself serializes all work: each module's Lean and generated C compilation
runs before moving to the next; the C validation variants are then compiled one at a time.
Existing Lean caches are reused; the small C/mutant suite is rebuilt to avoid stale recipes.

Each Lean build/audit command has a120s deadline, a3GiB virtual-address cap, and one Lean
worker with a16MiB thread stack. The top proof replay has a180s deadline. Validation has
600s overall and parent-CPU bounds; each tested program has a30s deadline/CPU bound, a3GiB
address-space cap and a128MiB capture-file limit. C compiler commands use1GiB/60s caps.
Lower inherited limits can cause an explicit failure. These are command-local controls;
no host configuration is changed. They are workload limits, not an adversarial sandbox.

Both sources and generated artifacts are hashed. The final record requires the staged C
hash and Lean executable hash to agree across build and differential records. The
translated binding remains an unverified alias despite those identity checks. The record's
axiom lists must contain only `propext`, `Classical.choice` and `Quot.sound`; warnings are
errors, and the manifest must contain the expected declarations. Runtime tests are listed
separately from those theorem checks.

The corpus exhausts specified small **schedule products**, using one deterministic binary
payload per chosen length. It does not exhaust all byte strings, all schedules or POSIX
behaviors. It adds 31/32/33 boundaries, multi-buffer data up to100000 bytes, all byte values,
NUL/invalid-UTF8 inputs, read/error/short-write/zero branches, 14 independent hand-calculated
vectors, and42 invalid common-interface configurations. Comparisons check exact bytes,
status, consumed count and both call counts. Four controlled C binaries combine macro
substitution/linker wrapping with O0/O2; an unshimmed negative control confirms fd isolation.
Nine C mutants test output-offset, short-write, failure, request-size and loop-progress faults.
Real-I/O tests include a1MiB copy, regular-file input, closed descriptors and `/dev/full`.

The driver cap is an acceptance bound, not a guarantee that every accepted large input
finishes under runtime limits. The pure recursion is not optimized for large streams.
The recorded sizes suffice for this phase; no compute offload is warranted.
