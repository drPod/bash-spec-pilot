#!/usr/bin/env python3
"""Compare the compiled Lean head model with GNU head on seeded line inputs."""
import os
import random
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
DEMO_BIN = HERE / ".lake" / "build" / "bin" / "demo"
GHEAD = os.environ.get("GHEAD", "/opt/homebrew/bin/ghead")

WORDS = ["alpha", "beta", "gamma", "", "a b c", "42", "x", "the quick", "z"]


def rand_input(rng):
    n = rng.randint(0, 8)
    return [rng.choice(WORDS) for _ in range(n)]


def as_stdin(lines):
    return ("\n".join(lines) + "\n") if lines else ""


def run(cmd, stdin_text):
    p = subprocess.run(cmd, input=stdin_text, capture_output=True, text=True)
    # Match the model's abstraction, which loses final-newline presence.
    return p.stdout.splitlines()


def model_head(k, stdin_text):
    return run([str(DEMO_BIN), "head", str(k)], stdin_text)


def gnu_head(k, stdin_text):
    return run([GHEAD, "-n", str(k)], stdin_text)


def main():
    if not DEMO_BIN.exists():
        sys.exit(f"build first: `lake build` (missing {DEMO_BIN})")
    trials = int(sys.argv[1]) if len(sys.argv) > 1 else 300
    rng = random.Random(0)

    passed, mismatches = 0, []
    for _ in range(trials):
        lines = rand_input(rng)
        k = rng.randint(0, len(lines) + 2)
        stdin_text = as_stdin(lines)
        m, g = model_head(k, stdin_text), gnu_head(k, stdin_text)
        if m == g:
            passed += 1
        elif len(mismatches) < 5:
            mismatches.append((lines, k, m, g))

    print(f"Suite A  head -n K, K >= 0   {passed}/{trials} match "
          f"({100 * passed / trials:.1f}% model-fidelity)")
    for lines, k, m, g in mismatches:
        print(f"  MISMATCH k={k} input={lines!r}\n    model={m!r}\n    gnu  ={g!r}")

    lines = ["l1", "l2", "l3", "l4", "l5"]
    g = gnu_head(-2, as_stdin(lines))
    print("\nSuite B  head -n -2 (count-from-end)  MODEL GAP")
    print(f"  gnu  ={g!r}   model: unsupported (headModel : Nat -> ...)")
    print("  => the spec/model covers K>=0 only; negative-count semantics is future work,")
    print("     and the two-layer method is what flagged it.")

    return 0 if passed == trials else 1


if __name__ == "__main__":
    raise SystemExit(main())
