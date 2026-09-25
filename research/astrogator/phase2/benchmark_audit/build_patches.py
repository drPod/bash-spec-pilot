"""Regenerate current v3 oracle proposal; historical versions are archived."""
import pathlib,runpy
runpy.run_path(str(pathlib.Path(__file__).with_name("build_patches_v3.py")),run_name="__main__")
