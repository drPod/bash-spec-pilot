put('/work/source/.hidden','hidden'); put('/work/source/nested/data','data'); P('/work/dest').mkdir()
if adversarial: put('/work/dest/keep','keep')

expected_source_files = {str(p.relative_to('/work/source')): p.read_bytes() for p in P('/work/source').rglob('*') if p.is_file()}
expected_dest_files = {str(p): p.read_bytes() for p in P('/work/dest').rglob('*') if p.is_file()}
