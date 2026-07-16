#!/usr/bin/env python3
"""Differential layer: does the kernel-verified Lean model match the real binary?

Layer 1 (proof) is checked by generate.py via `lake build` + the axiom gate.
Layer 2 (this file) runs the compiled model head-to-head against the GNU
utility over seeded random cases and compares stdout lines + exit code.
Mismatches are findings (model-fidelity gaps) rather than crashes; they feed
the refinement loop and the spec-quality story.

Usage: uv run validate.py <target> [trials]
"""

import random
import subprocess
import sys
from pathlib import Path

from targets import TARGETS, Target, oracle_cmd

LEAN_BIN = Path(__file__).resolve().parent / "lean" / ".lake" / "build" / "bin" / "model"


def _run(cmd: list[str], stdin_text: str) -> tuple[list[str], int]:
    p = subprocess.run(cmd, input=stdin_text, capture_output=True, text=True, timeout=30)
    return p.stdout.splitlines(), p.returncode


def validate(target: Target, trials: int = 200, seed: int = 0,
             max_mismatches: int = 10) -> dict:
    if not LEAN_BIN.exists():
        sys.exit(f"build first: `lake build` in pipeline/lean (missing {LEAN_BIN})")
    rng = random.Random(seed)  # fixed seed: reproducible, no wall-clock dependence
    oracle = oracle_cmd(target)
    passed, mismatches = 0, []
    for _ in range(trials):
        args, lines = target.gen_case(rng)
        stdin_text = ("\n".join(lines) + "\n") if lines else ""
        m_out, m_code = _run([str(LEAN_BIN), *args], stdin_text)
        g_out, g_code = _run([oracle, *args], stdin_text)
        if target.normalize(m_out) == target.normalize(g_out) and m_code == g_code:
            passed += 1
        elif len(mismatches) < max_mismatches:
            mismatches.append({"args": args, "stdin": lines,
                               "model_out": m_out, "oracle_out": g_out,
                               "model_code": m_code, "oracle_code": g_code})
    return {"trials": trials, "passed": passed, "oracle": oracle,
            "mismatches": mismatches}


if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] not in TARGETS:
        sys.exit(f"usage: validate.py <{'|'.join(TARGETS)}> [trials]")
    r = validate(TARGETS[sys.argv[1]],
                 trials=int(sys.argv[2]) if len(sys.argv) > 2 else 200)
    print(f"{sys.argv[1]} vs {r['oracle']}: {r['passed']}/{r['trials']} match")
    for m in r["mismatches"]:
        print(f"  MISMATCH args={m['args']} stdin={m['stdin']!r}\n"
              f"    model={m['model_out']!r} (exit {m['model_code']})\n"
              f"    gnu  ={m['oracle_out']!r} (exit {m['oracle_code']})")
    raise SystemExit(0 if r["passed"] == r["trials"] else 1)
