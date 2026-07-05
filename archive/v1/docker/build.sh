#!/usr/bin/env bash
# Build the formal-verification:trixie image. Idempotent — Docker layer
# caching makes re-runs cheap when nothing changed.
#
# Usage: docker/build.sh           # build with cache
#        docker/build.sh --no-cache  # full rebuild

set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
TAG="formal-verification:trixie"

CACHE_FLAG=""
if [[ "${1:-}" == "--no-cache" ]]; then
  CACHE_FLAG="--no-cache"
fi

echo "building $TAG from $REPO/docker/Dockerfile" >&2
docker build $CACHE_FLAG -t "$TAG" -f "$REPO/docker/Dockerfile" "$REPO/docker"

echo "image: $TAG" >&2
docker image inspect "$TAG" --format '{{.Size}}' | awk '{
    s = $1
    if (s > 1073741824) printf "size: %.2f GiB\n", s/1073741824
    else                printf "size: %.2f MiB\n", s/1048576
}' >&2
