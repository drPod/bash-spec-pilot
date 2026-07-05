#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/source.txt"
dst="$tmpdir/dest.txt"
printf 'hello world\n' > "$src"
if ! "$UTIL" "$src" "$dst"; then echo "copy command failed" >&2; exit 1; fi
if [[ "$(cat "$dst")" == "hello world" ]]; then exit 0; else echo "destination content mismatch" >&2; exit 1; fi
