#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/source.txt"
dst="$tmpdir/dest.txt"
alias="$tmpdir/alias.txt"
printf 'new data\n' > "$src"
printf 'old data\n' > "$dst"
ln "$dst" "$alias"
if ! "$UTIL" --remove-destination "$src" "$dst"; then echo "remove-destination copy failed" >&2; exit 1; fi
if [[ "$(cat "$alias")" == "old data" ]]; then exit 0; else echo "existing destination was overwritten rather than removed first" >&2; exit 1; fi
