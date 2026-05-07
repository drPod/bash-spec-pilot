#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/parent/child/file.txt"
out="$tmpdir/out"
mkdir -p "$(dirname "$src")" "$out"
printf 'parents\n' > "$src"
if ! "$UTIL" --parents "$src" "$out"; then echo "cp --parents failed" >&2; exit 1; fi
expected_path="$out$src"
if [[ "$(cat "$expected_path")" == "parents" ]]; then exit 0; fi
echo "--parents did not create full source path under directory" >&2
exit 1
