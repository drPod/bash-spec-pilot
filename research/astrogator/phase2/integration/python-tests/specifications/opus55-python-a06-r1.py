#!/usr/bin/env python3
import os
import stat
import sys
import unittest

PATH = "/etc/file.txt"
SCENARIO = os.environ.get("ASTRO_SCENARIO", "baseline").strip().lower()
EXPECTED_VARIANTS = (b"beginning", b"beginning\n")


def read_bytes(path):
    with open(path, "rb") as fh:
        return fh.read()


class TestFileCreation(unittest.TestCase):
    def test_file_exists_and_is_regular(self):
        self.assertTrue(os.path.lexists(PATH), "%s does not exist" % PATH)
        st = os.stat(PATH)
        self.assertTrue(stat.S_ISREG(st.st_mode),
                        "%s is not a regular file" % PATH)

    def test_contents(self):
        self.assertTrue(os.path.exists(PATH), "%s does not exist" % PATH)
        data = read_bytes(PATH)
        if SCENARIO == "adversarial":
            # The file already existed with other content; it must not
            # have been overwritten with the default contents.
            self.assertNotIn(
                data, EXPECTED_VARIANTS,
                "pre-existing %s was overwritten with 'beginning'" % PATH)
        else:
            self.assertIn(
                data, EXPECTED_VARIANTS,
                "%s has unexpected contents: %r" % (PATH, data))


if __name__ == "__main__":
    result = unittest.main(exit=False, verbosity=2).result
    sys.exit(0 if result.wasSuccessful() else 1)
