#!/usr/bin/env python3
"""Build the pipeline artifact from WcFromC.lean and its six public spec theorems."""

import json
from pathlib import Path

HERE = Path(__file__).resolve().parent

THEOREMS = [
    {"name": "wcLoop_counts_newlines",
     "informal": "The C program's getchar loop terminates on any byte sequence and adds exactly "
                 "the number of newline bytes to nl, consuming all of stdin and writing nothing."},
    {"name": "run_stdout_eq_newline_count",
     "informal": "For every input, stdout is exactly one line: the decimal count of newline bytes "
                 "fed to the program (POSIX wc -l counts <newline> characters)."},
    {"name": "run_stdout_eq_line_count",
     "informal": "At the harness interface (newline-free lines), the printed count equals the "
                 "number of input lines."},
    {"name": "run_exit_success",
     "informal": "The program's `return 0` is observed as exit status 0 on every input."},
    {"name": "run_independent_of_args",
     "informal": "With only -l in scope, the output does not depend on the argument vector."},
    {"name": "run_append",
     "informal": "Newline counting is additive over input concatenation (the loop is a fold over "
                 "bytes)."},
]

if __name__ == "__main__":
    src = (HERE / "WcFromC.lean").read_text()
    (HERE / "artifact.json").write_text(
        json.dumps({"lean_source": src, "spec_theorems": THEOREMS}, indent=1))
    print(f"artifact.json: {len(src)} chars of Lean, {len(THEOREMS)} spec theorems")
