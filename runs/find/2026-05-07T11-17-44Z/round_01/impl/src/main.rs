use regex::bytes::{Regex, RegexBuilder};
use std::cell::RefCell;
use std::collections::HashSet;
use std::env;
use std::ffi::{CString, OsStr, OsString};
use std::fs::{self, File, Metadata};
use std::io::{self, Read, Write};
use std::os::unix::ffi::{OsStrExt, OsStringExt};
use std::os::unix::fs::{FileTypeExt, MetadataExt, PermissionsExt};
use std::path::{Path, PathBuf};
use std::process::Command;
use std::rc::Rc;
use std::time::{SystemTime, UNIX_EPOCH};

#[derive(Clone, Copy, PartialEq)]
enum LinkMode { H, L, P }

struct Options {
    link_mode: LinkMode,
    follow_links: bool,
    depth_first: bool,
    maxdepth: Option<usize>,
    mindepth: usize,
    xdev: bool,
    ignore_race: bool,
}
impl Default for Options {
    fn default() -> Self { Self { link_mode: LinkMode::P, follow_links: false, depth_first: false, maxdepth: None, mindepth: 0, xdev: false, ignore_race: false } }
}

#[derive(Clone, Copy)]
enum Cmp { Less, Equal, Greater }
#[derive(Clone, Copy)]
struct NumCmp { op: Cmp, n: i64 }
impl NumCmp {
    fn parse(s: &str) -> Result<Self,String> {
        let (op, rest) = if let Some(r)=s.strip_prefix('+') {(Cmp::Greater,r)} else if let Some(r)=s.strip_prefix('-') {(Cmp::Less,r)} else {(Cmp::Equal,s)};
        let n = rest.parse::<i64>().map_err(|_| format!("invalid number `{}`", s))?;
        Ok(Self{op,n})
    }
    fn matches(&self, v: i64) -> bool { match self.op { Cmp::Less => v < self.n, Cmp::Equal => v == self.n, Cmp::Greater => v > self.n } }
}

#[derive(Clone, Copy)]
enum TimeKind { A, M, C }
#[derive(Clone, Copy)]
enum PermMode { Exact(u32), All(u32), Any(u32) }

enum Out { Stdout, Stderr, File(Rc<RefCell<File>>) }
impl Out {
    fn write(&self, b: &[u8]) -> io::Result<()> { match self { Out::Stdout => { let mut o=io::stdout(); o.write_all(b)?; o.flush() }, Out::Stderr => { let mut e=io::stderr(); e.write_all(b)?; e.flush() }, Out::File(f) => f.borrow_mut().write_all(b) } }
}

enum Expr {
    True, False,
    Not(Box<Expr>), And(Box<Expr>,Box<Expr>), Or(Box<Expr>,Box<Expr>), Comma(Box<Expr>,Box<Expr>),
    Name(Vec<u8>, bool), Path(Vec<u8>, bool), Regex(Regex), LName(Vec<u8>, bool),
    Type(Vec<u8>, bool), Empty, Perm(PermMode), Size(NumCmp,u64), Time(TimeKind,NumCmp,bool), Newer(TimeKind,i64),
    Uid(NumCmp), Gid(NumCmp), User(u32), Group(u32), NoUser, NoGroup, Links(NumCmp), Inum(NumCmp), SameFile(u64,u64), Access(i32),
    Print(Out,bool), Printf(Out,Vec<u8>), Ls(Out), Delete, Prune, Quit, Exec(Vec<OsString>,bool),
}

struct State { opts: Options, exit_code: i32, quit: bool }
struct EvalCtx { prune: bool }
struct Info { path: PathBuf, display: Vec<u8>, start: Vec<u8>, depth: usize, meta: Metadata, lmeta: Metadata }

fn eprintln_find(msg: impl AsRef<str>) { eprintln!("find: {}", msg.as_ref()); }
fn bytes_of_path(p: &Path) -> Vec<u8> { p.as_os_str().as_bytes().to_vec() }
fn cstring(b: &[u8]) -> Option<CString> { CString::new(b).ok() }

fn fnmatch_bytes(pat: &[u8], text: &[u8], insensitive: bool) -> bool {
    let (p,t) = if insensitive { (pat.iter().map(|c| c.to_ascii_lowercase()).collect::<Vec<_>>(), text.iter().map(|c| c.to_ascii_lowercase()).collect::<Vec<_>>()) } else { (pat.to_vec(), text.to_vec()) };
    match (cstring(&p), cstring(&t)) { (Some(cp),Some(ct)) => unsafe { libc::fnmatch(cp.as_ptr(), ct.as_ptr(), 0) == 0 }, _ => false }
}
fn basename_bytes(path: &Path) -> Vec<u8> {
    if path.as_os_str().as_bytes() == b"/" { return b"/".to_vec(); }
    path.file_name().map(|s| s.as_bytes().to_vec()).unwrap_or_else(|| path.as_os_str().as_bytes().to_vec())
}
fn dirname_bytes(path: &Path) -> Vec<u8> {
    let b = path.as_os_str().as_bytes();
    if !b.contains(&b'/') { return b".".to_vec(); }
    if b == b"/" { return Vec::new(); }
    let trimmed = if b.len()>1 && b.ends_with(b"/") { &b[..b.len()-1] } else { b };
    match trimmed.iter().rposition(|&c| c==b'/') { Some(0) => Vec::new(), Some(i) => trimmed[..i].to_vec(), None => b".".to_vec() }
}
fn rel_to_start(display: &[u8], start: &[u8]) -> Vec<u8> {
    if display == start { return Vec::new(); }
    if display.starts_with(start) { let mut r=&display[start.len()..]; if r.starts_with(b"/") { r=&r[1..]; } return r.to_vec(); }
    display.to_vec()
}

fn file_type_char(ft: fs::FileType) -> u8 {
    if ft.is_dir(){b'd'} else if ft.is_file(){b'f'} else if ft.is_symlink(){b'l'} else if ft.is_block_device(){b'b'} else if ft.is_char_device(){b'c'} else if ft.is_fifo(){b'p'} else if ft.is_socket(){b's'} else {b'U'}
}
fn mode_string(meta: &Metadata) -> Vec<u8> {
    let m=meta.mode(); let mut s=Vec::new(); s.push(file_type_char(meta.file_type()));
    for (r,w,x) in [(0o400,0o200,0o100),(0o040,0o020,0o010),(0o004,0o002,0o001)] { s.push(if m&r!=0{b'r'}else{b'-'}); s.push(if m&w!=0{b'w'}else{b'-'}); s.push(if m&x!=0{b'x'}else{b'-'}); }
    s
}
fn rounded_units(size: u64, unit: u64) -> i64 { if size==0 {0} else { ((size + unit - 1)/unit) as i64 } }
fn now_secs() -> i64 { SystemTime::now().duration_since(UNIX_EPOCH).unwrap_or_default().as_secs() as i64 }
fn meta_time(meta: &Metadata, k: TimeKind) -> i64 { match k { TimeKind::A => meta.atime(), TimeKind::M => meta.mtime(), TimeKind::C => meta.ctime() } }

fn lookup_user(name: &str) -> Option<u32> { if let Ok(n)=name.parse::<u32>() { return Some(n); } let c=CString::new(name).ok()?; unsafe { let p=libc::getpwnam(c.as_ptr()); if p.is_null(){None}else{Some((*p).pw_uid)} } }
fn lookup_group(name: &str) -> Option<u32> { if let Ok(n)=name.parse::<u32>() { return Some(n); } let c=CString::new(name).ok()?; unsafe { let p=libc::getgrnam(c.as_ptr()); if p.is_null(){None}else{Some((*p).gr_gid)} } }
fn uid_exists(uid: u32) -> bool { unsafe { !libc::getpwuid(uid).is_null() } }
fn gid_exists(gid: u32) -> bool { unsafe { !libc::getgrgid(gid).is_null() } }

fn parse_perm_bits(s: &str) -> Result<u32,String> {
    if !s.is_empty() && s.chars().all(|c| c>='0' && c<='7') { return u32::from_str_radix(s,8).map_err(|_| format!("invalid mode `{}`", s)); }
    let mut bits=0u32;
    for cl in s.split(',') {
        let mut chars=cl.chars().peekable(); let mut who=0u32;
        while let Some(&c)=chars.peek() { match c { 'u'=>{who|=0o700; chars.next();}, 'g'=>{who|=0o070; chars.next();}, 'o'=>{who|=0o007; chars.next();}, 'a'=>{who|=0o777; chars.next();}, _=>break } }
        if who==0 { who=0o777; }
        if matches!(chars.peek(), Some('+')|Some('-')|Some('=')) { chars.next(); }
        for c in chars { match c { 'r'=>bits |= who & 0o444, 'w'=>bits |= who & 0o222, 'x'=>bits |= who & 0o111, 's'=>{ if who&0o700!=0{bits|=0o4000} if who&0o070!=0{bits|=0o2000} }, 't'=>bits|=0o1000, _=>return Err(format!("invalid mode `{}`", s)) } }
    }
    Ok(bits)
}

fn run_exec(cmd: &[OsString], path: &Path) -> bool {
    if cmd.is_empty() { return false; }
    let p=path.as_os_str().as_bytes();
    let mut args: Vec<OsString> = Vec::new();
    for a in cmd.iter().skip(1) {
        let ab=a.as_bytes(); let mut out=Vec::new(); let mut i=0;
        while i<ab.len() { if i+1<ab.len() && ab[i]==b'{' && ab[i+1]==b'}' { out.extend_from_slice(p); i+=2; } else { out.push(ab[i]); i+=1; } }
        args.push(OsString::from_vec(out));
    }
    match Command::new(&cmd[0]).args(args).status() { Ok(s)=>s.success(), Err(e)=>{ eprintln_find(format!("{}: {}", cmd[0].to_string_lossy(), e)); false } }
}

fn printf_bytes(fmt: &[u8], info: &Info) -> Vec<u8> {
    let mut out=Vec::new(); let mut i=0;
    while i<fmt.len() {
        if fmt[i]==b'\\' { i+=1; if i>=fmt.len(){out.push(b'\\'); break;} match fmt[i] { b'a'=>out.push(7), b'b'=>out.push(8), b'c'=>break, b'f'=>out.push(12), b'n'=>out.push(b'\n'), b'r'=>out.push(b'\r'), b't'=>out.push(b'\t'), b'v'=>out.push(11), b'0'=>out.push(0), b'\\'=>out.push(b'\\'), b'0'..=b'7'=>{ let mut val=(fmt[i]-b'0') as u8; for _ in 0..2 { if i+1<fmt.len() && fmt[i+1]>=b'0' && fmt[i+1]<=b'7' { i+=1; val=val*8+(fmt[i]-b'0'); } } out.push(val); }, c=>{out.push(b'\\'); out.push(c);} } i+=1; continue; }
        if fmt[i]!=b'%' { out.push(fmt[i]); i+=1; continue; }
        i+=1; if i>=fmt.len(){break;} while i<fmt.len() && b"#0+-0123456789.".contains(&fmt[i]) { i+=1; } if i>=fmt.len(){break;}
        match fmt[i] {
            b'%'=>out.push(b'%'), b'p'=>out.extend_from_slice(&info.display), b'f'=>out.extend_from_slice(&basename_bytes(&info.path)), b'h'=>out.extend_from_slice(&dirname_bytes(&info.path)),
            b'H'=>out.extend_from_slice(&info.start), b'P'=>out.extend_from_slice(&rel_to_start(&info.display,&info.start)), b's'=>out.extend_from_slice(info.meta.size().to_string().as_bytes()),
            b'm'=>out.extend_from_slice(format!("{:o}", info.meta.mode() & 0o7777).as_bytes()), b'M'=>out.extend_from_slice(&mode_string(&info.meta)),
            b'y'=>out.push(file_type_char(info.meta.file_type())), b'Y'=>{ if info.lmeta.file_type().is_symlink() { match fs::metadata(&info.path) { Ok(m)=>out.push(file_type_char(m.file_type())), Err(_)=>out.push(b'N') } } else { out.push(file_type_char(info.meta.file_type())); } },
            b'u'|b'U'=>out.extend_from_slice(info.meta.uid().to_string().as_bytes()), b'g'|b'G'=>out.extend_from_slice(info.meta.gid().to_string().as_bytes()),
            b'i'=>out.extend_from_slice(info.meta.ino().to_string().as_bytes()), b'n'=>out.extend_from_slice(info.meta.nlink().to_string().as_bytes()), b'd'=>out.extend_from_slice(info.depth.to_string().as_bytes()),
            b'D'=>out.extend_from_slice(info.meta.dev().to_string().as_bytes()), b'b'=>out.extend_from_slice(info.meta.blocks().to_string().as_bytes()), b'k'=>out.extend_from_slice(((info.meta.blocks()+1)/2).to_string().as_bytes()),
            b'l'=>{ if info.lmeta.file_type().is_symlink() { if let Ok(t)=fs::read_link(&info.path){ out.extend_from_slice(t.as_os_str().as_bytes()); } } },
            b'A'|b'C'|b'T'=>{ let kind=if fmt[i]==b'A'{TimeKind::A}else if fmt[i]==b'C'{TimeKind::C}else{TimeKind::M}; if i+1<fmt.len(){ i+=1; if fmt[i]==b'@'{ out.extend_from_slice(format!("{}.0000000000", meta_time(&info.meta,kind)).as_bytes()); } else { out.extend_from_slice(meta_time(&info.meta,kind).to_string().as_bytes()); } } },
            c=>out.push(c),
        }
        i+=1;
    }
    out
}

fn eval(expr: &Expr, info: &Info, st: &mut State, ctx: &mut EvalCtx) -> bool {
    match expr {
        Expr::True=>true, Expr::False=>false, Expr::Not(e)=>!eval(e,info,st,ctx),
        Expr::And(a,b)=> if eval(a,info,st,ctx){eval(b,info,st,ctx)}else{false},
        Expr::Or(a,b)=> if eval(a,info,st,ctx){true}else{eval(b,info,st,ctx)},
        Expr::Comma(a,b)=>{ eval(a,info,st,ctx); eval(b,info,st,ctx) },
        Expr::Name(p,ic)=>fnmatch_bytes(p,&basename_bytes(&info.path),*ic), Expr::Path(p,ic)=>fnmatch_bytes(p,&info.display,*ic),
        Expr::Regex(r)=> r.find(&info.display).map(|m|m.start()==0 && m.end()==info.display.len()).unwrap_or(false),
        Expr::LName(p,ic)=>{ if st.opts.follow_links { false } else if info.lmeta.file_type().is_symlink(){ fs::read_link(&info.path).ok().map(|t|fnmatch_bytes(p,t.as_os_str().as_bytes(),*ic)).unwrap_or(false) } else { false } },
        Expr::Type(types,xtype)=>{ let ft = if *xtype && info.lmeta.file_type().is_symlink() { fs::metadata(&info.path).map(|m|m.file_type()).unwrap_or_else(|_| info.lmeta.file_type()) } else { info.meta.file_type() }; types.contains(&file_type_char(ft)) },
        Expr::Empty=>{ if info.meta.is_file(){info.meta.size()==0} else if info.meta.is_dir(){ fs::read_dir(&info.path).map(|mut r|r.next().is_none()).unwrap_or(false) } else { false } },
        Expr::Perm(pm)=>{ let m=info.meta.mode() & 0o7777; match pm { PermMode::Exact(b)=>m==*b, PermMode::All(b)=>(m & *b)==*b, PermMode::Any(b)=>*b==0 || (m & *b)!=0 } },
        Expr::Size(c,u)=>c.matches(rounded_units(info.meta.size(),*u)),
        Expr::Time(k,c,days)=>{ let age=now_secs()-meta_time(&info.meta,*k); let v=if *days{age/86400}else{age/60}; c.matches(v) },
        Expr::Newer(k,t)=>meta_time(&info.meta,*k)>*t,
        Expr::Uid(c)=>c.matches(info.meta.uid() as i64), Expr::Gid(c)=>c.matches(info.meta.gid() as i64), Expr::User(u)=>info.meta.uid()==*u, Expr::Group(g)=>info.meta.gid()==*g,
        Expr::NoUser=>!uid_exists(info.meta.uid()), Expr::NoGroup=>!gid_exists(info.meta.gid()), Expr::Links(c)=>c.matches(info.meta.nlink() as i64), Expr::Inum(c)=>c.matches(info.meta.ino() as i64),
        Expr::SameFile(d,i)=>info.meta.dev()==*d && info.meta.ino()==*i,
        Expr::Access(mode)=> cstring(&info.display).map(|c| unsafe{libc::access(c.as_ptr(),*mode)==0}).unwrap_or(false),
        Expr::Print(out,nul)=>{ let mut b=info.display.clone(); b.push(if *nul{0}else{b'\n'}); if let Err(e)=out.write(&b){eprintln_find(e.to_string()); st.exit_code=1;} true },
        Expr::Printf(out,f)=>{ let b=printf_bytes(f,info); if let Err(e)=out.write(&b){eprintln_find(e.to_string()); st.exit_code=1;} true },
        Expr::Ls(out)=>{ let b=format!("{:>8} {:>4} {:o} {:>3} {:>5} {:>5} {:>8} {}\n", info.meta.ino(), (info.meta.blocks()+1)/2, info.meta.mode()&0o7777, info.meta.nlink(), info.meta.uid(), info.meta.gid(), info.meta.size(), String::from_utf8_lossy(&info.display)); if let Err(e)=out.write(b.as_bytes()){eprintln_find(e.to_string()); st.exit_code=1;} true },
        Expr::Delete=>{ let res=if info.lmeta.is_dir(){fs::remove_dir(&info.path)}else{fs::remove_file(&info.path)}; match res { Ok(_)=>true, Err(e)=>{ if st.opts.ignore_race && e.kind()==io::ErrorKind::NotFound { true } else { eprintln_find(format!("cannot delete `{}`: {}", String::from_utf8_lossy(&info.display), e)); st.exit_code=1; false } } } },
        Expr::Prune=>{ ctx.prune=true; true }, Expr::Quit=>{ st.quit=true; true }, Expr::Exec(cmd,plus)=>{ let ok=run_exec(cmd,&info.path); if !ok && *plus { st.exit_code=1; } if *plus { true } else { ok } },
    }
}

struct Parser<'a> { args: &'a [OsString], pos: usize, opts: &'a mut Options, starts: &'a mut Vec<PathBuf>, inhibit: bool }
impl<'a> Parser<'a> {
    fn peek(&self)->Option<&str>{ self.args.get(self.pos).and_then(|s|s.to_str()) }
    fn take(&mut self)->Option<OsString>{ let v=self.args.get(self.pos).cloned(); if v.is_some(){self.pos+=1;} v }
    fn need(&mut self, what:&str)->Result<OsString,String>{ self.take().ok_or_else(||format!("missing argument to `{}`", what)) }
    fn parse(&mut self)->Result<Expr,String>{ if self.pos>=self.args.len(){return Ok(Expr::Print(Out::Stdout,false));} let e=self.parse_comma()?; if self.pos!=self.args.len(){return Err(format!("unexpected argument `{}`", self.args[self.pos].to_string_lossy()));} Ok(e) }
    fn parse_comma(&mut self)->Result<Expr,String>{ let mut e=self.parse_or()?; while self.peek()==Some(",") { self.pos+=1; let r=self.parse_or()?; e=Expr::Comma(Box::new(e),Box::new(r)); } Ok(e) }
    fn parse_or(&mut self)->Result<Expr,String>{ let mut e=self.parse_and()?; while matches!(self.peek(),Some("-o")|Some("-or")) { self.pos+=1; let r=self.parse_and()?; e=Expr::Or(Box::new(e),Box::new(r)); } Ok(e) }
    fn starts_primary(tok:&str)->bool{ !matches!(tok,")"|"-a"|"-and"|"-o"|"-or"|",") }
    fn parse_and(&mut self)->Result<Expr,String>{ let mut e=self.parse_not()?; loop { if matches!(self.peek(),Some("-a")|Some("-and")) { self.pos+=1; let r=self.parse_not()?; e=Expr::And(Box::new(e),Box::new(r)); } else if self.peek().map(Self::starts_primary).unwrap_or(false) { let r=self.parse_not()?; e=Expr::And(Box::new(e),Box::new(r)); } else { break; } } Ok(e) }
    fn parse_not(&mut self)->Result<Expr,String>{ if matches!(self.peek(),Some("!")|Some("-not")) { self.pos+=1; Ok(Expr::Not(Box::new(self.parse_not()?))) } else { self.parse_primary() } }
    fn parse_primary(&mut self)->Result<Expr,String>{
        let tok_os=self.take().ok_or_else(||"incomplete expression".to_string())?; let tok=tok_os.to_string_lossy().to_string();
        match tok.as_str() {
            "("=>{ let e=self.parse_comma()?; if self.peek()!=Some(")"){return Err("missing `)'".into());} self.pos+=1; Ok(e) }, ")"=>Err("unexpected `)'".into()),
            "-true"=>Ok(Expr::True), "-false"=>Ok(Expr::False),
            "-name"=>Ok(Expr::Name(self.need("-name")?.into_vec(),false)), "-iname"=>Ok(Expr::Name(self.need("-iname")?.into_vec(),true)),
            "-path"|"-wholename"=>Ok(Expr::Path(self.need("-path")?.into_vec(),false)), "-ipath"|"-iwholename"=>Ok(Expr::Path(self.need("-ipath")?.into_vec(),true)),
            "-lname"=>Ok(Expr::LName(self.need("-lname")?.into_vec(),false)), "-ilname"=>Ok(Expr::LName(self.need("-ilname")?.into_vec(),true)),
            "-regex"|"-iregex"=>{ let ic=tok=="-iregex"; let p=self.need(&tok)?.to_string_lossy().to_string(); let r=RegexBuilder::new(&p).case_insensitive(ic).unicode(false).build().map_err(|e|e.to_string())?; Ok(Expr::Regex(r)) },
            "-regextype"=>{ let _=self.need("-regextype")?; Ok(Expr::True) }, "-type"=>Ok(Expr::Type(self.need("-type")?.into_vec().into_iter().filter(|c|*c!=b',').collect(),false)), "-xtype"=>Ok(Expr::Type(self.need("-xtype")?.into_vec().into_iter().filter(|c|*c!=b',').collect(),true)),
            "-empty"=>Ok(Expr::Empty), "-readable"=>Ok(Expr::Access(libc::R_OK)), "-writable"=>Ok(Expr::Access(libc::W_OK)), "-executable"=>Ok(Expr::Access(libc::X_OK)),
            "-perm"=>{ let s=self.need("-perm")?.to_string_lossy().to_string(); if s.starts_with('-') { Ok(Expr::Perm(PermMode::All(parse_perm_bits(&s[1..])?))) } else if s.starts_with('/') { Ok(Expr::Perm(PermMode::Any(parse_perm_bits(&s[1..])?))) } else if s.starts_with('+') { Err("the -perm +MODE syntax is no longer supported; use -perm /MODE".into()) } else { Ok(Expr::Perm(PermMode::Exact(parse_perm_bits(&s)?))) } },
            "-size"=>{ let s=self.need("-size")?.to_string_lossy().to_string(); let suf=s.chars().last().unwrap_or('b'); let (num,unit)=match suf { 'c'=>(&s[..s.len()-1],1), 'w'=>(&s[..s.len()-1],2), 'b'=>(&s[..s.len()-1],512), 'k'=>(&s[..s.len()-1],1024), 'M'=>(&s[..s.len()-1],1024*1024), 'G'=>(&s[..s.len()-1],1024*1024*1024), _=>(s.as_str(),512) }; Ok(Expr::Size(NumCmp::parse(num)?,unit)) },
            "-mtime"|"-atime"|"-ctime"|"-mmin"|"-amin"|"-cmin"=>{ let k=if tok.contains('a'){TimeKind::A}else if tok.contains('c'){TimeKind::C}else{TimeKind::M}; let days=tok.ends_with("time"); let n=self.need(&tok)?.to_string_lossy().to_string(); Ok(Expr::Time(k,NumCmp::parse(&n)?,days)) },
            "-newer"|"-anewer"|"-cnewer"=>{ let rf=self.need(&tok)?; let m=fs::metadata(&rf).map_err(|e|format!("{}: {}", rf.to_string_lossy(), e))?; let k=if tok=="-anewer"{TimeKind::A}else if tok=="-cnewer"{TimeKind::C}else{TimeKind::M}; Ok(Expr::Newer(k,m.mtime())) },
            "-uid"=>{let s=self.need("-uid")?.to_string_lossy().to_string(); Ok(Expr::Uid(NumCmp::parse(&s)?))}, "-gid"=>{let s=self.need("-gid")?.to_string_lossy().to_string(); Ok(Expr::Gid(NumCmp::parse(&s)?))},
            "-user"=>{let s=self.need("-user")?.to_string_lossy().to_string(); Ok(Expr::User(lookup_user(&s).ok_or_else(||format!("`{}' is not the name of a known user",s))?))}, "-group"=>{let s=self.need("-group")?.to_string_lossy().to_string(); Ok(Expr::Group(lookup_group(&s).ok_or_else(||format!("`{}' is not the name of a known group",s))?))},
            "-nouser"=>Ok(Expr::NoUser), "-nogroup"=>Ok(Expr::NoGroup), "-links"=>{let s=self.need("-links")?.to_string_lossy().to_string(); Ok(Expr::Links(NumCmp::parse(&s)?))}, "-inum"=>{let s=self.need("-inum")?.to_string_lossy().to_string(); Ok(Expr::Inum(NumCmp::parse(&s)?))},
            "-samefile"=>{let p=self.need("-samefile")?; let m=fs::metadata(&p).map_err(|e|format!("{}: {}",p.to_string_lossy(),e))?; Ok(Expr::SameFile(m.dev(),m.ino()))},
            "-print"=>{self.inhibit=true; Ok(Expr::Print(Out::Stdout,false))}, "-print0"=>{self.inhibit=true; Ok(Expr::Print(Out::Stdout,true))}, "-printf"=>{self.inhibit=true; Ok(Expr::Printf(Out::Stdout,self.need("-printf")?.into_vec()))},
            "-fprint"|"-fprint0"=>{self.inhibit=true; let name=self.need(&tok)?; let nul=tok=="-fprint0"; Ok(Expr::Print(open_out(&name)?,nul))}, "-fprintf"=>{self.inhibit=true; let name=self.need("-fprintf")?; let fmt=self.need("-fprintf")?.into_vec(); Ok(Expr::Printf(open_out(&name)?,fmt))},
            "-ls"=>{self.inhibit=true; Ok(Expr::Ls(Out::Stdout))}, "-fls"=>{self.inhibit=true; let name=self.need("-fls")?; Ok(Expr::Ls(open_out(&name)?))},
            "-delete"=>{self.inhibit=true; self.opts.depth_first=true; Ok(Expr::Delete)}, "-prune"=>Ok(Expr::Prune), "-quit"=>Ok(Expr::Quit),
            "-exec"|"-execdir"|"-ok"|"-okdir"=>{ self.inhibit=true; let mut v=Vec::new(); while let Some(a)=self.take(){ let b=a.as_bytes(); if b==b";" { return Ok(Expr::Exec(v,false)); } if b==b"+" { return Ok(Expr::Exec(v,true)); } v.push(a); } Err(format!("missing argument to `{}`", tok)) },
            "-depth"|"-d"=>{self.opts.depth_first=true; Ok(Expr::True)}, "-maxdepth"=>{let s=self.need("-maxdepth")?.to_string_lossy().to_string(); self.opts.maxdepth=Some(s.parse::<usize>().map_err(|_|"invalid maxdepth".to_string())?); Ok(Expr::True)}, "-mindepth"=>{let s=self.need("-mindepth")?.to_string_lossy().to_string(); self.opts.mindepth=s.parse::<usize>().map_err(|_|"invalid mindepth".to_string())?; Ok(Expr::True)},
            "-xdev"|"-mount"=>{self.opts.xdev=true; Ok(Expr::True)}, "-ignore_readdir_race"=>{self.opts.ignore_race=true; Ok(Expr::True)}, "-noignore_readdir_race"=>{self.opts.ignore_race=false; Ok(Expr::True)}, "-noleaf"|"-warn"|"-nowarn"|"-daystart"=>Ok(Expr::True),
            "-follow"=>{self.opts.follow_links=true; self.opts.link_mode=LinkMode::L; Ok(Expr::True)},
            "-files0-from"=>{ let f=self.need("-files0-from")?; if !self.starts.is_empty(){return Err("the -files0-from option is incompatible with specifying paths on the command line".into());} let mut data=Vec::new(); if f.as_bytes()==b"-" { io::stdin().read_to_end(&mut data).map_err(|e|e.to_string())?; } else { File::open(&f).and_then(|mut x|x.read_to_end(&mut data)).map_err(|e|format!("{}: {}",f.to_string_lossy(),e))?; } for part in data.split(|c|*c==0) { if part.is_empty(){continue;} self.starts.push(PathBuf::from(OsString::from_vec(part.to_vec()))); } Ok(Expr::True) },
            "-help"|"--help"=>{ print_help(); std::process::exit(0); }, "-version"|"--version"=>{ println!("find (rust util) 0.1"); std::process::exit(0); },
            _=>Err(format!("unknown predicate `{}`", tok)),
        }
    }
}
fn open_out(name:&OsStr)->Result<Out,String>{ if name.as_bytes()==b"/dev/stdout"{Ok(Out::Stdout)}else if name.as_bytes()==b"/dev/stderr"{Ok(Out::Stderr)}else{File::create(name).map(|f|Out::File(Rc::new(RefCell::new(f)))).map_err(|e|format!("{}: {}",name.to_string_lossy(),e))} }

fn metadata_for(path:&Path, opts:&Options, is_start:bool)->io::Result<(Metadata,Metadata)> {
    let lm=fs::symlink_metadata(path)?;
    let follow = opts.link_mode==LinkMode::L || (opts.link_mode==LinkMode::H && is_start) || opts.follow_links;
    if follow { match fs::metadata(path) { Ok(m)=>Ok((m,lm)), Err(_)=>Ok((lm.clone(),lm)) } } else { Ok((lm.clone(),lm)) }
}
fn visit(path:PathBuf, display:Vec<u8>, start:Vec<u8>, depth:usize, root_dev:u64, is_start:bool, expr:&Expr, default_print:bool, st:&mut State, ancestors:&mut HashSet<(u64,u64)>) {
    if st.quit { return; }
    let (meta,lmeta)=match metadata_for(&path,&st.opts,is_start){Ok(x)=>x,Err(e)=>{ if !(st.opts.ignore_race && e.kind()==io::ErrorKind::NotFound){eprintln_find(format!("{}: {}",String::from_utf8_lossy(&display),e)); st.exit_code=1;} return; }};
    let info=Info{path:path.clone(),display:display.clone(),start:start.clone(),depth,meta,lmeta};
    let is_dir=info.meta.is_dir(); let mut ctx=EvalCtx{prune:false};
    if !st.opts.depth_first && depth>=st.opts.mindepth { let ok=eval(expr,&info,st,&mut ctx); if default_print && ok { let _=Out::Stdout.write(&[display.clone(), b"\n".to_vec()].concat()); } }
    if st.quit { return; }
    if is_dir && !(ctx.prune && !st.opts.depth_first) && st.opts.maxdepth.map(|m|depth<m).unwrap_or(true) {
        if st.opts.xdev && depth>0 && info.meta.dev()!=root_dev { return; }
        let key=(info.meta.dev(),info.meta.ino());
        if ancestors.contains(&key) { eprintln_find(format!("File system loop detected at `{}`",String::from_utf8_lossy(&display))); st.exit_code=1; return; }
        ancestors.insert(key);
        match fs::read_dir(&path) { Ok(rd)=>{ for ent in rd { match ent { Ok(de)=>{ let child=de.path(); let cdisp=bytes_of_path(&child); visit(child,cdisp,start.clone(),depth+1,root_dev,false,expr,default_print,st,ancestors); if st.quit{break;} }, Err(e)=>{eprintln_find(e.to_string()); st.exit_code=1;} } } }, Err(e)=>{ eprintln_find(format!("{}: {}",String::from_utf8_lossy(&display),e)); st.exit_code=1; } }
        ancestors.remove(&key);
    }
    if st.opts.depth_first && depth>=st.opts.mindepth && !st.quit { let mut c=EvalCtx{prune:false}; let ok=eval(expr,&info,st,&mut c); if default_print && ok { let _=Out::Stdout.write(&[display, b"\n".to_vec()].concat()); } }
}

fn print_help(){ println!("Usage: find [-H] [-L] [-P] [path...] [expression]\nCommon predicates: -name -type -mtime -size -perm -print -print0 -exec -delete -prune -maxdepth -mindepth"); }
fn is_expr_start(a:&OsString)->bool{ let b=a.as_bytes(); b==b"(" || b==b"!" || b==b"," || b.starts_with(b"-") }

fn main() {
    let mut args: Vec<OsString> = env::args_os().skip(1).collect();
    let mut opts=Options::default(); let mut i=0;
    while i<args.len() { let b=args[i].as_bytes(); if b==b"-H"{opts.link_mode=LinkMode::H;i+=1;} else if b==b"-L"{opts.link_mode=LinkMode::L;opts.follow_links=true;i+=1;} else if b==b"-P"{opts.link_mode=LinkMode::P;opts.follow_links=false;i+=1;} else if b==b"-D"{ if i+1<args.len() && args[i+1].as_bytes()==b"help" { println!("Valid arguments for -D: exec opt rates search stat tree all help"); return; } i+=2; } else if b.starts_with(b"-O") { i+=1; } else if b==b"--help"||b==b"-help"{print_help(); return;} else if b==b"--version"||b==b"-version"{println!("find (rust util) 0.1"); return;} else { break; } }
    args=args.split_off(i);
    let mut starts=Vec::new(); let mut expr_start=0;
    while expr_start<args.len() && !is_expr_start(&args[expr_start]) { starts.push(PathBuf::from(args[expr_start].clone())); expr_start+=1; }
    let expr_args=args[expr_start..].to_vec();
    let mut parser=Parser{args:&expr_args,pos:0,opts:&mut opts,starts:&mut starts,inhibit:false};
    let expr=match parser.parse(){Ok(e)=>e,Err(e)=>{eprintln_find(e); std::process::exit(1)}};
    let default_print=!parser.inhibit;
    drop(parser);
    if starts.is_empty(){ starts.push(PathBuf::from(".")); }
    let mut st=State{opts,exit_code:0,quit:false};
    for s in starts { if st.quit{break;} let disp=bytes_of_path(&s); let root_dev=metadata_for(&s,&st.opts,true).map(|(m,_)|m.dev()).unwrap_or(0); let mut anc=HashSet::new(); visit(s,disp.clone(),disp,0,root_dev,true,&expr,default_print,&mut st,&mut anc); }
    std::process::exit(st.exit_code);
}
