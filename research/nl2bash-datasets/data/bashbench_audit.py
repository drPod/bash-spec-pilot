"""Reproduce the BashBench (BashCoder-R1, arXiv 2606.27733) audit in bashbench-2026-audit.md.

Usage:
    uv run --with nothing python bashbench_audit.py <dir-with-extracted-json>

Expects these files, extracted from Zenodo record 18408692 (BashCoder-R1.zip):
    test_cases/command_test_cases_validated.json
    data/evaluation/script/evaluation_multi-line_script.json
    data/sft/sft_command.json          data/sft/sft_script.json
    data/grpo/grpo_command.json        data/grpo/grpo_script.json

Filenames may be flattened with '__' separators; both layouts are handled.

Scope: this covers the contamination and duplication half of the audit only, and it starts from
already-extracted JSON. Downloading the Zenodo record, unpacking it, and the harness inspection
written up in benchmark-validity.md were all done by hand and are not reproduced here.
"""

import collections
import json
import pathlib
import sys

FILES = {
    "bench_single": "test_cases/command_test_cases_validated.json",
    "bench_multi": "data/evaluation/script/evaluation_multi-line_script.json",
    "sft_cmd": "data/sft/sft_command.json",
    "sft_script": "data/sft/sft_script.json",
    "grpo_cmd": "data/grpo/grpo_command.json",
    "grpo_script": "data/grpo/grpo_script.json",
}


def load(root, rel):
    """Load a records list, tolerating flattened '__' filenames and {'data': [...]} wrappers."""
    candidates = [root / rel, root / rel.replace("/", "__")]
    for p in candidates:
        if p.exists():
            d = json.loads(p.read_text())
            return d if isinstance(d, list) else d.get("data", d)
    raise FileNotFoundError(f"none of {[str(c) for c in candidates]}")


def norm(s):
    """Collapse all whitespace, so leakage is matched on content rather than formatting."""
    return " ".join((s or "").split())


def has_test(rec):
    """The archive ships 927 single-line records; the paper's 773 are the validated ones
    that actually carry a test script. This is also how the shipped harness counts `total`."""
    t = rec.get("test_case")
    if isinstance(t, dict):
        return bool((t.get("test_script") or "").strip())
    return bool((t or "").strip())


def main(root):
    """Reproduce the audit from an extracted copy of the Zenodo archive.

    Reports how many of the benchmark's scored tasks reappear in the SFT and GRPO files released
    alongside it, and how many of its prompts are distinct. Takes the directory the 1.1 GB archive
    was unpacked into.
    """
    root = pathlib.Path(root)
    d = {k: load(root, v) for k, v in FILES.items()}

    bench = [r for r in d["bench_single"] if r.get("validated") and has_test(r)]
    print(f"single-line records shipped : {len(d['bench_single'])}")
    print(f"validated + has test script : {len(bench)}   (paper says 773)")

    inputs = [norm(r["input"]) for r in bench]
    sft = {norm(r["input"]) for r in d["sft_cmd"]}
    grpo = {norm(r["input"]) for r in d["grpo_cmd"]}

    n = len(inputs)
    in_sft = sum(1 for x in inputs if x in sft)
    in_grpo = sum(1 for x in inputs if x in grpo)
    print(f"\nFinding 1 — contamination")
    print(f"  in SFT command set  : {in_sft}/{n} = {100 * in_sft / n:.1f}%")
    print(f"  in GRPO command set : {in_grpo}/{n} = {100 * in_grpo / n:.1f}%")

    pairs = {(norm(r["input"]), norm(r["output"])) for r in d["sft_cmd"]}
    exact = sum(1 for r in bench if (norm(r["input"]), norm(r["reference_output"])) in pairs)
    print(f"  exact (input, output) pairs shared with SFT : {exact}"
          "   <- leakage is task-level, not record-level")

    uniq = len(set(inputs))
    print(f"\nFinding 2 — duplication")
    print(f"  unique prompts: {uniq}/{n} -> {n - uniq} redundant ({100 * (n - uniq) / n:.1f}%)")
    for prompt, count in collections.Counter(inputs).most_common(3):
        print(f"    x{count:<3} {prompt[:80]}")

    multi = [norm(r["input"]) for r in d["bench_multi"]]
    script_train = {norm(r["input"]) for r in d["sft_script"]}
    script_train |= {norm(r["input"]) for r in d["grpo_script"]}
    hit = sum(1 for x in multi if x in script_train)
    print(f"\nmulti-line control (N={len(multi)})")
    print(f"  in SFT/GRPO script sets : {hit}   <- expected 0")
    print(f"  unique prompts          : {len(set(multi))}/{len(multi)}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    main(sys.argv[1])
