"""Rejected source must never compile/report a stale generated binding."""
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
from frontend import Rejected
import run_checks


class ReplayGuardTests(unittest.TestCase):
    def test_rejected_source_aborts_before_building_existing_cache(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / 'bad.c'
            source.write_text((run_checks.ROOT / 'relay.c').read_text().replace('return 2;', 'return 0;'))
            work = root / 'cache/lean'
            work.mkdir(parents=True)
            previous = work / 'GeneratedRelay.lean'
            previous.write_text('previous successful generated binding')
            with patch('sys.argv', ['run_checks.py', '--source', str(source), '--cache', str(root/'cache')]), \
                 patch('run_checks.subprocess.run') as compiler, \
                 patch('run_checks.subprocess.check_output') as probe:
                with self.assertRaises(Rejected):
                    run_checks.main()
                compiler.assert_not_called()
                probe.assert_not_called()
            self.assertEqual(previous.read_text(), 'previous successful generated binding')
            self.assertFalse((root/'cache/check_result.json').exists())


if __name__ == '__main__':
    unittest.main()
