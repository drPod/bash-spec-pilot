// Declarations only, plus functions with empty bodies: the pinned semantic
// analysis handles these without reaching the unimplemented expression checker.
type byte = u8
struct buffer { cap : u64, len : u64, bytes : list::<u8> }
enum io_result { ok (n : u64), eof, error (code : i64) }
exception ReadError(code : i64)
attribute delivered : list::<u8>
local attribute pending : list::<u8>
element fd(n : int)
uninterpreted length(xs : list::<u8>) -> u64
fn relay(cap : u64) -> i64 { }
fn shutdown() { }
