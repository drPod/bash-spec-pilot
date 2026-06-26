#!/usr/bin/env bash
set -euo pipefail
# --strip-trailing-slashes : "remove any trailing slashes from each SOURCE
# argument". A regular-file SOURCE given with a trailing slash is stripped to
# the plain name, so the copy succeeds.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/file.txt"
dst="$tmpdir/out.txt"
printf 'Y' > "$src"

"$UTIL" --strip-trailing-slashes "$src/" "$dst"

if [[ "$(cat "$dst" 2>/dev/null)" != "Y" ]]; then
  echo "FAIL: --strip-trailing-slashes did not let a trailing-slash file SOURCE copy" >&2
  exit 1
fi
