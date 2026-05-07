#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/source.txt"
dst="$tmpdir/dest.txt"
printf 'new\n' > "$src"
printf 'old\n' > "$dst"
if ! printf 'n\n' | "$UTIL" -i "$src" "$dst" >/dev/null 2>&1; then echo "interactive invocation failed" >&2; exit 1; fi
if [[ "$(cat "$dst")" == "old" ]]; then exit 0; else echo "interactive negative answer overwrote destination" >&2; exit 1; fi
