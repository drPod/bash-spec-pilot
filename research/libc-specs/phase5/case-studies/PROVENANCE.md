# Source and frontend provenance (`head_bytes` / `wc_lines`)

## Pinned identities

Same pins as [`../utility-reuse/PROVENANCE.md`](../utility-reuse/PROVENANCE.md):

- coreutils `9530a14420fc1a267e90d45e8a0d710c3668382d` (v9.4)
- gnulib `bb5bb43a1ebb9f502b5ce38c0b8c8778d13b9f6e`

`src/pinned/coreutils/head.c`, `wc.c` and `src/pinned/gnulib/*` are byte-identical to the freeze in `pi-reviews/nonutf8-case-selection-4/frozen/` (`sha256sum -c` OK for all 18 entries). `src/tu/FRAGMENTS.json` (from `extract_fragments.py`) records byte ranges and hashes for the three extracted fragments.

## `head_bytes` line-range correction

The frozen brief `CASE-BRIEF.md` listed `head_bytes` as `head.c` 774–796 inclusive, hash `ebdb38f174c0bcc25e4cc6e1aa98eb1ea3bf8ed29a2f8165b1cd0b0d6e6a4414`. Line 796 is `return true;`; the closing `}` is line 797. Extracting 774–796 and running the directory’s `clightgen` command fails (`case4-clightgen-1`, exit 2: unbalanced brace). The complete function is 774–797, fragment hash `ae9f42de06cf55ca1bfcc8720986b32f8c8d14b8063af8374dece0b886bbc4b7`. `wc_lines` (`wc.c` 266–330) and `xwrite_stdout` (`head.c` 176–189, provenance only) match the pinned sources as recorded.

## Adapter translation units

`src/tu/head_bytes_fragment.c` and `src/tu/wc_lines_fragment.c` put declaration-only adapter context above an unedited `#include` of the extracted fragment (same convention as `../utility-reuse/src/tu/cat_fragment.c`). Adapter deviations, documented inline:

- **head_bytes:** fixed-arity `error` (one call site, four args); `quoteaf` as a 1-arg pure external; `xwrite_stdout` declared, body not verified (trust boundary, [`RESULTS.md`](RESULTS.md)); `head_bytes_entry` one-call export wrapper (CompCert drops an unreferenced `static`).
- **wc_lines:** fixed-arity `error`; `quotef`/`quotearg_n_style_colon` as in `cat_fragment.c`; `rawmemchr` declared but unused under this proof’s `!long_lines` restriction; `wc_lines_entry` export wrapper.

## Frontend (CompCert 3.15 `clightgen`, container `phase5-vst`)

Same command as utility-reuse:

```
clightgen -normalize -dprepro -nostdinc -Iinclude -I/home/coq/.opam/4.13.1+flambda/lib/compcert/include -std=c11 -fnone <tu>.c
```

Receipts: `case4-clightgen-2` (`head_bytes_fragment.c`, exit 0, after the line-range correction), `case4-clightgen-3` (`wc_lines_fragment.c`, exit 0). Generated ASTs in `generated/` with `generated/SHA256SUMS`. Both `.v` files contain `f_head_bytes`/`f_head_bytes_entry` and `f_wc_lines`/`f_wc_lines_entry` respectively.
