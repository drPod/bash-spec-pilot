#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
srcdir="$tmpdir/srcdir"
destdir="$tmpdir/destdir"
mkdir -p "$srcdir/sub"
printf 'nested\n' > "$srcdir/sub/file.txt"
if ! "$UTIL" -R -x "$srcdir" "$destdir"; then echo "recursive copy failed" >&2; exit 1; fi
if [[ "$(cat "$destdir/sub/file.txt")" == "nested" ]]; then exit 0; else echo "recursive copy did not copy nested file" >&2; exit 1; fi
