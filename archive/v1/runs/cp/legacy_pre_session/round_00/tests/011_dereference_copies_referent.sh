#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
target="$tmpdir/target.txt"
link="$tmpdir/source_link"
dst="$tmpdir/dest.txt"
printf 'follow me\n' > "$target"
ln -s "$target" "$link"
if ! "$UTIL" -L "$link" "$dst"; then echo "dereference copy failed" >&2; exit 1; fi
if [[ ! -L "$dst" && "$(cat "$dst")" == "follow me" ]]; then exit 0; else echo "destination is not a regular copy of the referent" >&2; exit 1; fi
