import subprocess
import os

def run_playbook(task_vars):
    # Define the playbook and task variables
    playbook_path = '/path/to/your/playbook.yml'
    task_vars['version'] = '2.0'
    task_vars['upgradable'] = True
    task_vars['upgrade'] = 'yes'
    task_vars['source'] = '/fixtures/astro-demo_2.0_all.deb'

    # Run the playbook and capture the output
    output = subprocess.run(['ansible-playbook', '-i', 'localhost', '--connection', 'local', '--extra-vars', ','.join(task_vars.keys()) + '=' + ','.join(task_vars.values()), playbook_path], capture_output=True, text=True, check=True)

    # Check if the playbook ran successfully
    if output.returncode != 0:
        print("Playbook failed: ", output.stderr)
        return 1

    # Check the state of astro-demo
    result = output.stdout.splitlines()
    for line in result:
        if 'installed' in line:
            installed_version = line.split(' ')[1]
            if installed_version != task_vars['version']:
                print("Installed version is not as expected. Expected:", task_vars['version'], "Found:", installed_version)
                return 1

    return 0

# Test the function with baseline initial state
baseline_version = '2.0'
baseline_output = run_playbook({'version': baseline_version})
assert baseline_output == 0, "Baseline initial state failed"

# Test the function with adversarial initial state
adversarial_version = '1.0'
adversarial_output = run_playbook({'version': adversarial_version})
assert adversarial_output == 0, "Adversarial initial state failed"

print("All tests passed!")
