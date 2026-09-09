"""Same-input OCaml-vs-Lean comparator for the byte-relay protocol (calculus-correspondence-9).

SUPERSEDED by `compare_relay.py` (calculus-correspondence-11). Kept verbatim (not deleted) as
the historical record of what actually produced the "1,080/1,080" figures reported in sessions
9/10 — see `compare_relay.py`'s docstring for the four bugs found in an orchestrator audit and
`README.md`'s "Session -11" section for which of the superseded numbers changed once re-verified
with the fixed comparator.

Reads compare_lean_<entry>.jsonl (`compare-run` output) and compare_ocaml_<entry>.jsonl
(`cb_main.exe run` output, same entry and case file) and reports exact/mismatched cases.
Normalizes each side's attribute representation (Lean: nested-pair-as-flat-array via
`Val.render`, or `"()"` for empty; OCaml: `{"hex": ..., "len": ...}`) to a bare hex string
before comparing, and compares `rc`, `delivered`, `lost`, `input`, and the sole `block`
element's `cap`/`len`/`bytes`. Does not compare `read_calls`/`write_calls`/`reads`/`writes`
by default (uncomment to add) or every element (only `block`, which is all these fixtures use).
"""
import json
import sys


def hex_of_ints(xs):
    return ''.join('%02x' % (b & 0xff) for b in xs)


def normalize_lean_attr(v):
    if v == "()":
        return ""
    if isinstance(v, list):
        return hex_of_ints(v)
    return v


def normalize_ocaml_attr(v):
    if isinstance(v, dict) and 'hex' in v:
        return v['hex']
    return v


def compare(entry, lean_path, ocaml_path):
    lean = {}
    with open(lean_path) as f:
        for line in f:
            d = json.loads(line)
            lean[d['name']] = d
    ocaml = {}
    with open(ocaml_path) as f:
        for line in f:
            d = json.loads(line)
            if d.get('mode') == 'run' and 'name' in d:
                ocaml[d['name']] = d

    mismatches = []
    matched = 0
    for name, o in ocaml.items():
        l = lean.get(name)
        if l is None:
            mismatches.append((name, "MISSING IN LEAN"))
            continue
        if o['outcome'] != l['outcome']:
            mismatches.append((name, f"outcome differ: ocaml={o['outcome']} lean={l['outcome']}"))
            continue
        if o.get('rc') != l.get('rc'):
            mismatches.append((name, f"rc differ: ocaml={o.get('rc')} lean={l.get('rc')}"))
            continue
        oa, la = o['attrs'], l['state']['attrs']
        diffs = []
        for key in ['delivered', 'lost', 'input']:
            ov, lv = normalize_ocaml_attr(oa.get(key)), normalize_lean_attr(la.get(key))
            if ov != lv:
                diffs.append(f"{key}: ocaml={ov!r} lean={lv!r}")
        oe = o['elements'][0]['attrs'] if o.get('elements') else {}
        le = l['state']['elements'][0]['attrs'] if l['state'].get('elements') else {}
        for key in ['cap', 'len', 'bytes']:
            ov, lv = normalize_ocaml_attr(oe.get(key)), normalize_lean_attr(le.get(key))
            if ov != lv:
                diffs.append(f"block.{key}: ocaml={ov!r} lean={lv!r}")
        if diffs:
            mismatches.append((name, "; ".join(diffs)))
        else:
            matched += 1

    print(f"{entry}: matched {matched}/{len(ocaml)}")
    for name, reason in mismatches:
        print(f"  MISMATCH {name}: {reason}")
    return len(mismatches) == 0


if __name__ == "__main__":
    entry = sys.argv[1] if len(sys.argv) > 1 else "relay"
    ok = compare(entry, f"results/compare_lean_{entry}.jsonl", f"results/compare_ocaml_{entry}.jsonl")
    sys.exit(0 if ok else 1)
