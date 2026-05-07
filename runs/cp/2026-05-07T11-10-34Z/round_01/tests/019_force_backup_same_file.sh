#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/same.txt"
printf 'same-file\n' > "$src"
if ! "$UTIL" -f --backup=simple --suffix=.bak "$src" "$src"; then echo "cp -f --backup same file failed" >&2; exit 1; fi
if [[ "$(cat "$src.bak")" == "same-file" ]]; then exit 0; fi
echo "same-file force backup not created with original data" >&2
exit 1
