#!/usr/bin/env bash
# Invariant: sudo -n true exits 0 when invoker has NOPASSWD privileges.
# Manpage backing: utils/sudo/manpage.txt lines 30-50 (sudo exits with the
# command's exit status); -n added per lines 261-264 to make the
# password-required path fail loudly instead of hang.
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

err="$tmpdir/sudo.err"
set +e
"$UTIL" -n true 2>"$err"
status=$?
set -e

if [ "$status" -ne 0 ]; then
  echo "sudo -n true exited $status; stderr: $(cat "$err")" >&2
  exit 1
fi
