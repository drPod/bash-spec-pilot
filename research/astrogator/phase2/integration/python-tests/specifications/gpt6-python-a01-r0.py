import os
import stat
from pathlib import Path

directory = Path("/srv/www")
assert stat.S_ISDIR(directory.lstat().st_mode), "/srv/www must be a directory"

if os.environ.get("ASTRO_SCENARIO", "baseline") == "adversarial":
    keep = directory / "keep"
    assert keep.is_file(), "/srv/www/keep must be preserved"
