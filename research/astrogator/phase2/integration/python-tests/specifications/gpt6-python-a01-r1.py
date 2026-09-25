import os
from pathlib import Path

directory = Path("/srv/www")
assert directory.is_dir(), "/srv/www must exist as a directory"

if os.environ.get("ASTRO_SCENARIO", "baseline") == "adversarial":
    assert (directory / "keep").is_file(), "/srv/www/keep must be preserved"
