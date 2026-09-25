import os
import subprocess

def is_cron_running():
    try:
        subprocess.check_output(['cron', '--version'])
    except subprocess.CalledProcessError:
        return False
    return True

def main():
    try:
        if is_cron_running():
            print("Cron service is already running.")
        else:
            print("Cron service is stopped. Attempting to start it.")
            # Execute the playbook to ensure cron is started
            result = subprocess.run(['ansible-playbook', '--connection=local', '--extra-vars="scenario=baseline"', 'path/to/playbook.yml'], check=True)
            if result.returncode == 0:
                print("Cron service was successfully started.")
            else:
                print("Failed to start cron service. Please check the playbook execution.")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    main()
