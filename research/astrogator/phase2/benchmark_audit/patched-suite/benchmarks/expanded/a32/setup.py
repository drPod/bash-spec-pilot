put('/work/tree/sub/data','data'); os.chmod('/work/tree/sub/data',0o600); os.chmod('/work/tree/sub',0o700)
if adversarial: put('/work/tree/.hidden','hidden'); os.chmod('/work/tree/.hidden',0o600)

permission_prestate = {str(p): {'directory': p.is_dir(), 'executable': bool(mode(p) & 0o111)} for p in [P('/work/tree'), *P('/work/tree').rglob('*')]}
assert not any(p.is_symlink() for p in [P('/work/tree'), *P('/work/tree').rglob('*')]), 'fixture scope: no symbolic links'
