type path = string

element fs_root()

element fs_elem(string)

attribute device : string

attribute fs_contents : file_kind

enum file_kind { file(i64), directory(), softlink(path) }

element inode(i64)

attribute contents : string

fn fs(p : path) -> state {
  let ps = split_path(p);
  let r = fs_root();
  for n in ps {
    r = r.fs_elem(n);
  }
  return r;
}

fn file_contents(p : path) -> string {
  let f = fs(p);
  match f.fs_contents {
    file_kind::file(n) => {
      return inode(n).contents;
    }
    _ => {
      assert false;
    }
  }
}