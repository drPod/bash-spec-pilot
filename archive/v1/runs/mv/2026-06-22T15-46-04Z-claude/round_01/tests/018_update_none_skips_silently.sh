#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# --update=none: like --no-clobber; no dest files replaced and skipped files do
# not induce a failure (exit status 0).
echo old > "$tmpdir/dst"
echo new > "$tmpdir/src"
set +e
"$UTIL" --update=none "$tmpdir/src" "$tmpdir/dst"
status=$?
set -e
if [[ $status -eq 0 && "$(cat "$tmpdir/dst")" == old ]]; then
  exit 0
fi
echo "--update=none did not skip silently (status=$status)" >&2
exit 1
