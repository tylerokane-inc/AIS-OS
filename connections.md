# Connections

Registry of every system your AIOS can reach. Filled by `/onboard` from Q4-Q7 answers; expanded over time as you wire new tools. `/audit` checks this file for domain coverage and freshness.

| # | Domain | Tool | Mechanism | Auth | Last checked |
|---|---|---|---|---|---|
| 1 | Revenue / Financials | Pre-revenue — none yet | not yet connected | — | — |
| 2 | Customer interactions | Pre-client — none yet (eBay/Yahoo side-hustle explicitly out of scope) | not yet connected | — | — |
| 3 | Calendar | Google Calendar | gws-cli — see `references/gws-cli.md` | OS keyring (OAuth2, encrypted) — verified working | 2026-07-23 |
| 4 | Communication | Gmail (main account) | gws-cli — see `references/gws-cli.md` | OS keyring (OAuth2, encrypted) — verified working | 2026-07-23 |
| 5 | Project / task tracking | ClickUp (primary), Notion (secondary/legacy) | key+ref + script — see `references/clickup-api.md`; hierarchy creation and task/subtask push via `scripts/clickup_push.ps1`, mediated by the `clickup-push` skill (called by `project-planner` and `clickup-capture` — neither talks to ClickUp directly) | `.env` (`CLICKUP_API_TOKEN`) — verified working (token rotated 2026-07-24) | 2026-07-24 |
| 6 | Meeting intelligence | Fireflies (planned — nightly speaking-practice transcripts) | not yet connected | — | — |
| 7 | Knowledge / files | Obsidian (primary, local, separate from gws-cli), Google Drive/Docs/Sheets | gws-cli — scopes authorized, no endpoints used yet (not a current priority) | OS keyring (OAuth2, encrypted) — auth verified, usage unverified | 2026-07-23 |

**Mechanism options:** `mcp` (MCP server), `script` (Python/Bash hitting an API, in `scripts/`), `export` (CSV/JSON dump pipeline), `key+ref` (`.env` key + `references/{tool}-api.md` guide), `gws-cli` (standalone Google Workspace CLI binary, OAuth2 via OS keyring — see `references/gws-cli.md`), `not yet connected`.

When you wire a new tool, also save `references/{tool}-api.md` capturing endpoints, auth flow, and common queries — researched-once-saved-forever.

**Growth policy for every `references/{tool}-api.md` file:** document endpoints
on-demand as they get used in a real build, not the full API surface up
front. Pre-documenting every endpoint group a tool offers bloats the
reference file with things nothing here actually touches — direct conflict
with the token-efficiency goal these files exist for. Every endpoint
documented **must carry its own `Source:` link** (the exact vendor doc page,
not just the docs root) — that's what makes a failure fast to fix later: on
a failed call, read the actual error body first (often the real bug isn't a
docs gap at all); if it is, the `Source:` link is sitting right there, no
search needed. Fix it, then update the spec. See the 2026-07-23 ClickUp
entry in `decisions/log.md` for the reasoning in full.
