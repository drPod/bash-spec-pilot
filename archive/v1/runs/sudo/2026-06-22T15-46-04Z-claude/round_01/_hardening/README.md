# Hardening: sudo `-D` / `--chdir` (test 012) — verdict: NOT a manpage defect

Three-oracle triangulation of the round-1 `manpage_underspec` candidate
`012_chdir_directory.sh`. See `sudo_D_probe.sh` / `sudo_D_probe.out` for the
reproducible probe (trixie, sudo 1.9.16p2).

## What the candidate claimed

The test grounded on this verbatim man-page span and asserted `-D` runs the
command in the given directory:

> "Run the command in the specified directory instead of the current working
> directory."

Real sudo refused: `you are not permitted to use the -D option`. The classifier
saw real-fail + rust-pass + grounded substring and bucketed it `manpage_underspec`.

## Why it is a false positive

The man page entry for `-D` (utils/sudo/manpage.txt:94-98) is **two sentences**.
The test quoted only the first. The second states the precondition that fired:

> "The security policy may return an error if the user does not have permission
> to specify the working directory."

The binary behaves exactly as the full entry documents. The man page is correct.

## Oracle 1 — real binary (trixie, sudo 1.9.16p2)

- (a) non-root tester, default sudoers (no `runcwd`): `sudo -n -D /tmp pwd` → refused, rc=1.
- (b) add `Defaults runcwd=*`: `sudo -n -D /tmp pwd` → `/tmp`, rc=0.
- (c) long form `--chdir=/tmp` → `/tmp`, rc=0.
- (d) as **root**, default sudoers: still refused, rc=1.

(d) clears the root confound: the refusal is the policy gate (`runcwd`), not the
as-root execution context. Behavior is identical root and non-root, and `-D`
works the moment the policy grants it — precisely the documented contract.

## Oracle 2 — POSIX

N/A. `sudo` is not in POSIX (CLAUDE.md; docs/posix). No standard to adjudicate.

## Oracle 3 — version stability

sudo 1.9.16p2. The `-D` policy gate (`runcwd`, introduced sudo 1.9.3, 2020) and
the "security policy may return an error" man-page wording are long-standing and
stable. The frozen Debian-trixie man page carries the disclaiming clause.

## Verdict

Candidate **killed**. Not a man-page defect. Reclassify as a **test-construction /
provenance-grounding artifact**: the `manpage_quote` was a true-in-isolation
substring negated by the adjacent sentence in the same entry.

## Meta-finding (the durable output)

Substring grounding in `classify_divergence.py` (a `manpage_quote` that is a
verbatim substring of the frozen man page → bucket `manpage_underspec`) is
**necessary but not sufficient**. A test can ground on a clause that the
surrounding sentence/paragraph qualifies or negates, producing a false
`manpage_underspec`. Every `manpage_underspec` row needs review against the full
surrounding context, not just the quoted span. This is a known false-positive
mode for the headline "man pages lie" class and a candidate caveat for
`docs/research/taxonomy.md`.

Contrast with the surviving mv finding: `mv --strip-trailing-slashes` quotes
"remove any trailing slashes from each SOURCE argument" with **no** qualifying
clause anywhere in the entry, and the binary adds an undocumented "must be a
directory" check. That is a real man-page defect; sudo `-D` is not.
