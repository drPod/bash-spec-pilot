assert read('/work/dest/.hidden') == 'hidden'; assert read('/work/dest/nested/data') == 'data'; assert read('/work/source/nested/data') == 'data'; assert not P('/work/dest/source').exists()
if adversarial: assert read('/work/dest/keep') == 'keep'
