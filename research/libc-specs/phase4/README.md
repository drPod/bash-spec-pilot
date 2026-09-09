# Phase4: backend adoption decision and checked reuse probe

**Choose VST/CompCert for the main C proof path.** Use VeriFast as a contract-development
comparator and AutoCorres2 as the fallback. [DECISION.md](DECISION.md) explains the evidence,
tradeoffs, Lean boundary and remaining obligations. [VST-PILOT.md](VST-PILOT.md) specifies
its first semantic acceptance test; the VST toolchain has not yet been built here.

Completed evidence: pinned VeriFast26.01 verifies the unchanged relay C body with memory
annotations using existing ownership libraries; two oversized-access controls reject,
while wrong-byte and zero-progress controls demonstrate the weak contract's limits.
The upstream buffered-I/O example also verifies. [results.json](results.json) records all
six outcomes and [backend-lock.json](backend-lock.json) records versions and provenance.

Reproduce with the official Linux VeriFast26.01 distribution already extracted locally:

```sh
uv run --no-project python -B research/libc-specs/phase4/check_adoption.py
```

Use `--toolchain /path/to/verifast-26.01` if needed; the checker validates the executable
hash. The default is `~/.cache/bash-spec-pilot/toolchains/verifast-26.01`. This script
installs nothing, runs sequentially under a compiler lock and1.5GiB/60s per-command limits,
and writes bounded logs outside source under `~/.cache/bash-spec-pilot/phase4-adoption`.
The package's download URL/hash is in backend-lock.json. No unsafe VeriFast options enabled.

The supplied unistd contracts are assumptions, not host libc specifications. `-c` is
modular verification and does not prove the external functions. The relay postcondition
is only a result range; no byte-stream, EOF or termination theorem is claimed here.
This phase makes a backend decision and demonstrates actual library reuse; it does not
claim completed VST verification, a kernel certificate from VeriFast, or new I/O theory.
