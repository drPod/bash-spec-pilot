assert list(P('/etc/rc2.d').glob('S*cron')); assert subprocess.run(['pgrep','-x','cron'],capture_output=True).returncode != 0
