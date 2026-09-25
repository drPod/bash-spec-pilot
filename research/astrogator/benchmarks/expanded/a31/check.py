assert not P('/work/cache/a.tmp').exists(); assert read('/work/cache/keep.txt') == 'keep'; assert read('/work/cache/sub/nested.tmp') == 'keep'
if adversarial: assert not P('/work/cache/.hidden.tmp').exists(); assert P('/work/cache/dir.tmp').is_dir()
