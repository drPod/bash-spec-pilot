#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# -T, --no-target-directory: treat DEST as a normal file (not a dir to move into).
# DEST does not exist; with -T it becomes the renamed file rather than dir/src.
echo data > "$tmpdir/src"
"$UTIL" -T "$tmpdir/src" "$tmpdir/dst"
if [[ -f "$tmpdir/dst" && ! -d "$tmpdir/dst" && ! -e "$tmpdir/src" ]]; then
  exit 0
fi
echo "-T did not treat DEST as a normal file" >&2
exit 1
