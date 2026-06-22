#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# -T, --no-target-directory: treat DEST as a normal file. When DEST is an
# existing directory, treating it as a normal file overwrite target must fail.
echo data > "$tmpdir/src"
mkdir "$tmpdir/destdir"
set +e
"$UTIL" -T "$tmpdir/src" "$tmpdir/destdir"
status=$?
set -e
if [[ $status -ne 0 && -e "$tmpdir/src" ]]; then
  exit 0
fi
echo "-T onto an existing directory did not fail (status=$status)" >&2
exit 1
