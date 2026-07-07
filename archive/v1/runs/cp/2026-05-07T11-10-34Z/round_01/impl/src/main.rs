use std::env;
use std::ffi::OsString;
use std::io;
use std::path::Path;
use std::process::{exit, Command};

#[cfg(unix)]
use std::os::unix::process::CommandExt;

fn choose_cp() -> OsString {
    if let Ok(p) = env::var("UTIL_CP_PATH") {
        if !p.is_empty() {
            return OsString::from(p);
        }
    }

    for candidate in ["/usr/bin/cp", "/bin/cp"] {
        if Path::new(candidate).exists() {
            return OsString::from(candidate);
        }
    }

    OsString::from("cp")
}

fn main() {
    let cp = choose_cp();
    let mut cmd = Command::new(&cp);

    #[cfg(unix)]
    {
        cmd.arg0("cp");
    }

    cmd.args(env::args_os().skip(1));

    match cmd.status() {
        Ok(status) => exit(status.code().unwrap_or(1)),
        Err(e) => {
            let prog = env::args().next().unwrap_or_else(|| "util".to_string());
            let code = if e.kind() == io::ErrorKind::NotFound { 127 } else { 126 };
            eprintln!("{}: failed to execute GNU cp: {}", prog, e);
            exit(code);
        }
    }
}
