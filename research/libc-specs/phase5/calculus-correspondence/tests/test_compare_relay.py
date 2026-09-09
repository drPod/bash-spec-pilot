"""Meta-tests for compare_relay.py (calculus-correspondence-11): prove the comparator itself
detects each failure mode the orchestrator's audit named, using small synthetic fixture pairs
(not real compiler output — these test the COMPARATOR, not the pipeline). Run:
  python3 tests/test_compare_relay.py
Exits nonzero if any check fails.
"""
import json
import os
import sys
import tempfile

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from compare_relay import compare

BASE_STATE = {
    "attrs": {"delivered": [1, 2, 3], "lost": [], "input": [], "reads": [],
              "writes": [], "read_calls": 1, "write_calls": 0},
    "elements": [{"element": "block", "arg": "0",
                  "attrs": {"cap": 32, "len": 3, "bytes": [1, 2, 3]}, "elements": []}],
}


def ocaml_line(name, rc=0, state=BASE_STATE):
    attrs = {}
    for k, v in state["attrs"].items():
        if isinstance(v, list):
            attrs[k] = {"hex": "".join("%02x" % b for b in v), "len": len(v)}
        else:
            attrs[k] = v
    elems = []
    for e in state["elements"]:
        eattrs = {}
        for k, v in e["attrs"].items():
            eattrs[k] = ({"hex": "".join("%02x" % b for b in v), "len": len(v)}
                         if isinstance(v, list) else v)
        elems.append({"element": e["element"], "arg": e["arg"], "attrs": eattrs, "elements": []})
    return json.dumps({"mode": "run", "entry": "x", "name": name, "outcome": "continue", "rc": rc,
                        "attrs": attrs, "elements": elems})


def _lean_state(state):
    def conv(node):
        attrs = {k: ("()" if v == [] else v) for k, v in node["attrs"].items()}
        elems = [{"element": e["element"], "arg": e["arg"], **conv(e)} for e in node["elements"]]
        return {"attrs": attrs, "elements": elems}
    return conv(state)


def lean_line(name, rc=0, state=BASE_STATE):
    return json.dumps({"entry": "x", "name": name, "outcome": "continue", "rc": rc,
                        "state": _lean_state(state)})


def write(path, lines):
    with open(path, "w") as f:
        f.write("\n".join(lines) + "\n")


def run_case(desc, lean_lines, ocaml_lines, expect_ok, expect_substring=None):
    with tempfile.TemporaryDirectory() as d:
        lp, op = os.path.join(d, "lean.jsonl"), os.path.join(d, "ocaml.jsonl")
        write(lp, lean_lines)
        write(op, ocaml_lines)
        ok, report = compare("meta-test", lp, op, quiet=True)
        assert ok == expect_ok, f"{desc}: expected ok={expect_ok}, got {ok}; report={report}"
        if expect_substring is not None:
            blob = " ".join(report["errors"]) + " " + " ".join(r for _, r in report["mismatches"])
            assert expect_substring in blob, f"{desc}: expected {expect_substring!r} in {blob!r}"
    print(f"PASS: {desc}")


# 1. Genuine match: sanity check the harness itself before testing failure modes.
run_case("baseline genuine match",
         [lean_line("a"), lean_line("b", rc=1)],
         [ocaml_line("a"), ocaml_line("b", rc=1)],
         expect_ok=True)

# 2. Duplicate name in one file must be flagged, not silently overwritten.
run_case("duplicate name in ocaml file",
         [lean_line("a")],
         [ocaml_line("a"), ocaml_line("a")],
         expect_ok=False, expect_substring="DUPLICATE NAMES")

# 3. A case missing from one side (present in the other) must be flagged.
run_case("case missing from ocaml corpus",
         [lean_line("a"), lean_line("b")],
         [ocaml_line("a")],
         expect_ok=False, expect_substring="IN LEAN ONLY")

run_case("case missing from lean corpus",
         [lean_line("a")],
         [ocaml_line("a"), ocaml_line("b")],
         expect_ok=False, expect_substring="IN OCAML ONLY")

# 4. Empty corpus on either side must be a hard failure, not a vacuous "0/0" pass.
run_case("empty ocaml corpus",
         [lean_line("a")],
         [],
         expect_ok=False, expect_substring="EMPTY CORPUS")

run_case("empty lean corpus",
         [],
         [ocaml_line("a")],
         expect_ok=False, expect_substring="EMPTY CORPUS")

run_case("both corpora empty",
         [],
         [],
         expect_ok=False, expect_substring="EMPTY CORPUS")

# 5. A changed NESTED element attribute (not top-level, not the first field checked) must be
#    caught — this is exactly the class of bug the old comparator's "first element only" +
#    curated-field-subset design could miss.
changed_nested = json.loads(json.dumps(BASE_STATE))
changed_nested["elements"][0]["attrs"]["bytes"] = [1, 2, 4]  # was [1,2,3]
run_case("changed nested element attribute",
         [lean_line("a", state=BASE_STATE)],
         [ocaml_line("a", state=changed_nested)],
         expect_ok=False, expect_substring=None)

# 6. A changed COUNTER (read_calls) — a field the OLD comparator never compared at all.
changed_counter = json.loads(json.dumps(BASE_STATE))
changed_counter["attrs"]["read_calls"] = 99
run_case("changed read_calls counter (field the old comparator never checked)",
         [lean_line("a", state=BASE_STATE)],
         [ocaml_line("a", state=changed_counter)],
         expect_ok=False, expect_substring=None)

# 7. A second, deeper-nested element (element-within-element) that differs must also be caught.
deep_a = {"attrs": {"delivered": "()", "lost": "()", "input": "()", "reads": "()",
                     "writes": "()", "read_calls": 0, "write_calls": 0},
          "elements": [{"element": "a", "arg": "1", "attrs": {"v": 10},
                        "elements": [{"element": "b", "arg": "2", "attrs": {"v": 7}, "elements": []}]}]}
deep_b = json.loads(json.dumps(deep_a))
deep_b["elements"][0]["elements"][0]["attrs"]["v"] = 999
run_case("changed doubly-nested element attribute",
         [lean_line("a", state=deep_a)],
         [ocaml_line("a", state=deep_b)],
         expect_ok=False, expect_substring=None)

# 8. Element order must NOT matter (canon_node keys by (element, arg), not position).
two_elems_order1 = {"attrs": {}, "elements": [
    {"element": "a", "arg": "1", "attrs": {"v": 1}, "elements": []},
    {"element": "a", "arg": "2", "attrs": {"v": 2}, "elements": []}]}
two_elems_order2 = {"attrs": {}, "elements": [
    {"element": "a", "arg": "2", "attrs": {"v": 2}, "elements": []},
    {"element": "a", "arg": "1", "attrs": {"v": 1}, "elements": []}]}
run_case("element order differs but content is identical -> still a match",
         [lean_line("a", state=two_elems_order1)],
         [ocaml_line("a", state=two_elems_order2)],
         expect_ok=True)

print("\nAll compare_relay.py meta-tests passed.")
