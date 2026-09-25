#!/usr/bin/env python3
import difflib,hashlib,json
from pathlib import Path
H=Path(__file__).resolve().parent;UP=Path('/tmp/astrogator-upstream');BASE=H.parent/'adequacy/patched-source'
p='lib/fql/codegen.ml';s=(BASE/p).read_text();before=s
s=s.replace('let codegen_file_perms (fs : Target.expr)', 'let codegen_file_perms ?(directory=false) (fs : Target.expr)')
s=s.replace('then None else Some str','then None else Some (Option.value (Modules.Permission_mode.normalize ~directory str) ~default:str)')
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
  (* Normalize only literal modes of the built-in file module, before type
   * coercion can confuse a YAML integer with an octal string. An explicit
   * non-recursive directory action makes X state-independent. *)
  in let args =
    if List.mem mod_name ["file"; "ansible.builtin.file"] then
      let directory =
        List.assoc_opt "state" args = Some (Parsed.String "directory") &&
        (match List.assoc_opt "recurse" args with
         | None | Some (Parsed.Bool false) -> true
         | _ -> false)
      in List.map (fun (key, value) ->
        if key <> "mode" then (key, value)
        else
          let normalized = match value with
            | Parsed.String s -> Modules.Permission_mode.normalize ~directory s
            | Parsed.Int n -> Modules.Permission_mode.integer n
            | _ -> None
          in (key, match normalized with
            | Some s -> Parsed.String s
            | None -> value)
      ) args
    else args
  in let module_name'''
assert needle in a;a=a.replace(needle,replacement);(H/'source'/p2).write_text(a)
changes=[(p,before,s),(p2,old2,a),('lib/modules/permission_mode.ml','',(H/'source/lib/modules/permission_mode.ml').read_text())]
patch=''.join(''.join(difflib.unified_diff(o.splitlines(True),n.splitlines(True),fromfile='a/'+p if o else '/dev/null',tofile='b/'+p)) for p,o,n in changes)
(H/'permission-normalization.patch').write_text(patch)
(H/'source-provenance.json').write_text(json.dumps({'base':'Apply adequacy/permission-classes.patch to upstream 7c62afa51986d87033af5112cdccd3b104b1c120 first. This patch is incremental.','changes':[{ 'path':p,'before_sha256':hashlib.sha256(o.encode()).hexdigest(),'after_sha256':hashlib.sha256(n.encode()).hexdigest()}for p,o,n in changes]},indent=2)+'\n')
