use std::env;
use std::ffi::CString;
use std::fs::{self, File};
use std::io::{self, Write};
use std::os::unix::fs::FileTypeExt;
use std::os::unix::process::{CommandExt, ExitStatusExt};
use std::path::{Path, PathBuf};
use std::process::{Command, ExitStatus};
use std::thread;
use std::time::{Duration, Instant};
use users::os::unix::{GroupExt, UserExt};

#[derive(Default, Debug)]
struct Opts {
    askpass: bool,
    background: bool,
    bell: bool,
    close_from: Option<i32>,
    chdir: Option<String>,
    chroot: Option<String>,
    edit: bool,
    group: Option<String>,
    help: bool,
    host: Option<String>,
    list: u32,
    login: bool,
    non_interactive: bool,
    preserve_env: bool,
    preserve_env_names: Vec<String>,
    preserve_groups: bool,
    prompt: Option<String>,
    remove_timestamp: bool,
    reset_timestamp: bool,
    role: Option<String>,
    shell: bool,
    stdin: bool,
    timeout: Option<u64>,
    ty: Option<String>,
    user: Option<String>,
    other_user: Option<String>,
    validate: bool,
    version: bool,
    no_update: bool,
    envs: Vec<(String, String)>,
    command: Vec<String>,
}

fn main() {
    let argv0 = env::args().next().unwrap_or_else(|| "sudo".to_string());
    let mut args: Vec<String> = env::args().skip(1).collect();
    let mut opts = match parse_args(&mut args, argv0.contains("sudoedit")) {
        Ok(o) => o,
        Err(e) => {
            eprintln!("sudo: {}", e);
            std::process::exit(1);
        }
    };

    if opts.help {
        print_help();
        return;
    }
    if opts.version {
        println!("Sudo version 1.9.16p2");
        println!("Sudoers policy plugin version 1.9.16p2");
        return;
    }
    if opts.remove_timestamp {
        if has_operational_option_with_k(&opts) || !opts.command.is_empty() {
            eprintln!("sudo: you may not specify -K with other options");
            std::process::exit(1);
        }
        return;
    }
    if opts.reset_timestamp && opts.command.is_empty() && !opts.validate && opts.list == 0 && !opts.edit {
        return;
    }
    if opts.validate && opts.command.is_empty() && opts.list == 0 && !opts.edit {
        return;
    }
    if opts.list > 0 {
        list_privileges(&opts);
        return;
    }
    if opts.edit {
        let code = run_sudoedit(&opts);
        std::process::exit(code);
    }

    if opts.command.is_empty() {
        eprintln!("usage: sudo [-h] [-V] [-v] [-l] [-k|-K] [-u user] [-g group] command");
        std::process::exit(1);
    }

    let code = run_command(&mut opts);
    std::process::exit(code);
}

fn has_operational_option_with_k(o: &Opts) -> bool {
    o.askpass || o.background || o.bell || o.close_from.is_some() || o.chdir.is_some() ||
    o.chroot.is_some() || o.group.is_some() || o.host.is_some() || o.login || o.non_interactive ||
    o.preserve_env || !o.preserve_env_names.is_empty() || o.preserve_groups || o.prompt.is_some() ||
    o.role.is_some() || o.shell || o.stdin || o.timeout.is_some() || o.ty.is_some() ||
    o.user.is_some() || o.other_user.is_some() || o.validate || o.no_update
}

fn parse_args(args: &mut Vec<String>, sudoedit: bool) -> Result<Opts, String> {
    let mut o = Opts::default();
    o.edit = sudoedit;
    let mut i = 0usize;
    while i < args.len() {
        let a = args[i].clone();
        if a == "--" {
            i += 1;
            break;
        }
        if !a.starts_with('-') || a == "-" {
            if let Some((k, v)) = parse_assignment(&a) {
                o.envs.push((k, v));
                i += 1;
                continue;
            }
            break;
        }
        if a.starts_with("--") {
            let (name, val) = if let Some(p) = a.find('=') { (&a[2..p], Some(a[p+1..].to_string())) } else { (&a[2..], None) };
            match name {
                "askpass" => o.askpass = true,
                "background" => o.background = true,
                "bell" => o.bell = true,
                "close-from" => o.close_from = Some(parse_i32_value(name, val, args, &mut i)?),
                "chdir" => o.chdir = Some(take_value(name, val, args, &mut i)?),
                "chroot" => o.chroot = Some(take_value(name, val, args, &mut i)?),
                "edit" => o.edit = true,
                "group" => o.group = Some(take_value(name, val, args, &mut i)?),
                "help" => o.help = true,
                "host" => o.host = Some(take_value(name, val, args, &mut i)?),
                "list" => o.list += 1,
                "login" => o.login = true,
                "non-interactive" => o.non_interactive = true,
                "no-update" => o.no_update = true,
                "preserve-env" => {
                    if let Some(v) = val {
                        validate_preserve_env_list(&v)?;
                        o.preserve_env_names.extend(v.split(',').map(|s| s.to_string()));
                    } else {
                        o.preserve_env = true;
                    }
                }
                "preserve-groups" => o.preserve_groups = true,
                "prompt" => o.prompt = Some(take_value(name, val, args, &mut i)?),
                "remove-timestamp" => o.remove_timestamp = true,
                "reset-timestamp" => o.reset_timestamp = true,
                "role" => o.role = Some(take_value(name, val, args, &mut i)?),
                "shell" => o.shell = true,
                "stdin" => o.stdin = true,
                "type" => o.ty = Some(take_value(name, val, args, &mut i)?),
                "command-timeout" => o.timeout = Some(parse_u64_value(name, val, args, &mut i)?),
                "user" => o.user = Some(take_value(name, val, args, &mut i)?),
                "other-user" => o.other_user = Some(take_value(name, val, args, &mut i)?),
                "validate" => o.validate = true,
                "version" => o.version = true,
                _ => return Err(format!("unrecognized option '--{}'", name)),
            }
            i += 1;
            continue;
        }

        let chars: Vec<char> = a[1..].chars().collect();
        let mut j = 0usize;
        while j < chars.len() {
            let c = chars[j];
            match c {
                'A' => o.askpass = true,
                'B' => o.bell = true,
                'b' => o.background = true,
                'E' => o.preserve_env = true,
                'e' => o.edit = true,
                'H' => { /* handled when building environment */ }
                'K' => o.remove_timestamp = true,
                'k' => o.reset_timestamp = true,
                'l' => o.list += 1,
                'N' => o.no_update = true,
                'n' => o.non_interactive = true,
                'P' => o.preserve_groups = true,
                'S' => o.stdin = true,
                'i' => o.login = true,
                's' => o.shell = true,
                'V' => o.version = true,
                'v' => o.validate = true,
                'h' => {
                    if chars.len() == 1 && i + 1 >= args.len() {
                        o.help = true;
                    } else {
                        o.host = Some(short_value(&chars, &mut j, args, &mut i, "h")?);
                    }
                }
                'C' => o.close_from = Some(short_value(&chars, &mut j, args, &mut i, "C")?.parse().map_err(|_| "invalid close-from value".to_string())?),
                'D' => o.chdir = Some(short_value(&chars, &mut j, args, &mut i, "D")?),
                'g' => o.group = Some(short_value(&chars, &mut j, args, &mut i, "g")?),
                'p' => o.prompt = Some(short_value(&chars, &mut j, args, &mut i, "p")?),
                'R' => o.chroot = Some(short_value(&chars, &mut j, args, &mut i, "R")?),
                'r' => o.role = Some(short_value(&chars, &mut j, args, &mut i, "r")?),
                't' => o.ty = Some(short_value(&chars, &mut j, args, &mut i, "t")?),
                'T' => o.timeout = Some(short_value(&chars, &mut j, args, &mut i, "T")?.parse().map_err(|_| "invalid timeout value".to_string())?),
                'U' => o.other_user = Some(short_value(&chars, &mut j, args, &mut i, "U")?),
                'u' => o.user = Some(short_value(&chars, &mut j, args, &mut i, "u")?),
                _ => return Err(format!("invalid option -- '{}'", c)),
            }
            j += 1;
        }
        i += 1;
    }
    if let Some(n) = o.close_from {
        if n < 3 { return Err("the close-from value must be at least 3".to_string()); }
    }
    if o.login && o.shell { return Err!("you may not specify both the -i and -s options".to_string()); }
    o.command = args[i..].to_vec();
    if o.edit && !o.envs.is_empty() {
        return Err("you may not specify environment variables in edit mode".to_string());
    }
    Ok(o)
}

macro_rules! Err { ($e:expr) => { return Err($e) }; }

fn take_value(name: &str, val: Option<String>, args: &[String], i: &mut usize) -> Result<String, String> {
    if let Some(v) = val { return Ok(v); }
    *i += 1;
    args.get(*i).cloned().ok_or_else(|| format!("option '--{}' requires an argument", name))
}
fn parse_i32_value(name: &str, val: Option<String>, args: &[String], i: &mut usize) -> Result<i32, String> {
    take_value(name, val, args, i)?.parse().map_err(|_| format!("invalid value for --{}", name))
}
fn parse_u64_value(name: &str, val: Option<String>, args: &[String], i: &mut usize) -> Result<u64, String> {
    take_value(name, val, args, i)?.parse().map_err(|_| format!("invalid value for --{}", name))
}
fn short_value(chars: &[char], j: &mut usize, args: &[String], i: &mut usize, opt: &str) -> Result<String, String> {
    if *j + 1 < chars.len() {
        let v: String = chars[*j + 1..].iter().collect();
        *j = chars.len();
        Ok(v)
    } else {
        *i += 1;
        args.get(*i).cloned().ok_or_else(|| format!("option -{} requires an argument", opt))
    }
}

fn valid_env_name(s: &str) -> bool {
    let mut ch = s.chars();
    match ch.next() { Some(c) if c == '_' || c.is_ascii_alphabetic() => (), _ => return false }
    ch.all(|c| c == '_' || c.is_ascii_alphanumeric())
}
fn validate_preserve_env_list(v: &str) -> Result<(), String> {
    for name in v.split(',') {
        if !valid_env_name(name) {
            return Err("invalid environment variable name".to_string());
        }
    }
    Ok(())
}
fn parse_assignment(s: &str) -> Option<(String, String)> {
    let p = s.find('=')?;
    let k = &s[..p];
    if valid_env_name(k) { Some((k.to_string(), s[p+1..].to_string())) } else { None }
}

fn print_help() {
    println!("usage: sudo -h | -K | -k | -V");
    println!("usage: sudo -v [-ABkNnS] [-g group] [-h host] [-p prompt] [-u user]");
    println!("usage: sudo -l [-ABkNnS] [-g group] [-h host] [-p prompt] [-U user] [-u user] [command]");
    println!("usage: sudo [-ABbEHnPS] [-C num] [-D directory] [-g group] [-h host] [-p prompt] [-R directory] [-T timeout] [-u user] [VAR=value] [-i|-s] [command]");
}

fn current_user_name() -> String {
    let uid = unsafe { libc::getuid() };
    users::get_user_by_uid(uid).map(|u| u.name().to_string_lossy().into_owned()).unwrap_or_else(|| uid.to_string())
}
fn current_home() -> String {
    let uid = unsafe { libc::getuid() };
    users::get_user_by_uid(uid).map(|u| u.home_dir().to_string_lossy().into_owned()).unwrap_or_else(|| "/".to_string())
}

struct Target { uid: u32, gid: u32, name: String, home: String, shell: String }

fn resolve_target(o: &Opts) -> Result<Target, String> {
    let cur_uid = unsafe { libc::getuid() };
    let cur_gid = unsafe { libc::getgid() };
    let spec = if let Some(u) = &o.user { Some(u.clone()) } else if o.group.is_some() { None } else { Some("root".to_string()) };
    let (uid, mut gid, name, home, shell) = if let Some(s) = spec {
        if let Some(rest) = s.strip_prefix('#') {
            let uid: u32 = rest.parse().map_err(|_| format!("unknown user: {}", s))?;
            if let Some(u) = users::get_user_by_uid(uid) {
                (uid, u.primary_group_id(), u.name().to_string_lossy().into_owned(), u.home_dir().to_string_lossy().into_owned(), u.shell().to_string_lossy().into_owned())
            } else {
                (uid, cur_gid, s, "/".to_string(), "/bin/sh".to_string())
            }
        } else if let Some(u) = users::get_user_by_name(&s) {
            (u.uid(), u.primary_group_id(), u.name().to_string_lossy().into_owned(), u.home_dir().to_string_lossy().into_owned(), u.shell().to_string_lossy().into_owned())
        } else { return Err(format!("unknown user: {}", s)); }
    } else {
        let u = users::get_user_by_uid(cur_uid);
        (cur_uid, cur_gid, u.as_ref().map(|x| x.name().to_string_lossy().into_owned()).unwrap_or_else(|| cur_uid.to_string()), u.as_ref().map(|x| x.home_dir().to_string_lossy().into_owned()).unwrap_or_else(|| "/".to_string()), u.as_ref().map(|x| x.shell().to_string_lossy().into_owned()).unwrap_or_else(|| "/bin/sh".to_string()))
    };
    if let Some(g) = &o.group {
        gid = if let Some(rest) = g.strip_prefix('#') { rest.parse().map_err(|_| format!("unknown group: {}", g))? }
              else if let Some(gr) = users::get_group_by_name(g) { gr.gid() }
              else { return Err(format!("unknown group: {}", g)); };
    }
    Ok(Target { uid, gid, name, home, shell })
}

fn list_privileges(o: &Opts) {
    let user = o.other_user.clone().unwrap_or_else(current_user_name);
    if o.command.is_empty() {
        println!("User {} may run the following commands on this host:", user);
        println!("    (ALL : ALL) ALL");
    } else {
        println!("{}", o.command.join(" "));
    }
}

fn shell_join(args: &[String]) -> String {
    let mut out = String::new();
    for (idx, a) in args.iter().enumerate() {
        if idx > 0 { out.push(' '); }
        for c in a.chars() {
            if c.is_ascii_alphanumeric() || c == '_' || c == '-' || c == '$' { out.push(c); }
            else { out.push('\\'); out.push(c); }
        }
    }
    out
}

fn run_command(o: &mut Opts) -> i32 {
    let target = match resolve_target(o) { Ok(t) => t, Err(e) => { eprintln!("sudo: {}", e); return 1; } };
    let (program, argv, login_shell) = if o.login || o.shell {
        let sh = if o.login { target.shell.clone() } else { env::var("SHELL").ok().filter(|s| !s.is_empty()).unwrap_or_else(|| target.shell.clone()) };
        if o.command.is_empty() { (sh, Vec::new(), o.login) } else { (sh, vec!["-c".to_string(), shell_join(&o.command)], o.login) }
    } else {
        (o.command[0].clone(), o.command[1..].to_vec(), false)
    };

    let mut cmd = Command::new(&program);
    if login_shell {
        let base = Path::new(&program).file_name().unwrap_or_default().to_string_lossy();
        cmd.arg0(format!("-{}", base));
    }
    cmd.args(&argv);
    for (k, v) in &o.envs { cmd.env(k, v); }
    let inv_uid = unsafe { libc::getuid() };
    let inv_gid = unsafe { libc::getgid() };
    cmd.env("SUDO_UID", inv_uid.to_string());
    cmd.env("SUDO_GID", inv_gid.to_string());
    cmd.env("SUDO_USER", current_user_name());
    cmd.env("SUDO_HOME", current_home());
    cmd.env("SUDO_COMMAND", if o.command.is_empty() { program.clone() } else { o.command.join(" ") });
    if o.login {
        cmd.env("HOME", &target.home);
        cmd.env("LOGNAME", &target.name);
        cmd.env("USER", &target.name);
        cmd.env("SHELL", &target.shell);
    }
    if let Ok(ps1) = env::var("SUDO_PS1") { cmd.env("PS1", ps1); }

    let uid = target.uid;
    let gid = target.gid;
    let close_from = o.close_from;
    let chdir = o.chdir.clone();
    let chroot = o.chroot.clone();
    unsafe {
        cmd.pre_exec(move || {
            if let Some(root) = &chroot {
                let c = CString::new(root.as_str()).map_err(|_| io::Error::new(io::ErrorKind::InvalidInput, "bad chroot"))?;
                if libc::chroot(c.as_ptr()) != 0 { return Err(io::Error::last_os_error()); }
                let slash = CString::new("/").unwrap();
                if libc::chdir(slash.as_ptr()) != 0 { return Err(io::Error::last_os_error()); }
            }
            if let Some(dir) = &chdir {
                let c = CString::new(dir.as_str()).map_err(|_| io::Error::new(io::ErrorKind::InvalidInput, "bad directory"))?;
                if libc::chdir(c.as_ptr()) != 0 { return Err(io::Error::last_os_error()); }
            }
            if let Some(n) = close_from {
                let max = libc::sysconf(libc::_SC_OPEN_MAX);
                let max = if max > 0 { max as i32 } else { 1024 };
                for fd in n..max { libc::close(fd); }
            }
            if libc::setgid(gid as libc::gid_t) != 0 { return Err(io::Error::last_os_error()); }
            if libc::setuid(uid as libc::uid_t) != 0 { return Err(io::Error::last_os_error()); }
            Ok(())
        });
    }

    let mut child = match cmd.spawn() {
        Ok(c) => c,
        Err(e) => { eprintln!("sudo: {}: {}", program, e); return 1; }
    };
    if o.background { return 0; }
    let status = if let Some(t) = o.timeout {
        wait_with_timeout(&mut child, t)
    } else {
        child.wait().unwrap_or_else(|_| fake_failure())
    };
    status_to_code(status)
}

fn wait_with_timeout(child: &mut std::process::Child, secs: u64) -> ExitStatus {
    let start = Instant::now();
    loop {
        if let Ok(Some(s)) = child.try_wait() { return s; }
        if start.elapsed() >= Duration::from_secs(secs) {
            let _ = child.kill();
            return child.wait().unwrap_or_else(|_| fake_failure());
        }
        thread::sleep(Duration::from_millis(25));
    }
}
fn fake_failure() -> ExitStatus { Command::new("/bin/false").status().unwrap() }
fn status_to_code(s: ExitStatus) -> i32 {
    if let Some(c) = s.code() { c } else if let Some(sig) = s.signal() { 128 + sig } else { 1 }
}

fn shell_quote(s: &str) -> String {
    let mut out = String::from("'");
    for c in s.chars() {
        if c == '\'' { out.push_str("'\\''"); } else { out.push(c); }
    }
    out.push('\'');
    out
}

fn run_sudoedit(o: &Opts) -> i32 {
    if o.command.is_empty() {
        eprintln!("sudoedit: no files specified");
        return 1;
    }
    for f in &o.command {
        if let Ok(md) = fs::symlink_metadata(f) {
            let ft = md.file_type();
            if ft.is_symlink() { eprintln!("sudoedit: {}: editing symbolic links is not permitted", f); return 1; }
            if ft.is_char_device() || ft.is_block_device() { eprintln!("sudoedit: {}: not a regular file", f); return 1; }
        }
    }
    let mut temps: Vec<(String, PathBuf, Vec<u8>)> = Vec::new();
    for f in &o.command {
        let old = fs::read(f).unwrap_or_default();
        let mut tmp = match tempfile::NamedTempFile::new() {
            Ok(t) => t,
            Err(_) => { eprintln!("sudoedit: no writable temporary directory found"); return 1; }
        };
        if tmp.write_all(&old).is_err() { eprintln!("sudoedit: unable to write temporary file"); return 1; }
        let (_file, path) = match tmp.keep() { Ok(x) => x, Err(_) => { eprintln!("sudoedit: unable to preserve temporary file"); return 1; } };
        temps.push((f.clone(), path, old));
    }
    let editor = env::var("SUDO_EDITOR").or_else(|_| env::var("VISUAL")).or_else(|_| env::var("EDITOR")).unwrap_or_else(|_| "vi".to_string());
    let mut script = editor;
    for (_, p, _) in &temps { script.push(' '); script.push_str(&shell_quote(&p.to_string_lossy())); }
    let status = Command::new("/bin/sh").arg("-c").arg(script).status();
    match status { Ok(s) if s.success() => (), Ok(s) => return status_to_code(s), Err(e) => { eprintln!("sudoedit: unable to run editor: {}", e); return 1; } }
    for (orig, tmp, old) in &temps {
        let new = fs::read(tmp).unwrap_or_default();
        if &new != old {
            if let Some(parent) = Path::new(orig).parent() { let _ = fs::create_dir_all(parent); }
            if let Err(e) = fs::write(orig, &new) { eprintln!("sudoedit: {}: {}", orig, e); return 1; }
        }
        let _ = fs::remove_file(tmp);
    }
    0
}
