use filetime::{set_file_times, set_symlink_file_times, FileTime};
use std::collections::HashMap;
use std::env;
use std::ffi::CString;
use std::fs::{self, File, OpenOptions};
use std::io::{self, Read, Write};
use std::os::unix::ffi::OsStrExt;
use std::os::unix::fs::{symlink, MetadataExt, PermissionsExt};
use std::path::{Path, PathBuf};

#[derive(Clone, Copy, PartialEq)]
enum DerefMode { Default, H, L, P }
#[derive(Clone, Copy, PartialEq)]
enum UpdateMode { All, None, NoneFail, Older }
#[derive(Clone, Copy, PartialEq)]
enum BackupControl { None, Simple, Numbered, Existing }

struct Opts {
    recursive: bool,
    force: bool,
    interactive: bool,
    no_clobber: bool,
    remove_destination: bool,
    verbose: bool,
    debug: bool,
    target_dir: Option<PathBuf>,
    no_target_dir: bool,
    parents: bool,
    strip_trailing_slashes: bool,
    hard_link: bool,
    symbolic_link: bool,
    attributes_only: bool,
    copy_contents: bool,
    one_file_system: bool,
    keep_directory_symlink: bool,
    deref: DerefMode,
    preserve_mode: bool,
    preserve_ownership: bool,
    preserve_timestamps: bool,
    preserve_links: bool,
    backup: Option<BackupControl>,
    suffix: String,
    update: UpdateMode,
}

impl Default for Opts {
    fn default() -> Self {
        Self {
            recursive: false, force: false, interactive: false, no_clobber: false,
            remove_destination: false, verbose: false, debug: false, target_dir: None,
            no_target_dir: false, parents: false, strip_trailing_slashes: false,
            hard_link: false, symbolic_link: false, attributes_only: false, copy_contents: false,
            one_file_system: false, keep_directory_symlink: false, deref: DerefMode::Default,
            preserve_mode: false, preserve_ownership: false, preserve_timestamps: false,
            preserve_links: false, backup: None,
            suffix: env::var("SIMPLE_BACKUP_SUFFIX").unwrap_or_else(|_| "~".to_string()),
            update: UpdateMode::All,
        }
    }
}

struct Ctx { opts: Opts, seen_links: HashMap<(u64, u64), PathBuf>, umask: u32 }

fn usage() {
    println!("Usage: cp [OPTION]... [-T] SOURCE DEST\n  or:  cp [OPTION]... SOURCE... DIRECTORY\n  or:  cp [OPTION]... -t DIRECTORY SOURCE...\nCopy SOURCE to DEST, or multiple SOURCE(s) to DIRECTORY.");
}

fn version() { println!("cp (rust coreutils-compatible) 0.1.0"); }

fn parse_backup_control(s: &str) -> Result<BackupControl, String> {
    match s {
        "none" | "off" => Ok(BackupControl::None),
        "numbered" | "t" => Ok(BackupControl::Numbered),
        "existing" | "nil" => Ok(BackupControl::Existing),
        "simple" | "never" => Ok(BackupControl::Simple),
        _ => Err(format!("invalid backup type '{}'", s)),
    }
}

fn default_backup_control() -> BackupControl {
    env::var("VERSION_CONTROL").ok().and_then(|v| parse_backup_control(&v).ok()).unwrap_or(BackupControl::Existing)
}

fn parse_update(s: &str) -> Result<UpdateMode, String> {
    match s { "all" => Ok(UpdateMode::All), "none" => Ok(UpdateMode::None), "none-fail" => Ok(UpdateMode::NoneFail), "older" => Ok(UpdateMode::Older), _ => Err(format!("invalid update value '{}'", s)) }
}

fn set_preserve(opts: &mut Opts, list: Option<&str>, val: bool) {
    let attrs = list.unwrap_or("mode,ownership,timestamps");
    for a in attrs.split(',') {
        match a {
            "all" => { opts.preserve_mode = val; opts.preserve_ownership = val; opts.preserve_timestamps = val; opts.preserve_links = val; }
            "mode" => opts.preserve_mode = val,
            "ownership" => opts.preserve_ownership = val,
            "timestamps" => opts.preserve_timestamps = val,
            "links" => opts.preserve_links = val,
            "context" | "xattr" => {},
            "" => {},
            _ => {},
        }
    }
}

fn parse_args() -> Result<(Opts, Vec<String>), String> {
    let mut opts = Opts::default();
    let mut operands = Vec::new();
    let mut it = env::args().skip(1).peekable();
    while let Some(arg) = it.next() {
        if arg == "--" { operands.extend(it); break; }
        if arg == "-" || !arg.starts_with('-') { operands.push(arg); continue; }
        if arg.starts_with("--") {
            let (name, val) = if let Some(p) = arg.find('=') { (&arg[2..p], Some(&arg[p+1..])) } else { (&arg[2..], None) };
            match name {
                "help" => { usage(); std::process::exit(0); }
                "version" => { version(); std::process::exit(0); }
                "archive" => { opts.recursive = true; opts.deref = DerefMode::P; opts.preserve_mode = true; opts.preserve_ownership = true; opts.preserve_timestamps = true; opts.preserve_links = true; }
                "attributes-only" => opts.attributes_only = true,
                "backup" => opts.backup = Some(if let Some(v) = val { parse_backup_control(v)? } else { default_backup_control() }),
                "copy-contents" => opts.copy_contents = true,
                "debug" => { opts.debug = true; opts.verbose = true; }
                "force" => opts.force = true,
                "interactive" => { opts.interactive = true; opts.no_clobber = false; }
                "link" => opts.hard_link = true,
                "dereference" => opts.deref = DerefMode::L,
                "no-clobber" => { opts.no_clobber = true; opts.interactive = false; }
                "no-dereference" => opts.deref = DerefMode::P,
                "preserve" => set_preserve(&mut opts, val, true),
                "no-preserve" => set_preserve(&mut opts, val, false),
                "parents" => opts.parents = true,
                "recursive" => opts.recursive = true,
                "remove-destination" => opts.remove_destination = true,
                "strip-trailing-slashes" => opts.strip_trailing_slashes = true,
                "symbolic-link" => opts.symbolic_link = true,
                "suffix" => opts.suffix = val.map(str::to_string).ok_or("--suffix requires an argument")?,
                "target-directory" => opts.target_dir = Some(PathBuf::from(val.map(str::to_string).or_else(|| it.next()).ok_or("--target-directory requires an argument")?)),
                "no-target-directory" => opts.no_target_dir = true,
                "update" => opts.update = if let Some(v) = val { parse_update(v)? } else { UpdateMode::Older },
                "verbose" => opts.verbose = true,
                "keep-directory-symlink" => opts.keep_directory_symlink = true,
                "one-file-system" => opts.one_file_system = true,
                "context" | "reflink" | "sparse" => {},
                _ => return Err(format!("unrecognized option '--{}'", name)),
            }
        } else {
            let mut chars = arg[1..].chars().peekable();
            while let Some(c) = chars.next() {
                match c {
                    'a' => { opts.recursive = true; opts.deref = DerefMode::P; opts.preserve_mode = true; opts.preserve_ownership = true; opts.preserve_timestamps = true; opts.preserve_links = true; }
                    'b' => opts.backup = Some(default_backup_control()),
                    'd' => { opts.deref = DerefMode::P; opts.preserve_links = true; }
                    'f' => opts.force = true,
                    'i' => { opts.interactive = true; opts.no_clobber = false; }
                    'H' => opts.deref = DerefMode::H,
                    'l' => opts.hard_link = true,
                    'L' => opts.deref = DerefMode::L,
                    'n' => { opts.no_clobber = true; opts.interactive = false; }
                    'P' => opts.deref = DerefMode::P,
                    'p' => { opts.preserve_mode = true; opts.preserve_ownership = true; opts.preserve_timestamps = true; }
                    'R' | 'r' => opts.recursive = true,
                    's' => opts.symbolic_link = true,
                    'S' => { let rest: String = chars.collect(); opts.suffix = if rest.is_empty() { it.next().ok_or("-S requires an argument")? } else { rest }; break; }
                    't' => { let rest: String = chars.collect(); opts.target_dir = Some(PathBuf::from(if rest.is_empty() { it.next().ok_or("-t requires an argument")? } else { rest })); break; }
                    'T' => opts.no_target_dir = true,
                    'u' => opts.update = UpdateMode::Older,
                    'v' => opts.verbose = true,
                    'x' => opts.one_file_system = true,
                    'Z' => {},
                    _ => return Err(format!("invalid option -- '{}'", c)),
                }
            }
        }
    }
    Ok((opts, operands))
}

fn get_umask() -> u32 { unsafe { let m = libc::umask(0); libc::umask(m); m as u32 } }

fn strip_trailing(s: &str) -> String {
    if s == "/" { return s.to_string(); }
    let t = s.trim_end_matches('/');
    if t.is_empty() { "/".to_string() } else { t.to_string() }
}

fn base_name(p: &Path) -> Result<&std::ffi::OsStr, String> { p.file_name().ok_or_else(|| format!("cannot get file name of '{}'", p.display())) }

fn source_metadata(path: &Path, opts: &Opts, cmdline: bool) -> io::Result<fs::Metadata> {
    let sm = fs::symlink_metadata(path)?;
    if sm.file_type().is_symlink() {
        let follow = match opts.deref { DerefMode::L => true, DerefMode::H => cmdline, DerefMode::P => false, DerefMode::Default => !opts.recursive };
        if follow { fs::metadata(path) } else { Ok(sm) }
    } else { Ok(sm) }
}

fn same_file(a: &fs::Metadata, b: &fs::Metadata) -> bool { a.dev() == b.dev() && a.ino() == b.ino() }

fn verbose(opts: &Opts, src: &Path, dst: &Path) { if opts.verbose { println!("'{}' -> '{}'", src.display(), dst.display()); } }

fn prompt_overwrite(dst: &Path) -> bool {
    eprint!("cp: overwrite '{}'? ", dst.display()); let _ = io::stderr().flush();
    let mut s = String::new(); if io::stdin().read_line(&mut s).is_ok() { s.starts_with('y') || s.starts_with('Y') } else { false }
}

fn numbered_backup_name(dst: &Path) -> PathBuf {
    let base = dst.to_string_lossy();
    for n in 1..1000000 { let p = PathBuf::from(format!("{}.~{}~", base, n)); if !p.exists() { return p; } }
    PathBuf::from(format!("{}.~1~", base))
}

fn has_numbered_backup(dst: &Path) -> bool {
    let base = dst.to_string_lossy();
    for n in 1..1000 { if PathBuf::from(format!("{}.~{}~", base, n)).exists() { return true; } }
    false
}

fn make_backup(dst: &Path, opts: &Opts) -> Result<(), String> {
    let Some(mut ctl) = opts.backup else { return Ok(()); };
    if ctl == BackupControl::Existing { ctl = if has_numbered_backup(dst) { BackupControl::Numbered } else { BackupControl::Simple }; }
    if ctl == BackupControl::None { return Ok(()); }
    let backup = if ctl == BackupControl::Numbered { numbered_backup_name(dst) } else { PathBuf::from(format!("{}{}", dst.to_string_lossy(), opts.suffix)) };
    fs::rename(dst, &backup).map_err(|e| format!("cannot backup '{}' to '{}': {}", dst.display(), backup.display(), e))
}

fn remove_path(p: &Path) -> io::Result<()> {
    let md = fs::symlink_metadata(p)?;
    if md.is_dir() && !md.file_type().is_symlink() { fs::remove_dir_all(p) } else { fs::remove_file(p) }
}

fn older_or_equal(src: &fs::Metadata, dst: &fs::Metadata) -> bool {
    (dst.mtime(), dst.mtime_nsec()) >= (src.mtime(), src.mtime_nsec())
}

fn prepare_existing(src: &Path, dst: &Path, src_md: &fs::Metadata, opts: &Opts, unlink_for_create: bool) -> Result<bool, String> {
    let Ok(dst_md_follow) = fs::metadata(dst) else { return Ok(true); };
    if same_file(src_md, &dst_md_follow) {
        if opts.force && opts.backup.is_some() && src_md.is_file() { make_backup(dst, opts)?; return Ok(false); }
        return Err(format!("'{}' and '{}' are the same file", src.display(), dst.display()));
    }
    if opts.no_clobber || opts.update == UpdateMode::None { return Ok(false); }
    if opts.update == UpdateMode::NoneFail { return Err(format!("not replacing '{}'; destination exists", dst.display())); }
    if opts.update == UpdateMode::Older && older_or_equal(src_md, &dst_md_follow) { return Ok(false); }
    if opts.interactive && !prompt_overwrite(dst) { return Ok(false); }
    if opts.backup.is_some() { make_backup(dst, opts)?; }
    if opts.remove_destination || unlink_for_create { remove_path(dst).map_err(|e| format!("cannot remove '{}': {}", dst.display(), e))?; }
    Ok(true)
}

fn c_path(p: &Path) -> CString { CString::new(p.as_os_str().as_bytes()).unwrap() }

fn apply_attrs(path: &Path, md: &fs::Metadata, opts: &Opts, is_symlink: bool, umask: u32) {
    if opts.preserve_ownership {
        let c = c_path(path);
        let rc = unsafe { if is_symlink { libc::lchown(c.as_ptr(), md.uid(), md.gid()) } else { libc::chown(c.as_ptr(), md.uid(), md.gid()) } };
        if rc != 0 && unsafe { libc::geteuid() } == 0 { eprintln!("cp: failed to preserve ownership for '{}'", path.display()); }
    }
    if opts.preserve_mode && !is_symlink {
        let _ = fs::set_permissions(path, fs::Permissions::from_mode((md.mode() & 0o7777) as u32));
    } else if !opts.preserve_mode && !is_symlink {
        let _ = fs::set_permissions(path, fs::Permissions::from_mode(((md.mode() as u32) & 0o777) & !umask));
    }
    if opts.preserve_timestamps {
        let at = FileTime::from_unix_time(md.atime(), md.atime_nsec() as u32);
        let mt = FileTime::from_unix_time(md.mtime(), md.mtime_nsec() as u32);
        let _ = if is_symlink { set_symlink_file_times(path, at, mt) } else { set_file_times(path, at, mt) };
    }
}

fn ensure_parent(dst: &Path) -> Result<(), String> {
    if let Some(p) = dst.parent() { if !p.as_os_str().is_empty() { fs::create_dir_all(p).map_err(|e| format!("cannot create directory '{}': {}", p.display(), e))?; } }
    Ok(())
}

fn copy_regular(src: &Path, dst: &Path, md: &fs::Metadata, ctx: &mut Ctx) -> Result<(), String> {
    if ctx.opts.attributes_only {
        OpenOptions::new().create(true).write(true).open(dst).map_err(|e| format!("cannot create '{}': {}", dst.display(), e))?;
    } else {
        let mut input = File::open(src).map_err(|e| format!("cannot open '{}' for reading: {}", src.display(), e))?;
        let mut out = match OpenOptions::new().create(true).write(true).truncate(true).open(dst) {
            Ok(f) => f,
            Err(e) if ctx.opts.force && !ctx.opts.no_clobber => { let _ = remove_path(dst); OpenOptions::new().create(true).write(true).truncate(true).open(dst).map_err(|e2| format!("cannot create '{}': {}", dst.display(), e2))? }
            Err(e) => return Err(format!("cannot create '{}': {}", dst.display(), e)),
        };
        io::copy(&mut input, &mut out).map_err(|e| format!("error copying '{}' to '{}': {}", src.display(), dst.display(), e))?;
    }
    apply_attrs(dst, md, &ctx.opts, false, ctx.umask);
    Ok(())
}

fn copy_filelike(src: &Path, dst: &Path, md: &fs::Metadata, ctx: &mut Ctx) -> Result<(), String> {
    ensure_parent(dst)?;
    let ft = md.file_type();
    let unlink = ctx.opts.hard_link || ctx.opts.symbolic_link || ft.is_symlink();
    if !prepare_existing(src, dst, md, &ctx.opts, unlink)? { return Ok(()); }
    verbose(&ctx.opts, src, dst);
    if ctx.opts.symbolic_link {
        symlink(src, dst).map_err(|e| format!("cannot create symbolic link '{}' to '{}': {}", dst.display(), src.display(), e))?;
        return Ok(());
    }
    if ctx.opts.hard_link {
        let link_src = if ctx.opts.deref == DerefMode::L { fs::canonicalize(src).unwrap_or_else(|_| src.to_path_buf()) } else { src.to_path_buf() };
        fs::hard_link(&link_src, dst).map_err(|e| format!("cannot create hard link '{}' to '{}': {}", dst.display(), src.display(), e))?;
        return Ok(());
    }
    if ft.is_symlink() {
        let target = fs::read_link(src).map_err(|e| format!("cannot read symbolic link '{}': {}", src.display(), e))?;
        symlink(&target, dst).map_err(|e| format!("cannot create symbolic link '{}': {}", dst.display(), e))?;
        apply_attrs(dst, md, &ctx.opts, true, ctx.umask);
        return Ok(());
    }
    if !ft.is_file() { return Err(format!("cannot copy special file '{}'", src.display())); }
    if ctx.opts.preserve_links && md.nlink() > 1 {
        let key = (md.dev(), md.ino());
        if let Some(first) = ctx.seen_links.get(&key) {
            fs::hard_link(first, dst).map_err(|e| format!("cannot preserve hard link '{}': {}", dst.display(), e))?;
            return Ok(());
        }
        ctx.seen_links.insert(key, dst.to_path_buf());
    }
    copy_regular(src, dst, md, ctx)
}

fn copy_dir(src: &Path, dst: &Path, md: &fs::Metadata, ctx: &mut Ctx, root_dev: u64) -> Result<(), String> {
    if dst.exists() {
        let dmd = fs::metadata(dst).map_err(|e| format!("cannot stat '{}': {}", dst.display(), e))?;
        if !dmd.is_dir() { return Err(format!("cannot overwrite non-directory '{}' with directory '{}'", dst.display(), src.display())); }
    } else {
        ensure_parent(dst)?;
        verbose(&ctx.opts, src, dst);
        fs::create_dir(dst).map_err(|e| format!("cannot create directory '{}': {}", dst.display(), e))?;
    }
    for ent in fs::read_dir(src).map_err(|e| format!("cannot read directory '{}': {}", src.display(), e))? {
        let ent = ent.map_err(|e| e.to_string())?;
        let sp = ent.path(); let dp = dst.join(ent.file_name());
        if ctx.opts.one_file_system {
            if let Ok(cm) = source_metadata(&sp, &ctx.opts, false) { if cm.is_dir() && cm.dev() != root_dev { continue; } }
        }
        copy_item(&sp, &dp, ctx, false, root_dev)?;
    }
    apply_attrs(dst, md, &ctx.opts, false, ctx.umask);
    Ok(())
}

fn copy_item(src: &Path, dst: &Path, ctx: &mut Ctx, cmdline: bool, root_dev: u64) -> Result<(), String> {
    let md = source_metadata(src, &ctx.opts, cmdline).map_err(|e| format!("cannot stat '{}': {}", src.display(), e))?;
    if md.is_dir() {
        if !ctx.opts.recursive { return Err(format!("-r not specified; omitting directory '{}'", src.display())); }
        if let (Ok(sc), Ok(dc)) = (fs::canonicalize(src), dst.parent().map(fs::canonicalize).transpose().unwrap_or(Ok(PathBuf::new()))) {
            if dc.starts_with(&sc) { return Err(format!("cannot copy a directory, '{}', into itself, '{}'", src.display(), dst.display())); }
        }
        copy_dir(src, dst, &md, ctx, if cmdline { md.dev() } else { root_dev })
    } else { copy_filelike(src, dst, &md, ctx) }
}

fn build_jobs(opts: &Opts, operands: Vec<String>) -> Result<Vec<(PathBuf, PathBuf)>, String> {
    let ops: Vec<PathBuf> = operands.into_iter().map(|s| PathBuf::from(if opts.strip_trailing_slashes { strip_trailing(&s) } else { s })).collect();
    let mut jobs = Vec::new();
    if let Some(tdir) = &opts.target_dir {
        if ops.is_empty() { return Err("missing file operand".to_string()); }
        for src in ops {
            let dst = if opts.parents { let rel = src.strip_prefix("/").unwrap_or(&src); tdir.join(rel) } else { tdir.join(base_name(&src)?) };
            jobs.push((src, dst));
        }
    } else {
        if ops.len() < 2 { return Err("missing destination file operand".to_string()); }
        let dest = ops.last().unwrap().clone();
        let sources = &ops[..ops.len()-1];
        if sources.len() > 1 {
            if opts.no_target_dir { return Err("extra operand after target file".to_string()); }
            if !dest.is_dir() { return Err(format!("target '{}' is not a directory", dest.display())); }
            for src in sources { jobs.push((src.clone(), dest.join(base_name(src)?))); }
        } else {
            let src = sources[0].clone();
            let dst = if !opts.no_target_dir && dest.is_dir() { dest.join(base_name(&src)?) } else { dest };
            jobs.push((src, dst));
        }
    }
    Ok(jobs)
}

fn run() -> Result<i32, String> {
    let (opts, operands) = parse_args()?;
    let jobs = build_jobs(&opts, operands)?;
    let mut ctx = Ctx { opts, seen_links: HashMap::new(), umask: get_umask() };
    let mut status = 0;
    for (src, dst) in jobs {
        let root_dev = source_metadata(&src, &ctx.opts, true).map(|m| m.dev()).unwrap_or(0);
        if let Err(e) = copy_item(&src, &dst, &mut ctx, true, root_dev) { eprintln!("cp: {}", e); status = 1; }
    }
    Ok(status)
}

fn main() {
    match run() { Ok(code) => std::process::exit(code), Err(e) => { eprintln!("cp: {}", e); std::process::exit(1); } }
}
