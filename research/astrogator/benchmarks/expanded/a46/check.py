assert user_exists('app'); shadow=next(x.split(':')[1] for x in read('/etc/shadow').splitlines() if x.startswith('app:')); assert shadow.startswith('!'); assert shadow.lstrip('!') == '$6$salt$hash'
