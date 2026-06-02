#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
printf 'new\n' > "$tmpdir/src"
printf 'old\n' > "$tmpdir/dst"
printf 'prior\n' > "$tmpdir/dst.~5~"
set +e
"$UTIL" --backup=existing "$tmpdir/src" "$tmpdir/dst" >/dev/null 2>"$tmpdir/err"
status=$?
set -e
if [[ $status -ne 0 ]]; then
  echo "mv unexpectedly failed" >&2
  exit 1
fi
if [[ ! -e "$tmpdir/dst.~6~" ]]; then
  echo "existing numbered backup did not select next numbered backup" >&2
  exit 1
fi
