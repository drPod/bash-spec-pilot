use std::env;
use std::ffi::{CString, OsStr, OsString};
use std::fs;
use std::io::{self, BufRead, Write};
use std::os::unix::ffi::{OsStrExt, OsStringExt};
use std::os::unix::fs::{symlink, MetadataExt, PermissionsExt};
use std::path::{Path, PathBuf};

#[derive(Clone, Copy, PartialEq)]
enum Clobber { Force, Interactive, NoClobber }
#[derive(Clone, Copy, PartialEq)]
enum Update { All, None, NoneFail, Older }
#[derive(Clone, PartialEq)]
enum Backup { None, Simple, Numbered, Existing }

struct Config {
    target_dir: Option<OsString>,
    no_target_dir: bool,
    strip_slashes: bool,
    verbose: bool,
    no_copy: bool,
    exchange: bool,
    clobber: Clobber,
    update: Update,
    backup: Option<Backup>,
    suffix: OsString,
}

fn q(p: &Path) -> String { format!("'{}'", p.to_string_lossy()) }
fn die(msg: &str) -> ! { eprintln!("mv: {}", msg); std::process::exit(1) }
fn err(msg: &str) { eprintln!("mv: {}", msg); }

fn print_help() {
    println!("Usage: mv [OPTION]... [-T] SOURCE DEST\n  or:  mv [OPTION]... SOURCE... DIRECTORY\n  or:  mv [OPTION]... -t DIRECTORY SOURCE...\nRename SOURCE to DEST, or move SOURCE(s) to DIRECTORY.\n\n  -f, --force                  do not prompt before overwriting\n  -i, --interactive            prompt before overwrite\n  -n, --no-clobber             do not overwrite an existing file\n  -t, --target-directory=DIR   move all SOURCE arguments into DIR\n  -T, --no-target-directory    treat DEST as a normal file\n  -u, --update                 move only when SOURCE is newer\n      --update[=all|none|none-fail|older]\n  -v, --verbose                explain what is being done\n  -b, --backup[=CONTROL]       make a backup of each existing destination\n  -S, --suffix=SUFFIX          override backup suffix\n      --strip-trailing-slashes remove trailing slashes from SOURCE arguments\n      --exchange               exchange source and destination\n      --no-copy                do not copy if renaming fails\n      --help                   display this help and exit\n      --version                output version information and exit");
}

fn version() { println!("mv (rust coreutils-compatible subset) 0.1.0"); }

fn parse_update(s: &str) -> Update {
    match s { "all" => Update::All, "none" => Update::None, "none-fail" => Update::NoneFail, "older" => Update::Older, _ => die(&format!("invalid argument '{}' for '--update'", s)) }
}
fn parse_backup(s: &str) -> Backup {
    match s { "none" | "off" => Backup::None, "numbered" | "t" => Backup::Numbered, "existing" | "nil" => Backup::Existing, "simple" | "never" => Backup::Simple, _ => die(&format!("invalid argument '{}' for '--backup'", s)) }
}
fn default_backup() -> Backup {
    env::var("VERSION_CONTROL").ok().map(|v| parse_backup(&v)).unwrap_or(Backup::Existing)
}

fn parse_args() -> (Config, Vec<OsString>) {
    let mut cfg = Config { target_dir: None, no_target_dir: false, strip_slashes: false, verbose: false, no_copy: false, exchange: false, clobber: Clobber::Force, update: Update::All, backup: None, suffix: env::var_os("SIMPLE_BACKUP_SUFFIX").unwrap_or_else(|| OsString::from("~")) };
    let mut ops = Vec::new();
    let mut it = env::args_os().skip(1).peekable();
    let mut end_opts = false;
    while let Some(a) = it.next() {
        if end_opts || !a.as_bytes().starts_with(b"-") || a == OsStr::new("-") { ops.push(a); continue; }
        if a == OsStr::new("--") { end_opts = true; continue; }
        let s = a.to_string_lossy();
        if s == "--help" { print_help(); std::process::exit(0); }
        if s == "--version" { version(); std::process::exit(0); }
        if s == "--force" { cfg.clobber = Clobber::Force; continue; }
        if s == "--interactive" { cfg.clobber = Clobber::Interactive; continue; }
        if s == "--no-clobber" { cfg.clobber = Clobber::NoClobber; continue; }
        if s == "--no-target-directory" { cfg.no_target_dir = true; continue; }
        if s == "--strip-trailing-slashes" { cfg.strip_slashes = true; continue; }
        if s == "--verbose" { cfg.verbose = true; continue; }
        if s == "--debug" { cfg.verbose = true; continue; }
        if s == "--no-copy" { cfg.no_copy = true; continue; }
        if s == "--exchange" { cfg.exchange = true; continue; }
        if s == "--context" || s == "-Z" { continue; }
        if s == "--backup" { cfg.backup = Some(default_backup()); continue; }
        if let Some(v) = s.strip_prefix("--backup=") { cfg.backup = Some(parse_backup(v)); continue; }
        if s == "--update" { cfg.update = Update::Older; continue; }
        if let Some(v) = s.strip_prefix("--update=") { cfg.update = parse_update(v); continue; }
        if let Some(v) = s.strip_prefix("--target-directory=") { cfg.target_dir = Some(OsString::from(v)); continue; }
        if s == "--target-directory" { cfg.target_dir = Some(it.next().unwrap_or_else(|| die("option '--target-directory' requires an argument"))); continue; }
        if let Some(v) = s.strip_prefix("--suffix=") { cfg.suffix = OsString::from(v); continue; }
        if s == "--suffix" { cfg.suffix = it.next().unwrap_or_else(|| die("option '--suffix' requires an argument")); continue; }
        if s.starts_with("--") { die(&format!("unrecognized option '{}'", s)); }
        let bytes = a.as_bytes();
        let mut i = 1;
        while i < bytes.len() {
            match bytes[i] as char {
                'f' => cfg.clobber = Clobber::Force,
                'i' => cfg.clobber = Clobber::Interactive,
                'n' => cfg.clobber = Clobber::NoClobber,
                'u' => cfg.update = Update::Older,
                'v' => cfg.verbose = true,
                'b' => cfg.backup = Some(default_backup()),
                'T' => cfg.no_target_dir = true,
                'Z' => {},
                't' => { if i + 1 < bytes.len() { cfg.target_dir = Some(OsString::from_vec(bytes[i+1..].to_vec())); } else { cfg.target_dir = Some(it.next().unwrap_or_else(|| die("option requires an argument -- 't'"))); } break; },
                'S' => { if i + 1 < bytes.len() { cfg.suffix = OsString::from_vec(bytes[i+1..].to_vec()); } else { cfg.suffix = it.next().unwrap_or_else(|| die("option requires an argument -- 'S'")); } break; },
                c => die(&format!("invalid option -- '{}'", c)),
            }
            i += 1;
        }
    }
    if cfg.target_dir.is_some() && cfg.no_target_dir { die("cannot combine --target-directory and --no-target-directory"); }
    (cfg, ops)
}

fn maybe_strip_source(s: OsString) -> OsString {
    let b = s.as_bytes();
    if b.len() <= 1 || !b.ends_with(b"/") { return s; }
    let mut n = b.len();
    while n > 1 && b[n-1] == b'/' { n -= 1; }
    let stripped = OsString::from_vec(b[..n].to_vec());
    if fs::symlink_metadata(&stripped).map(|m| m.file_type().is_symlink()).unwrap_or(false) { s } else { stripped }
}

fn basename(p: &Path) -> OsString {
    let b = p.as_os_str().as_bytes();
    let mut n = b.len();
    while n > 1 && b[n-1] == b'/' { n -= 1; }
    let trimmed = &b[..n];
    let start = trimmed.iter().rposition(|&c| c == b'/').map(|x| x + 1).unwrap_or(0);
    if start >= trimmed.len() { OsString::from("/") } else { OsString::from_vec(trimmed[start..].to_vec()) }
}

fn exists_l(p: &Path) -> bool { fs::symlink_metadata(p).is_ok() }
fn is_dir_follow(p: &Path) -> bool { fs::metadata(p).map(|m| m.is_dir()).unwrap_or(false) }
fn same_file(a: &Path, b: &Path) -> bool {
    match (fs::symlink_metadata(a), fs::symlink_metadata(b)) {
        (Ok(x), Ok(y)) => x.dev() == y.dev() && x.ino() == y.ino(),
        _ => false,
    }
}

fn numbered_backup_name(dst: &Path) -> PathBuf {
    let parent = dst.parent().unwrap_or_else(|| Path::new("."));
    let base = dst.file_name().unwrap_or_else(|| dst.as_os_str()).as_bytes().to_vec();
    let mut maxn = 0u64;
    if let Ok(rd) = fs::read_dir(parent) {
        for e in rd.flatten() {
            let name = e.file_name(); let nb = name.as_bytes();
            if nb.starts_with(&base) && nb.len() > base.len()+3 && nb[base.len()] == b'.' && nb[base.len()+1] == b'~' && nb[nb.len()-1] == b'~' {
                if let Ok(v) = std::str::from_utf8(&nb[base.len()+2..nb.len()-1]).unwrap_or("").parse::<u64>() { if v > maxn { maxn = v; } }
            }
        }
    }
    parent.join(OsString::from_vec([base, format!(".~{}~", maxn + 1).into_bytes()].concat()))
}
fn any_numbered(dst: &Path) -> bool { numbered_backup_name(dst).to_string_lossy().ends_with(".~2~") }

fn backup_path(dst: &Path, cfg: &Config) -> Option<PathBuf> {
    let b = cfg.backup.clone()?;
    match b {
        Backup::None => None,
        Backup::Simple => Some(PathBuf::from(format!("{}{}", dst.to_string_lossy(), cfg.suffix.to_string_lossy()))),
        Backup::Numbered => Some(numbered_backup_name(dst)),
        Backup::Existing => {
            if any_numbered(dst) { Some(numbered_backup_name(dst)) } else { Some(PathBuf::from(format!("{}{}", dst.to_string_lossy(), cfg.suffix.to_string_lossy()))) }
        }
    }
}

fn prompt(dst: &Path) -> bool {
    unsafe { if libc::isatty(libc::STDIN_FILENO) == 0 { return true; } }
    eprint!("mv: overwrite {}? ", q(dst)); let _ = io::stderr().flush();
    let mut line = String::new();
    if io::stdin().lock().read_line(&mut line).is_err() { return false; }
    matches!(line.as_bytes().first(), Some(b'y') | Some(b'Y'))
}

fn copy_tree(src: &Path, dst: &Path) -> io::Result<()> {
    let meta = fs::symlink_metadata(src)?;
    if meta.file_type().is_symlink() {
        let target = fs::read_link(src)?;
        if exists_l(dst) { remove_any(dst)?; }
        symlink(target, dst)
    } else if meta.is_dir() {
        if exists_l(dst) { fs::remove_dir(dst)?; }
        fs::create_dir(dst)?;
        fs::set_permissions(dst, fs::Permissions::from_mode(meta.permissions().mode()))?;
        for ent in fs::read_dir(src)? {
            let ent = ent?;
            copy_tree(&ent.path(), &dst.join(ent.file_name()))?;
        }
        Ok(())
    } else {
        fs::copy(src, dst).map(|_| ())
    }
}
fn remove_any(p: &Path) -> io::Result<()> {
    let m = fs::symlink_metadata(p)?;
    if m.is_dir() && !m.file_type().is_symlink() { fs::remove_dir_all(p) } else { fs::remove_file(p) }
}

fn do_exchange(a: &Path, b: &Path, cfg: &Config) -> bool {
    let ca = match CString::new(a.as_os_str().as_bytes()) { Ok(c) => c, Err(_) => { err("file name contains nul byte"); return false; } };
    let cb = match CString::new(b.as_os_str().as_bytes()) { Ok(c) => c, Err(_) => { err("file name contains nul byte"); return false; } };
    let r = unsafe { libc::syscall(libc::SYS_renameat2, libc::AT_FDCWD, ca.as_ptr(), libc::AT_FDCWD, cb.as_ptr(), libc::RENAME_EXCHANGE) };
    if r == 0 { if cfg.verbose { println!("exchanged {} and {}", q(a), q(b)); } true } else { err(&format!("cannot exchange {} and {}: {}", q(a), q(b), io::Error::last_os_error())); false }
}

fn should_skip(src: &Path, dst: &Path, cfg: &Config) -> Result<bool, bool> {
    if !exists_l(dst) { return Ok(false); }
    if cfg.clobber == Clobber::NoClobber { return Ok(true); }
    match cfg.update {
        Update::None => return Ok(true),
        Update::NoneFail => { err(&format!("not replacing {}", q(dst))); return Err(false); },
        Update::Older => {
            let sm = fs::symlink_metadata(src).and_then(|m| m.modified());
            let dm = fs::symlink_metadata(dst).and_then(|m| m.modified());
            if let (Ok(s), Ok(d)) = (sm, dm) { if s <= d { return Ok(true); } }
        },
        Update::All => {},
    }
    if cfg.clobber == Clobber::Interactive && !prompt(dst) { return Ok(true); }
    Ok(false)
}

fn move_one(src: &Path, dst: &Path, cfg: &Config) -> bool {
    if !exists_l(src) { err(&format!("cannot stat {}: No such file or directory", q(src))); return false; }
    if same_file(src, dst) { err(&format!("{} and {} are the same file", q(src), q(dst))); return false; }
    match should_skip(src, dst, cfg) { Ok(true) => return true, Err(_) => return false, Ok(false) => {} }
    if exists_l(dst) {
        if let Some(bp) = backup_path(dst, cfg) {
            if let Err(e) = fs::rename(dst, &bp) { err(&format!("cannot backup {}: {}", q(dst), e)); return false; }
        }
    }
    match fs::rename(src, dst) {
        Ok(_) => { if cfg.verbose { println!("renamed {} -> {}", q(src), q(dst)); } true },
        Err(e) => {
            if e.raw_os_error() == Some(libc::EXDEV) && !cfg.no_copy {
                match copy_tree(src, dst).and_then(|_| remove_any(src)) {
                    Ok(_) => { if cfg.verbose { println!("renamed {} -> {}", q(src), q(dst)); } true },
                    Err(e2) => { err(&format!("cannot move {} to {}: {}", q(src), q(dst), e2)); false }
                }
            } else { err(&format!("cannot move {} to {}: {}", q(src), q(dst), e)); false }
        }
    }
}

fn main() {
    let (cfg, mut ops) = parse_args();
    if cfg.strip_slashes { ops = ops.into_iter().map(maybe_strip_source).collect(); }
    if cfg.exchange {
        if ops.len() != 2 { die("--exchange requires exactly two file operands"); }
        std::process::exit(if do_exchange(Path::new(&ops[0]), Path::new(&ops[1]), &cfg) { 0 } else { 1 });
    }
    if ops.is_empty() { die("missing file operand"); }
    let mut jobs: Vec<(PathBuf, PathBuf)> = Vec::new();
    if let Some(td) = &cfg.target_dir {
        if ops.is_empty() { die("missing file operand"); }
        let tdp = Path::new(td);
        if !is_dir_follow(tdp) { die(&format!("target directory {} is not a directory", q(tdp))); }
        for s in &ops { jobs.push((PathBuf::from(s), tdp.join(basename(Path::new(s))))); }
    } else {
        if ops.len() < 2 { die("missing destination file operand after source"); }
        let dest = PathBuf::from(ops.pop().unwrap());
        if ops.len() > 1 {
            if cfg.no_target_dir { die("extra operand"); }
            if !is_dir_follow(&dest) { die(&format!("target {} is not a directory", q(&dest))); }
            for s in &ops { jobs.push((PathBuf::from(s), dest.join(basename(Path::new(s))))); }
        } else {
            let src = PathBuf::from(&ops[0]);
            if !cfg.no_target_dir && is_dir_follow(&dest) { jobs.push((src.clone(), dest.join(basename(&src)))); } else { jobs.push((src, dest)); }
        }
    }
    let mut ok = true;
    for (s, d) in jobs { if !move_one(&s, &d, &cfg) { ok = false; } }
    std::process::exit(if ok { 0 } else { 1 });
}
