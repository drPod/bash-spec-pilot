import os
import sys

def check_requirements(astro_scenario=None):
    # Check initial state: baseline
    baseline_file = "/work/app.conf"
    baseline_content = ""
    
    with open(baseline_file, "r", newline=None) as file:
        baseline_content = file.read().splitlines()
    
    expected_baseline_content = [
        "port=8080",
        "# keep newline mode=safe newline",
    ]
    
    for i, line in enumerate(expected_baseline_content):
        assert line in baseline_content, f"Port 8080 not found in baseline file."
        baseline_content.pop(i)
    
    # Check initial state: adversarial
    adversarial_file = "/work/app.conf"
    adversarial_content = ""
    
    with open(adversarial_file, "r", newline=None) as file:
        adversarial_content = file.read().splitlines()
    
    expected_adversarial_content = [
        "port=9090",
        "# keep newline mode=safe newline",
    ]
    
    for i, line in enumerate(expected_adversarial_content):
        assert line in adversarial_content, f"Port 9090 not found in adversarial file."
        adversarial_content.pop(i)
    
    # No additional checks needed for the given scenario
    
    # Exit 0 if all checks pass
    sys.exit(0)

# Run the test with the given scenario
check_requirements(astro_scenario=0)
