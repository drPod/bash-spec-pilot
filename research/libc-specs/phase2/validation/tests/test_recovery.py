"""Regressions for the actual interrupted harness and independent manual vectors."""
import json
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from relaycheck.runner import Scratch, read_capture, run_exe
from relaycheck.oracle import run_relay

class RecoveryTests(unittest.TestCase):
    def test_external_sink_is_never_read(self):
        with tempfile.TemporaryDirectory() as d:
            scratch = Scratch(Path(d), 'sink')
            original = read_capture
            def checked(p, *args):
                self.assertEqual(p, scratch.stderr)
                return original(p, *args)
            with patch('relaycheck.runner.read_capture', side_effect=checked):
                r = run_exe(['/usr/bin/printf', 'x'], b'', scratch, 2, stdout_path='/dev/full')
            self.assertNotEqual(r.status, 0)
            self.assertIn(b"No space left", r.stderr)
            self.assertEqual(r.stdout, b'')
            self.assertFalse(r.timed_out)

    def test_capture_rejects_character_device_before_read(self):
        with self.assertRaisesRegex(ValueError, 'regular file'):
            read_capture(Path('/dev/full'))

    def test_capture_size_limit(self):
        with tempfile.TemporaryDirectory() as d:
            p=Path(d)/'out';p.write_bytes(b'abcd')
            with self.assertRaises(ValueError):
                read_capture(p, 3)
            self.assertEqual(read_capture(p, 4), b'abcd')

    def test_child_address_space_is_bounded(self):
        with tempfile.TemporaryDirectory() as d:
            r=run_exe([sys.executable, '-c', 'x=bytearray(3*1024**3)'], b'', Scratch(Path(d),'mem'), 3)
            self.assertNotEqual(r.status, 0)
            self.assertIn(b'MemoryError', r.stderr)
            self.assertFalse(r.timed_out)

    def test_child_timeout(self):
        with tempfile.TemporaryDirectory() as d:
            r=run_exe([sys.executable, '-c', 'while True: pass'], b'', Scratch(Path(d),'time'), .1)
            self.assertTrue(r.timed_out)
            self.assertLess(r.status, 0)

    def test_independent_hand_calculations(self):
        vectors=json.loads((Path(__file__).resolve().parents[1]/'independent_vectors.json').read_text())
        self.assertEqual(len(vectors),14)
        for v in vectors:
            with self.subTest(v=v['name']):
                o=run_relay(bytes.fromhex(v['input_hex']),v['reads'],v['writes'])
                self.assertEqual(dict(output_hex=o.output.hex(),status=o.status,consumed=o.consumed,
                                      read_calls=o.read_calls,write_calls=o.write_calls),v['expected'])
