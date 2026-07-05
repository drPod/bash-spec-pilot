#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
srcdir="$tmpdir/archive_src"
destdir="$tmpdir/archive_dst"
mkdir -p "$srcdir"
printf 'referent\n' > "$srcdir/target.txt"
ln -s "$srcdir/target.txt" "$srcdir/link.txt"
if ! "$UTIL" -a "$srcdir" "$destdir"; then echo "archive copy failed" >&2; exit 1; fi
if [[ -L "$destdir/link.txt" ]]; then exit 0; else echo "archive copy did not preserve symlink" >&2; exit 1; fi
