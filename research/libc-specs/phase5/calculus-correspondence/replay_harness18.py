#!/usr/bin/env python3
"""calculus-correspondence-18: replay the 33 saved same-input comparisons against a FRESHLY built
`compare-run` (tokenizer switched to the total, fail-closed `tokenizeTotal`), WITHOUT any new OCaml
run: the OCaml side is the saved `results/compare_ocaml_<name>.jsonl`, exactly as accepted.

For every saved pair the script (1) runs the new `compare-run` on the same entry/export/case file
into `results/replay18/compare_lean_<name>.jsonl`, (2) checks the new Lean output is BYTE-IDENTICAL
to the saved `results/compare_lean_<name>.jsonl` (the tokenizer switch must not change any result),
and (3) re-runs the strict comparator (`compare_relay.compare`) new-Lean vs saved-OCaml.
Nothing under `results/` other than `results/replay18/` is written."""
import json, os, subprocess, sys, hashlib
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from compare_relay import compare  # the accepted strict comparator, unchanged

BIN = os.path.expanduser("~/.cache/bash-spec-pilot/phase5-integration-lean/.lake/build/bin/compare-run")
RES = os.path.join(HERE, "results")
OUT = os.path.join(RES, "replay18")
CASES = os.path.join(HERE, "..", "calculus-bytes", "results")
EXPORT = {"finite": "export_input__finite_ints.tsv", "nested": "export_input__nested_state.tsv",
          "relay": "export_input__byte_relay_exec.tsv"}

def entry_of(name):
    if name.startswith("finite_"): return name[len("finite_"):], EXPORT["finite"], "cases_curated.tsv"
    if name.startswith("nested_"): return name[len("nested_"):], EXPORT["nested"], "cases_curated.tsv"
    if name == "relay_phase3": return "relay", EXPORT["relay"], "cases_phase3_standard.tsv"
    return name, EXPORT["relay"], "cases_curated.tsv"

def sha(p):
    return hashlib.sha256(open(p, "rb").read()).hexdigest()

def main():
    os.makedirs(OUT, exist_ok=True)
    names = sorted(f[len("compare_ocaml_"):-len(".jsonl")] for f in os.listdir(RES)
                   if f.startswith("compare_ocaml_") and f.endswith(".jsonl"))
    summary = {"compare_run_sha256": sha(BIN), "pairs": [], "all_ok": True, "total_matched": 0}
    for name in names:
        entry, export, cases = entry_of(name)
        new_lean = os.path.join(OUT, f"compare_lean_{name}.jsonl")
        with open(os.path.join(CASES, cases)) as fin, open(new_lean, "w") as fout:
            r = subprocess.run([BIN, entry, os.path.join(RES, export)], stdin=fin, stdout=fout,
                               stderr=subprocess.PIPE, text=True)
        saved_lean = os.path.join(RES, f"compare_lean_{name}.jsonl")
        identical = sha(new_lean) == sha(saved_lean)
        ok, rep = compare(name, new_lean, os.path.join(RES, f"compare_ocaml_{name}.jsonl"), quiet=True)
        rec = {"name": name, "entry": entry, "export": export, "cases": cases, "compare_run_rc": r.returncode,
               "new_lean_sha256": sha(new_lean), "saved_lean_sha256": sha(saved_lean),
               "new_identical_to_saved_lean": identical, "strict_ok_vs_saved_ocaml": ok,
               "matched": rep["matched"], "compared": rep["compared"], "lean_n": rep["lean_n"], "ocaml_n": rep["ocaml_n"],
               "errors": rep["errors"], "mismatches": rep["mismatches"][:5]}
        summary["pairs"].append(rec)
        summary["total_matched"] += rep["matched"]
        if not (ok and identical and r.returncode == 0): summary["all_ok"] = False
        print(f"{name:32s} entry={entry:20s} rc={r.returncode} identical={identical} strict_ok={ok} matched={rep['matched']}/{rep['compared']}")
    with open(os.path.join(OUT, "SUMMARY.json"), "w") as f:
        json.dump(summary, f, indent=1)
    print(f"pairs={len(names)} total_matched={summary['total_matched']} all_ok={summary['all_ok']}")
    sys.exit(0 if summary["all_ok"] else 1)

if __name__ == "__main__":
    main()
