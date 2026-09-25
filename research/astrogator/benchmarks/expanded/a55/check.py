assert subprocess.run(['pgrep','-x','cron'],capture_output=True).returncode == 0
