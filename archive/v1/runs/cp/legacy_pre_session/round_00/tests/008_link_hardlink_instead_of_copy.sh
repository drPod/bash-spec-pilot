#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/source.txt"
dst="$tmpdir/dest.txt"
printf 'hard linked\n' > "$src"
if ! "$UTIL" -l "$src" "$dst"; then echo "hard-link copy failed" >&2; exit 1; fi
if [[ "$(stat -c %i "$src")" == "$(stat -c %i "$dst")" ]]; then exit 0; else echo "destination is not a hard link to source" >&2; exit 1; fi
