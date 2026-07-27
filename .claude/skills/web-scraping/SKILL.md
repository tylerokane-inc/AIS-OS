---
name: web-scraping
description: Use whenever Claude (or a subagent Claude spins up for research) needs real web content — either Claude's own web tools would fail or fall short (a JavaScript-heavy page WebFetch can't render, a query where WebSearch's keyword matching would miss what's actually meant), or Tyler explicitly asks to search/scrape/research something on the web. This is meant to fire automatically during research, not just on an explicit trigger phrase — the same way obsidian-context sometimes fires on its own. Foundational utility skill other skills lean on.
---

# Web Scraping

Fixes two real gaps in Claude's built-in web tools: `WebSearch` matches by keyword and can
miss what's actually meant; `WebFetch` can't render JavaScript, so a lot of modern pages
come back blank (proven live 2026-07-27 — a YouTube transcript came back as empty page
boilerplate). This skill replaces both with **Exa** (semantic/neural search) and
**Firecrawl** (JS-rendering page fetch), called directly via their REST APIs — no MCP, see
`decisions/log.md` for why.

**Who uses this:** both Tyler directly, and — more often — any subagent Claude spins up to
do research. It's meant to be reached for automatically during research, not only when
Tyler says a specific trigger phrase.

## Setup this skill depends on

Both API keys live in the **repo-root** `.env` (`EXA_API_KEY`, `FIRECRAWL_API_KEY`) —
shared infrastructure, not private to this skill. If either is missing, the scripts below
fail with a clear `error` field naming exactly which key is missing — never guess or skip
silently. Python packages: `pip install -r requirements.txt` in this folder (installs
`exa-py`, `requests`, `python-dotenv`, `truststore`, `xhtml2pdf`, `markdown`).

**Every script in `scripts/` calls `truststore.inject_into_ssl()` before making any web
request.** This machine's Norton Antivirus re-signs HTTPS traffic with its own
certificate; without this, every request fails with a certificate error that has nothing
to do with the API itself. See `decisions/log.md` 2026-07-27. If a future environment
doesn't need this, it's harmless to leave in — it just uses the OS's trust store instead
of a bundled one.

## The four scripts

Run these via Bash, from the repo root:

1. **`python .claude/skills/web-scraping/scripts/exa_search.py "query"`** — semantic web
   search. Returns relevant pages with query-relevant highlights (not full pages — kept
   token-efficient on purpose). Add `--output-schema '<json schema>'` and
   `--system-prompt "..."` to get Exa's own synthesized, source-attributed answer back
   directly (see "Synthesis" below) instead of raw results.
2. **`python .claude/skills/web-scraping/scripts/firecrawl_fetch.py "url"`** — fetch a
   specific URL's real, fully-rendered content (handles JS-heavy pages natively — nothing
   extra to configure). Add `--formats markdown screenshot` for a screenshot alongside the
   text; any of Firecrawl's valid formats work (see `references/firecrawl-api.md`).
3. **`python .claude/skills/web-scraping/scripts/export_pdf.py --output path/to/file.pdf`**
   (reads markdown from stdin, or `--input-file`) — turns markdown into a real PDF file.
   Firecrawl has no native PDF format; this builds one from whatever markdown you already have.
4. Use Exa and Firecrawl together when it makes sense: Exa to find *what's relevant*,
   Firecrawl when you need the full real content of a specific result (or Tyler hands you
   a URL directly that wasn't found via search). Check whether Exa's own `highlights`/
   `contents` already answer the question before reaching for Firecrawl too — don't call
   both by default if one already has what's needed.

## The output rule — never dump raw pages

**This is the most important rule in this skill.** Whatever comes back from these scripts
gets synthesized into a structured, source-attributed findings document before it's handed
to Tyler (or back up the chain to whatever called the subagent) — never pasted through as
raw fetched text. Tyler's own words: "I don't want you dumping raw pages. I want you to
take all that relevant information... I want to be able to look at the sources and know
where it's coming from."

**Synthesis is Claude's own job, not a separate script.** After calling these scripts, read
what came back and write up findings organized by topic, with every real claim attributed
to its source URL — like a research brief with citations, not a wall of pasted text. For
Exa results specifically, `--output-schema` can do a version of this synthesis natively at
the API level (Exa returns `output.content` matching your schema plus `output.grounding`
— field-level citations with confidence) — worth reaching for when the shape of the answer
is known ahead of time; for anything looser, or when combining Exa + Firecrawl results
together, do the synthesis directly when writing the response.

## Safety bar

If a fetch fails, a search comes back empty, or results are thin/ambiguous, **say so
plainly** — every script already returns a clear `error` or `warning` field for exactly
this. Never present a weak or missing result as if it were solid.

## What this skill does NOT do

Save or file anything long-term — results go back into the conversation only. Persisting
research for later is the future `ingest-source` skill's job, not this one. Doesn't touch
Tyler's files at all; it only reads the open web.
