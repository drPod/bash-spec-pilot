#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/source.txt"
dst="$tmpdir/dest.txt"
umask 077
printf 'mode\n' > "$src"
chmod 0644 "$src"
if ! "$UTIL" -p --no-preserve=mode "$src" "$dst"; then echo "no-preserve mode copy failed" >&2; exit 1; fi
if [[ "$(stat -c %a "$dst")" == "600" ]]; then exit 0; else echo "mode was unexpectedly preserved" >&2; exit 1; fi
