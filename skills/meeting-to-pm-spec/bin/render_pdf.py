#!/usr/bin/env python3
"""
meeting-to-pm-spec / render_pdf
HTML → A4 PDF via Playwright headless Chromium.

Usage: render_pdf.py <html_path> <pdf_path>
"""

import sys
from pathlib import Path
from playwright.sync_api import sync_playwright


def main():
    if len(sys.argv) != 3:
        print("Usage: render_pdf.py <html_path> <pdf_path>", file=sys.stderr)
        sys.exit(1)

    html_path = Path(sys.argv[1]).resolve()
    pdf_path = Path(sys.argv[2]).resolve()

    if not html_path.exists():
        print(f"❌ HTML not found: {html_path}", file=sys.stderr)
        sys.exit(1)

    pdf_path.parent.mkdir(parents=True, exist_ok=True)

    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()
        page.goto(f"file://{html_path}", wait_until="networkidle")
        page.pdf(
            path=str(pdf_path),
            format="A4",
            print_background=True,
            margin={"top": "0", "right": "0", "bottom": "0", "left": "0"},
            prefer_css_page_size=True,
        )
        browser.close()

    print(f"✓ {pdf_path}")


if __name__ == "__main__":
    main()
