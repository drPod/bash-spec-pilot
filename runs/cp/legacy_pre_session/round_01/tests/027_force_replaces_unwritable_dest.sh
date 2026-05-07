#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/source.txt"
dst="$tmpdir/dest.txt"
printf 'forced new\n' > "$src"
printf 'forced old\n' > "$dst"
chmod 000 "$dst"
if ! "$UTIL" -f "$src" "$dst"; then echo "force copy failed" >&2; exit 1; fi
if [[ "$(cat "$dst")" == "forced new" ]]; then exit 0; else echo "force did not replace destination content" >&2; exit 1; fi
