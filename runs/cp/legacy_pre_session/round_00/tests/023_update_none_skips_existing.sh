#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/source.txt"
dst="$tmpdir/dest.txt"
printf 'new\n' > "$src"
printf 'old\n' > "$dst"
if ! "$UTIL" --update=none "$src" "$dst"; then echo "update=none invocation failed" >&2; exit 1; fi
if [[ "$(cat "$dst")" == "old" ]]; then exit 0; else echo "update=none replaced existing destination" >&2; exit 1; fi
