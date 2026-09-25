s=read('/work/profile').splitlines(); assert s[-1] == 'export ASTRO=1'; assert s.count('export ASTRO=1') == 1; assert '# keep' in s and 'export KEEP=1' in s
