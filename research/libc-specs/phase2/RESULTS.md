# Phase2 results — 2026-09-07

**The standard replay passes.** The result is a kernel-checked pure buffer-view model and
independent implementation evidence for a restricted C relay under a deterministic adapter.
It is not a C/Bash verifier. [results.json](results.json) records source/AST/executable/corpus
hashes, the exact axiom manifest, measurements, limits and aggregate outcomes.

## Checked and executed evidence

| Check | Observed result |
|---|---|
| Pure-model audit |47 phase2 declarations; only propext, Classical.choice, Quot.sound; no admissions |
| Whole-unit frontend/replay tests |6 groups pass;5 nonsemantic variants accepted;19 semantic and22 unsupported variants rejected; stale binding guarded |
| Python/driver regressions |23 tests pass, including14 independently hand-calculated vectors and6 small-cap C boundaries |
| Lean ingestion runtime tests |72 finite cases and1 returning no-EOF stream pass; distinct from theorem checks |
| Standard corpus |2627 cases:2585 valid schedules and42 invalid common-interface configurations |
| Controlled C/Python/Lean comparison |All2627 cases match for each of four C variants and the Lean executable |
| Symbol checks |13 original/mutated relay objects pass their expected read/write symbol checks |
| Unshimmed control |2627 predicted outcomes; valid inputs hit real read on isolated fd0 and fail |
| Real relay defaults |35 corpus cases copy exact input with status0 |
| Real-I/O/tracing checks |10/10 pass, including1MiB copy, regular file, closed descriptors, /dev/full and strace; none skipped |
| Mutants |All9 distinguished; no tested program timeout in the final corpus |
| Phase1 preservation |26 saved source hashes unchanged; previous reports remain archived |

The2627-case corpus contains2205 small-input schedule products,273 33-byte schedule
products,88 directed cases,5 common CLI/default cases,14 manual vectors and42 rejections.
For small inputs, lengths0–4 use read alphabet{-1,1,3,32}, write alphabet{-1,0,1,2}, and
all schedule lengths0–2. At length33 the alphabets are{-1,1,32} and{-1,0,1,32}, again
lengths0–2. Each length uses one deterministic SHA256-derived payload. This exhausts these
schedule products, **not all byte strings or all possible execution environments**.
Directed tests cover buffer boundaries, binary values, multi-buffer input up to100000 bytes,
clipped quotas and failures after partial delivery. Exact bytes/status/consumption/call counts
are compared. The separate quick tier passed213 cases before the standard run.

| Mutant | Distinguishing standard cases |
|---|---:|
| eof_as_error | 898 |
| ignore_write_error | 466 |
| ignore_zero_write | 466 |
| no_offset_advance | 769 |
| read_error_status_2 | 755 |
| read_size_16 | 206 |
| read_size_31 | 155 |
| short_write_as_full | 352 |
| wrong_write_offset | 226 |

The nonadvancing-offset mutant hits the driver's status3 safety abort in592 cases; other
cases distinguish it by observable differences. This is a negative test control, not a
termination theorem for C. A read-size mutant can preserve final bytes yet change call counts;
those counters are deliberately included in the adapter observation. The source recognizer's
rejection tests are separate from executable mutation tests; unsafe unsupported C need not run.

## Measurements and reproduction

One serial end-to-end replay on OVH (4vCPU/8GiB), Lean4.31.0 and GCC13.3.0:

| Command group | Elapsed | Peak RSS |
|---|---:|---:|
| Proof/build/axiom/runtime-bound checks |8.72s |793008KiB (774MiB) |
| C build and standard executable validation |98.39s |88968KiB (87MiB) |
| BufferRelay Lean build within proof group |2.35s |793008KiB |
|47-declaration audit within proof group |0.40s |724092KiB |

These are GNU time per-command maximum RSS and wall time, not summed live host memory or a
statistical performance benchmark. Per-executable wait4 RSS in JSON can include pre-exec
memory inherited from the Python harness; do not interpret identical child peaks as the
individual program's intrinsic RAM need. The proof group started with a fresh phase2 package
cache while reusing the installed Lean/Std toolchain. Later replays may reuse local artifacts.
The standalone validator's unscoped Lean version probe found no global elan default; the
build record identifies the actual explicitly pinned4.31.0 toolchain. No default was changed.

Reproduce with the [single serial command](README.md#reproduce-on-ovhlinux). No Mac offload
is needed given these measurements. No external APIs, model credentials or optional UI OAuth
are required for the replay.

## Recovery and review findings

The preceding phase2 service was OOM-killed around02:08UTC. Its private Claude log records
`validate.py --tier quick` exiting137 after the corpus records reached the final case. Static
inspection found that the next smoke test redirected stdout to `/dev/full`, then the parent
runner called `Path(stdout_path).read_bytes()`. [Linux documents /dev/full](https://man7.org/linux/man-pages/man4/full.4.html)
as supplying zero bytes on reads; reading it to EOF allocates indefinitely. This is the
strongly supported failure mechanism. Kernel victim details were unavailable to the user
account, so this report does not claim kernel-level attribution or a measured OOM peak.
The saved successful Lean build/audit predates that failure and was resumed intact.

The integrated runner never reads an external output sink, captures only bounded regular
scratch files, and limits subprocess address space/CPU/output and process-group lifetime.
Actual /dev/full, allocation-limit and timeout regressions pass. Both input readers enforce
an inclusive acceptance cap with bounded ingestion; the C boundary regression compiles with
a32-byte test cap, while Lean tests use returning mock streams. Host blocking remains outside
that ingestion test. The signal handler now uses fixed async-safe diagnostics.

The first bounded quick attempt was stopped after a test-only fortification-flag omission
and a2GiB virtual-address limit that prevented Lean runtime initialization. The corrected
compile uses the same -U_FORTIFY_SOURCE requirement as the main shim build; a3GiB limit with
explicit16MiB thread stacks permits the runtime. A standalone empty model used9452KiB RSS.
Self-test failures and model crashes now stop validation early. These failed attempts are
retained privately; only the final passing run supplies the table above.

Independent Astra review confirmed nonvacuity and actual store/load output origin, while
identifying the missing whole-execution pointer refinement and the original unbounded
stdin ingestion. Independent Claude Fable5.1 static review confirmed the repaired OOM path,
checked the14 manual vectors and inspected mutant behavior. It also found misleading skip
reporting and stale C-build reuse; the final suite always rebuilds all C/mutants and renders
unavailable tracing as SKIPPED. CLI extensions in the C harness are explicitly outside the
common interface. Compiler warnings are errors and the exact axiom whitelist remains active.
This was collaborative artifact development/review, not a controlled agent benchmark.

## Interpretation and next obligation

The pure theorem establishes delivered/pending/unread conservation, successful exactness,
nonvacuous positive-schedule success, failure residuals, call bounds and well-founded
termination. Local memory lemmas establish initialized-range load/store/frame and pointer
slice identities. The drain runs over a loaded byte list; **there is no whole-execution
simulation of C pointer operations**, and the generated frontend theorem is only an alias.
Native IO, machine integers, header/link/compiler behavior, full POSIX and shell composition
remain outside the checked relation. Read [PROTOCOL.md](PROTOCOL.md) and [FRONTEND.md](FRONTEND.md)
before citing the result. Existing [primary-source prior art](../04_io_prior_art.md) precludes
an absence-based novelty claim.

The next bounded research step is an explicit pointer-machine transition relation with
buffer, initialized length, offset, unread input, delivered output and read/write events.
Prove a simulation between that machine and this frozen list-view model, tying every retry
to its actual pointer/range and conserving pending ownership. Only then pursue a typed
restricted-C lowering theorem and an explicit shell observation/composition relation.
