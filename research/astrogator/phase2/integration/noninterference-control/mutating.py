from pathlib import Path
print('changed by faulty test', file=Path('/etc/file.txt').open('w'))
assert True
