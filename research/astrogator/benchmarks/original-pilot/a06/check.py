assert read('/etc/file.txt') == ('existing content' if adversarial else 'beginning')
