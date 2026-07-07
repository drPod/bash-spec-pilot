#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
out="$tmpdir/background.out"
err="$tmpdir/background.err"
cmd="sleep 1; printf 'done' > '$out'"
if ! "$UTIL" -n -b /bin/sh -c "$cmd" >"$tmpdir/sudo.out" 2>"$err"; then
  echo "sudo -b failed to start command" >&2
  exit 1
fi
for _ in {1..50}; do
  [[ -f "$out" ]] && break
  sleep 0.1
done
if [[ "$(cat "$out" 2>/dev/null || true)" != "done" ]]; then
  echo "background command did not complete expected work" >&2
  exit 1
fi
