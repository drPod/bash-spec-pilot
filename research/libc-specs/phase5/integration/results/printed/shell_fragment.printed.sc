attribute stdout : string

uninterpreted concat(string, string) -> string

fn and_then(a : i64, b : i64) -> i64 {
  if a == 0i64 {
    return b;
  } else {
    return a;
  }
}

fn or_else(a : i64, b : i64) -> i64 {
  if a == 0i64 {
    return a;
  } else {
    return b;
  }
}

fn mark(status : i64) -> i64 {
  if status == 0i64 {
    stdout = concat(stdout, "!");
  } else {

  }
  return 0i64;
}