#!/usr/bin/env python3
"""Post-execution test: the password for the `service` user must be disabled.

Disabled means the shadow password field cannot match any password: it is
non-empty and starts with '!' or '*' (for example '!', '*', '!!', or a
'!'-locked hash). An empty field is NOT disabled, because it can allow
passwordless login.

baseline:    the user started with an unlocked hash, which must now be disabled.
adversarial: the user started with a locked hash, which must still be disabled.
In both scenarios the user must still exist.
"""
import os
import pwd
import subprocess
import sys
import unittest

USER = "service"
SCENARIO = os.environ.get("ASTRO_SCENARIO", "baseline")


def password_disabled(field):
    return bool(field) and field[0] in ("!", "*")


def shadow_entries(name):
    entries = []
    with open("/etc/shadow", "r", encoding="utf-8", errors="replace") as fh:
        for line in fh:
            line = line.rstrip("\n")
            if not line or line.startswith("#"):
                continue
            parts = line.split(":")
            if parts[0] == name:
                entries.append(parts)
    return entries


class TestServicePasswordDisabled(unittest.TestCase):
    def test_scenario_known(self):
        self.assertIn(SCENARIO, ("baseline", "adversarial"),
                      "unexpected ASTRO_SCENARIO=%r" % SCENARIO)

    def test_user_still_exists(self):
        try:
            pw = pwd.getpwnam(USER)
        except KeyError:
            self.fail("user %r no longer exists" % USER)
        self.assertEqual(pw.pw_name, USER)

    def test_passwd_field_not_a_usable_hash(self):
        try:
            pw = pwd.getpwnam(USER)
        except KeyError:
            self.fail("user %r no longer exists" % USER)
        field = pw.pw_passwd
        self.assertTrue(
            field == "x" or password_disabled(field),
            "/etc/passwd password field for %r is neither 'x' nor disabled: %r"
            % (USER, field),
        )

    def test_shadow_password_disabled(self):
        entries = shadow_entries(USER)
        self.assertTrue(entries, "no /etc/shadow entry for %r" % USER)
        for parts in entries:
            self.assertGreaterEqual(len(parts), 2,
                                    "malformed shadow entry for %r" % USER)
            field = parts[1]
            self.assertTrue(
                password_disabled(field),
                "shadow password field for %r is not disabled "
                "(must be non-empty and start with '!' or '*'): %r"
                % (USER, field),
            )

    def test_getent_shadow_agrees(self):
        res = subprocess.run(["getent", "shadow", USER],
                             stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                             universal_newlines=True)
        self.assertEqual(res.returncode, 0,
                         "getent shadow %s failed: %s" % (USER, res.stderr))
        lines = [l for l in res.stdout.splitlines() if l.strip()]
        self.assertTrue(lines, "getent shadow returned nothing for %r" % USER)
        for line in lines:
            parts = line.split(":")
            self.assertEqual(parts[0], USER)
            self.assertGreaterEqual(len(parts), 2)
            self.assertTrue(
                password_disabled(parts[1]),
                "getent shadow reports a usable or empty password for %r: %r"
                % (USER, parts[1]),
            )


if __name__ == "__main__":
    result = unittest.main(exit=False, verbosity=2).result
    sys.exit(0 if result.wasSuccessful() else 1)
