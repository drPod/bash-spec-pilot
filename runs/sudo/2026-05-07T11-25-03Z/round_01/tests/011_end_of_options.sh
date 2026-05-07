#!/usr/bin/env bash
set -euo pipefail
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
cmd="$tmpdir/record_arg"
out="$tmpdir/arg.out"
err="$tmpdir/arg.err"
cat >"$cmd" <<'EOS'
#!/bin/sh
printf '%s\n' "$1" > "$2"
EOS
chmod +x "$cmd"
if ! "$UTIL" -n -- "$cmd" -n "$out" >"$tmpdir/stdout.out" 2>"$err"; then
  echo "sudo -- command failed" >&2
  exit 1
fi
if [[ "$(cat "$out")" != "-n" ]]; then
  echo "argument after -- was not passed to command" >&2
  exit 1
fi
