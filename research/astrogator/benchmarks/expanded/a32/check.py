assert mode('/work/tree/sub') == 0o755; assert mode('/work/tree/sub/data') == 0o644
if adversarial: assert mode('/work/tree/.hidden') == 0o644
