#!/usr/bin/env bash
# Metamorphic invariant: `mv A B && mv B A` is content-identity.
# Backed by manpage NAME line: "mv - move (rename) files" and DESCRIPTION
# line 12: "Rename SOURCE to DEST". A rename must preserve file contents.
set -euo pipefail

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/a"
dst="$tmpdir/b"

# Non-trivial payload: binary-ish bytes plus newlines.
printf 'hello\0world\nline2\n' > "$src"
expected_sha=$(sha256sum "$src" | awk '{print $1}')

"$UTIL" "$src" "$dst"
"$UTIL" "$dst" "$src"

if [[ ! -f "$src" ]]; then
  echo "FAIL: round-trip lost source path $src" >&2
  exit 1
fi
if [[ -e "$dst" ]]; then
  echo "FAIL: round-trip left intermediate path $dst" >&2
  exit 1
fi

actual_sha=$(sha256sum "$src" | awk '{print $1}')
if [[ "$actual_sha" != "$expected_sha" ]]; then
  echo "FAIL: round-trip mutated contents (expected $expected_sha, got $actual_sha)" >&2
  exit 1
fi
