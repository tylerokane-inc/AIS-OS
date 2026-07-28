# Exa API Reference

Researched-once-saved-forever guide for the Exa API (semantic/neural web search).
Used by the `web-scrape` skill, and any future skill that needs the same
capability (e.g. a planned daily AI/trading news brief) — this is why the key
and this reference live at the repo root, not inside one skill's folder. See
`decisions/log.md` 2026-07-27 ("Secrets: root `.env` for shared infra").

Auth key lives in the repo-root `.env` (`EXA_API_KEY`) — never commit it.

Docs root: https://docs.exa.ai
Canonical coding-agent guide (source of truth if anything here goes stale):
https://docs.exa.ai/reference/search-api-guide-for-coding-agents

## Growth policy

Same spirit as `clickup-api.md`'s rule (document what's used, not the whole
surface) — refined 2026-07-27: also capture detail that's already in front of
Claude for free (e.g. from a generated setup doc), even before it's wired into
code, rather than re-deriving it later. See `decisions/log.md` 2026-07-27 ("API
reference docs: capture on-hand detail immediately"). Don't go hunting for
endpoints nobody's mentioned.

## Client: use the official SDK, not raw REST

Unlike Firecrawl (simple enough for plain `requests` calls), Exa's API has real
documented footguns — deprecated parameters that silently no-op, parameters
that must be nested a specific way, and a snake_case/camelCase mismatch
between raw JSON and the SDK. Use the official Python SDK instead of
hand-rolling requests:

```bash
pip install exa-py==2.14.0
```

```python
import os
from exa_py import Exa

exa = Exa(api_key=os.environ.get("EXA_API_KEY"))
```

## Auth

- **Header (if ever calling raw REST):** `x-api-key: <EXA_API_KEY>`, or
  `Authorization: Bearer <EXA_API_KEY>`
- **Base URL:** `https://api.exa.ai`

Source: https://docs.exa.ai/reference/search-api-guide-for-coding-agents

## Pricing / credits (not a rate limit — credit-based)

- Free: $20 signup credit + $10/month recurring
- Paid: ~$7 per 1,000 requests once credits are exhausted
- Personal-scale use (this project) should comfortably fit the free allocation

## Core endpoint: search

```
POST /search
```

Key request fields:
- `query` (string, required)
- `type` — `"auto"` (default, balanced) | `"fast"` (~450ms) | `"instant"`
  (~250ms, chat/autocomplete) | `"deep-lite"` (~4s, cheaper synthesis) |
  `"deep"` (4-15s, research/enrichment) | `"deep-reasoning"` (12-40s, hardest
  multi-step synthesis)
- `numResults` (1-100, default 10)
- `contents` — object requesting `highlights` (token-efficient excerpts,
  **default choice for agent workflows**), `text` (full extraction, needs
  `maxCharacters` cap to control token cost), and/or `summary`
- `category` — optional focus (`news`, `company`, `people`, etc.)
- `includeDomains` / `excludeDomains` — usually unnecessary (neural search
  finds relevant results without restriction); use only to target/exclude
  specific sources
- `maxAgeHours` (inside `contents`) — cache freshness: omit for default
  (livecrawl as fallback), `24` for daily-fresh, `0` to always livecrawl,
  `-1` to never livecrawl (cache only, fastest)
- **`outputSchema`** + **`systemPrompt`** — the important one for us: instead
  of raw results, Exa synthesizes a grounded answer matching a JSON schema you
  provide. `systemPrompt` controls source preferences/dedupe rules;
  `outputSchema` controls the shape of `output.content`. Works on every
  `type`. Max nesting depth 2, max 10 total properties. **Don't add
  citation/confidence fields to the schema — grounding comes back
  automatically.**
- `additionalQueries` — array of query variants to broaden a `deep`/
  `deep-lite`/`deep-reasoning` search
- `stream` (bool) — switches to SSE mode (OpenAI-style chunks) when using
  `outputSchema`

Response:
- `results[]` — `title`, `url`, `publishedDate`, `author`, `text`,
  `highlights`, `summary` per result, plus `costDollars`
- When `outputSchema` is used: `output.content` (synthesized JSON matching
  the schema) + `output.grounding` (array of `{field, citations, confidence}`
  — this is the source-attribution our `web-scrape` skill's synthesis step
  needs)

Source: https://docs.exa.ai/reference/search-api-guide-for-coding-agents

## Other endpoint: get contents for known URLs

```
POST /contents
```

Use when URLs are already known (not from an Exa search) and just need clean
content — e.g. a URL Tyler hands over directly. `highlights`/`text` are
**top-level** fields here (not nested inside `contents` like on `/search` —
easy to mix up, see gotchas below).

## Not used — noted for completeness

`POST /answer` — grounded single-answer Q&A with citations, built for
question-first UIs. Not our use case (`web-scrape` needs retrieval +
structured data for a subagent, not one prose answer) — their own guidance
recommends `/search` + `outputSchema` for exactly our situation.

## Common gotchas

- `useAutoprompt` — **deprecated**, don't use
- `includeUrls` / `excludeUrls` — **don't exist**; use `includeDomains` /
  `excludeDomains`
- `text`, `summary`, `highlights` — must be **nested inside `contents`** on
  `/search` (`"contents": {"highlights": true}`). On `/contents` they're
  **top-level** instead — don't confuse the two endpoints' shapes.
- `numSentences`, `highlightsPerUrl` — deprecated; use `highlights: true`
- `tokensNum` — doesn't exist; use `contents.text.maxCharacters`
- `livecrawl: "always"` — deprecated; use `contents.maxAgeHours: 0`
- `excludeDomains` + `category: "company"` or `"people"` — returns a 400
  error; those categories don't support domain/date filters
- **Case convention:** raw JSON / JS SDK use camelCase (`maxCharacters`);
  Python SDK uses snake_case (`max_characters`) — applies inside nested
  dicts too, not just top-level args
- `text: true` with no `maxCharacters` cap can blow up token usage — prefer
  `highlights` for most agent workflows

## All sources referenced in this file

- https://docs.exa.ai (docs root)
- https://docs.exa.ai/reference/search-api-guide-for-coding-agents (canonical
  coding-agent guide — check this first if anything above looks stale)
