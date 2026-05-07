use filetime::{set_file_times, FileTime};
use std::collections::HashMap;
use std::env;
use std::ffi::CString;
use std::fs::{self, File, OpenOptions};
use std::io::{self, IsTerminal, Read, Write};
use std::os::unix::ffi::OsStrExt;
use std::os::unix::fs::{symlink, MetadataExt, OpenOptionsExt, PermissionsExt};
use std::path::{Path, PathBuf};

#[derive(Clone, Copy, PartialEq)]
enum Update { All, None, NoneFail, Older }

#[derive(Clone, Copy, PartialEq)]
enum Reflink { Never, Auto, Always }

struct Opt {
    recursive: bool,
    attributes_only: bool,
    backup: bool,
    backup_control: Option<String>,
    suffix: String,
    copy_contents: bool,
    debug: bool,
    force: bool,
    interactive: bool,
    deref_all: bool,
    deref_cmdline: bool,
    hard_link: bool,
    no_clobber: bool,
    preserve_mode: bool,
    preserve_owner: bool,
    preserve_times: bool,
    preserve_links: bool,
    parents: bool,
    remove_destination: bool,
    strip_trailing_slashes: bool,
    symbolic_link: bool,
    target_dir: Option<PathBuf>,
    no_target_dir: bool,
    update: Update,
    update_seen: bool,
    verbose: bool,
    keep_directory_symlink: bool,
    one_file_system: bool,
    reflink: Reflink,
}

impl Default for Opt {
    fn default() -> Self {
        Self {
            recursive: false,
            attributes_only: false,
            backup: false,
            backup_control: None,
            suffix: env::var("SIMPLE_BACKUP_SUFFIX").unwrap_or_else(|_| "~".to_string()),
            copy_contents: false,
            debug: false,
            force: false,
            interactive: false,
            deref_all: false,
            deref_cmdline: true,
            hard_link: false,
            no_clobber: false,
            preserve_mode: false,
            preserve_owner: false,
            preserve_times: false,
            preserve_links: false,
            parents: false,
            remove_destination: false,
            strip_trailing_slashes: false,
            symbolic_link: false,
            target_dir: None,
            no_target_dir: false,
            update: Update::All,
            update_seen: false,
            verbose: false,
            keep_directory_symlink: false,
            one_file_system: false,
            reflink: Reflink::Auto,
        }
    }
}

fn usage() {
    println!("Usage: cp [OPTION]... SOURCE DEST\n  or:  cp [OPTION]... SOURCE... DIRECTORY\n  or:  cp [OPTION]... -t DIRECTORY SOURCE...");
}

fn version() { println!("cp (rust util) 0.1.0"); }

fn preserve_list(o: &mut Opt, list: &str, val: bool) -> Result<(), String> {
    let items = if list.is_empty() { "mode,ownership,timestamps" } else { list };
    for a in items.split(',') {
        match a {
            "mode" => o.preserve_mode = val,
            "ownership" => o.preserve_owner = val,
            "timestamps" => o.preserve_times = val,
            "links" => o.preserve_links = val,
            "all" => { o.preserve_mode = val; o.preserve_owner = val; o.preserve_times = val; o.preserve_links = val; },
            "context" | "xattr" => {},
            _ => return Err(format!("invalid attribute '{}'", a)),
        }
    }
    Ok(())
}

fn set_update(o: &mut Opt, s: Option<&str>) -> Result<(), String> {
    o.update_seen = true;
    o.update = match s.unwrap_or("older") {
        "all" => Update::All,
        "none" => Update::None,
        "none-fail" => Update::NoneFail,
        "older" => Update::Older,
        x => return Err(format!("invalid update value '{}'", x)),
    };
    if o.update == Update::None { o.no_clobber = true; }
    Ok(())
}

fn parse() -> Result<(Opt, Vec<PathBuf>), String> {
    let mut o = Opt::default();
    let mut paths = Vec::new();
    let mut it = env::args_os().skip(1).peekable();
    let mut end_opts = false;
    while let Some(arg) = it.next() {
        if end_opts { paths.push(PathBuf::from(arg)); continue; }
        let s = arg.to_string_lossy().to_string();
        if s == "--" { end_opts = true; continue; }
        if !s.starts_with('-') || s == "-" { paths.push(PathBuf::from(arg)); continue; }
        if s.starts_with("--") {
            let (name, val) = if let Some(p) = s.find('=') { (&s[..p], Some(&s[p+1..])) } else { (&s[..], None) };
            match name {
                "--help" => { usage(); std::process::exit(0); },
                "--version" => { version(); std::process::exit(0); },
                "--archive" => { o.recursive = true; o.deref_all = false; o.deref_cmdline = false; preserve_list(&mut o, "all", true)?; },
                "--attributes-only" => o.attributes_only = true,
                "--backup" => { o.backup = true; if let Some(v) = val { o.backup_control = Some(v.to_string()); } },
                "--copy-contents" => o.copy_contents = true,
                "--debug" => { o.debug = true; o.verbose = true; },
                "--force" => o.force = true,
                "--interactive" => { o.interactive = true; o.no_clobber = false; },
                "--link" => o.hard_link = true,
                "--dereference" => { o.deref_all = true; o.deref_cmdline = true; },
                "--no-clobber" => { o.no_clobber = true; o.interactive = false; },
                "--no-dereference" => { o.deref_all = false; o.deref_cmdline = false; },
                "--preserve" => preserve_list(&mut o, val.unwrap_or("mode,ownership,timestamps"), true)?,
                "--no-preserve" => preserve_list(&mut o, val.ok_or("--no-preserve requires an argument")?, false)?,
                "--parents" => o.parents = true,
                "--recursive" => o.recursive = true,
                "--remove-destination" => o.remove_destination = true,
                "--strip-trailing-slashes" => o.strip_trailing_slashes = true,
                "--symbolic-link" => o.symbolic_link = true,
                "--suffix" => o.suffix = val.map(|v| v.to_string()).or_else(|| it.next().map(|x| x.to_string_lossy().to_string())).ok_or("--suffix requires an argument")?,
                "--target-directory" => o.target_dir = Some(PathBuf::from(val.map(|v| v.to_string()).or_else(|| it.next().map(|x| x.to_string_lossy().to_string())).ok_or("--target-directory requires an argument")?)),
                "--no-target-directory" => o.no_target_dir = true,
                "--update" => set_update(&mut o, val)?,
                "--verbose" => o.verbose = true,
                "--keep-directory-symlink" => o.keep_directory_symlink = true,
                "--one-file-system" => o.one_file_system = true,
                "--sparse" => {},
                "--reflink" => { o.reflink = match val.unwrap_or("always") { "never" => Reflink::Never, "auto" => Reflink::Auto, "always" => Reflink::Always, x => return Err(format!("invalid reflink value '{}'", x)) }; },
                "--context" => {},
                _ => return Err(format!("unrecognized option '{}'", s)),
            }
        } else {
            let cs: Vec<char> = s[1..].chars().collect();
            let mut i = 0;
            while i < cs.len() {
                match cs[i] {
                    'a' => { o.recursive = true; o.deref_all = false; o.deref_cmdline = false; preserve_list(&mut o, "all", true)?; },
                    'b' => o.backup = true,
                    'd' => { o.deref_all = false; o.deref_cmdline = false; o.preserve_links = true; },
                    'f' => o.force = true,
                    'i' => { o.interactive = true; o.no_clobber = false; },
                    'H' => { o.deref_all = false; o.deref_cmdline = true; },
                    'l' => o.hard_link = true,
                    'L' => { o.deref_all = true; o.deref_cmdline = true; },
                    'n' => { o.no_clobber = true; o.interactive = false; },
                    'P' => { o.deref_all = false; o.deref_cmdline = false; },
                    'p' => preserve_list(&mut o, "mode,ownership,timestamps", true)?,
                    'R' | 'r' => o.recursive = true,
                    's' => o.symbolic_link = true,
                    'T' => o.no_target_dir = true,
                    'u' => set_update(&mut o, Some("older"))?,
                    'v' => o.verbose = true,
                    'x' => o.one_file_system = true,
                    'Z' => {},
                    'S' | 't' => {
                        let rest: String = cs[i+1..].iter().collect();
                        let v = if rest.is_empty() { it.next().map(|x| x.to_string_lossy().to_string()).ok_or(format!("option requires an argument -- '{}'", cs[i]))? } else { rest };
                        if cs[i] == 'S' { o.suffix = v; } else { o.target_dir = Some(PathBuf::from(v)); }
                        break;
                    },
                    c => return Err(format!("invalid option -- '{}'", c)),
                }
                i += 1;
            }
        }
    }
    if o.debug { o.verbose = true; }
    Ok((o, paths))
}

fn strip_slashes(p: PathBuf) -> PathBuf {
    let b = p.as_os_str().as_bytes();
    if b.len() <= 1 { return p; }
    let mut n = b.len();
    while n > 1 && b[n-1] == b'/' { n -= 1; }
    PathBuf::from(std::ffi::OsStr::from_bytes(&b[..n]))
}

fn source_name(src: &Path, parents: bool) -> Result<PathBuf, String> {
    if parents {
        let mut r = PathBuf::new();
        for c in src.components() {
            if let std::path::Component::Normal(x) = c { r.push(x); }
        }
        if r.as_os_str().is_empty() { Err(format!("cannot make directory entry for '{}'", src.display())) } else { Ok(r) }
    } else {
        src.file_name().map(PathBuf::from).ok_or_else(|| format!("cannot stat '{}': No such file or directory", src.display()))
    }
}

fn is_dir_follow(p: &Path) -> bool { fs::metadata(p).map(|m| m.is_dir()).unwrap_or(false) }
fn symlink_exists(p: &Path) -> bool { fs::symlink_metadata(p).is_ok() }

fn remove_any(p: &Path) -> io::Result<()> {
    let m = fs::symlink_metadata(p)?;
    if m.is_dir() && !m.file_type().is_symlink() { fs::remove_dir_all(p) } else { fs::remove_file(p) }
}

fn backup_name(p: &Path, o: &Opt) -> Option<PathBuf> {
    let ctl = o.backup_control.clone().or_else(|| env::var("VERSION_CONTROL").ok()).unwrap_or_else(|| "existing".to_string());
    if ctl == "none" || ctl == "off" { return None; }
    let numbered = ctl == "numbered" || ctl == "t" || ((ctl == "existing" || ctl == "nil") && numbered_exists(p));
    if numbered {
        for n in 1..1000000 {
            let q = PathBuf::from(format!("{}.~{}~", p.to_string_lossy(), n));
            if !symlink_exists(&q) { return Some(q); }
        }
        None
    } else { Some(PathBuf::from(format!("{}{}", p.to_string_lossy(), o.suffix))) }
}

fn numbered_exists(p: &Path) -> bool {
    let parent = p.parent().unwrap_or_else(|| Path::new("."));
    let base = p.file_name().map(|x| x.to_string_lossy().to_string()).unwrap_or_default();
    if let Ok(rd) = fs::read_dir(parent) {
        for e in rd.flatten() {
            let n = e.file_name().to_string_lossy().to_string();
            if n.starts_with(&(base.clone() + ".~")) && n.ends_with('~') { return true; }
        }
    }
    false
}

fn same_file(a: &fs::Metadata, b: &fs::Metadata) -> bool { a.dev() == b.dev() && a.ino() == b.ino() }

fn prompt(dst: &Path) -> bool {
    if !io::stdin().is_terminal() { return true; }
    eprint!("cp: overwrite '{}'? ", dst.display());
    let _ = io::stderr().flush();
    let mut s = String::new();
    if io::stdin().read_line(&mut s).is_err() { return false; }
    matches!(s.chars().next(), Some('y') | Some('Y'))
}

fn should_copy(srcm: &fs::Metadata, dst: &Path, o: &Opt) -> Result<bool, String> {
    if !symlink_exists(dst) { return Ok(true); }
    if o.no_clobber || o.update == Update::None { return Ok(false); }
    if o.update == Update::NoneFail { return Err(format!("not replacing '{}'; --update=none-fail specified", dst.display())); }
    if o.update == Update::Older {
        if let Ok(dm) = fs::metadata(dst) {
            if dm.modified().ok() >= srcm.modified().ok() { return Ok(false); }
        }
    }
    if o.interactive && !prompt(dst) { return Ok(false); }
    Ok(true)
}

fn prepare(dst: &Path, srcm: &fs::Metadata, o: &Opt) -> Result<bool, String> {
    if !should_copy(srcm, dst, o)? { return Ok(false); }
    if symlink_exists(dst) {
        if o.backup {
            if let Some(b) = backup_name(dst, o) { fs::rename(dst, &b).map_err(|e| format!("cannot create backup '{}': {}", b.display(), e))?; return Ok(true); }
        }
        if o.remove_destination { remove_any(dst).map_err(|e| format!("cannot remove '{}': {}", dst.display(), e))?; }
    }
    Ok(true)
}

fn preserve(dst: &Path, m: &fs::Metadata, o: &Opt) {
    if o.preserve_mode { let _ = fs::set_permissions(dst, fs::Permissions::from_mode(m.mode() & 0o7777)); }
    if o.preserve_times {
        let at = FileTime::from_last_access_time(m);
        let mt = FileTime::from_last_modification_time(m);
        let _ = set_file_times(dst, at, mt);
    }
    if o.preserve_owner {
        if let Ok(c) = CString::new(dst.as_os_str().as_bytes()) { unsafe { libc::chown(c.as_ptr(), m.uid(), m.gid()); } }
    }
}

fn verbose(src: &Path, dst: &Path, o: &Opt) { if o.verbose { println!("'{}' -> '{}'", src.display(), dst.display()); } }

fn try_reflink(src: &File, dst: &File) -> io::Result<()> {
    const FICLONE: libc::c_ulong = 0x40049409;
    let r = unsafe { libc::ioctl(dst.as_raw_fd(), FICLONE, src.as_raw_fd()) };
    if r == 0 { Ok(()) } else { Err(io::Error::last_os_error()) }
}
use std::os::fd::AsRawFd;

fn copy_regular(src: &Path, dst: &Path, m: &fs::Metadata, o: &Opt) -> Result<(), String> {
    if !prepare(dst, m, o)? { return Ok(()); }
    if let Some(p) = dst.parent() { if o.parents { fs::create_dir_all(p).map_err(|e| format!("cannot create directory '{}': {}", p.display(), e))?; } }
    let mut inp = File::open(src).map_err(|e| format!("cannot open '{}': {}", src.display(), e))?;
    let mut opts = OpenOptions::new();
    opts.write(true).create(true).truncate(true).mode(m.mode() & 0o777);
    let mut out = match opts.open(dst) {
        Ok(f) => f,
        Err(e) if o.force && !o.no_clobber => { let _ = remove_any(dst); opts.open(dst).map_err(|e2| format!("cannot create regular file '{}': {}", dst.display(), e2))? },
        Err(e) => return Err(format!("cannot create regular file '{}': {}", dst.display(), e)),
    };
    if !o.attributes_only {
        if o.reflink != Reflink::Never {
            match try_reflink(&inp, &out) {
                Ok(()) => {},
                Err(e) if o.reflink == Reflink::Always => return Err(format!("failed to clone '{}': {}", src.display(), e)),
                Err(_) => { io::copy(&mut inp, &mut out).map_err(|e| format!("error copying '{}': {}", src.display(), e))?; },
            }
        } else { io::copy(&mut inp, &mut out).map_err(|e| format!("error copying '{}': {}", src.display(), e))?; }
    }
    preserve(dst, m, o);
    verbose(src, dst, o);
    Ok(())
}

fn copy_symlink(src: &Path, dst: &Path, m: &fs::Metadata, o: &Opt) -> Result<(), String> {
    if !prepare(dst, m, o)? { return Ok(()); }
    if symlink_exists(dst) { remove_any(dst).map_err(|e| format!("cannot remove '{}': {}", dst.display(), e))?; }
    let t = fs::read_link(src).map_err(|e| format!("cannot read symbolic link '{}': {}", src.display(), e))?;
    symlink(&t, dst).map_err(|e| format!("cannot create symbolic link '{}': {}", dst.display(), e))?;
    verbose(src, dst, o);
    Ok(())
}

fn copy_item(src: &Path, dst: &Path, cmdline: bool, root_dev: Option<u64>, o: &Opt, links: &mut HashMap<(u64,u64), PathBuf>) -> Result<(), String> {
    let follow = o.deref_all || (cmdline && o.deref_cmdline);
    let m = if follow { fs::metadata(src) } else { fs::symlink_metadata(src) }.map_err(|e| format!("cannot stat '{}': {}", src.display(), e))?;
    if let Ok(dm) = fs::metadata(dst) {
        if same_file(&m, &dm) {
            if o.backup && o.force && m.is_file() {
                if let Some(b) = backup_name(dst, o) { fs::copy(src, &b).map_err(|e| format!("cannot create backup '{}': {}", b.display(), e))?; return Ok(()); }
            }
            return Err(format!("'{}' and '{}' are the same file", src.display(), dst.display()));
        }
    }
    if o.symbolic_link {
        if !prepare(dst, &m, o)? { return Ok(()); }
        if symlink_exists(dst) { remove_any(dst).map_err(|e| format!("cannot remove '{}': {}", dst.display(), e))?; }
        symlink(src, dst).map_err(|e| format!("cannot create symbolic link '{}': {}", dst.display(), e))?;
        verbose(src, dst, o);
    } else if o.hard_link {
        if !prepare(dst, &m, o)? { return Ok(()); }
        if symlink_exists(dst) { remove_any(dst).map_err(|e| format!("cannot remove '{}': {}", dst.display(), e))?; }
        fs::hard_link(src, dst).map_err(|e| format!("cannot create hard link '{}': {}", dst.display(), e))?;
        verbose(src, dst, o);
    } else if m.file_type().is_symlink() && !follow {
        copy_symlink(src, dst, &m, o)?;
    } else if m.is_dir() {
        if !o.recursive { return Err(format!("-r not specified; omitting directory '{}'", src.display())); }
        if let Some(d) = root_dev { if o.one_file_system && m.dev() != d { return Ok(()); } }
        if let (Ok(sc), Ok(dc)) = (fs::canonicalize(src), dst.parent().unwrap_or_else(|| Path::new(".")).canonicalize()) {
            if dc.starts_with(&sc) { return Err(format!("cannot copy a directory, '{}', into itself, '{}'", src.display(), dst.display())); }
        }
        if symlink_exists(dst) && !is_dir_follow(dst) { return Err(format!("cannot overwrite non-directory '{}' with directory '{}'", dst.display(), src.display())); }
        if !symlink_exists(dst) { fs::create_dir(dst).map_err(|e| format!("cannot create directory '{}': {}", dst.display(), e))?; }
        verbose(src, dst, o);
        for ent in fs::read_dir(src).map_err(|e| format!("cannot read directory '{}': {}", src.display(), e))? {
            let ent = ent.map_err(|e| e.to_string())?;
            copy_item(&ent.path(), &dst.join(ent.file_name()), false, root_dev, o, links)?;
        }
        preserve(dst, &m, o);
    } else if m.is_file() {
        if o.preserve_links {
            let k = (m.dev(), m.ino());
            if let Some(prev) = links.get(&k).cloned() {
                if prepare(dst, &m, o)? {
                    if symlink_exists(dst) { remove_any(dst).map_err(|e| format!("cannot remove '{}': {}", dst.display(), e))?; }
                    fs::hard_link(prev, dst).map_err(|e| format!("cannot create hard link '{}': {}", dst.display(), e))?;
                    verbose(src, dst, o);
                }
                return Ok(());
            }
            copy_regular(src, dst, &m, o)?;
            links.insert(k, dst.to_path_buf());
        } else { copy_regular(src, dst, &m, o)?; }
    } else if o.copy_contents { copy_regular(src, dst, &m, o)?; }
    else { return Err(format!("cannot copy special file '{}'", src.display())); }
    Ok(())
}

fn run() -> Result<(), String> {
    let (o, mut args) = parse()?;
    if o.strip_trailing_slashes { args = args.into_iter().map(strip_slashes).collect(); }
    if args.is_empty() { return Err("missing file operand".to_string()); }
    let mut jobs: Vec<(PathBuf, PathBuf)> = Vec::new();
    if let Some(td) = &o.target_dir {
        if args.is_empty() { return Err("missing file operand".to_string()); }
        if !is_dir_follow(td) { return Err(format!("target '{}' is not a directory", td.display())); }
        for s in &args { jobs.push((s.clone(), td.join(source_name(s, o.parents)?))); }
    } else {
        if args.len() < 2 { return Err(format!("missing destination file operand after '{}'", args[0].display())); }
        let dest = args.pop().unwrap();
        if args.len() > 1 {
            if o.no_target_dir { return Err("extra operand with --no-target-directory".to_string()); }
            if !is_dir_follow(&dest) { return Err(format!("target '{}' is not a directory", dest.display())); }
            for s in &args { jobs.push((s.clone(), dest.join(source_name(s, o.parents)?))); }
        } else {
            let s = args[0].clone();
            if !o.no_target_dir && is_dir_follow(&dest) { jobs.push((s.clone(), dest.join(source_name(&s, o.parents)?))); } else { jobs.push((s, dest)); }
        }
    }
    let mut links = HashMap::new();
    for (s,d) in jobs {
        let root = if o.one_file_system { fs::metadata(&s).ok().map(|m| m.dev()) } else { None };
        copy_item(&s, &d, true, root, &o, &mut links)?;
    }
    Ok(())
}

fn main() {
    if let Err(e) = run() { eprintln!("cp: {}", e); std::process::exit(1); }
}
