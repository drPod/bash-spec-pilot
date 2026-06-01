#!/usr/bin/env bash
# Metamorphic invariant: within-device move is atomic-by-rename(2):
# after `mv A B` the source path A no longer exists AND B holds A's bytes.
# Backed by manpage SEE ALSO line: "rename(2)" and DESCRIPTION line 12:
# "Rename SOURCE to DEST". Same tmpdir => same filesystem => rename(2) path.
set -euo pipefail

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src"
dst="$tmpdir/dst"

printf 'payload-%s\n' "$$" > "$src"
expected_sha=$(sha256sum "$src" | awk '{print $1}')

"$UTIL" "$src" "$dst"

if [[ -e "$src" ]]; then
  echo "FAIL: source path $src still exists after mv" >&2
  exit 1
fi
if [[ ! -f "$dst" ]]; then
  echo "FAIL: destination path $dst missing after mv" >&2
  exit 1
fi
actual_sha=$(sha256sum "$dst" | awk '{print $1}')
if [[ "$actual_sha" != "$expected_sha" ]]; then
  echo "FAIL: destination bytes diverge from source (expected $expected_sha, got $actual_sha)" >&2
  exit 1
fi
