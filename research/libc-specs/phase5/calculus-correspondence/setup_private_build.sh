#!/bin/bash
# Repeat-safe private OCaml build for same-input comparison (calculus-correspondence-11).
#
# Fixes over the calculus-correspondence-10 README's prose instructions (found wrong by the
# orchestrator's audit, not by this worker):
#   - `docker exec ... patch -p1 < file` never actually sent the host file's content into the
#     container: `docker exec` needs `-i` to attach stdin at all, which was missing, so the
#     redirection was a silent no-op running against an empty stdin (`patch` would then either
#     hang waiting for input or fail outright, depending on how it's invoked interactively vs
#     scripted -- fixed here two ways: `-i` on `docker exec`, and `docker cp`  the patch in
#     first rather than relying on redirection at all, matching how the OTHER three adapter
#     files were already (correctly) transferred with `docker cp`).
#   - The staging directory name (`calculus-correspondence10`) was static: a second run would
#     either collide with the first or silently reuse a stale copy. This script always creates
#     a fresh, uniquely-suffixed directory and prints its name; nothing is overwritten.
#   - No hash verification: this script sha256sums every file it stages and the resulting
#     patched `interp.ml`, and prints them, so a later run (or a different worker) can confirm
#     byte-for-byte it built the same thing.
#
# Usage: ./setup_private_build.sh [container] [repo_root]
# Prints the staging directory path on the LAST line of stdout on success (nothing else does).
set -euo pipefail

CONTAINER="${1:-phase5-vst}"
REPO_ROOT="${2:-/home/ubuntu/Coding/bash-spec-pilot}"
ADAPTER="$REPO_ROOT/research/libc-specs/phase5/calculus-bytes/adapter"
STAGE="calculus-correspondence11-$(date -u +%Y%m%dT%H%M%SZ)-$$"
STAGE_PATH="/home/coq/phase5/$STAGE"

echo "== staging at $STAGE_PATH (unique per run; never reused) ==" >&2

docker exec "$CONTAINER" cp -r /home/coq/phase5/calculus-bytes "$STAGE_PATH"

for f in bytes_builtin.ml lower.ml cb_main.ml; do
  docker cp "$ADAPTER/$f" "$CONTAINER:$STAGE_PATH/bash-verifier/calculus_bytes/$f"
done
docker cp "$ADAPTER/interp_element_path.patch" "$CONTAINER:$STAGE_PATH/interp_element_path.patch"

echo "== applying interp_element_path.patch (dry-run first) ==" >&2
docker exec -w "$STAGE_PATH" "$CONTAINER" patch -p1 --dry-run < "$ADAPTER/interp_element_path.patch"
docker exec -i -w "$STAGE_PATH" "$CONTAINER" patch -p1 < "$ADAPTER/interp_element_path.patch"

echo "== source hashes (staged == repo adapter, except interp.ml which is patched) ==" >&2
docker exec "$CONTAINER" sha256sum \
  "$STAGE_PATH/bash-verifier/calculus_bytes/bytes_builtin.ml" \
  "$STAGE_PATH/bash-verifier/calculus_bytes/lower.ml" \
  "$STAGE_PATH/bash-verifier/calculus_bytes/cb_main.ml" \
  "$STAGE_PATH/bash-verifier/lib/calculus/interp.ml" >&2
sha256sum "$ADAPTER"/bytes_builtin.ml "$ADAPTER"/lower.ml "$ADAPTER"/cb_main.ml \
  "$ADAPTER"/interp_element_path.patch >&2

echo "== building (dune, release profile; run under the shared compiler lock by the caller) ==" >&2
echo "next: uv run --no-project python research/libc-specs/phase5/run_vst.py --name <fresh-name> --seconds 120 --workdir $STAGE_PATH -- dune build --profile release ./bash-verifier/calculus_bytes/cb_main.exe --display short" >&2

echo "$STAGE_PATH"
