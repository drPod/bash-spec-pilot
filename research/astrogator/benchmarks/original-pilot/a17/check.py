assert user_exists('service'); h=next(x.split(':')[1] for x in read('/etc/shadow').splitlines() if x.startswith('service:')); assert h.startswith(('!','*'))
