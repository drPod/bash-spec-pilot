#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
marker="$tmpdir/background.marker"
set +e
"$UTIL" -n -b /bin/sh -c 'sleep 1; printf done > "$1"' sh "$marker" >"$tmpdir/background.out" 2>"$tmpdir/background.err"
set -e
for _ in 1 2 3 4 5 6 7 8 9 10; do
  [[ -f "$marker" ]] && break
  sleep 0.3
done
if [[ "$(cat "$marker" 2>/dev/null || true)" != "done" ]]; then
  echo "background command did not complete expected work" >&2
  exit 1
fi
