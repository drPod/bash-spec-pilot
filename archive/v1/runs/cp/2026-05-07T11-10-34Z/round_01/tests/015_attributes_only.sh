#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/source.txt"
dst="$tmpdir/dest.txt"
printf 'nonempty data\n' > "$src"
if ! "$UTIL" --attributes-only "$src" "$dst"; then echo "cp --attributes-only failed" >&2; exit 1; fi
if [[ "$(stat -c '%s' "$dst")" -eq 0 ]]; then exit 0; fi
echo "attributes-only copy copied file data" >&2
exit 1
