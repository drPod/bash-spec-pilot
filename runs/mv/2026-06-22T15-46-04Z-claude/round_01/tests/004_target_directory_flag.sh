#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# -t, --target-directory=DIRECTORY: move all SOURCE arguments into DIRECTORY.
echo a > "$tmpdir/a"
echo b > "$tmpdir/b"
mkdir "$tmpdir/dir"
"$UTIL" -t "$tmpdir/dir" "$tmpdir/a" "$tmpdir/b"
if [[ -f "$tmpdir/dir/a" && -f "$tmpdir/dir/b" && ! -e "$tmpdir/a" && ! -e "$tmpdir/b" ]]; then
  exit 0
fi
echo "-t did not move sources into target directory" >&2
exit 1
