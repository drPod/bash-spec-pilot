#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
gid=$(/usr/bin/id -g)
out="$tmpdir/id.out"
err="$tmpdir/id.err"
if ! "$UTIL" -n -g "#$gid" /usr/bin/id -g >"$out" 2>"$err"; then
  echo "sudo -g numeric gid command failed" >&2
  exit 1
fi
if [[ "$(cat "$out")" != "$gid" ]]; then
  echo "command did not run with requested primary gid" >&2
  exit 1
fi
