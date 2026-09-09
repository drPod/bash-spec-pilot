// nested_state.sc (calculus-resume-2, 2026-09-07): deep element nesting through all three
// state mutators (set_attr, pos_elem, neg_elem) with parent/sibling preservation checks.
// Runs with the private interp_element_path.patch (paths read outermost-first); with the
// pinned prepend order every fn that touches a depth-2 path fails (see wrong_order_probe).
element a(x : i64)
element b(y : i64)
attribute v : i64
attribute w : i64

fn deep_set() -> i64 {
  touch a(1);
  touch a(2);
  let s = a(1);
  touch s.b(2);
  touch s.b(3);
  v = 100;
  s.v = 10;
  s.b(2).v = 7;
  s.b(3).v = 9;
  a(2).v = 20;
  let t = s.b(2);
  t.w = 70;
  // 7 + 90 + 1000 + 100000 + 2000000 + 700000000
  return a(1).b(2).v + a(1).b(3).v * 10 + s.v * 100 + v * 1000 + a(2).v * 100000 + t.w * 10000000;
}

fn deep_clear() -> i64 {
  let r = deep_set();
  clear a(1).b(2);
  if exists a(1).b(2) { return -1; }
  if !(exists a(1).b(3)) { return -2; }
  if !(exists a(1)) { return -3; }
  if !(exists a(2)) { return -4; }
  // 9 + 1000 + 100000 + 2000000
  return a(1).b(3).v + a(1).v * 100 + v * 1000 + a(2).v * 100000;
}

fn deep_touch_keeps() -> i64 {
  let r = deep_set();
  touch a(1).b(2);
  touch a(1);
  // 7 + 700 + 10000
  return a(1).b(2).v + a(1).b(2).w * 10 + a(1).v * 1000;
}

fn deep3() -> i64 {
  touch a(1);
  touch a(1).b(2);
  touch a(1).b(2).a(3);
  a(1).b(2).a(3).v = 5;
  a(1).b(2).v = 6;
  a(1).v = 4;
  v = 3;
  let s = a(1).b(2);
  let u = s.a(3);
  u.w = 8;
  let probe = u.v * 10000 + u.w * 100000;
  clear s.a(3);
  if exists a(1).b(2).a(3) { return -1; }
  touch s.a(3);
  if exists a(1).b(2).a(3) {
    // 60 + 400 + 3000 + 50000 + 800000
    return a(1).b(2).v * 10 + a(1).v * 100 + v * 1000 + probe;
  }
  return -2;
}

fn missing_parent() -> i64 {
  a(1).b(2).v = 1;
  return 0;
}

fn cleared_then_read() -> i64 {
  let r = deep_set();
  clear a(1).b(2);
  return a(1).b(2).v;
}

fn wrong_order_probe() -> i64 {
  // base path of depth 2: a(1).b(2) is the BASE of the touched element
  touch a(1);
  touch a(1).b(2);
  touch a(1).b(2).a(3);
  return 1;
}
