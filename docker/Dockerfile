# GNU oracle + Rust toolchain image for the formal-verification experiment.
#
# Why this image exists:
#   The experiment targets Linux/GNU userland (see decisions.md §1). Running
#   tests against BSD `/bin/cp` on a macOS dev box silently uses the wrong
#   oracle and corrupts every per-test result. This image is the deterministic
#   GNU oracle: coreutils, findutils, sudo at the exact Debian-trixie package
#   versions pinned in scripts/freeze_manpage.sh, plus a Rust toolchain so
#   `cargo build` and `cargo tarpaulin` run against the same userland the
#   tests run against.
#
# Tag (built by docker/build.sh): formal-verification:trixie
#
# Pinning rationale:
#   - debian:trixie-20260421-slim is a date-stamped digest tag (most recent
#     trixie-slim as of 2026-05-07). debian:trixie-slim alone floats; we want
#     reproducibility on re-runs months from now.
#   - coreutils/findutils/sudo apt-pinned to the trixie versions referenced
#     by scripts/freeze_manpage.sh (9.7-3, 4.10.0-3, 1.9.16p2-3+deb13u1).
#     Apt will install whatever trixie currently ships; if Debian rotates,
#     `apt-get install` will pick the newer version and the build will note
#     a mismatch in the version-check step below. That's a visible Debian
#     event we re-pin against (same convention as freeze_manpage.sh).
#   - rustup is fetched at a specific commit-equivalent install date is
#     not pinnable via the public installer. We accept that drift here -
#     stable-channel rust is not the source-of-truth in this image; the
#     GNU coreutils versions are.

FROM debian:trixie-20260421-slim

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PATH=/root/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Layer 1: GNU userland (the actual oracle). Pin versions to match the
# manpage-freeze script. apt-get install with =VERSION will fail loudly if
# Debian has rotated the package, surfacing the drift instead of hiding it.
#
# coreutils ships /usr/bin/cp, /usr/bin/mv (for the cp+mv tests).
# findutils ships /usr/bin/find.
# sudo ships /usr/bin/sudo.
#
# Extras: bash, mandoc (for `man cp` parity inside the container if anyone
# wants to read a man page from the same source the freeze script used),
# curl (for one-off fetches), ca-certificates (for HTTPS), build-essential
# (cargo crates with C deps - filetime, libc, etc.).
# Two tiers of pinning:
#   Tier A (the GNU oracle): coreutils, findutils, sudo are version-pinned to
#     the Debian-trixie versions referenced by scripts/freeze_manpage.sh.
#     These are the source of truth for differential testing — drift here
#     would mean the man page and the oracle no longer match.
#   Tier B (image hygiene): bash, mandoc, curl, ca-certificates, build-essential,
#     pkg-config, libssl-dev, python3*, git intentionally NOT version-pinned.
#     These rotate within trixie point-releases (e.g. 8.14.1-2 -> 8.14.1-2+deb13u2)
#     for security updates without changing the userland under test. Pinning
#     them tightly produces fragile builds without buying anything we measure.
RUN apt-get update && apt-get install -y --no-install-recommends \
        coreutils=9.7-3 \
        findutils=4.10.0-3 \
        sudo=1.9.16p2-3+deb13u1 \
        bash \
        mandoc \
        curl \
        ca-certificates \
        build-essential \
        pkg-config \
        libssl-dev \
        python3 \
        python3-pip \
        python3-venv \
        git \
    && rm -rf /var/lib/apt/lists/*

# Smoke check: print the versions we actually got. If they don't match the
# pin in freeze_manpage.sh, the build still proceeds (apt-get already
# arbitrated), but the layer cache will record what was installed.
RUN cp --version | head -1 \
    && find --version | head -1 \
    && sudo --version | head -1 \
    && bash --version | head -1 \
    && python3 --version

# Layer 2: Rust toolchain. Stable channel; no version pin — we want the
# tarpaulin coverage tool to keep working as crates/rustc move forward.
# Re-running this layer once a quarter is fine; coverage numbers don't
# require deterministic rustc.
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
        sh -s -- -y --default-toolchain stable --profile minimal \
    && rustc --version \
    && cargo --version

# Layer 3: cargo-tarpaulin for branch/line coverage. Build from crates.io
# rather than apt — Debian doesn't package it, and the binary is the
# preferred install path per the tarpaulin README.
# --locked ensures Cargo.lock-driven reproducibility for the install itself.
RUN cargo install cargo-tarpaulin --locked \
    && cargo tarpaulin --version

# Layer 4: project working directory. Mounted at runtime via docker/run.sh.
WORKDIR /work

# Default command is bash so `docker run -it formal-verification:trixie`
# drops the user into a shell. Real invocations go through docker/run.sh.
CMD ["/bin/bash"]
