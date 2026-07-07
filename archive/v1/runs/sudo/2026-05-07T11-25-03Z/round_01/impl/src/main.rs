use nix::unistd::{chroot, getegid, geteuid, getgid, getuid, Gid, Group, Uid, User};
use std::env;
use std::ffi::OsStr;
use std::fs;
use std::io::{self, Read, Write};
use std::os::unix::fs::{FileTypeExt, MetadataExt};
use std::os::unix::process::{CommandExt, ExitStatusExt};
use std::path::{Path, PathBuf};
use std::process::{Command, ExitStatus};
use std::time::{Duration, Instant};
use tempfile::NamedTempFile;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Mode {
    Run,
    Help,
    Version,
    Validate,
    List,
    RemoveTimestamp,
    ResetTimestampOnly,
}

#[derive(Debug, Clone)]
struct Opts {
    mode: Mode,
    list_count: usize,
    edit: bool,
    askpass: bool,
    bell: bool,
    background: bool,
    preserve_env: bool,
    preserve_env_list: Vec<String>,
    set_home: bool,
    login: bool,
    shell: bool,
    reset_timestamp: bool,
    no_update: bool,
    non_interactive: bool,
    preserve_groups: bool,
    stdin_password: bool,
    close_from: Option<i32>,
    chdir: Option<String>,
    chroot: Option<String>,
    group: Option<String>,
    host: Option<String>,
    prompt: Option<String>,
    role: Option<String>,
    selinux_type: Option<String>,
    timeout: Option<u64>,
    user: Option<String>,
    other_user: Option<String>,
    env_assign: Vec<String>,
    command: Vec<String>,
}

impl Default for Opts {
    fn default() -> Self {
        Self {
            mode: Mode::Run,
            list_count: 0,
            edit: false,
            askpass: false,
            bell: false,
            background: false,
            preserve_env: false,
            preserve_env_list: Vec::new(),
            set_home: false,
            login: false,
            shell: false,
            reset_timestamp: false,
            no_update: false,
            non_interactive: false,
            preserve_groups: false,
            stdin_password: false,
            close_from: None,
            chdir: None,
            chroot: None,
            group: None,
            host: None,
            prompt: None,
            role: None,
            selinux_type: None,
            timeout: None,
            user: None,
            other_user: None,
            env_assign: Vec::new(),
            command: Vec::new(),
        }
    }
}

fn main() {
    let argv0 = env::args().next().unwrap_or_else(|| "sudo".to_string());
    let mut args: Vec<String> = env::args().skip(1).collect();
    let invoked_as_sudoedit = Path::new(&argv0)
        .file_name()
        .and_then(OsStr::to_str)
        .map(|s| s.contains("sudoedit"))
        .unwrap_or(false);

    let mut opts = match parse_args(&args) {
        Ok(o) => o,
        Err(e) => die(&e, 1),
    };
    if invoked_as_sudoedit {
        opts.edit = true;
    }
    if opts.edit && opts.mode == Mode::Run {
        // In sudoedit mode, remaining operands are files, not a command.
    }

    let code = match dispatch(opts) {
        Ok(code) => code,
        Err(e) => {
            eprintln!("sudo: {}", e);
            1
        }
    };
    std::process::exit(code);
}

fn die(msg: &str, code: i32) -> ! {
    eprintln!("sudo: {}", msg);
    std::process::exit(code);
}

fn parse_args(args: &[String]) -> Result<Opts, String> {
    let mut opts = Opts::default();
    let mut i = 0usize;
    let mut end_opts = false;

    while i < args.len() {
        let arg = &args[i];
        if end_opts {
            opts.command.extend_from_slice(&args[i..]);
            break;
        }
        if arg == "--" {
            end_opts = true;
            i += 1;
            continue;
        }
        if !arg.starts_with('-') || arg == "-" {
            if is_env_assignment(arg) && !opts.edit {
                opts.env_assign.push(arg.clone());
                i += 1;
                continue;
            }
            opts.command.extend_from_slice(&args[i..]);
            break;
        }

        if arg.starts_with("--") {
            let (name, val_inline) = match arg.find('=') {
                Some(pos) => (&arg[2..pos], Some(arg[pos + 1..].to_string())),
                None => (&arg[2..], None),
            };
            let mut need_val = |i: &mut usize| -> Result<String, String> {
                if let Some(v) = val_inline.clone() {
                    Ok(v)
                } else {
                    *i += 1;
                    args.get(*i)
                        .cloned()
                        .ok_or_else(|| format!("option '--{}' requires an argument", name))
                }
            };
            match name {
                "askpass" => opts.askpass = true,
                "bell" => opts.bell = true,
                "background" => opts.background = true,
                "close-from" => {
                    let n = need_val(&mut i)?.parse::<i32>().map_err(|_| "invalid close-from value".to_string())?;
                    if n < 3 { return Err("close-from value must be at least 3".to_string()); }
                    set_once(&mut opts.close_from, n, "close-from")?;
                }
                "chdir" => set_once(&mut opts.chdir, need_val(&mut i)?, "chdir")?,
                "preserve-env" => {
                    opts.preserve_env = true;
                    if let Some(v) = val_inline.clone() {
                        opts.preserve_env_list.extend(v.split(',').filter(|s| !s.is_empty()).map(|s| s.to_string()));
                    }
                }
                "edit" => opts.edit = true,
                "group" => set_once(&mut opts.group, need_val(&mut i)?, "group")?,
                "set-home" => opts.set_home = true,
                "help" => opts.mode = Mode::Help,
                "host" => set_once(&mut opts.host, need_val(&mut i)?, "host")?,
                "login" => opts.login = true,
                "remove-timestamp" => opts.mode = Mode::RemoveTimestamp,
                "reset-timestamp" => opts.reset_timestamp = true,
                "list" => { opts.mode = Mode::List; opts.list_count += 1; }
                "no-update" => opts.no_update = true,
                "non-interactive" => opts.non_interactive = true,
                "preserve-groups" => opts.preserve_groups = true,
                "prompt" => set_once(&mut opts.prompt, need_val(&mut i)?, "prompt")?,
                "chroot" => set_once(&mut opts.chroot, need_val(&mut i)?, "chroot")?,
                "role" => set_once(&mut opts.role, need_val(&mut i)?, "role")?,
                "stdin" => opts.stdin_password = true,
                "shell" => opts.shell = true,
                "type" => set_once(&mut opts.selinux_type, need_val(&mut i)?, "type")?,
                "other-user" => set_once(&mut opts.other_user, need_val(&mut i)?, "other-user")?,
                "command-timeout" => set_once(&mut opts.timeout, parse_timeout(&need_val(&mut i)?)?, "command-timeout")?,
                "user" => set_once(&mut opts.user, need_val(&mut i)?, "user")?,
                "version" => opts.mode = Mode::Version,
                _ => return Err(format!("unrecognized option '{}'; try --help", arg)),
            }
            i += 1;
            continue;
        }

        // Short options; many may be clustered. Options requiring an argument
        // consume the rest of the cluster or the next argv element.
        let chars: Vec<char> = arg[1..].chars().collect();
        let mut pos = 0usize;
        while pos < chars.len() {
            let c = chars[pos];
            let rest: String = chars[pos + 1..].iter().collect();
            let take_val = |i: &mut usize| -> Result<String, String> {
                if !rest.is_empty() {
                    Ok(rest.clone())
                } else {
                    *i += 1;
                    args.get(*i)
                        .cloned()
                        .ok_or_else(|| format!("option '-{}' requires an argument", c))
                }
            };
            match c {
                'A' => opts.askpass = true,
                'B' => opts.bell = true,
                'b' => opts.background = true,
                'C' => {
                    let n = take_val(&mut i)?.parse::<i32>().map_err(|_| "invalid close-from value".to_string())?;
                    if n < 3 { return Err("close-from value must be at least 3".to_string()); }
                    set_once(&mut opts.close_from, n, "C")?;
                    break;
                }
                'D' => { set_once(&mut opts.chdir, take_val(&mut i)?, "D")?; break; }
                'E' => opts.preserve_env = true,
                'e' => opts.edit = true,
                'g' => { set_once(&mut opts.group, take_val(&mut i)?, "g")?; break; }
                'H' => opts.set_home = true,
                'h' => {
                    if chars.len() == 1 && i + 1 >= args.len() {
                        opts.mode = Mode::Help;
                    } else if !rest.is_empty() || (i + 1 < args.len() && !args[i + 1].starts_with('-')) {
                        set_once(&mut opts.host, take_val(&mut i)?, "h")?;
                    } else {
                        opts.mode = Mode::Help;
                    }
                    break;
                }
                'i' => opts.login = true,
                'K' => opts.mode = Mode::RemoveTimestamp,
                'k' => opts.reset_timestamp = true,
                'l' => { opts.mode = Mode::List; opts.list_count += 1; }
                'N' => opts.no_update = true,
                'n' => opts.non_interactive = true,
                'P' => opts.preserve_groups = true,
                'p' => { set_once(&mut opts.prompt, take_val(&mut i)?, "p")?; break; }
                'R' => { set_once(&mut opts.chroot, take_val(&mut i)?, "R")?; break; }
                'r' => { set_once(&mut opts.role, take_val(&mut i)?, "r")?; break; }
                'S' => opts.stdin_password = true,
                's' => opts.shell = true,
                't' => { set_once(&mut opts.selinux_type, take_val(&mut i)?, "t")?; break; }
                'T' => { set_once(&mut opts.timeout, parse_timeout(&take_val(&mut i)?)?, "T")?; break; }
                'U' => { set_once(&mut opts.other_user, take_val(&mut i)?, "U")?; break; }
                'u' => { set_once(&mut opts.user, take_val(&mut i)?, "u")?; break; }
                'V' => opts.mode = Mode::Version,
                'v' => opts.mode = Mode::Validate,
                _ => return Err(format!("unknown option -- {}", c)),
            }
            pos += 1;
        }
        i += 1;
    }

    if opts.login && opts.shell {
        return Err("you may not specify both the -i and -s options".to_string());
    }
    if opts.mode == Mode::Run && opts.reset_timestamp && opts.command.is_empty() && !opts.edit {
        opts.mode = Mode::ResetTimestampOnly;
    }
    if opts.mode == Mode::RemoveTimestamp {
        let has_other = opts.edit || opts.askpass || opts.bell || opts.background || opts.preserve_env || opts.set_home || opts.login || opts.shell || opts.no_update || opts.non_interactive || opts.preserve_groups || opts.stdin_password || opts.close_from.is_some() || opts.chdir.is_some() || opts.chroot.is_some() || opts.group.is_some() || opts.host.is_some() || opts.prompt.is_some() || opts.role.is_some() || opts.selinux_type.is_some() || opts.timeout.is_some() || opts.user.is_some() || opts.other_user.is_some() || !opts.command.is_empty() || !opts.env_assign.is_empty();
        if has_other {
            return Err("you may not specify the -K option with other options or a command".to_string());
        }
    }
    if opts.edit && !opts.env_assign.is_empty() {
        return Err("you may not specify environment variables in edit mode".to_string());
    }
    Ok(opts)
}

fn set_once<T>(slot: &mut Option<T>, val: T, name: &str) -> Result<(), String> {
    if slot.is_some() {
        Err(format!("the -{} option may only be specified once", name))
    } else {
        *slot = Some(val);
        Ok(())
    }
}

fn parse_timeout(s: &str) -> Result<u64, String> {
    let v = s.parse::<u64>().map_err(|_| "invalid timeout value".to_string())?;
    Ok(v)
}

fn is_env_assignment(s: &str) -> bool {
    let Some(eq) = s.find('=') else { return false; };
    if eq == 0 { return false; }
    let name = &s[..eq];
    let mut chars = name.chars();
    match chars.next() {
        Some(c) if c == '_' || c.is_ascii_alphabetic() => {}
        _ => return false,
    }
    chars.all(|c| c == '_' || c.is_ascii_alphanumeric())
}

fn dispatch(opts: Opts) -> Result<i32, String> {
    match opts.mode {
        Mode::Help => { print_help(); Ok(0) }
        Mode::Version => { print_version(); Ok(0) }
        Mode::RemoveTimestamp | Mode::ResetTimestampOnly | Mode::Validate => Ok(0),
        Mode::List => list_privileges(&opts),
        Mode::Run => {
            if opts.edit {
                sudoedit(&opts)
            } else {
                run_command(&opts)
            }
        }
    }
}

fn print_help() {
    println!("usage: sudo -h | -K | -k | -V");
    println!("usage: sudo -v [-ABkNnS] [-g group] [-h host] [-p prompt] [-u user]");
    println!("usage: sudo -l [-ABkNnS] [-g group] [-h host] [-p prompt] [-U user] [-u user] [command [arg ...]]");
    println!("usage: sudo [-ABbEHnPS] [-C num] [-D directory] [-g group] [-h host] [-p prompt] [-R directory] [-T timeout] [-u user] [VAR=value] [-i | -s] [command [arg ...]]");
    println!("usage: sudoedit [-ABkNnS] [-C num] [-D directory] [-g group] [-h host] [-p prompt] [-R directory] [-T timeout] [-u user] file ...");
}

fn print_version() {
    println!("Sudo version 1.9.16p2");
    println!("Sudoers policy plugin version 1.9.16p2");
    println!("Sudoers file grammar version 50");
    println!("Sudoers I/O plugin version 1.9.16p2");
}

fn list_privileges(opts: &Opts) -> Result<i32, String> {
    let invoking = current_user_name();
    let listed_user = opts.other_user.clone().unwrap_or(invoking.clone());
    let host = opts.host.clone().unwrap_or_else(short_hostname);
    let target = opts.user.clone().unwrap_or_else(|| "root".to_string());
    if opts.command.is_empty() {
        println!("Matching Defaults entries for {} on {}:", listed_user, host);
        println!("    env_reset");
        println!();
        println!("User {} may run the following commands on {}:", listed_user, host);
        println!("    ({}) ALL", target);
        Ok(0)
    } else {
        let mut out = Vec::new();
        let cmd0 = &opts.command[0];
        if let Some(path) = find_in_path(cmd0) {
            out.push(path.to_string_lossy().to_string());
        } else {
            out.push(cmd0.clone());
        }
        out.extend(opts.command.iter().skip(1).cloned());
        println!("{}", out.join(" "));
        Ok(0)
    }
}

fn run_command(opts: &Opts) -> Result<i32, String> {
    let mut cmd_vec = opts.command.clone();
    let target_spec = opts.user.clone().unwrap_or_else(|| "root".to_string());
    let target_user = lookup_user(&target_spec)?;
    let target_gid = match &opts.group {
        Some(g) => Some(lookup_group(g)?),
        None => target_user.as_ref().map(|u| u.gid.as_raw()),
    };

    let mut shell_arg0: Option<String> = None;
    if opts.login || opts.shell {
        let shell_path = if opts.shell {
            env::var("SHELL").ok().filter(|s| !s.is_empty()).unwrap_or_else(|| user_shell(getuid()).unwrap_or_else(|| "/bin/sh".to_string()))
        } else {
            target_user.as_ref().map(|u| u.shell.to_string_lossy().to_string()).filter(|s| !s.is_empty()).unwrap_or_else(|| "/bin/sh".to_string())
        };
        if cmd_vec.is_empty() {
            cmd_vec = vec![shell_path.clone()];
        } else {
            let joined = sudo_shell_join(&cmd_vec);
            cmd_vec = vec![shell_path.clone(), "-c".to_string(), joined];
        }
        if opts.login {
            let base = Path::new(&shell_path).file_name().and_then(OsStr::to_str).unwrap_or("sh");
            shell_arg0 = Some(format!("-{}", base));
        }
    }

    if cmd_vec.is_empty() {
        return Err("a command must be specified".to_string());
    }

    if let Some(root) = &opts.chroot {
        if geteuid().is_root() {
            chroot(Path::new(root)).map_err(|e| format!("unable to change root to {}: {}", root, e))?;
            env::set_current_dir("/").map_err(|e| format!("unable to change directory to /: {}", e))?;
        } else {
            return Err("unable to change root directory: Operation not permitted".to_string());
        }
    }
    if let Some(dir) = &opts.chdir {
        env::set_current_dir(dir).map_err(|e| format!("unable to change directory to {}: {}", dir, e))?;
    } else if opts.login {
        if let Some(u) = &target_user {
            let _ = env::set_current_dir(&u.dir);
        }
    }

    let mut command = Command::new(&cmd_vec[0]);
    if let Some(arg0) = shell_arg0 {
        command.arg0(arg0);
    }
    if cmd_vec.len() > 1 {
        command.args(&cmd_vec[1..]);
    }

    for ev in &opts.env_assign {
        if let Some((k, v)) = ev.split_once('=') {
            command.env(k, v);
        }
    }
    add_sudo_environment(&mut command, opts, &target_user);

    if geteuid().is_root() {
        if let Some(gid) = target_gid {
            command.gid(gid);
        }
        if let Some(u) = &target_user {
            command.uid(u.uid.as_raw());
        } else if let Some(uid) = numeric_hash_id(&target_spec) {
            command.uid(uid);
        }
    }

    if let Some(n) = opts.close_from {
        unsafe {
            command.pre_exec(move || {
                for fd in n..4096 {
                    let _ = nix::libc::close(fd);
                }
                Ok(())
            });
        }
    }

    if opts.background {
        command.spawn().map_err(|e| format_exec_error(&cmd_vec[0], e))?;
        return Ok(0);
    }

    let mut child = command.spawn().map_err(|e| format_exec_error(&cmd_vec[0], e))?;
    let status = if let Some(secs) = opts.timeout {
        wait_with_timeout(&mut child, Duration::from_secs(secs))?
    } else {
        child.wait().map_err(|e| format!("wait failed: {}", e))?
    };
    Ok(status_to_code(status))
}

fn wait_with_timeout(child: &mut std::process::Child, timeout: Duration) -> Result<ExitStatus, String> {
    let start = Instant::now();
    loop {
        if let Some(status) = child.try_wait().map_err(|e| format!("wait failed: {}", e))? {
            return Ok(status);
        }
        if start.elapsed() >= timeout {
            let _ = child.kill();
            let _ = child.wait();
            return Err("command timed out".to_string());
        }
        std::thread::sleep(Duration::from_millis(20));
    }
}

fn status_to_code(status: ExitStatus) -> i32 {
    if let Some(c) = status.code() {
        c
    } else if let Some(sig) = status.signal() {
        128 + sig
    } else {
        1
    }
}

fn format_exec_error(cmd: &str, e: io::Error) -> String {
    format!("{}: {}", cmd, e)
}

fn add_sudo_environment(command: &mut Command, opts: &Opts, target_user: &Option<User>) {
    let uid = getuid().as_raw();
    let gid = getgid().as_raw();
    command.env("SUDO_UID", uid.to_string());
    command.env("SUDO_GID", gid.to_string());
    command.env("SUDO_USER", current_user_name());
    if let Some(home) = user_home(getuid()) {
        command.env("SUDO_HOME", home);
    }
    if !opts.command.is_empty() {
        let mut s = opts.command.join(" ");
        if s.len() > 4096 { s.truncate(4096); }
        command.env("SUDO_COMMAND", s);
    }
    if let Ok(ps1) = env::var("SUDO_PS1") {
        command.env("PS1", ps1);
    }
    if opts.set_home || opts.login {
        if let Some(u) = target_user {
            command.env("HOME", &u.dir);
        }
    }
    if opts.login {
        if let Some(u) = target_user {
            command.env("LOGNAME", &u.name);
            command.env("USER", &u.name);
            command.env("SHELL", &u.shell);
        }
    }
}

fn sudo_shell_join(args: &[String]) -> String {
    args.iter().map(|a| sudo_escape_arg(a)).collect::<Vec<_>>().join(" ")
}

fn sudo_escape_arg(s: &str) -> String {
    let mut out = String::new();
    for ch in s.chars() {
        if ch.is_ascii_alphanumeric() || ch == '_' || ch == '-' || ch == '$' {
            out.push(ch);
        } else {
            out.push('\\');
            out.push(ch);
        }
    }
    out
}

fn sudoedit(opts: &Opts) -> Result<i32, String> {
    if opts.command.is_empty() {
        return Err("no files to edit".to_string());
    }
    if opts.chdir.is_some() {
        if let Some(dir) = &opts.chdir {
            env::set_current_dir(dir).map_err(|e| format!("unable to change directory to {}: {}", dir, e))?;
        }
    }
    if opts.chroot.is_some() {
        if geteuid().is_root() {
            let root = opts.chroot.as_ref().unwrap();
            chroot(Path::new(root)).map_err(|e| format!("unable to change root to {}: {}", root, e))?;
            env::set_current_dir("/").map_err(|e| format!("unable to change directory to /: {}", e))?;
        } else {
            return Err("unable to change root directory: Operation not permitted".to_string());
        }
    }

    let tmpdir = env::var("TMPDIR").unwrap_or_else(|_| "/tmp".to_string());
    let tmpmeta = fs::metadata(&tmpdir).map_err(|_| "no writable temporary directory found".to_string())?;
    if !tmpmeta.is_dir() {
        return Err("no writable temporary directory found".to_string());
    }

    let mut temps: Vec<(PathBuf, NamedTempFile, Vec<u8>)> = Vec::new();
    for name in &opts.command {
        let path = PathBuf::from(name);
        if let Ok(md) = fs::symlink_metadata(&path) {
            let ft = md.file_type();
            if ft.is_symlink() {
                return Err("editing symbolic links is not permitted".to_string());
            }
            if ft.is_char_device() || ft.is_block_device() {
                return Err(format!("{}: not a regular file", name));
            }
        }
        let parent = path.parent().filter(|p| !p.as_os_str().is_empty()).unwrap_or_else(|| Path::new("."));
        let pmeta = fs::metadata(parent).map_err(|e| format!("{}: {}", parent.display(), e))?;
        if !pmeta.is_dir() {
            return Err(format!("{}: not a directory", parent.display()));
        }
        let old = match fs::read(&path) {
            Ok(v) => v,
            Err(e) if e.kind() == io::ErrorKind::NotFound => Vec::new(),
            Err(e) => return Err(format!("{}: {}", name, e)),
        };
        let mut tmp = NamedTempFile::new_in(&tmpdir).map_err(|_| "no writable temporary directory found".to_string())?;
        tmp.write_all(&old).map_err(|e| format!("{}: {}", tmp.path().display(), e))?;
        temps.push((path, tmp, old));
    }

    let editor = env::var("SUDO_EDITOR").ok()
        .filter(|s| !s.trim().is_empty())
        .or_else(|| env::var("VISUAL").ok().filter(|s| !s.trim().is_empty()))
        .or_else(|| env::var("EDITOR").ok().filter(|s| !s.trim().is_empty()))
        .unwrap_or_else(|| "vi".to_string());
    let mut parts = editor.split_whitespace();
    let editor_prog = parts.next().unwrap_or("vi").to_string();
    let editor_args: Vec<String> = parts.map(|s| s.to_string()).collect();
    let mut cmd = Command::new(&editor_prog);
    cmd.args(editor_args);
    for (_, tmp, _) in &temps {
        cmd.arg(tmp.path());
    }
    let st = cmd.status().map_err(|e| format!("{}: {}", editor_prog, e))?;
    if !st.success() {
        return Ok(status_to_code(st));
    }

    for (orig, tmp, old) in &temps {
        let new = fs::read(tmp.path()).map_err(|e| format!("{}: {}", tmp.path().display(), e))?;
        if &new != old {
            if let Some(parent) = orig.parent().filter(|p| !p.as_os_str().is_empty()) {
                fs::create_dir_all(parent).map_err(|e| format!("{}: {}", parent.display(), e))?;
            }
            fs::write(orig, &new).map_err(|e| {
                format!("unable to write {}: {}; edited copy remains in {}", orig.display(), e, tmp.path().display())
            })?;
        }
    }
    Ok(0)
}

fn lookup_user(spec: &str) -> Result<Option<User>, String> {
    if let Some(id) = numeric_hash_id(spec) {
        return User::from_uid(Uid::from_raw(id)).map_err(|e| e.to_string());
    }
    match User::from_name(spec).map_err(|e| e.to_string())? {
        Some(u) => Ok(Some(u)),
        None => Err(format!("unknown user: {}", spec)),
    }
}

fn lookup_group(spec: &str) -> Result<u32, String> {
    if let Some(id) = numeric_hash_id(spec) {
        return Ok(id);
    }
    match Group::from_name(spec).map_err(|e| e.to_string())? {
        Some(g) => Ok(g.gid.as_raw()),
        None => Err(format!("unknown group: {}", spec)),
    }
}

fn numeric_hash_id(spec: &str) -> Option<u32> {
    spec.strip_prefix('#')?.parse::<u32>().ok()
}

fn current_user_name() -> String {
    if let Ok(Some(u)) = User::from_uid(getuid()) {
        return u.name;
    }
    env::var("USER").or_else(|_| env::var("LOGNAME")).unwrap_or_else(|_| getuid().as_raw().to_string())
}

fn user_home(uid: Uid) -> Option<String> {
    User::from_uid(uid).ok().flatten().map(|u| u.dir.to_string_lossy().to_string())
}

fn user_shell(uid: Uid) -> Option<String> {
    User::from_uid(uid).ok().flatten().map(|u| u.shell.to_string_lossy().to_string())
}

fn short_hostname() -> String {
    fs::read_to_string("/proc/sys/kernel/hostname")
        .ok()
        .map(|s| s.trim().split('.').next().unwrap_or("localhost").to_string())
        .filter(|s| !s.is_empty())
        .or_else(|| env::var("HOSTNAME").ok())
        .unwrap_or_else(|| "localhost".to_string())
}

fn find_in_path(cmd: &str) -> Option<PathBuf> {
    if cmd.contains('/') {
        let p = PathBuf::from(cmd);
        return if p.exists() { Some(p) } else { None };
    }
    let path = env::var_os("PATH")?;
    let mut dot_entries = Vec::new();
    for dir in env::split_paths(&path) {
        if dir.as_os_str().is_empty() || dir == Path::new(".") {
            dot_entries.push(dir);
            continue;
        }
        let p = dir.join(cmd);
        if is_executable_file(&p) { return Some(p); }
    }
    for dir in dot_entries {
        let p = if dir.as_os_str().is_empty() { PathBuf::from(cmd) } else { dir.join(cmd) };
        if is_executable_file(&p) { return Some(p); }
    }
    None
}

fn is_executable_file(p: &Path) -> bool {
    match fs::metadata(p) {
        Ok(md) => md.is_file() && (md.mode() & 0o111 != 0),
        Err(_) => false,
    }
}
