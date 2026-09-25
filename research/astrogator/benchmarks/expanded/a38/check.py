s=read('/work/rules').splitlines(); assert s.count('allow local') == 1; assert s.index('allow local') < s.index('deny all'); assert 'allow admin' in s
