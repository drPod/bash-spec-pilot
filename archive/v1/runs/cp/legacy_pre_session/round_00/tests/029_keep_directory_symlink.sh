#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
srcdir="$tmpdir/srcdir"
real="$tmpdir/real_target"
link="$tmpdir/dest_link"
mkdir -p "$srcdir" "$real"
printf 'through symlink\n' > "$srcdir/file.txt"
ln -s "$real" "$link"
if ! "$UTIL" -R --keep-directory-symlink "$srcdir" "$link"; then echo "keep-directory-symlink copy failed" >&2; exit 1; fi
if [[ "$(cat "$real/srcdir/file.txt")" == "through symlink" ]]; then exit 0; else echo "existing directory symlink was not followed" >&2; exit 1; fi
