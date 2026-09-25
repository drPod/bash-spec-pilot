import sys
from pathlib import Path
import unittest
import json
import tempfile
from unittest.mock import patch
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'scripts'))
from paired_comparison import metrics, generated_decision


class Comparison(unittest.TestCase):
    def test_abstention_is_not_rejection_and_pending_not_truth(self):
        rows = [dict(local_label=l, judge=d) for l, d in [
            ('passed_local_checks', 'accept'),
            ('failed_local_checks_or_execution', 'uncertain'),
            ('pending', 'reject'), ('unresolved', 'accept'),
            ('missing_processed', 'missing_processed')]]
        result = metrics(rows, 'judge')
        self.assertEqual(result['execution_labeled'], 2)
        self.assertEqual(result['decision_coverage'], .5)
        self.assertEqual(result['agreement_on_decided'], 1)
        self.assertEqual(result['rejected_local_fail'], 0)
        self.assertEqual(result['other_decisions'], {'uncertain': 1})

    def test_empty_denominators_are_not_zero_accuracy(self):
        self.assertIsNone(metrics([], 'judge')['agreement_on_decided'])
        self.assertIsNone(metrics([], 'judge')['decision_coverage'])

    def test_generated_tests_do_not_borrow_independent_oracle_label(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); folder = root / 'experiments/four-task-tests-v1'
            folder.mkdir(parents=True)
            for scenario in ('baseline', 'adversarial'):
                (folder / f'm-p01-0-{scenario}.json').write_text(json.dumps({
                    'status': 'oracle_rejected', 'input_sha256': {'candidate': 'abc'},
                    'generated_test': {'status': 'evaluated', 'passed': True}}))
            with patch('paired_comparison.ROOT', root):
                result = generated_decision({'sample_id': 'm/p01/0', 'task_id': 'a01'},
                                            'abc', {'a01': {'status': 'eligible'}})
            self.assertEqual(result, 'accept')

    def test_faulty_reference_gate_abstains_without_candidate_execution(self):
        result = generated_decision({'sample_id': 'm/p01/0', 'task_id': 'a01'},
                                    'abc', {'a01': {'status': 'reference_control_failed'}})
        self.assertEqual(result, 'test_reference_control_failed')
