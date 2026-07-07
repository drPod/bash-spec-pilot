#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/input.txt"
out="$tmpdir/target"
printf 'via -t\n' > "$src"
mkdir -p "$out"
if ! "$UTIL" -t "$out" "$src"; then echo "target-directory copy failed" >&2; exit 1; fi
if [[ "$(cat "$out/input.txt")" == "via -t" ]]; then exit 0; else echo "file was not copied to target directory" >&2; exit 1; fi
