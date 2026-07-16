#!/usr/bin/env python3
"""Checker: gate one generated artifact through kernel + differential layers.

Generator-agnostic on purpose: the artifact may come from the OpenAI driver
(generate.py), a Claude subagent, or a human. Sequence: static guard ->
`lake build` (kernel check, builds the executable) -> axiom gate (#print axioms
whitelisted to propext/Classical.choice/Quot.sound) -> differential run vs the
GNU binary. Returns machine-readable failures suitable as refinement feedback.

Artifact JSON: {"lean_source": "...", "spec_theorems": [{"name": ..., "informal": ...}]}

Usage: uv run check.py --target uniq --artifact artifact.json [--trials 200]
"""

import argparse
import json
import re
import subprocess
import time
from pathlib import Path

from targets import TARGETS, Target
from validate import validate

LEAN_DIR = Path(__file__).resolve().parent / "lean"
GENERATED = LEAN_DIR / "Pipeline" / "Generated.lean"

ALLOWED_AXIOMS = {"propext", "Classical.choice", "Quot.sound"}
AXIOM_LINE = re.compile(
    r"'([^']+)' (?:depends on axioms: \[([^\]]*)\]|does not depend on any axioms)")
LEAN_IDENT = re.compile(r"[A-Za-z_][A-Za-z0-9_'.]*\Z")
FORBIDDEN = re.compile(
    r"^\s*import\b"
    r"|\b(partial|unsafe|axiom|sorry|admit|opaque|native_decide|macro|elab)\b"
    r"|@\[\s*(extern|implemented_by)", re.M)


def lake_build() -> tuple[bool, str, float]:
    t0 = time.time()
    p = subprocess.run(["lake", "build"], cwd=LEAN_DIR,
                       capture_output=True, text=True, timeout=600)
    out = p.stdout + p.stderr
    # `sorry` only warns at build time; reject it here so the message is precise
    # (the axiom gate would catch it too, via sorryAx).
    ok = p.returncode == 0 and "declaration uses `sorry`" not in out
    return ok, out, time.time() - t0


def axiom_gate(theorem_names: list[str]) -> tuple[list[str], str]:
    """#print axioms for run + every claimed spec theorem; whitelist core axioms."""
    problems, decls = [], ["Pipeline.Generated.run"]
    for n in theorem_names:
        if not LEAN_IDENT.match(n):  # names are LLM output: no Lean injection
            problems.append(f"invalid theorem name: {n!r}")
            continue
        decls.append(n if n.startswith("Pipeline.Generated.") else f"Pipeline.Generated.{n}")
    src = "import Pipeline\n" + "\n".join(f"#print axioms {d}" for d in decls) + "\n"
    check_file = LEAN_DIR / "AxiomCheck.lean"
    check_file.write_text(src)
    p = subprocess.run(["lake", "env", "lean", check_file.name], cwd=LEAN_DIR,
                       capture_output=True, text=True, timeout=300)
    out = p.stdout + p.stderr
    if p.returncode != 0:
        problems.append("axiom check did not elaborate (a claimed theorem "
                        "probably does not exist); output:\n" + out)
        return problems, out
    reported = {}
    for m in AXIOM_LINE.finditer(out):
        reported[m.group(1)] = [a.strip() for a in (m.group(2) or "").split(",") if a.strip()]
    for d in decls:
        if d not in reported:
            problems.append(f"no axiom report for {d}")
        else:
            bad = [a for a in reported[d] if a not in ALLOWED_AXIOMS]
            if bad:
                problems.append(f"{d} depends on forbidden axioms: {bad}")
    return problems, out


def check(target: Target, source: str, theorems: list[dict], trials: int) -> dict:
    """Run every gate; returns failures (feedback-ready) + per-gate detail."""
    r: dict = {"failures": [], "mismatches": [], "build_ok": None,
               "axioms_ok": None, "diff": None, "build_log": "", "axioms_log": "",
               "secs": {}}
    GENERATED.write_text(source)
    hits = sorted({m.group(0).strip() for m in FORBIDDEN.finditer(source)})
    r["guard_hits"] = hits
    if hits:
        r["failures"].append(f"forbidden constructs found: {hits} — remove them")
    if not 3 <= len(theorems) <= 6:
        r["failures"].append(f"{len(theorems)} spec theorems; the contract "
                             "requires 3 to 6 meaningful ones")
    if r["failures"]:
        return r

    r["build_ok"], r["build_log"], secs = lake_build()
    r["secs"]["build"] = round(secs, 1)
    if not r["build_ok"]:
        r["failures"].append("Lean build failed:\n" + r["build_log"][-6000:])
        return r

    ax_problems, r["axioms_log"] = axiom_gate([t["name"] for t in theorems])
    r["axioms_ok"] = not ax_problems
    r["failures"].extend(ax_problems)
    if ax_problems:
        return r

    t0 = time.time()
    diff = validate(target, trials=trials)
    r["secs"]["diff"] = round(time.time() - t0, 1)
    r["diff"] = {"passed": diff["passed"], "trials": diff["trials"]}
    r["mismatches"] = diff["mismatches"]
    if diff["passed"] < diff["trials"]:
        r["failures"].append(
            f"kernel accepted, but the model diverged from the real program on "
            f"{diff['trials'] - diff['passed']}/{diff['trials']} random inputs")
    return r


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--target", required=True, choices=list(TARGETS))
    ap.add_argument("--artifact", required=True, help="path to artifact JSON")
    ap.add_argument("--trials", type=int, default=200)
    ap.add_argument("--out", help="write full result JSON here")
    args = ap.parse_args()
    art = json.loads(Path(args.artifact).read_text())
    r = check(TARGETS[args.target], art["lean_source"],
              art["spec_theorems"], args.trials)
    if args.out:
        Path(args.out).write_text(json.dumps(r, indent=2))
    print(f"{args.target}: build={r['build_ok']} axioms={r['axioms_ok']} "
          f"diff={r['diff']}")
    for f in r["failures"]:
        print(f"FAILURE: {f[:2000]}")
    for m in r["mismatches"][:5]:
        print(f"  MISMATCH args={m['args']} stdin={m['stdin']!r}\n"
              f"    model={m['model_out']!r} (exit {m['model_code']})\n"
              f"    gnu  ={m['oracle_out']!r} (exit {m['oracle_code']})")
    return 0 if not r["failures"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
