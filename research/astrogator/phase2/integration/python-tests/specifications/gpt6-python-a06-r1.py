import os
from pathlib import Path

scenario = os.environ["ASTRO_SCENARIO"]
assert scenario in ("baseline", "adversarial"), "Unknown scenario"

path = Path("/etc/file.txt")
assert path.is_file(), "/etc/file.txt must exist as a file"

expected = b"beginning" if scenario == "baseline" else b"existing content"
assert path.read_bytes() == expected, "Unexpected file contents"
