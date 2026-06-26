#!/usr/bin/env bash
# COLD adversarial: -empty matches empty regular files AND empty directories,
# but not non-empty ones.
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

: > "$tmpdir/emptyfile"
mkdir "$tmpdir/emptydir"
mkdir "$tmpdir/fulldir"; : > "$tmpdir/fulldir/inner"
printf 'x' > "$tmpdir/fullfile"

# Documented: "File is empty and is either a regular file or a directory."
got="$("$UTIL" "$tmpdir" -mindepth 1 -empty | LC_ALL=C sort)"
want="$(printf '%s\n%s\n' "$tmpdir/emptydir" "$tmpdir/emptyfile" | LC_ALL=C sort)"

if [[ "$got" != "$want" ]]; then
  echo "-empty mismatch: got [$got] want [$want]" >&2
  exit 1
fi
