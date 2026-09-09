# Extended: general compositional parser/semantics for pipe + redirect

Date: 2026-09-08. Worker: Claude CLI (`shell-parser-semantics-6`/`-8`, same session,
resumed after two quota interruptions — see `claude-resume/shell-parser-semantics-8/`
STATUS/REPORT/NEXT for the session account). Everything below is checked by Coq 8.20.1
in the shared `phase5-vst` container (CompCert 3.15, VST 2.15) through `../../run_vst.py`,
in this job's own container directory `/home/coq/phase5/shell-expansion8`. Nothing is
committed, nothing upstream is touched. `shell-bridge/`, `relay/`, and the parent
`shell-expansion/` directory (`Pipeline.v`, `Bridge2.v`, `Redirect.v`, `ParseExpansion.v`,
`ShellExpansionAudit.v`) are FROZEN and were only read/recompiled unmodified, never edited.

## Why this directory (resuming `shell-expansion-4`'s NEXT.md)

`shell-expansion-4`'s own NEXT.md named four gaps, in priority order: (1) a soundness
proof for the text frontend, (2) generalizing redirection to cover a piped result,
(3) composition with `;`/`&&`/`||`/parens, (4) a real-execution differential test
(not just `bash -n`). This directory does all four together, since (2) and (3) turned
out to share one design: unify `Bridge2.v`'s `atom2` and `Redirect.v`'s `ratom` into
one atom type (`yatom`) that a SINGLE parser and a SINGLE soundness proof can cover.

## Files (final receipts; earlier development iterations — including the compile-error
attempts and diagnostic `idtac` probes used to find the real root cause below — are
preserved unmodified in the same runs directory)

| File | Receipt (exit 0) | sha256 | Content |
|---|---|---|---|
| `Compose.v` | `shellexp8-Compose-v16` (1.14 s, 495,728 KiB) | `8456dce1...9d76d59d6a08b` | Generalized redirect (`yatom`, `yredirect_prim`), full `;`/`&&`/`||`/parens grammar (`rcmd_derives`/`uandor_derives`/`ulist_derives`/`ubody_derives`), recursive-descent parser, soundness theorem (`parse_program3_sound`), 17 accept/reject/tie-in examples |
| `ComposeAudit.v` | `shellexp8-ComposeAudit-v1` (4.74 s, 521,932 KiB) | `2f86299d...c6aa435d915d` | 30x `Print Assumptions`: every theorem/example in `Compose.v`, all "Closed under the global context" |

Machine-readable receipt list and source hashes: `results/receipts.json`,
`results/source-sha256.txt`. No `Admitted`, `Axiom`, `Parameter` or `Conjecture`
anywhere in either file (checked by grep, consistent with the audit above).

`Pipeline.v`, `Bridge2.v`, `Redirect.v`, `ParseExpansion.v` (the frozen
`shell-expansion-4` files) were recompiled FRESH, byte-for-byte unmodified, in this
job's own `/home/coq/phase5/shell-expansion8` container directory so that `Compose.v`'s
dependency chain has its own receipts under this job, rather than silently reusing
`shell-expansion4`'s already-compiled `.vo`s.

## 1. Generalized redirect: `yredirect_prim` (item 2 in the old NEXT.md)

`Redirect.v`'s `ratom` wraps a bare `atom` (`Direct`/`Redirect` of `Relay`/`Mark` only);
`(relay | relay) > out` could not be expressed. `Compose.v`'s `yatom := YDirect (a2 :
atom2) | YRedirect (append : bool) (path : string) (a2 : atom2)` wraps `Bridge2.v`'s
`atom2` instead (bare relay/mark, OR `PipeRR`), so a redirect can now attach to either.

- `pipe_prim_delivered_extra` generalizes `Redirect.v`'s own `relay_prim_delivered_extra`
  from `relay_prim` to `pipe_prim`: for `FromShell a`, it IS the old lemma (reused,
  unchanged); for `PipeRR`, it follows directly from `pipe_prim`'s own definition
  (`delivered (os t) = delivered (os s) ++ delivered (pw_consumer pwF)`) — no new fact
  about `Pipeline.v`'s internals was needed or proved.
- `yredirect_prim`'s structure is otherwise IDENTICAL to `Redirect.v`'s `redirect_prim`
  (same restoration via `os_reset`, same truncate/append-at-open-time distinction, same
  empty-path error case) — `yredirect_underlying_exec`/`yredirect_open_failure` mirror
  `Redirect.v`'s `redirect_underlying_exec`/`redirect_open_failure` exactly.
- **Faithfulness of what gets redirected**: `relay | relay > out` in real Bash redirects
  only the PIPELINE's own visible stdout (the second stage's writes), not some internal
  trace. `pipe_prim`'s own definition already folds exactly that into the ambient
  `delivered` stream, so redirecting `PipeRR` redirects the real observable output, not
  an approximation — checked concretely by `pipe_redirect_witness`/
  `pipe_redirect_observations` (the SAME "abcdef"/`PIPE_CAP=4` fixture as `Pipeline.v`'s
  own `demo_pipeline_success`, redirected: file `"out"` ends up exactly `demo_bytes`).
- `yredirect_relay_gt_out_matches_old` is a reuse-sanity check: redirecting a BARE relay
  through the new, generalized `yredirect_prim` reproduces `Redirect.v`'s own
  `redirect_truncate_witness` byte-for-byte — the generalization did not silently change
  the old case.
- **What is NOT generalized**: `YRedirect` still wraps exactly one `atom2` (a bare atom
  or the one two-stage `PipeRR`), not an arbitrary `command atom2` (a `;`/`&&`/`||`
  sub-expression) — redirecting a COMPOUND command is still out of scope, matching real
  Bash's own distinction between redirecting a simple command/pipeline vs. a `{ ...; }`
  group (which needs different, unimplemented, syntax here).

## 2. Full grammar with `;`/`&&`/`||`/parens (items 1 and 3 together)

`rcmd_derives`/`uandor_derives`/`ulist_derives`/`ubody_derives` mirror `shell-bridge/
Parse.v`'s own `cmd_derives`/`andor_derives`/`list_derives`/`body_derives` in EXACT
shape (four levels, same left-associativity, same "parens only group, no subshell-local
state" convention) — the only change is the bottom level: `Parse.v`'s bare `TIdent`
identifier is replaced by `redir_derives` (`unit_derives`/`pipe_derives`/`redir_derives`,
three small new relations: a bare relay/mark, OR exactly `relay | relay`, with an
OPTIONAL trailing `>`/`>>` target on that whole unit).

- **Precedence, exactly as stated in `Pipeline.v`'s and the old README's "Precedence"
  sections and now actually IMPLEMENTED, not just asserted**: `|` and `>`/`>>` bind
  inside one unit; that unit sits at exactly the level `Parse.v`'s bare identifier did,
  i.e. tighter than `&&`/`||`, which are tighter than `;`; parens group a full `;`-level
  expression. `ex_accept_paren_and` (`"(relay ; mark) && mark"`) checks a nested case.
- **Soundness**: `parse_program3_sound` — mirrors `Parse.v`'s own `parse_program_sound`
  proof pattern exactly (a fuel-indexed mutual induction over the four parser levels).
  This was, by far, the hardest part of this session (see "Process notes" below for the
  actual Coq pitfall found and how it was diagnosed, in case a later worker in this
  container hits the same class of bug). NOT proved, same as `Parse.v` itself:
  completeness (every token list the grammar relation derives is accepted by the parser).
- **Composition itself is NOT new proof, only application**: `yatom`/`yredirect_prim` is
  one more instantiation of `Shell.v`'s generic `command`/`exec`; `compose_command_
  refines`/`compose_query_transfer` are direct instantiations of `command_refines`/
  `query_transfer` (unchanged, universally quantified) — stated explicitly, per the
  assignment's own caution against "declaring pipeline closed just by instantiating
  abstract `command_refines`". What IS new and checked here is the GRAMMAR/PARSER that
  produces `command yatom` trees mixing pipes, redirects, and `;`/`&&`/`||`/parens in the
  first place — `Bridge2.v`/`Redirect.v` alone had no parser that could build such a tree.
- **Explicit unsupported forms** (rejected, not silently mis-parsed — checked by
  `vm_compute`): `relay | mark` (mismatched pipe operands — `parse_pipe`'s match commits
  to the 3-token pipe shape and requires literally "relay"/"relay", it does not fall back
  to parsing a bare `relay` and leaving `| mark` as noise); `relay | relay | relay`
  (three-stage pipe — the third stage is unconsumed trailing garbage, rejected at the top
  level, not silently dropped); `relay > a > b` (a second redirect is likewise unconsumed
  trailing garbage); `cat > out` (unknown command name); `(relay | relay) > out`
  (redirecting a PARENTHESIZED group — only a bare pipe-or-unit carries a redirect in
  this fragment, matching `relay | relay > out` WITHOUT parens working instead, since
  that is the level a redirect actually attaches at).

## 3. Real-execution test (item 4) — container-wrapped (repaired)

`validate_extended.py` stages `phase2/relay.c` plus a tiny `main` privately in a
fresh `/home/coq/phase5/shellexpval9-*` directory and compiles/runs **only** through
`phase5/run_vst.py` (`phase5-vst`, shared lock, unique names, receipt
exit/timing/log_sha256 checked). Host `gcc` is not used.

Expectations are **hand-coded literals** in the Python script. There is no
executable Coq oracle; this is not an automated model differential and not a proof.

Source provenance records exact sha256 of `relay.c` and of CompCert-preprocessed
`relay.i`. Those hashes differ; substring checks are **not** treated as translation
identity.

Historical host-unwrapped 12/12 JSON is kept as
`results/bash_execution_validation.host-unwrapped.historical.json`.
Corrected container run: `results/bash_execution_validation.corrected12.json`
(and the live `bash_execution_validation.json` copy). Cases (same 12 directed
fixtures; labels are informal pointers to Coq names, not Coq execution):

1. Bare `relay` (matches `Shell.v`'s `input_s`/`success_outcome`).
2. Bare `mark` (matches `Mark bang`).
3. `relay | relay` (matches `Pipeline.v`'s `demo_pipeline_success` end-to-end bytes).
4. `relay > out` (truncate; matches `Redirect.v`'s `redirect_truncate_witness`).
5. `relay >> out` over pre-existing content (matches `redirect_append_vs_truncate`).
6. **NEW**: `relay | relay > out` (matches THIS session's `pipe_redirect_witness`).
7. `relay ; mark > log` (matches `ycompose_within_seq`/`redirect_within_seq`: terminal
   stdout is exactly relay's own output, the file gets the mark byte separately).
8. `relay && mark` (both run, on success).
9. Read-error path: `relay <&-` (closed stdin) — real Bash/kernel EBADF makes `relay`'s
   own `read(0,...)` fail, and relay's OWN convention (`relay.c`: `if (n<0) return 1`)
   reports status 1, matching `relay_prim`'s `rc=1` branch. Recorded plainly as
   RELAY'S OWN contract (from its C source), not a general "EBADF implies 1" Bash rule.
   `&&`/`||` short-circuit correctly around it (`and_short_circuits_on_read_error`,
   `or_runs_mark_on_read_error`).
10. A GENUINE SIGPIPE: `yes | head -c 2000000 | relay | true` — `true` never reads, so
    once the kernel pipe fills, `relay`'s `write(1,...)` gets a real `SIGPIPE`, and Bash
    reports `${PIPESTATUS[0]}` = 141 (128+13), exactly `Pipeline.v`'s modelled
    `demo_sigpipe` status. Stated precisely: `relay` here is the LEFT stage writing to
    `true`, not a `PipeRR`-composed pair — this is an independent oracle check on the
    128+SIGPIPE STATUS CONVENTION only, not a claim that a 2-stage `relay|relay` pipeline
    was exercised end-to-end through a real SIGPIPE (the grammar's own `PipeRR` still has
    no real fd/process model at all, per `Pipeline.v`'s own stated scope, unchanged).

**What this does NOT establish**: 12 directed cases on one host, one Bash version, one
kernel are finite evidence, not a completeness or correctness proof of the grammar
against Bash's actual parser/process model (same caveat `shell-bridge/validate_text.py`
states for the old fragment). No randomized/fuzzed differential test was run here (the
old fragment's `RandomFixtures.v`-style 200-case sweep was not repeated for this new
grammar under the session's time budget — flagged in NEXT.md below as follow-up).

## What this directory does NOT establish

- Real fds/dup2/process/fork/exec model. `PipeRR` is still exactly two `Relay`-shaped
  stages behind ONE deterministic scheduler (`Pipeline.v`, unchanged) — no N-stage, no
  heterogeneous pipeline, no nondeterministic "any legal interleaving" relation. The
  SIGPIPE cross-check above (case 10) is a genuine real-Bash comparison of the STATUS
  CONVENTION, but it does not exercise `PipeRR` itself (see its own caveat above).
- Redirecting a compound (`;`/`&&`/`||`/paren) command — only a bare pipe-or-unit.
- Parser COMPLETENESS (every grammar-derivable token list is accepted) — only
  soundness (every accepted token list derives from the grammar) is proved, matching
  `Parse.v`'s own stated gap.
- A randomized/fuzzed Bash comparison for the new grammar (only 12 directed cases).
- Any claim beyond finite, directed, host-specific evidence: this is not a universal
  statement about Bash's own parser or the POSIX process model.

## Interface for a later State Calculus correspondence worker

Unchanged from `shell-expansion-4`'s own note: `yatom` (superseding `atom2`/`ratom` as
the more general target) is an ordinary instantiation of `Shell.v`'s `command`/`exec`.
A worker connecting Aaron's State Calculus interpreter would still need: (1) AST nodes
for `|`/`>`/`>>` in `calculus-bytes/build/bash-verifier/lib/frontend/ast.ml` (none exist
today); (2) a `map_command`-style translation to `yatom`/`command yatom`; (3) the
correspondence theorem itself. Not attempted here.

## Process notes for whoever resumes in this container

**The actual Coq pitfall behind most of this session's iteration** (in case a later
worker hits the same class of bug): `parse_redir` (a plain, NON-recursive `Definition`)
can sometimes be FULLY COMPUTED by `simpl`/`cbn` even when its argument list has an
abstract TAIL, because its own pattern match only needs to inspect the HEAD token to
decide rejection (e.g. `parse_redir (USemi :: toks')` reduces all the way to `None`
regardless of what `toks'` is, since `USemi` alone already fails every accepting
pattern). This looks, at a glance, exactly like the "genuinely stuck on an abstract
mutually-recursive call" case (e.g. `parse_ulist n toks'`, which really CANNOT reduce
further without knowing `n`/`toks'`) — but it is not: it is a LEGITIMATE full
computation. A generic `try (destruct (parse_redir toksx) as ... eqn:E; ...)` tactic
written to handle "the redir case" therefore correctly FAILS on these already-fully-
reduced branches (there is no `parse_redir` subterm left in the hypothesis to destruct),
and if that failure is silently swallowed by an enclosing `try`, the proof script
proceeds as if that branch were handled, leaving it open — which then surfaces as
confusing, seemingly-unrelated errors much later (wrong hypothesis contents, bullet/
goal-count mismatches) at a COMPLETELY different point in the script. Diagnosed here by
inserting `let ty := type of H in idtac "CHK..." ty` checkpoints between tactic steps to
see the ACTUAL hypothesis shape at each point, rather than trusting what the tactic
combinator was assumed to be doing. Fix: handle the "always fully reducible" branches
with plain `discriminate` and reserve the generic pipe-lookup tactic for the one branch
(`UIdent`) where the call genuinely stays symbolic.

`shell-expansion-4`'s own `buflen_eq` workaround (`Pipeline.v`, "Cannot find witness"
from `injection`/`inversion`/`lia`) was not encountered this session.

## Replay

```sh
docker exec phase5-vst mkdir -p /home/coq/phase5/shell-expansion8
for f in Pipeline Bridge2 Redirect ParseExpansion; do
  docker cp research/libc-specs/phase5/shell-expansion/$f.v phase5-vst:/home/coq/phase5/shell-expansion8/$f.v
done
for f in Compose ComposeAudit; do
  docker cp research/libc-specs/phase5/shell-expansion/extended/$f.v phase5-vst:/home/coq/phase5/shell-expansion8/$f.v
done
for f in Pipeline Bridge2 Redirect ParseExpansion Compose ComposeAudit; do
  uv run --no-project python research/libc-specs/phase5/run_vst.py --name shellexp8-replay-$f --seconds 180 \
    --workdir /home/coq/phase5/shell-expansion8 -- \
    coqc -Q /home/coq/phase5/relay "" -Q /home/coq/phase5/shell-bridge "" $f.v
done
python3 research/libc-specs/phase5/shell-expansion/extended/validate_extended.py
```

Requires `Protocol`, `Reach`, `ReachExamples`, `Conservation` compiled in
`/home/coq/phase5/relay` and `Shell`, `Parse`, `Bridge` compiled in
`/home/coq/phase5/shell-bridge` (both frozen, see their own READMEs for replay); `gcc`
container `gcc`/`bash` for `validate_extended.py` must go through `run_vst.py` (unique names; do not use host gcc).

## Assumptions

`ComposeAudit.v` (receipt `shellexp8-ComposeAudit-v1`, `results/receipts.json`) runs
`Print Assumptions` on all 30 theorems/examples in `Compose.v`: every line reads "Closed
under the global context". No axiom, no `Admitted`, no project-local hypothesis. Every
theorem is `Qed`-closed against `shell-expansion/`'s own already-frozen, already-audited
facts (`relay_prim_delivered_extra`, `pipe_prim`, `redirect_prim`'s pattern, `Shell.v`'s
`command_refines`/`query_transfer`) plus `Parse.v`'s own grammar-mirroring pattern.
