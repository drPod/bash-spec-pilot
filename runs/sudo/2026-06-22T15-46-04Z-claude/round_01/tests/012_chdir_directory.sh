#!/usr/bin/env bash
# -D directory / --chdir: run the command in the specified directory instead
# of the current working directory.
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/work"
out="$tmpdir/out"
set +e
"$UTIL" -n -D "$tmpdir/work" pwd >"$out" 2>"$tmpdir/err"
status=$?
set -e

if [[ $status -ne 0 ]]; then
  echo "expected sudo -D to run, exited $status: $(cat "$tmpdir/err")" >&2
  exit 1
fi
if [[ "$(cat "$out")" != "$tmpdir/work" ]]; then
  echo "expected cwd '$tmpdir/work', got '$(cat "$out")'" >&2
  exit 1
fi
