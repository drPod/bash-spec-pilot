use clap::{Arg, ArgAction, Command};
use filetime::{set_file_times, FileTime};
use std::collections::HashMap;
use std::ffi::CString;
use std::fs::{self, File, OpenOptions};
use std::io::{self, Read, Write};
use std::os::unix::ffi::OsStrExt;
use std::os::unix::fs::{symlink, FileTypeExt, MetadataExt, OpenOptionsExt, PermissionsExt};
use std::path::{Component, Path, PathBuf};
use std::process;

#[derive(Clone, Copy, PartialEq, Eq)]
enum DerefMode {
    Default,
    Always,
    Never,
    CommandLine,
}

#[derive(Clone, Copy, PartialEq, Eq)]
enum UpdateMode {
    All,
    None,
    NoneFail,
    Older,
}

#[derive(Clone, Copy, PartialEq, Eq)]
enum BackupMode {
    None,
    Simple,
    Numbered,
    Existing,
}

#[derive(Clone, Copy, Default)]
struct Preserve {
    mode: bool,
    ownership: bool,
    timestamps: bool,
    links: bool,
}

struct Options {
    recursive: bool,
    attributes_only: bool,
    copy_contents: bool,
    force: bool,
    interactive: bool,
    no_clobber: bool,
    link: bool,
    symbolic_link: bool,
    remove_destination: bool,
    parents: bool,
    no_target_directory: bool,
    strip_trailing_slashes: bool,
    verbose: bool,
    keep_directory_symlink: bool,
    one_file_system: bool,
    deref: DerefMode,
    update: UpdateMode,
    backup: BackupMode,
    suffix: String,
    preserve: Preserve,
}

struct Copier {
    opts: Options,
    hardlinks: HashMap<(u64, u64), PathBuf>,
    failed: bool,
}

fn main() {
    let matches = Command::new("cp")
        .disable_help_flag(false)
        .disable_version_flag(true)
        .version("cp (rust implementation) 0.1")
        .arg(Arg::new("archive").short('a').long("archive").action(ArgAction::SetTrue))
        .arg(Arg::new("attributes_only").long("attributes-only").action(ArgAction::SetTrue))
        .arg(Arg::new("backup").long("backup").num_args(0..=1).require_equals(true).default_missing_value("existing"))
        .arg(Arg::new("backup_short").short('b').action(ArgAction::SetTrue))
        .arg(Arg::new("copy_contents").long("copy-contents").action(ArgAction::SetTrue))
        .arg(Arg::new("debug").long("debug").action(ArgAction::SetTrue))
        .arg(Arg::new("force").short('f').long("force").action(ArgAction::SetTrue))
        .arg(Arg::new("interactive").short('i').long("interactive").action(ArgAction::SetTrue))
        .arg(Arg::new("H").short('H').action(ArgAction::SetTrue))
        .arg(Arg::new("link").short('l').long("link").action(ArgAction::SetTrue))
        .arg(Arg::new("L").short('L').long("dereference").action(ArgAction::SetTrue))
        .arg(Arg::new("no_clobber").short('n').long("no-clobber").action(ArgAction::SetTrue))
        .arg(Arg::new("P").short('P').long("no-dereference").action(ArgAction::SetTrue))
        .arg(Arg::new("preserve_short").short('p').action(ArgAction::SetTrue))
        .arg(Arg::new("preserve").long("preserve").num_args(0..=1).require_equals(true).default_missing_value("mode,ownership,timestamps"))
        .arg(Arg::new("no_preserve").long("no-preserve").num_args(1))
        .arg(Arg::new("parents").long("parents").action(ArgAction::SetTrue))
        .arg(Arg::new("recursive").short('R').short('r').long("recursive").action(ArgAction::SetTrue))
        .arg(Arg::new("reflink").long("reflink").num_args(0..=1).require_equals(true).default_missing_value("always"))
        .arg(Arg::new("remove_destination").long("remove-destination").action(ArgAction::SetTrue))
        .arg(Arg::new("sparse").long("sparse").num_args(1))
        .arg(Arg::new("strip_trailing_slashes").long("strip-trailing-slashes").action(ArgAction::SetTrue))
        .arg(Arg::new("symbolic_link").short('s').long("symbolic-link").action(ArgAction::SetTrue))
        .arg(Arg::new("suffix").short('S').long("suffix").num_args(1))
        .arg(Arg::new("target_directory").short('t').long("target-directory").num_args(1))
        .arg(Arg::new("no_target_directory").short('T').long("no-target-directory").action(ArgAction::SetTrue))
        .arg(Arg::new("update").short('u').long("update").num_args(0..=1).require_equals(true).default_missing_value("older"))
        .arg(Arg::new("verbose").short('v').long("verbose").action(ArgAction::SetTrue))
        .arg(Arg::new("keep_directory_symlink").long("keep-directory-symlink").action(ArgAction::SetTrue))
        .arg(Arg::new("one_file_system").short('x').long("one-file-system").action(ArgAction::SetTrue))
        .arg(Arg::new("context").short('Z').long("context").num_args(0..=1).require_equals(true).default_missing_value(""))
        .arg(Arg::new("version_long").long("version").action(ArgAction::SetTrue))
        .arg(Arg::new("paths").num_args(0..).action(ArgAction::Append))
        .get_matches();

    if matches.get_flag("version_long") {
        println!("cp (rust implementation) 0.1");
        return;
    }

    let archive = matches.get_flag("archive");
    let mut preserve = Preserve::default();
    if archive {
        preserve = Preserve { mode: true, ownership: true, timestamps: true, links: true };
    }
    if matches.get_flag("preserve_short") {
        preserve.mode = true;
        preserve.ownership = true;
        preserve.timestamps = true;
    }
    if let Some(v) = matches.get_one::<String>("preserve") {
        apply_preserve(v, &mut preserve, true);
    }
    if let Some(v) = matches.get_one::<String>("no_preserve") {
        apply_preserve(v, &mut preserve, false);
    }

    let deref = if archive || matches.get_flag("P") {
        DerefMode::Never
    } else if matches.get_flag("L") {
        DerefMode::Always
    } else if matches.get_flag("H") {
        DerefMode::CommandLine
    } else {
        DerefMode::Default
    };

    let update = match matches.get_one::<String>("update").map(|s| s.as_str()) {
        None => UpdateMode::All,
        Some("all") => UpdateMode::All,
        Some("none") => UpdateMode::None,
        Some("none-fail") => UpdateMode::NoneFail,
        Some("older") => UpdateMode::Older,
        Some(x) => die(&format!("invalid update value '{}'", x)),
    };

    let suffix = matches.get_one::<String>("suffix").cloned()
        .or_else(|| std::env::var("SIMPLE_BACKUP_SUFFIX").ok())
        .unwrap_or_else(|| "~".to_string());
    let backup_requested = matches.get_flag("backup_short") || matches.contains_id("backup") && matches.get_one::<String>("backup").is_some();
    let backup_control = matches.get_one::<String>("backup").map(|s| s.as_str())
        .or_else(|| if backup_requested { std::env::var("VERSION_CONTROL").ok().as_deref() } else { None });
    let backup = if backup_requested {
        match backup_control.unwrap_or("existing") {
            "none" | "off" => BackupMode::None,
            "numbered" | "t" => BackupMode::Numbered,
            "existing" | "nil" => BackupMode::Existing,
            "simple" | "never" => BackupMode::Simple,
            x => die(&format!("invalid backup type '{}'", x)),
        }
    } else {
        BackupMode::None
    };

    let opts = Options {
        recursive: archive || matches.get_flag("recursive"),
        attributes_only: matches.get_flag("attributes_only"),
        copy_contents: matches.get_flag("copy_contents"),
        force: matches.get_flag("force"),
        interactive: matches.get_flag("interactive"),
        no_clobber: matches.get_flag("no_clobber") && !matches.get_flag("interactive"),
        link: matches.get_flag("link"),
        symbolic_link: matches.get_flag("symbolic_link"),
        remove_destination: matches.get_flag("remove_destination"),
        parents: matches.get_flag("parents"),
        no_target_directory: matches.get_flag("no_target_directory"),
        strip_trailing_slashes: matches.get_flag("strip_trailing_slashes"),
        verbose: matches.get_flag("verbose") || matches.get_flag("debug"),
        keep_directory_symlink: matches.get_flag("keep_directory_symlink"),
        one_file_system: matches.get_flag("one_file_system"),
        deref,
        update,
        backup,
        suffix,
        preserve,
    };

    let mut paths: Vec<PathBuf> = matches.get_many::<String>("paths")
        .map(|v| v.map(|s| PathBuf::from(s)).collect())
        .unwrap_or_default();
    if opts.strip_trailing_slashes {
        paths = paths.into_iter().map(strip_trailing).collect();
    }

    let target_dir = matches.get_one::<String>("target_directory").map(PathBuf::from);
    let jobs = match build_jobs(&paths, target_dir.as_deref(), &opts) {
        Ok(j) => j,
        Err(e) => die(&e),
    };

    let mut copier = Copier { opts, hardlinks: HashMap::new(), failed: false };
    for (src, dst) in jobs {
        let root_dev = if copier.opts.one_file_system {
            source_metadata(&src, 0, &copier.opts).ok().map(|m| m.dev())
        } else { None };
        if let Err(e) = copier.copy_path(&src, &dst, 0, root_dev) {
            eprintln!("cp: {}", e);
            copier.failed = true;
        }
    }
    if copier.failed { process::exit(1); }
}

fn die(msg: &str) -> ! {
    eprintln!("cp: {}", msg);
    process::exit(1);
}

fn apply_preserve(list: &str, p: &mut Preserve, val: bool) {
    for a in list.split(',') {
        match a {
            "all" => { p.mode = val; p.ownership = val; p.timestamps = val; p.links = val; }
            "mode" => p.mode = val,
            "ownership" => p.ownership = val,
            "timestamps" => p.timestamps = val,
            "links" => p.links = val,
            "context" | "xattr" => {}
            "" => {}
            x => die(&format!("invalid attribute '{}'", x)),
        }
    }
}

fn strip_trailing(p: PathBuf) -> PathBuf {
    let s = p.as_os_str().as_bytes();
    if s.len() <= 1 { return p; }
    let mut end = s.len();
    while end > 1 && s[end - 1] == b'/' { end -= 1; }
    PathBuf::from(std::ffi::OsStr::from_bytes(&s[..end]))
}

fn build_jobs(paths: &[PathBuf], target_dir: Option<&Path>, opts: &Options) -> Result<Vec<(PathBuf, PathBuf)>, String> {
    let mut out = Vec::new();
    if let Some(td) = target_dir {
        if paths.is_empty() { return Err("missing file operand".into()); }
        if !td.is_dir() { return Err(format!("target directory '{}' is not a directory", td.display())); }
        for s in paths {
            out.push((s.clone(), dest_under_dir(td, s, opts)?));
        }
    } else {
        if paths.len() < 2 { return Err("missing destination file operand".into()); }
        if paths.len() > 2 {
            let td = paths.last().unwrap();
            if !td.is_dir() { return Err(format!("target '{}' is not a directory", td.display())); }
            for s in &paths[..paths.len() - 1] {
                out.push((s.clone(), dest_under_dir(td, s, opts)?));
            }
        } else {
            let src = paths[0].clone();
            let mut dst = paths[1].clone();
            if !opts.no_target_directory && dst.is_dir() {
                dst = dest_under_dir(&dst, &src, opts)?;
            }
            out.push((src, dst));
        }
    }
    Ok(out)
}

fn dest_under_dir(dir: &Path, src: &Path, opts: &Options) -> Result<PathBuf, String> {
    if opts.parents {
        let mut d = dir.to_path_buf();
        for c in src.components() {
            match c {
                Component::Normal(x) => d.push(x),
                Component::ParentDir => d.push(".."),
                Component::CurDir => {}
                Component::RootDir | Component::Prefix(_) => {}
            }
        }
        Ok(d)
    } else {
        let name = src.file_name().ok_or_else(|| format!("cannot determine file name for '{}'", src.display()))?;
        Ok(dir.join(name))
    }
}

fn source_metadata(src: &Path, depth: usize, opts: &Options) -> io::Result<fs::Metadata> {
    let lm = fs::symlink_metadata(src)?;
    let is_link = lm.file_type().is_symlink();
    let follow = match opts.deref {
        DerefMode::Always => true,
        DerefMode::Never => false,
        DerefMode::CommandLine => depth == 0,
        DerefMode::Default => is_link && !opts.recursive,
    };
    if follow { fs::metadata(src) } else { Ok(lm) }
}

impl Copier {
    fn copy_path(&mut self, src: &Path, dst: &Path, depth: usize, root_dev: Option<u64>) -> Result<(), String> {
        if self.opts.symbolic_link && depth == 0 {
            return self.copy_as_symlink(src, dst);
        }
        let meta = source_metadata(src, depth, &self.opts).map_err(|e| format!("cannot stat '{}': {}", src.display(), e))?;
        let ft = meta.file_type();
        if ft.is_dir() {
            self.copy_dir(src, dst, &meta, depth, root_dev)
        } else if ft.is_symlink() {
            self.copy_symlink(src, dst)
        } else if ft.is_file() {
            self.copy_regular(src, dst, &meta)
        } else if self.opts.copy_contents || !self.opts.recursive {
            self.copy_regular_stream(src, dst, &meta)
        } else if ft.is_fifo() {
            self.copy_fifo(dst, &meta)
        } else {
            Err(format!("unsupported special file '{}'", src.display()))
        }
    }

    fn copy_dir(&mut self, src: &Path, dst: &Path, meta: &fs::Metadata, depth: usize, root_dev: Option<u64>) -> Result<(), String> {
        if !self.opts.recursive {
            return Err(format!("-r not specified; omitting directory '{}'", src.display()));
        }
        if let (Ok(sc), Ok(dc)) = (fs::canonicalize(src), fs::canonicalize(dst.parent().unwrap_or(Path::new(".")))) {
            if dc.starts_with(&sc) && depth == 0 {
                return Err(format!("cannot copy a directory, '{}', into itself, '{}'", src.display(), dst.display()));
            }
        }
        match fs::symlink_metadata(dst) {
            Ok(dm) => {
                if !dm.file_type().is_dir() {
                    return Err(format!("cannot overwrite non-directory '{}' with directory '{}'", dst.display(), src.display()));
                }
                if dm.file_type().is_symlink() && !self.opts.keep_directory_symlink {
                    return Err(format!("will not overwrite just-created '{}' with '{}'", dst.display(), src.display()));
                }
            }
            Err(e) if e.kind() == io::ErrorKind::NotFound => {
                fs::create_dir(dst).map_err(|e| format!("cannot create directory '{}': {}", dst.display(), e))?;
                if self.opts.verbose { println!("'{}' -> '{}'", src.display(), dst.display()); }
            }
            Err(e) => return Err(format!("cannot stat '{}': {}", dst.display(), e)),
        }
        for ent in fs::read_dir(src).map_err(|e| format!("cannot read directory '{}': {}", src.display(), e))? {
            let ent = ent.map_err(|e| format!("cannot read directory '{}': {}", src.display(), e))?;
            let child_src = ent.path();
            if let Some(dev) = root_dev {
                if let Ok(cm) = source_metadata(&child_src, depth + 1, &self.opts) {
                    if cm.file_type().is_dir() && cm.dev() != dev { continue; }
                }
            }
            let child_dst = dst.join(ent.file_name());
            if let Err(e) = self.copy_path(&child_src, &child_dst, depth + 1, root_dev) {
                eprintln!("cp: {}", e);
                self.failed = true;
            }
        }
        self.apply_attrs(dst, meta, false).ok();
        Ok(())
    }

    fn copy_regular(&mut self, src: &Path, dst: &Path, meta: &fs::Metadata) -> Result<(), String> {
        if let Ok(dm) = fs::metadata(dst) {
            if dm.dev() == meta.dev() && dm.ino() == meta.ino() {
                if self.opts.force && self.opts.backup != BackupMode::None && meta.file_type().is_file() {
                    let b = self.backup_name(dst);
                    self.copy_data_to(src, &b, meta, true)?;
                    if self.opts.verbose { println!("'{}' -> '{}' (backup)", src.display(), b.display()); }
                    return Ok(());
                }
                return Err(format!("'{}' and '{}' are the same file", src.display(), dst.display()));
            }
        }
        if self.opts.link {
            self.prepare_destination(src, dst, Some(meta))?;
            fs::hard_link(src, dst).map_err(|e| format!("cannot create hard link '{}': {}", dst.display(), e))?;
            if self.opts.verbose { println!("'{}' => '{}'", src.display(), dst.display()); }
            return Ok(());
        }
        if self.opts.preserve.links {
            let key = (meta.dev(), meta.ino());
            if let Some(prev) = self.hardlinks.get(&key).cloned() {
                self.prepare_destination(src, dst, Some(meta))?;
                if fs::hard_link(&prev, dst).is_ok() {
                    if self.opts.verbose { println!("'{}' => '{}'", prev.display(), dst.display()); }
                    return Ok(());
                }
            }
            self.hardlinks.insert(key, dst.to_path_buf());
        }
        self.copy_data_to(src, dst, meta, false)
    }

    fn copy_regular_stream(&mut self, src: &Path, dst: &Path, meta: &fs::Metadata) -> Result<(), String> {
        self.copy_data_to(src, dst, meta, false)
    }

    fn copy_data_to(&mut self, src: &Path, dst: &Path, meta: &fs::Metadata, backup_copy: bool) -> Result<(), String> {
        if !backup_copy {
            self.prepare_destination(src, dst, Some(meta))?;
        }
        if let Some(parent) = dst.parent() { if !parent.as_os_str().is_empty() { fs::create_dir_all(parent).ok(); } }
        let mut out = OpenOptions::new().write(true).create(true).truncate(true)
            .mode((meta.mode() & 0o7777) as u32)
            .open(dst)
            .or_else(|e| {
                if self.opts.force && !self.opts.no_clobber && !backup_copy {
                    let _ = fs::remove_file(dst);
                    OpenOptions::new().write(true).create(true).truncate(true).mode((meta.mode() & 0o7777) as u32).open(dst)
                } else { Err(e) }
            })
            .map_err(|e| format!("cannot create regular file '{}': {}", dst.display(), e))?;
        if !self.opts.attributes_only {
            let mut inp = File::open(src).map_err(|e| format!("cannot open '{}': {}", src.display(), e))?;
            io::copy(&mut inp, &mut out).map_err(|e| format!("error copying '{}' to '{}': {}", src.display(), dst.display(), e))?;
        }
        drop(out);
        self.apply_attrs(dst, meta, false).ok();
        if self.opts.verbose && !backup_copy { println!("'{}' -> '{}'", src.display(), dst.display()); }
        Ok(())
    }

    fn copy_symlink(&mut self, src: &Path, dst: &Path) -> Result<(), String> {
        let target = fs::read_link(src).map_err(|e| format!("cannot read symbolic link '{}': {}", src.display(), e))?;
        self.prepare_destination(src, dst, None)?;
        symlink(&target, dst).map_err(|e| format!("cannot create symbolic link '{}': {}", dst.display(), e))?;
        if self.opts.verbose { println!("'{}' -> '{}'", src.display(), dst.display()); }
        Ok(())
    }

    fn copy_as_symlink(&mut self, src: &Path, dst: &Path) -> Result<(), String> {
        self.prepare_destination(src, dst, None)?;
        symlink(src, dst).map_err(|e| format!("cannot create symbolic link '{}': {}", dst.display(), e))?;
        if self.opts.verbose { println!("'{}' -> '{}'", src.display(), dst.display()); }
        Ok(())
    }

    fn copy_fifo(&mut self, dst: &Path, meta: &fs::Metadata) -> Result<(), String> {
        self.prepare_destination(dst, dst, Some(meta))?;
        let c = cstring_path(dst)?;
        let rc = unsafe { libc::mkfifo(c.as_ptr(), (meta.mode() & 0o7777) as libc::mode_t) };
        if rc != 0 { return Err(format!("cannot create fifo '{}': {}", dst.display(), io::Error::last_os_error())); }
        self.apply_attrs(dst, meta, false).ok();
        Ok(())
    }

    fn prepare_destination(&mut self, src: &Path, dst: &Path, src_meta: Option<&fs::Metadata>) -> Result<(), String> {
        if let Some(parent) = dst.parent() { if !parent.as_os_str().is_empty() { fs::create_dir_all(parent).ok(); } }
        if fs::symlink_metadata(dst).is_err() { return Ok(()); }
        if self.opts.no_clobber || self.opts.update == UpdateMode::None {
            return Err(format!("not replacing '{}'", dst.display()));
        }
        if self.opts.update == UpdateMode::NoneFail {
            return Err(format!("not replacing '{}'", dst.display()));
        }
        if self.opts.update == UpdateMode::Older {
            if let (Some(sm), Ok(dm)) = (src_meta, fs::metadata(dst)) {
                if (dm.mtime(), dm.mtime_nsec()) >= (sm.mtime(), sm.mtime_nsec()) {
                    return Err(format!("not replacing newer '{}'", dst.display()));
                }
            }
        }
        if self.opts.interactive && !prompt_overwrite(dst) {
            return Err(format!("not replacing '{}'", dst.display()));
        }
        if self.opts.backup != BackupMode::None {
            self.make_backup(dst)?;
        } else if self.opts.remove_destination {
            remove_any(dst).map_err(|e| format!("cannot remove '{}': {}", dst.display(), e))?;
        }
        Ok(())
    }

    fn make_backup(&self, dst: &Path) -> Result<(), String> {
        let b = self.backup_name(dst);
        fs::rename(dst, &b).map_err(|e| format!("cannot backup '{}': {}", dst.display(), e))?;
        Ok(())
    }

    fn backup_name(&self, dst: &Path) -> PathBuf {
        match self.opts.backup {
            BackupMode::Simple | BackupMode::None => PathBuf::from(format!("{}{}", dst.display(), self.opts.suffix)),
            BackupMode::Numbered => numbered_backup(dst),
            BackupMode::Existing => {
                if numbered_exists(dst) { numbered_backup(dst) } else { PathBuf::from(format!("{}{}", dst.display(), self.opts.suffix)) }
            }
        }
    }

    fn apply_attrs(&self, dst: &Path, meta: &fs::Metadata, no_follow: bool) -> Result<(), String> {
        if self.opts.preserve.ownership {
            let c = cstring_path(dst)?;
            let rc = unsafe {
                if no_follow { libc::lchown(c.as_ptr(), meta.uid(), meta.gid()) } else { libc::chown(c.as_ptr(), meta.uid(), meta.gid()) }
            };
            if rc != 0 { /* GNU cp often ignores chown failure for non-root unless explicit; keep going. */ }
        }
        if self.opts.preserve.mode {
            fs::set_permissions(dst, fs::Permissions::from_mode((meta.mode() & 0o7777) as u32))
                .map_err(|e| format!("preserving permissions for '{}': {}", dst.display(), e))?;
        }
        if self.opts.preserve.timestamps {
            let at = FileTime::from_unix_time(meta.atime(), meta.atime_nsec() as u32);
            let mt = FileTime::from_unix_time(meta.mtime(), meta.mtime_nsec() as u32);
            set_file_times(dst, at, mt).map_err(|e| format!("preserving times for '{}': {}", dst.display(), e))?;
        }
        Ok(())
    }
}

fn remove_any(p: &Path) -> io::Result<()> {
    match fs::symlink_metadata(p) {
        Ok(m) if m.file_type().is_dir() => fs::remove_dir(p),
        Ok(_) => fs::remove_file(p),
        Err(e) => Err(e),
    }
}

fn prompt_overwrite(p: &Path) -> bool {
    eprint!("cp: overwrite '{}'? ", p.display());
    let _ = io::stderr().flush();
    let mut s = String::new();
    if io::stdin().read_line(&mut s).is_err() { return false; }
    matches!(s.chars().next(), Some('y') | Some('Y'))
}

fn cstring_path(p: &Path) -> Result<CString, String> {
    CString::new(p.as_os_str().as_bytes()).map_err(|_| format!("invalid path '{}': contains NUL", p.display()))
}

fn numbered_exists(dst: &Path) -> bool {
    let base = dst.file_name().map(|s| s.to_string_lossy().to_string()).unwrap_or_default();
    let parent = dst.parent().unwrap_or(Path::new("."));
    if let Ok(rd) = fs::read_dir(parent) {
        for e in rd.flatten() {
            let n = e.file_name().to_string_lossy().to_string();
            if n.starts_with(&(base.clone() + ".~")) && n.ends_with('~') { return true; }
        }
    }
    false
}

fn numbered_backup(dst: &Path) -> PathBuf {
    let parent = dst.parent().unwrap_or(Path::new("."));
    let base = dst.file_name().map(|s| s.to_string_lossy().to_string()).unwrap_or_else(|| dst.display().to_string());
    for i in 1.. {
        let p = parent.join(format!("{}.~{}~", base, i));
        if fs::symlink_metadata(&p).is_err() { return p; }
    }
    unreachable!()
}
