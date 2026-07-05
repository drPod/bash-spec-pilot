#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# The backup suffix is '~', unless set with --suffix or SIMPLE_BACKUP_SUFFIX.
echo new > "$tmpdir/src"
echo old > "$tmpdir/dst"
SIMPLE_BACKUP_SUFFIX=.sb "$UTIL" --backup "$tmpdir/src" "$tmpdir/dst"
if [[ -f "$tmpdir/dst.sb" && "$(cat "$tmpdir/dst.sb")" == old ]]; then
  exit 0
fi
echo "SIMPLE_BACKUP_SUFFIX did not set backup suffix" >&2
exit 1
