#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/source.txt"
dst="$tmpdir/existing_dir"
printf 'data\n' > "$src"
mkdir "$dst"
set +e
"$UTIL" -T "$src" "$dst" >/dev/null 2>&1
status=$?
set -e
if [[ "$status" -ne 0 ]]; then exit 0; fi
echo "cp -T unexpectedly succeeded for existing directory" >&2
exit 1
