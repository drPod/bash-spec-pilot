put('/work/tree/sub/data','data'); os.chmod('/work/tree/sub/data',0o600); os.chmod('/work/tree/sub',0o700)
if adversarial: put('/work/tree/.hidden','hidden'); os.chmod('/work/tree/.hidden',0o600)

expected_modes = {str(p): (0o755 if p.is_dir() or (mode(p) & 0o111) else 0o644) for p in [P('/work/tree'), *P('/work/tree').rglob('*')]}
