# Calibration results: gnulib `u8_mbtoucr` (bounded, 2026-09-07)

The authoring budget began at 06:56:24 UTC on 2026-09-07, with an 08:56:24 UTC
deadline (the two-hour cap in `../CALIBRATION.md`, excluding shared-toolchain setup).
The resumed worker actually ran from 08:06:59 to 08:25:58 UTC and stopped before
that deadline; this was not a two-hour uninterrupted proof attempt or a deadline
timeout. The C body and caller obligations were left unestablished after bounded
probes. Machine-readable identities and receipt names: `results.json`. Run receipts
(`<run>.json` + `<run>.log`) live outside the repository under
`~/agent-jobs/astra-research/phase5/runs/`; every claim below names its run.

## Summary of obligations

| Obligation (CALIBRATION.md / REQUIREMENTS.md) | Status | Evidence |
|---|---|---|
| Frozen source, headers, preprocessed unit, generated Clight AST | Done | `u8_mbtoucr.c` byte-identical to upstream download; `clightgen` run `utf8-clightgen-2`; AST accepted by Coq (`utf8-ast-coqc-1`) |
| Independent semantic oracle frozen from standard + API | Done, reviewed | `UnicodeSpec.v` (`unicode-spec-coqc-2`); review in private `UNICODE-ORACLE-REVIEW.md` |
| Oracle lemmas connecting `decode` to `encoding` | Done, checked, axiom-free | `UnicodeSpecLemmas.v` (`utf8-oracle-lemmas-coqc-6`; `Print Assumptions` closed, `utf8-oracle-lemmas-axioms-1`) |
| Differential evidence: C vs oracle, with sanitizers | Done, bounded to corpus | 1,190,417 cases, exact output match, no sanitizer report (`utf8-full-corpus-resume-1`) |
| Coverage of the C unit by the corpus | Done | 51/51 lines, 50/50 branches taken (`utf8-gcov-nopie-1`) |
| Frozen VST funspec (theorem type for trials) | Done, statement only | `Verif_u8_mbtoucr_spec.v` typechecks (`utf8-vst-spec-coqc-1`); `start_function` accepts it (probe `utf8-vst-probe-startfunction-2`, aborted, outside repo) |
| **VST C-conformance body theorem** | **Not established when work stopped** | Only bounded probes were attempted. `body_obligation` is a `Prop` definition, not a lemma. |
| **Gettext caller transfer** | **Not attempted** | No gettext source was fetched, preprocessed or translated. |
| Twelve proof-generation trials | Not run | Requires a proved baseline; none exists. |

Consequently, per the stop rule, this is **backend calibration evidence only**: the tooling,
oracle, corpus and frozen task are ready; the conformance theorem and transfer are open.
Nothing here is an autonomous proof-success result, and nothing here concerns Bash.

## What was measured

### Differential test (not a theorem)

The non-PIE AddressSanitizer/UndefinedBehaviorSanitizer build of the unmodified C unit
plus `test_driver.c` was run on the frozen corpus. Each case uses an exact-length heap
buffer to expose out-of-bounds accesses to the sanitizers, and the driver fails if
the input's final contents differ from the saved copy. This does not exclude transient
writes later restored or errors the instrumentation does not detect.

| Quantity | Value |
|---|---|
| Cases | 1,190,417 |
| Output SHA-256 | equals `expected.txt` (`9ab0ccdf…c45`) |
| Sanitizer reports | 0 |
| Exit status | 0 |
| Wall / peak RSS | 0.76 s / 111,616 KiB |
| Limits | 120 s wall, 3 GiB cgroup memory, 64 MiB output file; address-space limit disabled for ASan shadow |

Corpus composition (cases overlap across groups; counts are cases, not unique strings):

| Group | Cases | Expectation provenance |
|---|---|---|
| Exhaustive length 1 | 256 | table oracle |
| Exhaustive length 2 | 65,536 | table oracle |
| All Unicode scalars (encoded by Python's standard codec) | 1,112,064 | Python standard encoder; cross-checked against the table oracle at generation |
| Row boundaries and every truncation depth | 6,679 | table oracle |
| Legal or illegal prefix followed by `FF 00` | 1,779 | table oracle |
| Seeded arbitrary bytes, lengths 1–8 | 4,096 | table oracle |
| Explicit regressions (`00`, `E2 82`, `E0 9F`, `ED A0`, `F4 90`, `C2 A2 FF`, 32×`A`) | 7 | table oracle |

Directed valid and invalid cases include NUL, overlong leaders and second-byte
restrictions, surrogate and above-range boundaries, every truncation depth of the
generated row-boundary products, early invalidity in short buffers, and malformed
suffixes after complete characters. Lengths one and two are exhaustive; lengths
three and four are not. These are test inputs, not mutation controls demonstrating
that an intentionally wrong decoder is rejected.

Five supplementary Grok/Pi-selected inputs were absent from the frozen corpus and
passed a separate frozen-source ASan/UBSan rebuild (`pi-utf8-controls-build-2`,
`pi-utf8-controls-run-1`): `E2 82 AC FF`, `F0 90 80 80 80`, `F8 80 80 80 80`,
`C2 80 41`, and `41 00 42`. Expected return/scalar pairs were respectively
`(3,8364)`, `(4,65536)`, `(-1,65533)`, `(2,128)`, and `(1,65)`.
These five cases do not change the frozen corpus count or establish a theorem.

Provenance caveat: `unicode_oracle.py` and `UnicodeSpec.v` share the nine-row table
construction. Agreement between the C code and the corpus checks transcription and
integration, not two independent oracles. The scalar group's expectations are the one
part with distinct provenance (Python's encoder). The review found no discrepancy against
Unicode 16 Tables 3-6/3-7, but that review is a source review, not a theorem.

### Coverage

`gcov -b -c` on the non-PIE build after the startup vector and full corpus:
100% of 51 lines, 100% of 50 branches executed and taken at least once, zero unexecuted
lines in `u8_mbtoucr.c`. The 72 "calls" are sanitizer instrumentation, not source calls.

### PIE startup failure (root cause not established)

The first ASan build (default PIE) looped on `AddressSanitizer:DEADLYSIGNAL` at startup
until the 60 s timeout (16,141,438 lines, exit 143; `utf8-sanitizer-run-1`). The same
binary with `handle_segv=0` ran the startup vector correctly
(`utf8-asan-startup-diagnosis-1`). Rebuilding with `-fno-pie -no-pie` removed the
symptom and the rebuilt binary ran the whole corpus cleanly. The cause was not diagnosed;
do not cite it as a known ASan/PIE/container interaction.

### Checked Coq statements (all axiom-free, no `Admitted`)

`UnicodeSpecLemmas.v` proves, about the oracle alone:

- Nine review witnesses by computation (including `C2 A2 FF ↦ (2, 162)`, `E0 9F`, `ED A0`,
  `F4 90 ↦ (-1, U+FFFD)`, `F0 90 80 ↦ (-2, U+FFFD)`, `F4 8F BF BF ↦ (4, U+10FFFF)`), and
  the documented totalization `decode [] = (-2, U+FFFD)` that `contract` excludes.
- Exhaustive check over all 256 single bytes against Table 3-7's first-byte column,
  stated independently of the row list.
- `decode_success_encoding`: a positive result `k` means `k ≤ length` and the first `k`
  bytes are a legal encoding of the returned scalar (suffix irrelevant).
- `decode_incomplete_prefix`: result -2 means some table row is compatible with the whole
  input and strictly longer than it.
- `decode_invalid_no_prefix` and `decode_invalid_stable`: result -1 means no row is
  compatible, and appending any bytes cannot change the -1 classification.
- `full_row_app` / `full_row_app_inv`: framing lemmas needed later for suffix
  generalization from exact-length buffers to larger scratch buffers.

These audit classifier logic; they cannot certify the table transcription, since
`encoding` and `decode` share the table.

### Frozen VST task (statement only)

`Verif_u8_mbtoucr_spec.v` fixes the theorem type. Hypotheses: readable input share,
writable output share, `bs <> nil`, `Zlength bs ≤ Int64.max_unsigned`, every element in
0..255, `n` equal to the list length. Post: input array unchanged, output cell holds the
scalar, return value and scalar satisfy `UnicodeSpec.contract`. It typechecks and
`start_function` accepts it against the generated body. No body proof exists.

Bounded body-proof probes (private job directory, every file ends in `Abort`, so no
theorem results; receipts `utf8-vst-probe-ascii-1` … `-12`): under the frozen spec, VST's
`forward` reaches and closes the ASCII branch (`c < 0x80`: store, return 1, oracle fact via
a `decode_ascii` lemma, array refold). The blockers met on the way, in order, were: the
scalar load `*s` against a `tarray tuchar n` SEP (needs `split2_data_at_Tarray_app` and
`data_at_singleton_array_eq`), the flattened-SEP requirement, a `tc_val tuchar` side goal
needing the byte-range hypothesis, clightgen's `-normalize` splitting the load into two
statements, and `forward_if` needing an explicit join postcondition because invalid paths
fall through to the final `return -1`. The other 24 conditionals were not attempted.

## Replay

From `research/libc-specs/phase5`, with the shared `phase5-vst` container live and idle
(fresh run names are mandatory; the script refuses to overwrite receipts):

```
python3 run_vst.py --name <fresh> --seconds 120 --workdir /home/coq/phase5/calibration -- coqc UnicodeSpec.v
python3 run_vst.py --name <fresh> --seconds 120 --workdir /home/coq/phase5/calibration -- coqc u8_mbtoucr.v
python3 run_vst.py --name <fresh> --seconds 120 --workdir /home/coq/phase5/calibration -- coqc UnicodeSpecLemmas.v
python3 run_vst.py --name <fresh> --seconds 300 --workdir /home/coq/phase5/calibration -- coqc Verif_u8_mbtoucr_spec.v
python3 calibration/make_vectors.py --out <fresh-dir>      # regenerates input.hex / expected.txt; compare SHA-256 to results.json
python3 run_vst.py --name <fresh> --seconds 60 --workdir /home/coq/phase5/calibration -- gcc -std=c11 -Wall -Wextra -Werror -O1 -g -fno-pie -no-pie -fsanitize=address,undefined -fno-omit-frame-pointer --coverage -Iinclude u8_mbtoucr.c test_driver.c -o utf8_check_nopie
python3 run_vst.py --name <fresh> --seconds 120 --allow-sanitizer-shadow --workdir /home/coq/phase5/calibration -- env ASAN_OPTIONS=detect_leaks=1:quarantine_size_mb=64:abort_on_error=1 UBSAN_OPTIONS=halt_on_error=1 ./utf8_check_nopie input.hex
sha256sum ~/agent-jobs/astra-research/phase5/runs/<fresh>.log   # expect 9ab0ccdff1d8b9899a30426decb25b5e5cbfdb3f8faab14124135c89a782fc45
```

`input.hex` must be copied into the container directory first (`docker cp`). The Clight
AST is regenerated with the `clightgen` command recorded in `results.json`; compare the
SHA-256 of the output to the frozen `u8_mbtoucr.v`.

## Intervention accounting

All artifacts in this directory were authored collaboratively by orchestrator and worker
agents with logged compiler feedback; the lemma file needed six `coqc` iterations
(receipts `utf8-oracle-lemmas-coqc-1` … `-6`). No human expert minutes are claimed. None
of this counts as autonomous proof success under the CALIBRATION.md trial protocol.
