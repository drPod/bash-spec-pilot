from pathlib import Path
import difflib,hashlib,json
H=Path(__file__).resolve().parent;U=Path('/tmp/astrogator-upstream');rel='lib/fql/semant.ml';old=(U/rel).read_text();start=old.index('    | Delete vs ->');end=old.index('        | Str "files" ->',start);section=old[start:end]
for kind in ['file','directory']:
 needle='| Some p -> analyze_path p\n              | None -> K.'+('fileDef'if kind=='file'else'dirDef')+' ctx rest args'
 replacement='''| Some p ->
                  if List.is_empty rest then analyze_path p
                  else Error (Printf.sprintf
                    "For delete, explicit 'at' cannot discard %s description: %%s"
                    (ParseTree.unparse_vals rest))
              | None -> K.%s ctx rest args'''%(kind,'fileDef'if kind=='file'else'dirDef')
 assert section.count(needle)==1;section=section.replace(needle,replacement)
new=old[:start]+section+old[end:];(H/'source'/rel).write_text(new)
patch=''.join(difflib.unified_diff(old.splitlines(True),new.splitlines(True),fromfile='a/'+rel,tofile='b/'+rel))
for rel in ['test/dune','test/description_regression.ml']:
 old=(U/rel).read_text()if(U/rel).exists()else'';new=(H/'source'/rel).read_text();patch+=''.join(difflib.unified_diff(old.splitlines(True),new.splitlines(True),fromfile='a/'+rel if old else'/dev/null',tofile='b/'+rel))
(H/'description-guard.patch').write_text(patch)
(H/'source-provenance.json').write_text(json.dumps({'upstream_commit':'7c62afa51986d87033af5112cdccd3b104b1c120','original_semant_sha256':hashlib.sha256((U/'lib/fql/semant.ml').read_bytes()).hexdigest(),'patched_semant_sha256':hashlib.sha256((H/'source/lib/fql/semant.ml').read_bytes()).hexdigest()},indent=2)+'\n')
