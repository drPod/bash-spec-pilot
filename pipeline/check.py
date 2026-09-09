#!/usr/bin/env python3
"""Check generated Lean artifacts with static, kernel, axiom, and differential gates."""

import argparse
import json
import re
import subprocess
import time
from pathlib import Path

from contracts import CheckResult, SpecTheorem
from targets import TARGETS, Target
from validate import validate

LEAN_DIR = Path(__file__).resolve().parent / "lean"
GENERATED = LEAN_DIR / "Pipeline" / "Generated.lean"

ALLOWED_AXIOMS = {"propext", "Classical.choice", "Quot.sound"}
AXIOM_LINE = re.compile(
    r"'([^']+)' (?:depends on axioms: \[([^\]]*)\]|does not depend on any axioms)")
LEAN_IDENT = re.compile(r"[A-Za-z_][A-Za-z0-9_'.]*\Z")
# Lexical filter only, not a complete Lean-command sandbox.
FORBIDDEN = re.compile(
    r"^\s*import\b"
    r"|\b(partial|unsafe|axiom|sorry|admit|opaque|native_decide|macro|elab)\b"
    r"|\b(extern|implemented_by)\b", re.M)


def lake_build() -> tuple[bool, str, float]:
    t0 = time.time()
    p = subprocess.run(["lake", "build"], cwd=LEAN_DIR,
                       capture_output=True, text=True, timeout=600)
    out = p.stdout + p.stderr
    # Lean can exit successfully with a sorry warning.
    ok = p.returncode == 0 and "declaration uses `sorry`" not in out
    return ok, out, time.time() - t0


def axiom_gate(theorem_names: list[str]) -> tuple[list[str], str]:
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


def check(target: Target, source: str, theorems: list[SpecTheorem], trials: int) -> CheckResult:
    result: CheckResult = {
        "failures": [], "mismatches": [], "guard_hits": [],
        "build_ok": None, "axioms_ok": None, "diff": None,
        "build_log": "", "axioms_log": "", "secs": {},
    }
    GENERATED.write_text(source)
    hits = sorted({m.group(0).strip() for m in FORBIDDEN.finditer(source)})
    result["guard_hits"] = hits
    if hits:
        result["failures"].append(f"forbidden constructs found: {hits} — remove them")
    if not 3 <= len(theorems) <= 6:
        result["failures"].append(
            f"{len(theorems)} spec theorems; the contract requires 3 to 6 meaningful ones")
    if result["failures"]:
        return result

    result["build_ok"], result["build_log"], secs = lake_build()
    result["secs"]["build"] = round(secs, 1)
    if not result["build_ok"]:
        result["failures"].append("Lean build failed:\n" + result["build_log"][-6000:])
        return result

    ax_problems, result["axioms_log"] = axiom_gate([t["name"] for t in theorems])
    result["axioms_ok"] = not ax_problems
    result["failures"].extend(ax_problems)
    if ax_problems:
        return result

    t0 = time.time()
    diff = validate(target, trials=trials)
    result["secs"]["diff"] = round(time.time() - t0, 1)
    result["diff"] = {"passed": diff["passed"], "trials": diff["trials"]}
    result["mismatches"] = diff["mismatches"]
    if diff["passed"] < diff["trials"]:
        result["failures"].append(
            f"kernel accepted, but the model diverged from the real program on "
            f"{diff['trials'] - diff['passed']}/{diff['trials']} random inputs")
    return result


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--target", required=True, choices=list(TARGETS))
    ap.add_argument("--artifact", required=True, help="path to artifact JSON")
    ap.add_argument("--trials", type=int, default=200)
    ap.add_argument("--out", help="write full result JSON here")
    args = ap.parse_args()
    art = json.loads(Path(args.artifact).read_text())
    result = check(TARGETS[args.target], art["lean_source"],
                   art["spec_theorems"], args.trials)
    if args.out:
        Path(args.out).write_text(json.dumps(result, indent=2))
    print(f"{args.target}: build={result['build_ok']} axioms={result['axioms_ok']} "
          f"diff={result['diff']}")
    for f in result["failures"]:
        print(f"FAILURE: {f[:2000]}")
    for m in result["mismatches"][:5]:
        print(f"  MISMATCH args={m['args']} stdin={m['stdin']!r}\n"
              f"    model={m['model_out']!r} (exit {m['model_code']})\n"
              f"    gnu  ={m['oracle_out']!r} (exit {m['oracle_code']})")
    return 0 if not result["failures"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
