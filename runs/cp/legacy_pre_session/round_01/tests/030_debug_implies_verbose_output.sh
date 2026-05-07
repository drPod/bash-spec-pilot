#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/source.txt"
dst="$tmpdir/dest.txt"
printf 'debug\n' > "$src"
output="$tmpdir/output.txt"
if ! "$UTIL" --debug "$src" "$dst" > "$output"; then echo "debug copy failed" >&2; exit 1; fi
if [[ -s "$output" ]]; then exit 0; else echo "debug mode produced no explanatory output" >&2; exit 1; fi
