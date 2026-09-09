// byte_relay_exec.sc -- EXECUTABLE byte relay in the pinned spec language
// (calculus-bytes worker, 2026-09-07). Distinct from the illustrative parse
// fixture ../../integration/fixtures/byte_relay_plain.sc, which raises on read
// error and returns 1 on write failure and is NOT a faithful relay model.
//
// Semantics are pinned to the frozen C relay (phase2/relay.c) through the Coq
// protocol model (phase5/relay/Protocol.v read32/write_block, Reach.v):
//   read action < 0 (error)        -> relay returns 1; bytes already delivered stay delivered
//   read returns 0 (EOF)           -> relay returns 0
//   write ret <= 0 (error or zero) -> relay returns 2; the unwritten suffix of the
//                                     chunk is appended to `lost` (Shell.v ledger)
//   otherwise the write loop retries at offset off + ret over the initialized region.
// Schedules: `reads`/`writes` hold the pending actions; an empty schedule means the
// default action (capacity for reads, the request length for writes). Every read
// consumes one action, every write consumes one action, as in Protocol.v.
// Integers are untyped here (see MAPPING.md); byte values are range-checked by the
// list builtins.

type byte = u8

attribute input : list::<u8>       // unread stream, consumed from the front
attribute delivered : list::<u8>   // output stream
attribute lost : list::<u8>        // pending bytes discarded at relay exit
attribute reads : list::<i64>
attribute writes : list::<i64>
attribute read_calls : i64
attribute write_calls : i64

element block(id : int)            // the single allocation, indexed by block identity
attribute cap : u64                // capacity (32 for the relay)
attribute len : u64                // initialized length
attribute bytes : list::<u8>       // initialized contents, length == len

uninterpreted length(xs : list::<u8>) -> u64
uninterpreted take(xs : list::<u8>, n : u64) -> list::<u8>
uninterpreted drop(xs : list::<u8>, n : u64) -> list::<u8>
uninterpreted slice(xs : list::<u8>, off : u64, n : u64) -> list::<u8>
uninterpreted append(xs : list::<u8>, ys : list::<u8>) -> list::<u8>
uninterpreted empty() -> list::<u8>
uninterpreted single(b : u8) -> list::<u8>
uninterpreted head_or(xs : list::<i64>, d : i64) -> i64
uninterpreted tail(xs : list::<i64>) -> list::<i64>
uninterpreted min(a : i64, b : i64) -> i64
uninterpreted max(a : i64, b : i64) -> i64

exception ReadError(code : i64)

// read(0, buf, cap): Protocol.read32 with the block's capacity as the request.
fn read_block(b : state) -> i64 {
  let q = head_or(reads, b.cap);
  reads = tail(reads);
  read_calls = read_calls + 1;
  if q < 0 { return -1; }
  let k = min(max(1, q), min(b.cap, length(input)));
  b.bytes = take(input, k);
  b.len = k;
  input = drop(input, k);
  return k;
}

// write(1, buf + off, n - off): Protocol.write_block on the initialized region [off, n).
fn write_block(b : state, off : u64, n : u64) -> i64 {
  assert off <= n;
  assert n <= b.len;
  let l = b.len;
  assert l <= b.cap;
  let req = slice(b.bytes, off, n);
  let q = head_or(writes, length(req));
  writes = tail(writes);
  write_calls = write_calls + 1;
  if q < 0 { return -1; }
  let k = min(q, length(req));
  delivered = append(delivered, take(req, k));
  return k;
}

// One relay invocation: fresh block state, then the read/drain loop of relay.c.
fn relay() -> i64 {
  clear block(0);
  touch block(0);
  let b = block(0);
  b.cap = 32;
  b.len = 0;
  b.bytes = empty();
  while true {
    let r = read_block(b);
    if r < 0 { return 1; }
    if r == 0 { return 0; }
    let off = 0;
    while off < r {
      let w = write_block(b, off, r);
      if w <= 0 {
        lost = append(lost, slice(b.bytes, off, r));
        return 2;
      }
      off = off + w;
    }
  }
}

// Same relay, but the read error is a raised exception carrying the
// interpreter state (partial effects) instead of a returned status.
fn relay_raising() -> i64 {
  clear block(0);
  touch block(0);
  let b = block(0);
  b.cap = 32;
  b.len = 0;
  b.bytes = empty();
  while true {
    let r = read_block(b);
    if r < 0 { raise ReadError(r) }
    if r == 0 { return 0; }
    let off = 0;
    while off < r {
      let w = write_block(b, off, r);
      if w <= 0 {
        lost = append(lost, slice(b.bytes, off, r));
        return 2;
      }
      off = off + w;
    }
  }
}

// The exception is caught and mapped back to status 1: must agree with relay().
fn relay_caught() -> i64 {
  try {
    let s = relay_raising();
    return s;
  } catch ReadError(code) {
    return 1;
  }
}

// One-byte marker process (Shell.v `Mark`, assumed successful write of '!').
fn mark() -> i64 {
  delivered = append(delivered, single(33));
  return 0;
}

// Shell compositions from the phase3 grammar, written in the source language.
fn relay_seq_relay() -> i64 {
  let a = relay();
  let c = relay();
  return c;
}

fn relay_and_mark() -> i64 {
  let rc = relay();
  if rc == 0 {
    let m = mark();
    return m;
  }
  return rc;
}

fn relay_or_mark() -> i64 {
  let rc = relay();
  if rc == 0 { return rc; }
  let m = mark();
  return m;
}
