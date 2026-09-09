// Typed byte-buffer relay protocol written in the pinned spec language.
// Mirrors the phase2/phase3 relay: bounded reads into a private buffer, retried
// writes at the offset, routine syscall outcomes as typed data, error as exception.
type byte = u8

struct buffer {
  cap : u64,
  len : u64,
  bytes : list::<u8>,
}

enum io_result {
  ok (n : u64),
  eof,
  error (code : i64),
}

exception ReadError(code : i64)

attribute input : list::<u8>
attribute delivered : list::<u8>
element fd(n : int)

uninterpreted empty_bytes() -> list::<u8>
uninterpreted length(xs : list::<u8>) -> u64
uninterpreted take(n : u64) -> list::<u8>
uninterpreted drop(xs : list::<u8>, n : u64) -> list::<u8>
uninterpreted read_chunk(cap : u64) -> io_result
uninterpreted write_chunk(xs : list::<u8>) -> io_result

fn relay(cap : u64) -> i64 {
  let status : i64 = 0;
  let pending = empty_bytes();
  let done = false;
  while !done {
    let r = read_chunk(cap);
    match r {
      io_result::ok(n) => { pending = take(n); }
      io_result::eof => { done = true; }
      io_result::error(code) => { raise ReadError(code); }
    }
    while length(pending) > 0u64 {
      let w = write_chunk(pending);
      match w {
        io_result::ok(n) => { pending = drop(pending, n); }
        _ => { status = 1; done = true; pending = empty_bytes(); }
      }
    }
  }
  return status;
}
