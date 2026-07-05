// cp - copy files and directories. Single-file Rust implementation of the
// documented GNU coreutils 9.7 behavior, for a Linux/GNU test harness.
//
// Out of scope per harness contract: SELinux/--context/-Z, NLS/locale,
// xattr/ACL, sparse/--sparse/--reflink, signal handling, network/remote.

use std::collections::HashSet;
use std::ffi::{CString, OsStr, OsString};
use std::fs;
use std::io::{self, BufRead, Read, Write};
use std::os::unix::ffi::OsStrExt;
use std::os::unix::fs::{symlink, MetadataExt, OpenOptionsExt, PermissionsExt};
use std::path::{Component, Path, PathBuf};
use std::process::exit;

const PROG: &str = "cp";

// ---------------------------------------------------------------------------
// Options
// ---------------------------------------------------------------------------

#[derive(Clone, Copy, PartialEq, Eq)]
enum DerefMode {
    // -L: always follow symlinks in SOURCE
    Always,
    // -P / -d: never follow symlinks in SOURCE
    Never,
    // -H: follow command-line symlinks only
    CommandLine,
    // default: follow command-line symlinks when not recursive,
    // never when recursive (GNU default).
    Default,
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
    Numbered,
    Existing,
    Simple,
}

#[derive(Default, Clone, Copy)]
struct Preserve {
    mode: bool,
    ownership: bool,
    timestamps: bool,
    links: bool,
}

struct Opts {
    recursive: bool,
    force: bool,
    interactive: bool,
    no_clobber: bool,
    link: bool,
    symbolic_link: bool,
    deref: DerefMode,
    update: UpdateMode,
    verbose: bool,
    parents: bool,
    strip_trailing_slashes: bool,
    remove_destination: bool,
    attributes_only: bool,
    preserve: Preserve,
    backup: bool,
    backup_mode: BackupMode,
    suffix: String,
    target_directory: Option<PathBuf>,
    no_target_directory: bool,
    one_file_system: bool,
}

impl Default for Opts {
    fn default() -> Self {
        Opts {
            recursive: false,
            force: false,
            interactive: false,
            no_clobber: false,
            link: false,
            symbolic_link: false,
            deref: DerefMode::Default,
            update: UpdateMode::All,
            verbose: false,
            parents: false,
            strip_trailing_slashes: false,
            remove_destination: false,
            attributes_only: false,
            preserve: Preserve::default(),
            backup: false,
            backup_mode: BackupMode::Existing,
            suffix: "~".to_string(),
            target_directory: None,
            no_target_directory: false,
            one_file_system: false,
        }
    }
}

// ---------------------------------------------------------------------------
// Error reporting
// ---------------------------------------------------------------------------

fn err(msg: &str) {
    eprintln!("{}: {}", PROG, msg);
}

fn die(msg: &str) -> ! {
    err(msg);
    exit(1);
}

fn try_help() -> ! {
    eprintln!("Try '{} --help' for more information.", PROG);
    exit(1);
}

fn quote(p: &Path) -> String {
    format!("'{}'", p.display())
}

// ---------------------------------------------------------------------------
// Argument parsing
// ---------------------------------------------------------------------------

fn parse_preserve_list(list: &str, p: &mut Preserve, on: bool) {
    for attr in list.split(',') {
        match attr.trim() {
            "mode" => p.mode = on,
            "ownership" => p.ownership = on,
            "timestamps" => p.timestamps = on,
            "links" => p.links = on,
            "all" => {
                p.mode = on;
                p.ownership = on;
                p.timestamps = on;
                p.links = on;
            }
            // context / xattr are out of scope; accept and ignore.
            "context" | "xattr" => {}
            "" => {}
            other => {
                err(&format!("invalid argument '{}' for '--preserve'", other));
                try_help();
            }
        }
    }
}

fn backup_mode_from_str(s: &str) -> Option<BackupMode> {
    match s {
        "none" | "off" => Some(BackupMode::None),
        "numbered" | "t" => Some(BackupMode::Numbered),
        "existing" | "nil" => Some(BackupMode::Existing),
        "simple" | "never" => Some(BackupMode::Simple),
        _ => None,
    }
}

fn parse_update(s: &str) -> UpdateMode {
    match s {
        "all" => UpdateMode::All,
        "none" => UpdateMode::None,
        "none-fail" => UpdateMode::NoneFail,
        "older" => UpdateMode::Older,
        other => {
            err(&format!("invalid argument '{}' for '--update'", other));
            try_help();
        }
    }
}

fn parse_args() -> (Opts, Vec<PathBuf>) {
    let mut opts = Opts::default();
    let mut operands: Vec<PathBuf> = Vec::new();
    let raw: Vec<OsString> = std::env::args_os().skip(1).collect();

    // Resolve backup defaults from environment, like GNU cp.
    if let Some(s) = std::env::var_os("SIMPLE_BACKUP_SUFFIX") {
        opts.suffix = s.to_string_lossy().into_owned();
    }
    let env_vc = std::env::var("VERSION_CONTROL").ok();

    let mut explicit_backup_control = false;
    let mut explicit_update = false;
    let mut no_clobber_set = false;
    let mut i = 0;
    let mut end_of_opts = false;

    while i < raw.len() {
        let arg = &raw[i];
        let bytes = arg.as_bytes();

        if end_of_opts || bytes == b"-" || !bytes.starts_with(b"-") {
            operands.push(PathBuf::from(arg));
            i += 1;
            continue;
        }
        if bytes == b"--" {
            end_of_opts = true;
            i += 1;
            continue;
        }

        if bytes.starts_with(b"--") {
            // Long option, possibly --opt=value.
            let s = arg.to_string_lossy();
            let (name, value) = match s.find('=') {
                Some(p) => (&s[2..p], Some(s[p + 1..].to_string())),
                None => (&s[2..], None),
            };
            match name {
                "archive" => {
                    opts.recursive = true;
                    opts.deref = DerefMode::Never;
                    opts.preserve.links = true;
                    opts.preserve.mode = true;
                    opts.preserve.ownership = true;
                    opts.preserve.timestamps = true;
                }
                "attributes-only" => opts.attributes_only = true,
                "backup" => {
                    opts.backup = true;
                    if let Some(v) = value {
                        match backup_mode_from_str(&v) {
                            Some(m) => {
                                opts.backup_mode = m;
                                explicit_backup_control = true;
                            }
                            None => {
                                err(&format!("invalid argument '{}' for '--backup'", v));
                                try_help();
                            }
                        }
                    }
                }
                "copy-contents" => { /* recursive special-file copy: ignored */ }
                "debug" => opts.verbose = true,
                "force" => opts.force = true,
                "interactive" => {
                    opts.interactive = true;
                    opts.no_clobber = false;
                }
                "link" => opts.link = true,
                "dereference" => opts.deref = DerefMode::Always,
                "no-clobber" => {
                    opts.no_clobber = true;
                    no_clobber_set = true;
                }
                "no-dereference" => opts.deref = DerefMode::Never,
                "preserve" => match value {
                    Some(v) => parse_preserve_list(&v, &mut opts.preserve, true),
                    None => {
                        opts.preserve.mode = true;
                        opts.preserve.ownership = true;
                        opts.preserve.timestamps = true;
                    }
                },
                "no-preserve" => match value {
                    Some(v) => parse_preserve_list(&v, &mut opts.preserve, false),
                    None => {
                        err("option '--no-preserve' requires an argument");
                        try_help();
                    }
                },
                "parents" => opts.parents = true,
                "recursive" => opts.recursive = true,
                "reflink" => { /* out of scope: accept WHEN, do a standard copy */ }
                "remove-destination" => opts.remove_destination = true,
                "sparse" => { /* out of scope: accept WHEN, no sparse handling */ }
                "strip-trailing-slashes" => opts.strip_trailing_slashes = true,
                "symbolic-link" => opts.symbolic_link = true,
                "suffix" => match value {
                    Some(v) => opts.suffix = v,
                    None => {
                        err("option '--suffix' requires an argument");
                        try_help();
                    }
                },
                "target-directory" => match value {
                    Some(v) => opts.target_directory = Some(PathBuf::from(v)),
                    None => {
                        // value is next argument
                        i += 1;
                        if i >= raw.len() {
                            err("option '--target-directory' requires an argument");
                            try_help();
                        }
                        opts.target_directory = Some(PathBuf::from(&raw[i]));
                    }
                },
                "no-target-directory" => opts.no_target_directory = true,
                "update" => {
                    explicit_update = true;
                    match value {
                        Some(v) => opts.update = parse_update(&v),
                        None => opts.update = UpdateMode::Older,
                    }
                }
                "verbose" => opts.verbose = true,
                "keep-directory-symlink" => { /* accepted */ }
                "one-file-system" => opts.one_file_system = true,
                "context" => { /* SELinux: out of scope */ }
                "help" => {
                    print_help();
                    exit(0);
                }
                "version" => {
                    println!("cp (cp_impl) 9.7");
                    exit(0);
                }
                other => {
                    err(&format!("unrecognized option '--{}'", other));
                    try_help();
                }
            }
            i += 1;
            continue;
        }

        // Short option cluster: -abc  or  -S<suffix> / -t<dir>
        let cluster = &bytes[1..];
        let mut j = 0;
        while j < cluster.len() {
            let c = cluster[j];
            match c {
                b'a' => {
                    opts.recursive = true;
                    opts.deref = DerefMode::Never;
                    opts.preserve.links = true;
                    opts.preserve.mode = true;
                    opts.preserve.ownership = true;
                    opts.preserve.timestamps = true;
                }
                b'b' => opts.backup = true,
                b'd' => {
                    opts.deref = DerefMode::Never;
                    opts.preserve.links = true;
                }
                b'f' => opts.force = true,
                b'i' => {
                    opts.interactive = true;
                    opts.no_clobber = false;
                }
                b'H' => opts.deref = DerefMode::CommandLine,
                b'l' => opts.link = true,
                b'L' => opts.deref = DerefMode::Always,
                b'n' => {
                    opts.no_clobber = true;
                    no_clobber_set = true;
                }
                b'P' => opts.deref = DerefMode::Never,
                b'p' => {
                    opts.preserve.mode = true;
                    opts.preserve.ownership = true;
                    opts.preserve.timestamps = true;
                }
                b'R' | b'r' => opts.recursive = true,
                b's' => opts.symbolic_link = true,
                b'u' => {
                    explicit_update = true;
                    opts.update = UpdateMode::Older;
                }
                b'v' => opts.verbose = true,
                b'x' => opts.one_file_system = true,
                b'Z' => { /* SELinux: out of scope */ }
                b'S' => {
                    // -S takes an argument: rest of cluster or next arg.
                    let rest = &cluster[j + 1..];
                    if !rest.is_empty() {
                        opts.suffix = String::from_utf8_lossy(rest).into_owned();
                    } else {
                        i += 1;
                        if i >= raw.len() {
                            err("option requires an argument -- 'S'");
                            try_help();
                        }
                        opts.suffix = raw[i].to_string_lossy().into_owned();
                    }
                    j = cluster.len();
                    break;
                }
                b't' => {
                    let rest = &cluster[j + 1..];
                    if !rest.is_empty() {
                        opts.target_directory =
                            Some(PathBuf::from(OsStr::from_bytes(rest)));
                    } else {
                        i += 1;
                        if i >= raw.len() {
                            err("option requires an argument -- 't'");
                            try_help();
                        }
                        opts.target_directory = Some(PathBuf::from(&raw[i]));
                    }
                    j = cluster.len();
                    break;
                }
                b'T' => opts.no_target_directory = true,
                other => {
                    err(&format!("invalid option -- '{}'", other as char));
                    try_help();
                }
            }
            j += 1;
        }
        i += 1;
    }

    // -f is ignored when -n is also used.
    if opts.no_clobber {
        opts.force = false;
        opts.interactive = false;
    }
    let _ = no_clobber_set;

    // --no-clobber maps to update=none unless an explicit --update overrode it.
    if opts.no_clobber && !explicit_update {
        opts.update = UpdateMode::None;
    }

    // Resolve backup control from VERSION_CONTROL env when -b/--backup given
    // without an explicit =CONTROL.
    if opts.backup && !explicit_backup_control {
        if let Some(v) = env_vc {
            if let Some(m) = backup_mode_from_str(&v) {
                opts.backup_mode = m;
            }
        }
    }

    (opts, operands)
}

fn print_help() {
    println!("Usage: {} [OPTION]... [-T] SOURCE DEST", PROG);
    println!("  or:  {} [OPTION]... SOURCE... DIRECTORY", PROG);
    println!("  or:  {} [OPTION]... -t DIRECTORY SOURCE...", PROG);
    println!("Copy SOURCE to DEST, or multiple SOURCE(s) to DIRECTORY.");
}

// ---------------------------------------------------------------------------
// Backup naming
// ---------------------------------------------------------------------------

fn make_backup(dest: &Path, opts: &Opts) -> io::Result<()> {
    if opts.backup_mode == BackupMode::None {
        return Ok(());
    }
    if !dest.symlink_metadata().is_ok() {
        return Ok(()); // nothing to back up
    }
    let backup_path = match opts.backup_mode {
        BackupMode::None => return Ok(()),
        BackupMode::Simple => simple_backup_name(dest, &opts.suffix),
        BackupMode::Numbered => numbered_backup_name(dest),
        BackupMode::Existing => {
            // numbered if a numbered backup exists, simple otherwise
            if numbered_backup_exists(dest) {
                numbered_backup_name(dest)
            } else {
                simple_backup_name(dest, &opts.suffix)
            }
        }
    };
    fs::rename(dest, &backup_path)
}

fn simple_backup_name(dest: &Path, suffix: &str) -> PathBuf {
    let mut s = dest.as_os_str().to_os_string();
    s.push(suffix);
    PathBuf::from(s)
}

fn numbered_backup_name(dest: &Path) -> PathBuf {
    let mut n = 1;
    loop {
        let candidate = numbered_name(dest, n);
        if !candidate.symlink_metadata().is_ok() {
            return candidate;
        }
        n += 1;
    }
}

fn numbered_name(dest: &Path, n: u64) -> PathBuf {
    let mut s = dest.as_os_str().to_os_string();
    s.push(format!(".~{}~", n));
    PathBuf::from(s)
}

fn numbered_backup_exists(dest: &Path) -> bool {
    numbered_name(dest, 1).symlink_metadata().is_ok()
}

// ---------------------------------------------------------------------------
// Prompting (interactive)
// ---------------------------------------------------------------------------

fn prompt_overwrite(dest: &Path) -> bool {
    eprint!("{}: overwrite {}? ", PROG, quote(dest));
    let _ = io::stderr().flush();
    let mut line = String::new();
    if io::stdin().lock().read_line(&mut line).is_err() {
        return false;
    }
    let t = line.trim_start();
    t.starts_with('y') || t.starts_with('Y')
}

// ---------------------------------------------------------------------------
// libc helpers for attributes / special files
// ---------------------------------------------------------------------------

fn cpath(p: &Path) -> CString {
    CString::new(p.as_os_str().as_bytes()).unwrap()
}

fn preserve_attrs(src_meta: &fs::Metadata, dest: &Path, opts: &Opts) {
    let cdest = cpath(dest);
    if opts.preserve.ownership {
        unsafe {
            // best-effort; non-root typically cannot chown
            libc::lchown(cdest.as_ptr(), src_meta.uid(), src_meta.gid());
        }
    }
    if opts.preserve.mode && !is_symlink_meta(src_meta) {
        let perm = fs::Permissions::from_mode(src_meta.mode() & 0o7777);
        let _ = fs::set_permissions(dest, perm);
    }
    if opts.preserve.timestamps {
        set_times(dest, src_meta.atime(), src_meta.mtime());
    }
}

fn is_symlink_meta(m: &fs::Metadata) -> bool {
    m.file_type().is_symlink()
}

fn set_times(dest: &Path, atime: i64, mtime: i64) {
    let cdest = cpath(dest);
    let times = [
        libc::timeval {
            tv_sec: atime as libc::time_t,
            tv_usec: 0,
        },
        libc::timeval {
            tv_sec: mtime as libc::time_t,
            tv_usec: 0,
        },
    ];
    unsafe {
        libc::utimes(cdest.as_ptr(), times.as_ptr());
    }
}

fn make_special(src: &Path, dest: &Path, meta: &fs::Metadata) -> io::Result<()> {
    let ft = meta.file_type();
    let cdest = cpath(dest);
    use std::os::unix::fs::FileTypeExt;
    if ft.is_fifo() {
        let r = unsafe { libc::mkfifo(cdest.as_ptr(), (meta.mode() & 0o7777) as libc::mode_t) };
        if r != 0 {
            return Err(io::Error::last_os_error());
        }
        Ok(())
    } else if ft.is_block_device() || ft.is_char_device() {
        let r = unsafe {
            libc::mknod(
                cdest.as_ptr(),
                meta.mode() as libc::mode_t,
                meta.rdev() as libc::dev_t,
            )
        };
        if r != 0 {
            return Err(io::Error::last_os_error());
        }
        Ok(())
    } else {
        Err(io::Error::new(
            io::ErrorKind::Other,
            format!("cannot create special file {}", quote(src)),
        ))
    }
}

// ---------------------------------------------------------------------------
// Copy engine
// ---------------------------------------------------------------------------

struct Ctx {
    failed: bool,
    // map (dev, ino) -> first dest path, for preserving hard links
    seen_links: std::collections::HashMap<(u64, u64), PathBuf>,
    // root device for --one-file-system
    root_dev: Option<u64>,
}

fn main() {
    let (opts, operands) = parse_args();

    // Determine sources and dest.
    let mut sources: Vec<PathBuf>;
    let dest: PathBuf;
    let dest_is_target_dir: bool;

    if let Some(td) = &opts.target_directory {
        if operands.is_empty() {
            err("missing file operand");
            try_help();
        }
        sources = operands;
        dest = td.clone();
        dest_is_target_dir = true;
    } else {
        if operands.is_empty() {
            err("missing file operand");
            try_help();
        }
        if operands.len() == 1 {
            err(&format!(
                "missing destination file operand after {}",
                quote(&operands[0])
            ));
            try_help();
        }
        let mut ops = operands;
        dest = ops.pop().unwrap();
        sources = ops;
        // Whether dest is a directory determines layout, computed below.
        dest_is_target_dir = false;
    }

    // strip-trailing-slashes
    if opts.strip_trailing_slashes {
        for s in sources.iter_mut() {
            *s = strip_trailing_slashes(s);
        }
    }

    // Sanity: incompatible flags.
    if opts.no_target_directory && opts.target_directory.is_some() {
        die("cannot combine --target-directory (-t) and --no-target-directory (-T)");
    }

    let mut ctx = Ctx {
        failed: false,
        seen_links: std::collections::HashMap::new(),
        root_dev: None,
    };

    // Resolve destination directory semantics.
    let dest_is_dir = dest.is_dir(); // follows symlink, which is correct for DEST

    if dest_is_target_dir {
        // -t DIRECTORY: DEST must be (or behave as) a directory.
        if !dest.is_dir() {
            err(&format!(
                "target directory {} is not a directory",
                quote(&dest)
            ));
            exit(1);
        }
        for src in &sources {
            copy_into_dir(src, &dest, &opts, &mut ctx);
        }
    } else if opts.no_target_directory {
        // -T: treat DEST as a normal file (single source only).
        if sources.len() != 1 {
            err(&format!("extra operand {}", quote(&sources[1])));
            try_help();
        }
        copy_operand(&sources[0], &dest, &opts, &mut ctx, true);
    } else if dest_is_dir {
        // multiple sources OR single source into existing directory
        for src in &sources {
            copy_into_dir(src, &dest, &opts, &mut ctx);
        }
    } else {
        // dest is not a directory
        if sources.len() > 1 {
            err(&format!("target {} is not a directory", quote(&dest)));
            exit(1);
        }
        copy_operand(&sources[0], &dest, &opts, &mut ctx, true);
    }

    if ctx.failed {
        exit(1);
    }
}

fn strip_trailing_slashes(p: &Path) -> PathBuf {
    let bytes = p.as_os_str().as_bytes();
    let mut end = bytes.len();
    while end > 1 && bytes[end - 1] == b'/' {
        end -= 1;
    }
    PathBuf::from(OsStr::from_bytes(&bytes[..end]))
}

// Compute DEST path when copying SRC into DIRECTORY.
fn dest_in_dir(src: &Path, dir: &Path, opts: &Opts) -> PathBuf {
    if opts.parents {
        // use full source name under DIRECTORY, creating intermediate dirs
        let rel = normalize_for_parents(src);
        return dir.join(rel);
    }
    let base = src.file_name().unwrap_or_else(|| OsStr::new(""));
    dir.join(base)
}

// For --parents, strip leading "/" and "." components but keep the structure.
fn normalize_for_parents(src: &Path) -> PathBuf {
    let mut out = PathBuf::new();
    for c in src.components() {
        match c {
            Component::RootDir | Component::Prefix(_) | Component::CurDir => {}
            Component::ParentDir => out.push(".."),
            Component::Normal(s) => out.push(s),
        }
    }
    out
}

fn copy_into_dir(src: &Path, dir: &Path, opts: &Opts, ctx: &mut Ctx) {
    let dest = dest_in_dir(src, dir, opts);

    if opts.parents {
        if let Some(parent) = dest.parent() {
            if let Err(e) = fs::create_dir_all(parent) {
                err(&format!("cannot create directory {}: {}", quote(parent), e));
                ctx.failed = true;
                return;
            }
        }
    }
    copy_operand(src, &dest, opts, ctx, true);
}

// command_line=true means SRC is a top-level operand (affects -H/default deref).
fn copy_operand(src: &Path, dest: &Path, opts: &Opts, ctx: &mut Ctx, command_line: bool) {
    // Decide whether to follow a symlink at SRC.
    let follow = should_follow(opts, command_line);

    let src_meta = match if follow {
        fs::metadata(src)
    } else {
        fs::symlink_metadata(src)
    } {
        Ok(m) => m,
        Err(e) => {
            // If we tried to follow and it's a dangling symlink, GNU still
            // diagnoses; report the original.
            err(&format!("cannot stat {}: {}", quote(src), e));
            ctx.failed = true;
            return;
        }
    };

    // --one-file-system: record root device on first top-level operand.
    if opts.one_file_system && command_line && ctx.root_dev.is_none() {
        ctx.root_dev = Some(src_meta.dev());
    }

    let ft = src_meta.file_type();

    if ft.is_dir() {
        if !opts.recursive {
            err(&format!("-r not specified; omitting directory {}", quote(src)));
            ctx.failed = true;
            return;
        }
        copy_dir(src, dest, &src_meta, opts, ctx);
    } else if ft.is_symlink() {
        // We only reach here when not following (follow==false), so replicate
        // the symlink itself.
        copy_symlink(src, dest, &src_meta, opts, ctx);
    } else if ft.is_file() {
        copy_regular(src, dest, &src_meta, opts, ctx);
    } else {
        // special file (fifo, device, socket)
        copy_special_operand(src, dest, &src_meta, opts, ctx);
    }
}

fn should_follow(opts: &Opts, command_line: bool) -> bool {
    match opts.deref {
        DerefMode::Always => true,
        DerefMode::Never => false,
        DerefMode::CommandLine => command_line,
        DerefMode::Default => {
            // GNU: when not recursive and not -d, follow symlinks by default
            // for command-line args; when recursive, do not follow.
            if opts.recursive {
                false
            } else {
                command_line
            }
        }
    }
}

// Returns true if we should proceed to overwrite/create dest, false to skip.
fn check_clobber(src_meta: &fs::Metadata, dest: &Path, opts: &Opts, ctx: &mut Ctx) -> bool {
    let dest_meta = match dest.symlink_metadata() {
        Ok(m) => m,
        Err(_) => return true, // dest does not exist; proceed
    };

    // --update handling
    match opts.update {
        UpdateMode::None => {
            // skip silently, success
            return false;
        }
        UpdateMode::NoneFail => {
            err(&format!("not replacing {}", quote(dest)));
            ctx.failed = true;
            return false;
        }
        UpdateMode::Older => {
            // replace only if src is newer than dest
            let dm = match dest.metadata() {
                Ok(m) => m,
                Err(_) => dest_meta.clone(),
            };
            if src_meta.mtime() <= dm.mtime() {
                return false;
            }
        }
        UpdateMode::All => {}
    }

    if opts.interactive {
        if !prompt_overwrite(dest) {
            return false;
        }
    }

    true
}

fn same_file(a: &fs::Metadata, b: &fs::Metadata) -> bool {
    a.dev() == b.dev() && a.ino() == b.ino()
}

fn copy_regular(
    src: &Path,
    dest: &Path,
    src_meta: &fs::Metadata,
    opts: &Opts,
    ctx: &mut Ctx,
) {
    // Refuse copying a file onto itself.
    if let Ok(dmeta) = dest.symlink_metadata() {
        if let Ok(dmeta_f) = dest.metadata() {
            if same_file(src_meta, &dmeta_f) {
                // Special case from man page: -f && backup of same file allowed.
                if !(opts.force && opts.backup) {
                    err(&format!(
                        "{} and {} are the same file",
                        quote(src),
                        quote(dest)
                    ));
                    ctx.failed = true;
                    return;
                }
            }
        }
        let _ = dmeta;
    }

    if !check_clobber(src_meta, dest, opts, ctx) {
        return;
    }

    // Preserve hard links across multiple sources (--preserve=links / -d / -a).
    if opts.preserve.links && src_meta.nlink() > 1 {
        let key = (src_meta.dev(), src_meta.ino());
        if let Some(first) = ctx.seen_links.get(&key).cloned() {
            // Make dest a hard link to the previously-created dest.
            let _ = fs::remove_file(dest);
            match fs::hard_link(&first, dest) {
                Ok(()) => {
                    verbose_report(src, dest, opts);
                    return;
                }
                Err(e) => {
                    err(&format!("cannot link {}: {}", quote(dest), e));
                    ctx.failed = true;
                    return;
                }
            }
        }
    }

    // Backup of existing dest.
    if opts.backup && dest.symlink_metadata().is_ok() {
        if let Err(e) = make_backup(dest, opts) {
            err(&format!("cannot backup {}: {}", quote(dest), e));
            ctx.failed = true;
            return;
        }
    }

    // --remove-destination
    if opts.remove_destination {
        let _ = fs::remove_file(dest);
    }

    // -s: make a symbolic link instead of copying.
    if opts.symbolic_link {
        let _ = fs::remove_file(dest);
        if let Err(e) = symlink(src, dest) {
            err(&format!("cannot create symbolic link {}: {}", quote(dest), e));
            ctx.failed = true;
            return;
        }
        verbose_report(src, dest, opts);
        return;
    }

    // -l: hard link instead of copying.
    if opts.link {
        let _ = fs::remove_file(dest);
        if let Err(e) = fs::hard_link(src, dest) {
            err(&format!("cannot create hard link {}: {}", quote(dest), e));
            ctx.failed = true;
            return;
        }
        verbose_report(src, dest, opts);
        return;
    }

    // Standard data copy (unless --attributes-only).
    if opts.attributes_only {
        // ensure dest exists; create empty if needed
        if dest.symlink_metadata().is_err() {
            if let Err(e) = fs::File::create(dest) {
                err(&format!("cannot create regular file {}: {}", quote(dest), e));
                ctx.failed = true;
                return;
            }
        }
    } else if let Err(e) = do_data_copy(src, dest, src_meta, opts) {
        // --force: if dest can't be opened, remove and retry once.
        if opts.force && !opts.no_clobber {
            let _ = fs::remove_file(dest);
            if let Err(e2) = do_data_copy(src, dest, src_meta, opts) {
                err(&format!("cannot create regular file {}: {}", quote(dest), e2));
                ctx.failed = true;
                return;
            }
        } else {
            err(&format!("cannot create regular file {}: {}", quote(dest), e));
            ctx.failed = true;
            return;
        }
    }

    preserve_attrs(src_meta, dest, opts);

    if opts.preserve.links && src_meta.nlink() > 1 {
        ctx.seen_links
            .insert((src_meta.dev(), src_meta.ino()), dest.to_path_buf());
    }

    verbose_report(src, dest, opts);
}

fn do_data_copy(
    src: &Path,
    dest: &Path,
    src_meta: &fs::Metadata,
    _opts: &Opts,
) -> io::Result<()> {
    let mut input = fs::File::open(src)?;
    // Create dest with source mode bits (umask still applies until preserve).
    let mut out = fs::OpenOptions::new()
        .write(true)
        .create(true)
        .truncate(true)
        .mode(src_meta.mode() & 0o7777)
        .open(dest)?;
    let mut buf = vec![0u8; 128 * 1024];
    loop {
        let n = input.read(&mut buf)?;
        if n == 0 {
            break;
        }
        out.write_all(&buf[..n])?;
    }
    out.flush()?;
    Ok(())
}

fn copy_symlink(
    src: &Path,
    dest: &Path,
    src_meta: &fs::Metadata,
    opts: &Opts,
    ctx: &mut Ctx,
) {
    if !check_clobber(src_meta, dest, opts, ctx) {
        return;
    }
    if opts.backup && dest.symlink_metadata().is_ok() {
        if let Err(e) = make_backup(dest, opts) {
            err(&format!("cannot backup {}: {}", quote(dest), e));
            ctx.failed = true;
            return;
        }
    }
    let target = match fs::read_link(src) {
        Ok(t) => t,
        Err(e) => {
            err(&format!("cannot read symbolic link {}: {}", quote(src), e));
            ctx.failed = true;
            return;
        }
    };
    let _ = fs::remove_file(dest);
    if let Err(e) = symlink(&target, dest) {
        err(&format!("cannot create symbolic link {}: {}", quote(dest), e));
        ctx.failed = true;
        return;
    }
    if opts.preserve.ownership || opts.preserve.timestamps {
        // chown/utimes on the link itself where possible
        let cdest = cpath(dest);
        if opts.preserve.ownership {
            unsafe {
                libc::lchown(cdest.as_ptr(), src_meta.uid(), src_meta.gid());
            }
        }
    }
    verbose_report(src, dest, opts);
}

fn copy_special_operand(
    src: &Path,
    dest: &Path,
    src_meta: &fs::Metadata,
    opts: &Opts,
    ctx: &mut Ctx,
) {
    if !check_clobber(src_meta, dest, opts, ctx) {
        return;
    }
    if opts.backup && dest.symlink_metadata().is_ok() {
        let _ = make_backup(dest, opts);
    }
    let _ = fs::remove_file(dest);
    match make_special(src, dest, src_meta) {
        Ok(()) => {
            preserve_attrs(src_meta, dest, opts);
            verbose_report(src, dest, opts);
        }
        Err(e) => {
            err(&format!("cannot create {}: {}", quote(dest), e));
            ctx.failed = true;
        }
    }
}

fn copy_dir(
    src: &Path,
    dest: &Path,
    src_meta: &fs::Metadata,
    opts: &Opts,
    ctx: &mut Ctx,
) {
    // --one-file-system: skip directories on a different device.
    if opts.one_file_system {
        if let Some(rd) = ctx.root_dev {
            if src_meta.dev() != rd {
                return;
            }
        }
    }

    // Create destination directory if needed.
    match dest.symlink_metadata() {
        Ok(m) => {
            if !m.file_type().is_dir() {
                err(&format!(
                    "cannot overwrite non-directory {} with directory {}",
                    quote(dest),
                    quote(src)
                ));
                ctx.failed = true;
                return;
            }
        }
        Err(_) => {
            if let Err(e) = fs::create_dir(dest) {
                err(&format!("cannot create directory {}: {}", quote(dest), e));
                ctx.failed = true;
                return;
            }
        }
    }

    // Recurse into entries.
    let entries = match fs::read_dir(src) {
        Ok(e) => e,
        Err(e) => {
            err(&format!("cannot read directory {}: {}", quote(src), e));
            ctx.failed = true;
            return;
        }
    };
    let mut names: HashSet<OsString> = HashSet::new();
    for entry in entries {
        let entry = match entry {
            Ok(e) => e,
            Err(_) => continue,
        };
        let name = entry.file_name();
        names.insert(name.clone());
        let child_src = src.join(&name);
        let child_dest = dest.join(&name);
        // Children are not command-line operands.
        copy_operand(&child_src, &child_dest, opts, ctx, false);
    }
    let _ = names;

    // Preserve directory attributes after populating it.
    preserve_attrs(src_meta, dest, opts);

    verbose_report(src, dest, opts);
}

fn verbose_report(src: &Path, dest: &Path, opts: &Opts) {
    if opts.verbose {
        println!("{} -> {}", src.display(), dest.display());
    }
}
