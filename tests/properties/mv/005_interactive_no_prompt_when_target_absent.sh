#!/usr/bin/env bash
# Metamorphic invariant: `mv -i` does not prompt and does not hang when the
# destination does not yet exist — there is nothing to overwrite, so the
# interactive path is unreachable. Backed by manpage lines 31-32:
# "-i, --interactive  prompt before overwrite". No overwrite => no prompt.
#
# We redirect stdin from /dev/null. If mv -i incorrectly tried to read a
# response, it would either hang or read EOF and (by convention) skip,
# leaving the source in place. We assert the rename completed.
set -euo pipefail

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

src="$tmpdir/src"
dst="$tmpdir/dst"

printf 'payload\n' > "$src"
src_sha=$(sha256sum "$src" | awk '{print $1}')

# Bound the call: a buggy impl that blocks reading stdin would otherwise hang
# the whole suite. timeout turns the hang into a nonzero exit `set -e` surfaces.
timeout 10 "$UTIL" -i "$src" "$dst" </dev/null

if [[ -e "$src" ]]; then
  echo "FAIL: -i did not move source $src (possibly prompted on /dev/null)" >&2
  exit 1
fi
if [[ ! -f "$dst" ]]; then
  echo "FAIL: -i did not create destination $dst" >&2
  exit 1
fi
# The rename must carry the original bytes — an impl could create an empty or
# wrong dst and pass an existence-only check.
if [[ "$(sha256sum "$dst" | awk '{print $1}')" != "$src_sha" ]]; then
  echo "FAIL: -i created destination but content != original source bytes" >&2
  exit 1
fi
