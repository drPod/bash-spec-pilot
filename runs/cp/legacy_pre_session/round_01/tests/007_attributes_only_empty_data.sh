#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/source.bin"
dst="$tmpdir/dest.bin"
printf 'payload data\n' > "$src"
if ! "$UTIL" --attributes-only "$src" "$dst"; then echo "attributes-only copy failed" >&2; exit 1; fi
if [[ "$(stat -c %s "$dst")" == "0" ]]; then exit 0; else echo "attributes-only destination contains file data" >&2; exit 1; fi
