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

# Under -L: dst must be a regular file (not a symlink) AND hold the referent
# bytes. Type alone is insufficient — an impl could create an empty regular
# file and pass a type-only check.
if [[ -L "$dst_L" ]] || [[ ! -f "$dst_L" ]]; then
    echo "-L did not dereference: dst is symlink or non-regular" >&2
    exit 1
fi
if ! cmp -s "$target" "$dst_L"; then
    echo "-L dereferenced but dst content != referent" >&2
    exit 1
fi
# Under -P: dst must itself be a symlink AND point at the same target as the
# original link — a symlink to the wrong place would pass a type-only check.
if [[ ! -L "$dst_P" ]]; then
    echo "-P did not preserve symlink: dst is not a symlink" >&2
    exit 1
fi
if [[ "$(readlink "$dst_P")" != "$(readlink "$link")" ]]; then
    echo "-P preserved a symlink but its target differs from the original" >&2
    exit 1
fi
exit 0
