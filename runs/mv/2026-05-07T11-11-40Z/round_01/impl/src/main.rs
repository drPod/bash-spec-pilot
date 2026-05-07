use std::env;
use std::ffi::{CString, OsStr, OsString};
use std::fs::{self, Metadata};
use std::io::{self, Write};
use std::os::unix::ffi::{OsStrExt, OsStringExt};
use std::os::unix::fs::{symlink, MetadataExt, PermissionsExt};
use std::path::{Path, PathBuf};
use std::time::SystemTime;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum ReplacePolicy {
    All,
    Interactive,
    NoneSkip,
    NoneFail,
    Older,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum BackupMode {
    Off,
    Simple,
    Numbered,
    Existing,
}

#[derive(Debug)]
struct Options {
    target_dir: Option<PathBuf>,
    no_target_dir: bool,
    strip_trailing_slashes: bool,
    no_copy: bool,
    exchange: bool,
    verbose: bool,
    debug: bool,
    suffix: OsString,
    backup_requested: bool,
    backup_control: Option<String>,
    policy: ReplacePolicy,
}

impl Default for Options {
    fn default() -> Self {
        let suffix = env::var_os("SIMPLE_BACKUP_SUFFIX").unwrap_or_else(|| OsString::from("~"));
        Self {
            target_dir: None,
            no_target_dir: false,
            strip_trailing_slashes: false,
            no_copy: false,
            exchange: false,
            verbose: false,
            debug: false,
            suffix,
            backup_requested: false,
            backup_control: None,
            policy: ReplacePolicy::All,
        }
    }
}

fn main() {
    let (opts, mut operands) = match parse_args() {
        Ok(v) => v,
        Err(msg) => {
            eprintln!("mv: {}", msg);
            std::process::exit(1);
        }
    };

    if opts.strip_trailing_slashes {
        operands = operands.into_iter().map(strip_trailing_slashes).collect();
    }

    let backup_mode = determine_backup_mode(&opts);

    if opts.exchange {
        if opts.target_dir.is_some() || operands.len() != 2 {
            eprintln!("mv: --exchange requires exactly two file operands");
            std::process::exit(1);
        }
        let ok = exchange_paths(Path::new(&operands[0]), Path::new(&operands[1]), &opts);
        std::process::exit(if ok { 0 } else { 1 });
    }

    let mut jobs: Vec<(PathBuf, PathBuf)> = Vec::new();

    if let Some(dir) = &opts.target_dir {
        if operands.is_empty() {
            eprintln!("mv: missing file operand");
            std::process::exit(1);
        }
        if !is_dir(dir) {
            eprintln!("mv: target directory '{}' is not a directory", q(dir));
            std::process::exit(1);
        }
        for src_os in operands {
            let src = PathBuf::from(&src_os);
            let Some(name) = source_basename(&src) else {
                eprintln!("mv: cannot move '{}': invalid source path", q(&src));
                std::process::exit(1);
            };
            jobs.push((src, dir.join(name)));
        }
    } else {
        if operands.len() < 2 {
            eprintln!("mv: missing destination file operand after '{}'", operands.get(0).map(|s| s.to_string_lossy()).unwrap_or_default());
            std::process::exit(1);
        }
        if opts.no_target_dir && operands.len() > 2 {
            eprintln!("mv: extra operand '{}'", operands[2].to_string_lossy());
            std::process::exit(1);
        }
        let dest_arg = PathBuf::from(operands.pop().unwrap());
        if operands.len() > 1 {
            if opts.no_target_dir {
                eprintln!("mv: extra operand '{}'", operands[1].to_string_lossy());
                std::process::exit(1);
            }
            if !is_dir(&dest_arg) {
                eprintln!("mv: target '{}' is not a directory", q(&dest_arg));
                std::process::exit(1);
            }
            for src_os in operands {
                let src = PathBuf::from(&src_os);
                let Some(name) = source_basename(&src) else {
                    eprintln!("mv: cannot move '{}': invalid source path", q(&src));
                    std::process::exit(1);
                };
                jobs.push((src, dest_arg.join(name)));
            }
        } else {
            let src = PathBuf::from(operands.pop().unwrap());
            if !opts.no_target_dir && is_dir(&dest_arg) {
                let Some(name) = source_basename(&src) else {
                    eprintln!("mv: cannot move '{}': invalid source path", q(&src));
                    std::process::exit(1);
                };
                jobs.push((src, dest_arg.join(name)));
            } else {
                jobs.push((src, dest_arg));
            }
        }
    }

    let mut ok = true;
    for (src, dst) in jobs {
        if !move_one(&src, &dst, &opts, backup_mode) {
            ok = false;
        }
    }
    std::process::exit(if ok { 0 } else { 1 });
}

fn parse_args() -> Result<(Options, Vec<OsString>), String> {
    let mut opts = Options::default();
    let mut operands = Vec::new();
    let mut args: Vec<OsString> = env::args_os().skip(1).collect();
    let mut i = 0usize;
    let mut end_opts = false;

    while i < args.len() {
        let arg = args[i].clone();
        if end_opts || !is_option_like(&arg) {
            operands.push(arg);
            i += 1;
            continue;
        }
        let s = arg.to_string_lossy().into_owned();
        if s == "--" {
            end_opts = true;
            i += 1;
            continue;
        }
        if s == "--help" {
            print_help();
            std::process::exit(0);
        }
        if s == "--version" {
            println!("mv (util) 9.7");
            println!("Copyright (C) 2025 Free Software Foundation, Inc.");
            std::process::exit(0);
        }
        if s.starts_with("--") {
            if s == "--backup" {
                opts.backup_requested = true;
            } else if let Some(v) = s.strip_prefix("--backup=") {
                opts.backup_requested = true;
                opts.backup_control = Some(v.to_string());
            } else if s == "--debug" {
                opts.debug = true;
                opts.verbose = true;
            } else if s == "--exchange" {
                opts.exchange = true;
            } else if s == "--force" {
                opts.policy = ReplacePolicy::All;
            } else if s == "--interactive" {
                opts.policy = ReplacePolicy::Interactive;
            } else if s == "--no-clobber" {
                opts.policy = ReplacePolicy::NoneSkip;
            } else if s == "--no-copy" {
                opts.no_copy = true;
            } else if s == "--strip-trailing-slashes" {
                opts.strip_trailing_slashes = true;
            } else if let Some(v) = s.strip_prefix("--suffix=") {
                opts.suffix = OsString::from(v);
            } else if let Some(v) = s.strip_prefix("--target-directory=") {
                opts.target_dir = Some(PathBuf::from(v));
            } else if s == "--no-target-directory" {
                opts.no_target_dir = true;
            } else if s == "--update" {
                opts.policy = ReplacePolicy::Older;
            } else if let Some(v) = s.strip_prefix("--update=") {
                opts.policy = parse_update(v)?;
            } else if s == "--verbose" {
                opts.verbose = true;
            } else if s == "--context" {
                // SELinux context handling intentionally ignored.
            } else {
                return Err(format!("unrecognized option '{}'", s));
            }
            i += 1;
            continue;
        }

        let bytes = arg.as_bytes();
        let mut pos = 1usize;
        while pos < bytes.len() {
            let ch = bytes[pos] as char;
            match ch {
                'b' => opts.backup_requested = true,
                'f' => opts.policy = ReplacePolicy::All,
                'i' => opts.policy = ReplacePolicy::Interactive,
                'n' => opts.policy = ReplacePolicy::NoneSkip,
                'u' => opts.policy = ReplacePolicy::Older,
                'v' => opts.verbose = true,
                'T' => opts.no_target_dir = true,
                'Z' => {}
                't' | 'S' => {
                    let val = if pos + 1 < bytes.len() {
                        OsString::from_vec(bytes[pos + 1..].to_vec())
                    } else {
                        i += 1;
                        if i >= args.len() {
                            return Err(format!("option requires an argument -- '{}'", ch));
                        }
                        args[i].clone()
                    };
                    if ch == 't' {
                        opts.target_dir = Some(PathBuf::from(val));
                    } else {
                        opts.suffix = val;
                    }
                    pos = bytes.len();
                    continue;
                }
                _ => return Err(format!("invalid option -- '{}'", ch)),
            }
            pos += 1;
        }
        i += 1;
    }

    Ok((opts, operands))
}

fn parse_update(v: &str) -> Result<ReplacePolicy, String> {
    match v {
        "all" => Ok(ReplacePolicy::All),
        "none" => Ok(ReplacePolicy::NoneSkip),
        "none-fail" => Ok(ReplacePolicy::NoneFail),
        "older" => Ok(ReplacePolicy::Older),
        _ => Err(format!("invalid argument '{}' for '--update'", v)),
    }
}

fn print_help() {
    println!("Usage: mv [OPTION]... [-T] SOURCE DEST");
    println!("  or:  mv [OPTION]... SOURCE... DIRECTORY");
    println!("  or:  mv [OPTION]... -t DIRECTORY SOURCE...");
    println!("Rename SOURCE to DEST, or move SOURCE(s) to DIRECTORY.");
    println!("\n  -f, --force                  do not prompt before overwriting");
    println!("  -i, --interactive            prompt before overwrite");
    println!("  -n, --no-clobber             do not overwrite an existing file");
    println!("  -t, --target-directory=DIR   move all SOURCE arguments into DIR");
    println!("  -T, --no-target-directory    treat DEST as a normal file");
    println!("  -u, --update                 move only when SOURCE is newer");
    println!("  -v, --verbose                explain what is being done");
    println!("  -b, --backup[=CONTROL]       make a backup of each existing destination");
}

fn is_option_like(s: &OsStr) -> bool {
    let b = s.as_bytes();
    b.len() > 1 && b[0] == b'-'
}

fn determine_backup_mode(opts: &Options) -> BackupMode {
    if !opts.backup_requested {
        return BackupMode::Off;
    }
    let control = opts
        .backup_control
        .clone()
        .or_else(|| env::var("VERSION_CONTROL").ok())
        .unwrap_or_else(|| "existing".to_string());
    match control.as_str() {
        "none" | "off" => BackupMode::Off,
        "numbered" | "t" => BackupMode::Numbered,
        "simple" | "never" => BackupMode::Simple,
        "existing" | "nil" => BackupMode::Existing,
        _ => BackupMode::Existing,
    }
}

fn strip_trailing_slashes(s: OsString) -> OsString {
    let mut b = s.into_vec();
    while b.len() > 1 && b.last() == Some(&b'/') {
        b.pop();
    }
    OsString::from_vec(b)
}

fn source_basename(p: &Path) -> Option<OsString> {
    p.file_name().map(|s| s.to_os_string())
}

fn is_dir(p: &Path) -> bool {
    fs::metadata(p).map(|m| m.is_dir()).unwrap_or(false)
}

fn move_one(src: &Path, dst: &Path, opts: &Options, backup_mode: BackupMode) -> bool {
    let src_meta = match fs::symlink_metadata(src) {
        Ok(m) => m,
        Err(e) => {
            eprintln!("mv: cannot stat '{}': {}", q(src), e);
            return false;
        }
    };

    let dst_meta = match fs::symlink_metadata(dst) {
        Ok(m) => Some(m),
        Err(e) if e.kind() == io::ErrorKind::NotFound => None,
        Err(e) => {
            eprintln!("mv: cannot stat '{}': {}", q(dst), e);
            return false;
        }
    };

    if let Some(dm) = &dst_meta {
        if same_file(&src_meta, dm) {
            eprintln!("mv: '{}' and '{}' are the same file", q(src), q(dst));
            return false;
        }
        match should_replace(src, dst, &src_meta, dm, opts) {
            Ok(true) => {}
            Ok(false) => return true,
            Err(()) => return false,
        }
        if backup_mode != BackupMode::Off {
            if let Err(e) = make_backup(dst, backup_mode, &opts.suffix) {
                eprintln!("mv: cannot backup '{}': {}", q(dst), e);
                return false;
            }
        }
    }

    match fs::rename(src, dst) {
        Ok(()) => {
            if opts.verbose {
                eprintln!("renamed '{}' -> '{}'", q(src), q(dst));
            }
            true
        }
        Err(e) => {
            if e.raw_os_error() == Some(libc::EXDEV) {
                if opts.no_copy {
                    eprintln!("mv: inter-device move failed for '{}' to '{}': {}", q(src), q(dst), e);
                    return false;
                }
                if opts.debug {
                    eprintln!("mv: rename failed across file systems; copying '{}' to '{}'", q(src), q(dst));
                }
                if dst_meta.is_some() && backup_mode == BackupMode::Off {
                    if let Err(rmerr) = remove_destination_for_copy(dst, &src_meta) {
                        eprintln!("mv: cannot overwrite '{}': {}", q(dst), rmerr);
                        return false;
                    }
                }
                if let Err(ce) = copy_recursive(src, dst) {
                    eprintln!("mv: cannot move '{}' to '{}': {}", q(src), q(dst), ce);
                    return false;
                }
                if let Err(re) = remove_source_after_copy(src, &src_meta) {
                    eprintln!("mv: cannot remove '{}': {}", q(src), re);
                    return false;
                }
                if opts.verbose {
                    eprintln!("copied '{}' -> '{}'", q(src), q(dst));
                    eprintln!("removed '{}'", q(src));
                }
                true
            } else {
                eprintln!("mv: cannot move '{}' to '{}': {}", q(src), q(dst), e);
                false
            }
        }
    }
}

fn should_replace(src: &Path, dst: &Path, src_meta: &Metadata, dst_meta: &Metadata, opts: &Options) -> Result<bool, ()> {
    match opts.policy {
        ReplacePolicy::All => Ok(true),
        ReplacePolicy::Interactive => {
            eprint!("mv: overwrite '{}'? ", q(dst));
            let _ = io::stderr().flush();
            let mut ans = String::new();
            if io::stdin().read_line(&mut ans).is_ok() {
                Ok(ans.starts_with('y') || ans.starts_with('Y'))
            } else {
                Ok(false)
            }
        }
        ReplacePolicy::NoneSkip => {
            if opts.verbose {
                eprintln!("mv: not replacing '{}'", q(dst));
            }
            Ok(false)
        }
        ReplacePolicy::NoneFail => {
            eprintln!("mv: not replacing '{}'", q(dst));
            Err(())
        }
        ReplacePolicy::Older => {
            let sm = src_meta.modified().unwrap_or(SystemTime::UNIX_EPOCH);
            let dm = dst_meta.modified().unwrap_or(SystemTime::UNIX_EPOCH);
            if dm >= sm {
                if opts.verbose {
                    eprintln!("mv: not replacing '{}'", q(dst));
                }
                Ok(false)
            } else {
                Ok(true)
            }
        }
    }
}

fn same_file(a: &Metadata, b: &Metadata) -> bool {
    a.dev() == b.dev() && a.ino() == b.ino()
}

fn make_backup(dst: &Path, mode: BackupMode, suffix: &OsStr) -> io::Result<()> {
    let backup = backup_path(dst, mode, suffix);
    if backup.exists() {
        let md = fs::symlink_metadata(&backup)?;
        if md.file_type().is_dir() && !md.file_type().is_symlink() {
            fs::remove_dir_all(&backup)?;
        } else {
            fs::remove_file(&backup)?;
        }
    }
    fs::rename(dst, backup)
}

fn backup_path(dst: &Path, mode: BackupMode, suffix: &OsStr) -> PathBuf {
    match mode {
        BackupMode::Off => dst.to_path_buf(),
        BackupMode::Simple => append_suffix(dst, suffix),
        BackupMode::Numbered => numbered_backup_path(dst),
        BackupMode::Existing => {
            if numbered_backup_exists(dst) {
                numbered_backup_path(dst)
            } else {
                append_suffix(dst, suffix)
            }
        }
    }
}

fn append_suffix(dst: &Path, suffix: &OsStr) -> PathBuf {
    let mut name = dst.as_os_str().as_bytes().to_vec();
    name.extend_from_slice(suffix.as_bytes());
    PathBuf::from(OsString::from_vec(name))
}

fn numbered_backup_path(dst: &Path) -> PathBuf {
    let mut maxn = 0u64;
    let (parent, base) = parent_and_base(dst);
    if let Ok(rd) = fs::read_dir(parent) {
        for ent in rd.flatten() {
            if let Some(n) = parse_numbered_backup(&ent.file_name(), &base) {
                maxn = maxn.max(n);
            }
        }
    }
    let mut p = dst.as_os_str().as_bytes().to_vec();
    p.extend_from_slice(format!(".~{}~", maxn + 1).as_bytes());
    PathBuf::from(OsString::from_vec(p))
}

fn numbered_backup_exists(dst: &Path) -> bool {
    let (parent, base) = parent_and_base(dst);
    if let Ok(rd) = fs::read_dir(parent) {
        for ent in rd.flatten() {
            if parse_numbered_backup(&ent.file_name(), &base).is_some() {
                return true;
            }
        }
    }
    false
}

fn parent_and_base(dst: &Path) -> (&Path, Vec<u8>) {
    let parent = dst.parent().unwrap_or_else(|| Path::new("."));
    let base = dst.file_name().unwrap_or_else(|| dst.as_os_str()).as_bytes().to_vec();
    (parent, base)
}

fn parse_numbered_backup(name: &OsStr, base: &[u8]) -> Option<u64> {
    let b = name.as_bytes();
    let mid = b".~";
    if b.len() <= base.len() + 3 || !b.starts_with(base) || !b.ends_with(b"~") {
        return None;
    }
    let rest = &b[base.len()..];
    if !rest.starts_with(mid) || rest.len() <= 3 {
        return None;
    }
    std::str::from_utf8(&rest[2..rest.len() - 1]).ok()?.parse().ok()
}

fn remove_destination_for_copy(dst: &Path, src_meta: &Metadata) -> io::Result<()> {
    let dm = fs::symlink_metadata(dst)?;
    if dm.file_type().is_dir() && !dm.file_type().is_symlink() {
        if src_meta.file_type().is_dir() && !src_meta.file_type().is_symlink() {
            fs::remove_dir(dst)
        } else {
            Err(io::Error::new(io::ErrorKind::IsADirectory, "is a directory"))
        }
    } else {
        fs::remove_file(dst)
    }
}

fn copy_recursive(src: &Path, dst: &Path) -> io::Result<()> {
    let md = fs::symlink_metadata(src)?;
    let ft = md.file_type();
    if ft.is_symlink() {
        let target = fs::read_link(src)?;
        symlink(target, dst)
    } else if ft.is_dir() {
        fs::create_dir(dst)?;
        fs::set_permissions(dst, fs::Permissions::from_mode(md.permissions().mode()))?;
        for ent in fs::read_dir(src)? {
            let ent = ent?;
            copy_recursive(&ent.path(), &dst.join(ent.file_name()))?;
        }
        Ok(())
    } else if ft.is_file() {
        fs::copy(src, dst)?;
        fs::set_permissions(dst, fs::Permissions::from_mode(md.permissions().mode()))?;
        Ok(())
    } else {
        Err(io::Error::new(io::ErrorKind::Other, "unsupported file type"))
    }
}

fn remove_source_after_copy(src: &Path, md: &Metadata) -> io::Result<()> {
    if md.file_type().is_dir() && !md.file_type().is_symlink() {
        fs::remove_dir_all(src)
    } else {
        fs::remove_file(src)
    }
}

fn exchange_paths(src: &Path, dst: &Path, opts: &Options) -> bool {
    let c_src = match CString::new(src.as_os_str().as_bytes()) {
        Ok(c) => c,
        Err(_) => {
            eprintln!("mv: invalid path '{}': contains NUL byte", q(src));
            return false;
        }
    };
    let c_dst = match CString::new(dst.as_os_str().as_bytes()) {
        Ok(c) => c,
        Err(_) => {
            eprintln!("mv: invalid path '{}': contains NUL byte", q(dst));
            return false;
        }
    };
    let r = unsafe {
        libc::syscall(
            libc::SYS_renameat2,
            libc::AT_FDCWD,
            c_src.as_ptr(),
            libc::AT_FDCWD,
            c_dst.as_ptr(),
            libc::RENAME_EXCHANGE,
        )
    };
    if r == 0 {
        if opts.verbose {
            eprintln!("exchanged '{}' <-> '{}'", q(src), q(dst));
        }
        true
    } else {
        eprintln!("mv: cannot exchange '{}' and '{}': {}", q(src), q(dst), io::Error::last_os_error());
        false
    }
}

fn q(p: &Path) -> String {
    p.to_string_lossy().into_owned()
}
