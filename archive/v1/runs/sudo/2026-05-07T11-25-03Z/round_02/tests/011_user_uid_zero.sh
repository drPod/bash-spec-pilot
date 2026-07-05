#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
out="$tmpdir/uid.out"
set +e
"$UTIL" -n -u '#0' /usr/bin/id -u >"$out" 2>"$tmpdir/uid.err"
set -e
if [[ "$(tr -d '\n' < "$out")" != "0" ]]; then
  echo "numeric target uid was not applied" >&2
  exit 1
fi
