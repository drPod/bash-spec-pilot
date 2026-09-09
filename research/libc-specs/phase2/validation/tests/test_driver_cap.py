"""Check inclusive input cap with a 32-byte test configuration, avoiding huge workloads."""
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from relaycheck.runner import Scratch, run_exe

class DriverCapTests(unittest.TestCase):
    def test_small_cap_boundary(self):
        root=Path(__file__).resolve().parents[1]
        with tempfile.TemporaryDirectory() as d:
            d=Path(d)
            commands=[
                ['cc','-std=c11','-U_FORTIFY_SOURCE','-O2','-Wall','-Wextra','-DRELAY_SHIM_MACRO','-DRELAY_MAX_INPUT=32',
                 '-c',str(root/'driver/relay_driver.c'),'-o',str(d/'driver.o')],
                ['cc','-std=c11','-U_FORTIFY_SOURCE','-O2','-Dread=shim_read','-Dwrite=shim_write','-c',str(root.parent/'relay.c'),'-o',str(d/'relay.o')],
                ['cc',str(d/'driver.o'),str(d/'relay.o'),'-o',str(d/'driver')]]
            for cmd in commands:
                cp=subprocess.run(['timeout','--kill-after=1s','10s','prlimit','--as=1073741824:1073741824','--cpu=10:10','--',*cmd],capture_output=True,timeout=12)
                self.assertEqual(cp.returncode,0,cp.stderr)
            scratch=Scratch(d,'cap')
            for n in [0,1,31,32,33,65]:
                data=bytes(range(n))
                r=run_exe([str(d/'driver')],data,scratch,3)
                with self.subTest(n=n):
                    self.assertEqual(r.status,0 if n<=32 else 64,r.stderr)
                    self.assertEqual(r.stdout,data if n<=32 else b'')
                    self.assertFalse(r.timed_out)
