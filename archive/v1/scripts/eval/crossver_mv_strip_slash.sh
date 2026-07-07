#!/usr/bin/env bash
# Cross-version check for the wave-4 mv `--strip-trailing-slashes` finding.
#
# The finding (runs/mv/.../manpage_underspec.jsonl): the manpage states
# "remove any trailing slashes from each SOURCE argument", but GNU mv 9.7-3
# rejects `mv --strip-trailing-slashes <file>/ <dest>` with exit 1 and
# "Not a directory" when the source is a regular file. This script checks
# whether that behavior is version-stable or a 9.7 quirk by replaying the
# exact repro against coreutils 9.5-1, 9.6-2, and 9.7-3.
#
# 9.7-3 is the version pinned into the formal-verification:trixie image
# (docker/Dockerfile) and is exercised via the container's native /usr/bin/mv
# *before* any downgrade. 9.5-1 and 9.6-2 are pulled from snapshot.debian.org
# as .debs (pinned by content hash, so the check is reproducible) and installed
# over the base with `dpkg -i --force-downgrade` inside a throwaway container.
# Each binary's --version is verified before its result is trusted.
#
# The image is multi-arch (arm64 on Apple Silicon, amd64 on x86). A .deb only
# runs on its own architecture, so the script asks the container which arch it
# is (`dpkg --print-architecture`) and selects the matching snapshot hashes.
#
# Usage: scripts/eval/crossver_mv_strip_slash.sh
# Output: runs/mv/_crossver/<UTC>/result.json + a summary table on stdout.

set -euo pipefail

REPO="$(cd "$(dirname "$0")/../.." && pwd)"
TAG="formal-verification:trixie"

# snapshot.debian.org file URLs, pinned by sha1 (= reproducible), per arch.
arch="$(docker run --rm "$TAG" dpkg --print-architecture | tr -d '\r\n')"
case "$arch" in
  arm64)
    HASH_95="8fac6cc43b669e6babccd2fb4975f8d6ece6a4e7"
    HASH_96="660662739e4a816f96fd8ccc7d347eccc81a65f5"
    ;;
  amd64)
    HASH_95="c1cfb65c80598adf104fb6e97805fcce324024ed"
    HASH_96="29f59cf8d2d4082396636ca7f833baa1984c9ec5"
    ;;
  *)
    echo "unsupported container arch: $arch (expected arm64 or amd64)" >&2
    exit 2
    ;;
esac
echo "container arch: $arch"

ts="$(date -u +%Y-%m-%dT%H-%M-%SZ)"
outdir="$REPO/runs/mv/_crossver/$ts"
mkdir -p "$outdir"

scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT

echo "downloading coreutils 9.5-1, 9.6-2 .debs ($arch) from snapshot.debian.org ..."
curl -sSL "https://snapshot.debian.org/file/$HASH_95" -o "$scratch/coreutils_9.5-1.deb"
curl -sSL "https://snapshot.debian.org/file/$HASH_96" -o "$scratch/coreutils_9.6-2.deb"

# The repro + per-version runner, executed inside the trixie container.
# Native 9.7-3 is measured first, then 9.5/9.6 are installed over it with
# dpkg --force-downgrade. Emits one TSV line per version:
#   label<TAB>reported_version<TAB>rc<TAB>stderr_head.
container_script='
set -u
repro() {
  ver="$(mv --version 2>/dev/null | head -1 | sed "s/^mv (GNU coreutils) //")"
  d="$(mktemp -d)"
  printf "payload\n" > "$d/src"
  set +e
  err="$(mv --strip-trailing-slashes "$d/src/" "$d/dest" 2>&1)"
  rc=$?
  set -e
  rm -rf "$d"
  err="$(printf "%s" "$err" | head -1 | tr "\t\n" "  ")"
  printf "%s\t%s\t%s\t%s\n" "$1" "${ver:-UNKNOWN}" "$rc" "$err"
}
repro 9.7-3
dpkg -i --force-downgrade /debs/coreutils_9.5-1.deb >/dev/null 2>&1
repro 9.5-1
dpkg -i --force-downgrade /debs/coreutils_9.6-2.deb >/dev/null 2>&1
repro 9.6-2
'

echo "running repro under each version inside $TAG ..."
tsv="$(docker run --rm \
  -v "$scratch":/debs:ro \
  "$TAG" bash -c "$container_script")"

printf '%s\n' "$tsv"

# Assemble result.json on the host (python3 may be absent in the image).
python3 - "$outdir/result.json" "$arch" <<PY
import json, sys
arch = sys.argv[2]
rows = []
for line in '''$tsv'''.strip().splitlines():
    parts = line.split("\t")
    if len(parts) < 4:
        continue
    label, ver, rc, stderr = parts[0], parts[1], int(parts[2]), parts[3]
    reproduces = rc != 0 and "Not a directory" in stderr
    rows.append({
        "pinned_version": label,
        "reported_version": ver,
        "rc": rc,
        "stderr_head": stderr,
        "reproduces_finding": reproduces,
        "version_verified": ver.startswith(label.split("-")[0]),
    })
all_repro = all(r["reproduces_finding"] for r in rows)
all_verified = all(r["version_verified"] for r in rows)
result = {
    "finding": "mv --strip-trailing-slashes <file>/ <dest> rejects a regular-file "
               "source with trailing slash (exit!=0, 'Not a directory') despite the "
               "manpage saying the slash is stripped from each SOURCE argument",
    "repro": "printf 'payload\\\\n' > src; mv --strip-trailing-slashes src/ dest",
    "container_arch": arch,
    "versions": rows,
    "version_stable": all_repro,
    "all_versions_verified": all_verified,
}
with open(sys.argv[1], "w") as f:
    json.dump(result, f, indent=2)
print()
print("version-stable:", all_repro, " all-verified:", all_verified)
print("wrote", sys.argv[1])
PY
