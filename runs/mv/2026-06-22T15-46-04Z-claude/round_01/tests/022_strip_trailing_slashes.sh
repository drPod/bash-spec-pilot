#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# --strip-trailing-slashes: remove any trailing slashes from each SOURCE argument.
# A file SOURCE given with a trailing slash is still moved as a file.
echo data > "$tmpdir/src"
"$UTIL" --strip-trailing-slashes "$tmpdir/src/" "$tmpdir/dst"
if [[ -f "$tmpdir/dst" && ! -e "$tmpdir/src" ]]; then
  exit 0
fi
echo "--strip-trailing-slashes did not strip slash and move the file source" >&2
exit 1
