# Phase2 results — 2026-09-07

Record the standard replay of the restricted C relay under a deterministic adapter.

The replay passed: a kernel-checked pure buffer-view model and independent implementation evidence. [results.json](results.json) records source/AST/executable/corpus hashes, the exact axiom manifest, measurements, limits and aggregate outcomes.

Not a C/Bash verifier. This is local-stage evidence, not the later whole-program script connection in [`../phase5/evaluation/DRAFT-PAPER.md`](../phase5/evaluation/DRAFT-PAPER.md).

## Checked and executed evidence

| Check | Observed result |
|---|---|
| Pure-model audit | 47 phase2 declarations; only propext, Classical.choice, Quot.sound; no admissions |
| Whole-unit frontend/replay tests | 6 groups pass; 5 nonsemantic variants accepted; 19 semantic and 22 unsupported variants rejected; stale binding guarded |
| Python/driver regressions | 23 tests pass, including 14 independently hand-calculated vectors and 6 small-cap C boundaries |
| Lean ingestion runtime tests | 72 finite cases and 1 returning no-EOF stream pass; distinct from theorem checks |
| Standard corpus | 2627 cases: 2585 valid schedules and 42 invalid common-interface configurations |
| Controlled C/Python/Lean comparison | All 2627 cases match for each of four C variants and the Lean executable |
| Symbol checks | 13 original/mutated relay objects pass their expected read/write symbol checks |
| Unshimmed control | 2627 predicted outcomes; valid inputs hit real read on isolated fd0 and fail |
| Real relay defaults | 35 corpus cases copy exact input with status 0 |
| Real-I/O/tracing checks | 10/10 pass, including 1MiB copy, regular file, closed descriptors, `/dev/full` and strace; none skipped |
| Mutants | All 9 distinguished; no tested program timeout in the final corpus |
| Phase1 preservation | 26 saved source hashes unchanged; previous reports remain archived |

The 2627-case corpus contains 2205 small-input schedule products, 273 33-byte schedule
products, 88 directed cases, 5 common CLI/default cases, 14 manual vectors and 42 rejections.
For small inputs, lengths 0–4 use read alphabet {-1,1,3,32}, write alphabet {-1,0,1,2}, and
all schedule lengths 0–2. At length 33 the alphabets are {-1,1,32} and {-1,0,1,32}, again
lengths 0–2. Each length uses one deterministic SHA256-derived payload. This exhausts these
schedule products, **not all byte strings or all possible execution environments**.
Directed tests cover buffer boundaries, binary values, multi-buffer input up to 100000 bytes,
clipped quotas and failures after partial delivery. Exact bytes/status/consumption/call counts
are compared. The separate quick tier passed 213 cases before the standard run.

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

The nonadvancing-offset mutant hits the driver's status 3 safety abort in 592 cases; other
cases distinguish it by observable differences. This is a negative test control, not a
termination theorem for C. A read-size mutant can preserve final bytes yet change call counts;
those counters are deliberately included in the adapter observation. The source recognizer's
rejection tests are separate from executable mutation tests; unsafe unsupported C need not run.

## Measurements and reproduction

One serial end-to-end replay on OVH (4vCPU/8GiB), Lean 4.31.0 and GCC 13.3.0:

| Command group | Elapsed | Peak RSS |
|---|---:|---:|
| Proof/build/axiom/runtime-bound checks | 8.72s | 793008KiB (774MiB) |
| C build and standard executable validation | 98.39s | 88968KiB (87MiB) |
| BufferRelay Lean build within proof group | 2.35s | 793008KiB |
| 47-declaration audit within proof group | 0.40s | 724092KiB |

These are GNU time per-command maximum RSS and wall time, not summed live host memory or a
statistical performance benchmark. Per-executable wait4 RSS in JSON can include pre-exec
memory inherited from the Python harness; do not interpret identical child peaks as the
individual program's intrinsic RAM need. The proof group started with a fresh phase2 package
cache while reusing the installed Lean/Std toolchain. Later replays may reuse local artifacts.
The standalone validator's unscoped Lean version probe found no global elan default; the
build record identifies the actual explicitly pinned 4.31.0 toolchain.

Reproduce with the [single serial command](README.md#reproduce-on-linux). No external APIs or model credentials are required for the replay.

## Harness failures retained (not counted as successes)

| Incident | Mechanism / fix |
|---|---|
| Preceding service OOM around 02:08 UTC | `validate.py --tier quick` exited 137 after corpus records reached the final case. The next smoke test redirected stdout to `/dev/full`, then the parent called `Path(stdout_path).read_bytes()`. [Linux `/dev/full`](https://man7.org/linux/man-pages/man4/full.4.html) supplies zero bytes on reads; reading it to EOF allocates indefinitely. Kernel victim details were unavailable; no measured OOM peak is claimed. Saved Lean build/audit predates the failure and was resumed intact. |
| Integrated runner | Never reads an external output sink; captures only bounded regular scratch files; limits address space/CPU/output and process-group lifetime. `/dev/full`, allocation-limit and timeout regressions pass. |
| First bounded quick attempt | Stopped after a test-only fortification-flag omission and a 2GiB virtual-address limit that prevented Lean runtime initialization. Corrected compile uses the same `-U_FORTIFY_SOURCE` as the main shim; a 3GiB limit with 16MiB thread stacks permits the runtime. A standalone empty model used 9452KiB RSS. |

Reviews identified missing whole-execution pointer refinement, originally unbounded stdin ingestion, misleading skip reporting, and stale C-build reuse. The final suite always rebuilds all C/mutants and renders unavailable tracing as SKIPPED. CLI extensions in the C harness are outside the common interface. This was collaborative artifact development, not a controlled agent benchmark.

## Interpretation

The pure theorem establishes delivered/pending/unread conservation, successful exactness,
nonvacuous positive-schedule success, failure residuals, call bounds and well-founded
termination. Local memory lemmas establish initialized-range load/store/frame and pointer
slice identities. The drain runs over a loaded byte list; **there is no whole-execution
simulation of C pointer operations**, and the generated frontend theorem is only an alias.
Native IO, machine integers, header/link/compiler behavior, full POSIX and shell composition
remain outside the checked relation. Read [PROTOCOL.md](PROTOCOL.md) and [FRONTEND.md](FRONTEND.md)
before citing the result. Existing [primary-source prior art](../04_io_prior_art.md) precludes
an absence-based novelty claim.

A later phase3 step was an explicit pointer-machine transition relation with
buffer, initialized length, offset, unread input, delivered output and read/write events.
That simulation is not claimed in this phase2 record.
