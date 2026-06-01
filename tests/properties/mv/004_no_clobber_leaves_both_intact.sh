#!/usr/bin/env bash
# Metamorphic invariant: `mv -n` (no-clobber) on an existing destination
# leaves BOTH paths intact with their original contents — source not
# removed, destination not overwritten. Backed by manpage lines 34-35:
# "-n, --no-clobber  do not overwrite an existing file".
set -euo pipefail

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src"
dst="$tmpdir/dst"

printf 'source-bytes\n' > "$src"
printf 'destination-bytes\n' > "$dst"
src_sha=$(sha256sum "$src" | awk '{print $1}')
dst_sha=$(sha256sum "$dst" | awk '{print $1}')

# mv -n is documented to skip; coreutils may exit 0 or nonzero depending on
# version. We assert state, not exit code.
set +e
"$UTIL" -n "$src" "$dst"
set -e

if [[ ! -f "$src" ]]; then
  echo "FAIL: -n removed source $src" >&2
  exit 1
fi
if [[ ! -f "$dst" ]]; then
  echo "FAIL: -n removed destination $dst" >&2
  exit 1
fi
actual_src_sha=$(sha256sum "$src" | awk '{print $1}')
actual_dst_sha=$(sha256sum "$dst" | awk '{print $1}')
if [[ "$actual_src_sha" != "$src_sha" ]]; then
  echo "FAIL: -n mutated source bytes" >&2
  exit 1
fi
if [[ "$actual_dst_sha" != "$dst_sha" ]]; then
  echo "FAIL: -n overwrote destination (clobbered)" >&2
  exit 1
fi
