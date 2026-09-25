run('groupadd','primary'); run('groupadd','deploy'); run('groupadd','audit')
if adversarial: run('useradd','-m','-g','primary','-G','deploy','app')
