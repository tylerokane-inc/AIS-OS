#!/usr/bin/env python3
"""Semantic web search via Exa. Run directly: python exa_search.py "query" [options].
Prints a JSON result to stdout so Claude (or another script) can read it."""
import argparse
import json
import os
import sys
from pathlib import Path

import truststore
truststore.inject_into_ssl()  # Use Windows' own trusted-certificate list instead of a
# separate bundled one — needed on this machine because Norton Antivirus's HTTPS scanning
# re-signs traffic with its own certificate, which Windows trusts but Python's default
# list doesn't. See decisions/log.md 2026-07-27.

from dotenv import load_dotenv
from exa_py import Exa

# The API key lives in the repo-root .env (shared infra, not private to this skill —
# see decisions/log.md 2026-07-27). Walk up from this file to find it, so it works no
# matter what directory this script gets run from.
REPO_ROOT = Path(__file__).resolve().parents[4]
load_dotenv(REPO_ROOT / ".env")


def get_client() -> Exa:
    api_key = os.environ.get("EXA_API_KEY")
    if not api_key:
        print(json.dumps({"error": "EXA_API_KEY not set in repo-root .env"}), file=sys.stderr)
        sys.exit(1)
    return Exa(api_key=api_key)


def search(query: str, num_results: int = 10, search_type: str = "auto",
           output_schema: dict | None = None, system_prompt: str | None = None) -> dict:
    """Run a semantic search. Returns raw results (title/url/highlights) by default.
    If output_schema is given, also returns a synthesized, source-attributed answer
    matching that schema (Exa's native grounding — see references/exa-api.md)."""
    exa = get_client()
    kwargs = {"type": search_type, "num_results": num_results, "contents": {"highlights": True}}
    if output_schema:
        kwargs["output_schema"] = output_schema
    if system_prompt:
        kwargs["system_prompt"] = system_prompt

    try:
        response = exa.search(query, **kwargs)
    except Exception as e:
        # Safety bar: a failed call says so plainly, never returns something that
        # looks like a valid empty result.
        return {"error": str(e), "query": query}

    result = {
        "query": query,
        "results": [
            {
                "title": r.title,
                "url": r.url,
                "highlights": getattr(r, "highlights", None),
            }
            for r in response.results
        ],
    }
    if output_schema and getattr(response, "output", None):
        result["synthesized"] = response.output.content
        result["grounding"] = response.output.grounding

    if not result["results"] and "synthesized" not in result:
        result["warning"] = "No results found for this query — say so, don't guess."

    return result


def main():
    parser = argparse.ArgumentParser(description="Semantic web search via Exa")
    parser.add_argument("query", help="Search query")
    parser.add_argument("--num-results", type=int, default=10)
    parser.add_argument("--type", default="auto",
                         choices=["auto", "fast", "instant", "deep-lite", "deep", "deep-reasoning"])
    parser.add_argument("--output-schema", help="JSON schema string for synthesized/grounded output")
    parser.add_argument("--system-prompt", help="System prompt to steer synthesis")
    args = parser.parse_args()

    schema = json.loads(args.output_schema) if args.output_schema else None
    result = search(args.query, args.num_results, args.type, schema, args.system_prompt)
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
