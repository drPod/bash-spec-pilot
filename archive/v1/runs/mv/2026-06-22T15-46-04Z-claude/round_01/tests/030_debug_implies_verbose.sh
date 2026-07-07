#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# --debug: explain how a file is copied. Implies -v, so it names src and dst.
echo data > "$tmpdir/src"
out=$("$UTIL" --debug "$tmpdir/src" "$tmpdir/dst")
if [[ "$out" == *"$tmpdir/src"* && "$out" == *"$tmpdir/dst"* && -f "$tmpdir/dst" ]]; then
  exit 0
fi
echo "--debug did not imply -v output naming src and dst" >&2
exit 1
