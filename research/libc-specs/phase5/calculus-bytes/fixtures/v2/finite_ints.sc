// finite_ints.sc (calculus-resume-2, 2026-09-07): the adapter's explicit finite-integer
// semantics: 63-bit carrier with trapping overflow (no wraparound), truncating division,
// declared widths enforced as range assertions at annotated lets, attribute assignments,
// fn parameters and returns. Every fn is a unit case; expected outcomes in check_v2.py.
type byte = u8
attribute small : u8
attribute big : i64

fn carrier_max() -> i64 { return 4611686018427387903; }
fn overflow_add() -> i64 { let m = 4611686018427387903; return m + 1; }
fn overflow_sub() -> i64 { let m = -4611686018427387903; return m - 2; }
fn overflow_mul() -> i64 { let m = 3037000500; return m * m; }
fn overflow_neg() -> i64 { let m = -4611686018427387903; let n = m - 1; return -n; }
fn div_trunc() -> i64 { let a = -7; return a / 2; }
fn mod_sign() -> i64 { let a = -7; return a % 2; }
fn div_zero() -> i64 { let a = 7; let z = 0; return a / z; }
fn u8_ok() -> i64 { small = 255; return small; }
fn u8_overflow_runtime() -> i64 { let x = 200; small = x + 100; return small; }
fn u8_local_annot() -> i64 { let x : u8 = 200; let y : u8 = x + 55; return y; }
fn u8_local_annot_trap() -> i64 { let x : u8 = 200; let y : u8 = x + 56; return y; }
fn u8_param(b : byte) -> i64 { return b; }
fn u8_param_ok() -> i64 { return u8_param(255); }
fn u8_param_trap() -> i64 { let x = 256; return u8_param(x); }
fn u64_negative_trap() -> i64 { let x : u64 = 0; let z = x - 1; x = z; return x; }
fn ret_u8_trap() -> u8 { let x = 300; return x; }
fn ret_u8_ok() -> u8 { let x = 255; return x; }
fn typed_literal_widths() -> i64 { let a : u8 = 255u8; let b : i8 = -127i8 - 1; let c : u16 = 65535u16; return a + b + c; }
fn big_attr() -> i64 { big = -4611686018427387903 - 1; return big; }
fn char_lit() -> i64 { let c : u8 = '!'; return c; }
