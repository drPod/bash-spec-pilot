"""Round-trip probe JSONL and inject trace faults to test the judge and invariants."""
import copy
import json
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from ptrcheck.invariants import check_invariants  # noqa: E402
from ptrcheck.judge import classify_distinction, compare_documents, wire_problems  # noqa: E402
from ptrcheck.pointer_model import run_pointer_machine  # noqa: E402
from ptrcheck.trace_format import core, document_from_probe, parse_probe_jsonl, validate_document  # noqa: E402


def as_probe_jsonl(doc: dict, status=None, exit_record=True) -> bytes:
    """Render a document the way pointer_probe.c writes it."""
    lines = []
    for e in doc["events"]:
        rec = dict(e)
        rec["probe"] = {"base_known": True, "in_bounds": True, "clamped": False}
        lines.append(json.dumps(rec))
    if exit_record:
        f = doc["final"]
        mem = doc["events"][-1]["memory_hex"] if doc["events"] else ""
        lines.append(json.dumps({"kind": "exit", "status": f["status"] if status is None else status,
                                 "consumed": f["consumed"], "read_calls": f["read_calls"], "write_calls": f["write_calls"],
                                 "base_known": bool(doc["events"]), "chunk": 0, "defined": len(mem) // 2, "memory_hex": mem}))
    return ("\n".join(lines) + "\n").encode()


def stderr_of(final: dict) -> bytes:
    return f"consumed={final['consumed']}\nread_calls={final['read_calls']}\nwrite_calls={final['write_calls']}\n".encode()


class RoundTripTests(unittest.TestCase):
    def test_probe_jsonl_roundtrips_to_the_reference_document(self):
        for data, r, w in [(b"abc", [], []), (bytes(range(40)), [], [5, -1]), (b"abcdef", [4], [2, 0]), (b"", [], [])]:
            ref = run_pointer_machine(data, r, w, name="t")
            parsed = parse_probe_jsonl(as_probe_jsonl(ref))
            self.assertEqual(parsed["problems"], [])
            act = document_from_probe(ref["case"], parsed, ref["final"]["status"], bytes.fromhex(ref["final"]["output_hex"]), "c:test")
            self.assertEqual(core(act), core(ref))
            self.assertEqual(validate_document(act), [])
            self.assertEqual(check_invariants(act), [])
            self.assertEqual(wire_problems(ref["final"], ref["final"]["status"], bytes.fromhex(ref["final"]["output_hex"]),
                                           stderr_of(ref["final"]), False), [])

    def test_parser_flags_garbage_and_events_after_exit(self):
        ref = run_pointer_machine(b"abc", [], [])
        raw = as_probe_jsonl(ref) + b'{"kind":"write","seq":9}\nnot json\n'
        parsed = parse_probe_jsonl(raw)
        self.assertTrue(any("after exit" in p for p in parsed["problems"]))
        self.assertTrue(any("invalid JSON" in p for p in parsed["problems"]))

    def test_pending_derived_from_actual_memory(self):
        ref = run_pointer_machine(bytes(range(40)), [], [5, -1])
        act = document_from_probe(ref["case"], parse_probe_jsonl(as_probe_jsonl(ref)), 2, bytes(range(5)), "c:test")
        self.assertEqual(act["final"]["pending_hex"], bytes(range(5, 32)).hex())
        self.assertEqual(act["final"]["unread_hex"], bytes(range(32, 40)).hex())


class InjectedFaultTests(unittest.TestCase):
    """Each injected fault mirrors one compiled mutant in ptrcheck/mutations.py."""

    def setUp(self):
        self.data = bytes(range(40))
        self.ref = run_pointer_machine(self.data, [], [5], name="fault")
        self.assertEqual([e["kind"] for e in self.ref["events"]], ["read", "write", "write", "read", "write", "read"])

    def mutate(self, fn):
        doc = copy.deepcopy(self.ref)
        fn(doc)
        return doc

    def assert_flagged(self, doc, needle, wire_same=True):
        inv = check_invariants(doc)
        cmp = compare_documents(self.ref, doc)
        self.assertTrue(any(needle in p for p in inv), f"invariants missed {needle!r}: {inv}")
        self.assertTrue(cmp["event_problems"] or cmp["final_problems"], "judge did not distinguish")
        if wire_same:
            # stdout/status/counters identical: only the event trace tells them apart
            self.assertEqual(classify_distinction(doc["final"]["status"], [], cmp), "event_only")

    def test_wrong_pointer(self):
        def f(doc):
            e = doc["events"][2]
            e["offset"] = 0
            e["bytes_hex"] = self.data[0:27].hex()
            doc["final"]["output_hex"] = (self.data[0:5] + self.data[0:27] + self.data[32:40]).hex()
        self.assert_flagged(self.mutate(f), "write pointer offset 0 != retry offset 5", wire_same=False)

    def test_wrong_residual_request(self):
        def f(doc):
            doc["events"][2]["request"] = 32
        self.assert_flagged(self.mutate(f), "write request 32 != residual n-off = 27")
        self.assertTrue(any("exceeds initialized chunk" in p for p in check_invariants(self.mutate(f))))

    def test_request_one_byte(self):
        def f(doc):
            doc["events"][1]["request"] = 1
        self.assert_flagged(self.mutate(f), "write request 1 != residual")

    def test_skipped_short_write_retry(self):
        def f(doc):
            del doc["events"][2]
            for i, e in enumerate(doc["events"]):
                e["seq"] = i
            doc["final"]["output_hex"] = (self.data[0:5] + self.data[32:40]).hex()
        d = self.mutate(f)
        inv = check_invariants(d)
        self.assertTrue(any("read while 27 chunk bytes are undelivered" in p for p in inv), inv)
        self.assertTrue(any("missing expected write" in p or "event count" in p for p in compare_documents(self.ref, d)["event_problems"]))

    def test_read_before_drain(self):
        def f(doc):
            doc["events"][2] = dict(doc["events"][3], seq=2)
            del doc["events"][3]
            for i, e in enumerate(doc["events"]):
                e["seq"] = i
            doc["final"]["output_hex"] = (self.data[0:5] + self.data[32:40]).hex()
        inv = check_invariants(self.mutate(f))
        self.assertTrue(any("read before drain" in p for p in inv), inv)

    def test_zero_write_looping_extra_events(self):
        ref0 = run_pointer_machine(self.data, [], [0], name="z")
        doc = copy.deepcopy(ref0)
        extra = dict(doc["events"][1], seq=2, action=32, action_source="default", result=32, bytes_hex=self.data[:32].hex())
        doc["events"].append(extra)
        doc["final"].update(status=0, output_hex=self.data[:32].hex(), write_calls=2)
        inv = check_invariants(doc)
        self.assertTrue(any("after terminal event" in p for p in inv), inv)
        cmp = compare_documents(ref0, doc)
        self.assertTrue(any("unexpected extra write" in p for p in cmp["event_problems"]), cmp)
        # the strict per-case cap makes the compiled mutant abort instead: classified as 'abort'
        self.assertEqual(classify_distinction(3, ["status 3 != 2"], cmp), "abort")

    def test_read_request_31_on_empty_input(self):
        ref = run_pointer_machine(b"", [], [], name="e")
        doc = copy.deepcopy(ref)
        doc["events"][0]["request"] = 31
        doc["events"][0]["action"] = 31
        inv = check_invariants(doc)
        self.assertTrue(any("read request 31 != 32" in p for p in inv), inv)
        self.assertEqual(classify_distinction(0, [], compare_documents(ref, doc)), "event_only")

    def test_frame_violation_after_write(self):
        def f(doc):
            doc["events"][1]["memory_hex"] = ("ff" + doc["events"][1]["memory_hex"][2:])
        self.assertTrue(any("frame" in p for p in check_invariants(self.mutate(f))))

    def test_bytes_not_from_memory(self):
        def f(doc):
            e = doc["events"][2]
            e["bytes_hex"] = "00" * 27
        self.assertTrue(any("differ from memory" in p for p in check_invariants(self.mutate(f))))


if __name__ == "__main__":
    unittest.main()
