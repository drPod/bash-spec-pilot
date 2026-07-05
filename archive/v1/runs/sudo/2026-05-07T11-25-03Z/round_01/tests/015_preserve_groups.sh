#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
expected=$(/usr/bin/id -G)
out="$tmpdir/groups.out"
err="$tmpdir/groups.err"
if ! "$UTIL" -n -P /usr/bin/id -G >"$out" 2>"$err"; then
  echo "sudo -P command failed" >&2
  exit 1
fi
if [[ "$(cat "$out")" != "$expected" ]]; then
  echo "supplementary groups were not preserved" >&2
  exit 1
fi
