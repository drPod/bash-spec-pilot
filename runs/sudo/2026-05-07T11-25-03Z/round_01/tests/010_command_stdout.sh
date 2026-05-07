#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
out="$tmpdir/stdout.out"
err="$tmpdir/stdout.err"
if ! "$UTIL" -n /bin/printf 'hello\n' >"$out" 2>"$err"; then
  echo "sudo command execution failed" >&2
  exit 1
fi
if [[ "$(cat "$out")" != "hello" ]]; then
  echo "command stdout was not preserved" >&2
  exit 1
fi
