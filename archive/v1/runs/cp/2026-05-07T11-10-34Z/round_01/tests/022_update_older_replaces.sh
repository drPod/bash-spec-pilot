#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/source.txt"
dst="$tmpdir/dest.txt"
printf 'new\n' > "$src"
printf 'old\n' > "$dst"
touch -d '2020-01-01 00:00:00 UTC' "$dst"
touch -d '2021-01-01 00:00:00 UTC' "$src"
if ! "$UTIL" --update=older "$src" "$dst"; then echo "cp --update=older failed" >&2; exit 1; fi
if [[ "$(cat "$dst")" == "new" ]]; then exit 0; fi
echo "--update=older did not replace older destination" >&2
exit 1
