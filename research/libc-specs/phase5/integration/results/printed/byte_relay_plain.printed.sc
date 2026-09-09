type byte = u8

struct buffer { cap : u64, len : u64, bytes : list::<u8> }

enum io_result { ok(u64), eof(), error(i64) }

exception ReadError(i64)

attribute input : list::<u8>

attribute delivered : list::<u8>

element fd(i64)

uninterpreted empty_bytes() -> list::<u8>

uninterpreted length(list::<u8>) -> u64

uninterpreted take(u64) -> list::<u8>

uninterpreted drop(list::<u8>, u64) -> list::<u8>

uninterpreted read_chunk(u64) -> io_result

uninterpreted write_chunk(list::<u8>) -> io_result

fn relay(cap : u64) -> i64 {
  let status : i64 = 0i64;
  let pending = empty_bytes();
  let done = false;
  while ! done {
    let r = read_chunk(cap);
    match r {
      io_result::ok(n) => {
        pending = take(n);
      }
      io_result::eof() => {
        done = true;
      }
      io_result::error(code) => {
        raise ReadError(code);
      }
      _ => {

      }
    }
    while length(pending) > 0i64 {
      let w = write_chunk(pending);
      match w {
        io_result::ok(n) => {
          pending = drop(pending, n);
        }
        _ => {
          status = 1i64;
          done = true;
          pending = empty_bytes();
        }
      }
    }
  }
  return status;
}