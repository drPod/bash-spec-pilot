#!/usr/bin/env bash
# COLD adversarial: an explicit action (other than -prune/-quit) inhibits the
# default -print. Here -fprint to a file means nothing goes to stdout.
set -euo pipefail
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

: > "$tmpdir/x"
out="$tmpdir/captured"

# Documented: "The -print action is performed on all files for which the whole
# expression is true, unless it contains an action other than -prune or -quit.
# Actions which inhibit the default -print are -delete, -exec, -execdir, -ok,
# -okdir, -fls, -fprint, -fprintf, -ls, -print and -printf."
# With -fprint present, stdout must be empty.
stdout="$("$UTIL" "$tmpdir" -name x -fprint "$out")"

if [[ -n "$stdout" ]]; then
  echo "-fprint should inhibit default -print to stdout: got [$stdout]" >&2
  exit 1
fi
