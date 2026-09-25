from pathlib import Path
assert Path('/etc/file.txt').read_text() == 'beginning'
