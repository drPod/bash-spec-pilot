type byte = u8

struct buffer { cap : u64, len : u64, bytes : list::<u8> }

enum io_result { ok(u64), eof(), error(i64) }

exception ReadError(i64)

attribute delivered : list::<u8>

local attribute pending : list::<u8>

element fd(i64)

uninterpreted length(list::<u8>) -> u64

fn relay(cap : u64) -> i64 {

}

fn shutdown() -> void {

}