#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/source.txt"
dst="$tmpdir/dest.txt"
printf 'new\n' > "$src"
printf 'old\n' > "$dst"
set +e
"$UTIL" --update=none-fail "$src" "$dst" >/dev/null 2>&1
status=$?
set -e
if [[ $status -ne 0 ]]; then exit 0; else echo "update=none-fail did not fail for skipped destination" >&2; exit 1; fi
