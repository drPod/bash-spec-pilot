import json
from pathlib import Path
import sys
import unittest

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'scripts'))
from generated_checks import validate
from validate_expansion import summarize
from llm_pilot import extract,FAMILIES


class CorpusIntegrity(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.rows=[json.loads(l) for l in (ROOT/'data/manifest.jsonl').read_text().splitlines()]

    def test_join_cardinality(self):
        self.assertEqual(len(self.rows),2310)
        self.assertEqual(len({r['sample_id'] for r in self.rows}),2310)
        self.assertEqual(sum('response' not in r['artifacts'] for r in self.rows),72)
        self.assertTrue(all('raw' in r['artifacts'] for r in self.rows))

    def test_old_new_numbering_and_sample_zero(self):
        for r in self.rows:
            if r['legacy_id']=='p17': self.assertEqual(r['task_id'],'a18')
            if r['legacy_id']=='p10': self.assertEqual(r['task_id'],'a17')
            self.assertEqual(r['upstream_response_number'],r['sample_index'] or 10)

    def test_do_not_treat_unknown_tags_as_syntax_errors(self):
        r=next(r for r in self.rows if r['sample_id']=='qwen2.5-coder/p10/7')
        a=r['artifacts']['response']
        self.assertEqual(a['yaml_status'],'load_error')
        self.assertEqual(a['yaml_syntax_status'],'parsed')

    def test_demonstrations_follow_each_arms_declared_exclusions(self):
        for path in (ROOT/'experiments').glob('*/fql-*/*.json'):
            r=json.loads(path.read_text())
            for ident in r['demonstration_ids']:
                self.assertNotEqual(ident,r['task_id'])
                if r.get('pool') in ('original','expanded'):
                    # Declared retrieval arms allow same-family demonstrations.
                    continue
                self.assertNotEqual(FAMILIES[ident],FAMILIES[r['task_id']])
            if r.get('diverse_demos'):
                self.assertEqual(len({FAMILIES[t] for t in r['demonstration_ids']}),len(r['demonstration_ids']))


class HonestMeasurement(unittest.TestCase):
    def test_harness_failures_do_not_kill_mutants(self):
        r=summarize([dict(task_id='a22',scenario='baseline',variant='mutant',status='harness_error')])
        self.assertFalse(r['tasks']['a22']['mutant_killed'])
        self.assertTrue(r['tasks']['a22']['mutant_inconclusive'])

    def test_one_scenario_is_not_validation(self):
        r=summarize([dict(task_id='a22',scenario='baseline',variant='reference',status='passed')])
        self.assertFalse(r['tasks']['a22']['reference_validated'])

    def test_output_extraction_does_not_repair_truncation(self):
        self.assertEqual(extract('```python\nassert True\n```'),'assert True')
        self.assertEqual(extract('```python\nassert Tr'),'```python\nassert Tr')
        self.assertEqual(extract('Here is code:\n```\nx\n```'),'Here is code:\n```\nx\n```')

    def test_empty_or_vacuous_generated_checks_rejected(self):
        for bad in [{'checks':[]},{'checks':[{'kind':'directory','path':'/work','scenario':'baseline'}]}]:
            with self.assertRaises(ValueError): validate(bad)

    def test_unknown_check_fields_rejected(self):
        with self.assertRaises(ValueError): validate({'checks':[{'kind':'running','name':'cron','value':'true'}]})
        with self.assertRaises(ValueError): validate({'checks':[{'kind':'directory','path':'/work','expected':True}]})

    def test_two_scenario_checks_allowed(self):
        x={'checks':[{'kind':'content','path':'/work/x','value':v,'scenario':s}
                     for s,v in [('baseline','new'),('adversarial','old')]]}
        self.assertEqual(validate(x),x)


if __name__=='__main__': unittest.main()
