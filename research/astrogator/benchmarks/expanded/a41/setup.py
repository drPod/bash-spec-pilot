run('groupadd','deploy'); run('groupadd','audit'); run('useradd','-m','app')
if adversarial: run('usermod','-aG','audit','app')
