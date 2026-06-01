#!/usr/bin/env bash
# Metamorphic invariant: within-device move preserves file permissions.
# Backed by manpage SEE ALSO line: "rename(2)" — rename(2) preserves the
# inode, therefore mode bits survive. The manpage describes mv as
# "rename"; a rename that silently re-modes its target violates that.
set -euo pipefail

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src"
dst="$tmpdir/dst"

printf 'x\n' > "$src"
# Pick a non-default mode unlikely to coincide with umask defaults.
chmod 0640 "$src"
expected_mode=$(stat -c '%a' "$src")

"$UTIL" "$src" "$dst"

if [[ ! -f "$dst" ]]; then
  echo "FAIL: destination $dst missing after mv" >&2
  exit 1
fi
actual_mode=$(stat -c '%a' "$dst")
if [[ "$actual_mode" != "$expected_mode" ]]; then
  echo "FAIL: mode changed across mv (expected $expected_mode, got $actual_mode)" >&2
  exit 1
fi
