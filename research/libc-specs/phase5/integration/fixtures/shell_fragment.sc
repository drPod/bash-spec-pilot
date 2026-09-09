// Exit-status composition of the phase3 shell fragment (`;`, `&&`, `||`)
// expressed as functions over statuses in the pinned spec language.
attribute stdout : string
uninterpreted concat(a : string, b : string) -> string

fn and_then(a : i64, b : i64) -> i64 {
  if a == 0 { return b; } else { return a; }
}

fn or_else(a : i64, b : i64) -> i64 {
  if a == 0 { return a; } else { return b; }
}

fn mark(status : i64) -> i64 {
  if status == 0 { stdout = concat(stdout, "!"); }
  return 0;
}
