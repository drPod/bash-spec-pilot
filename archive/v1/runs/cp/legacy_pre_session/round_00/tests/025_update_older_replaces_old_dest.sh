#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/source.txt"
dst="$tmpdir/dest.txt"
printf 'newer source\n' > "$src"
printf 'older dest\n' > "$dst"
touch -t 200001010000.00 "$dst"
touch -t 200101010000.00 "$src"
if ! "$UTIL" --update=older "$src" "$dst"; then echo "update=older invocation failed" >&2; exit 1; fi
if [[ "$(cat "$dst")" == "newer source" ]]; then exit 0; else echo "older destination was not replaced" >&2; exit 1; fi
