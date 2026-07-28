#!/usr/bin/env python3
"""Fetch a single URL's real, rendered content via Firecrawl (handles JS-heavy pages).
Run directly: python firecrawl_fetch.py "https://example.com" [options].
Prints a JSON result to stdout so Claude (or another script) can read it."""
import argparse
import json
import os
import sys
from pathlib import Path

import truststore
truststore.inject_into_ssl()  # Windows' own trusted-certificate list, not Python's
# separate bundled one — Norton Antivirus's HTTPS scanning re-signs traffic with its own
# certificate, which Windows trusts but Python's default list doesn't. See
# decisions/log.md 2026-07-27.

import requests
from dotenv import load_dotenv

# The API key lives in the repo-root .env (shared infra, not private to this skill —
# see decisions/log.md 2026-07-27). Walk up from this file to find it.
REPO_ROOT = Path(__file__).resolve().parents[4]
load_dotenv(REPO_ROOT / ".env")

FIRECRAWL_SCRAPE_URL = "https://api.firecrawl.dev/v2/scrape"


def get_api_key() -> str:
    api_key = os.environ.get("FIRECRAWL_API_KEY")
    if not api_key:
        print(json.dumps({"error": "FIRECRAWL_API_KEY not set in repo-root .env"}), file=sys.stderr)
        sys.exit(1)
    return api_key


def fetch(url: str, formats: list[str] | None = None) -> dict:
    """Fetch a URL's real, rendered content. JS-rendering is Firecrawl's default
    behavior, not something that has to be turned on. Returns the requested formats
    (markdown by default) or a plain error — never a silent empty success."""
    formats = formats or ["markdown"]
    headers = {
        "Authorization": f"Bearer {get_api_key()}",
        "Content-Type": "application/json",
    }
    body = {"url": url, "formats": formats}

    try:
        response = requests.post(FIRECRAWL_SCRAPE_URL, headers=headers, json=body, timeout=30)
    except requests.RequestException as e:
        return {"error": str(e), "url": url}

    if response.status_code != 200:
        # Safety bar: surface the real error, never pretend a failed fetch succeeded.
        return {"error": f"HTTP {response.status_code}", "detail": response.text[:500], "url": url}

    data = response.json()
    if not data.get("success", True):
        return {"error": data.get("error", "Firecrawl reported failure"), "url": url}

    result = {"url": url, "data": data.get("data", {})}
    if not result["data"]:
        result["warning"] = "No content returned — say so, don't guess."

    return result


def main():
    parser = argparse.ArgumentParser(description="Fetch a URL's real content via Firecrawl")
    parser.add_argument("url", help="URL to fetch")
    parser.add_argument("--formats", nargs="+", default=["markdown"],
                         help="e.g. markdown html screenshot")
    args = parser.parse_args()

    result = fetch(args.url, args.formats)
    print(json.dumps(result, indent=2))  # full content, never truncated — a synthesis
    # step reading this needs everything, and silently cutting it here would be exactly
    # the kind of data loss the "don't dump raw pages, but don't lose real content either"
    # rule is meant to prevent


if __name__ == "__main__":
    main()
