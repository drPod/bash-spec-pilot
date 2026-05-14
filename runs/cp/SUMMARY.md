# cp — session trajectories summary

This file is the per-utility roll-up across all sessions. One section per
session_id, summarizing round-by-round metrics. Stable across sessions —
do not delete entries when a session ends; treat as append-only.

## Schema for each session entry

```
### <session_id>           kind: <iteration | reproducibility | other>

| Round | test_real-gnu | test_rust | flag_cov | line_cov | notes |
|-------|---------------|-----------|----------|----------|-------|
| 01    | P/T (X%)      | P/T (X%)  | F%       | L%       | one-liner |
| 02    | ...           | ...       | ...      | ...      | what changed |
```

Append a one-paragraph "what we learned" at the end of each session entry.
The `kind` column was added 2026-05-07 to accommodate sessions whose shape
doesn't fit a round-by-round iteration table — e.g. `_reproducibility_*`
sessions are 2-call A/B tests, not iteration trajectories. For those, use
`kind: reproducibility` and a single pointer row to the report file rather
than coercing the round table.

---

## legacy_pre_session   kind: pre-experiment baseline (round 0)

Pre-session-id baseline. See `legacy_pre_session/_README.md` for context.
Run on macOS against BSD `/bin/cp`; oracle was wrong, infra was incomplete.
Treated as round **0** to flag "pre-methodology — not comparable to wave-2+ rows."

| Round | test_real-gnu | test_rust | flag_cov | line_cov       | notes |
|-------|---------------|-----------|----------|----------------|-------|
| 00    | 28/30 (93%)   | n/a       | 77.8%    | compile_failed | Original macOS BSD run scored 13/30; re-running with the new GNU oracle moved that to 28/30. The 2 remaining failures are `018_strip_trailing_slashes.sh` (shell follows symlink-with-slash before cp sees it — misread edge case at the boundary between bash semantics and cp semantics) and `022_interactive_decline_overwrite.sh` (GNU `cp -i` skips the prompt when stdin is not a tty and exits nonzero — misread error case in the man page's silence on tty-detection). |

What we learned: the run is already 28/30-correct against the real GNU
oracle. The misread-edge-case failures are nontrivial — they live at the
seam between the documented utility and the surrounding shell, which is
exactly the kind of failure mode the experiment is supposed to surface.
The Rust impl never compiled (single E0515 lifetime issue) so impl-side
correctness is unmeasurable for this round.

---

## 2026-05-07T11-10-34Z   kind: iteration

Fresh session against the GNU oracle in trixie. Round 1 is a cold call;
round 2 includes an auto-built "Previous attempt feedback" block from
round 1's failed-test stderrs + analyst observations. Same canonical
manpage as legacy. Reasoning effort default (model picks).

| Round | test_real-gnu | test_rust   | flag_cov | line_cov | notes |
|-------|---------------|-------------|----------|----------|-------|
| 01    | 26/28 (93%)   | 26/28 (93%) | 66.67%   | 60.0%    | Generated 28 tests (vs legacy 30). Rust impl compiled cleanly this time (no E0515). Two real-gnu failures replicate legacy's surviving-failure categories: `024_interactive_i_decline.sh` (`-i` non-TTY semantics — misread edge case) and `026_strip_trailing_slashes.sh` (bash follows `link.txt/` before cp sees it — infrastructure / shell-cp seam). |
| 02    | 26/28 (93%)   | 28/28 (100%)| 66.67%   | 87.45%   | LLM clearly engaged with feedback: tests renumbered + renamed (`_tty` and `_dir_symlink` suffixes), impl gained `use std::io::IsTerminal`. But both rewrites are still wrong: `026_interactive_i_decline_tty.sh` uses `script(1)` flags that don't quote-expand correctly; `027_strip_trailing_slashes_dir_symlink.sh` doesn't account for trailing-slash overriding `-P`. Same two failure categories persist on real-gnu. **Rust 28/28 is misleading** — impl coevolved with wrong test expectations. Line coverage jump 60→87% from impl thoroughness, not new branches. Cost: ~$0.27 round 1, ~$0.32 round 2 (≈$0.59 session total). |

What we learned: **the LLM uses the structured feedback section** —
filenames encode the suggested fixes verbatim, the impl imports
`IsTerminal` in direct response to the round-1 `-i` note. But one round
of feedback is not enough to converge on the two surviving failure
categories: the LLM produces *plausibly different* rewrites that still
miss the real semantics (`script(1)` quoting, trailing-slash precedence
over `-P`). No regressions on real-gnu — 26/28 → 26/28 — so iteration
isn't destabilizing what already works. Round-2 Rust impl scoring 28/28
on its own tests while still failing 2/28 on real-gnu is the cleanest
example yet of why differential testing against the real utility is
non-negotiable: the LLM-generated tests + impl are internally consistent
but jointly drifted from GNU. This LLM-vs-LLM mutual ratification is the
central methodology finding promoted to `for_aaron.md` § 3. The coverage
line-delta (60→87%) is real but orthogonal — a different gradient of
progress on the impl than on the tests. **Empirical answer to Aaron's
prelim Ch. 5 footnote: with N=1, iteration moves the impl noticeably
and the tests minimally; the hard residual failures (Tambon §4.1.1 #5
misread edge cases at the shell/cp seam) survive one round of structured
feedback.** N=1 caveat applies — see `decisions.md` § 8.

---

## _reproducibility_2026-05-07T11-18-09Z   kind: reproducibility

Two-call A/B test, not an iteration trajectory. The round table doesn't
fit; this row is a pointer to the full report.

| Shape    | Pointer |
|----------|---------|
| 2-call A/B, identical prompt | **see report file: `runs/cp/_reproducibility_2026-05-07T11-18-09Z.md`** |

What we learned: same prompt produced 291-line vs 393-line `main.rs`,
613-line / 40,630-byte `diff -u`, identical dependency choice
(`filetime + libc`), 9.3% reasoning-token delta, and **a compile
flip — A passed `cargo check`, B failed with E0308**. Different
`response.id` confirms real round-trips both times (no caching).
The dated-snapshot + content-hash determinism story documented in
`decisions.md` § 3 is a mechanism statement, not a measurement.
**N≥3 sampling required for defensible single-cell claims.** Decisions
log entry: `decisions.md` § 8.

---

## 2026-05-07T11-10-34Z

Fresh session running both rounds against the GNU oracle in trixie. Round
2's prompt includes an auto-built "Previous attempt feedback" block from
round 1's failed-test stderrs + analyst observations. Same canonical
manpage as legacy. Reasoning effort default (model picks).

| Round | test_real-gnu | test_rust   | flag_cov | line_cov | notes |
|-------|---------------|-------------|----------|----------|-------|
| 01    | 26/28 (93%)   | 26/28 (93%) | 66.67%   | 60.0%    | Generated 28 tests (vs legacy 30). Rust impl compiled cleanly this time (no E0515). Two real-gnu failures replicate legacy's surviving-failure categories: `024_interactive_i_decline.sh` (`-i` non-TTY semantics — misread edge case) and `026_strip_trailing_slashes.sh` (bash follows `link.txt/` before cp sees it — infrastructure / shell-cp seam). |
| 02    | 26/28 (93%)   | 28/28 (100%)| 66.67%   | 87.45%   | LLM clearly engaged with feedback: tests renumbered + renamed (`_tty` and `_dir_symlink` suffixes), impl gained `use std::io::IsTerminal`. But both rewrites are still wrong: `026_interactive_i_decline_tty.sh` uses `script(1)` flags that don't quote-expand correctly; `027_strip_trailing_slashes_dir_symlink.sh` doesn't account for trailing-slash overriding `-P`. Same two failure categories persist on real-gnu. Rust 100% is misleading — impl coevolved with wrong test expectations. Line coverage jump 60→87% from impl thoroughness, not new branches. Cost: ~$0.27 round 1, ~$0.32 round 2 (≈$0.59 session total). |

What we learned: **the LLM uses the structured feedback section** —
filenames encode the suggested fixes verbatim, the impl imports
`IsTerminal` in direct response to the round-1 `-i` note. But one round
of feedback is not enough to converge on the two surviving failure
categories: the LLM produces *plausibly different* rewrites that still
miss the real semantics (`script(1)` quoting, trailing-slash precedence
over `-P`). No regressions on real-gnu — 26/28 → 26/28 — so iteration
isn't destabilizing what already works. Round-2 Rust impl scoring 28/28
on its own tests while still failing 2/28 on real-gnu is the cleanest
example yet of why differential testing against the real utility is
non-negotiable: the LLM-generated tests + impl are internally consistent
but jointly drifted from GNU. The coverage line-delta (60→87%) is real
but orthogonal — a different gradient of progress on the impl than on
the tests. **Empirical answer to Aaron's prelim Ch. 5 footnote: with
N=1, iteration moves the impl noticeably and the tests minimally; the
hard residual failures (Tambon §4.1.1 #5 misread edge cases at the
shell/cp seam) survive one round of structured feedback.**
