// scope_ok.sc (calculus-resume-2, 2026-09-07): block scoping accepted by the v2 lowering:
// a name declared in a branch/loop body may be redeclared after the block; each branch may
// declare the same name; catch variables are scoped to the handler.
exception E(code : i64)
attribute count : i64

fn branch_lets() -> i64 { let r = 0; if true { let x = 1; r = x; } else { let x = 2; r = x; } let x = 5; return r + x; }
fn loop_let() -> i64 { let i = 0; let acc = 0; while i < 3 { let d = i * 2; acc = acc + d; i = i + 1; } return acc; }
fn catch_scope() -> i64 { try { raise E(4) } catch E(c) { return c; } return -1; }
fn finally_runs() -> i64 { count = 0; try { count = count + 1; } finally { count = count + 10; } return count; }
fn uncaught_is_raise() -> i64 { raise E(9) }
fn partial_effects_survive_raise() -> i64 { count = 0; try { count = 5; raise E(1) } catch E(c) { return count + c; } return -1; }
