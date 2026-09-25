import os
from pathlib import Path

scenario = os.environ.get("ASTRO_SCENARIO", "baseline")
assert scenario in ("baseline", "adversarial"), "Unknown ASTRO_SCENARIO"

path = Path("/etc/file.txt")
assert path.is_file(), "/etc/file.txt must exist as a file"

expected = b"beginning" if scenario == "baseline" else b"existing content"
assert path.read_bytes() == expected, "Unexpected file contents"
