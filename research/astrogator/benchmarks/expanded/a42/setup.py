run('groupadd','deploy'); run('useradd','-m','app'); put('/home/app/keep','keep')
if adversarial: run('usermod','-g','deploy','app')
