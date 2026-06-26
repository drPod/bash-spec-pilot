#!/usr/bin/env bash
set -euo pipefail
# -b : "like --backup but does not accept an argument" ;
# --backup : "make a backup of each existing destination file" ;
# "The backup suffix is '~', unless set with --suffix or SIMPLE_BACKUP_SUFFIX."
# No numbered backups exist, env defaults -> simple backup named DEST~.
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
unset SIMPLE_BACKUP_SUFFIX VERSION_CONTROL || true

src="$tmpdir/src.txt"
dst="$tmpdir/dst.txt"
printf 'NEW' > "$src"
printf 'OLD' > "$dst"

"$UTIL" -b "$src" "$dst"

if [[ "$(cat "${dst}~" 2>/dev/null)" != "OLD" ]]; then
  echo "FAIL: -b did not create backup '${dst}~' holding the old DEST content" >&2
  exit 1
fi
