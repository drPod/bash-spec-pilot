#!/usr/bin/env python3
"""Strip nav chrome from an Open Group POSIX HTML page (stdin -> stdout).

The onlinepubs pages wrap real content in two `<div class="NAVHEADER">` blocks
(top + bottom Prev/Home/Next) and pull in a `codes.js` script. Remove those so
pandoc renders only the spec text. Everything else (mansect headings,
blockquotes, the edition banner, CHANGE HISTORY boxes) is kept verbatim.
"""
import re
import sys

html = sys.stdin.read()
html = re.sub(r'<div class="NAVHEADER">.*?</div>', "", html, flags=re.DOTALL | re.IGNORECASE)
html = re.sub(r"<script\b[^>]*>.*?</script>", "", html, flags=re.DOTALL | re.IGNORECASE)
html = re.sub(r"<basefont\b[^>]*>", "", html, flags=re.IGNORECASE)
sys.stdout.write(html)
