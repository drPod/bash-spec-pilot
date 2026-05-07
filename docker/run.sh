#!/usr/bin/env bash
# Run an arbitrary command inside the formal-verification:trixie image with
# the repo mounted at /work. Used by run_tests.py --in-docker, by
# scripts/coverage_rust.sh, and by anything else that needs Linux/GNU.
#
# Usage:
#   docker/run.sh <cmd> [args...]
#
# Examples:
#   docker/run.sh bash -lc 'cp --version'
#   docker/run.sh bash -lc 'cd /work/runs/cp/<sid>/round_01/impl && cargo build --release'

set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
TAG="formal-verification:trixie"

# --rm: ephemeral container per invocation (no leftover stopped containers).
# -v: bind-mount the repo at /work. Read-write by default; tests under
#     /work/runs/... must write back to the host.
# --network=none: disabled. The image needs network during build (apt, rustup,
#     cargo install); at runtime we want it OFF for test isolation, but
#     cargo tarpaulin sometimes resolves crates.io if Cargo.lock is stale.
#     We leave network ON for now and rely on the impl being self-contained.
# -w /work: matches the WORKDIR baked into the image but explicit here in
#     case someone overrides via docker run --workdir.
exec docker run --rm \
    -v "$REPO":/work \
    -w /work \
    "$TAG" "$@"
