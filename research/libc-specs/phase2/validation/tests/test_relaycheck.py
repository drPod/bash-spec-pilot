"""Schedule parsing and hand-computed oracle regressions."""
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from relaycheck.corpus import build_corpus, corpus_hash  # noqa: E402
from relaycheck.mutants import MUTANTS, apply_mutant  # noqa: E402
from relaycheck.oracle import run_relay  # noqa: E402
from relaycheck.schedule import MAX_ACTION, MAX_SCHEDULE, ScheduleError, parse_schedule  # noqa: E402


class ParseTests(unittest.TestCase):
    def test_accepts_valid(self):
        self.assertEqual(parse_schedule("", "reads"), [])
        self.assertEqual(parse_schedule("2,1,-1", "reads"), [2, 1, -1])
        self.assertEqual(parse_schedule("1,0,-1", "writes"), [1, 0, -1])
        self.assertEqual(parse_schedule(str(MAX_ACTION), "reads"), [MAX_ACTION])
        self.assertEqual(len(parse_schedule(",".join(["1"] * MAX_SCHEDULE), "writes")), MAX_SCHEDULE)

    def test_rejects(self):
        bad_reads = ["0", "-2", "1,0", "1,,2", "a", "1,", ",1", " 1", "+1", "01", "1.0", "0x10", "-", "--1",
                     "99999999999999999999", str(MAX_ACTION + 1), "-1-1", "1 2", ",", "-0", "١", "1\t",
                     "9223372036854775808", ",".join(["1"] * (MAX_SCHEDULE + 1))]
        for text in bad_reads:
            with self.subTest(text=text):
                with self.assertRaises(ScheduleError):
                    parse_schedule(text, "reads")
        for text in ["-2", "1,,0", "01", "-0", "+0", "0,", "1" * 40]:
            with self.subTest(text=text):
                with self.assertRaises(ScheduleError):
                    parse_schedule(text, "writes")
        with self.assertRaises(ValueError):
            parse_schedule("1", "other")


class OracleTests(unittest.TestCase):
    def test_default_copies(self):
        d = bytes(range(100))
        o = run_relay(d, [], [])
        self.assertEqual((o.output, o.status, o.consumed, o.read_calls, o.write_calls), (d, 0, 100, 5, 4))

    def test_empty(self):
        o = run_relay(b"", [], [])
        self.assertEqual((o.output, o.status, o.read_calls, o.write_calls), (b"", 0, 1, 0))

    def test_read_error_first(self):
        o = run_relay(b"abc", [-1], [])
        self.assertEqual((o.output, o.status, o.consumed, o.read_calls, o.write_calls), (b"", 1, 0, 1, 0))

    def test_read_error_at_eof_position(self):
        d = bytes(64)
        o = run_relay(d, [32, 32, -1], [])
        self.assertEqual((o.output, o.status, o.consumed, o.read_calls, o.write_calls), (d, 1, 64, 3, 2))

    def test_write_zero_after_partial(self):
        d = bytes(range(40))
        o = run_relay(d, [], [5, 0])
        self.assertEqual((o.output, o.status, o.consumed, o.read_calls, o.write_calls), (d[:5], 2, 32, 1, 2))

    def test_write_error_before(self):
        d = bytes(range(40))
        o = run_relay(d, [], [-1])
        self.assertEqual((o.output, o.status, o.consumed, o.read_calls, o.write_calls), (b"", 2, 32, 1, 1))

    def test_short_writes_then_default(self):
        d = bytes(range(32))
        o = run_relay(d, [], [7, 7, 7, 7])
        self.assertEqual((o.output, o.status, o.read_calls, o.write_calls), (d, 0, 2, 5))

    def test_read_exhaustion(self):
        d = bytes(range(100))
        o = run_relay(d, [1], [])
        self.assertEqual((o.output, o.status, o.read_calls, o.write_calls), (d, 0, 6, 5))

    def test_over_request_clamped(self):
        d = bytes(range(40))
        o = run_relay(d, [33], [33])
        self.assertEqual((o.output, o.status, o.read_calls, o.write_calls), (d, 0, 3, 2))

    def test_stderr_text(self):
        o = run_relay(b"xy", [1], [1])
        self.assertEqual(o.stderr_text(), "consumed=2\nread_calls=3\nwrite_calls=2\n")

    def test_rejects_invalid(self):
        with self.assertRaises(ScheduleError):
            run_relay(b"x", [0], [])
        with self.assertRaises(ScheduleError):
            run_relay(b"x", [], [-2])

    def test_output_is_prefix_of_input(self):
        import itertools
        d = bytes(range(70))
        for r in itertools.product([-1, 1, 5, 32], repeat=2):
            for w in itertools.product([-1, 0, 1, 3], repeat=2):
                o = run_relay(d, list(r), list(w))
                self.assertTrue(d.startswith(o.output))
                self.assertEqual(o.output + o.remaining, d[: len(o.output)] + o.remaining)
                if o.status == 0:
                    self.assertEqual(o.output, d)


class CorpusTests(unittest.TestCase):
    def test_corpus_deterministic(self):
        a = build_corpus("quick")
        b = build_corpus("quick")
        self.assertEqual(corpus_hash(a), corpus_hash(b))
        self.assertGreater(len(a), 100)

    def test_mutants_apply_once(self):
        text = ("int relay(void) {\n unsigned char buf[32];\n n = read(0, buf, 32);\n if (n < 0) return 1;\n"
                " if (n == 0) return 0;\n w = write(1, buf + off, (size_t)n - off);\n if (w <= 0) return 2;\n"
                " off = off + (size_t)w;\n}\n")
        for m in MUTANTS:
            self.assertNotEqual(apply_mutant(text, m), text)


if __name__ == "__main__":
    unittest.main()
