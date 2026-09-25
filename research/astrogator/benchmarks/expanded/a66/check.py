s=read('/work/header').splitlines(); assert s[0] == '# managed'; assert s.count('# managed') == 1; assert s[1:] == ['body one','body two']
