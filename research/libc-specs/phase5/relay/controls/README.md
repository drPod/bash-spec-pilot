# Negative controls for the relay body proof

These files are **hand-mutated copies of the generated `relay.v`**; they were
not produced from any C source and make no claim about any program. Their sole
purpose is to check that the unchanged `Specs.v` contracts plus the unchanged
`Body.v` proof script reject two mutations discussed in
RELAY-VST-DESIGN.md §7. A failing `coqc` here is the expected result; it shows
the *script* fails, and for the retry mutant additionally why no derivation of
the abstract relation can exist (argument below, not a checked theorem).

| File | Mutation | Run (2026-09-07) | Result |
|---|---|---|---|
| `relay_mut_ptr.v` | `write(1, buf, n-off)` instead of `write(1, buf+off, n-off)` | `control-mut-ptr-ast-coqc-1` | AST accepted (exit 0) |
| `ControlPtr.v` = Specs.v + Body.v script on it | — | `control-ptr-body-coqc-1` | **fails** (exit 1) at the write call's argument obligation: the passed pointer `v_buf` cannot be matched with the required `offset_val off v_buf` (`entailer!` leaves `[…; v_buf; …] = […; offset_val off v_buf; …]` open; in the genuine proof this goal is closed automatically) |
| `relay_mut_retry.v` | `if (w < 0) return 2;` instead of `if (w <= 0) return 2;` (zero-length write retried) | `control-mut-retry-ast-coqc-1` | AST accepted (exit 0) |
| `ControlRetry.v` = Specs.v + Body.v script on it | — | `control-retry-body-coqc-1` | **fails** (exit 1) at `apply write_data` in the loop-advance branch: the else branch only knows `0 <= w`, and `reaches` has no constructor for a zero-result write, so the inner invariant `reaches initial (Drain chunk off) t'` cannot be re-established for the post-call world `t'` |

Why the retry mutant is excluded by the contract, not just by this script: a
zero write consumes a schedule action and increments `write_calls` while
leaving `off` unchanged. `outcome` is the graph of the deterministic `run`
(`Determinism.v`), in which a zero write is always `Halt 2`. Any valid world
whose write schedule is `[0; k]` with `k > 0` makes the mutant return with a
world that no `reaches` derivation produces, so `relay_spec`'s postcondition
is unprovable for it by any invariant. The only mutant executions with no
postcondition obligation are the non-terminating ones (schedules of zeros
forever), which is why `Progress.v` is a separate obligation. This paragraph is
an argument; the checked facts are the two `coqc` failures and the theorems in
`Determinism.v`/`Distinguish.v`.

Replay (repository root, container idle; fresh names):

```sh
for f in relay_mut_ptr relay_mut_retry ControlPtr ControlRetry; do docker cp research/libc-specs/phase5/relay/controls/$f.v phase5-vst:/home/coq/phase5/relay/$f.v; done
uv run --no-project python research/libc-specs/phase5/run_vst.py --name control-mut-ptr-ast-replay --seconds 120 --workdir /home/coq/phase5/relay -- coqc relay_mut_ptr.v
uv run --no-project python research/libc-specs/phase5/run_vst.py --name control-ptr-body-replay --seconds 600 --workdir /home/coq/phase5/relay -- coqc ControlPtr.v   # expected exit 1
uv run --no-project python research/libc-specs/phase5/run_vst.py --name control-mut-retry-ast-replay --seconds 120 --workdir /home/coq/phase5/relay -- coqc relay_mut_retry.v
uv run --no-project python research/libc-specs/phase5/run_vst.py --name control-retry-body-replay --seconds 600 --workdir /home/coq/phase5/relay -- coqc ControlRetry.v   # expected exit 1
```
