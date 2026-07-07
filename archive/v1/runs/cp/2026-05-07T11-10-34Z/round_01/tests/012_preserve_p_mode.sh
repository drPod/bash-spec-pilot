#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/source.txt"
dst="$tmpdir/dest.txt"
printf 'mode\n' > "$src"
chmod 640 "$src"
if ! "$UTIL" -p "$src" "$dst"; then echo "cp -p failed" >&2; exit 1; fi
if [[ "$(stat -c '%a' "$dst")" == "640" ]]; then exit 0; fi
echo "-p did not preserve mode" >&2
exit 1
