#!/usr/bin/env bash
set -euo pipefail

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dest"

SIMPLE_BACKUP_SUFFIX=.save "$UTIL" --backup=simple "$tmpdir/src" "$tmpdir/dest"

actual="$(<"$tmpdir/dest.save")"
if [[ "$actual" != "old" ]]; then
  echo "SIMPLE_BACKUP_SUFFIX was not used" >&2
  exit 1
fi
