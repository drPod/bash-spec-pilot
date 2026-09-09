"""Strict, full-state OCaml-vs-Lean comparator for the byte-relay protocol
(calculus-correspondence-9/10/11).

calculus-correspondence-11 rewrite. The prior version (kept as `compare_relay_v1.py` for the
historical record; do not delete) had four real bugs, found by the orchestrator's audit, not by
this worker:

1. Duplicate case names were silently overwritten in a `dict` (last write wins) — a duplicate
   name in either producer's output would silently drop a case instead of being reported.
2. Only OCaml's key set was iterated, so a name present in Lean but absent from OCaml (or vice
   versa, once duplicates are counted correctly) was invisible; "matched N/M" could be too high.
3. An empty corpus (0 cases, e.g. a wrong path or an accidentally-truncated file) compared as
   "0/0" and exited 0 (success) — a silent false-positive on the most basic failure mode.
4. Only `rc` plus `delivered`/`lost`/`input` plus the FIRST element's `cap`/`len`/`bytes` were
   compared — not `read_calls`/`write_calls`/`reads`/`writes`, not any element beyond the first,
   not nested elements, and (a separate latent crash, never actually triggered because every
   corpus run so far happened to have `outcome: continue` on every matching case) a genuine
   `outcome: failure` match on both sides would `KeyError` trying to read a nonexistent `attrs`.

This version: (a) collects every line, reports any duplicate name as a hard error before doing
anything else; (b) requires the two case-name SETS to be identical (symmetric difference must be
empty), also a hard error, and requires each corpus to be non-empty; (c) recursively compares
the ENTIRE state tree — every attribute, every element at every depth, keyed by (element name,
arg) so element order doesn't matter — not a curated field subset; (d) handles every outcome
(`continue`/`raise`/`return`/`failure`) without assuming `attrs`/`state` exist.

## Representation normalization (documented, not silently absorbed into a "helper")

OCaml (`cb_main.ml`'s `attr_json`/`state_json`) renders an attribute as: an int, a bool, a JSON
list of ints (a non-byte-range int list, e.g. `reads`/`writes` schedules with `-1` markers), or
`{"hex": ..., "len": ...}` (a byte-range, i.e. every element in [0,255], int list). Lean
(`CalculusNested.Val.render`) renders the SAME four cases as: the OCaml-side plain int/bool
unchanged, `"()"` for `.lit .unit` (which is how BOTH an empty list (nil) and a genuine unit
value render — every attribute this comparator looks at is always constructed as a list, so `()`
is always treated as `[]` here; this is a real, documented ambiguity in `Val.render`, not
silently resolved by assuming — if a future attribute could legitimately hold `.lit .unit`, this
comparator would need a schema, not a blanket rule), or a flat JSON array for ANY well-formed int
list regardless of byte range (not just the byte-range ones OCaml would hex-encode).

Canonical form here: every int-list-shaped value (OCaml hex-object OR list, Lean flat array or
`"()"`) becomes a plain Python `list[int]`; ints/bools/strings pass through unchanged. This makes
a byte-range list (OCaml hex, Lean flat array) and a non-byte-range list (OCaml list, Lean flat
array) compare correctly through the SAME code path.
"""
import json
import sys


def canon_ocaml_scalar(v):
    if isinstance(v, dict) and 'hex' in v:
        h = v['hex']
        return [int(h[i:i + 2], 16) for i in range(0, len(h), 2)]
    if isinstance(v, list):
        return list(v)
    return v


def canon_lean_scalar(v):
    if v == "()":
        return []
    if isinstance(v, list):
        return list(v)
    return v


def canon_node(node, scalar_fn):
    """`node`: a dict with an `attrs` dict and (optionally) an `elements` list of dicts each
    shaped `{"element": name, "arg": argtext, "attrs": {...}, "elements": [...]}` (recursive).
    Returns a structure comparable with `==` across the OCaml/Lean representations: attrs as a
    dict of canonical scalars, elements as a dict keyed by (name, arg) — NOT a positional list,
    so producer-side element ordering is not asserted, only content — recursing into each."""
    attrs = {k: scalar_fn(v) for k, v in node.get('attrs', {}).items()}
    elems = node.get('elements', [])
    keyed = {}
    dup_elem_keys = []
    for e in elems:
        key = (e['element'], e['arg'])
        if key in keyed:
            dup_elem_keys.append(key)
        keyed[key] = canon_node(e, scalar_fn)
    if dup_elem_keys:
        raise ValueError(f"duplicate (element, arg) key(s) in one state tree: {dup_elem_keys}")
    return {'attrs': attrs, 'elements': keyed}


def canon_ocaml_run(d):
    """Full canonical form of one `cb_main.exe run` JSON line: outcome/rc plus the state tree
    when the outcome actually carries one (`continue`/`raise`/`return`; `failure` carries
    nothing on either side)."""
    out = {'outcome': d['outcome'], 'rc': d.get('rc')}
    if 'attrs' in d:
        out['state'] = canon_node({'attrs': d['attrs'], 'elements': d.get('elements', [])},
                                    canon_ocaml_scalar)
    return out


def canon_lean_run(d):
    out = {'outcome': d['outcome'], 'rc': d.get('rc')}
    if 'state' in d:
        out['state'] = canon_node(d['state'], canon_lean_scalar)
    return out


def index_by_name(path, canon_fn, name_key='name'):
    """Returns (dict[name -> canonical record], list-of-duplicate-names, total-line-count).
    Never silently drops a duplicate: the caller decides whether duplicates are fatal."""
    by_name = {}
    dups = []
    n = 0
    with open(path) as f:
        for line in f:
            line = line.rstrip('\n')
            if not line:
                continue
            d = json.loads(line)
            if d.get('mode') is not None and d.get('mode') != 'run':
                continue  # the one leading "lower" line in *_ocaml_* files, if present
            name = d.get(name_key)
            if name is None:
                continue
            n += 1
            if name in by_name:
                dups.append(name)
            by_name[name] = canon_fn(d)
    return by_name, dups, n


def compare(entry, lean_path, ocaml_path, quiet=False):
    """Returns (ok: bool, report: dict) — report always has enough detail to reconstruct the
    verdict without re-running; `ok` is False for ANY of: duplicate names, non-identical case
    sets, an empty corpus on either side, or a content mismatch on a shared case."""
    lean, lean_dups, lean_n = index_by_name(lean_path, canon_lean_run)
    ocaml, ocaml_dups, ocaml_n = index_by_name(ocaml_path, canon_ocaml_run)

    errors = []
    if lean_n == 0:
        errors.append(f"EMPTY CORPUS: {lean_path} has 0 case lines")
    if ocaml_n == 0:
        errors.append(f"EMPTY CORPUS: {ocaml_path} has 0 case lines")
    if lean_dups:
        errors.append(f"DUPLICATE NAMES in {lean_path}: {sorted(set(lean_dups))}")
    if ocaml_dups:
        errors.append(f"DUPLICATE NAMES in {ocaml_path}: {sorted(set(ocaml_dups))}")

    lean_names, ocaml_names = set(lean), set(ocaml)
    missing_in_ocaml = lean_names - ocaml_names
    missing_in_lean = ocaml_names - lean_names
    if missing_in_ocaml:
        errors.append(f"IN LEAN ONLY (missing from OCaml corpus): {sorted(missing_in_ocaml)}")
    if missing_in_lean:
        errors.append(f"IN OCAML ONLY (missing from Lean corpus): {sorted(missing_in_lean)}")

    mismatches = []
    matched = 0
    for name in sorted(lean_names & ocaml_names):
        l, o = lean[name], ocaml[name]
        try:
            if l == o:
                matched += 1
            else:
                mismatches.append((name, f"lean={l!r} ocaml={o!r}"))
        except ValueError as e:
            mismatches.append((name, f"CANONICALIZATION ERROR: {e}"))

    ok = not errors and not mismatches
    report = {
        'entry': entry, 'lean_n': lean_n, 'ocaml_n': ocaml_n,
        'matched': matched, 'compared': len(lean_names & ocaml_names),
        'errors': errors, 'mismatches': mismatches, 'ok': ok,
    }
    if not quiet:
        print(f"{entry}: lean_n={lean_n} ocaml_n={ocaml_n} matched={matched} "
              f"compared={report['compared']} ok={ok}")
        for e in errors:
            print(f"  ERROR {e}")
        for name, reason in mismatches:
            print(f"  MISMATCH {name}: {reason}")
    return ok, report


if __name__ == "__main__":
    entry = sys.argv[1] if len(sys.argv) > 1 else "relay"
    ok, _ = compare(entry, f"results/compare_lean_{entry}.jsonl", f"results/compare_ocaml_{entry}.jsonl")
    sys.exit(0 if ok else 1)
