#!/usr/bin/env bash
# -g group: "If no -u option is specified, the command will be run as the
# invoking user." As root the invoking user is root, so id -un stays root
# while -g sets the primary group.
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

out="$tmpdir/out"
set +e
"$UTIL" -n -g daemon id -un >"$out" 2>"$tmpdir/err"
status=$?
set -e

if [[ $status -ne 0 ]]; then
  echo "expected sudo -g daemon to run, exited $status: $(cat "$tmpdir/err")" >&2
  exit 1
fi
if [[ "$(tr -d '[:space:]' <"$out")" != "root" ]]; then
  echo "expected -g without -u to keep invoking user root, got '$(cat "$out")'" >&2
  exit 1
fi
