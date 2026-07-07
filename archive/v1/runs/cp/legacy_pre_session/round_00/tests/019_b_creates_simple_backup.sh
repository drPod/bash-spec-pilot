#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/source.txt"
dst="$tmpdir/dest.txt"
printf 'new\n' > "$src"
printf 'old\n' > "$dst"
if ! "$UTIL" -b "$src" "$dst"; then echo "backup copy failed" >&2; exit 1; fi
if [[ "$(cat "$dst~")" == "old" ]]; then exit 0; else echo "simple backup does not contain old destination" >&2; exit 1; fi
