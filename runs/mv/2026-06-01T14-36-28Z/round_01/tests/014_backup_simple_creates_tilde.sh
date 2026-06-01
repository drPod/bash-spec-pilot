#!/usr/bin/env bash
set -euo pipefail

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dest"

"$UTIL" --backup=simple "$tmpdir/src" "$tmpdir/dest"

actual="$(<"$tmpdir/dest~")"
if [[ "$actual" != "old" ]]; then
  echo "simple backup did not contain old dest" >&2
  exit 1
fi
