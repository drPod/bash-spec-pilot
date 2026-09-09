// short_circuit.sc (calculus-resume-2, 2026-09-07): real short-circuit `&&`/`||` in the v2
// lowering: skipped traps (division by zero), skipped and taken action operands,
// left-to-right effect order, and the relay-style compound assert.
attribute count : i64

fn bump() -> bool { count = count + 1; return true; }
fn bump_false() -> bool { count = count + 1; return false; }

fn sc_skip_trap_and() -> i64 { if false && ((1 / 0) == 0) { return 1; } return 0; }
fn sc_skip_trap_or() -> i64 { if true || ((1 / 0) == 0) { return 1; } return 0; }
fn sc_eval_trap_and() -> i64 { if true && ((1 / 0) == 0) { return 1; } return 0; }
fn sc_eval_trap_or() -> i64 { if false || ((1 % 0) == 0) { return 1; } return 0; }
fn sc_action_skipped() -> i64 { count = 0; let r = false && bump(); return count; }
fn sc_action_taken() -> i64 { count = 0; let r = true && bump(); if r { return count; } return -1; }
fn sc_or_action_skipped() -> i64 { count = 0; let r = true || bump(); return count; }
fn sc_or_action_taken() -> i64 { count = 0; let r = false || bump_false(); if r { return -1; } return count; }
fn sc_left_to_right() -> i64 { count = 0; let r = bump() && bump_false() && bump(); if r { return -1; } return count; }
fn sc_nested_or_and() -> i64 { count = 0; let r = (bump_false() || bump()) && bump(); if r { return count; } return -1; }
fn sc_relay_style_assert() -> i64 { let off = 3; let n = 5; assert off <= n && n <= 10; return 1; }
fn sc_assert_fails_skips_trap() -> i64 { let n = 5; assert n <= 3 && ((1 / 0) == 0); return 1; }
fn sc_not_and() -> i64 { if !(false && ((1 / 0) == 0)) { return 1; } return 0; }
