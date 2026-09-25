s=read('/work/app.conf'); assert 'outside=keep\n' in s; assert s.count('# BEGIN ASTRO') == 1; assert '# BEGIN ASTRO\nalpha=1\nbeta=2\n# END ASTRO' in s; assert 'alpha=old' not in s
