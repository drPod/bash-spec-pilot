# Negative controls for the relay body proof

Hand-mutated copies of generated `relay.v`; not produced from C and not a program claim. They check that unchanged `Specs.v` plus the `Body.v` script reject two mutations from RELAY-VST-DESIGN.md §7. A failing `coqc` is the expected result.

| File | Mutation | Run (2026-09-07) | Result |
|---|---|---|---|
| `relay_mut_ptr.v` | `write(1, buf, n-off)` instead of `write(1, buf+off, n-off)` | `control-mut-ptr-ast-coqc-1` | AST accepted (exit 0) |
| `ControlPtr.v` | Specs + Body script on the pointer mutant | `control-ptr-body-coqc-1` | **fails** (exit 1) at the write-call argument: `v_buf` vs required `offset_val off v_buf` |
| `relay_mut_retry.v` | `if (w < 0) return 2;` instead of `if (w <= 0) return 2;` | `control-mut-retry-ast-coqc-1` | AST accepted (exit 0) |
| `ControlRetry.v` | Specs + Body script on the retry mutant | `control-retry-body-coqc-1` | **fails** (exit 1) at `apply write_data`: `reaches` has no zero-result write constructor |

A zero write consumes a schedule action and increments `write_calls` while leaving `off` unchanged. `outcome` is the graph of deterministic `run` (`Determinism.v`); a zero write is always `Halt 2`. A valid world with write schedule `[0; k]`, `k > 0`, yields a world with no `reaches` derivation, so `relay_spec`’s postcondition is unprovable. Non-terminating all-zero schedules have no postcondition obligation, which is why `Progress.v` is separate. This paragraph is an argument; checked facts are the two `coqc` failures and `Determinism.v` / `Distinguish.v`.

```sh
for f in relay_mut_ptr relay_mut_retry ControlPtr ControlRetry; do docker cp research/libc-specs/phase5/relay/controls/$f.v phase5-vst:/home/coq/phase5/relay/$f.v; done
uv run --no-project python research/libc-specs/phase5/run_vst.py --name control-mut-ptr-ast-replay --seconds 120 --workdir /home/coq/phase5/relay -- coqc relay_mut_ptr.v
uv run --no-project python research/libc-specs/phase5/run_vst.py --name control-ptr-body-replay --seconds 600 --workdir /home/coq/phase5/relay -- coqc ControlPtr.v   # expected exit 1
uv run --no-project python research/libc-specs/phase5/run_vst.py --name control-mut-retry-ast-replay --seconds 120 --workdir /home/coq/phase5/relay -- coqc relay_mut_retry.v
uv run --no-project python research/libc-specs/phase5/run_vst.py --name control-retry-body-replay --seconds 600 --workdir /home/coq/phase5/relay -- coqc ControlRetry.v   # expected exit 1
```
