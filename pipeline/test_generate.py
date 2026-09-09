import os
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from generate import load_env


class EnvironmentTests(unittest.TestCase):
    def test_repo_env_parsing_and_environment_precedence(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / ".env").write_text(
                'export OPENAI_API_KEY="test-key" # local credential\n'
                'OPENAI_REASONING_EFFORT=low\n'
                'OPENAI_MAX_RETRIES=2 # local default\n'
            )
            with patch("generate.REPO", root), patch.dict(
                os.environ, {"OPENAI_REASONING_EFFORT": "high"}, clear=True
            ):
                load_env()
                self.assertEqual(os.environ["OPENAI_API_KEY"], "test-key")
                self.assertEqual(os.environ["OPENAI_REASONING_EFFORT"], "high")
                self.assertEqual(os.environ["OPENAI_MAX_RETRIES"], "2")

    def test_missing_repo_env_is_optional(self):
        with tempfile.TemporaryDirectory() as directory:
            with patch("generate.REPO", Path(directory)), patch.dict(os.environ, {}, clear=True):
                load_env()
                self.assertEqual(dict(os.environ), {})


if __name__ == "__main__":
    unittest.main()
