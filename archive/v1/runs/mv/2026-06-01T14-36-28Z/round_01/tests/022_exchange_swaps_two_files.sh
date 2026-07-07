#!/usr/bin/env bash
set -euo pipefail

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

printf 'left\n' > "$tmpdir/a"
printf 'right\n' > "$tmpdir/b"

"$UTIL" --exchange "$tmpdir/a" "$tmpdir/b"

actual="$(<"$tmpdir/a")"
if [[ "$actual" != "right" ]]; then
  echo "--exchange did not swap files" >&2
  exit 1
fi
