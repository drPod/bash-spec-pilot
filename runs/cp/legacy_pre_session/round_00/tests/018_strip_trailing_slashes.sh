#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
dir="$tmpdir/real_dir"
link="$tmpdir/source_link"
dst="$tmpdir/copied_link"
mkdir -p "$dir"
ln -s "$dir" "$link"
if ! "$UTIL" -P --strip-trailing-slashes "$link/" "$dst"; then echo "strip trailing slashes copy failed" >&2; exit 1; fi
if [[ -L "$dst" && "$(readlink "$dst")" == "$dir" ]]; then exit 0; else echo "trailing slash was not stripped before no-dereference copy" >&2; exit 1; fi
