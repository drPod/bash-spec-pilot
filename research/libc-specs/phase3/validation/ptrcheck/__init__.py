"""Pointer-event validation of frozen phase2 relay.c, independent of relaycheck; see TRACE_SCHEMA.md."""

# sha256 of research/libc-specs/phase2/relay.c, frozen 2026-09-07 (identical to phase2's constant,
# recomputed independently with sha256sum before this package was written).
FROZEN_RELAY_SHA256 = "c5abc06f53474d90ff7927aa485a03316e267fe758593a411f70a6d22f1afe68"

CAPACITY = 32          # unsigned char buf[32]
READ_FD = 0
WRITE_FD = 1
SCHEMA = "pointer-relay-trace/1"

__version__ = "0.1.0"
