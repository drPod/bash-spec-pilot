#!/usr/bin/env bash
# Metamorphic invariant: -L and -P diverge in the documented direction on a
# symlink source. Manpage lines 49-56:
#   "-L, --dereference     always follow symbolic links in SOURCE"
#   "-P, --no-dereference  never follow symbolic links in SOURCE"
# Therefore: under -L the destination must be a regular file (the referent
# content); under -P the destination must itself be a symlink.
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

target="$tmpdir/target"
link="$tmpdir/link"
dst_L="$tmpdir/dst_L"
dst_P="$tmpdir/dst_P"

printf 'referent\n' > "$target"
ln -s "$target" "$link"

if ! "$UTIL" -L "$link" "$dst_L"; then
    echo "cp -L invocation failed" >&2
    exit 1
fi
if ! "$UTIL" -P "$link" "$dst_P"; then
    echo "cp -P invocation failed" >&2
    exit 1
fi

# Under -L: dst must be a regular file (not a symlink) with referent content.
if [[ -L "$dst_L" ]] || [[ ! -f "$dst_L" ]]; then
    echo "-L did not dereference: dst is symlink or non-regular" >&2
    exit 1
fi
# Under -P: dst must itself be a symlink.
if [[ ! -L "$dst_P" ]]; then
    echo "-P did not preserve symlink: dst is not a symlink" >&2
    exit 1
fi
exit 0
