# Observations: mv session=2026-05-07T11-11-40Z round=1

## Numbers
- Tests pass on real-gnu: 24/26 (= 92%)
- Tests pass on rust impl: 25/26 (= 96%)
- Flag coverage: 16/18 flags exercised (= 88.89%)
- Branch/line coverage on Rust impl: 65.04% (240/369 lines)

## Test-correctness failures (tests that failed on the real utility)

Tambon labels (per `taxonomy.md` §1) + Astrogator-style cause code.

- **008_interactive_decline_keeps_destination.sh** [Misinterpretation; TEST-MAN-PAGE-MISREAD] — `-i/--interactive`. Test pipes `n\n` into `mv -i` via heredoc and expects the destination to be preserved. GNU `mv -i` only prompts when stdin is a tty (the man page says "prompt before overwrite", silent on tty-detection). With heredoc-stdin, GNU `mv` sees no tty, skips the prompt, overwrites silently — `dst` becomes `new`. Real-side rc=1 from the test's own assertion. Identical shape to `cp` round-1 `022_interactive_decline_overwrite.sh`. The man-page silence on tty-detection is the consistent miss across both utilities.

- **020_strip_trailing_slashes.sh** [Missing Corner Case; TEST-MAN-PAGE-MISREAD] — `--strip-trailing-slashes` on a symlink-to-dir. Test creates `link -> real/` and calls `mv --strip-trailing-slashes "$tmpdir/link/" movedlink`. Bash does not strip the slash before exec; `mv` receives literal `link/`. GNU `mv` treats `link/` as a directory-semantics request through the symlink (POSIX path-resolution rule: trailing slash forces directory semantics on the source) and fails with "Not a directory" because `movedlink` doesn't exist. The flag is intended to strip trailing slashes from non-symlink sources to make `mv foo/ bar/` shaped like `mv foo bar/`; it does not rescue `link/` semantics. The LLM read "remove any trailing slashes from each SOURCE argument" and over-generalized. Test-side bug.

## Impl-correctness failures (tests that passed on real, failed on rust)

- **021_verbose_outputs_action.sh** [Misinterpretation; IMPL-WRONG-SEMANTICS] — `-v/--verbose` output stream. GNU `mv -v` writes `renamed 'src' -> 'dst'` to **stdout**. The Rust impl writes the same string to **stderr**. Test captures via `out=$("$UTIL" -v ...)` (command substitution = stdout only). Real-gnu: stdout populated, test passes. Rust: stdout empty, stderr populated, test fails. The man page does not explicitly say "stdout" for `-v`, but coreutils convention (and the GNU behavior the LLM is supposed to mimic) is stdout for action narration, stderr for errors. Wrong-stream is a subtle but consistent class of LLM impl bug.

## Compile / runtime failures of the Rust impl

The host-side `cargo check` pre-flight gate failed (macOS toolchain missing `std::os::unix` features used by the impl), but `cargo build --release` succeeded inside the trixie container with two unused-variable warnings only. No runtime failures.

## Open questions for next round

- `mv -i` on non-tty stdin: should the spec record "prompt only when stdin is a tty"? This turns implicit GNU behavior into explicit spec. Test prompt may need a hint that `-i` semantics depend on runtime environment.
- Trailing-slash behavior at the shell/utility seam: should the experiment take a position on what `mv link/` means? GNU treats it as a directory-semantics request through the symlink; that is one of three plausible interpretations.
- `-v` output stream: should the prompt force the LLM to be explicit about which stream each flag writes to? Currently the man page leaves it unstated and the LLM defaulted to stderr.
