import os
import stat
import sys
import unittest

TARGET = "/srv/www"
KEEP = os.path.join(TARGET, "keep")
SCENARIO = os.environ.get("ASTRO_SCENARIO", "baseline").strip().lower()


class TestSrvWwwDirectory(unittest.TestCase):
    def test_target_exists(self):
        self.assertTrue(os.path.lexists(TARGET), f"{TARGET} does not exist")

    def test_target_is_real_directory(self):
        st = os.lstat(TARGET)
        self.assertTrue(
            stat.S_ISDIR(st.st_mode),
            f"{TARGET} is not a directory (mode={oct(st.st_mode)})",
        )
        self.assertFalse(stat.S_ISLNK(st.st_mode), f"{TARGET} is a symlink")

    def test_parent_is_directory(self):
        st = os.lstat("/srv")
        self.assertTrue(stat.S_ISDIR(st.st_mode), "/srv is not a directory")

    def test_target_accessible(self):
        # The directory must be traversable/listable by root.
        os.listdir(TARGET)

    @unittest.skipUnless(SCENARIO == "adversarial", "adversarial-only check")
    def test_existing_file_preserved(self):
        self.assertTrue(
            os.path.lexists(KEEP),
            f"pre-existing file {KEEP} was removed",
        )
        st = os.lstat(KEEP)
        self.assertTrue(
            stat.S_ISREG(st.st_mode),
            f"{KEEP} is no longer a regular file (mode={oct(st.st_mode)})",
        )


if __name__ == "__main__":
    if SCENARIO not in ("baseline", "adversarial"):
        print(f"Unknown ASTRO_SCENARIO: {SCENARIO!r}", file=sys.stderr)
        sys.exit(2)
    result = unittest.main(argv=[sys.argv[0]], exit=False, verbosity=2).result
    sys.exit(0 if result.wasSuccessful() else 1)
