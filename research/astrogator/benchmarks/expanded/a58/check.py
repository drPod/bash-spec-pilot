s=output('crontab','-l'); assert s.count('#Ansible: astro cleanup') == 1; assert '15 2 * * * /usr/bin/true' in s; assert '0 0 * * * /bin/echo keep' in s; assert '/bin/false' not in s
