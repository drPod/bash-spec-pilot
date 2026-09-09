# Source provenance and frontend record

All identities were verified locally (`src/pinned/SHA256SUMS`, `src/tu/SHA256SUMS`,
`generated/SHA256SUMS`). Nothing in `src/pinned/` or the verbatim copies in
`src/tu/` was edited.

## Pinned upstream sources

| Object | Identity |
|---|---|
| coreutils commit (tag `v9.4`) | `9530a14420fc1a267e90d45e8a0d710c3668382d` |
| `src/cat.c` | sha256 `f52880ce866aa8f95d5830851054755d9d58e0e750905632e2db0a0378726983` |
| `src/system.h` (same commit; source of `quotef`, `write_error`) | sha256 `0b9e8b999938518643a782b9e08c6b27699fb5de1729f2c6241c497848436b0e` |
| gnulib submodule commit | `bb5bb43a1ebb9f502b5ce38c0b8c8778d13b9f6e` |
| `lib/safe-read.c` | `f74513daf89644aa8b048d239d04509a66ff68098b808cc7e2d5e945e99810d5` |
| `lib/safe-read.h` | `8dd428a89bad92c9b8c1363c8705cc73a8f2769994dbee602f1cbc981829a83c` |
| `lib/safe-write.c` | `165d1a742410921c5d8674e85dc304efa00d5fb1b34ba01bb4af6e9dc423737b` |
| `lib/safe-write.h` | `cd1a27cf23e70c934906cae9ddfcee9a760362cea1071e026959e4401909924a` |
| `lib/full-write.c` | `1c69aa16ee892532e2a49568385df119ffcdb60c548b61c5cc7a1eb93dc23dbb` |
| `lib/full-write.h` | `db2f47fd581edbe3923b23b23696a0006c37fff4c8938bc890a6be242cf4d3de` |
| `lib/sys-limits.h` | `41eac6654ef4f7f2d3f147d1c385e24a47cf3595d3450b6cfc5821844de4c796` |
| `lib/quotearg.h` (enum order, prototype) | `cfb2bcad09df3e792d60bfde4e16989d44213f5f44464cbc17f16958b1fc7a5c` |
| `lib/idx.h` (`typedef ptrdiff_t idx_t`) | `00f859b9ffb287b6f3b61b2cfd64938306aa4504162f3156571de493e0a082e8` |
| `lib/error.in.h` (variadic `error` declaration) | `ddbda46dc7ee8f493024b07dd3699b1a08de1a937cebeb49453582f53a17655d` |

The gnulib `.c`/`.h` files and `sys-limits.h` are compiled byte-identical
(`src/tu/*.c`, `src/tu/*.h` hashes equal the pinned ones). The cat fragment
(`src/tu/simple_cat.frag.c`) is `cat.c` bytes `[4362, 5085)` = lines 152–182
inclusive (doc comment through closing brace), 723 bytes, sha256
`503c39fff31698fdf373c82ec2a1a9b8bed6874e07cb3443e3034558960984f8`, extracted
and token-checked (82 C tokens equal to the source region) by
`extract_fragment.py`; record in `src/tu/FRAGMENT.json`.

## Translation units and adapters (`src/tu/`)

- `safe_read.c`, `safe_write.c`, `full_write.c`: one-line `#include` wrappers
  giving the frozen files Coq-compatible module names (gnulib's own
  `safe-write.c` uses the same technique).
- `cat_fragment.c`: declaration context + `#include "simple_cat.frag.c"`.
- `include/config.h` (empty), `include/errno.h` (`extern int errno`, Linux
  `EINTR=4`, `EINVAL=22`, `ENOSPC=28`), `include/limits.h` (`INT_MAX`),
  `include/sys/types.h` and `include/unistd.h` (`ssize_t`, `read`, `write`,
  `STDOUT_FILENO`; same declarations as the relay adapter): declaration-only
  adapters, no code, no behavior. CompCert's own `stddef.h`
  (sha256 `b94b9d8485408cab3737f25edf527f82f1f954f2ba329d288f6d55744ac6ad7b`)
  and `stdbool.h` (`538dd2199192325ca856e5186576e0d4e6330b260aee28d939290cc9c21b2f9d`).

Explicit adapter deviations (all in `cat_fragment.c`, all outside the fragment):

1. `error` declared with the fixed arity of the fragment's single call
   `(int, int, const char *, const char *)` instead of variadic. Reason: VST 2.15
   cannot reason about vararg calls (`floyd/forward.v`: "vararg function
   definitions are not supported"). The fragment's tokens are unchanged.
2. `write_error` declared as an external `void write_error (void)` instead of
   including system.h's `static inline` body (which calls `fflush`, `fpurge`,
   `clearerr`, then `error (EXIT_FAILURE, ...)`, i.e. exits). Its funspec asserts
   non-return.
3. `simple_cat_entry`, an exported one-call wrapper appended after the include,
   because CompCert's frontend drops an unreferenced `static` function (observed:
   run `utility-clightgen-1` produced no `f_simple_cat`). The theorem is about
   `f_simple_cat`; the wrapper is not verified.

`quotef` is reproduced as the exact macro from system.h:813–814 and
`quotearg_n_style_colon` with the exact prototype from quotearg.h:408; the
`enum quoting_style` enumerator list is copied in order (comments removed), so
`shell_escape_quoting_style` = 3 as upstream.

## Frontend (CompCert 3.15 `clightgen`, container `phase5-vst`)

Command (per TU, workdir `/home/coq/phase5/utility-reuse`):

```
clightgen -normalize -dprepro -nostdinc -Iinclude -I/home/coq/.opam/4.13.1+flambda/lib/compcert/include -std=c11 -fnone <tu>.c
```

`clightgen` sha256 `7219a47562eb2e99c75a7d9dc52ef2b7e9f174cbece2f3fdeff5340de344672f`
(same binary as the relay record). Target: x86-64 Linux, LP64 (`size_t`/
`idx_t` are `tulong`/`tlong`, `ssize_t` is `tlong`). Receipts:
`utility-clightgen-1` (four TUs), `utility-clightgen-2` (cat_fragment after
deviation 3). Generated ASTs and preprocessed inputs are in `generated/` with
`generated/SHA256SUMS`:

| File | sha256 |
|---|---|
| `safe_read.v` | `edec926b76c65fb678b51282b89fbfc8f5de56713ea8e7a83d7816b2878f51ac` |
| `safe_write.v` | `e90500fd35844997d0afa63effb89fe5950626011208c2eb615887aa2c89279f` |
| `full_write.v` | `1599cde0e9752ecaf522aa8ad8a58c52e6ae561a70e0981d2a4a6004f430cfa1` |
| `cat_fragment.v` | `9e0c2ca3f2f91a60327a8ba3ff7e5e0aa5bccb13546d7999e1d9e3932a5a3fc4` |

Generation is not a translation-correctness theorem (see `../FRONTEND.md`). The
source-audit of the generated `f_simple_cat`: `safe_read (input_desc, buf,
bufsize)` with `bufsize : tlong` passed to a `tulong` parameter; the error test is
`n_read == (unsigned long)(-1)`; `error (0, errno, "%s", quotearg_n_style_colon
(0, 3, infile))`; `full_write (1, buf, n_read) != n_read` then `write_error ()`.
`f_safe_write` is textually identical to `f_safe_read` modulo the two names.
