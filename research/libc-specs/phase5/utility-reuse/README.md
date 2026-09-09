# utility-reuse: GNU `simple_cat` + gnulib `safe_read`/`safe_write`/`full_write` on generalized I/O contracts

Real-utility / reusable-libc workstream of phase 5.

**Status (2026-09-07 20:38 UTC):** all five `semax_body` theorems are accepted
by direct `coqc` runs: `body_safe_read`, `body_safe_write`, `body_full_write`,
`body_simple_cat`, `body_simple_cat_entry`, plus the bundled
`Summary.wrapper_chain` and the cross-TU funspec agreement lemmas; `Audit.v`
shows only standard VST/CompCert axioms. **The four TUs are now VST-linked**:
`SafeReadVSU`/`SafeWriteVSU`/`FullWriteVSU`/`CatFragmentVSU` (per-TU `VSU`s)
compose via VST's real `linkVSUs` (`LinkAll.v`, `AllVSU`) into one component
whose only remaining imports are the five trust-boundary leaf/external specs;
`Print Assumptions AllVSU` shows only standard axioms. See
[RESULTS.md](RESULTS.md) for receipts, exact scope and what stays assumed
(leaf `read`/`write` contracts, coreutils externals, no GNU cat binary/CLI/
`main`/termination claim). [REUSE.md](REUSE.md) lists the relay objects reused
literally versus what is newly authored, and how the two body proofs are
reused unchanged inside `CatFragmentVSU.v` via a Gprog-widening lemma.

Layout:

- `src/pinned/` verbatim upstream files + `SHA256SUMS`; `src/tu/` translation
  units, declaration adapters (`include/`), byte-extracted fragment
  (`simple_cat.frag.c`, `FRAGMENT.json`); `extract_fragment.py` reproduces it.
  Provenance and adapter deviations: [PROVENANCE.md](PROVENANCE.md).
- `generated/` CompCert 3.15 `clightgen -normalize` output (`*.v`) and
  preprocessed input (`*.i`) for the four TUs, with `SHA256SUMS`.
- `coq/` the development: `IOWorld.v` (generalized world, wrapper relations,
  functional theorems), `IOSpecs.v` (funspecs), `SafeReadBody.v`,
  `SafeWriteBody.v`, `FullWriteBody.v`, `CatBody.v`, `CatEntryBody.v`
  (`semax_body` proofs), `Summary.v` (identifier/funspec agreement across
  TUs, bundled chain), `Audit.v` (`Print Assumptions`), `SafeReadVSU.v`/
  `SafeWriteVSU.v`/`FullWriteVSU.v`/`CatFragmentVSU.v` (per-TU VST `VSU`
  components, VST's own `mkVSU`/`mkComponent` automation reused for 9 of
  10 proof obligations — see `CatFragmentVSU.v`'s header comment for the
  one that needed a hand-written replacement, and why), `LinkAll.v` (the
  four VSUs combined via `linkVSUs`, `AllVSU`). `CatFragmentVSU_diag.v`,
  `CatFragmentVSU_diag2.v`, `CatFrag_gp_*.v`, `FlushProbe.v` are
  diagnostic-only bisection files (some end in `Admitted`, one in a `Qed`
  that never actually ran to completion because of an unrelated missing
  bullet) — not evidence, not part of any accepted receipt table.
- `tests/` differential tests of the frozen C sources (host gcc, mock syscalls
  with the model's schedule semantics) against a Python transliteration of
  `IOWorld.v`; results are written outside the repository.

## Replay (repository root; container `phase5-vst` idle; fresh run names)

```sh
U=research/libc-specs/phase5/utility-reuse
docker exec phase5-vst mkdir -p /home/coq/phase5/utility-reuse/include/sys
for f in $(cd $U/src/tu && ls *.c *.h); do docker cp $U/src/tu/$f phase5-vst:/home/coq/phase5/utility-reuse/$f; done
for f in config.h errno.h limits.h unistd.h; do docker cp $U/src/tu/include/$f phase5-vst:/home/coq/phase5/utility-reuse/include/$f; done
docker cp $U/src/tu/include/sys/types.h phase5-vst:/home/coq/phase5/utility-reuse/include/sys/types.h
uv run --no-project python research/libc-specs/phase5/run_vst.py --name utility-clightgen-replay --seconds 60 --workdir /home/coq/phase5/utility-reuse -- sh -c 'for f in safe_read safe_write full_write cat_fragment; do clightgen -normalize -dprepro -nostdinc -Iinclude -I/home/coq/.opam/4.13.1+flambda/lib/compcert/include -std=c11 -fnone $f.c || exit 1; done; sha256sum *.v *.i'
# compare with generated/SHA256SUMS, then compile each file with its own direct receipt
# (order matters: this is the real Require dependency chain, ending with the
# VSU link — LinkAll.v — before the identifier/assumption audits):
ORDER="IOWorld IOSpecs SafeReadBody SafeWriteBody FullWriteBody CatBody CatEntryBody SafeReadVSU SafeWriteVSU FullWriteVSU CatFragmentVSU LinkAll Summary Audit"
for f in $ORDER; do docker cp $U/coq/$f.v phase5-vst:/home/coq/phase5/utility-reuse/$f.v; done
for f in safe_read safe_write full_write cat_fragment $ORDER; do
  uv run --no-project python research/libc-specs/phase5/run_vst.py --name utility-replay-$f --seconds 600 \
    --workdir /home/coq/phase5/utility-reuse -- coqc -Q ../relay "" -Q . "" $f.v
done
# acceptance = every receipt ~/agent-jobs/astra-research/phase5/runs/utility-replay-<f>.json has "exit_status": 0
```

Do not wrap `coqc` in a pipe or a `for` loop inside one `sh -c`: the recorded
exit status would then be the pipe's/loop's, not the compiler's.

`coq/` requires the compiled relay development (`../relay`: `Protocol`, `Specs`,
`Body`, `Conservation` and their dependencies) because it reuses those modules
literally. Differential tests build with host gcc and must hold the shared compiler lock:

```sh
flock "$HOME/.cache/bash-spec-pilot/phase3-compiler.lock" python3 research/libc-specs/phase5/utility-reuse/tests/run_tests.py --cases 2000 --out <dir outside the repo>
```
