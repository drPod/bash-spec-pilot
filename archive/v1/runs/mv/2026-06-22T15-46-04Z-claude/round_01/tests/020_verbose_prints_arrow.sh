#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# -v, --verbose: explain what is being done. Names both src and dst on stdout.
echo data > "$tmpdir/src"
out=$("$UTIL" -v "$tmpdir/src" "$tmpdir/dst")
if [[ "$out" == *"$tmpdir/src"* && "$out" == *"$tmpdir/dst"* ]]; then
  exit 0
fi
echo "-v did not explain the move naming src and dst" >&2
exit 1
