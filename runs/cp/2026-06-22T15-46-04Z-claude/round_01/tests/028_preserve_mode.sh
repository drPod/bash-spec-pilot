#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src.sh"
dst="$tmpdir/dst.sh"
printf 'echo hi\n' > "$src"
chmod 0741 "$src"

# -p: same as --preserve=mode,ownership,timestamps. Assert mode bits preserved.
"$UTIL" -p "$src" "$dst"

src_mode=$(stat -c '%a' "$src" 2>/dev/null || stat -f '%Lp' "$src")
dst_mode=$(stat -c '%a' "$dst" 2>/dev/null || stat -f '%Lp' "$dst")
if [[ "$src_mode" != "$dst_mode" ]]; then
  echo "FAIL: -p did not preserve mode (src=$src_mode dst=$dst_mode)" >&2
  exit 1
fi
