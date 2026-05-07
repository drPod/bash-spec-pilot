#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/source.txt"
dst="$tmpdir/dest.txt"
printf 'new\n' > "$src"
printf 'old suffix\n' > "$dst"
if ! "$UTIL" --backup=simple -S .bak "$src" "$dst"; then echo "backup with suffix failed" >&2; exit 1; fi
if [[ "$(cat "$dst.bak")" == "old suffix" ]]; then exit 0; else echo "custom suffix backup not created with old content" >&2; exit 1; fi
