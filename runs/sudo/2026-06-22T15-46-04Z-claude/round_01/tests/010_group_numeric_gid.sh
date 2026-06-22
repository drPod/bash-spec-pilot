#!/usr/bin/env bash
# -g group: group may be a numeric GID prefixed with '#'. '#0' for GID 0.
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

out="$tmpdir/out"
set +e
"$UTIL" -n -g '#0' id -g >"$out" 2>"$tmpdir/err"
status=$?
set -e

if [[ $status -ne 0 ]]; then
  echo "expected sudo -g #0 to run, exited $status: $(cat "$tmpdir/err")" >&2
  exit 1
fi
if [[ "$(tr -d '[:space:]' <"$out")" != "0" ]]; then
  echo "expected numeric GID 0 for '#0', got '$(cat "$out")'" >&2
  exit 1
fi
