# Firecrawl API Reference

Researched-once-saved-forever guide for the Firecrawl API (JS-rendering page
scrape). Used by the `web-scraping` skill, and any future skill that needs the
same capability (e.g. a planned daily AI/trading news brief) — this is why the
key and this reference live at the repo root, not inside one skill's folder.
See `decisions/log.md` 2026-07-27 ("Secrets: root `.env` for shared infra").

Auth key lives in the repo-root `.env` (`FIRECRAWL_API_KEY`) — never commit it.

Docs root: https://docs.firecrawl.dev
Agent-onboarding guide (pasted in full by Tyler 2026-07-27, source of the
richer endpoint list below): https://firecrawl.dev/agent-onboarding/SKILL.md

## Growth policy

Same spirit as `clickup-api.md`'s rule (document what's used, not the whole
surface) — refined 2026-07-27: also capture detail that's already in front of
Claude for free, even before it's wired into code. See `decisions/log.md`
2026-07-27 ("API reference docs: capture on-hand detail immediately"). Don't
go hunting for endpoints nobody's mentioned.

## Client: plain REST calls, no SDK/CLI needed

Firecrawl's own agent-onboarding doc confirms two integration paths: **Path A**
(their CLI, `npx firecrawl-cli`) runs commands live during a single session —
for one-off lookups, not what we're building. **Path B/E** (REST API directly)
is for "code that will keep running long after the agent stops" — exactly a
persistent Claude Code skill. We use Path E: call the REST API directly with
Python's `requests` — no CLI install, no Node/npm dependency, no bundled
skill packages from Firecrawl living alongside our own. Decided 2026-07-27,
see `decisions/log.md`.

## Auth

- **Header:** `Authorization: Bearer <FIRECRAWL_API_KEY>`
- **Base URL:** `https://api.firecrawl.dev/v2`
- A key is technically optional for basic/keyless use (lower, shared rate
  limits) — always send ours for the higher limit.

Source: https://firecrawl.dev/agent-onboarding/SKILL.md

## Free tier

- 1,000 credits/month, 2 concurrent requests (paid tiers: 5-150 concurrent)
- **JS-rendering is core/default Firecrawl behavior, not gated to paid
  tiers** — confirmed via docs, not just the pricing page (this was an open
  question during planning, now resolved)
- Paid plans start at $16/month (Hobby) once free credits are exhausted

## Core endpoint: scrape

```
POST /scrape
```

Request body:
- `url` (string, required)
- `formats` — array. **Confirmed full valid list (via a live 400 error's validation
  detail, 2026-07-27):** `markdown`, `html`, `rawHtml`, `links`, `images`, `summary`,
  `json`, `deterministicJson`, `changeTracking`, `screenshot`, `attributes`, `branding`,
  `product`, `menu`, `question`, `highlights`, `query`, `audio`, `video`. **No `pdf`
  format exists** — PDF export has to be generated ourselves from fetched
  markdown/HTML, Firecrawl doesn't offer it natively.
- `actions`, `location`, `maxAge` — optional, not needed for v1

Handles JS-rendered pages and PDFs as source documents natively (both confirmed via live
`/scrape` tests, 2026-07-27 — a Wikipedia HTML page, a Vue.js SPA, and an arXiv PDF all
fetched cleanly). **Correction (2026-07-27): image URLs are NOT supported** — a direct
image URL returns `HTTP 500 SCRAPE_UNSUPPORTED_FILE_ERROR` ("Binary files like images,
videos, executables, and archives are not supported"). The earlier claim that Firecrawl
"handles images as source documents natively" was wrong; removed. Also confirmed: some
sites are blocklisted server-side regardless of content (Reddit returned `HTTP 403` — "we
do not support this site") — not a bug, no workaround via `/scrape`.

Source: https://firecrawl.dev/agent-onboarding/SKILL.md

## Other confirmed endpoints (not wired into code yet — captured now since the
detail was already in front of us, per the growth policy above)

- **`POST /search`** — "discover pages by query, returns results with
  optional full-page content." A real search capability, not just scrape —
  considered and **not** adopted for our search step; Exa is a dedicated
  neural search engine (its whole product), this is a bundled convenience
  feature. Kept in mind as a fallback if Exa's search ever disappoints.
- **`POST /crawl`** — crawl an entire site into structured data (bulk, many
  pages). Exact request/response shape **not yet confirmed**. Not part of
  this build.
- **`POST /interact`** — browser actions (clicks, forms, navigation) for
  pages needing interaction first, e.g. a login wall. Exact request shape
  **not yet confirmed**. Not part of this build.
- **`POST /parse`** — local/non-public document upload (`multipart/form-data`;
  PDF, DOCX, DOC, ODT, RTF, XLSX, XLS, HTML; up to 50MB) → markdown/JSON/
  HTML/summary. Different from `/scrape`, which handles *public* document
  URLs already.
- **`POST /monitor`** — recurring change-detection on a page/site/search
  query; diffs against the last snapshot, can judge changes against a
  plain-language goal, notifies via webhook/email/Slack. Relevant later for
  "alert me when X changes" (e.g. the news-brief idea), not this build.
- **`GET /search/research/papers`**, **`GET /search/research/github`** — a
  purpose-built index for scientific papers and GitHub issues/PRs/READMEs.
- **`POST /support/ask`** — diagnose a failing call by passing the failing
  `jobId`, instead of guessing why something broke.
- **`POST /support/docs-search`** — "how do I…" questions answered from
  Firecrawl's own current docs, with citations.

## Keyless free tier (fallback only)

Search/scrape/interact/parse work rate-limited with no API key at all, but
only when called from an official Firecrawl client (MCP, CLI, or SDK) — not
from a plain unauthenticated REST call. Not our path (we're using a real key
via direct REST), just worth knowing if a key is ever unavailable mid-session.

## Common gotchas

- None confirmed yet through real use — this file will grow here once we've
  actually made live calls and hit something worth recording (matches the
  `clickup-api.md` pattern of gotchas coming from real testing, not guesses).

## All sources referenced in this file

- https://docs.firecrawl.dev (docs root)
- https://firecrawl.dev/agent-onboarding/SKILL.md (agent-onboarding guide —
  pasted in full by Tyler 2026-07-27; source of the fuller endpoint list above)
