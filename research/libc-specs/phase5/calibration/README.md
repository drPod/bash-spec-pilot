# Bounded UTF-8 calibration (gnulib `u8_mbtoucr`)

Ask whether a real gnulib decoder can be related to an independent Unicode table specification under VST, as a calibration of C-as-spec rather than as Bash/State Calculus work.

Frozen source, Clight AST, table oracle, lemmas, sanitizer corpus and coverage are checked. The VST body theorem and gettext caller transfer were **not** established. This is a preserved negative result for C-conformance (`../CALIBRATION.md` stop rule; paper: [`../evaluation/DRAFT-PAPER.md`](../evaluation/DRAFT-PAPER.md)).

Nothing here is a claim about Bash, gettext binaries, or the script-fragment prototype. Details: [`RESULTS.md`](RESULTS.md).

| File | Role |
|---|---|
| `u8_mbtoucr.c` | Frozen gnulib source, byte-identical to upstream (SHA-256 in `RESULTS.md`). Unmodified. |
| `include/{config.h,stdint.h,unistr.h}` | Minimal declaration adapters for preprocessing. Not gnulib’s generated headers. |
| `u8_mbtoucr.i` | CompCert `clightgen -dprepro` preprocessed unit. |
| `u8_mbtoucr.v` | CompCert 3.15 Clight AST; accepted by Coq 8.20.1. Never hand-edited. |
| `UnicodeSpec.v` | Independent table specification from Unicode 16 Tables 3-6/3-7 plus the frozen gnulib API return convention. Reviewed (private `UNICODE-ORACLE-REVIEW.md`). |
| `UnicodeSpecLemmas.v` | Checked lemmas connecting `decode` to `encoding`, review witnesses, exhaustive first-byte check. No Admitted/axioms. |
| `Verif_u8_mbtoucr_spec.v` | Frozen VST 2.15 funspec and the body obligation as a `Prop`. Statement only, typechecked, unproved. |
| `unicode_oracle.py` | Python oracle sharing the table construction with `UnicodeSpec.v` (same provenance, not independent). |
| `make_vectors.py` | Deterministic corpus generator; cross-checks every scalar against Python’s standard UTF-8 encoder. |
| `test_driver.c` | ASan/UBSan differential harness with exact-length heap buffers. Not part of the verified unit. |
| `COPYING.LIB` | LGPL licence accompanying the gnulib source. |
