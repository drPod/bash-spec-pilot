"""Test corpus, build plans, and bounded execution without compiling C."""
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from ptrcheck import FROZEN_RELAY_SHA256  # noqa: E402
from ptrcheck.actions import ActionError, parse_actions  # noqa: E402
from ptrcheck.build_probe import COMPILER_AS_BYTES, build_all, sha256_file  # noqa: E402
from ptrcheck.cases import CASE_BUDGET, build_cases, corpus_hash  # noqa: E402
from ptrcheck.exec_bounded import Scratch, read_capture, run_bounded  # noqa: E402
from ptrcheck.mutations import MUTANTS, apply_mutant  # noqa: E402

ROOT = Path(__file__).resolve().parents[1]
RELAY = ROOT.parents[1] / "phase2" / "relay.c"
PROBE = ROOT / "probe" / "pointer_probe.c"


class CorpusTests(unittest.TestCase):
    def test_tiers_deterministic_unique_and_budgeted(self):
        for tier in ("quick", "standard"):
            a, b = build_cases(tier), build_cases(tier)
            self.assertEqual(corpus_hash(a), corpus_hash(b))
            self.assertLessEqual(len(a), CASE_BUDGET, f"{tier} has {len(a)} cases")
            self.assertEqual(len({c.name for c in a}), len(a))
        self.assertGreater(len(build_cases("full")), CASE_BUDGET)

    def test_corpus_has_required_families(self):
        names = {c.name for c in build_cases("standard")}
        for n in ("directed/buf31/w1", "directed/buf32/w16_16", "directed/buf33/w31", "directed/buf65/w5_werr",
                  "directed/loop/wzero_x8", "directed/cross33/r31_2", "hand/boundary33_short31", "reject/r_zero",
                  "noflags/noflags/n40"):
            self.assertIn(n, names)
        cats = {c.category for c in build_cases("standard")}
        self.assertEqual(cats, {"exhaustive", "directed", "noflags", "hand", "reject"})

    def test_payloads_are_binary_and_bounded(self):
        cases = build_cases("standard")
        self.assertLessEqual(max(len(c.data) for c in cases), 4096)
        self.assertLessEqual(max(len(c.reads) + len(c.writes) for c in cases), 40)
        self.assertTrue(any(0 in c.data and 255 in c.data for c in cases))

    def test_schedule_text_grammar(self):
        self.assertEqual(parse_actions("2,1,-1", "reads"), [2, 1, -1])
        for bad in ("0", "-2", "01", "+1", "1,", ",1", " 1", "1 2", "-0"):
            with self.assertRaises(ActionError):
                parse_actions(bad, "reads")
        self.assertEqual(parse_actions("0", "writes"), [0])


class MutantTests(unittest.TestCase):
    def test_frozen_source_hash(self):
        self.assertEqual(sha256_file(RELAY), FROZEN_RELAY_SHA256)

    def test_each_mutant_pattern_occurs_once_in_frozen_source(self):
        text = RELAY.read_text()
        for m in MUTANTS:
            with self.subTest(m["name"]):
                self.assertEqual(text.count(m["old"]), 1)
                self.assertNotEqual(apply_mutant(text, m), text)
        self.assertEqual(len({m["name"] for m in MUTANTS}), len(MUTANTS))
        self.assertEqual(len(MUTANTS), 8)


class BuildPlanTests(unittest.TestCase):
    def test_dry_run_plans_bounded_serial_commands_without_compiling(self):
        with tempfile.TemporaryDirectory() as d:
            plan = build_all(RELAY, PROBE, Path(d) / "build", cc="cc", dry_run=True)
            self.assertFalse((Path(d) / "build").exists())
        self.assertTrue(plan["dry_run"])
        cmds = plan["log"]
        self.assertEqual(len(cmds), 2 + 3 * 2 + 1 + 2 * len(MUTANTS))
        for e in cmds:
            b = e["bounded"]
            self.assertEqual(b[:3], ["timeout", "--kill-after=2s", "60s"])
            self.assertEqual(b[3], "prlimit")
            self.assertIn(f"--as={COMPILER_AS_BYTES}:{COMPILER_AS_BYTES}", b)
            self.assertIn("--cpu=60:60", b)
        flat = [" ".join(e["cmd"]) for e in cmds]
        self.assertTrue(any("-Dread=probe_read -Dwrite=probe_write" in c and "relay_frozen.c" in c for c in flat))
        self.assertTrue(any("-Wl,--wrap=read -Wl,--wrap=write" in c for c in flat))
        self.assertTrue(any("-DPROBE_WRAP" in c for c in flat) and any("-DPROBE_MACRO" in c for c in flat))
        self.assertTrue(all("-U_FORTIFY_SOURCE" in c for c in flat if " -c " in c))
        self.assertEqual({e["role"] for e in plan["executables"].values()}, {"original", "control", "mutant"})
        self.assertEqual(sorted(n for n, e in plan["executables"].items() if e["role"] == "original"),
                         ["orig_macro_O0", "orig_macro_O2", "orig_wrap_O2"])


class ExecutorTests(unittest.TestCase):
    def test_child_address_space_bounded_to_256MiB(self):
        with tempfile.TemporaryDirectory() as d:
            r = run_bounded([sys.executable, "-c", "x = bytearray(400 * 1024 * 1024)"], b"", Scratch(Path(d)))
        self.assertNotEqual(r.status, 0)
        self.assertIn(b"MemoryError", r.stderr)
        self.assertFalse(r.timed_out)

    def test_child_wall_timeout_kills_process_group(self):
        with tempfile.TemporaryDirectory() as d:
            r = run_bounded([sys.executable, "-c", "while True: pass"], b"", Scratch(Path(d)), wall=0.2)
        self.assertTrue(r.timed_out)
        self.assertLess(r.status, 0)

    def test_stdin_stdout_trace_roundtrip(self):
        with tempfile.TemporaryDirectory() as d:
            s = Scratch(Path(d))
            code = ("import sys,os; d=sys.stdin.buffer.read(); sys.stdout.buffer.write(d[::-1]); "
                    "open(sys.argv[1],'w').write('{\"kind\":\"exit\"}\\n')")
            r = run_bounded([sys.executable, "-c", code, str(s.trace)], bytes(range(256)), s)
        self.assertEqual(r.status, 0)
        self.assertEqual(r.stdout, bytes(range(256))[::-1])
        self.assertIn(b'"exit"', r.trace)

    def test_capture_rejects_devices_and_oversize(self):
        with self.assertRaisesRegex(ValueError, "regular file"):
            read_capture(Path("/dev/full"))
        with tempfile.TemporaryDirectory() as d:
            p = Path(d) / "big"
            p.write_bytes(b"x" * 10)
            with self.assertRaises(ValueError):
                read_capture(p, cap=5)
            self.assertEqual(read_capture(Path(d) / "absent", missing_ok=True), b"")

    def test_not_reentrant(self):
        from ptrcheck import exec_bounded
        self.assertTrue(exec_bounded._active.acquire(blocking=False))
        try:
            with self.assertRaises(RuntimeError):
                run_bounded(["/bin/true"], b"", Scratch(Path(tempfile.mkdtemp())))
        finally:
            exec_bounded._active.release()


if __name__ == "__main__":
    unittest.main()
