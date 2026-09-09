// C-style for loop and brackets are not in the pinned grammar.
fn count(n : i64) -> i64 {
  let total = 0;
  for (i = 0; i < n; i = i + 1) { total = total + i; }
  return total;
}
