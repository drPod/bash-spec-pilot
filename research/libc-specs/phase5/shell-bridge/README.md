# Shell bridge: Coq composition over `outcome`, and a bounded text frontend

Instantiate the generic shell `exec` relation with the relay contract’s `outcome` predicate, and parse a restricted command fragment into that AST.

Checked by Coq 8.20.1 (`phase5-vst`, CompCert 3.15, VST 2.15) via `../run_vst.py`. 44 `Print Assumptions` reports closed (`shell-bridge-final-ShellAudit`). No Lean import into Coq.

Not Bash processes, pipes, or fds; `Mark` assumes a successful write; `semax_body` is partial correctness; lexer/parser completeness unproved; identification with Bash `parse.y` is inspection plus 29+28 directed and 200 random tests.

Receipts: `~/agent-jobs/astra-research/phase5/runs/`; `results/receipts.json`.

| File | Receipt (exit 0) | Content |
|---|---|---|
| `Shell.v` | `shell-bridge-final-Shell` (0.66 s, 485,660 KiB) | grammar + `exec`; `command_refines`/`query_transfer`; `RelayReach.outcome`; ledger; status-sensitive query |
| `Parse.v` | `shell-bridge-final-Parse` | `body_derives`, fuel parser, `parse_program_sound`, `run_reachable` |
| `Fixtures.v` | `shell-bridge-final-Fixtures` | 29 accepted / 28 rejected texts |
| `Bridge.v` | `shell-bridge-final-Bridge` | `relay_command`; `relay && mark`, `relay ; relay` |
| `Lex.v` | `shell-bridge-final-Lex` | `lex_sound` / `parse_program_sound_chars` |
| `RandomFixtures.v` | `shell-bridge-final-RandomFixtures` | 200 random texts, seed 1, bash as oracle |
| `ShellAudit.v` | `shell-bridge-final-ShellAudit` (4.52 s) | `Print Assumptions` |

Depends on compiled `../relay` `Protocol`/`Reach`/`ReachExamples`/`Conservation` (not `Specs.v`; link is identity of `outcome`).

| File | sha256 |
|---|---|
| `Shell.v` | `dbf72d607d46ef37ffbb992271781d26133a055b7bf219cca5fadff19076c8af` |
| `Parse.v` | `c25385f59fddf0f08c4731f2dadd2aa5c09b3737bc2209526b766f6a73a3613e` |
| `Fixtures.v` | `28c9e797a1a34c720207b1927906719e5a0dda7f7811850695d26638f6ea9f08` |
| `text_fixtures.json` | `7d4834a5a4506c0277188f1a2dedb1bf8c77bf26e0073e4307aa8ea31f04da14` |
| `Lex.v` | `9b1997bc9ad70e79a6acca5c188d0bdb81c8a551a94cf408ef4069519a3a5d0d` |
| `Bridge.v` | `b81849cf2f5660c41a2120e2caca1d76be5992726ce3b8dcde683d04d0cecbae` |
| `RandomFixtures.v` | `fcf4e5618abb3ab4486c11e659667f7630be0b496852649770749527f2b5ef78` |
| `validate_text.py` | `96db1cf948b098e4ff4ffb21a63325d68c197ae758003d9cf26c589cc912ef10` |
| `ShellAudit.v` | `e899fd25071b732e0435b193a68c674c575ba7080638f72c445c07b75a54152a` |
| `../relay/Protocol.v` | `1f5b6364d0933dfe4ca23a18d5e666aafabde9aade6d567b22fbabac0660da4d` |
| `../relay/Reach.v` | `24b5d01b171c34f509b13ae813b1487c914e05f03581de3cb5a184846979a98b` |
| `../relay/ReachExamples.v` | `459a65ed55cfac11c4a693ecdb6d71ea0e7439617248a50d8bdf1629ae390344` |
| `../relay/Conservation.v` | `3ff4b6385a070652af2d6fd8e442d2bb4c79656a838cf2dd4cecfbdbcabdffc7` |
| `../relay/Specs.v` | `b1c6b3bc0aaba46a4c0a3dfee31c0cbf3948a07505a53080e196d1e1296f4359` |

## Shell layer uses the funspec postcondition

Relay POST: `PROP (outcome initial status final pending)`. `Body.v` proves `semax_body … f_relay relay_spec` (`relay-body-coqc-16`). Shell primitive:

```coq
Relay => exists pending, outcome (os s) rc (os t) pending /\ lost t = lost s ++ pending
```

`Mark b` is a successful one-byte stdout write (failure modes out of model). Grammar: `call`, `seq`, `and_then`, `or_else`. Bytes are CompCert `byte`.

Theorems (`ShellComposition`): `command_refines`, `query_transfer`; `exec_ledgers`; `exec_relay_only_conservation`; `relay_then_mark_query` (for every initial state: success delivers unread then `b` with nothing lost; status 1/2 omits marker, pending empty iff status 1). Nonvacuity: `late_error_exec`, `success_exec`, `same_relay_bytes` / `different_composed_bytes` / `no_stdout_only_context`, `pending_lost_then_fresh_relay`, `nul255_exec`.

Not established: Bash process/pipe/fd; C-loop termination; host `read`/`write`; Lean/Coq agreement.

## Text frontend

Accepted fragment: identifiers `[A-Za-z_][A-Za-z0-9_]*` excluding reserved words; no arguments/expansions; `;`, `&&`, `||`; parentheses; spaces/tabs. Precedence as Bash `parse.y`. Rejected: newlines, `|`, `&`, redirections, quotes, `$`, `#`, `!`, braces, `((`, non-ASCII, digits-first names, assignments.

`parse_program_sound : parse_program s = Some c -> exists toks, lex_string s = Some toks /\ body_derives toks c`. `lex_string s = Some toks -> renders toks (list_of_string s)` (maximal munch). Completeness and uniqueness unproved. `( c )` denotes `c` (no subshell-local state).

Differential (`validate_text.py bash`, bash 5.2.21, `LC_ALL=C`): 29/29 accepted texts match Coq `run test_env`. Of 28 rejected, `bash -n` accepts 19. First version accepted `((t))` as nested grouping; Bash lexes `((` as arithmetic — lexer now rejects adjacent `((`. Random: 200 texts, seed 1 (`results/random_validation.json`). Finite tests only.

`relay_command "relay && mark" = Some (relay_then_mark bang)` hence `relay_and_mark_text_query`. Names bound by a modelling map, not Bash lookup.

## Replay

```sh
docker exec phase5-vst mkdir -p /home/coq/phase5/shell-bridge
python3 research/libc-specs/phase5/shell-bridge/validate_text.py gen
python3 research/libc-specs/phase5/shell-bridge/validate_text.py bash
python3 research/libc-specs/phase5/shell-bridge/validate_text.py random --count 200 --seed 1
for f in Shell Parse Fixtures Bridge RandomFixtures Lex ShellAudit; do docker cp research/libc-specs/phase5/shell-bridge/$f.v phase5-vst:/home/coq/phase5/shell-bridge/$f.v; done
for f in Shell Parse Fixtures Bridge RandomFixtures Lex ShellAudit; do uv run --no-project python research/libc-specs/phase5/run_vst.py --name shell-bridge-$f-replay --seconds 300 --workdir /home/coq/phase5/shell-bridge -- coqc -Q /home/coq/phase5/relay "" $f.v; done
```

Requires relay README replay first. Audit log: `results/audit-final.log`. C-to-Clight trusted (`../integration/PROOF-CHAIN.md`). GNU `simple_cat` is a separate Coq study, not this frontend.
