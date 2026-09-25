import sys
from pathlib import Path
import unittest
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'scripts'))
from retrieval_fql import retrieve


class Retrieval(unittest.TestCase):
    def test_target_excluded_and_similar_request_ranks_first(self):
        target = {'id': 'target', 'natural_language': 'create a private directory'}
        pool = [target, {'id': 'similar', 'natural_language': 'create directory'},
                {'id': 'distant', 'natural_language': 'disable a user password'}]
        result = retrieve(target, pool)
        self.assertEqual([b['id'] for _, b in result], ['similar', 'distant'])

    def test_ties_are_stable_by_id(self):
        target = {'id': 'target', 'natural_language': 'install package'}
        pool = [{'id': 'b', 'natural_language': 'create directory'},
                {'id': 'a', 'natural_language': 'create directory'}]
        self.assertEqual([b['id'] for _, b in retrieve(target, pool)], ['a', 'b'])
