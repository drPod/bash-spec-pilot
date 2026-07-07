// sudo(8) research stand-in. Implements the documented COMMAND-LINE surface
// from utils/sudo/manpage.txt: argument parsing for the common flags, plus the
// "run COMMAND as target user" path via the libc setuid/setgid family.
//
// What this is NOT: a security tool. There is no sudoers policy, no PAM, no
// password authentication, no credential cache, no plugin architecture, no pty
// monitor. Those are documented in _deps_rationale.txt as out-of-scope. The
// policy check here is the crudest possible approximation the man page allows
// ("the security policy determines what privileges, if any"): we permit the
// run if and only if our own effective UID is 0 (root), which is the state the
// test container runs us in. Where real sudo would consult a policy, we say so
// loudly rather than pretend.

use std::collections::BTreeMap;
use std::env;
use std::ffi::CString;
use std::process::Command;
use std::process::exit;

const SUDO_VERSION: &str = "Sudo version 1.9.16p2 (research stand-in)";

// Exit with the usage / config error code documented in EXIT VALUE: "a
// configuration/permission problem, or if the given command cannot be
// executed, sudo exits with a value of 1."
fn die(msg: &str) -> ! {
    eprintln!("sudo: {}", msg);
    exit(1);
}

#[derive(Default)]
struct Opts {
    // Target identity.
    user: Option<String>,         // -u / --user
    group: Option<String>,        // -g / --group
    list_other_user: Option<String>, // -U / --other-user (list mode only)

    // Environment handling.
    preserve_env: bool,           // -E / --preserve-env
    preserve_env_list: Vec<String>, // --preserve-env=list (comma-separated, repeatable)
    set_home: bool,               // -H / --set-home
    preserve_groups: bool,        // -P / --preserve-groups

    // Shell / login modes.
    login: bool,                  // -i / --login
    shell: bool,                  // -s / --shell

    // Interaction / credential-cache flags (mostly no-ops in this stand-in).
    non_interactive: bool,        // -n / --non-interactive
    askpass: bool,                // -A / --askpass
    bell: bool,                   // -B / --bell
    stdin: bool,                  // -S / --stdin
    no_update: bool,              // -N / --no-update
    reset_timestamp: bool,        // -k / --reset-timestamp
    background: bool,             // -b / --background

    // Action modes.
    validate: bool,               // -v / --validate
    list: u8,                     // -l / --list (count; verbose if >1)

    // Execution context.
    chdir: Option<String>,        // -D / --chdir
    prompt: Option<String>,       // -p / --prompt (recorded, unused: no auth)
    host: Option<String>,         // -h host / --host
    close_from: Option<i64>,      // -C / --close-from
    timeout: Option<String>,      // -T / --command-timeout (recorded, no enforce)

    // VAR=value environment assignments passed on the command line.
    env_assignments: Vec<(String, String)>,

    // The command and its arguments (after option processing).
    command: Vec<String>,
}

fn usage_short() {
    // Mirrors the SYNOPSIS shape from the man page closely enough to be a
    // recognizable help message; -h prints this to stdout and exits 0.
    println!(
        "usage: sudo -h | -K | -k | -V\n\
         usage: sudo -v [-ABkNnS] [-g group] [-h host] [-p prompt] [-u user]\n\
         usage: sudo -l [-ABkNnS] [-g group] [-h host] [-p prompt] [-U user] [-u user]\n\
         \x20            [command [arg ...]]\n\
         usage: sudo [-ABbEHnPS] [-C num] [-D directory] [-g group] [-h host]\n\
         \x20           [-p prompt] [-T timeout] [-u user] [VAR=value]\n\
         \x20           [-i | -s] [command [arg ...]]"
    );
}

// Parse a single short-option cluster like "-Hn" or a long option like
// "--user=root". Returns the remaining args consumed. We mutate `opts` in place
// and advance the iterator index `i` ourselves because some short options take
// an attached or following value.
fn parse_args(args: &[String]) -> Opts {
    let mut o = Opts::default();
    let mut i = 0usize;
    let mut end_of_opts = false;

    // Helper: pull the value for an option that needs one. Either it is
    // attached ("-uroot" / "--user=root") via `attached`, or it is the next
    // argv element.
    macro_rules! take_value {
        ($attached:expr, $i:expr, $optname:expr) => {{
            if let Some(v) = $attached {
                v
            } else {
                $i += 1;
                if $i >= args.len() {
                    die(&format!("option requires an argument -- '{}'", $optname));
                }
                args[$i].clone()
            }
        }};
    }

    while i < args.len() {
        let arg = &args[i];

        if end_of_opts {
            o.command.push(arg.clone());
            i += 1;
            continue;
        }

        if arg == "--" {
            // The -- delimits the end of sudo options; subsequent args belong
            // to the command.
            end_of_opts = true;
            i += 1;
            continue;
        }

        // Long options.
        if let Some(rest) = arg.strip_prefix("--") {
            let (name, attached) = match rest.split_once('=') {
                Some((n, v)) => (n, Some(v.to_string())),
                None => (rest, None),
            };
            match name {
                "user" => o.user = Some(take_value!(attached, i, "user")),
                "group" => o.group = Some(take_value!(attached, i, "group")),
                "other-user" => o.list_other_user = Some(take_value!(attached, i, "other-user")),
                "preserve-env" => match attached {
                    Some(list) => {
                        for v in list.split(',') {
                            if v.contains('=') {
                                die("invalid environment variable name");
                            }
                            o.preserve_env_list.push(v.to_string());
                        }
                    }
                    None => o.preserve_env = true,
                },
                "set-home" => o.set_home = true,
                "preserve-groups" => o.preserve_groups = true,
                "login" => o.login = true,
                "shell" => o.shell = true,
                "non-interactive" => o.non_interactive = true,
                "askpass" => o.askpass = true,
                "bell" => o.bell = true,
                "stdin" => o.stdin = true,
                "no-update" => o.no_update = true,
                "reset-timestamp" => o.reset_timestamp = true,
                "background" => o.background = true,
                "validate" => o.validate = true,
                "list" => o.list += 1,
                "chdir" => o.chdir = Some(take_value!(attached, i, "chdir")),
                "prompt" => o.prompt = Some(take_value!(attached, i, "prompt")),
                "host" => o.host = Some(take_value!(attached, i, "host")),
                "command-timeout" => o.timeout = Some(take_value!(attached, i, "command-timeout")),
                "close-from" => {
                    let v = take_value!(attached, i, "close-from");
                    match v.parse::<i64>() {
                        Ok(n) if n >= 3 => o.close_from = Some(n),
                        Ok(_) => die("the argument to -C must be a number greater than or equal to 3"),
                        Err(_) => die("the argument to -C must be a number greater than or equal to 3"),
                    }
                }
                "help" => {
                    usage_short();
                    exit(0);
                }
                "version" => {
                    println!("{}", SUDO_VERSION);
                    exit(0);
                }
                "remove-timestamp" => {
                    // -K: no credential cache exists in this stand-in. No-op, exit 0.
                    exit(0);
                }
                _ => die(&format!("unrecognized option '--{}'", name)),
            }
            i += 1;
            continue;
        }

        // Short option cluster.
        if arg.starts_with('-') && arg.len() > 1 {
            let bytes: Vec<char> = arg.chars().skip(1).collect();
            let mut j = 0usize;
            while j < bytes.len() {
                let c = bytes[j];
                // For value-taking short options, the value may be the rest of
                // this cluster (e.g. -uroot) or the next argv element.
                let attached_rest: Option<String> = if j + 1 < bytes.len() {
                    Some(bytes[j + 1..].iter().collect())
                } else {
                    None
                };
                match c {
                    // Boolean flags.
                    'E' => o.preserve_env = true,
                    'H' => o.set_home = true,
                    'P' => o.preserve_groups = true,
                    'i' => o.login = true,
                    's' => o.shell = true,
                    'n' => o.non_interactive = true,
                    'A' => o.askpass = true,
                    'B' => o.bell = true,
                    'S' => o.stdin = true,
                    'N' => o.no_update = true,
                    'k' => o.reset_timestamp = true,
                    'b' => o.background = true,
                    'v' => o.validate = true,
                    'l' => o.list += 1,
                    'K' => exit(0), // remove-timestamp: no cache here.
                    'h' => {
                        // Ambiguous in the man page: "-h" alone is help, but
                        // "-h host" takes a value. sudo resolves this by:
                        // bare -h (no attached/following non-option) = help.
                        // Here we treat -h as help only when it is the entire
                        // argument and not followed by a value-looking token;
                        // otherwise it consumes the host value.
                        if attached_rest.is_some() {
                            o.host = Some(attached_rest.clone().unwrap());
                            break;
                        } else if i + 1 < args.len() && !args[i + 1].starts_with('-') {
                            i += 1;
                            o.host = Some(args[i].clone());
                        } else {
                            usage_short();
                            exit(0);
                        }
                    }
                    'V' => {
                        println!("{}", SUDO_VERSION);
                        exit(0);
                    }
                    'u' => {
                        o.user = Some(take_value!(attached_rest.clone(), i, "u"));
                        break;
                    }
                    'g' => {
                        o.group = Some(take_value!(attached_rest.clone(), i, "g"));
                        break;
                    }
                    'U' => {
                        o.list_other_user = Some(take_value!(attached_rest.clone(), i, "U"));
                        break;
                    }
                    'D' => {
                        o.chdir = Some(take_value!(attached_rest.clone(), i, "D"));
                        break;
                    }
                    'p' => {
                        o.prompt = Some(take_value!(attached_rest.clone(), i, "p"));
                        break;
                    }
                    'T' => {
                        o.timeout = Some(take_value!(attached_rest.clone(), i, "T"));
                        break;
                    }
                    'C' => {
                        let v = take_value!(attached_rest.clone(), i, "C");
                        match v.parse::<i64>() {
                            Ok(n) if n >= 3 => o.close_from = Some(n),
                            _ => die("the argument to -C must be a number greater than or equal to 3"),
                        }
                        break;
                    }
                    other => die(&format!("invalid option -- '{}'", other)),
                }
                j += 1;
            }
            i += 1;
            continue;
        }

        // Not an option. Could be a VAR=value assignment (only valid before the
        // command begins) or the start of the command itself.
        if o.command.is_empty() && is_env_assignment(arg) {
            let (k, v) = arg.split_once('=').unwrap();
            o.env_assignments.push((k.to_string(), v.to_string()));
            i += 1;
            continue;
        }

        // First non-option, non-assignment token: the command begins here.
        // Everything from here on is part of the command (greedy).
        end_of_opts = true;
        o.command.push(arg.clone());
        i += 1;
    }

    o
}

// A VAR=value token: NAME=... where NAME is a valid shell-ish identifier (not
// starting with a digit, no '=' in the name). Mirrors the man page's "VAR=value"
// option form.
fn is_env_assignment(s: &str) -> bool {
    match s.split_once('=') {
        None => false,
        Some((name, _)) => {
            !name.is_empty()
                && !name.chars().next().unwrap().is_ascii_digit()
                && name.chars().all(|c| c.is_ascii_alphanumeric() || c == '_')
        }
    }
}

// ---- passwd/group database lookups via libc ----

struct PwInfo {
    uid: libc::uid_t,
    gid: libc::gid_t,
    name: String,
    dir: String,
    shell: String,
}

// Resolve a target user spec. Accepts "#NNN" (numeric UID) or a name.
fn resolve_user(spec: &str) -> PwInfo {
    if let Some(num) = spec.strip_prefix('#') {
        let uid: libc::uid_t = num
            .parse()
            .unwrap_or_else(|_| die(&format!("invalid user ID \"{}\"", spec)));
        // Try to enrich from the passwd db, but per the man page the sudoers
        // policy allows UIDs not in the database. If absent, synthesize.
        unsafe {
            let pw = libc::getpwuid(uid);
            if !pw.is_null() {
                return pwinfo_from_ptr(pw);
            }
        }
        return PwInfo {
            uid,
            gid: uid as libc::gid_t,
            name: format!("#{}", uid),
            dir: "/".to_string(),
            shell: "/bin/sh".to_string(),
        };
    }
    let cname = CString::new(spec).unwrap_or_else(|_| die("invalid user name"));
    unsafe {
        let pw = libc::getpwnam(cname.as_ptr());
        if pw.is_null() {
            die(&format!("unknown user {}", spec));
        }
        pwinfo_from_ptr(pw)
    }
}

unsafe fn pwinfo_from_ptr(pw: *const libc::passwd) -> PwInfo {
    let p = &*pw;
    PwInfo {
        uid: p.pw_uid,
        gid: p.pw_gid,
        name: cstr_to_string(p.pw_name),
        dir: cstr_to_string(p.pw_dir),
        shell: cstr_to_string(p.pw_shell),
    }
}

// Resolve a target group spec. Accepts "#NNN" or a group name. Returns GID.
fn resolve_group(spec: &str) -> libc::gid_t {
    if let Some(num) = spec.strip_prefix('#') {
        return num
            .parse()
            .unwrap_or_else(|_| die(&format!("invalid group ID \"{}\"", spec)));
    }
    let cname = CString::new(spec).unwrap_or_else(|_| die("invalid group name"));
    unsafe {
        let gr = libc::getgrnam(cname.as_ptr());
        if gr.is_null() {
            die(&format!("unknown group {}", spec));
        }
        (*gr).gr_gid
    }
}

unsafe fn cstr_to_string(p: *const libc::c_char) -> String {
    if p.is_null() {
        return String::new();
    }
    std::ffi::CStr::from_ptr(p).to_string_lossy().into_owned()
}

fn current_euid() -> libc::uid_t {
    unsafe { libc::geteuid() }
}

fn current_uid() -> libc::uid_t {
    unsafe { libc::getuid() }
}

// Look up the invoking user's name from the real UID, for SUDO_USER/LOGNAME.
fn invoking_user_name() -> String {
    let uid = current_uid();
    unsafe {
        let pw = libc::getpwuid(uid);
        if !pw.is_null() {
            return cstr_to_string((*pw).pw_name);
        }
    }
    format!("#{}", uid)
}

fn main() {
    let argv: Vec<String> = env::args().skip(1).collect();
    let opts = parse_args(&argv);

    // ---- Action modes that do not run a command ----

    // -v / --validate: real sudo would re-authenticate and extend the cached
    // credential timeout. There is no auth or cache here. The man page's exit
    // contract for -v is success if the user is allowed; we approximate
    // "allowed" as euid==0. Without a command, validate is terminal.
    if opts.validate && opts.command.is_empty() {
        if current_euid() != 0 {
            die("a password is required");
        }
        exit(0);
    }

    // -l / --list: list privileges. No sudoers policy to introspect, so we emit
    // a minimal documented-shape listing and exit per the EXIT VALUE rules.
    if opts.list > 0 {
        let who = opts
            .list_other_user
            .clone()
            .unwrap_or_else(invoking_user_name);
        if current_euid() != 0 {
            die("a password is required");
        }
        if opts.command.is_empty() {
            // List form. Real sudo prints the policy; we print a stand-in line.
            println!(
                "User {} may run the following commands on this host:",
                who
            );
            println!("    (ALL : ALL) ALL");
            exit(0);
        } else {
            // "command specified with -l": print the resolved path if found,
            // else exit 1 (command not permitted / not found).
            let cmd = &opts.command[0];
            match which(cmd) {
                Some(path) => {
                    let mut line = path;
                    for a in &opts.command[1..] {
                        line.push(' ');
                        line.push_str(a);
                    }
                    println!("{}", line);
                    exit(0);
                }
                None => exit(1),
            }
        }
    }

    // -k / -K with no command: just invalidate (no-op here), exit 0. The man
    // page: "This option does not require a password." -K already exited during
    // parsing; bare -k with nothing else to do is a no-op success.
    if opts.reset_timestamp && opts.command.is_empty() && !opts.validate {
        exit(0);
    }

    // From here on we are in the "run a command" path.

    // ---- Policy approximation ----
    // Real sudo: the security policy (sudoers/PAM) decides. Out of scope. We
    // permit iff we are effectively root, which is the documented prerequisite
    // ("is sudo installed setuid root?" diagnostic) and the container's state.
    if current_euid() != 0 {
        // Closest documented diagnostic for "we cannot become root".
        die("effective uid is not 0, is sudo installed setuid root?");
    }

    // ---- Resolve target identity (default target user is root) ----
    let target = match &opts.user {
        Some(u) => resolve_user(u),
        None => resolve_user("#0"), // default target = root
    };

    // Primary GID: -g overrides; else target user's primary group.
    let primary_gid = match &opts.group {
        Some(g) => resolve_group(g),
        None => target.gid,
    };

    // ---- Build the command to execute ----
    // -i (login) and -s (shell): run a shell. With a command, pass it to the
    // shell via -c with the args concatenated (we join by spaces; the man page
    // describes a backslash-escaping rule which we approximate by simple join,
    // sufficient for the documented surface).
    let (program, prog_args): (String, Vec<String>) = if opts.login || opts.shell {
        let shell = if opts.login {
            // Login shell = target user's password-db shell.
            nonempty_or(&target.shell, "/bin/sh")
        } else {
            // -s: SHELL env if set, else invoking user's db shell.
            env::var("SHELL").unwrap_or_else(|_| nonempty_or(&target.shell, "/bin/sh"))
        };
        if opts.command.is_empty() {
            // Interactive shell. -i runs it as a login shell (argv[0] = "-name").
            (shell, vec![])
        } else {
            let joined = opts.command.join(" ");
            (shell, vec!["-c".to_string(), joined])
        }
    } else {
        if opts.command.is_empty() {
            // No command and not a shell/list/validate mode: usage error.
            usage_short();
            exit(1);
        }
        (opts.command[0].clone(), opts.command[1..].to_vec())
    };

    // ---- Compute the command environment ----
    let env_map = build_environment(&opts, &target, primary_gid);

    // ---- Switch credentials down to the target user via libc ----
    // Order matters: set groups, then GID, then UID last (once UID drops we
    // lose the privilege to change groups). This mirrors the standard
    // privilege-drop idiom.
    drop_privileges(&target, primary_gid, &opts);

    // ---- chdir / login-dir handling ----
    if let Some(dir) = &opts.chdir {
        if let Err(e) = env::set_current_dir(dir) {
            die(&format!("unable to change directory to {}: {}", dir, e));
        }
    } else if opts.login {
        // -i: attempt to change to the target user's home directory.
        let _ = env::set_current_dir(&target.dir);
    }

    // ---- Exec the command ----
    let mut cmd = Command::new(&program);
    cmd.args(&prog_args);
    cmd.env_clear();
    for (k, v) in &env_map {
        cmd.env(k, v);
    }
    // For a login shell, sudo sets argv[0] to "-<shellname>" so the shell knows
    // it is a login shell. std::process::Command cannot set argv[0]
    // independently of the program path without arg0() (unstable on some
    // toolchains), so we approximate by relying on the shell path; this is a
    // known fidelity gap documented in _deps_rationale.txt.

    let status = cmd.status();
    match status {
        Ok(s) => {
            // EXIT VALUE: sudo's exit status is the command's exit status.
            if let Some(code) = s.code() {
                exit(code);
            }
            // Terminated by a signal: real sudo re-raises the same signal on
            // itself. We approximate with 128+signal, the shell convention.
            #[cfg(unix)]
            {
                use std::os::unix::process::ExitStatusExt;
                if let Some(sig) = s.signal() {
                    exit(128 + sig);
                }
            }
            exit(1);
        }
        Err(e) => {
            // "the given command cannot be executed" -> exit 1, message to stderr.
            die(&format!("{}: command not found", program_basename(&program, &e)));
        }
    }
}

fn program_basename(program: &str, _e: &std::io::Error) -> String {
    program.to_string()
}

fn nonempty_or(s: &str, default: &str) -> String {
    if s.is_empty() {
        default.to_string()
    } else {
        s.to_string()
    }
}

// Build the environment for the command. This is a deliberately small
// approximation of the man page's ENVIRONMENT section. The real sudoers policy
// has env_reset/env_keep/env_check lists that we do not model. We model:
//   - default ("env_reset"): start from a minimal safe set + always-set sudo
//     vars; this is the sudoers default.
//   - -E / --preserve-env: keep the invoking environment wholesale.
//   - --preserve-env=list: keep only the named variables from the invoking env.
//   - VAR=value command-line assignments: applied on top.
//   - -i / -H: set HOME (and login-related vars for -i).
fn build_environment(
    opts: &Opts,
    target: &PwInfo,
    _primary_gid: libc::gid_t,
) -> BTreeMap<String, String> {
    let mut out: BTreeMap<String, String> = BTreeMap::new();
    let invoking = invoking_user_name();

    if opts.preserve_env {
        // -E: preserve the whole environment.
        for (k, v) in env::vars() {
            out.insert(k, v);
        }
    } else {
        // env_reset default: keep a minimal safe baseline.
        let keep_baseline = ["TERM", "PATH", "DISPLAY", "LANG", "LC_ALL", "TZ"];
        for k in keep_baseline {
            if let Ok(v) = env::var(k) {
                out.insert(k.to_string(), v);
            }
        }
        // --preserve-env=list: add the named variables back from invoking env.
        for name in &opts.preserve_env_list {
            if let Ok(v) = env::var(name) {
                out.insert(name.clone(), v);
            }
        }
    }

    // A sane default PATH if none survived.
    out.entry("PATH".to_string())
        .or_insert_with(|| "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin".to_string());

    // sudo always-set SUDO_* vars (ENVIRONMENT section).
    out.insert("SUDO_USER".to_string(), invoking.clone());
    out.insert("SUDO_UID".to_string(), current_uid().to_string());
    out.insert("SUDO_GID".to_string(), unsafe { libc::getgid() }.to_string());
    if let Ok(home) = env::var("HOME") {
        out.insert("SUDO_HOME".to_string(), home);
    }
    let cmdline = opts.command.join(" ");
    let truncated: String = cmdline.chars().take(4096).collect();
    out.insert("SUDO_COMMAND".to_string(), truncated);

    // HOME handling: set to target home with -i or -H (man page ENVIRONMENT).
    if opts.login || opts.set_home {
        out.insert("HOME".to_string(), nonempty_or(&target.dir, "/"));
    }

    // -i (login): LOGNAME/USER/HOME/SHELL/MAIL set to target user's values.
    if opts.login {
        out.insert("LOGNAME".to_string(), target.name.clone());
        out.insert("USER".to_string(), target.name.clone());
        if !target.shell.is_empty() {
            out.insert("SHELL".to_string(), target.shell.clone());
        }
        out.insert("MAIL".to_string(), format!("/var/mail/{}", target.name));
    }

    // Command-line VAR=value assignments override everything (subject in real
    // sudo to env_check/setenv; not modeled here).
    for (k, v) in &opts.env_assignments {
        out.insert(k.clone(), v.clone());
    }

    out
}

// Drop privileges to the target user via the setuid/setgid family. We must run
// as root for this to succeed (checked earlier).
fn drop_privileges(target: &PwInfo, primary_gid: libc::gid_t, opts: &Opts) {
    unsafe {
        // Supplementary groups. By default sudoers initializes the group vector
        // to the target user's groups; -P preserves the invoking user's vector.
        if !opts.preserve_groups {
            // initgroups() sets the supplementary group list for the target
            // user, then we override the primary GID below.
            let cname = CString::new(target.name.as_str()).unwrap_or_else(|_| die("invalid user name"));
            // initgroups takes the *primary* gid as its second arg and adds it.
            if libc::initgroups(cname.as_ptr(), target.gid) != 0 {
                // Non-fatal in this stand-in: a synthesized #UID user has no
                // group db entry. Fall back to a single-group vector.
                let groups = [primary_gid];
                let _ = libc::setgroups(1, groups.as_ptr());
            }
        }

        // Set GID before UID (cannot change GID after dropping UID).
        if libc::setgid(primary_gid) != 0 {
            die("unable to set group ID");
        }

        // Set UID last.
        if libc::setuid(target.uid) != 0 {
            die("unable to set user ID");
        }
    }
}

// Minimal PATH search for the -l command form. Honors the man page's security
// note that "." is checked last; we simply skip empty/relative entries to keep
// it conservative.
fn which(cmd: &str) -> Option<String> {
    if cmd.contains('/') {
        let p = std::path::Path::new(cmd);
        if p.exists() {
            return Some(cmd.to_string());
        }
        return None;
    }
    let path = env::var("PATH").unwrap_or_default();
    for dir in path.split(':') {
        if dir.is_empty() || dir == "." {
            continue; // skip CWD-like entries (checked last / not at all here)
        }
        let candidate = std::path::Path::new(dir).join(cmd);
        if candidate.exists() {
            return Some(candidate.to_string_lossy().into_owned());
        }
    }
    None
}
