#!/usr/bin/env python3
"""Create tiny real dpkg packages without repository/network dependencies."""
from pathlib import Path
import subprocess

for name,version in [('astro-demo','1.0'),('astro-demo','2.0'),('astro-keep','1.0')]:
    d=Path('/tmp')/f'{name}-{version}'
    (d/'DEBIAN').mkdir(parents=True,exist_ok=True)
    (d/'DEBIAN/control').write_text(f'Package: {name}\nVersion: {version}\nArchitecture: all\nMaintainer: Fixture <fixture@example.invalid>\nDescription: Offline benchmark fixture\n')
    p=d/'usr/share'/name; p.mkdir(parents=True,exist_ok=True); (p/'version').write_text(version)
    Path('/fixtures').mkdir(exist_ok=True)
    subprocess.run(['dpkg-deb','--build',str(d),f'/fixtures/{name}_{version}_all.deb'],check=True)
