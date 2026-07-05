#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# -f, --force: do not prompt before overwriting. Existing dest is overwritten.
echo new > "$tmpdir/src"
echo old > "$tmpdir/dst"
"$UTIL" -f "$tmpdir/src" "$tmpdir/dst" < /dev/null
if [[ "$(cat "$tmpdir/dst")" == new && ! -e "$tmpdir/src" ]]; then
  exit 0
fi
echo "-f did not overwrite existing destination" >&2
exit 1
