import pwd
from pathlib import Path

pwd.getpwnam("service")

entries = [
    line.split(":")
    for line in Path("/etc/shadow").read_text().splitlines()
    if line.split(":", 1)[0] == "service"
]

assert len(entries) == 1, "Expected a shadow entry for service"
assert entries[0][1].startswith(("!", "*")), (
    "Password authentication for service is not disabled"
)
