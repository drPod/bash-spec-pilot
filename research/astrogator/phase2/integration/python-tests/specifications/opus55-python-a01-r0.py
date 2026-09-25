#!/usr/bin/env python3
import os
import stat
import sys
import unittest

TARGET = "/srv/www"
KEEP = os.path.join(TARGET, "keep")
SCENARIO = os.environ.get("ASTRO_SCENARIO", "baseline").strip().lower()


class TestCreateSrvWww(unittest.TestCase):
    def test_target_is_directory(self):
        self.assertTrue(os.path.lexists(TARGET), f"{TARGET} does not exist")
        st = os.lstat(TARGET)
        self.assertFalse(stat.S_ISLNK(st.st_mode), f"{TARGET} is a symlink, expected a directory")
        self.assertTrue(stat.S_ISDIR(st.st_mode), f"{TARGET} is not a directory")

    def test_parent_is_directory(self):
        st = os.stat("/srv")
        self.assertTrue(stat.S_ISDIR(st.st_mode), "/srv is not a directory")

    def test_existing_content_preserved(self):
        if SCENARIO != "adversarial":
            self.skipTest("only applies to adversarial scenario")
        self.assertTrue(os.path.lexists(KEEP), f"pre-existing file {KEEP} was removed")
        st = os.lstat(KEEP)
        self.assertTrue(stat.S_ISREG(st.st_mode), f"{KEEP} is no longer a regular file")


if __name__ == "__main__":
    result = unittest.main(exit=False, verbosity=2).result
    sys.exit(0 if result.wasSuccessful() else 1)
