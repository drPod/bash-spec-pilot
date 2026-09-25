#!/usr/bin/env python3
import os
import stat
import sys
import unittest

TARGET = "/home/mydata/web"
PARENT = "/home/mydata"
SCENARIO = os.environ.get("ASTRO_SCENARIO", "baseline").strip().lower()


class TestDirectoryDeleted(unittest.TestCase):
    def test_target_absent(self):
        # lexists also catches a dangling or replacement symlink at the path
        self.assertFalse(
            os.path.lexists(TARGET),
            f"{TARGET} still exists (or was replaced by another filesystem object)",
        )

    def test_target_not_replaced_by_any_entry(self):
        try:
            st = os.lstat(TARGET)
        except FileNotFoundError:
            return
        self.fail(f"{TARGET} exists with mode {stat.filemode(st.st_mode)}")

    def test_no_leftover_children_listed_in_parent(self):
        if not os.path.isdir(PARENT):
            return
        entries = os.listdir(PARENT)
        self.assertNotIn(
            "web", entries, f"'web' entry still present in {PARENT}: {entries}"
        )

    @unittest.skipUnless(SCENARIO == "adversarial", "adversarial scenario only")
    def test_parent_preserved_in_adversarial(self):
        # The target existed inside /home/mydata; only the target itself should be removed
        self.assertTrue(
            os.path.isdir(PARENT),
            f"{PARENT} should still exist; only {TARGET} was to be deleted",
        )


if __name__ == "__main__":
    result = unittest.main(exit=False, verbosity=2).result
    sys.exit(0 if result.wasSuccessful() else 1)
