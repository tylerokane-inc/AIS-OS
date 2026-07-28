#!/usr/bin/env python3
"""Turn markdown text into a real PDF file. Firecrawl has no native PDF format (confirmed
2026-07-27 — see references/firecrawl-api.md), so this converts markdown -> HTML -> PDF
ourselves using pure-Python libraries (no external binaries to install).
Run directly: python export_pdf.py --input-file notes.md --output notes.pdf
Or pipe text in: cat notes.md | python export_pdf.py --output notes.pdf"""
import argparse
import json
import sys
from pathlib import Path

import markdown
from xhtml2pdf import pisa


def markdown_to_pdf(md_text: str, output_path: str) -> dict:
    html_body = markdown.markdown(md_text, extensions=["tables", "fenced_code"])
    html = f"<html><body>{html_body}</body></html>"

    output_path = Path(output_path)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    with open(output_path, "wb") as f:
        result = pisa.CreatePDF(html, dest=f)

    if result.err:
        return {"error": f"PDF generation failed with {result.err} error(s)", "output": str(output_path)}

    return {"output": str(output_path.resolve())}


def main():
    parser = argparse.ArgumentParser(description="Convert markdown to a PDF file")
    parser.add_argument("--input-file", help="Path to a markdown file (omit to read stdin)")
    parser.add_argument("--output", required=True, help="Path to write the PDF to")
    args = parser.parse_args()

    if args.input_file:
        md_text = Path(args.input_file).read_text(encoding="utf-8")
    else:
        md_text = sys.stdin.read()

    if not md_text.strip():
        print(json.dumps({"error": "No markdown content given — nothing to convert"}))
        sys.exit(1)

    result = markdown_to_pdf(md_text, args.output)
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
