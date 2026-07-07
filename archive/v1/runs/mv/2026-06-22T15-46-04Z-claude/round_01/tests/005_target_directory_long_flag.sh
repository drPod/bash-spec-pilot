#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# --target-directory=DIRECTORY long form moves source into DIRECTORY.
echo data > "$tmpdir/file"
mkdir "$tmpdir/dir"
"$UTIL" --target-directory="$tmpdir/dir" "$tmpdir/file"
if [[ -f "$tmpdir/dir/file" && ! -e "$tmpdir/file" ]]; then
  exit 0
fi
echo "--target-directory= did not move source into directory" >&2
exit 1
