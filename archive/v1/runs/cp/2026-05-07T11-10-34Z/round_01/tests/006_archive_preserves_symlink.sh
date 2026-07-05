#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
srcdir="$tmpdir/srcdir"
dstdir="$tmpdir/dstdir"
mkdir "$srcdir"
printf 'target\n' > "$srcdir/file.txt"
ln -s "file.txt" "$srcdir/link.txt"
if ! "$UTIL" -a "$srcdir" "$dstdir"; then echo "cp -a failed" >&2; exit 1; fi
if [[ -L "$dstdir/link.txt" ]]; then exit 0; fi
echo "archive copy did not preserve symlink" >&2
exit 1
