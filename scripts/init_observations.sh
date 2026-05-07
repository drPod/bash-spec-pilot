#!/usr/bin/env bash
# Write the _observations.md skeleton for a round, with the quantitative
# numbers pre-filled from the existing JSONL/JSON metric files. The
# qualitative sections (failure taxonomy, open questions) are left empty
# for the analyst to fill in.
#
# Usage:
#   scripts/init_observations.sh <util> <session> <round>
#
# Idempotent: re-running will overwrite the file. If the analyst has
# already added qualitative content, do NOT re-run blindly. Use the
# --force flag (4th arg) if you really want to clobber.

set -euo pipefail

if [[ $# -lt 3 ]]; then
    echo "usage: $0 <util> <session> <round> [--force]" >&2
    exit 2
fi
UTIL="$1"
SESSION="$2"
ROUND="$3"
FORCE="${4:-}"
RR=$(printf '%02d' "$ROUND")

REPO="$(cd "$(dirname "$0")/.." && pwd)"
ROUND_DIR="${REPO}/runs/${UTIL}/${SESSION}/round_${RR}"
OUT="${ROUND_DIR}/_observations.md"

if [[ -f "$OUT" && "$FORCE" != "--force" ]]; then
    echo "$OUT exists. Pass --force as 4th arg to overwrite." >&2
    exit 0
fi

if [[ ! -d "$ROUND_DIR" ]]; then
    echo "no round dir at $ROUND_DIR" >&2
    exit 2
fi

python3 - "$UTIL" "$SESSION" "$ROUND" "$ROUND_DIR" "$OUT" <<'PY'
import json, sys, pathlib
util, session, rnd, round_dir, out_path = sys.argv[1:6]
rd = pathlib.Path(round_dir)

def count(name):
    p = rd / name
    if not p.is_file(): return None, None, []
    rows = [json.loads(l) for l in p.read_text().splitlines() if l.strip()]
    total = len(rows)
    if any("correct" in r for r in rows):
        correct = sum(1 for r in rows if r.get("correct") is True)
    else:
        correct = sum(1 for r in rows if r.get("status") == "pass")
    failures = [r for r in rows if r.get("correct") is False or
                (r.get("correct") is None and r.get("status") != "pass")]
    return correct, total, failures

real_c, real_t, real_fail = count("results_real-gnu.jsonl")
rust_c, rust_t, rust_fail = count("results_rust.jsonl")

# Cross-target: tests that pass on real-gnu but fail on rust isolate
# impl-side bugs (the Tambon "impl correctness" failure mode).
real_pass_names = set()
if real_t is not None:
    rows = [json.loads(l) for l in (rd / "results_real-gnu.jsonl").read_text().splitlines() if l.strip()]
    for r in rows:
        if (r.get("correct") is True) or (r.get("correct") is None and r.get("status") == "pass"):
            real_pass_names.add(r["name"])
rust_only_fail = [r for r in (rust_fail or []) if r["name"] in real_pass_names]

flag_pct = "n/a"; flag_m = flag_t = "n/a"
fp = rd / "coverage_flags.json"
if fp.is_file():
    cov = json.loads(fp.read_text())
    flag_pct = f"{cov.get('coverage_pct', 'n/a')}%"
    flag_m = cov.get("exercised_count", "n/a")
    flag_t = cov.get("documented_count", "n/a")

line_pct = "n/a"
compile_failed = False
build_err_first = ""
cp = rd / "coverage_rust.json"
if cp.is_file():
    cov = json.loads(cp.read_text())
    if cov.get("compile_failed"):
        line_pct = "compile_failed"
        compile_failed = True
    elif cov.get("line_coverage_pct") is not None:
        line_pct = f"{cov['line_coverage_pct']}%"

be = rd / "impl" / "_logs" / "build_error.txt"
if be.is_file():
    lines = be.read_text().splitlines()
    build_err_first = lines[0] if lines else ""

def fmt(c, t):
    if c is None: return "n/a"
    return f"{c}/{t}"

def fail_section(failures, title, default_text):
    if not failures:
        return f"## {title}\n\n_None._\n"
    lines = [f"## {title}", "",
             "Categorize each failure by Tambon-2025 schema",
             "(literature/tambon_2025_*.pdf):",
             "  - hallucinated flag / nonexistent feature",
             "  - wrong default",
             "  - wrong precedence",
             "  - misread edge case",
             "  - misread error case",
             "  - infrastructure (env / shell / quoting bug in test, not the LLM's reading)",
             "",
             "Per-failure (analyst fills `<category>`):", ""]
    for f in failures:
        name = f.get("name", "<?>")
        ex = (f.get("exercises") or "").strip()
        line = f"- **{name}** [<category>] — {ex}" if ex else f"- **{name}** [<category>]"
        lines.append(line)
    return "\n".join(lines) + "\n"

doc = f"""# Observations: {util} session={session} round={rnd}

## Numbers
- Tests pass on real-gnu: {fmt(real_c, real_t)}{f' (= {real_c/real_t*100:.0f}%)' if real_t else ''}
- Tests pass on rust impl: {fmt(rust_c, rust_t)}{f' (= {rust_c/rust_t*100:.0f}%)' if rust_t else ''}
- Flag coverage: {flag_m}/{flag_t} flags exercised (= {flag_pct})
- Branch/line coverage on Rust impl: {line_pct}

{fail_section(real_fail or [], "Test-correctness failures (tests that failed on the real utility)", None)}
{fail_section(rust_only_fail or [], "Impl-correctness failures (tests that passed on real, failed on rust)", None)}
## Compile / runtime failures of the Rust impl

{('First-line summary of the cargo error: `' + build_err_first + '`') if compile_failed and build_err_first else ('_The Rust impl compiled cleanly._' if not compile_failed else '_Compile failed but no build_error.txt was captured._')}

## Open questions for next round

_Analyst: list the specific feedback you want surfaced in round {int(rnd)+1}. The
driver appends the verbatim contents of this file under "Manual analyst
observations" in the next round's prompt._

- (write here)
"""
pathlib.Path(out_path).write_text(doc)
print(f"wrote {out_path}")
PY
