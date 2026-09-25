u=pwd.getpwnam('app'); assert u.pw_shell == '/bin/bash'; assert u.pw_uid == 1501; assert read('/home/app/keep') == 'keep'
