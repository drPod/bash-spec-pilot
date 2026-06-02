#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dst"
printf 'prior\n' > "$tmpdir/dst.~1~"
set +e
"$UTIL" --backup=numbered "$tmpdir/src" "$tmpdir/dst" >/dev/null 2>"$tmpdir/err"
status=$?
set -e
if [[ $status -ne 0 ]]; then
  echo "mv unexpectedly failed" >&2
  exit 1
fi
if [[ ! -e "$tmpdir/dst.~2~" ]]; then
  echo "numbered backup did not create next numbered name" >&2
  exit 1
fi
