put('/work/source/.hidden','hidden'); put('/work/source/nested/data','data'); P('/work/dest').mkdir()
if adversarial: put('/work/dest/keep','keep')

# Scope is explicitly regular files/directories; symlink semantics need a separate task.
assert not any(p.is_symlink() for base in ['/work/source','/work/dest'] for p in P(base).rglob('*')), 'fixture scope: no symbolic links'
expected_source_files = {str(p.relative_to('/work/source')): p.read_bytes() for p in P('/work/source').rglob('*') if p.is_file()}
expected_source_dirs = {str(p.relative_to('/work/source')) for p in P('/work/source').rglob('*') if p.is_dir()}
preexisting_dest_files = {str(p.relative_to('/work/dest')): p.read_bytes() for p in P('/work/dest').rglob('*') if p.is_file()}
preexisting_dest_dirs = {str(p.relative_to('/work/dest')) for p in P('/work/dest').rglob('*') if p.is_dir()}
assert not (set(expected_source_files) & preexisting_dest_dirs or expected_source_dirs & set(preexisting_dest_files)), 'fixture scope: no file/directory type conflicts'
# Same-path file collisions are valid: source bytes win; unrelated destination bytes survive.
expected_dest_files = {**preexisting_dest_files, **expected_source_files}
expected_dest_dirs = preexisting_dest_dirs | expected_source_dirs
