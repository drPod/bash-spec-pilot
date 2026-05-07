#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
target="$tmpdir/target.txt"
link="$tmpdir/source_link"
dst="$tmpdir/dest.txt"
printf 'command line referent\n' > "$target"
ln -s "$target" "$link"
if ! "$UTIL" -H "$link" "$dst"; then echo "-H copy failed" >&2; exit 1; fi
if [[ ! -L "$dst" && "$(cat "$dst")" == "command line referent" ]]; then exit 0; else echo "command-line symlink was not followed" >&2; exit 1; fi
