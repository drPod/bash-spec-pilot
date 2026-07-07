#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
out="$tmpdir/gid.out"
set +e
"$UTIL" -n -g '#0' /usr/bin/id -g >"$out" 2>"$tmpdir/gid.err"
set -e
if [[ "$(tr -d '\n' < "$out")" != "0" ]]; then
  echo "numeric target gid was not applied" >&2
  exit 1
fi
