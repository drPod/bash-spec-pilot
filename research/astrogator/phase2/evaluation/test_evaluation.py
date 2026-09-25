#!/usr/bin/env python3
"""Targeted checks for methodological mistakes, not snapshots of output counts."""
import json
import unittest
from unittest.mock import patch
import yaml
from analyze import stats
from duplicates import canonical
from frontier_comparison import prediction
from revised_case import observe, password_matches, HASH
from summarize_revised import label


class EvaluationTests(unittest.TestCase):
    def test_unresolved_label_cannot_be_scored_as_failure(self):
        with self.assertRaises(ValueError):stats([{'local_label':'unresolved','m':'reject'}],'m')

    def test_abstention_is_not_failure_detection(self):
        rows=[{'local_label':'failed_local_checks_or_execution','m':'unsupported'},
              {'local_label':'passed_local_checks','m':'accept'}]
        s=stats(rows,'m')
        self.assertEqual(s['failure_detection_recall'],0)
        self.assertEqual(s['failure_abstention_rate'],1)
        self.assertEqual(s['failures_blocked_if_abstentions_block'],1)
        self.assertEqual(s['coverage'],.5)

    def test_empty_acceptance_risk_is_undefined(self):
        s=stats([{'local_label':'failed_local_checks_or_execution','m':'reject'}],'m')
        self.assertIsNone(s['accepted_failure_risk'])

    def test_canonicalization_keeps_module_name(self):
        a=yaml.compose('- name: Model A\n  tasks:\n  - user:\n      name: alice\n')
        b=yaml.compose('- name: Model B\n  tasks:\n  - user:\n      name: alice\n')
        c=yaml.compose('- name: Model A\n  tasks:\n  - user:\n      name: bob\n')
        self.assertEqual(canonical(a,True),canonical(b,True))
        self.assertNotEqual(canonical(a,True),canonical(c,True))

    def test_canonicalization_preserves_custom_tags_and_duplicate_keys(self):
        self.assertNotEqual(canonical(yaml.compose('x: !secret hi')),canonical(yaml.compose('x: hi')))
        self.assertNotEqual(canonical(yaml.compose('x: 1\nx: 2')),canonical(yaml.compose('x: 2')))
        self.assertNotEqual(canonical(yaml.compose('x: 1\nx: 2')),canonical(yaml.compose('x: 2\nx: 1')))

    def test_tool_use_invalidates_prediction(self):
        self.assertEqual(prediction({'status':'ok','tool_use_detected':True,
                                     'extracted':json.dumps({'verdict':'accept','reason':'x'})}),'tool_use_invalid')

    def test_failed_call_is_abstention_even_with_valid_json(self):
        self.assertEqual(prediction({'status':'transport_error',
                                     'extracted':json.dumps({'verdict':'accept','reason':'x'})}),'transport_error')

    def test_unresolved_execution_is_not_rejection(self):
        self.assertEqual(label([{'status':'execution_timeout'},{'status':'observed'}],'old_oracle'),'unresolved')

    def test_execution_failure_cannot_be_saved_by_poststate(self):
        self.assertEqual(label([{'status':'execution_error','after':{'old_oracle':True}},
                                {'status':'observed','after':{'old_oracle':True}}],'old_oracle'),
                         'failed_local_checks_or_execution')

    def test_real_hash_matches_fixture_password(self):
        self.assertTrue(password_matches(HASH))
        self.assertFalse(password_matches('!'+HASH))

    def test_malformed_shadow_cannot_pass_strict_integrity(self):
        class FakePath:
            def __init__(self,path):self.path=path
            def read_text(self):
                return 'service:!:1:0:99999:7::::\n' if self.path=='/etc/shadow' else 'service:x:1000:1000::/home/service:/bin/sh\n'
        with patch('revised_case.Path',FakePath),patch('revised_case.pwd.getpwnam',return_value=True):
            r=observe('a17','baseline')
        self.assertTrue(r['old_oracle'])
        self.assertFalse(r['strict_oracle'])

    def test_duplicate_shadow_records_cannot_pass_strict_integrity(self):
        class FakePath:
            def __init__(self,path):self.path=path
            def read_text(self):
                return 'service:!:1:0:99999:7:::\n'*2 if self.path=='/etc/shadow' else 'service:x:1000:1000::/home/service:/bin/sh\n'
        with patch('revised_case.Path',FakePath),patch('revised_case.pwd.getpwnam',return_value=True):
            r=observe('a17','baseline')
        self.assertTrue(r['old_oracle'])
        self.assertFalse(r['strict_oracle'])


if __name__=='__main__':unittest.main(verbosity=2)
