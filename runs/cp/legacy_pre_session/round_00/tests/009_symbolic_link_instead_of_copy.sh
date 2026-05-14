#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/source.txt"
dst="$tmpdir/dest_link"
printf 'symlinked\n' > "$src"
if ! "$UTIL" -s "$src" "$dst"; then echo "symbolic-link copy failed" >&2; exit 1; fi
if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then exit 0; else echo "destination is not the expected symbolic link" >&2; exit 1; fi
