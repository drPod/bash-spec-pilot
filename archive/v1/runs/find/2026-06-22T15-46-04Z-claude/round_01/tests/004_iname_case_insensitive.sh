#!/usr/bin/env bash
set -euo pipefail
# Documented: "-iname pattern  Like -name, but the match is case insensitive.
# For example, the patterns `fo*' ... match the file names `Foo', `FOO', `foo'".
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

: > "$tmpdir/Foo"
: > "$tmpdir/FOO" 2>/dev/null || true
: > "$tmpdir/bar"

out=$("$UTIL" "$tmpdir" -iname 'fo*' | sort)
# On a case-insensitive FS Foo and FOO collapse; assert every match is a
# case-insensitive 'fo*' hit and that at least one matched.
if [[ -z "$out" ]]; then
    echo "FAIL: -iname 'fo*' matched nothing" >&2
    exit 1
fi
while IFS= read -r line; do
    base=$(basename "$line")
    lc=$(printf '%s' "$base" | tr '[:upper:]' '[:lower:]')
    case "$lc" in
        fo*) : ;;
        *) echo "FAIL: -iname 'fo*' matched non-fo* entry: $line" >&2; exit 1 ;;
    esac
done <<< "$out"
