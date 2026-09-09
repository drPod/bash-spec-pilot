"""Check the reference against hand traces, schema, invariants, and byte conservation."""
import itertools
import json
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from ptrcheck.actions import ActionError  # noqa: E402
from ptrcheck.cases import build_cases  # noqa: E402
from ptrcheck.invariants import check_invariants  # noqa: E402
from ptrcheck.judge import compare_documents  # noqa: E402
from ptrcheck.pointer_model import run_pointer_machine  # noqa: E402
from ptrcheck.trace_format import core, expand_hand_traces, trace_sha256, validate_document  # noqa: E402

HAND = Path(__file__).resolve().parents[1] / "hand_traces.json"


class HandTraceTests(unittest.TestCase):
    def setUp(self):
        self.hand = expand_hand_traces(json.loads(HAND.read_text()))

    def test_twelve_hand_traces_are_well_formed(self):
        self.assertEqual(len(self.hand), 12)
        for d in self.hand:
            with self.subTest(d["case"]["name"]):
                self.assertEqual(validate_document(d), [])
                self.assertEqual(check_invariants(d), [])

    def test_reference_reproduces_every_hand_trace_exactly(self):
        for d in self.hand:
            with self.subTest(d["case"]["name"]):
                m = run_pointer_machine(bytes.fromhex(d["case"]["input_hex"]), d["case"]["reads"], d["case"]["writes"],
                                        name=d["case"]["name"])
                cmp = compare_documents(d, m)
                self.assertEqual(cmp["event_problems"], [])
                self.assertEqual(cmp["final_problems"], [])
                self.assertEqual(core(d), core(m))
                self.assertEqual(trace_sha256(d), trace_sha256(m))

    def test_hand_trace_names_unique(self):
        names = [d["case"]["name"] for d in self.hand]
        self.assertEqual(len(names), len(set(names)))


class ReferenceTests(unittest.TestCase):
    def test_unsupported_capacity_is_rejected(self):
        for capacity in (0, 1, 31, 33):
            with self.subTest(capacity=capacity), self.assertRaises(ValueError):
                run_pointer_machine(b"abcd", [], [], capacity=capacity)

    def test_quick_corpus_reference_is_valid_and_invariant(self):
        cases = [c for c in build_cases("quick") if not c.expect_reject]
        self.assertGreater(len(cases), 100)
        for c in cases:
            d = run_pointer_machine(c.data, list(c.reads), list(c.writes), name=c.name)
            with self.subTest(c.name):
                self.assertEqual(validate_document(d), [])
                self.assertEqual(check_invariants(d), [])

    def test_conservation_and_status_over_small_product(self):
        data = bytes(range(70))
        for r in itertools.product([-1, 1, 5, 32], repeat=2):
            for w in itertools.product([-1, 0, 1, 31], repeat=2):
                d = run_pointer_machine(data, list(r), list(w))
                f = d["final"]
                out, pend, unread = (bytes.fromhex(f[k]) for k in ("output_hex", "pending_hex", "unread_hex"))
                self.assertEqual(out + pend + unread, data)
                self.assertTrue(data.startswith(out))
                if f["status"] == 0:
                    self.assertEqual(out, data)
                if f["status"] == 2:
                    self.assertTrue(pend)
                if f["status"] == 1:
                    self.assertEqual(pend, b"")
                self.assertEqual(f["read_calls"], sum(1 for e in d["events"] if e["kind"] == "read"))
                self.assertLessEqual(f["read_calls"], len(data) + 1)
                self.assertLessEqual(f["write_calls"], len(data))

    def test_write_loads_from_memory_not_from_a_chunk_copy(self):
        # After a short first chunk, the second chunk overwrites only its prefix; the retry
        # write at the advanced pointer must return exactly what the array holds there.
        d = run_pointer_machine(b"ABCDEFG", [5, 2], [3])
        ev = d["events"]
        self.assertEqual([e["kind"] for e in ev], ["read", "write", "write", "read", "write", "read"])
        self.assertEqual((ev[2]["offset"], ev[2]["request"], ev[2]["bytes_hex"]), (3, 2, b"DE".hex()))
        self.assertEqual(ev[3]["memory_hex"], b"FGCDE".hex())  # stale C D E remain defined
        self.assertEqual(d["final"]["output_hex"], b"ABCDEFG".hex())

    def test_rejects_invalid_actions(self):
        with self.assertRaises(ActionError):
            run_pointer_machine(b"x", [0], [])
        with self.assertRaises(ActionError):
            run_pointer_machine(b"x", [], [-2])


if __name__ == "__main__":
    unittest.main()
