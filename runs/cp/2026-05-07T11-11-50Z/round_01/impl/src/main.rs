use filetime::{set_file_times, set_symlink_file_times, FileTime};
use std::collections::HashMap;
use std::env;
use std::ffi::{CString, OsStr, OsString};
use std::fs::{self, File, OpenOptions};
use std::io::{self, Read, Write};
use std::os::unix::ffi::OsStrExt;
use std::os::unix::fs::{symlink, MetadataExt, OpenOptionsExt, PermissionsExt};
use std::path::{Component, Path, PathBuf};

#[derive(Clone, Copy, PartialEq)]
enum DerefMode { Default, H, L, P }
#[derive(Clone, Copy, PartialEq)]
enum UpdateMode { All, None, NoneFail, Older }
#[derive(Clone, Copy, PartialEq)]
enum BackupMode { Off, Simple, Numbered, Existing }

struct Opts {
    recursive: bool,
    deref: DerefMode,
    hard_link: bool,
    sym_link: bool,
    force: bool,
    interactive: bool,
    no_clobber: bool,
    remove_destination: bool,
    attributes_only: bool,
    preserve_mode: bool,
    preserve_ownership: bool,
    preserve_timestamps: bool,
    preserve_links: bool,
    parents: bool,
    strip_trailing_slashes: bool,
    target_dir: Option<PathBuf>,
    no_target_dir: bool,
    update: UpdateMode,
    verbose: bool,
    backup: BackupMode,
    suffix: String,
    one_file_system: bool,
    keep_directory_symlink: bool,
    copy_contents: bool,
}
impl Default for Opts {
    fn default() -> Self {
        Self { recursive: false, deref: DerefMode::Default, hard_link: false, sym_link: false, force: false, interactive: false, no_clobber: false, remove_destination: false, attributes_only: false, preserve_mode: false, preserve_ownership: false, preserve_timestamps: false, preserve_links: false, parents: false, strip_trailing_slashes: false, target_dir: None, no_target_dir: false, update: UpdateMode::All, verbose: false, backup: BackupMode::Off, suffix: env::var("SIMPLE_BACKUP_SUFFIX").unwrap_or_else(|_| "~".to_string()), one_file_system: false, keep_directory_symlink: false, copy_contents: false }
    }
}

struct Ctx { link_map: HashMap<(u64,u64), PathBuf>, root_dev: Option<u64> }
enum Prep { Skip, Go { existed: bool } }

type R<T> = Result<T, String>;

fn main() { std::process::exit(match run() { Ok(c) => c, Err(e) => { eprintln!("cp: {}", e); 1 } }); }

fn run() -> R<i32> {
    let (mut opts, mut operands) = parse_args()?;
    if operands.is_empty() { return Err("missing file operand".into()); }
    if opts.strip_trailing_slashes { operands = operands.into_iter().map(strip_slashes).collect(); }
    let jobs: Vec<(PathBuf, PathBuf)>;
    if let Some(dir) = opts.target_dir.clone() {
        if operands.is_empty() { return Err("missing file operand".into()); }
        jobs = operands.iter().map(|s| (s.clone(), dest_in_dir(&dir, s, opts.parents))).collect();
    } else {
        if operands.len() < 2 { return Err(format!("missing destination file operand after '{}'", operands[0].display())); }
        let dest = operands.pop().unwrap();
        if operands.len() > 1 {
            if opts.no_target_dir { return Err("extra operand given with -T".into()); }
            if !is_dir_follow(&dest) { return Err(format!("target '{}' is not a directory", dest.display())); }
            jobs = operands.iter().map(|s| (s.clone(), dest_in_dir(&dest, s, opts.parents))).collect();
        } else if !opts.no_target_dir && is_dir_follow(&dest) {
            let s = operands.pop().unwrap();
            jobs = vec![(s.clone(), dest_in_dir(&dest, &s, opts.parents))];
        } else {
            jobs = vec![(operands.pop().unwrap(), dest)];
        }
    }
    let mut status = 0;
    for (src, dst) in jobs {
        let mut ctx = Ctx { link_map: HashMap::new(), root_dev: None };
        if let Some(p) = dst.parent() { if opts.parents { let _ = fs::create_dir_all(p); } }
        if let Err(e) = copy_entry(&src, &dst, true, &opts, &mut ctx) { eprintln!("cp: {}", e); status = 1; }
    }
    Ok(status)
}

fn parse_args() -> R<(Opts, Vec<PathBuf>)> {
    let mut o = Opts::default();
    let mut ops = Vec::new();
    let mut it = env::args_os().skip(1).peekable();
    while let Some(a) = it.next() {
        let s = a.to_string_lossy();
        if s == "--" { ops.extend(it.map(PathBuf::from)); break; }
        if !s.starts_with('-') || s == "-" { ops.push(PathBuf::from(a)); continue; }
        if s.starts_with("--") {
            let raw = &s[2..];
            let mut sp = raw.splitn(2, '=');
            let name = sp.next().unwrap();
            let val = sp.next();
            match name {
                "archive" => { o.recursive = true; o.deref = DerefMode::P; o.preserve_mode = true; o.preserve_ownership = true; o.preserve_timestamps = true; o.preserve_links = true; },
                "attributes-only" => o.attributes_only = true,
                "backup" => { o.backup = parse_backup(val.map(|x| x.to_string()).or_else(|| env::var("VERSION_CONTROL").ok()).as_deref()); },
                "copy-contents" => o.copy_contents = true,
                "debug" => o.verbose = true,
                "force" => o.force = true,
                "interactive" => { o.interactive = true; o.no_clobber = false; o.update = UpdateMode::All; },
                "link" => o.hard_link = true,
                "dereference" => o.deref = DerefMode::L,
                "no-clobber" => { o.no_clobber = true; o.interactive = false; o.update = UpdateMode::None; },
                "no-dereference" => o.deref = DerefMode::P,
                "preserve" => set_preserve(&mut o, val.unwrap_or("mode,ownership,timestamps"), true),
                "no-preserve" => set_preserve(&mut o, val.ok_or("option '--no-preserve' requires an argument")?, false),
                "parents" => o.parents = true,
                "recursive" => o.recursive = true,
                "remove-destination" => o.remove_destination = true,
                "strip-trailing-slashes" => o.strip_trailing_slashes = true,
                "symbolic-link" => o.sym_link = true,
                "suffix" => o.suffix = val.map(|v| v.to_string()).unwrap_or_else(|| it.next().unwrap_or_default().to_string_lossy().into_owned()),
                "target-directory" => o.target_dir = Some(PathBuf::from(val.map(OsString::from).unwrap_or_else(|| it.next().unwrap_or_default()))),
                "no-target-directory" => o.no_target_dir = true,
                "update" => o.update = parse_update(val.unwrap_or("older"))?,
                "verbose" => o.verbose = true,
                "keep-directory-symlink" => o.keep_directory_symlink = true,
                "one-file-system" => o.one_file_system = true,
                "reflink" | "sparse" | "context" => {},
                "help" => { print_help(); std::process::exit(0); },
                "version" => { println!("util cp 0.1.0"); std::process::exit(0); },
                _ => return Err(format!("unrecognized option '--{}'", name)),
            }
        } else {
            let bytes = a.as_os_str().as_bytes();
            let mut i = 1;
            while i < bytes.len() {
                match bytes[i] as char {
                    'a' => { o.recursive = true; o.deref = DerefMode::P; o.preserve_mode = true; o.preserve_ownership = true; o.preserve_timestamps = true; o.preserve_links = true; },
                    'b' => o.backup = parse_backup(env::var("VERSION_CONTROL").ok().as_deref()),
                    'd' => { o.deref = DerefMode::P; o.preserve_links = true; },
                    'f' => o.force = true,
                    'i' => { o.interactive = true; o.no_clobber = false; o.update = UpdateMode::All; },
                    'H' => o.deref = DerefMode::H,
                    'l' => o.hard_link = true,
                    'L' => o.deref = DerefMode::L,
                    'n' => { o.no_clobber = true; o.interactive = false; o.update = UpdateMode::None; },
                    'P' => o.deref = DerefMode::P,
                    'p' => { o.preserve_mode = true; o.preserve_ownership = true; o.preserve_timestamps = true; },
                    'R' | 'r' => o.recursive = true,
                    's' => o.sym_link = true,
                    'T' => o.no_target_dir = true,
                    'u' => o.update = UpdateMode::Older,
                    'v' => o.verbose = true,
                    'x' => o.one_file_system = true,
                    'Z' => {},
                    'S' | 't' => {
                        let rest = &bytes[i+1..];
                        let val = if !rest.is_empty() { OsString::from(OsStr::from_bytes(rest)) } else { it.next().ok_or("option requires an argument")? };
                        if bytes[i] as char == 'S' { o.suffix = val.to_string_lossy().into_owned(); } else { o.target_dir = Some(PathBuf::from(val)); }
                        break;
                    },
                    c => return Err(format!("invalid option -- '{}'", c)),
                }
                i += 1;
            }
        }
    }
    Ok((o, ops))
}

fn parse_backup(v: Option<&str>) -> BackupMode { match v.unwrap_or("existing") { "none"|"off" => BackupMode::Off, "numbered"|"t" => BackupMode::Numbered, "simple"|"never" => BackupMode::Simple, _ => BackupMode::Existing } }
fn parse_update(v: &str) -> R<UpdateMode> { Ok(match v { "all" => UpdateMode::All, "none" => UpdateMode::None, "none-fail" => UpdateMode::NoneFail, "older" => UpdateMode::Older, _ => return Err(format!("invalid update argument '{}'", v)) }) }
fn set_preserve(o: &mut Opts, list: &str, yes: bool) { for a in list.split(',') { match a { "all" => { o.preserve_mode=yes; o.preserve_ownership=yes; o.preserve_timestamps=yes; o.preserve_links=yes; }, "mode" => o.preserve_mode=yes, "ownership" => o.preserve_ownership=yes, "timestamps" => o.preserve_timestamps=yes, "links" => o.preserve_links=yes, _ => {} } } }

fn print_help() { println!("Usage: cp [OPTION]... SOURCE DEST\n  or:  cp [OPTION]... SOURCE... DIRECTORY\n  or:  cp [OPTION]... -t DIRECTORY SOURCE...\nCopy files and directories. Common options: -a -R -r -f -i -n -p -d -H -L -P -l -s -t -T -u -v --backup --parents."); }

fn copy_entry(src: &Path, dst: &Path, top: bool, o: &Opts, c: &mut Ctx) -> R<()> {
    if o.sym_link { return make_symlink(src, dst, o); }
    let meta = source_meta(src, top, o).map_err(|e| format!("cannot stat '{}': {}", src.display(), e))?;
    if top { c.root_dev = Some(meta.dev()); } else if o.one_file_system && meta.is_dir() && c.root_dev.map_or(false, |d| d != meta.dev()) { return Ok(()); }
    if meta.is_dir() { return copy_dir(src, dst, &meta, top, o, c); }
    if meta.file_type().is_symlink() { return copy_symlink(src, dst, &meta, o); }
    if !meta.is_file() { if o.copy_contents { return copy_regular(src, dst, &meta, o, c); } else { return Err(format!("-r not specified; omitting non-regular file '{}'", src.display())); } }
    copy_regular(src, dst, &meta, o, c)
}

fn source_meta(src: &Path, top: bool, o: &Opts) -> io::Result<fs::Metadata> {
    match o.deref { DerefMode::L => fs::metadata(src), DerefMode::H if top => fs::metadata(src), DerefMode::P | DerefMode::H => fs::symlink_metadata(src), DerefMode::Default => if o.recursive { fs::symlink_metadata(src) } else { fs::metadata(src) } }
}

fn copy_dir(src: &Path, dst: &Path, meta: &fs::Metadata, top: bool, o: &Opts, c: &mut Ctx) -> R<()> {
    if !o.recursive { return Err(format!("-r not specified; omitting directory '{}'", src.display())); }
    if top { if let (Ok(cs), Ok(cd)) = (fs::canonicalize(src), canonical_parent_join(dst)) { if cd.starts_with(&cs) { return Err(format!("cannot copy a directory, '{}', into itself, '{}'", src.display(), dst.display())); } } }
    if dst.exists() {
        if !is_dir_follow(dst) { return Err(format!("cannot overwrite non-directory '{}' with directory '{}'", dst.display(), src.display())); }
    } else {
        fs::create_dir(dst).map_err(|e| format!("cannot create directory '{}': {}", dst.display(), e))?;
    }
    if o.verbose { eprintln!("'{}' -> '{}'", src.display(), dst.display()); }
    for ent in fs::read_dir(src).map_err(|e| format!("cannot read directory '{}': {}", src.display(), e))? {
        let ent = ent.map_err(|e| e.to_string())?;
        let name = ent.file_name();
        copy_entry(&ent.path(), &dst.join(name), false, o, c)?;
    }
    apply_attrs(dst, meta, o, true)
}

fn copy_regular(src: &Path, dst: &Path, meta: &fs::Metadata, o: &Opts, c: &mut Ctx) -> R<()> {
    if o.preserve_links && meta.nlink() > 1 {
        let key = (meta.dev(), meta.ino());
        if let Some(first) = c.link_map.get(&key).cloned() {
            match prepare(dst, Some(meta), true, o)? { Prep::Skip => return Ok(()), Prep::Go{..} => { fs::hard_link(&first, dst).map_err(|e| format!("cannot create hard link '{}': {}", dst.display(), e))?; if o.verbose { eprintln!("'{}' => '{}'", first.display(), dst.display()); } return Ok(()); } }
        }
    }
    if o.hard_link {
        match prepare(dst, Some(meta), true, o)? { Prep::Skip => return Ok(()), Prep::Go{..} => {} }
        fs::hard_link(src, dst).map_err(|e| format!("cannot create hard link '{}': {}", dst.display(), e))?;
        if o.verbose { eprintln!("'{}' => '{}'", src.display(), dst.display()); }
        return Ok(());
    }
    let prep = prepare(dst, Some(meta), false, o)?;
    let existed = match prep { Prep::Skip => return Ok(()), Prep::Go{existed} => existed };
    let mode = meta.mode() & 0o7777;
    let create_mode = if o.preserve_mode { mode } else { mode & !current_umask() };
    let mut out = OpenOptions::new().create(true).write(true).truncate(true).mode(create_mode).open(dst).or_else(|e| {
        if o.force && !o.no_clobber { let _ = remove_existing(dst); OpenOptions::new().create(true).write(true).truncate(true).mode(create_mode).open(dst) } else { Err(e) }
    }).map_err(|e| format!("cannot create regular file '{}': {}", dst.display(), e))?;
    if !o.attributes_only {
        let mut input = File::open(src).map_err(|e| format!("cannot open '{}': {}", src.display(), e))?;
        io::copy(&mut input, &mut out).map_err(|e| format!("error copying '{}': {}", src.display(), e))?;
    }
    drop(out);
    if o.verbose { eprintln!("'{}' -> '{}'", src.display(), dst.display()); }
    if !existed || o.preserve_mode { set_mode(dst, mode)?; }
    apply_attrs(dst, meta, o, false)?;
    if o.preserve_links && meta.nlink() > 1 { c.link_map.insert((meta.dev(), meta.ino()), dst.to_path_buf()); }
    Ok(())
}

fn copy_symlink(src: &Path, dst: &Path, meta: &fs::Metadata, o: &Opts) -> R<()> {
    let target = fs::read_link(src).map_err(|e| format!("cannot read symbolic link '{}': {}", src.display(), e))?;
    match prepare(dst, Some(meta), true, o)? { Prep::Skip => return Ok(()), Prep::Go{..} => {} }
    symlink(&target, dst).map_err(|e| format!("cannot create symbolic link '{}': {}", dst.display(), e))?;
    if o.verbose { eprintln!("'{}' -> '{}'", src.display(), dst.display()); }
    apply_attrs(dst, meta, o, true)
}

fn make_symlink(src: &Path, dst: &Path, o: &Opts) -> R<()> {
    match prepare(dst, None, true, o)? { Prep::Skip => return Ok(()), Prep::Go{..} => {} }
    symlink(src, dst).map_err(|e| format!("cannot create symbolic link '{}': {}", dst.display(), e))?;
    if o.verbose { eprintln!("'{}' -> '{}'", src.display(), dst.display()); }
    Ok(())
}

fn prepare(dst: &Path, src_meta: Option<&fs::Metadata>, need_unlink: bool, o: &Opts) -> R<Prep> {
    let dm = match fs::symlink_metadata(dst) { Ok(m) => m, Err(e) if e.kind()==io::ErrorKind::NotFound => return Ok(Prep::Go{existed:false}), Err(e) => return Err(format!("cannot stat '{}': {}", dst.display(), e)) };
    if let Some(sm) = src_meta {
        if sm.is_file() { if let Ok(fm) = fs::metadata(dst) { if sm.dev()==fm.dev() && sm.ino()==fm.ino() { if o.force && o.backup != BackupMode::Off { make_backup_copy(dst, o)?; return Ok(Prep::Skip); } else { return Err(format!("'{}' and '{}' are the same file", dst.display(), dst.display())); } } } }
        match o.update { UpdateMode::None => return Ok(Prep::Skip), UpdateMode::NoneFail => return Err(format!("not replacing '{}': file exists", dst.display())), UpdateMode::Older => if !older(&dm, sm) { return Ok(Prep::Skip); }, UpdateMode::All => {} }
    } else if o.no_clobber { return Ok(Prep::Skip); }
    if o.no_clobber { return Ok(Prep::Skip); }
    if o.interactive && !confirm(dst)? { return Ok(Prep::Skip); }
    if o.backup != BackupMode::Off { make_backup_rename(dst, o)?; return Ok(Prep::Go{existed:false}); }
    if o.remove_destination || need_unlink { remove_existing(dst)?; return Ok(Prep::Go{existed:false}); }
    Ok(Prep::Go{existed:true})
}

fn confirm(dst: &Path) -> R<bool> { eprint!("cp: overwrite '{}'? ", dst.display()); let _ = io::stderr().flush(); let mut s = String::new(); io::stdin().read_line(&mut s).map_err(|e| e.to_string())?; Ok(matches!(s.as_bytes().first(), Some(b'y')|Some(b'Y'))) }
fn older(dst: &fs::Metadata, src: &fs::Metadata) -> bool { (dst.mtime(), dst.mtime_nsec()) < (src.mtime(), src.mtime_nsec()) }

fn make_backup_rename(dst: &Path, o: &Opts) -> R<()> { let b = backup_name(dst, o); fs::rename(dst, &b).map_err(|e| format!("cannot backup '{}': {}", dst.display(), e)) }
fn make_backup_copy(dst: &Path, o: &Opts) -> R<()> { let b = backup_name(dst, o); fs::copy(dst, &b).map_err(|e| format!("cannot backup '{}': {}", dst.display(), e)).map(|_| ()) }
fn backup_name(dst: &Path, o: &Opts) -> PathBuf { match effective_backup(o, dst) { BackupMode::Numbered => numbered_backup(dst), _ => PathBuf::from(format!("{}{}", dst.as_os_str().to_string_lossy(), o.suffix)) } }
fn effective_backup(o: &Opts, dst: &Path) -> BackupMode { if o.backup == BackupMode::Existing { if has_numbered(dst) { BackupMode::Numbered } else { BackupMode::Simple } } else { o.backup } }
fn numbered_backup(dst: &Path) -> PathBuf { let base = dst.as_os_str().to_string_lossy(); for n in 1.. { let p = PathBuf::from(format!("{}.~{}~", base, n)); if !p.exists() { return p; } } unreachable!() }
fn has_numbered(dst: &Path) -> bool { let dir = dst.parent().unwrap_or_else(|| Path::new(".")); let stem = dst.file_name().unwrap_or_default().to_string_lossy().into_owned() + ".~"; if let Ok(rd) = fs::read_dir(dir) { for e in rd.flatten() { let n = e.file_name().to_string_lossy().into_owned(); if n.starts_with(&stem) && n.ends_with('~') { return true; } } } false }

fn apply_attrs(dst: &Path, meta: &fs::Metadata, o: &Opts, symlink_obj: bool) -> R<()> {
    if o.preserve_mode && !symlink_obj { set_mode(dst, meta.mode() & 0o7777)?; }
    if o.preserve_ownership { let _ = chown_path(dst, meta.uid(), meta.gid(), symlink_obj); }
    if o.preserve_timestamps { let at = FileTime::from_last_access_time(meta); let mt = FileTime::from_last_modification_time(meta); if symlink_obj { let _ = set_symlink_file_times(dst, at, mt); } else { set_file_times(dst, at, mt).map_err(|e| format!("preserving times for '{}': {}", dst.display(), e))?; } }
    Ok(())
}
fn set_mode(p: &Path, mode: u32) -> R<()> { fs::set_permissions(p, fs::Permissions::from_mode(mode)).map_err(|e| format!("setting permissions for '{}': {}", p.display(), e)) }
fn chown_path(p: &Path, uid: u32, gid: u32, nofollow: bool) -> io::Result<()> { let c = CString::new(p.as_os_str().as_bytes()).unwrap(); let r = unsafe { if nofollow { libc::lchown(c.as_ptr(), uid, gid) } else { libc::chown(c.as_ptr(), uid, gid) } }; if r == 0 { Ok(()) } else { Err(io::Error::last_os_error()) } }
fn current_umask() -> u32 { unsafe { let m = libc::umask(0); libc::umask(m); m as u32 } }

fn remove_existing(p: &Path) -> R<()> { let m = fs::symlink_metadata(p).map_err(|e| e.to_string())?; if m.is_dir() && !m.file_type().is_symlink() { return Err(format!("cannot overwrite directory '{}'", p.display())); } fs::remove_file(p).map_err(|e| format!("cannot remove '{}': {}", p.display(), e)) }
fn is_dir_follow(p: &Path) -> bool { fs::metadata(p).map(|m| m.is_dir()).unwrap_or(false) }
fn dest_in_dir(dir: &Path, src: &Path, parents: bool) -> PathBuf { if parents { let mut d = dir.to_path_buf(); for c in src.components() { match c { Component::Normal(x) => d.push(x), Component::CurDir => d.push("."), Component::ParentDir => d.push(".."), _ => {} } } d } else { dir.join(src.file_name().unwrap_or_else(|| OsStr::new(""))) } }
fn strip_slashes(mut p: PathBuf) -> PathBuf { let s = p.as_os_str().to_string_lossy(); if s.len() > 1 { let t = s.trim_end_matches('/'); if !t.is_empty() { p = PathBuf::from(t); } } p }
fn canonical_parent_join(p: &Path) -> io::Result<PathBuf> { if p.exists() { fs::canonicalize(p) } else { Ok(fs::canonicalize(p.parent().unwrap_or_else(|| Path::new(".")))?.join(p.file_name().unwrap_or_default())) } }
