#!/usr/bin/env bash
# Invariant: without -E (and absent env_keep / env_check entry), an
# arbitrary parent env var SUDO_TEST_VAR is scrubbed from the child env.
# Manpage backing: utils/sudo/manpage.txt lines 100-104 contrast (-E exists
# precisely because the default behavior scrubs unlisted vars); reinforced
# by lines 553-575 enumerating which named vars get preserved by default.
# SUDO_TEST_VAR is not in that list.
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

export SUDO_TEST_VAR="scrub_me_$$"
out="$tmpdir/env.out"
err="$tmpdir/env.err"

if ! "$UTIL" -n env >"$out" 2>"$err"; then
  echo "sudo -n env failed: $(cat "$err")" >&2
  exit 1
fi

if grep -qx "SUDO_TEST_VAR=$SUDO_TEST_VAR" "$out"; then
  echo "expected SUDO_TEST_VAR scrubbed without -E, but it leaked through" >&2
  exit 1
fi
