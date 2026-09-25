run('useradd','-m','app'); put('/home/app/keep','keep'); os.chmod('/home/app',0o755)
if adversarial: os.chown('/home/app',0,0)
