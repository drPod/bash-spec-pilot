#!/usr/bin/env bash
# COLD adversarial boundary: -size rounds UP to the next unit; -size -1M only
# matches empty files (the documented worked example).
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

: > "$tmpdir/empty"                       # 0 bytes
printf 'x' > "$tmpdir/one_byte"          # 1 byte -> rounds up to 1M unit, excluded

# Documented: "Therefore -size -1M is not equivalent to -size -1048576c. The
# former only matches empty files, the latter matches files from 0 to
# 1,048,575 bytes."
got="$("$UTIL" "$tmpdir" -type f -size -1M | LC_ALL=C sort)"
want="$tmpdir/empty"

if [[ "$got" != "$want" ]]; then
  echo "-size -1M should match only empty files: got [$got] want [$want]" >&2
  exit 1
fi
