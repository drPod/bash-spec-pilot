#!/usr/bin/env python3
import os
import stat
import sys
import unittest
from pathlib import Path

TARGET = Path("/home/mydata/web")
SCENARIO = os.environ.get("ASTRO_SCENARIO", "baseline").strip().lower()


class TestWebDirectoryDeleted(unittest.TestCase):
    def test_target_does_not_exist(self):
        # lexists also catches dangling symlinks left at the path
        self.assertFalse(
            os.path.lexists(str(TARGET)),
            f"{TARGET} still exists (scenario={SCENARIO})",
        )

    def test_target_not_any_filesystem_object(self):
        try:
            st = os.lstat(str(TARGET))
        except FileNotFoundError:
            return
        except NotADirectoryError:
            # A parent component is not a directory, so the target cannot exist
            return
        kind = "directory" if stat.S_ISDIR(st.st_mode) else (
            "symlink" if stat.S_ISLNK(st.st_mode) else "other file type"
        )
        self.fail(f"{TARGET} is still present as a {kind} (scenario={SCENARIO})")

    def test_no_contents_remain(self):
        # Nested and hidden files must not survive anywhere under the target
        if not os.path.isdir(str(TARGET)):
            return
        remaining = []
        for root, dirs, files in os.walk(str(TARGET)):
            for name in dirs + files:
                remaining.append(os.path.join(root, name))
        self.fail(
            f"{TARGET} still exists with {len(remaining)} entries remaining: "
            f"{remaining[:10]} (scenario={SCENARIO})"
        )


if __name__ == "__main__":
    result = unittest.main(exit=False, verbosity=2).result
    sys.exit(0 if result.wasSuccessful() else 1)
