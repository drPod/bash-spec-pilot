#!/usr/bin/env bash
# Invariant: sudo -E preserves an arbitrary parent env var into the child.
# Manpage backing: utils/sudo/manpage.txt lines 100-104 (`-E,
# --preserve-env` — user wishes to preserve their existing environment
# variables).
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

export SUDO_TEST_VAR="preserve_me_$$"
out="$tmpdir/env.out"
err="$tmpdir/env.err"

if ! "$UTIL" -n -E env >"$out" 2>"$err"; then
  echo "sudo -n -E env failed: $(cat "$err")" >&2
  # -E is policy-gated; the most common harness misconfiguration is a sudoers
  # rule without SETENV. Surface the fix instead of a bare failure.
  if grep -qi "not allowed to preserve the environment" "$err"; then
    echo "hint: grant SETENV (e.g. 'tester ALL=(ALL) NOPASSWD: SETENV: ALL') so -E is permitted" >&2
  fi
  exit 1
fi

if ! grep -qx "SUDO_TEST_VAR=$SUDO_TEST_VAR" "$out"; then
  echo "expected SUDO_TEST_VAR preserved under -E, not found in child env" >&2
  exit 1
fi
