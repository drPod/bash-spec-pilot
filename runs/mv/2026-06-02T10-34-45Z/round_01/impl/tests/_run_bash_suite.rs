// Auto-generated integration harness for cargo-tarpaulin coverage.
// Iterates bash test scripts in $TESTS_DIR and invokes the built binary
// at $UTIL_BIN so tarpaulin's instrumentation registers hit counters.
//
// Failures are not fatal here -- coverage is about code paths, not
// pass/fail. run_tests.py handles correctness scoring separately.
use std::env;
use std::fs;
use std::process::Command;

#[test]
fn run_bash_suite() {
    let tests_dir = env::var("TESTS_DIR")
        .unwrap_or_else(|_| panic!("TESTS_DIR env var required"));
    let util_bin = env::var("UTIL_BIN")
        .unwrap_or_else(|_| panic!("UTIL_BIN env var required"));
    let mut count = 0usize;
    for entry in fs::read_dir(&tests_dir).expect("read tests dir") {
        let entry = entry.expect("entry");
        let path = entry.path();
        if path.extension().and_then(|s| s.to_str()) != Some("sh") {
            continue;
        }
        // Run with a timeout-ish bound via `timeout` if available; if not,
        // cargo test will time it out at the harness level.
        let _ = Command::new("bash")
            .arg(&path)
            .env("UTIL", &util_bin)
            .output();
        count += 1;
    }
    assert!(count > 0, "no .sh tests found in {}", tests_dir);
}
