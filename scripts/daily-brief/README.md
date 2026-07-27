# Daily Brief

A small automated script that checks Tyler's Google Calendar and ClickUp tasks each
morning and surfaces one clear "today's top priority" as a notification — no manual
checking required.

## What it does

Every morning it reads today's Calendar events and today's ClickUp tasks, picks one
winner using a fixed rule (a scheduled Calendar event wins if one's happening; otherwise
the highest-Priority ClickUp task, earliest-due breaking ties), and sends Tyler a
notification naming it.

## Status

v1 — in progress (Discovery phase)

## How to run it

```
(fill in during the build — Discovery will settle whether this runs via Windows Task
Scheduler or Claude Code's built-in schedule feature)
```

## Folder guide

- `docs/` — the plan (spec + build checklist)
- `lib/` — the code, once it's built
- `tests/` — checks that it's working

## Built with

PowerShell (matching this repo's `scripts/clickup_push.ps1`), `gws-cli`, ClickUp API.
Reuses the repo root `.env` (`CLICKUP_API_TOKEN`) and the existing `gws-cli` auth — no
separate credentials needed.

---

*Planned with the Project Planner.*
