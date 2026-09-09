"""Negative regressions for known proof/executable substitution paths."""
import unittest

from check import FORBIDDEN


class GuardTests(unittest.TestCase):
    def test_implementation_substitution_forms(self):
        sources = [
            '@[implemented_by impl] def run := 999',
            '@[inline, implemented_by impl] def run := 999',
            '@[inline, /- spacing -/ implemented_by impl] def run := 999',
            'attribute [implemented_by impl] run',
            '@[inline, implemented_by impl] def helper := 999\ndef run := helper',
            '@[inline, extern "different_function"] def helper := 999',
            'attribute [extern "different_function"] helper',
        ]
        for source in sources:
            with self.subTest(source=source):
                self.assertIsNotNone(FORBIDDEN.search(source))

    def test_ordinary_definitions_remain_allowed(self):
        self.assertIsNone(FORBIDDEN.search(
            'namespace Pipeline.Generated\n'
            'def run (_a s : List String) : List String × UInt32 := '
            '([toString s.length], 0)\n'
            'theorem output (a s) : (run a s).1 = [toString s.length] := rfl\n'
            'end Pipeline.Generated'))


if __name__ == '__main__':
    unittest.main()
