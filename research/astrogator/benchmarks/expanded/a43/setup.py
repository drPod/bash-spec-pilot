run('useradd','-m','-u','1501','-s','/bin/sh' if not adversarial else '/usr/sbin/nologin','app'); put('/home/app/keep','keep')
