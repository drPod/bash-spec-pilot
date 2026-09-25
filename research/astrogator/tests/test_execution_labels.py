import sys
from pathlib import Path
import unittest

sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'scripts'))
from corpus_ground_truth import summarize


class Labels(unittest.TestCase):
    def setUp(self):
        self.config={'raw_attempts':2,'processed_samples':1,'samples':[
            {'sample_id':'m/p01/0','task_id':'a01','response':{'path':'x'}},
            {'sample_id':'m/p01/1','task_id':'a01','response':None}]}

    def rows(self,a,b):
        return {('m/p01/0',s):{'status':v} for s,v in [('baseline',a),('adversarial',b)]}

    def test_timeout_not_incorrect(self):
        r=summarize(self.config,self.rows('passed','execution_timeout'))
        self.assertEqual(r['counts'],{'unresolved':1,'missing_processed':1})

    def test_infrastructure_error_dominates_semantic_failure(self):
        r=summarize(self.config,self.rows('oracle_rejected','harness_error'))
        self.assertEqual(r['samples'][0]['local_label'],'unresolved')

    def test_one_bad_scenario_fails_local_label(self):
        r=summarize(self.config,self.rows('passed','oracle_rejected'))
        self.assertEqual(r['samples'][0]['local_label'],'failed_local_checks_or_execution')

    def test_missing_scenario_is_pending(self):
        r=summarize(self.config,{('m/p01/0','baseline'):{'status':'passed'}})
        self.assertFalse(r['complete'])
        self.assertEqual(r['samples'][0]['local_label'],'pending')


if __name__=='__main__': unittest.main()
