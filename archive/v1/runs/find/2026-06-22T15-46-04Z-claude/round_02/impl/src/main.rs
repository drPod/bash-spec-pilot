// Single-file Rust reimplementation of a core subset of GNU find(1).
//
// Scope (per the frozen man page): starting-point traversal, the predicates
// -name/-iname, -path/-ipath/-wholename, -type (single + comma list),
// -maxdepth/-mindepth, -size, -empty, -true/-false; the actions -print,
// -print0, -prune, -quit, -exec (both `;` and `+` forms); operators
// -a/-and (and implicit), -o/-or, !/-not, ( ), and the global options
// -depth/-d. Symlink handling: -P (default), -L, -H.
//
// Deliberately skipped (documented in _deps_rationale.txt): time predicates
// (-mtime/-atime/-ctime/-mmin/...), ownership/perm predicates
// (-user/-group/-uid/-gid/-perm/-readable/-writable/-executable), -regex,
// -lname, -inum/-links/-samefile, -newer*, -printf/-ls/-fprint*, -delete,
// -execdir/-ok/-okdir, -prune-via-comma `,` operator, -fstype, -xdev/-mount,
// SELinux/-context, regextype, debug/-O options.

use std::ffi::{CString, OsStr, OsString};
use std::os::unix::ffi::{OsStrExt, OsStringExt};
use std::os::unix::fs::MetadataExt;
use std::path::{Path, PathBuf};
use std::process::{exit, Command};

// ---------------------------------------------------------------------------
// Exit status. GNU find returns 0 on success, >0 if any error occurred.
// ---------------------------------------------------------------------------
static mut EXIT_STATUS: i32 = 0;

fn set_error() {
    // ponytail: process-global mutable status mirrors find's single-threaded
    // error accumulation; a threaded impl would carry this in context.
    unsafe {
        EXIT_STATUS = 1;
    }
}

fn current_status() -> i32 {
    unsafe { EXIT_STATUS }
}

fn fatal(msg: &str) -> ! {
    eprintln!("util: {}", msg);
    exit(2);
}

// ---------------------------------------------------------------------------
// Symlink handling mode set by -P / -L / -H (the "real" options).
// ---------------------------------------------------------------------------
#[derive(Clone, Copy, PartialEq)]
enum LinkMode {
    P, // never follow (default)
    L, // always follow
    H, // follow only on the command-line start points
}

// ---------------------------------------------------------------------------
// File type letters used by -type.
// ---------------------------------------------------------------------------
fn type_matches(letter: u8, md: &std::fs::Metadata) -> bool {
    let ft = md.file_type();
    match letter {
        b'f' => ft.is_file(),
        b'd' => ft.is_dir(),
        b'l' => ft.is_symlink(),
        b'b' => md.mode() & libc::S_IFMT == libc::S_IFBLK,
        b'c' => md.mode() & libc::S_IFMT == libc::S_IFCHR,
        b'p' => md.mode() & libc::S_IFMT == libc::S_IFIFO,
        b's' => md.mode() & libc::S_IFMT == libc::S_IFSOCK,
        _ => false,
    }
}

// ---------------------------------------------------------------------------
// Numeric comparison with the +n / -n / n convention (man page TESTS section).
// ---------------------------------------------------------------------------
#[derive(Clone, Copy)]
enum NumCmp {
    Greater(u64), // +n  -> value > n
    Less(u64),    // -n  -> value < n
    Exact(u64),   // n   -> value == n
}

impl NumCmp {
    fn parse(s: &str) -> Result<(NumCmp, &str), String> {
        // Returns the comparison plus the trailing (unit) suffix, if any.
        let (kind, rest) = if let Some(r) = s.strip_prefix('+') {
            (1, r)
        } else if let Some(r) = s.strip_prefix('-') {
            (-1, r)
        } else {
            (0, s)
        };
        // Split leading digits from any trailing unit characters.
        let digits_end = rest.find(|c: char| !c.is_ascii_digit()).unwrap_or(rest.len());
        let (num_str, suffix) = rest.split_at(digits_end);
        if num_str.is_empty() {
            return Err(format!("invalid numeric argument `{}'", s));
        }
        let n: u64 = num_str
            .parse()
            .map_err(|_| format!("invalid numeric argument `{}'", s))?;
        let cmp = match kind {
            1 => NumCmp::Greater(n),
            -1 => NumCmp::Less(n),
            _ => NumCmp::Exact(n),
        };
        Ok((cmp, suffix))
    }

    fn test(&self, value: u64) -> bool {
        match *self {
            NumCmp::Greater(n) => value > n,
            NumCmp::Less(n) => value < n,
            NumCmp::Exact(n) => value == n,
        }
    }
}

// ---------------------------------------------------------------------------
// fnmatch-style shell pattern matching for -name / -path.
// We delegate to the libc fnmatch(3) the man page references (line ~619).
// -name strips a path component; -path matches the whole name. The FNM_PATHNAME
// flag is NOT set for either (find's -path explicitly does not treat `/`
// specially, man page line ~666).
// ---------------------------------------------------------------------------
fn fnmatch(pattern: &OsStr, name: &OsStr) -> bool {
    let pat = match CString::new(pattern.as_bytes()) {
        Ok(p) => p,
        Err(_) => return false, // embedded NUL: cannot occur in a real filename
    };
    let nm = match CString::new(name.as_bytes()) {
        Ok(n) => n,
        Err(_) => return false,
    };
    unsafe { libc::fnmatch(pat.as_ptr(), nm.as_ptr(), 0) == 0 }
}

fn fnmatch_ci(pattern: &OsStr, name: &OsStr) -> bool {
    // Case-insensitive via FNM_CASEFOLD (GNU extension, used by -iname/-ipath).
    let pat = match CString::new(pattern.as_bytes()) {
        Ok(p) => p,
        Err(_) => return false,
    };
    let nm = match CString::new(name.as_bytes()) {
        Ok(n) => n,
        Err(_) => return false,
    };
    const FNM_CASEFOLD: libc::c_int = 1 << 4;
    unsafe { libc::fnmatch(pat.as_ptr(), nm.as_ptr(), FNM_CASEFOLD) == 0 }
}

// ---------------------------------------------------------------------------
// Expression AST.
// ---------------------------------------------------------------------------
enum Expr {
    True,
    False,
    Name(OsString),
    IName(OsString),
    Path(OsString),
    IPath(OsString),
    Type(Vec<u8>), // one or more type letters (comma list)
    Size(NumCmp, u64), // comparison, unit size in bytes
    Empty,
    Print,
    Print0,
    Prune,
    Quit,
    // -exec argv ;   (per-file)   or   -exec argv {} +   (batched)
    Exec { argv: Vec<OsString>, plus: bool },
    Not(Box<Expr>),
    And(Box<Expr>, Box<Expr>),
    Or(Box<Expr>, Box<Expr>),
}

// Whether an expression contains an action that suppresses the default -print.
// Man page lines ~255-259: -prune and -quit do NOT suppress; -print/-print0/
// -exec do.
fn suppresses_default_print(e: &Expr) -> bool {
    match e {
        Expr::Print | Expr::Print0 | Expr::Exec { .. } => true,
        Expr::Not(a) => suppresses_default_print(a),
        Expr::And(a, b) | Expr::Or(a, b) => {
            suppresses_default_print(a) || suppresses_default_print(b)
        }
        _ => false,
    }
}

// ---------------------------------------------------------------------------
// Traversal context shared across the walk.
// ---------------------------------------------------------------------------
struct Context {
    link_mode: LinkMode,
    depth_first: bool,        // -depth / -d
    maxdepth: Option<usize>,
    mindepth: usize,
    quit: bool,               // set once -quit fires; aborts the whole walk
    // Pending argv batches for `-exec ... {} +`, keyed by position in a flat
    // vector. Index aligns with the order Exec(plus=true) nodes are discovered.
    plus_batches: Vec<PlusBatch>,
}

struct PlusBatch {
    argv_template: Vec<OsString>, // contains exactly one "{}" placeholder slot
    pending: Vec<OsString>,       // accumulated file names
}

// A node visited during traversal.
struct Entry {
    path: PathBuf,
    depth: usize,
    // Metadata per the active link mode. None if it could not be stat'd.
    md: Option<std::fs::Metadata>,
}

// ---------------------------------------------------------------------------
// stat / lstat per link mode.
// ---------------------------------------------------------------------------
fn get_meta(path: &Path, mode: LinkMode, is_cmdline: bool) -> Option<std::fs::Metadata> {
    let follow = match mode {
        LinkMode::P => false,
        LinkMode::L => true,
        LinkMode::H => is_cmdline,
    };
    let res = if follow {
        std::fs::metadata(path)
    } else {
        std::fs::symlink_metadata(path)
    };
    match res {
        Ok(m) => Some(m),
        Err(_) if follow => {
            // Broken link / unreadable target: fall back to the link itself.
            std::fs::symlink_metadata(path).ok()
        }
        Err(_) => None,
    }
}

// ---------------------------------------------------------------------------
// Evaluate an expression against an entry. Returns the boolean result; side
// effects (printing, exec, prune) happen here. `pruned` is set if -prune fired
// on a directory so the caller skips descent.
// ---------------------------------------------------------------------------
fn eval(e: &Expr, entry: &Entry, ctx: &mut Context, pruned: &mut bool, exec_idx: &mut usize) -> bool {
    match e {
        Expr::True => true,
        Expr::False => false,
        Expr::Empty => {
            // Empty regular file (size 0) or empty directory (man page line 512).
            match &entry.md {
                Some(m) if m.is_file() => m.len() == 0,
                Some(m) if m.is_dir() => match std::fs::read_dir(&entry.path) {
                    Ok(mut it) => it.next().is_none(),
                    Err(_) => {
                        set_error();
                        false
                    }
                },
                _ => false,
            }
        }
        Expr::Name(pat) => {
            let base = basename(&entry.path);
            fnmatch(pat, &base)
        }
        Expr::IName(pat) => {
            let base = basename(&entry.path);
            fnmatch_ci(pat, &base)
        }
        Expr::Path(pat) => fnmatch(pat, entry.path.as_os_str()),
        Expr::IPath(pat) => fnmatch_ci(pat, entry.path.as_os_str()),
        Expr::Type(letters) => match &entry.md {
            Some(m) => letters.iter().any(|&c| type_matches(c, m)),
            None => false,
        },
        Expr::Size(cmp, unit) => match &entry.md {
            Some(m) => {
                // Round size up to the next whole unit (man page line ~744).
                let bytes = m.len();
                let units = if *unit <= 1 {
                    bytes
                } else {
                    (bytes + unit - 1) / unit
                };
                cmp.test(units)
            }
            None => false,
        },
        Expr::Print => {
            print_path(&entry.path, b'\n');
            true
        }
        Expr::Print0 => {
            print_path(&entry.path, 0);
            true
        }
        Expr::Prune => {
            // -depth makes -prune a no-op (man page line ~1294).
            if !ctx.depth_first {
                if let Some(m) = &entry.md {
                    if m.is_dir() {
                        *pruned = true;
                    }
                }
            }
            true
        }
        Expr::Quit => {
            ctx.quit = true;
            true
        }
        Expr::Exec { argv, plus } => {
            let idx = *exec_idx;
            *exec_idx += 1;
            if *plus {
                ctx.plus_batches[idx]
                    .pending
                    .push(entry.path.clone().into_os_string());
                true // `+` form always returns true (man page line ~909)
            } else {
                run_exec_single(argv, &entry.path)
            }
        }
        Expr::Not(a) => !eval(a, entry, ctx, pruned, exec_idx),
        Expr::And(a, b) => {
            // Short-circuit: b not evaluated if a is false (man page line ~1341).
            if !eval(a, entry, ctx, pruned, exec_idx) {
                false
            } else {
                eval(b, entry, ctx, pruned, exec_idx)
            }
        }
        Expr::Or(a, b) => {
            // Short-circuit: b not evaluated if a is true (man page line ~1353).
            if eval(a, entry, ctx, pruned, exec_idx) {
                true
            } else {
                eval(b, entry, ctx, pruned, exec_idx)
            }
        }
    }
}

fn basename(p: &Path) -> OsString {
    match p.file_name() {
        Some(n) => n.to_os_string(),
        // For "/" the base name is "/" (man page line ~608).
        None => p.as_os_str().to_os_string(),
    }
}

fn print_path(p: &Path, terminator: u8) {
    use std::io::Write;
    let stdout = std::io::stdout();
    let mut h = stdout.lock();
    // Print raw bytes; find does not mangle names for -print/-print0 in our
    // scope (UNUSUAL FILENAMES quoting on a tty is out of scope).
    let _ = h.write_all(p.as_os_str().as_bytes());
    let _ = h.write_all(&[terminator]);
}

// Run `-exec cmd ... ;` substituting {} for the path everywhere it occurs.
fn run_exec_single(argv: &[OsString], path: &Path) -> bool {
    let placeholder = OsStr::new("{}");
    let mut built: Vec<OsString> = Vec::with_capacity(argv.len());
    for a in argv {
        if a == placeholder {
            built.push(path.as_os_str().to_os_string());
        } else if a.as_bytes().windows(2).any(|w| w == b"{}") {
            built.push(substitute_braces(a, path));
        } else {
            built.push(a.clone());
        }
    }
    spawn(&built)
}

// Replace every "{}" inside a single argument with the path (man page line
// ~880: {} is replaced everywhere it occurs, not only when standalone).
fn substitute_braces(arg: &OsStr, path: &Path) -> OsString {
    let bytes = arg.as_bytes();
    let path_bytes = path.as_os_str().as_bytes();
    let mut out: Vec<u8> = Vec::with_capacity(bytes.len());
    let mut i = 0;
    while i < bytes.len() {
        if i + 1 < bytes.len() && bytes[i] == b'{' && bytes[i + 1] == b'}' {
            out.extend_from_slice(path_bytes);
            i += 2;
        } else {
            out.push(bytes[i]);
            i += 1;
        }
    }
    OsString::from_vec(out)
}

fn spawn(argv: &[OsString]) -> bool {
    if argv.is_empty() {
        return false;
    }
    match Command::new(&argv[0]).args(&argv[1..]).status() {
        Ok(st) => st.success(),
        Err(e) => {
            eprintln!("util: {}: {}", argv[0].to_string_lossy(), e);
            set_error();
            false
        }
    }
}

// Flush any `-exec ... {} +` batches at end of run / on -quit.
fn flush_plus_batches(ctx: &mut Context) {
    for batch in ctx.plus_batches.iter_mut() {
        if batch.pending.is_empty() {
            continue;
        }
        // Build argv with the accumulated files spliced in at the {} slot.
        let mut built: Vec<OsString> = Vec::new();
        for a in &batch.argv_template {
            if a == OsStr::new("{}") {
                built.extend(batch.pending.iter().cloned());
            } else {
                built.push(a.clone());
            }
        }
        if !built.is_empty() && !spawn(&built) {
            set_error(); // `+` form: nonzero child status -> find exit nonzero
        }
        batch.pending.clear();
    }
}

// ---------------------------------------------------------------------------
// Traversal. Iterative stack to avoid recursion depth limits.
// ---------------------------------------------------------------------------
fn walk(start: &Path, expr: &Expr, ctx: &mut Context) {
    // Each start point is processed with depth 0.
    visit_root(start, expr, ctx);
}

fn visit_root(start: &Path, expr: &Expr, ctx: &mut Context) {
    let md = get_meta(start, ctx.link_mode, true);
    if md.is_none() {
        eprintln!(
            "util: '{}': No such file or directory",
            start.display()
        );
        set_error();
        return;
    }
    recurse(start.to_path_buf(), 0, md, expr, ctx);
}

fn recurse(
    path: PathBuf,
    depth: usize,
    md: Option<std::fs::Metadata>,
    expr: &Expr,
    ctx: &mut Context,
) {
    if ctx.quit {
        return;
    }

    let is_dir = md.as_ref().map(|m| m.is_dir()).unwrap_or(false);
    let entry = Entry { path: path.clone(), depth, md };

    let within_max = ctx.maxdepth.map(|mx| depth < mx).unwrap_or(true);
    let mut pruned = false;

    // Pre-order: test/act before descending.
    if !ctx.depth_first {
        if depth >= ctx.mindepth {
            let mut exec_idx = 0;
            eval(expr, &entry, ctx, &mut pruned, &mut exec_idx);
        }
        if ctx.quit {
            return;
        }
    }

    if is_dir && !pruned && within_max {
        descend(&path, depth, expr, ctx);
        if ctx.quit {
            return;
        }
    }

    // Post-order (-depth): test/act after descending.
    if ctx.depth_first && depth >= ctx.mindepth {
        let mut exec_idx = 0;
        eval(expr, &entry, ctx, &mut pruned, &mut exec_idx);
    }
}

fn descend(dir: &Path, depth: usize, expr: &Expr, ctx: &mut Context) {
    let rd = match std::fs::read_dir(dir) {
        Ok(rd) => rd,
        Err(e) => {
            eprintln!("util: '{}': {}", dir.display(), e);
            set_error();
            return;
        }
    };
    for ent in rd {
        if ctx.quit {
            return;
        }
        let ent = match ent {
            Ok(e) => e,
            Err(e) => {
                eprintln!("util: '{}': {}", dir.display(), e);
                set_error();
                continue;
            }
        };
        let child = ent.path();
        let cmd = get_meta(&child, ctx.link_mode, false);
        recurse(child, depth + 1, cmd, expr, ctx);
    }
}

// ---------------------------------------------------------------------------
// Argument parsing: split [options] [paths] [expression], then parse the
// expression with a recursive-descent precedence parser.
// ---------------------------------------------------------------------------

struct Parser<'a> {
    toks: &'a [OsString],
    pos: usize,
    // Pre-registered `-exec ... +` batch templates, in discovery order.
    plus_templates: Vec<Vec<OsString>>,
}

impl<'a> Parser<'a> {
    fn peek(&self) -> Option<&OsString> {
        self.toks.get(self.pos)
    }
    fn next(&mut self) -> Option<&OsString> {
        let t = self.toks.get(self.pos);
        if t.is_some() {
            self.pos += 1;
        }
        t
    }
    fn expect_arg(&mut self, opt: &str) -> OsString {
        match self.next() {
            Some(a) => a.clone(),
            None => fatal(&format!("missing argument to {}", opt)),
        }
    }

    // Grammar (decreasing precedence): or := and (-o and)* ;
    //   and := unary ( [-a] unary )* ; unary := [! | -not] primary ;
    //   primary := '(' or ')' | test | action.
    fn parse_or(&mut self) -> Expr {
        let mut left = self.parse_and();
        while let Some(t) = self.peek() {
            if t == "-o" || t == "-or" {
                self.pos += 1;
                let right = self.parse_and();
                left = Expr::Or(Box::new(left), Box::new(right));
            } else {
                break;
            }
        }
        left
    }

    fn parse_and(&mut self) -> Expr {
        let mut left = self.parse_unary();
        while let Some(t) = self.peek() {
            if t == "-o" || t == "-or" || t == ")" {
                break;
            }
            if t == "-a" || t == "-and" {
                self.pos += 1;
                let right = self.parse_unary();
                left = Expr::And(Box::new(left), Box::new(right));
            } else {
                // Implicit -a between two adjacent primaries.
                let right = self.parse_unary();
                left = Expr::And(Box::new(left), Box::new(right));
            }
        }
        left
    }

    fn parse_unary(&mut self) -> Expr {
        if let Some(t) = self.peek() {
            if t == "!" || t == "-not" {
                self.pos += 1;
                let inner = self.parse_unary();
                return Expr::Not(Box::new(inner));
            }
        }
        self.parse_primary()
    }

    fn parse_primary(&mut self) -> Expr {
        let tok = match self.next() {
            Some(t) => t.clone(),
            None => fatal("expected an expression"),
        };
        let s = tok.to_string_lossy();
        match s.as_ref() {
            "(" => {
                let inner = self.parse_or();
                match self.next() {
                    Some(t) if t == ")" => {}
                    _ => fatal("expected `)'"),
                }
                inner
            }
            "-true" => Expr::True,
            "-false" => Expr::False,
            "-print" => Expr::Print,
            "-print0" => Expr::Print0,
            "-prune" => Expr::Prune,
            "-quit" => Expr::Quit,
            "-empty" => Expr::Empty,
            "-name" => Expr::Name(self.expect_arg("-name")),
            "-iname" => Expr::IName(self.expect_arg("-iname")),
            "-path" | "-wholename" => Expr::Path(self.expect_arg(&s)),
            "-ipath" | "-iwholename" => Expr::IPath(self.expect_arg(&s)),
            "-type" => {
                let arg = self.expect_arg("-type");
                let letters = parse_type_list(&arg.to_string_lossy());
                Expr::Type(letters)
            }
            "-size" => {
                let arg = self.expect_arg("-size");
                let (cmp, unit) = parse_size(&arg.to_string_lossy());
                Expr::Size(cmp, unit)
            }
            "-exec" => self.parse_exec(),
            other => fatal(&format!("unknown predicate `{}'", other)),
        }
    }

    fn parse_exec(&mut self) -> Expr {
        // Collect argv up to a lone ";" or a lone "{} +" terminator.
        let mut argv: Vec<OsString> = Vec::new();
        let mut plus = false;
        loop {
            let t = match self.next() {
                Some(t) => t.clone(),
                None => fatal("missing terminator (`;' or `+') for -exec"),
            };
            if t == ";" {
                break;
            }
            // `+` terminates only when the immediately preceding token was `{}`.
            if t == "+" {
                if argv.last().map(|x| x == OsStr::new("{}")).unwrap_or(false) {
                    plus = true;
                    break;
                } else {
                    // A literal `+` argument to the command.
                    argv.push(t);
                    continue;
                }
            }
            argv.push(t);
        }
        if argv.is_empty() {
            fatal("-exec requires a command");
        }
        if plus {
            self.plus_templates.push(argv.clone());
        }
        Expr::Exec { argv, plus }
    }
}

fn parse_type_list(s: &str) -> Vec<u8> {
    // Comma-separated list of type letters (GNU extension, man page line ~801).
    let mut out = Vec::new();
    for part in s.split(',') {
        let b = part.as_bytes();
        if b.len() != 1 || !matches!(b[0], b'f' | b'd' | b'l' | b'b' | b'c' | b'p' | b's' | b'D') {
            fatal(&format!("unknown argument to -type: {}", part));
        }
        out.push(b[0]);
    }
    if out.is_empty() {
        fatal("-type requires an argument");
    }
    out
}

fn parse_size(s: &str) -> (NumCmp, u64) {
    let (cmp, suffix) = match NumCmp::parse(s) {
        Ok(v) => v,
        Err(e) => fatal(&e),
    };
    // Suffix -> unit size in bytes (man page line ~743).
    let unit: u64 = match suffix {
        "" | "b" => 512,
        "c" => 1,
        "w" => 2,
        "k" => 1024,
        "M" => 1024 * 1024,
        "G" => 1024 * 1024 * 1024,
        other => fatal(&format!("invalid size suffix `{}'", other)),
    };
    (cmp, unit)
}

// ---------------------------------------------------------------------------
// Top-level CLI split.
// ---------------------------------------------------------------------------
fn is_expr_start(arg: &OsStr) -> bool {
    // An expression begins at the first arg starting with '-', or '(' or '!'.
    let b = arg.as_bytes();
    !b.is_empty() && (b[0] == b'-' || b == b"(" || b == b"!")
}

fn main() {
    let raw: Vec<OsString> = std::env::args_os().skip(1).collect();
    let mut i = 0;
    let mut link_mode = LinkMode::P;

    // 1. The "real" options -H/-L/-P (last wins). -depth/-d may also lead, but
    //    GNU treats -depth as a global expression option; we accept it here too.
    while i < raw.len() {
        let a = &raw[i];
        match a.to_string_lossy().as_ref() {
            "-H" => {
                link_mode = LinkMode::H;
                i += 1;
            }
            "-L" => {
                link_mode = LinkMode::L;
                i += 1;
            }
            "-P" => {
                link_mode = LinkMode::P;
                i += 1;
            }
            _ => break,
        }
    }

    // 2. Starting points: everything until the first expression token.
    let mut starts: Vec<PathBuf> = Vec::new();
    while i < raw.len() {
        if is_expr_start(&raw[i]) {
            break;
        }
        starts.push(PathBuf::from(&raw[i]));
        i += 1;
    }
    if starts.is_empty() {
        starts.push(PathBuf::from(".")); // default start point (man page line 17)
    }

    // 3. Pull out global options that may appear before/among the expression
    //    in our supported subset: -depth/-d, -maxdepth, -mindepth. We strip
    //    them so the expression parser sees only tests/actions/operators.
    let mut depth_first = false;
    let mut maxdepth: Option<usize> = None;
    let mut mindepth: usize = 0;
    let mut expr_toks: Vec<OsString> = Vec::new();
    while i < raw.len() {
        let s = raw[i].to_string_lossy().into_owned();
        match s.as_str() {
            "-depth" | "-d" => {
                depth_first = true;
                i += 1;
            }
            "-maxdepth" => {
                i += 1;
                let v = raw.get(i).map(|x| x.to_string_lossy().into_owned());
                match v.as_deref().and_then(|x| x.parse::<usize>().ok()) {
                    Some(n) => maxdepth = Some(n),
                    None => fatal("invalid argument to -maxdepth"),
                }
                i += 1;
            }
            "-mindepth" => {
                i += 1;
                let v = raw.get(i).map(|x| x.to_string_lossy().into_owned());
                match v.as_deref().and_then(|x| x.parse::<usize>().ok()) {
                    Some(n) => mindepth = n,
                    None => fatal("invalid argument to -mindepth"),
                }
                i += 1;
            }
            _ => {
                expr_toks.push(raw[i].clone());
                i += 1;
            }
        }
    }

    // 4. Parse the remaining expression (may be empty -> default -print).
    let (expr, plus_templates): (Expr, Vec<Vec<OsString>>) = if expr_toks.is_empty() {
        (Expr::Print, Vec::new())
    } else {
        let mut p = Parser {
            toks: &expr_toks,
            pos: 0,
            plus_templates: Vec::new(),
        };
        let e = p.parse_or();
        if p.pos != expr_toks.len() {
            fatal(&format!(
                "unexpected extra argument `{}'",
                expr_toks[p.pos].to_string_lossy()
            ));
        }
        (e, p.plus_templates)
    };

    // 5. Wrap with default -print unless an output action is present
    //    (man page lines ~255-259).
    let final_expr = if suppresses_default_print(&expr) {
        expr
    } else {
        // Equivalent to ( expr ) -a -print, but -print only runs when expr true.
        Expr::And(Box::new(expr), Box::new(Expr::Print))
    };

    let mut ctx = Context {
        link_mode,
        depth_first,
        maxdepth,
        mindepth,
        quit: false,
        plus_batches: plus_templates
            .into_iter()
            .map(|t| PlusBatch {
                argv_template: t,
                pending: Vec::new(),
            })
            .collect(),
    };

    for start in &starts {
        if ctx.quit {
            break;
        }
        walk(start, &final_expr, &mut ctx);
    }

    // Any pending `-exec ... +` batches run before exit, even on -quit
    // (man page line ~1308).
    flush_plus_batches(&mut ctx);

    exit(current_status());
}
