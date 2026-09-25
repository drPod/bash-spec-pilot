import unittest
from summarize_tests import label, verdict

def case(status='observed',passed=True,oracle=True):
    return {'task_id':'a01','status':status,'original_oracle':oracle,
            'generated_tests':{'test':{'status':'evaluated','passed':passed}}}

class MethodologyTests(unittest.TestCase):
    def test_never_borrow_oracle_for_test_prediction(self):
        cs=[case(oracle=False),case(oracle=False)]
        self.assertEqual(label(cs,'strict_integrity'),'failed_local_checks_or_execution')
        self.assertEqual(verdict(cs,'test',{'eligible':True}),'accept')
    def test_test_rejection_is_not_oracle_failure(self):
        cs=[case(passed=False),case()]
        self.assertEqual(label(cs,'strict_integrity'),'passed_local_checks')
        self.assertEqual(verdict(cs,'test',{'eligible':True}),'reject')
    def test_gate_abstention(self):
        self.assertEqual(verdict([case(),case()],'test',{'eligible':False}),'reference_gate_abstention')
    def test_missing_state_unresolved(self):
        self.assertEqual(label([case()],'strict_integrity'),'unresolved')
        self.assertEqual(verdict([case()],'test',{'eligible':True}),'execution_unavailable')
    def test_timeout_not_rejection_even_when_other_fails(self):
        cs=[case(status='execution_timeout'),case(status='execution_error')]
        self.assertEqual(label(cs,'strict_integrity'),'unresolved')
        self.assertEqual(verdict(cs,'test',{'eligible':True}),'execution_unavailable')
    def test_execution_failure_policy_explicit(self):
        self.assertEqual(verdict([case(status='execution_error'),case()],'test',{'eligible':True}),'reject')
    def test_invalid_test_abstains(self):
        c=case();c['generated_tests']['test']['status']='invalid'
        self.assertEqual(verdict([c,case()],'test',{'eligible':True}),'test_unavailable')
    def test_password_structural_integrity_separate(self):
        cs=[dict(case(),task_id='a17',observations={'strict_oracle':False}) for _ in range(2)]
        self.assertEqual(label(cs,'new_fixture_original_oracle'),'passed_local_checks')
        self.assertEqual(label(cs,'strict_integrity'),'failed_local_checks_or_execution')

if __name__=='__main__': unittest.main()
