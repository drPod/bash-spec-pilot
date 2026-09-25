assert P('/work/private').is_dir(); assert mode('/work/private') == 0o700
if adversarial: assert read('/work/private/keep') == 'keep'
