#!/usr/bin/env bash
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
src="$tmpdir/source.txt"
dst="$tmpdir/dest.txt"
printf 'new\n' > "$src"
printf 'old\n' > "$dst"
if ! "$UTIL" -n "$src" "$dst"; then echo "no-clobber invocation failed" >&2; exit 1; fi
if [[ "$(cat "$dst")" == "old" ]]; then exit 0; else echo "existing destination was clobbered" >&2; exit 1; fi
