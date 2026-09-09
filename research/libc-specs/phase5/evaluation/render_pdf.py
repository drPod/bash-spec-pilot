#!/usr/bin/env python3
"""Render the manuscript as a printable PDF.

Dependencies: weasyprint==70.0, markdown-it-py==4.2.0.
Usage: python render_pdf.py
"""
from pathlib import Path
from html import escape
from markdown_it import MarkdownIt
from weasyprint import HTML

ROOT = Path(__file__).resolve().parent
REPO = ROOT.parents[3]
source = (ROOT / 'DRAFT-PAPER.md').read_text()
md = MarkdownIt('commonmark').enable('table')
tokens = md.parse(source)
# PDF readers need web links rather than this machine's local filesystem paths.
for token in tokens:
    for child in token.children or []:
        if child.type == 'link_open':
            href = child.attrGet('href') or ''
            if href and '://' not in href and not href.startswith('#'):
                target = (ROOT / href).resolve().relative_to(REPO)
                child.attrSet('href', 'https://github.com/drPod/bash-spec-pilot/blob/main/' + target.as_posix())
body = md.renderer.render(tokens, md.options, {})
css = '''
@page {
  size: A4; margin: 19mm 19mm 20mm;
  @bottom-left { content: "C utility implementations and shell verification";
    font-family: sans-serif; font-size: 8pt; color: #68737d; }
  @bottom-right { content: counter(page); font-family: sans-serif; font-size: 8pt; color: #68737d; }
}
body { font-family: "DejaVu Serif", serif; font-size: 10pt; line-height: 1.48; color: #202b33; }
h1,h2,h3 { font-family: "DejaVu Sans", sans-serif; color: #163d53; line-height: 1.22; break-after: avoid; }
h1 { font-size: 23pt; margin: 5mm 0 5mm; letter-spacing: -.5pt; }
h2 { font-size: 14pt; margin: 7mm 0 3mm; }
h3 { font-size: 11pt; margin: 5mm 0 2mm; }
p { margin: 0 0 3mm; orphans: 3; widows: 3; }
h1 + p { font-family: sans-serif; font-size: 10pt; color: #657681; margin-bottom: 7mm; }
a { color: #185b7c; text-decoration: none; }
blockquote { margin: 4mm 0; padding: 2mm 4mm; border-left: 2pt solid #467b91; background: #f1f5f7; }
blockquote p { margin: 0; }
pre { font-family: "DejaVu Sans Mono", monospace; font-size: 8pt; line-height: 1.5;
  background: #f1f5f7; padding: 3mm; white-space: pre-wrap; break-inside: avoid; }
code { font-family: "DejaVu Sans Mono", monospace; font-size: .85em; }
table { width: 100%; border-collapse: collapse; font-family: "DejaVu Sans", sans-serif; font-size: 8pt; line-height: 1.4; margin: 4mm 0; }
th { text-align: left; color: #163d53; background: #eaf0f3; }
th,td { padding: 2mm; border-bottom: .5pt solid #cbd5db; vertical-align: top; overflow-wrap: anywhere; }
tr { break-inside: avoid; }
thead { display: table-header-group; }
li { margin-bottom: 2mm; }
'''
title = source.splitlines()[0].removeprefix('# ')
doc = '<!doctype html><html lang="en"><head><meta charset="utf-8"><title>' + escape(title) + '</title><style>' + css + '</style></head><body>' + body + '</body></html>'
output = ROOT / 'paper.pdf'
HTML(string=doc, base_url=str(ROOT)).write_pdf(output)
print(output)
