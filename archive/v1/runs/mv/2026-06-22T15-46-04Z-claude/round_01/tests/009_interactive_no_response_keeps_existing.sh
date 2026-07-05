#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# -i, --interactive: prompt before overwrite. With empty (no) answer on stdin,
# the existing destination is not overwritten.
echo new > "$tmpdir/src"
echo old > "$tmpdir/dst"
set +e
"$UTIL" -i "$tmpdir/src" "$tmpdir/dst" < /dev/null
set -e
if [[ "$(cat "$tmpdir/dst")" == old ]]; then
  exit 0
fi
echo "-i overwrote destination despite no affirmative prompt answer" >&2
exit 1
