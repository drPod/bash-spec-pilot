// Semantic errors the pinned analyzer is expected to report without exceptions.
type byte = u8
type byte = u16
struct buffer { cap : missing_type, len : u64 }
enum io_result { ok (n : u64), eof }
exception ReadError(code : i64)
exception ReadError(code : i64)
fn dup(a : i64, a : i64) -> i64 { }
fn wrong(x : list::<nothere>) -> pair::<u8> { }
