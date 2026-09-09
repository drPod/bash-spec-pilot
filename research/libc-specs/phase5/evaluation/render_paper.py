#!/usr/bin/env python3
"""Render the working manuscript to a self-contained, printable HTML document."""
from pathlib import Path
from markdown_it import MarkdownIt

root = Path(__file__).resolve().parent
source = root / "DRAFT-PAPER.md"
body = MarkdownIt("commonmark").enable("table").render(source.read_text())
style = """
:root { color-scheme: light; }
body { margin: 3rem auto; max-width: 49rem; padding: 0 1.5rem; color: #17212b;
       background: white; font: 17px/1.65 Georgia, 'Times New Roman', serif; }
h1,h2,h3 { font-family: system-ui, sans-serif; line-height: 1.25; color: #102f49; }
h1 { font-size: 2rem; margin-bottom: 1.4rem; }
h2 { font-size: 1.35rem; margin-top: 2.5rem; border-top: 1px solid #d8e0e5; padding-top: 1rem; }
h3 { font-size: 1.05rem; margin-top: 1.8rem; }
a { color: #075886; text-underline-offset: 0.16em; }
code { font-size: 0.85em; overflow-wrap: anywhere; }
table { width: 100%; border-collapse: collapse; font: 0.87em/1.45 system-ui, sans-serif; margin: 1.5rem 0; }
th,td { padding: 0.6rem 0.7rem; border-bottom: 1px solid #d8e0e5; text-align: left; vertical-align: top; }
th { background: #f0f5f8; }
footer { margin-top: 3rem; border-top: 1px solid #d8e0e5; padding-top: 1rem;
         font: 0.8rem/1.5 system-ui, sans-serif; color: #4c5d68; }
@media print { body { margin: 0; max-width: none; font-size: 10pt; }
  h2,h3 { break-after: avoid; } tr { break-inside: avoid; } a { color: inherit; }
  @page { margin: 20mm 18mm; } }
"""
document = '<!doctype html>\n<html lang="en"><head><meta charset="utf-8">'
document += '<meta name="viewport" content="width=device-width,initial-scale=1">'
document += '<title>Using C Utility Implementations to Verify Shell Scripts</title>'
document += '<style>' + style + '</style></head><body><main>' + body + '</main>'
document += '<footer>Working research manuscript. Generated from <a href="DRAFT-PAPER.md">DRAFT-PAPER.md</a>. '
document += 'See the linked requirements and checker receipts for current acceptance boundaries.</footer></body></html>\n'
(root / "paper.html").write_text(document)
print(root / "paper.html")
