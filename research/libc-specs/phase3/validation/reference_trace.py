#!/usr/bin/env python3
"""Emit an independent pointer trace or validate --check-doc. See TRACE_SCHEMA.md.

Exit 64 for invalid controls, 1 for invalid documents. Input is capped at 1 MiB."""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

from ptrcheck.actions import ActionError, parse_actions  # noqa: E402
from ptrcheck.invariants import check_invariants  # noqa: E402
from ptrcheck.judge import compare_documents  # noqa: E402
from ptrcheck.pointer_model import run_pointer_machine  # noqa: E402
from ptrcheck.trace_format import core, trace_sha256, validate_document  # noqa: E402

INPUT_CAP = 1 << 20


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    src = ap.add_mutually_exclusive_group()
    src.add_argument("--input-hex", default=None)
    src.add_argument("--stdin", action="store_true", help="read the raw input bytes from stdin")
    src.add_argument("--case", default=None, help="corpus case name (see --tier)")
    ap.add_argument("--tier", default="quick")
    ap.add_argument("--reads", default="")
    ap.add_argument("--writes", default="")
    ap.add_argument("--name", default="reference")
    ap.add_argument("--core-only", action="store_true", help="print only the canonical case/events/final")
    ap.add_argument("--check-doc", type=Path, default=None,
                    help="validate a common-schema document, check invariants and compare with the reference")
    args = ap.parse_args(argv)

    if args.check_doc is not None:
        doc = json.loads(args.check_doc.read_text())
        problems = validate_document(doc)
        if not problems:
            problems += check_invariants(doc)
            c = doc["case"]
            ref = run_pointer_machine(bytes.fromhex(c["input_hex"]), c["reads"], c["writes"], name=c["name"])
            cmp = compare_documents(ref, doc)
            problems += cmp["event_problems"] + cmp["final_problems"]
        print(json.dumps({"document": str(args.check_doc), "sha256": trace_sha256(doc) if not validate_document(doc) else None,
                          "ok": not problems, "problems": problems}, indent=1))
        return 0 if not problems else 1

    try:
        if args.case is not None:
            from ptrcheck.cases import build_cases
            match = [c for c in build_cases(args.tier) if c.name == args.case]
            if not match or match[0].expect_reject:
                print(f"unknown or reject-only case {args.case!r} in tier {args.tier}", file=sys.stderr)
                return 64
            c = match[0]
            data, reads, writes, name = c.data, list(c.reads), list(c.writes), c.name
        else:
            if args.stdin:
                data = sys.stdin.buffer.read(INPUT_CAP + 1)
                if len(data) > INPUT_CAP:
                    print("input exceeds 1 MiB cap", file=sys.stderr)
                    return 64
            else:
                data = bytes.fromhex(args.input_hex or "")
            reads, writes, name = parse_actions(args.reads, "reads"), parse_actions(args.writes, "writes"), args.name
    except (ActionError, ValueError) as e:
        print(f"invalid arguments: {e}", file=sys.stderr)
        return 64
    doc = run_pointer_machine(data, reads, writes, name=name)
    doc["trace_sha256"] = trace_sha256(doc)
    print(json.dumps(core(doc) if args.core_only else doc, indent=1, sort_keys=True))
    return 0


if __name__ == "__main__":
    sys.exit(main())
