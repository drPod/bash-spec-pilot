from pathlib import Path
import pwd

pwd.getpwnam("service")

entries = [
    line.split(":")
    for line in Path("/etc/shadow").read_text().splitlines()
    if line.split(":", 1)[0] == "service"
]
assert len(entries) == 1, "Expected one shadow entry for service"
assert len(entries[0]) >= 2, "Malformed service shadow entry"
assert entries[0][1].startswith(("!", "*")), (
    "Password authentication for service is not disabled"
)
