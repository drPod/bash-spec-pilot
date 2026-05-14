#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
out="$tmpdir/arg.out"
set +e
"$UTIL" -n -- /bin/sh -c 'printf "%s" "$1" > "$2"' sh '-x' "$out" >"$tmpdir/delim.out" 2>"$tmpdir/delim.err"
set -e
if [[ "$(cat "$out" 2>/dev/null || true)" != "-x" ]]; then
  echo "option delimiter did not pass option-like command argument" >&2
  exit 1
fi
