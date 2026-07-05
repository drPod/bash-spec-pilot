#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
out="$tmpdir/noninteractive.out"
set +e
"$UTIL" -n /usr/bin/printf 'ok' >"$out" 2>"$tmpdir/noninteractive.err"
set -e
if [[ "$(cat "$out")" != "ok" ]]; then
  echo "non-interactive command did not produce expected output" >&2
  exit 1
fi
