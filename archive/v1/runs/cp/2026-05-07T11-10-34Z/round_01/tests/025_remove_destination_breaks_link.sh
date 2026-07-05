#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/source.txt"
dst="$tmpdir/dest.txt"
peer="$tmpdir/peer.txt"
printf 'new\n' > "$src"
printf 'old\n' > "$dst"
ln "$dst" "$peer"
if ! "$UTIL" --remove-destination "$src" "$dst"; then echo "cp --remove-destination failed" >&2; exit 1; fi
if [[ "$(stat -c '%d:%i' "$dst")" != "$(stat -c '%d:%i' "$peer")" ]]; then exit 0; fi
echo "destination was not removed before replacement" >&2
exit 1
