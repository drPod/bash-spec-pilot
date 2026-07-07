#!/usr/bin/env bash
# Probe sudo -D / --chdir policy gating in trixie, non-root tester.
# Three conditions: (a) default sudoers, (b) Defaults runcwd=*, (c) long form.
set -uo pipefail

apt-get update -qq >/dev/null 2>&1
apt-get install -y -qq sudo coreutils >/dev/null 2>&1

echo "=== sudo version ==="
sudo --version | head -1

useradd -m -s /bin/bash tester
echo 'tester ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/tester
chmod 0440 /etc/sudoers.d/tester

probe() { su - tester -c 'sudo -n -D /tmp pwd; echo "  rc=$?"' 2>&1; }
probe_long() { su - tester -c 'sudo -n --chdir=/tmp pwd; echo "  rc=$?"' 2>&1; }

echo "=== (a) default sudoers (no runcwd), non-root tester: sudo -n -D /tmp pwd ==="
probe

echo "=== now grant: Defaults runcwd=* ==="
echo 'Defaults runcwd=*' > /etc/sudoers.d/runcwd
chmod 0440 /etc/sudoers.d/runcwd

echo "=== (b) with runcwd=*, non-root tester: sudo -n -D /tmp pwd ==="
probe

echo "=== (c) with runcwd=*, long form: sudo -n --chdir=/tmp pwd ==="
probe_long

echo "=== (d) as root (the run_tests.py confound condition): sudo -n -D /tmp pwd ==="
rm -f /etc/sudoers.d/runcwd
sudo -n -D /tmp pwd; echo "  rc=$?"
