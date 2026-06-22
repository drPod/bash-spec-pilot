// mv - move (rename) files. Single-file Rust implementation of the documented
// GNU coreutils 9.7 behavior (frozen man page). Behavioral oracle is real GNU
// mv inside Debian trixie; this targets POSIX/Linux semantics.

use std::env;
use std::ffi::CString;
use std::fs;
use std::io::{self, Read, Write};
use std::os::unix::fs::MetadataExt;
use std::os::unix::fs::PermissionsExt;
use std::os::unix::fs::symlink as unix_symlink;
use std::path::{Path, PathBuf};
use std::process::ExitCode;

const PROG: &str = "mv";

#[derive(Clone, Copy, PartialEq)]
enum Clobber {
    Force,       // -f: overwrite without prompting (default)
    Interactive, // -i: prompt before overwrite
    NoClobber,   // -n: do not overwrite, no error
}

#[derive(Clone, Copy, PartialEq)]
enum Update {
    All,      // default: always replace
    None,     // like --no-clobber, skip silently
    NoneFail, // skip but diagnose + fail
    Older,    // replace only if source is newer than dest
}

#[derive(Clone, Copy, PartialEq)]
enum BackupMode {
    None,
    Numbered,
    Existing, // numbered if numbered backups exist, simple otherwise
    Simple,
}

struct Options {
    clobber: Clobber,
    update: Update,
    backup: BackupMode,
    suffix: String,
    target_directory: Option<PathBuf>,
    no_target_directory: bool, // -T
    strip_trailing_slashes: bool,
    verbose: bool,
}

impl Default for Options {
    fn default() -> Self {
        Options {
            clobber: Clobber::Force,
            update: Update::All,
            backup: BackupMode::None,
            suffix: backup_suffix_default(),
            target_directory: None,
            no_target_directory: false,
            strip_trailing_slashes: false,
            verbose: false,
        }
    }
}

fn backup_suffix_default() -> String {
    env::var("SIMPLE_BACKUP_SUFFIX").unwrap_or_else(|_| "~".to_string())
}

fn err(msg: &str) {
    eprintln!("{}: {}", PROG, msg);
}

// Map a --backup CONTROL string (or VERSION_CONTROL value) to a mode.
fn parse_backup_control(s: &str) -> Result<BackupMode, String> {
    match s {
        "none" | "off" => Ok(BackupMode::None),
        "numbered" | "t" => Ok(BackupMode::Numbered),
        "existing" | "nil" => Ok(BackupMode::Existing),
        "simple" | "never" => Ok(BackupMode::Simple),
        other => Err(format!("invalid argument '{}' for 'backup type'", other)),
    }
}

fn parse_update(s: &str) -> Result<Update, String> {
    match s {
        "all" => Ok(Update::All),
        "none" => Ok(Update::None),
        "none-fail" => Ok(Update::NoneFail),
        "older" => Ok(Update::Older),
        other => Err(format!("invalid argument '{}' for '--update'", other)),
    }
}

fn print_help() {
    println!("Usage: {} [OPTION]... [-T] SOURCE DEST", PROG);
    println!("  or:  {} [OPTION]... SOURCE... DIRECTORY", PROG);
    println!("  or:  {} [OPTION]... -t DIRECTORY SOURCE...", PROG);
    println!("Rename SOURCE to DEST, or move SOURCE(s) to DIRECTORY.");
}

fn print_version() {
    println!("mv (Rust mv_impl) 9.7");
}

// Parse argv. Returns (options, operands). Exits the process on --help/--version
// or on a usage error.
fn parse_args(args: Vec<String>) -> Result<(Options, Vec<String>), i32> {
    let mut opts = Options::default();
    let mut operands: Vec<String> = Vec::new();
    let mut backup_requested = false; // -b or --backup seen
    let mut backup_control: Option<BackupMode> = None;
    let mut update_seen = false;

    let mut i = 0;
    let mut no_more_opts = false;
    while i < args.len() {
        let a = &args[i];
        if no_more_opts || a == "-" || !a.starts_with('-') {
            operands.push(a.clone());
            i += 1;
            continue;
        }
        if a == "--" {
            no_more_opts = true;
            i += 1;
            continue;
        }
        if a.starts_with("--") {
            // Long option, possibly --opt=value.
            let body = &a[2..];
            let (name, inline_val) = match body.find('=') {
                Some(p) => (&body[..p], Some(body[p + 1..].to_string())),
                None => (body, None),
            };
            match name {
                "backup" => {
                    backup_requested = true;
                    if let Some(v) = inline_val {
                        match parse_backup_control(&v) {
                            Ok(m) => backup_control = Some(m),
                            Err(e) => {
                                err(&e);
                                return Err(1);
                            }
                        }
                    }
                }
                "force" => opts.clobber = Clobber::Force,
                "interactive" => opts.clobber = Clobber::Interactive,
                "no-clobber" => opts.clobber = Clobber::NoClobber,
                "strip-trailing-slashes" => opts.strip_trailing_slashes = true,
                "suffix" => {
                    let v = match inline_val {
                        Some(v) => v,
                        None => match take_value(&args, &mut i, "--suffix") {
                            Some(v) => v,
                            None => return Err(1),
                        },
                    };
                    opts.suffix = v;
                }
                "target-directory" => {
                    let v = match inline_val {
                        Some(v) => v,
                        None => match take_value(&args, &mut i, "--target-directory") {
                            Some(v) => v,
                            None => return Err(1),
                        },
                    };
                    opts.target_directory = Some(PathBuf::from(v));
                }
                "no-target-directory" => opts.no_target_directory = true,
                "update" => {
                    update_seen = true;
                    match inline_val {
                        Some(v) => match parse_update(&v) {
                            Ok(u) => opts.update = u,
                            Err(e) => {
                                err(&e);
                                return Err(1);
                            }
                        },
                        None => opts.update = Update::Older,
                    }
                }
                "verbose" => opts.verbose = true,
                "help" => {
                    print_help();
                    return Err(0);
                }
                "version" => {
                    print_version();
                    return Err(0);
                }
                _ => {
                    err(&format!("unrecognized option '--{}'", name));
                    err("Try 'mv --help' for more information.");
                    return Err(1);
                }
            }
            i += 1;
            continue;
        }

        // Short option cluster, e.g. -bfv or -tDIR or -SBAK.
        let chars: Vec<char> = a[1..].chars().collect();
        let mut j = 0;
        while j < chars.len() {
            let c = chars[j];
            match c {
                'b' => {
                    backup_requested = true;
                }
                'f' => opts.clobber = Clobber::Force,
                'i' => opts.clobber = Clobber::Interactive,
                'n' => opts.clobber = Clobber::NoClobber,
                'u' => {
                    update_seen = true;
                    opts.update = Update::Older;
                }
                'v' => opts.verbose = true,
                'T' => opts.no_target_directory = true,
                'S' => {
                    // Rest of cluster is the value, else next arg.
                    let rest: String = chars[j + 1..].iter().collect();
                    let v = if !rest.is_empty() {
                        rest
                    } else {
                        match take_value(&args, &mut i, "-S") {
                            Some(v) => v,
                            None => return Err(1),
                        }
                    };
                    opts.suffix = v;
                    break;
                }
                't' => {
                    let rest: String = chars[j + 1..].iter().collect();
                    let v = if !rest.is_empty() {
                        rest
                    } else {
                        match take_value(&args, &mut i, "-t") {
                            Some(v) => v,
                            None => return Err(1),
                        }
                    };
                    opts.target_directory = Some(PathBuf::from(v));
                    break;
                }
                other => {
                    err(&format!("invalid option -- '{}'", other));
                    err("Try 'mv --help' for more information.");
                    return Err(1);
                }
            }
            j += 1;
        }
        i += 1;
    }

    // Resolve backup mode. VERSION_CONTROL env supplies the control when
    // --backup is given without an explicit argument (or -b is used).
    if backup_requested {
        opts.backup = match backup_control {
            Some(m) => m,
            None => match env::var("VERSION_CONTROL") {
                Ok(v) => match parse_backup_control(&v) {
                    Ok(m) => m,
                    Err(e) => {
                        err(&e);
                        return Err(1);
                    }
                },
                Err(_) => BackupMode::Existing, // GNU default control
            },
        };
    }

    // --backup is incompatible with -n / --update=none family in GNU mv, but
    // the man page does not document the interaction; leave as set.
    let _ = update_seen;

    Ok((opts, operands))
}

// Consume the value for an option that takes a separate argument.
fn take_value(args: &[String], i: &mut usize, opt: &str) -> Option<String> {
    if *i + 1 < args.len() {
        *i += 1;
        Some(args[*i].clone())
    } else {
        err(&format!("option requires an argument -- '{}'", opt));
        None
    }
}

fn strip_trailing_slashes(s: &str) -> String {
    if s == "/" {
        return s.to_string();
    }
    let trimmed = s.trim_end_matches('/');
    if trimmed.is_empty() {
        "/".to_string()
    } else {
        trimmed.to_string()
    }
}

fn is_dir(p: &Path) -> bool {
    fs::metadata(p).map(|m| m.is_dir()).unwrap_or(false)
}

fn path_exists(p: &Path) -> bool {
    // symlink_metadata so a dangling symlink still counts as existing.
    fs::symlink_metadata(p).is_ok()
}

// Final component of a source path, for building DEST inside a directory.
fn base_name(p: &Path) -> PathBuf {
    match p.file_name() {
        Some(n) => PathBuf::from(n),
        None => p.to_path_buf(),
    }
}

fn isatty_stdin() -> bool {
    unsafe { libc::isatty(libc::STDIN_FILENO) == 1 }
}

fn prompt_overwrite(dest: &Path) -> bool {
    eprint!("{}: overwrite '{}'? ", PROG, dest.display());
    let _ = io::stderr().flush();
    let mut line = String::new();
    if io::stdin().read_line(&mut line).is_err() {
        return false;
    }
    let t = line.trim_start();
    matches!(t.chars().next(), Some('y') | Some('Y'))
}

// mtime comparison for --update=older. Returns true if src is strictly newer.
fn src_newer(src_md: &fs::Metadata, dst_md: &fs::Metadata) -> bool {
    let (ss, sn) = (src_md.mtime(), src_md.mtime_nsec());
    let (ds, dn) = (dst_md.mtime(), dst_md.mtime_nsec());
    (ss, sn) > (ds, dn)
}

// Build the backup path for `dest` per the resolved backup mode.
fn backup_path(dest: &Path, mode: BackupMode, suffix: &str) -> Option<PathBuf> {
    match mode {
        BackupMode::None => None,
        BackupMode::Simple => Some(append_suffix(dest, suffix)),
        BackupMode::Numbered => Some(numbered_backup(dest)),
        BackupMode::Existing => {
            // If a numbered backup .~1~ exists, use numbered; else simple.
            let first = numbered_name(dest, 1);
            if path_exists(&first) || any_numbered_exists(dest) {
                Some(numbered_backup(dest))
            } else {
                Some(append_suffix(dest, suffix))
            }
        }
    }
}

fn append_suffix(dest: &Path, suffix: &str) -> PathBuf {
    let mut s = dest.as_os_str().to_os_string();
    s.push(suffix);
    PathBuf::from(s)
}

fn numbered_name(dest: &Path, n: u64) -> PathBuf {
    let mut s = dest.as_os_str().to_os_string();
    s.push(format!(".~{}~", n));
    PathBuf::from(s)
}

fn any_numbered_exists(dest: &Path) -> bool {
    // Cheap check: only probe the first few; GNU scans the directory, but for
    // the documented behavior probing #1 is the decisive case.
    path_exists(&numbered_name(dest, 1))
}

fn numbered_backup(dest: &Path) -> PathBuf {
    let mut n = 1;
    loop {
        let cand = numbered_name(dest, n);
        if !path_exists(&cand) {
            return cand;
        }
        n += 1;
    }
}

// Move a single source to a fully-resolved destination path.
fn move_one(src: &Path, dest: &Path, opts: &Options) -> Result<(), ()> {
    let src_md = match fs::symlink_metadata(src) {
        Ok(m) => m,
        Err(e) => {
            err(&format!(
                "cannot stat '{}': {}",
                src.display(),
                e.to_string()
            ));
            return Err(());
        }
    };

    let dest_exists = path_exists(dest);

    if dest_exists {
        let dest_md = fs::symlink_metadata(dest).ok();

        // --update / clobber policy.
        match opts.update {
            Update::None => {
                if opts.verbose {
                    println!("skipped '{}'", dest.display());
                }
                return Ok(());
            }
            Update::NoneFail => {
                err(&format!("not replacing '{}'", dest.display()));
                return Err(());
            }
            Update::Older => {
                if let (Some(dmd), true) = (&dest_md, !is_dir(dest)) {
                    if !src_newer(&src_md, dmd) {
                        return Ok(()); // dest is same age or newer: skip
                    }
                }
            }
            Update::All => {}
        }

        match opts.clobber {
            Clobber::NoClobber => {
                return Ok(()); // skip silently, no error
            }
            Clobber::Interactive => {
                if isatty_stdin() && !prompt_overwrite(dest) {
                    return Ok(());
                }
            }
            Clobber::Force => {}
        }

        // Backup the existing destination before overwriting.
        if opts.backup != BackupMode::None {
            if let Some(bpath) = backup_path(dest, opts.backup, &opts.suffix) {
                if let Err(e) = fs::rename(dest, &bpath) {
                    err(&format!(
                        "cannot backup '{}': {}",
                        dest.display(),
                        e.to_string()
                    ));
                    return Err(());
                }
            }
        }
    }

    // Attempt the actual move: rename(2), with cross-device copy fallback.
    if do_rename(src, dest) {
        if opts.verbose {
            println!("renamed '{}' -> '{}'", src.display(), dest.display());
        }
        return Ok(());
    }

    // rename failed; inspect errno.
    let e = io::Error::last_os_error();
    let exdev = e.raw_os_error() == Some(libc::EXDEV);
    if !exdev {
        err(&format!(
            "cannot move '{}' to '{}': {}",
            src.display(),
            dest.display(),
            e.to_string()
        ));
        return Err(());
    }

    // Cross-device: copy then remove the source.
    if let Err(msg) = copy_recursive(src, dest, &src_md) {
        err(&format!("cannot move '{}' to '{}': {}", src.display(), dest.display(), msg));
        return Err(());
    }
    if let Err(msg) = remove_recursive(src) {
        err(&format!("cannot remove '{}': {}", src.display(), msg));
        return Err(());
    }
    if opts.verbose {
        println!("renamed '{}' -> '{}'", src.display(), dest.display());
    }
    Ok(())
}

// rename(2) wrapper. Returns true on success.
fn do_rename(src: &Path, dest: &Path) -> bool {
    let cs = match path_to_cstring(src) {
        Some(c) => c,
        None => return false,
    };
    let cd = match path_to_cstring(dest) {
        Some(c) => c,
        None => return false,
    };
    unsafe { libc::rename(cs.as_ptr(), cd.as_ptr()) == 0 }
}

fn path_to_cstring(p: &Path) -> Option<CString> {
    use std::os::unix::ffi::OsStrExt;
    CString::new(p.as_os_str().as_bytes()).ok()
}

// Recursive copy used only for the EXDEV cross-device fallback. Preserves
// mode and (best-effort) symlinks. Skips xattr/ACL/sparse per scope.
fn copy_recursive(src: &Path, dest: &Path, src_md: &fs::Metadata) -> Result<(), String> {
    let ft = src_md.file_type();
    if ft.is_symlink() {
        let target = fs::read_link(src).map_err(|e| e.to_string())?;
        if path_exists(dest) {
            let _ = fs::remove_file(dest);
        }
        unix_symlink(&target, dest).map_err(|e| e.to_string())?;
        return Ok(());
    }
    if ft.is_dir() {
        fs::create_dir_all(dest).map_err(|e| e.to_string())?;
        for entry in fs::read_dir(src).map_err(|e| e.to_string())? {
            let entry = entry.map_err(|e| e.to_string())?;
            let child = entry.path();
            let child_dest = dest.join(entry.file_name());
            let cmd = fs::symlink_metadata(&child).map_err(|e| e.to_string())?;
            copy_recursive(&child, &child_dest, &cmd)?;
        }
        let perm = fs::Permissions::from_mode(src_md.mode());
        let _ = fs::set_permissions(dest, perm);
        return Ok(());
    }
    // Regular file (and best-effort for others): byte copy.
    copy_file_bytes(src, dest)?;
    let perm = fs::Permissions::from_mode(src_md.mode());
    let _ = fs::set_permissions(dest, perm);
    Ok(())
}

fn copy_file_bytes(src: &Path, dest: &Path) -> Result<(), String> {
    let mut input = fs::File::open(src).map_err(|e| e.to_string())?;
    let mut output = fs::File::create(dest).map_err(|e| e.to_string())?;
    let mut buf = [0u8; 65536];
    loop {
        let n = input.read(&mut buf).map_err(|e| e.to_string())?;
        if n == 0 {
            break;
        }
        output.write_all(&buf[..n]).map_err(|e| e.to_string())?;
    }
    Ok(())
}

fn remove_recursive(src: &Path) -> Result<(), String> {
    let md = fs::symlink_metadata(src).map_err(|e| e.to_string())?;
    if md.file_type().is_dir() {
        fs::remove_dir_all(src).map_err(|e| e.to_string())
    } else {
        fs::remove_file(src).map_err(|e| e.to_string())
    }
}

fn run() -> i32 {
    let raw: Vec<String> = env::args().skip(1).collect();
    let (opts, mut operands) = match parse_args(raw) {
        Ok(v) => v,
        Err(code) => return code,
    };

    if opts.strip_trailing_slashes {
        operands = operands
            .iter()
            .map(|s| strip_trailing_slashes(s))
            .collect();
    }

    // Determine sources and the destination/target.
    let (sources, target, target_is_dir_mode): (Vec<String>, PathBuf, bool) =
        if let Some(td) = &opts.target_directory {
            if operands.is_empty() {
                err("missing file operand");
                err("Try 'mv --help' for more information.");
                return 1;
            }
            (operands.clone(), td.clone(), true)
        } else {
            if operands.is_empty() {
                err("missing file operand");
                err("Try 'mv --help' for more information.");
                return 1;
            }
            if operands.len() == 1 {
                err(&format!(
                    "missing destination file operand after '{}'",
                    operands[0]
                ));
                err("Try 'mv --help' for more information.");
                return 1;
            }
            // Last operand is the destination.
            let dest = operands.pop().unwrap();
            let dest_path = PathBuf::from(&dest);
            let sources = operands.clone();
            let into_dir = is_dir(&dest_path) && !opts.no_target_directory;
            (sources, dest_path, into_dir)
        };

    // -T with multiple sources is an error.
    if opts.no_target_directory && opts.target_directory.is_none() && sources.len() > 1 {
        err(&format!("extra operand '{}'", sources[1]));
        err("Try 'mv --help' for more information.");
        return 1;
    }

    let mut status = 0;

    if target_is_dir_mode {
        // Each source moves into the target directory.
        if !is_dir(&target) {
            err(&format!(
                "target '{}' is not a directory",
                target.display()
            ));
            return 1;
        }
        for s in &sources {
            let src = PathBuf::from(s);
            let dest = target.join(base_name(&src));
            if move_one(&src, &dest, &opts).is_err() {
                status = 1;
            }
        }
    } else {
        // SOURCE DEST form (single source, exactly one move).
        if sources.len() != 1 {
            err(&format!("target '{}' is not a directory", target.display()));
            return 1;
        }
        let src = PathBuf::from(&sources[0]);
        // -T: treat DEST as a normal file even if it exists as a directory is
        // handled by rename semantics; we just move src onto target.
        if move_one(&src, &target, &opts).is_err() {
            status = 1;
        }
    }

    status
}

fn main() -> ExitCode {
    let code = run();
    ExitCode::from(code as u8)
}
