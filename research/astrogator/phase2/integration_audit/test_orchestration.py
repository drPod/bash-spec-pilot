import errno
from pathlib import Path
import subprocess
import sys
import unittest
from unittest.mock import patch
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'integration'))
import orchestration as o

def result(text):return subprocess.CompletedProcess([],0,text,'')

class Tests(unittest.TestCase):
    def test_resource_exhaustion_retries_fork_only(self):
        with patch.object(o.subprocess,'run',side_effect=[BlockingIOError(errno.EAGAIN,'busy'),result('done')]) as call, patch.object(o.time,'sleep'):
            self.assertEqual(o.run(['x']).stdout,'done');self.assertEqual(call.call_count,2)
    def test_failed_dependency_is_not_completion(self):
        with patch.object(o,'run',return_value=result('LoadState=loaded\nActiveState=failed\nResult=exit-code\nExecMainCode=1\nExecMainStatus=1\n')):
            with self.assertRaises(RuntimeError):o.wait_success('unit')
    def test_collected_success_needs_journal_evidence(self):
        with patch.object(o,'run',side_effect=[result('LoadState=not-found\nActiveState=inactive\n'),result('{"MESSAGE":"unit: Deactivated successfully."}\n')]):o.wait_success('unit')
    def test_collected_failure_not_older_success(self):
        with patch.object(o,'run',side_effect=[result('LoadState=not-found\n'),result('{"MESSAGE":"unit: Deactivated successfully."}\n{"MESSAGE":"Started unit"}\n{"MESSAGE":"unit: Failed with result exit-code"}\n')]):
            with self.assertRaises(RuntimeError):o.wait_success('unit')
    def test_consumed_record_alone_not_success(self):
        with patch.object(o,'run',side_effect=[result('LoadState=not-found\n'),result('{"MESSAGE":"Started unit"}\n{"MESSAGE":"unit: Consumed 1s CPU time."}\n')]), patch.object(o,'artifacts_complete',return_value=False):
            with self.assertRaises(RuntimeError):o.wait_success('unit')
    def test_consumed_plus_validated_artifacts(self):
        with patch.object(o,'run',side_effect=[result('LoadState=not-found\n'),result('{"MESSAGE":"Started unit"}\n{"MESSAGE":"unit: Consumed 1s CPU time."}\n')]), patch.object(o,'artifacts_complete',return_value=True):o.wait_success('unit')
    def test_loaded_success_requires_exited_zero(self):
        with patch.object(o,'run',return_value=result('LoadState=loaded\nActiveState=inactive\nResult=success\nExecMainCode=1\nExecMainStatus=0\nExecMainStartTimestampMonotonic=12\n')):o.wait_success('unit')
if __name__=='__main__':unittest.main()
