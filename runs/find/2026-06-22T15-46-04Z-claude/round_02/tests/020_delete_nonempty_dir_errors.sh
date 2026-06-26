#!/usr/bin/env bash
# COLD adversarial ERROR: -delete fails to remove a non-empty directory ->
# nonzero exit status.
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/parent/child"
: > "$tmpdir/parent/child/file"

# Documented: "The -delete action will fail to remove a directory unless it is
# empty." and "If the removal failed, an error message is issued and find's
# exit status will be nonzero (when it eventually exits)."
# Target ONLY the non-empty directory "parent" by name. -delete implies -depth,
# but because we only match "parent" (not its contents), the directory is still
# non-empty when removal is attempted -> failure.
set +e
"$UTIL" "$tmpdir" -depth -type d -name parent -delete >/dev/null 2>&1
status=$?
set -e

if [[ $status -eq 0 ]]; then
  echo "-delete on non-empty dir should set nonzero exit, got 0" >&2
  exit 1
fi
