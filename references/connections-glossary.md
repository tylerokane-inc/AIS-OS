# Connections Glossary — API, REST, SDK, MCP, static vs. rotating keys

Plain-English reference for the terms that come up every time a new connection/API gets
wired into this repo. Written 2026-07-27 after walking through it live while building
`web-scrape`. See `project-planner`/`project-builder`'s "default to direct API, not MCP"
rule and `decisions/log.md` (2026-07-23, 2026-07-27) for the actual standing decision this
glossary explains the reasoning behind.

## API

The general concept: a menu + waiter between two programs. One program (us) asks for
something in a documented format; the other program (Firecrawl, ClickUp, etc.) does the
work and hands back a result. We never need to know how the other side works internally.

## REST API

Not a different thing from "API" — the most common *style* of API. The house rules:
- Each kind of request goes to a specific address (a URL)
- A small set of action words: `GET` (fetch), `POST` (create), `PUT` (update), `DELETE` (remove)
- Data usually travels as JSON (a simple, standard text format)

"Calling a REST API directly" = sending a plain, standard-format request straight to that
address in code, no extra software layer in between.

## SDK (Software Development Kit)

A ready-made bundle of code, built and maintained by the provider itself (e.g. Exa's
`exa-py`), that wraps up the correct request-formatting/error-handling so you call simple,
friendly functions instead of hand-building the raw request. Worth using over plain REST
when an API has enough tricky rules that hand-rolling it risks real mistakes (Exa). Not
needed when the API is simple enough that raw REST is just as safe (Firecrawl, ClickUp).

## MCP (Model Context Protocol)

A standing connection that registers a whole list of "things I can do" into Claude's
context for the *entire conversation*, whether it's used that message or not — like a
walkie-talkie installed on my belt, always on, versus a reference doc that only costs
anything when actually opened. That "always on" cost is real: it's measured in tokens
(roughly, how much Claude is "holding in mind," which is also what usage is billed on).
**Default: don't use MCP** — a direct API call + a `references/<provider>-api.md` file has
zero standing cost. Reach for MCP only when a service's auth is genuinely complex/stateful
enough that hand-rolled code would likely be fragile, or when no usable REST API/SDK
exists at all — and say so explicitly when that's the call, never default to MCP silently.

## Static vs. rotating (OAuth2) API keys

- **Static key** (ClickUp, Firecrawl, Exa) — like a house key cut once; works forever
  until manually replaced. Simple — get it, use the same one every time.
- **Rotating key / OAuth2** (Google Calendar) — like a hotel key card that auto-expires;
  the code has to notice expiry and fetch a fresh one ("refreshing the token"). More
  secure, genuinely more work to get right, which is why Google uses the maintained
  `gws-cli` tool instead of hand-rolled code.

## The actual decision table this all adds up to

| Situation | What we use |
|---|---|
| Static key + simple rules | Direct REST calls (Firecrawl, ClickUp) |
| Static key + finicky/complex rules | Direct calls via the provider's SDK (Exa) |
| Rotating key + complex protocol | A maintained CLI/tool that handles refreshing (Google → `gws-cli`) |
| No simpler option exists, or auth's too fragile to hand-roll safely | MCP — accept the standing token cost because the alternative is worse |
