#!/usr/bin/env python3
"""Post-execution test: the password for the `service` user is disabled.

Final state required in both scenarios (baseline: previously unlocked hash;
adversarial: already locked hash):
  * the `service` account still exists;
  * its shadow password field cannot authenticate any password, i.e. it is
    non-empty and begins with '!' or '*' (locked / disabled marker).
An empty field would mean password-less login, which is not "disabled".
"""

import os
import pwd
import subprocess
import sys
import unittest
from pathlib import Path

USER = "service"
SCENARIO = os.environ.get("ASTRO_SCENARIO", "baseline")


def shadow_entry(name):
    """Return the shadow fields for `name`, or None if absent."""
    path = Path("/etc/shadow")
    if path.exists():
        for line in path.read_text(errors="replace").splitlines():
            if not line or line.startswith("#"):
                continue
            fields = line.split(":")
            if fields[0] == name:
                return fields
    # Fallback via NSS (e.g. non-files shadow backend).
    try:
        out = subprocess.run(
            ["getent", "shadow", name],
            capture_output=True,
            text=True,
            check=False,
        )
    except OSError:
        return None
    if out.returncode == 0 and out.stdout.strip():
        return out.stdout.strip().splitlines()[0].split(":")
    return None


class TestServicePasswordDisabled(unittest.TestCase):
    def test_user_still_exists(self):
        try:
            pwd.getpwnam(USER)
        except KeyError:
            self.fail(f"user {USER!r} no longer exists ({SCENARIO})")

    def test_password_field_disabled(self):
        fields = shadow_entry(USER)
        self.assertIsNotNone(fields, f"no shadow entry for {USER!r} ({SCENARIO})")
        self.assertGreaterEqual(len(fields), 2, "malformed shadow entry")
        hash_field = fields[1]
        self.assertNotEqual(
            hash_field,
            "",
            f"{USER!r} has an empty password field (password-less login), "
            f"not a disabled password ({SCENARIO})",
        )
        self.assertTrue(
            hash_field[0] in ("!", "*"),
            f"{USER!r} password field does not start with '!' or '*'; "
            f"password is still usable ({SCENARIO})",
        )


if __name__ == "__main__":
    result = unittest.main(exit=False, verbosity=2).result
    sys.exit(0 if result.wasSuccessful() else 1)
