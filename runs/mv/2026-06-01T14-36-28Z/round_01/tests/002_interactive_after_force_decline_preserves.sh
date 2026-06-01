#!/usr/bin/env bash
set -euo pipefail

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dest"

printf 'n\n' | "$UTIL" -f -i "$tmpdir/src" "$tmpdir/dest"

actual="$(<"$tmpdir/dest")"
if [[ "$actual" != "old" ]]; then
  echo "-i after -f did not preserve on no" >&2
  exit 1
fi
