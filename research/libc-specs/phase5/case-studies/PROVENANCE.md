# Source and frontend provenance

## Pinned identities

Coreutils `9530a14420fc1a267e90d45e8a0d710c3668382d` (v9.4), gnulib
`bb5bb43a1ebb9f502b5ce38c0b8c8778d13b9f6e` - same pins as `utility-reuse/`.
`src/pinned/coreutils/head.c`, `wc.c` and `src/pinned/gnulib/*` copied
byte-identical from the Pi source-selection review's frozen fetch
(`pi-reviews/nonutf8-case-selection-4/frozen/`, itself checked against
`SHA256SUMS` there - re-verified here, `sha256sum -c` OK for all 18 entries
before use). `src/tu/FRAGMENTS.json` (from `extract_fragments.py`) records
byte ranges/hashes for all three extracted fragments.

## `head_bytes` fragment line-range correction

`CASE-BRIEF.md` (the frozen Pi brief) records `head_bytes` as `head.c` lines
774-796 inclusive, hash `ebdb38f174c0bcc25e4cc6e1aa98eb1ea3bf8ed29a2f8165b1cd0b0d6e6a4414`.
Direct inspection of the pinned `head.c` shows line 796 is `return true;` and
the function's closing `}` is line 797 - the recorded range excludes it and
is not valid C. Confirmed empirically: extracting exactly 774-796 and running
it through the same `clightgen` command used everywhere else in this
directory fails (`case4-clightgen-1`, exit 2, CompCert's parser: "syntax
error after ')' and before '{'... a list of declarators has been
recognized... a semicolon is expected" - the classic symptom of an unbalanced
brace). This is an off-by-one in the frozen brief's own line count, not a
rescoping decision: the corrected range (774-797, fragment hash
`ae9f42de06cf55ca1bfcc8720986b32f8c8d14b8063af8374dece0b886bbc4b7`) is the
complete, byte-identical function body the brief's own prose describes
(ending at `return true; }`), one line longer than what the brief's SHA256
covers. `wc_lines`'s recorded range (`wc.c` 266-330) and `xwrite_stdout`'s
(`head.c` 176-189, provenance only) were both checked against the pinned
sources and are correct as recorded.

## Adapter translation units

`src/tu/head_bytes_fragment.c`, `src/tu/wc_lines_fragment.c`: declaration-only
adapter context above an unedited `#include` of the byte-extracted fragment,
same convention as `utility-reuse/src/tu/cat_fragment.c`. Each documents its
own `ADAPTER DEVIATION`s inline:

- `head_bytes_fragment.c`: fixed-arity `error` (1 call site, 4 args);
  `quoteaf` declared as a 1-arg pure external (gnulib `quote.h`);
  `xwrite_stdout` declared as an external with NO body verified here (trust
  boundary, see `RESULTS.md`); `head_bytes_entry` one-call export wrapper
  (CompCert drops an unreferenced `static` function, same issue
  `simple_cat_entry` solved in `utility-reuse`).
- `wc_lines_fragment.c`: fixed-arity `error`; `quotef`/`quotearg_n_style_colon`
  reproduced identically to `cat_fragment.c`'s copy; `rawmemchr` declared but
  never called under this proof's `!long_lines` domain restriction (see
  `CASE-BRIEF.md`'s "Honest slice"); `wc_lines_entry` export wrapper.

## Frontend (CompCert 3.15 `clightgen`, container `phase5-vst`)

Same command as `utility-reuse/PROVENANCE.md`:
```
clightgen -normalize -dprepro -nostdinc -Iinclude -I/home/coq/.opam/4.13.1+flambda/lib/compcert/include -std=c11 -fnone <tu>.c
```
Receipts `case4-clightgen-2` (head_bytes_fragment.c, exit 0, after the
correction above), `case4-clightgen-3` (wc_lines_fragment.c, exit 0).
Generated ASTs in `generated/` with `generated/SHA256SUMS`; both TUs' `.v`
files contain `f_head_bytes`/`f_head_bytes_entry` and
`f_wc_lines`/`f_wc_lines_entry` respectively (checked by `grep -c`).
