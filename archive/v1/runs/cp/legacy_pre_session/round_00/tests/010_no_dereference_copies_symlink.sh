#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
target="$tmpdir/target.txt"
link="$tmpdir/source_link"
dst="$tmpdir/dest_link"
printf 'target data\n' > "$target"
ln -s "$target" "$link"
if ! "$UTIL" -P "$link" "$dst"; then echo "no-dereference copy failed" >&2; exit 1; fi
if [[ -L "$dst" && "$(readlink "$dst")" == "$target" ]]; then exit 0; else echo "symlink was not copied as a symlink" >&2; exit 1; fi
