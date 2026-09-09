#!/usr/bin/env python3
"""Mocked sequential Lean compile: missing imports, order/cycles, error stop, audit, argv."""
import json
import os
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import replay  # noqa: E402


class ImportOrderTests(unittest.TestCase):
    def test_missing_import_fail_closed(self):
        with tempfile.TemporaryDirectory() as td:
            d = Path(td)
            (d / 'A.lean').write_text('import MissingDep\n')
            with self.assertRaises(ValueError) as ctx:
                replay.lean_compile_order(d, ['A'])
            self.assertIn('missing Lean dependency', str(ctx.exception))

    def test_dependency_order(self):
        with tempfile.TemporaryDirectory() as td:
            d = Path(td)
            (d / 'A.lean').write_text('import Init\n')
            (d / 'B.lean').write_text('import A\n')
            (d / 'C.lean').write_text('import B\nimport A\n')
            order = replay.lean_compile_order(d, ['C'])
            self.assertEqual(order, ['A', 'B', 'C'])

    def test_cycle_fail_closed(self):
        with tempfile.TemporaryDirectory() as td:
            d = Path(td)
            (d / 'A.lean').write_text('import B\n')
            (d / 'B.lean').write_text('import A\n')
            with self.assertRaises(ValueError) as ctx:
                replay.lean_compile_order(d, ['A'])
            self.assertIn('cycle', str(ctx.exception).lower())

    def test_trailing_comment_is_parsed(self):
        with tempfile.TemporaryDirectory() as td:
            d = Path(td)
            (d / 'A.lean').write_text('def x := 1\n')
            (d / 'B.lean').write_text('import A -- local dep\n')
            self.assertEqual(replay.lean_compile_order(d, ['B']), ['A', 'B'])

    def test_block_comment_import_ignored(self):
        with tempfile.TemporaryDirectory() as td:
            d = Path(td)
            (d / 'A.lean').write_text('def x := 1\n')
            (d / 'B.lean').write_text('/- import Missing -/\nimport A\n')
            self.assertEqual(replay.lean_compile_order(d, ['B']), ['A', 'B'])

    def test_multiline_import_rejected(self):
        with tempfile.TemporaryDirectory() as td:
            d = Path(td)
            (d / 'A.lean').write_text('def x := 1\n')
            (d / 'B.lean').write_text('import\nA\n')
            with self.assertRaises(ValueError) as ctx:
                replay.lean_compile_order(d, ['B'])
            self.assertIn('unsupported Lean import syntax', str(ctx.exception))

    def test_multiple_imports_one_line_rejected(self):
        with tempfile.TemporaryDirectory() as td:
            d = Path(td)
            (d / 'A.lean').write_text('def x := 1\n')
            (d / 'C.lean').write_text('def y := 1\n')
            (d / 'B.lean').write_text('import A import C\n')
            with self.assertRaises(ValueError) as ctx:
                replay.lean_compile_order(d, ['B'])
            self.assertIn('unsupported Lean import syntax', str(ctx.exception))


class SequentialCompileTests(unittest.TestCase):
    def test_error_stops_further_compile(self):
        calls = []

        def fake_run(argv, cwd, seconds, log_path, max_wait=5, extra_env=None):
            Path(log_path).write_text('fail\n' if len(calls) == 0 else 'should-not\n')
            calls.append(argv[-1])
            if len(calls) == 1:
                return 1, 0.1
            return 0, 0.1

        with tempfile.TemporaryDirectory() as td:
            scratch = Path(td) / 's'
            receipts = Path(td) / 'r'
            scratch.mkdir(); receipts.mkdir()
            (scratch / 'A.lean').write_text('def x := 1\n')
            (scratch / 'B.lean').write_text('import A\n')
            with mock.patch.object(replay, 'run_real', side_effect=fake_run):
                out = replay.compile_lean_modules_sequential(
                    Path('/fake/lean'), scratch, ['A', 'B'], receipts, 'e')
            self.assertFalse(out['ok'])
            self.assertEqual(calls, ['A.lean'])
            self.assertIn('compiler failure', out['reason'])
            self.assertTrue(Path(out['per_file'][0]['receipt']).is_file())

    def test_resource_args_and_persisted_json(self):
        captured = {}

        def fake_run(argv, cwd, seconds, log_path, max_wait=5, extra_env=None):
            captured['argv'] = argv
            captured['seconds'] = seconds
            captured['env'] = extra_env
            captured['max_wait'] = max_wait
            Path(log_path).write_text('ok\n')
            Path(cwd, 'M.olean').write_bytes(b'olean')
            return 0, 0.2

        with tempfile.TemporaryDirectory() as td:
            scratch = Path(td) / 's'
            receipts = Path(td) / 'r'
            scratch.mkdir(); receipts.mkdir()
            (scratch / 'M.lean').write_text('def x := 1\n')
            with mock.patch.object(replay, 'run_real', side_effect=fake_run):
                out = replay.compile_lean_modules_sequential(
                    Path('/toolchains/lean'), scratch, ['M'], receipts, 'e')
            self.assertTrue(out['ok'])
            argv = captured['argv']
            self.assertEqual(argv[0], '/toolchains/lean')
            self.assertIn('-j1', argv)
            self.assertIn('-s16384', argv)
            self.assertIn('-DElab.async=false', argv)
            self.assertEqual(captured['seconds'], 60)
            self.assertEqual(captured['max_wait'], 5)
            self.assertEqual(captured['env']['LEAN_PATH'], str(scratch))
            rec = out['per_file'][0]
            self.assertEqual(rec['address_space_bytes'], 3 * 1024 ** 3)
            self.assertEqual(rec['environment']['LEAN_NUM_THREADS'], '1')
            saved = json.loads(Path(rec['receipt']).read_text())
            self.assertEqual(saved['file'], 'M.lean')
            self.assertEqual(saved['exit_status'], 0)

    def test_lock_wait_default_is_short(self):
        self.assertLessEqual(replay.LEAN_LOCK_WAIT, 5)
        self.assertLessEqual(replay.compile_lean_modules_sequential.__defaults__[1], 5)

    def test_audit_failure_sorry(self):
        text = "'Bad.thm' depends on axioms: [sorryAx]\n"
        names, results = replay._parse_axiom_prints(text)
        self.assertEqual(names, ['Bad.thm'])
        self.assertFalse(results['Bad.thm']['allowed'])

    def test_audit_requires_check_ok_and_exact_names(self):
        expected = ['T.a', 'T.b']
        text = (
            "'T.a' does not depend on any axioms\n"
            "'T.b' depends on axioms: [propext]\n"
        )
        ok, res = replay.audit_theorems_ok(text, expected, dict(ok=True, exit_status=0))
        self.assertTrue(ok)
        fail_exit, _ = replay.audit_theorems_ok(text, expected, dict(ok=True, exit_status=1))
        self.assertFalse(fail_exit)
        fail_empty, _ = replay.audit_theorems_ok('', expected, dict(ok=True, exit_status=0))
        self.assertFalse(fail_empty)
        extra = text + "'T.c' does not depend on any axioms\n"
        fail_extra, _ = replay.audit_theorems_ok(extra, expected, dict(ok=True, exit_status=0))
        self.assertFalse(fail_extra)

    def test_negative_audit_prints_then_exit1(self):
        """Valid axiom prints with compiler exit 1 must not pass."""
        text = (
            "'CalculusNested.setAttrAt_frame' does not depend on any axioms\n"
            "'CalculusNested.addElemAt_attrs' does not depend on any axioms\n"
            "'CalculusNested.removeElemAt_here_frame' does not depend on any axioms\n"
        )
        expected = [
            'CalculusNested.setAttrAt_frame',
            'CalculusNested.addElemAt_attrs',
            'CalculusNested.removeElemAt_here_frame',
        ]
        ok, _ = replay.audit_theorems_ok(text, expected, dict(ok=False, exit_status=1))
        self.assertFalse(ok)

    def test_nested_theorems_ok_ignores_failed_check(self):
        calls = {'n': 0}

        def fake_run(argv, cwd, seconds, log_path, max_wait=5, extra_env=None):
            calls['n'] += 1
            Path(log_path).write_text(
                "'CalculusNested.setAttrAt_frame' does not depend on any axioms\n"
                "'CalculusNested.addElemAt_attrs' does not depend on any axioms\n"
                "'CalculusNested.removeElemAt_here_frame' does not depend on any axioms\n"
            )
            mod = Path(argv[-1]).stem
            if mod == 'Check':
                return 1, 0.1
            Path(cwd, mod + '.olean').write_bytes(b'x')
            return 0, 0.1

        entry = {
            'id': 'lean_calculus_nested_real',
            'source_file': 'x',
            'archive_source': None,
            'source_sha256': None,
            'theorems': [
                'CalculusNested.setAttrAt_frame',
                'CalculusNested.addElemAt_attrs',
                'CalculusNested.removeElemAt_here_frame',
            ],
            'expected_exit': 0,
        }
        with tempfile.TemporaryDirectory() as td:
            td = Path(td)
            src = td / 'CalculusNested.evaluation-frozen.lean'
            src.write_text('def x := 1\n')
            entry['source_sha256'] = replay.sha(src)
            receipts = td / 'r'
            receipts.mkdir()
            with mock.patch.object(replay, '_pinned_lean_binary', return_value=Path('/lean')), \
                 mock.patch.object(replay, 'fresh_scratch', return_value=td / 's'), \
                 mock.patch.object(replay, 'LIBC', td), \
                 mock.patch.object(replay, 'run_real', side_effect=fake_run):
                (td / 's').mkdir()
                # archive_source absent uses source_file relative to LIBC
                entry['source_file'] = src.name
                out = replay.replay_lean_calculus_nested_real(entry, receipts)
        self.assertFalse(out['passed'])
        self.assertEqual(out.get('audit_exit_status'), 1)
        self.assertTrue(any(p.get('receipt') for p in out.get('per_file') or []))


class NoLakeRegression(unittest.TestCase):
    def test_lake_not_in_compile_helper_argv(self):
        argv = replay._direct_lean_argv('/lean', 'Foo')
        self.assertNotIn('lake', argv[0])
        joined = ' '.join(argv)
        self.assertNotIn('lake', joined)

    def test_phase3_link_uses_leanc_not_lean_run(self):
        captured = []

        def fake_run(argv, cwd, seconds, log_path, max_wait=5, extra_env=None):
            captured.append(argv)
            Path(log_path).write_text('ok\n')
            last = Path(argv[-1]) if argv else Path('x')
            if str(argv[0]).endswith('leanc'):
                Path(cwd, 'pointer-trace').write_bytes(b'\x7fELF')
                os.chmod(Path(cwd, 'pointer-trace'), 0o755)
                return 0, 0.1
            if argv[1:2] == ['-c'] or (len(argv) > 2 and '-c' in argv):
                Path(cwd, Path(argv[-1]).stem + '.c').write_text('/*c*/\n')
                return 0, 0.1
            Path(cwd, Path(argv[-1]).stem + '.olean').write_bytes(b'o')
            return 0, 0.1

        with tempfile.TemporaryDirectory() as td:
            scratch = Path(td) / 's'
            receipts = Path(td) / 'r'
            scratch.mkdir(); receipts.mkdir()
            (scratch / 'TraceMain.lean').write_text('def main := 1\n')
            with mock.patch.object(replay, 'run_real', side_effect=fake_run):
                out = replay.compile_lean_c_sources_and_link(
                    Path('/toolchains/lean'), Path('/toolchains/leanc'),
                    scratch, ['TraceMain'], 'pointer-trace', receipts, 'p3')
            self.assertTrue(out['ok'])
            self.assertTrue(Path(out['executable']).is_file())
            self.assertTrue(any(Path(a[0]).name == 'leanc' for a in captured))
            self.assertFalse(any('--run' in a for a in captured))
            self.assertTrue((receipts / 'p3.link.json').is_file())




class Tokenizer134AdapterTests(unittest.TestCase):
    def test_malformed_archive_dir_rejected(self):
        entry = {'id': 'lean_calculus_tokenizer134_replay', 'source_files': {},
                 'modules': list(replay.TOKENIZE134_MODULES),
                 'theorems': list(replay.TOKENIZE134_THEOREMS),
                 'archive_dir': 'phase5/artifact/archive/calculus-query-guards95'}
        with tempfile.TemporaryDirectory() as td:
            out = replay.replay_lean_tokenizer134(entry, Path(td))
        self.assertFalse(out['passed'])
        self.assertIn('malformed', out.get('reason', ''))

    def test_generic_hash_pin(self):
        self.assertTrue(replay.TOKENIZE134_GENERIC.startswith('5193c045'))
        self.assertTrue(replay.TOKENIZE134_COMPAREMAIN.startswith('6b917746'))
        self.assertTrue(replay.TOKENIZE134_CHUNKS.startswith('ef2baca1'))


    def _full_entry(self):
        man = json.loads((HERE / 'manifest.json').read_text())
        for e in man['entries']:
            if e['id'] == 'lean_calculus_tokenizer134_replay':
                return json.loads(json.dumps(e))
        raise AssertionError('missing tokenizer134 entry')

    def test_wrong_bin_pin_rejected_without_compile(self):
        entry = self._full_entry()
        entry['expected_binaries']['compare-run'] = '0' * 64
        called = []
        with tempfile.TemporaryDirectory() as td, \
             mock.patch.object(replay, 'compile_lean_modules_sequential',
                               side_effect=lambda *a, **k: called.append('compile') or {}) :
            out = replay.replay_lean_tokenizer134(entry, Path(td))
        self.assertFalse(out['passed'])
        self.assertIn('expected_binaries', out.get('reason', ''))
        self.assertEqual(called, [])

    def test_corrupt_data_pin_rejected_without_compile(self):
        entry = self._full_entry()
        bad = dict(entry['data_files'])
        key = 'calculus-correspondence/compare_relay.py'
        bad[key] = '0' * 64
        entry['data_files'] = bad
        called = []
        with tempfile.TemporaryDirectory() as td, \
             mock.patch.object(replay, 'compile_lean_modules_sequential',
                               side_effect=lambda *a, **k: called.append('compile') or {}) :
            out = replay.replay_lean_tokenizer134(entry, Path(td))
        self.assertFalse(out['passed'])
        self.assertTrue('data' in out.get('reason', '').lower() or 'pin' in out.get('reason', '').lower())
        self.assertEqual(called, [])

    def test_on_disk_corrupt_data_rejected_without_compile(self):
        entry = self._full_entry()
        n = {'hv': 0}

        def fake_hv(repo, hashes):
            n['hv'] += 1
            if n['hv'] == 1:
                return True, {k: dict(matches=True) for k in hashes}
            return False, {k: dict(matches=False, error='corrupt') for k in hashes}

        called = []
        with tempfile.TemporaryDirectory() as td, \
             mock.patch.object(replay, 'hash_verify_host', side_effect=fake_hv), \
             mock.patch.object(replay, 'compile_lean_modules_sequential',
                               side_effect=lambda *a, **k: called.append('compile') or {}) :
            out = replay.replay_lean_tokenizer134(entry, Path(td))
        self.assertFalse(out['passed'])
        self.assertIn('archived data identity', out.get('reason', ''))
        self.assertEqual(called, [])
        self.assertEqual(n['hv'], 2)

    def test_unique_compare_module_name(self):
        self.assertTrue(hasattr(replay, '_tokenize134_load_compare'))

    def test_wildcard_names_rejected_in_helper(self):
        self.assertFalse(any('*' in n for n in replay.TOKENIZE134_MODULES))


if __name__ == '__main__':
    unittest.main()
