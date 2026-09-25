#!/usr/bin/env python3
import difflib,hashlib,json
from pathlib import Path
H=Path(__file__).resolve().parent;UP=Path('/tmp/astrogator-upstream');BASE=H.parent/'adequacy/patched-source'
p='lib/fql/codegen.ml';s=(BASE/p).read_text();before=s
s=s.replace('let codegen_file_perms (fs : Target.expr)', 'let codegen_file_perms ?(directory=false) (fs : Target.expr)')
s=s.replace('then None else Some str','then None else Some (if !Modules.Permission_mode.enabled then Option.value (Modules.Permission_mode.normalize ~directory str) ~default:str else str)')
s=s.replace('let codegen_file_info (fs : Target.expr)', 'let codegen_file_info ?(directory=false) (fs : Target.expr)')
s=s.replace('let config_mode = codegen_file_perms fs perms','let config_mode = codegen_file_perms ~directory fs perms')
s=s.replace('let codegen_file_desc (fs : Target.expr)', 'let codegen_file_desc ?(directory=false) (fs : Target.expr)')
s=s.replace('in codegen_file_info fs owner group perms env','in codegen_file_info ~directory fs owner group perms env',1)
old='''  | CreateDir { dest } ->
      let^ (path, sys, env) = codegen_path dest.path env
      in let^ (config, env) = codegen_file_desc (fs (Id "^dst") sys) dest env'''
new=old.replace('codegen_file_desc (','codegen_file_desc ~directory:true (')
assert old in s;s=s.replace(old,new);(H/'source'/p).write_text(s)
p2='lib/ansible/semant.ml';a=(UP/p2).read_text();old2=a
needle='''  let { Parsed.mod_info = mod_name; args } = m
  in let module_name'''
replacement='''  let { Parsed.mod_info = mod_name; args } = m
  (* The current model stores modes as values, not state transformers. Restrict
   * it to literal state-independent assignments; do not silently verify
   * relative chmod operations by equality of their source strings. *)
  in let^ args =
    let mode_modules = ["file"; "copy"; "get_url"; "uri"; "lineinfile"; "blockinfile"] in
    let eligible = List.exists (fun name ->
      mod_name = name || mod_name = "ansible.builtin." ^ name) mode_modules in
    if !Modules.Permission_mode.enabled && eligible then
      let directory = List.mem mod_name ["file"; "ansible.builtin.file"] &&
        List.assoc_opt "state" args = Some (Parsed.String "directory") &&
        (match List.assoc_opt "recurse" args with
         | None | Some (Parsed.Bool false) -> true
         | _ -> false)
      in map_res (fun (key, value) ->
        let directory_mode = key = "directory_mode" &&
          List.mem mod_name ["copy"; "ansible.builtin.copy"] in
        if key <> "mode" && not directory_mode then Ok (key, value)
        else
          let normalized = match value with
            | Parsed.String s -> Modules.Permission_mode.normalize
                ~directory:(directory || directory_mode) s
            | _ -> None
          in match normalized with
            | Some s -> Ok (key, Parsed.String s)
            | None -> Error ("Unsupported permission mode: the current model requires a quoted constant octal mode or complete u=/g=/o= assignments; X requires an explicit nonrecursive directory")
      ) args
    else Ok args
  in let module_name'''
assert needle in a;a=a.replace(needle,replacement);(H/'source'/p2).write_text(a)
p3='bin/verify.ml';v=(UP/p3).read_text();old3=v
v=v.replace('  [("--", Arg.Rest_all', '  [("--constant-modes", Arg.Set Modules.Permission_mode.enabled, "Opt in to constant permission-mode normalization; unsupported state-dependent modes fail lowering");\n   ("--", Arg.Rest_all')
(H/'source/bin').mkdir(exist_ok=True)
(H/'source'/p3).write_text(v)
changes=[(p,before,s),(p2,old2,a),(p3,old3,v),('lib/modules/permission_mode.ml','',(H/'source/lib/modules/permission_mode.ml').read_text())]
patch=''.join(''.join(difflib.unified_diff(o.splitlines(True),n.splitlines(True),fromfile='a/'+p if o else '/dev/null',tofile='b/'+p)) for p,o,n in changes)
(H/'permission-normalization.patch').write_text(patch)
(H/'source-provenance.json').write_text(json.dumps({'base':'Apply adequacy/permission-classes.patch to upstream 7c62afa51986d87033af5112cdccd3b104b1c120 first. This patch is incremental.','changes':[{ 'path':p,'before_sha256':hashlib.sha256(o.encode()).hexdigest(),'after_sha256':hashlib.sha256(n.encode()).hexdigest()}for p,o,n in changes]},indent=2)+'\n')
# Add independently executable normalizer regression tests alongside the base patch.
tp='test/dune';td=(BASE/tp).read_text();tn=td+'\n(test\n (name mode_regression)\n (modules mode_regression)\n (libraries modules))\n'
(H/'source/test').mkdir(exist_ok=True)
(H/'source/test/dune').write_text(tn)
mt=(H/'mode_regression.ml').read_text();(H/'source/test/mode_regression.ml').write_text(mt)
with (H/'permission-normalization.patch').open('a')as f:
 f.write(''.join(difflib.unified_diff(td.splitlines(True),tn.splitlines(True),fromfile='a/test/dune',tofile='b/test/dune')))
 f.write(''.join(difflib.unified_diff([],mt.splitlines(True),fromfile='/dev/null',tofile='b/test/mode_regression.ml')))
