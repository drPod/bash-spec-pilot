# GNU `simple_cat` + gnulib I/O wrappers on generalized contracts

Reuse scheduled I/O contracts, generalized from the purpose-built relay, on real gnulib `safe_read`/`safe_write`/`full_write` and a byte-identical `simple_cat` fragment.

Five `semax_body` theorems accepted: `body_safe_read`, `body_safe_write`, `body_full_write`, `body_simple_cat`, `body_simple_cat_entry`, plus `Summary.wrapper_chain` and cross-TU funspec agreement. Four TUs are VST-linked (`SafeReadVSU`/`SafeWriteVSU`/`FullWriteVSU`/`CatFragmentVSU` via `linkVSUs` in `LinkAll.v`, `AllVSU`). Remaining imports are five trust-boundary specs. `Print Assumptions AllVSU`: standard VST/CompCert axioms only.

Not GNU cat binary/CLI/`main`; not host syscalls; not termination; not the Lean script fragment. Details: [`RESULTS.md`](RESULTS.md), reuse: [`REUSE.md`](REUSE.md), provenance: [`PROVENANCE.md`](PROVENANCE.md).

Layout:

- `src/pinned/` verbatim upstream + `SHA256SUMS`; `src/tu/` adapters and `simple_cat.frag.c` (`FRAGMENT.json`; `extract_fragment.py`).
- `generated/` CompCert 3.15 `clightgen -normalize` output.
- `coq/` development (`IOWorld.v`, `IOSpecs.v`, body files, VSUs, `LinkAll.v`, `Summary.v`, `Audit.v`). `CatFragmentVSU_diag*.v`, `CatFrag_gp_*.v`, `FlushProbe.v` are diagnostic-only (some `Admitted`); not evidence.
- `tests/` host gcc differential tests against a Python transliteration of `IOWorld.v`; results outside the repository.

## Replay (repository root; `phase5-vst` idle; fresh run names)

```sh
U=research/libc-specs/phase5/utility-reuse
docker exec phase5-vst mkdir -p /home/coq/phase5/utility-reuse/include/sys
for f in $(cd $U/src/tu && ls *.c *.h); do docker cp $U/src/tu/$f phase5-vst:/home/coq/phase5/utility-reuse/$f; done
for f in config.h errno.h limits.h unistd.h; do docker cp $U/src/tu/include/$f phase5-vst:/home/coq/phase5/utility-reuse/include/$f; done
docker cp $U/src/tu/include/sys/types.h phase5-vst:/home/coq/phase5/utility-reuse/include/sys/types.h
uv run --no-project python research/libc-specs/phase5/run_vst.py --name utility-clightgen-replay --seconds 60 --workdir /home/coq/phase5/utility-reuse -- sh -c 'for f in safe_read safe_write full_write cat_fragment; do clightgen -normalize -dprepro -nostdinc -Iinclude -I/home/coq/.opam/4.13.1+flambda/lib/compcert/include -std=c11 -fnone $f.c || exit 1; done; sha256sum *.v *.i'
ORDER="IOWorld IOSpecs SafeReadBody SafeWriteBody FullWriteBody CatBody CatEntryBody SafeReadVSU SafeWriteVSU FullWriteVSU CatFragmentVSU LinkAll Summary Audit"
for f in $ORDER; do docker cp $U/coq/$f.v phase5-vst:/home/coq/phase5/utility-reuse/$f.v; done
for f in safe_read safe_write full_write cat_fragment $ORDER; do
  uv run --no-project python research/libc-specs/phase5/run_vst.py --name utility-replay-$f --seconds 600 \
    --workdir /home/coq/phase5/utility-reuse -- coqc -Q ../relay "" -Q . "" $f.v
done
```

Do not wrap `coqc` in a pipe or a `for` loop inside one `sh -c`. `coq/` requires compiled `../relay` (`Protocol`, `Specs`, `Body`, `Conservation`). Differential tests:

```sh
flock "$HOME/.cache/bash-spec-pilot/phase3-compiler.lock" python3 research/libc-specs/phase5/utility-reuse/tests/run_tests.py --cases 2000 --out <dir outside the repo>
```
