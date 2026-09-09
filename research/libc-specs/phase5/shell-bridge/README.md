# Shell bridge: Coq shell composition over the actual relay contract, and a bounded shell-text frontend

Date: 2026-09-07. Worker: Claude CLI (shell-bridge), collaborative agent development under
orchestrator direction; no controlled generation trial. Everything here is checked by Coq
8.20.1 in the shared `phase5-vst` container (CompCert 3.15, VST 2.15) through
`../run_vst.py`, or is a host `bash` differential test whose scope is stated. Nothing is
committed, nothing upstream is touched, no Lean file is imported into Coq.

## What is checked (receipts in `~/agent-jobs/astra-research/phase5/runs/`; the `shell-bridge-final-*` chain was compiled in this order from the final file bytes; earlier iterations incl. failures are listed in `results/receipts.json`)

| File | Receipt (exit 0) | Content |
|---|---|---|
| `Shell.v` | `shell-bridge-final-Shell` (0.66 s, 485,660 KiB) | grammar + exec relation (port of phase3 `ShellObservation`), generic `command_refines`/`query_transfer`, instantiation with `RelayReach.outcome`, ledger theorems, status-sensitive query, nonvacuous examples |
| `Parse.v` | `shell-bridge-final-Parse` (0.65 s, 482,836 KiB) | precedence-stratified grammar relation `body_derives`, fuel recursive-descent parser, `parse_program_sound`, validation evaluator `run` with `run_reachable` |
| `Fixtures.v` (generated) | `shell-bridge-final-Fixtures` (0.63 s, 484,900 KiB) | 29 accepted texts: `parse_program "<text>" = Some <ast>` and `run test_env <ast> "" = (<status>, "<stdout>")`; 28 rejected texts: `parse_program "<text>" = None`; one `body_derives` witness via soundness |
| `Bridge.v` | `shell-bridge-final-Bridge` (0.49 s, 434,580 KiB) | `relay_command` = parse + name map to relay atoms; literal texts `relay && mark`, `relay ; relay` yield exactly the query/witness commands; pipe/redirect/unknown names yield `None` |
| `Lex.v` | `shell-bridge-final-Lex` (0.61 s, 483,992 KiB) | lexer soundness: `lex_sound`/`lex_string_sound` (tokens are a maximal-munch tokenization `renders` of the characters), `parse_program_sound_chars` (characters -> tokens -> AST through two inductive relations) |
| `RandomFixtures.v` (generated) | `shell-bridge-final-RandomFixtures` (1.66 s, 486,660 KiB) | 200 random fragment texts (seed 1); Coq's `parse_program` + `run test_env` reproduces real bash's actual exit status and stdout for each (bash is the oracle) |
| `ShellAudit.v` | `shell-bridge-final-ShellAudit` (4.52 s, 512,956 KiB) | `Print Assumptions` of every theorem above on the accepted files |

Dependencies: the relay worker's compiled `Protocol.vo`, `Reach.vo`, `ReachExamples.vo`,
`Conservation.vo` in `/home/coq/phase5/relay` (sources `../relay/*.v`, sha256 below). `Specs.v`
is not imported: the link to the funspec is by identity of the predicate, see next section.

Source identities (sha256, host files at check time):

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

## Deliverable 1: the shell layer uses the funspec's own postcondition

`Specs.v` (relay worker, unchanged) states the relay contract as

```coq
POST [ tint ] EX status : Z, EX final : world, EX pending : list byte,
  PROP (outcome initial status final pending) RETURN (Vint (Int.repr status)) SEP (has_ext final)
```

and `Body.v` proves `semax_body Vprog Gprog f_relay relay_spec` for the generated Clight
`f_relay` (receipt `relay-body-coqc-16`, relay README). `Shell.v` defines the shell-level
primitive for the atom `Relay` as

```coq
Relay => exists pending, outcome (os s) rc (os t) pending /\ lost t = lost s ++ pending
```

i.e. the same `RelayReach.outcome` predicate, with the existentially hidden `pending` bytes
recorded in a shell-level ledger `lost` (bytes read but not delivered when the process
exited). No separate relay semantics is invented; every relay fact used downstream
(`outcome_conservation`, `outcome_success_exact`, `outcome_read_error_pending`,
`outcome_write_error_pending`, `outcome_status`) is imported from `Conservation.v`/`Reach.v`.
The second atom `Mark b` models a successful one-byte stdout write by another command
(phase3's `mark`); its failure modes are outside this model and stated as such.

Grammar and execution relation are the phase3 ones (`call`, `seq`, `and_then`, `or_else`;
six `exec` rules), status in `Z` instead of `Nat` because `outcome` carries a `Z` status.
Bytes are CompCert `byte` (`Integers.byte`), i.e. finite raw bytes, not strings or Unicode.

Theorems (all in module `ShellComposition`):

- `command_refines`, `query_transfer`: the phase3 generic composition/refinement and query
  transfer statements, for any atom/state types and any primitive relations.
- `exec_ledgers`: for every command and every execution over `relay_prim`, stdout is only
  extended, unread input is only consumed from the front, the lost ledger only grows.
- `exec_relay_only_conservation`: for commands without `Mark`, the byte count over
  delivered + lost + unread is invariant (composed form of `outcome_conservation`).
- `relay_then_mark_query` (status-sensitive query, for **every** initial state): after
  `relay && mark b`, either the status is 0 and stdout is exactly the old stdout, then the
  whole unread input, then `b`, with nothing lost; or the status is 1 or 2, the marker is
  absent, stdout grew by a prefix `extra` of the input with `extra ++ pending ++ unread' =
  unread`, `pending` was lost, and `pending = []` iff the status is 1 (read error) while
  `pending <> []` for status 2 (write error).
- Nonvacuity, each an actual `exec` derivation built from actual `outcome` derivations:
  - `late_error_exec`: `relay && mark` on `ReachExamples.input_a` (abc, read schedule
    `[3; -1]`) exits 1 with stdout `abc` (uses `ReachExamples.read_error_outcome`).
  - `success_exec`: the same bytes with schedule `[3]` exit 0 with stdout `abc!`.
  - `same_relay_bytes` / `different_composed_bytes` / `no_stdout_only_context`: the relay's
    stdout is identical in both, the composed stdout is not, and no function of the relay's
    stdout alone predicts the composed stdout (the status is essential).
  - `pending_lost_then_fresh_relay`: `relay ; relay` on `abcdef` with schedules `[4]` /
    `[2; 0]`: first relay exits 2 losing `cd`, second relay delivers `ef`; stdout `abef`,
    ledger `cd`, unread empty; the concatenation is **not** `abcdef` while the byte count is
    conserved (`pending_lost_observations`).
  - `nul255_exec`: bytes `0, 255, 10` relayed then marked: stdout bytes `[0; 255; 10; 33]`.

What this does not establish: Bash process, pipe or fd semantics (the state is the relay's
abstract `world`); termination of the C loop (`semax_body` is partial correctness); any
statement about the host kernel `read`/`write`; that the Lean phase3 model and this Coq
model agree (they are separately checked; no import either way).

## Deliverable 2: actual shell text reaches the checked AST

`Parse.v` is a **new bounded shell-text frontend**. It is not Aaron Councilman's spec-language
parser (`counc009/state_based` `bash-verifier`), which parses a different language and is
untouched (its limitations are recorded in `../integration/README.md`).

Accepted fragment, chosen transparently: command identifiers `[A-Za-z_][A-Za-z0-9_]*` that are
not Bash reserved words, no arguments, no expansions; `;`, `&&`, `||`; parentheses; spaces
and tabs. Precedence as in Bash `parse.y`: `&&`/`||` equal and left-associative, tighter than
`;`; `;` left-associative; a trailing `;` allowed. Everything else is rejected by the lexer
or parser: newlines, `|`, `&`, redirections, quotes, `$`, `#`, `!`, braces, `((`,
non-ASCII, digits-first names, assignments. Nothing is erased.

Checked: `parse_program_sound : parse_program s = Some c -> exists toks, lex_string s = Some
toks /\ body_derives toks c`, where `body_derives` is the inductive, precedence-stratified
grammar relation (the specification) and the parser is an ordinary fuel-indexed recursive
descent function. So an accepted text yields an AST that the grammar derives from exactly the
lexed tokens; the parser itself is not trusted. Also checked: `run_reachable`, tying the
executable validation evaluator to the `exec` relation of `Shell.v`.

Lexer, also checked (`Lex.v`, added after the first version): `lex_string s = Some toks ->
renders toks (list_of_string s)`, where `renders` is an inductive maximal-munch tokenization
relation (blanks skipped; identifiers start with a letter or `_`, continue with identifier
characters, are not reserved and are not followed by an identifier character; `&&`/`||`/`;`/
`(`/`)` literal; `(` never followed by `(`). `parse_program_sound_chars` composes both:
characters -> tokens -> AST through two inductive specifications; neither the executable lexer
nor the parser is trusted any more.

Trusted boundary, named: (1) the identification of `renders` + `body_derives` with Bash's
lexer/parser on this fragment (by inspection of bash `parse.y` precedence and the directed and
random differential tests below); (2) that `( c )` denotes `c` (the model has no
subshell-local state). Not proved: completeness (every derivable/renderable input is accepted)
and uniqueness of the derivation.

Differential validation (`validate_text.py bash`, host bash 5.2.21, `LC_ALL=C`, record at
`~/.cache/bash-spec-pilot/phase5-shell-bridge/bash_validation.json`): every accepted text
runs in real Bash with functions `t`/`u` (status 0) and `f`/`g` (status 1/2) printing their
name, and the actual exit status and stdout equal the Coq `run test_env` prediction that
`Fixtures.v` proves for the parsed AST: 29/29 agree. For the 28 rejected texts, `bash -n`
accepts 19 (they are valid Bash outside the fragment) and rejects 9. **The differential test
found a defect** in the first version: `((t))` was accepted as nested grouping, but Bash lexes
adjacent `((` as the arithmetic command (status 1 for `t` unset); the lexer now rejects
adjacent `((` and `( (t) )` remains accepted. Randomized test with Bash as the oracle
(`validate_text.py random --count 200 --seed 1`, `results/random_validation.json`): 200
random texts of the fragment (random blanks, nesting, trailing `;`; texts containing adjacent
`((` are excluded by construction) were run in bash, and `RandomFixtures.v` proves for each
that Coq's `parse_program` + `run test_env` yields bash's actual status and stdout. Finite
tests are evidence for these inputs only, not parser correctness.

Replayable path, text -> kernel-checked AST -> relay-contract query, in `Bridge.v`:
`relay_command "relay && mark" = Some (relay_then_mark bang)` (vm_compute on the actual
lexer/parser), hence `relay_and_mark_text_query`: every execution of the command parsed from
that text satisfies the status-sensitive query of Deliverable 1; `relay_and_mark_text_witnesses`
and `relay_seq_text_witness` attach the concrete late-error/success/pending-loss executions to
the parsed texts; `relay_command_derives` gives the grammar derivation. Names are bound by a
stated modelling map (`relay` -> the relay_spec process, `mark` -> successful one-byte printf),
not by Bash command lookup. Over the validation alphabet, e.g. `Fixtures.v`
`accept_11_parse : parse_program "t && f || u" = Some (or_else (and_then (call "t") (call
"f")) (call "u"))` (vm_compute), `accept_11_run` gives `(0, "tfu")`, `accept_0_derivation`
exhibits `body_derives` through `parse_program_sound`, and the same AST shape over the relay
atoms is what `relay_then_mark_query` quantifies over.

## Replay (repository root; container idle; fresh run names; lock is taken by run_vst.py)

```sh
docker exec phase5-vst mkdir -p /home/coq/phase5/shell-bridge
python3 research/libc-specs/phase5/shell-bridge/validate_text.py gen      # regenerates Fixtures.v
python3 research/libc-specs/phase5/shell-bridge/validate_text.py bash     # host bash differential test
python3 research/libc-specs/phase5/shell-bridge/validate_text.py random --count 200 --seed 1   # regenerates RandomFixtures.v from bash
for f in Shell Parse Fixtures Bridge RandomFixtures Lex ShellAudit; do docker cp research/libc-specs/phase5/shell-bridge/$f.v phase5-vst:/home/coq/phase5/shell-bridge/$f.v; done
for f in Shell Parse Fixtures Bridge RandomFixtures Lex ShellAudit; do uv run --no-project python research/libc-specs/phase5/run_vst.py --name shell-bridge-$f-replay --seconds 300 --workdir /home/coq/phase5/shell-bridge -- coqc -Q /home/coq/phase5/relay "" $f.v; done
```

Requires `Protocol`, `Reach`, `ReachExamples`, `Conservation` compiled in
`/home/coq/phase5/relay` (relay README replay).

## Assumptions

`results/audit-final.log` (receipt `shell-bridge-final-ShellAudit`): all 44 `Print Assumptions` reports read "Closed under the global context"; no axiom, no `Admitted`, no project hypothesis. The relay dependencies are the relay worker's theorems, themselves closed per `../relay/README.md` (`relay-audit-3`). Machine-readable summary with run list and `.vo` hashes: `results/receipts.json`.

## Remaining limits (explicit)

- Source: the C relay is the purpose-built phase2 `relay.c`; no upstream utility yet
  (GNU `simple_cat` is under assessment, see `../integration/COMPLETION-AUDIT.md` item 10).
- OS: `read32`/`write_block` are scheduled abstract primitives; kernel behaviour, signals,
  pipes, fd inheritance, process creation and exit codes of real Bash are outside every
  checker. The `Mark` atom assumes a successful write.
- Termination: `semax_body` is partial correctness; `Progress.v` is abstract. No C loop
  termination theorem; the shell `exec` relation only covers terminating executions.
- Proof assistant: single Coq kernel from Clight body to shell query (Coq-final subchain);
  Lean phase3/phase5 artifacts are an independent reference, not imported. CompCert's
  C-text-to-Clight parser is trusted (link 1 of `../integration/PROOF-CHAIN.md`).
- Frontend: lexer and parser both sound against inductive relations; completeness unproved;
  fragment excludes arguments, pipes, redirections, expansions, newlines; identification of
  the two relations with Bash's grammar is by inspection plus 29 + 28 directed and 200 random
  differential tests.
