#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
work="$tmpdir/work"
mkdir "$work"
out="$tmpdir/pwd.out"
err="$tmpdir/pwd.err"
if ! "$UTIL" -n -D "$work" /bin/pwd >"$out" 2>"$err"; then
  echo "sudo -D command failed" >&2
  exit 1
fi
if [[ "$(cat "$out")" != "$work" ]]; then
  echo "command did not run in requested directory" >&2
  exit 1
fi
