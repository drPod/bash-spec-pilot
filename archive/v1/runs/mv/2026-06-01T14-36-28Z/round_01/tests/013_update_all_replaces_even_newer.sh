#!/usr/bin/env bash
set -euo pipefail

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dest"
touch -d '2024-01-01 00:00:00 UTC' "$tmpdir/src"
touch -d '2024-01-02 00:00:00 UTC' "$tmpdir/dest"

"$UTIL" --update=all "$tmpdir/src" "$tmpdir/dest"

actual="$(<"$tmpdir/dest")"
if [[ "$actual" != "new" ]]; then
  echo "--update=all did not replace newer dest" >&2
  exit 1
fi
