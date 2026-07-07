#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
uid=$(/usr/bin/id -u)
out="$tmpdir/id.out"
err="$tmpdir/id.err"
if ! "$UTIL" -n -u "#$uid" /usr/bin/id -u >"$out" 2>"$err"; then
  echo "sudo -u numeric uid command failed" >&2
  exit 1
fi
if [[ "$(cat "$out")" != "$uid" ]]; then
  echo "command did not run as requested uid" >&2
  exit 1
fi
