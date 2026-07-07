#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# --update=none-fail: no files replaced, but any skipped files are diagnosed and
# induce a failure. Existing dest => skip => nonzero exit, dest unchanged.
echo old > "$tmpdir/dst"
echo new > "$tmpdir/src"
set +e
"$UTIL" --update=none-fail "$tmpdir/src" "$tmpdir/dst"
status=$?
set -e
if [[ $status -ne 0 && "$(cat "$tmpdir/dst")" == old ]]; then
  exit 0
fi
echo "--update=none-fail did not induce a failure on a skipped file (status=$status)" >&2
exit 1
