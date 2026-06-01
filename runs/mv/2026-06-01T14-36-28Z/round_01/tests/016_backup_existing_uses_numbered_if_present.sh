#!/usr/bin/env bash
set -euo pipefail

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

printf 'prior\n' > "$tmpdir/dest.~1~"
printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dest"

"$UTIL" --backup=existing "$tmpdir/src" "$tmpdir/dest"

actual="$(<"$tmpdir/dest.~2~")"
if [[ "$actual" != "old" ]]; then
  echo "existing backup did not choose numbered" >&2
  exit 1
fi
