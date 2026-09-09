# Calibration results: gnulib `u8_mbtoucr` (bounded, 2026-09-07)

Independent Unicode-table oracle vs frozen gnulib `u8_mbtoucr`, plus a VST body theorem if it could be closed under a two-hour cap (`../CALIBRATION.md`).

Tooling, oracle, 1,190,417-case sanitizer corpus and coverage are checked. **VST C-conformance and gettext transfer were not established.** Preserved negative result; not Bash. Identities: `results.json`. Receipts: `~/agent-jobs/astra-research/phase5/runs/`.

Authoring window in `CALIBRATION.md` was 06:56:24–08:56:24 UTC. Work on this tree ran 08:06:59–08:25:58 UTC and stopped before the deadline; not a two-hour uninterrupted attempt or a timeout.

## Obligations

| Obligation | Status | Evidence |
|---|---|---|
| Frozen source, headers, Clight AST | Done | `u8_mbtoucr.c` byte-identical to upstream; `utf8-clightgen-2`; AST `utf8-ast-coqc-1` |
| Independent semantic oracle | Done, reviewed | `UnicodeSpec.v` (`unicode-spec-coqc-2`); private `UNICODE-ORACLE-REVIEW.md` |
| Oracle lemmas | Done, axiom-free | `UnicodeSpecLemmas.v` (`utf8-oracle-lemmas-coqc-6`; `Print Assumptions` closed, `utf8-oracle-lemmas-axioms-1`) |
| Differential C vs oracle + sanitizers | Done, corpus-bounded | 1,190,417 cases, exact match, no sanitizer report (`utf8-full-corpus-resume-1`) |
| Coverage | Done | 51/51 lines, 50/50 branches (`utf8-gcov-nopie-1`) |
| Frozen VST funspec | Statement only | `Verif_u8_mbtoucr_spec.v` (`utf8-vst-spec-coqc-1`); `start_function` probe aborted |
| **VST C-conformance body** | **Not established** | `body_obligation` is a `Prop`, not a lemma |
| **Gettext caller transfer** | **Not attempted** | No gettext source fetched |
| Twelve proof-generation trials | Not run | Requires a proved baseline |

Per the stop rule: backend calibration only. Nothing here is autonomous proof success.

## Differential test (not a theorem)

Non-PIE ASan/UBSan build of unmodified C plus `test_driver.c`. Exact-length heap buffers. Driver fails if input’s final contents differ from the saved copy. Does not exclude transient writes later restored.

| Quantity | Value |
|---|---|
| Cases | 1,190,417 |
| Output SHA-256 | equals `expected.txt` (`9ab0ccdf…c45`) |
| Sanitizer reports | 0 |
| Exit status | 0 |
| Wall / peak RSS | 0.76 s / 111,616 KiB |
| Limits | 120 s wall, 3 GiB cgroup, 64 MiB output; address-space limit disabled for ASan shadow |

| Group | Cases | Expectation provenance |
|---|---|---|
| Exhaustive length 1 | 256 | table oracle |
| Exhaustive length 2 | 65,536 | table oracle |
| All Unicode scalars (Python codec) | 1,112,064 | Python encoder; cross-checked vs table at generation |
| Row boundaries and every truncation depth | 6,679 | table oracle |
| Legal or illegal prefix + `FF 00` | 1,779 | table oracle |
| Seeded arbitrary bytes, lengths 1–8 | 4,096 | table oracle |
| Explicit regressions | 7 | table oracle |

Lengths three and four are not exhaustive. Not mutation controls.

Five supplementary inputs absent from the frozen corpus passed a separate ASan/UBSan rebuild (`pi-utf8-controls-build-2`, `pi-utf8-controls-run-1`): `E2 82 AC FF`, `F0 90 80 80 80`, `F8 80 80 80 80`, `C2 80 41`, `41 00 42` with expected pairs `(3,8364)`, `(4,65536)`, `(-1,65533)`, `(2,128)`, `(1,65)`. They do not change the corpus count.

`unicode_oracle.py` and `UnicodeSpec.v` share the nine-row table. Scalar-group expectations have distinct provenance (Python encoder). Review vs Unicode 16 Tables 3-6/3-7 is a source review, not a theorem.

### Coverage

`gcov -b -c`: 100% of 51 lines, 100% of 50 branches. The 72 “calls” are sanitizer instrumentation.

### PIE startup failure (cause unknown)

Default-PIE ASan looped on `AddressSanitizer:DEADLYSIGNAL` until 60 s (`utf8-sanitizer-run-1`, 16,141,438 lines, exit 143). Same binary with `handle_segv=0` ran the startup vector (`utf8-asan-startup-diagnosis-1`). `-fno-pie -no-pie` removed the symptom. Do not cite as a known ASan/PIE/container interaction.

### Checked Coq statements (oracle only)

`UnicodeSpecLemmas.v`: nine review witnesses by computation; exhaustive 256 first bytes vs Table 3-7; `decode_success_encoding`; `decode_incomplete_prefix`; `decode_invalid_no_prefix` / `decode_invalid_stable`; `full_row_app` / `full_row_app_inv`. `encoding` and `decode` share the table.

### Frozen VST task (statement only)

Hypotheses: readable input share, writable output share, `bs <> nil`, `Zlength bs ≤ Int64.max_unsigned`, elements in 0..255, `n` = list length. Post: input unchanged, output cell holds scalar, return and scalar satisfy `UnicodeSpec.contract`. Typechecks. No body proof.

Bounded probes (`utf8-vst-probe-ascii-1` … `-12`, all `Abort`): `forward` closes the ASCII branch. Blockers: `split2_data_at_Tarray_app` / `data_at_singleton_array_eq` for `*s`; flattened SEP; `tc_val tuchar`; `-normalize` splitting the load; `forward_if` join postcondition. Other 24 conditionals not attempted.

## Replay

From `research/libc-specs/phase5`, container `phase5-vst` idle (fresh run names):

```
python3 run_vst.py --name <fresh> --seconds 120 --workdir /home/coq/phase5/calibration -- coqc UnicodeSpec.v
python3 run_vst.py --name <fresh> --seconds 120 --workdir /home/coq/phase5/calibration -- coqc u8_mbtoucr.v
python3 run_vst.py --name <fresh> --seconds 120 --workdir /home/coq/phase5/calibration -- coqc UnicodeSpecLemmas.v
python3 run_vst.py --name <fresh> --seconds 300 --workdir /home/coq/phase5/calibration -- coqc Verif_u8_mbtoucr_spec.v
python3 calibration/make_vectors.py --out <fresh-dir>
python3 run_vst.py --name <fresh> --seconds 60 --workdir /home/coq/phase5/calibration -- gcc -std=c11 -Wall -Wextra -Werror -O1 -g -fno-pie -no-pie -fsanitize=address,undefined -fno-omit-frame-pointer --coverage -Iinclude u8_mbtoucr.c test_driver.c -o utf8_check_nopie
python3 run_vst.py --name <fresh> --seconds 120 --allow-sanitizer-shadow --workdir /home/coq/phase5/calibration -- env ASAN_OPTIONS=detect_leaks=1:quarantine_size_mb=64:abort_on_error=1 UBSAN_OPTIONS=halt_on_error=1 ./utf8_check_nopie input.hex
sha256sum ~/agent-jobs/astra-research/phase5/runs/<fresh>.log   # expect 9ab0ccdff1d8b9899a30426decb25b5e5cbfdb3f8faab14124135c89a782fc45
```

Copy `input.hex` into the container first. Regenerate Clight with the `clightgen` command in `results.json`; compare SHA-256 to frozen `u8_mbtoucr.v`.

Lemma file needed six `coqc` iterations (`utf8-oracle-lemmas-coqc-1` … `-6`). None of this counts as autonomous proof success under the trial protocol.
