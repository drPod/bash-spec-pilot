#!/usr/bin/env bash
# Harden cp/mv --strip-trailing-slashes on a regular-file SOURCE with a trailing
# slash. Run in trixie: docker run --rm -v <dir>:/probe debian:trixie-slim bash /probe/cp_sts_probe.sh
set -u
apt-get update -qq >/dev/null 2>&1; apt-get install -y -qq coreutils >/dev/null 2>&1
echo "cp/mv $(cp --version | head -1)"
cd "$(mktemp -d)"
mk(){ rm -rf w; mkdir w; printf Y > w/file.txt; mkdir w/dir; printf Z > w/dir/inner; }
run(){ local d="$1"; shift; ( "$@" ) >/tmp/o 2>/tmp/e; local rc=$?; echo "--- $d -> rc=$rc"; [ -s /tmp/e ] && sed "s/^/    stderr: /" /tmp/e; return 0; }
echo "=== cp regular-file source ==="
mk; run "cp --strip-trailing-slashes w/file.txt/ w/out1" cp --strip-trailing-slashes w/file.txt/ w/out1; [ -f w/out1 ] && echo "    out1 created" || echo "    out1 MISSING"
mk; run "cp (no flag)              w/file.txt/ w/out2" cp w/file.txt/ w/out2
mk; run "cp --strip-trailing-slashes w/file.txt  w/out3 (no slash sanity)" cp --strip-trailing-slashes w/file.txt w/out3; [ -f w/out3 ] && echo "    out3 created" || echo "    out3 MISSING"
echo "=== cp directory source (-r) ==="
mk; run "cp -r --strip-trailing-slashes w/dir/ w/dc1" cp -r --strip-trailing-slashes w/dir/ w/dc1; [ -d w/dc1 ] && echo "    dc1 created" || echo "    dc1 MISSING"
mk; run "cp -r (no flag)              w/dir/ w/dc2" cp -r w/dir/ w/dc2; [ -d w/dc2 ] && echo "    dc2 created" || echo "    dc2 MISSING"
echo "=== mv parallel (regular-file source) ==="
mk; run "mv --strip-trailing-slashes w/file.txt/ w/moved" mv --strip-trailing-slashes w/file.txt/ w/moved; [ -f w/moved ] && echo "    moved created" || echo "    moved MISSING"
