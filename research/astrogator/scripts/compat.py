"""Build-only OCaml 5.3 shim for three upstream OCaml 5.5 String APIs."""
from pathlib import Path
p=Path('/opt/astrogator/lib/modules/target.ml')
s=p.read_text()
if s.startswith(('module String = struct\n','module Compat_string = struct\n')):
    s=s.split('end\n\n',1)[1]
shim='''module Compat_string = struct
  include Stdlib.String
  let includes ~affix text =
    let n = length affix and m = length text in
    let rec scan i = i + n <= m && (sub text i n = affix || scan (i + 1)) in
    scan 0
  let find_first ~sub:needle ?(start=0) text =
    let n = length needle and m = length text in
    if start < 0 || start > m then invalid_arg "String.find_first";
    let rec scan i =
      if i + n > m then None
      else if sub text i n = needle then Some i else scan (i + 1) in
    scan start
  let replace_all ~sub:needle ~by ?(start=0) text =
    let n = length needle and m = length text in
    if start < 0 || start > m then invalid_arg "String.replace_all";
    let b = Buffer.create m in
    Buffer.add_substring b text 0 start;
    let rec scan i =
      if n = 0 then (
        Buffer.add_string b by;
        if i < m then (Buffer.add_char b text.[i]; scan (i+1)))
      else if i + n <= m && sub text i n = needle then
        (Buffer.add_string b by; scan (i+n))
      else if i < m then (Buffer.add_char b text.[i]; scan (i+1)) in
    scan start; Buffer.contents b
end

'''
for name in ['includes','find_first','replace_all']:
    s=s.replace('String.'+name,'Compat_string.'+name)
p.write_text(shim+s)
