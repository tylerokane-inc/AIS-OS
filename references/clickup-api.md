# ClickUp API Reference

Researched-once-saved-forever guide for the ClickUp API. Used directly via
HTTP (not the MCP server) for token efficiency. Auth key lives in `.env`
(`CLICKUP_API_TOKEN`) — never commit it.

Docs root: https://developer.clickup.com/reference

## Growth policy

This file documents endpoints **as they get used**, not the full API surface
up front — a complete mirror of every ClickUp endpoint group (Chat, Docs,
Goals, Guests, Time Tracking, Templates, Roles, User Groups, Custom Task
Types, Attachments...) would bloat this file with things none of Tyler's
priorities touch. Instead:

1. Only document a group here once it's actually wired into something real.
2. **Every endpoint documented below carries its own `Source:` link** — the
   exact `developer.clickup.com/reference/{slug}` page, not just the docs
   root. That's the whole point: if a call fails, there's a direct link
   sitting right next to it, no search needed.
3. On a failed call: read the actual error body first (ClickUp usually
   returns a specific code/message — often the real bug isn't a docs gap at
   all, e.g. auth-format or network issues). If it is a docs gap, open that
   endpoint's `Source:` link, fix it, then update the spec + confirm the
   source link is still correct.
4. Result: this file converges toward "exactly what we use, verified against
   real calls, one click from the fix" rather than a stale copy of docs we
   never touch.

## Auth

Two methods:

- **Personal API Token** (what we're using) — starts with `pk_`, never
  expires. Generate at ClickUp → avatar menu → Settings → Apps → API Token.
  Header format (no `Bearer` prefix):
  ```
  Authorization: {personal_token}
  ```
- **OAuth2** — for multi-user apps only. Not needed here (single user).

Base URL: `https://api.clickup.com/api/v2`

Source: https://developer.clickup.com/docs/authentication

## Rate limits

| Plan | Requests/min per token |
|---|---|
| Free / Unlimited / Business | 100 |
| Business Plus | 1,000 |
| Enterprise | 10,000 |

On 429, response headers: `X-RateLimit-Limit`, `X-RateLimit-Remaining`,
`X-RateLimit-Reset` (unix timestamp).

Source: https://developer.clickup.com/docs/rate-limits

## Hierarchy (need these IDs before anything else works)

`Workspace (team_id)` → `Space` → `Folder` → `List` → `Task`

Confirmed IDs (fill in as more get created):

```
team_id (workspace): 90141451608   (workspace name: "Personal OS")
space_id:            90146700544   (name: "Projects" -- renamed by Tyler from "Personal Projects")
folder_id:           901411023035  (name: "Personal Trainer App" -- one Folder PER PROJECT, not a shared bucket)
```

**Standing hierarchy model (updated 2026-07-24, direct user feedback drove this):**
`Space` → one **Folder per project** → one **List per phase** inside that Folder → one
plain **Task per step** inside its phase's List. No ClickUp Checklists — a List's normal
view already shows everything in a phase together, which is what actually solves "let me
see the whole phase without clicking into individual tasks."

A phase is never a subtask, and never will be. Subtasks (the `parent` field) are used in
one narrow case only: a single Task with a few small sub-steps worth checking off
separately — an indented `- [ ] ...` line under a top-level one in the checklist file. See
`scripts/clickup_push.ps1`'s `push-plan` action for the working implementation.

Phase Lists carry a `V1 —` or `Expansion —` name prefix (from the build-checklist
template) so the "ship this now" tier and the "parked for later" tier stay visually
separate inside one Folder, without needing a second Folder. `push-plan` is safe to
re-run: a phase already cached is skipped, so `Expansion —` phases can be appended to a
project's checklist and pushed anytime after V1 ships, without duplicating anything.

Lists are created with no forced color (ClickUp's default) — a `status` field on Lists
does control color and works (see below), it's just not applied automatically. Tyler's
actual ask was the **Folder** icon being yellow, and that's **not possible via the API**:
verified live by POSTing both a `color` and a `status` field to `create-folder` — both
are accepted with no error and both are silently ignored (no color field ever comes back
on the Folder object). This is a real ClickUp API limitation, not a script gap — see the
2026-07-24 decision log entry. Setting a Folder's color, if ClickUp's UI even exposes it,
would have to be a manual step Tyler does himself in the app.

See the 2026-07-24 decision log entries for the full story of why the original
parent-Task/subtask design got reversed, and why narrow single-task subtasks came back
later.

Hierarchy is created and read via `scripts/clickup_push.ps1` (shared by the
`project-planner` and `clickup-capture` skills), not called ad hoc — see that
script for the working PowerShell implementation of every endpoint below.

| Purpose | Endpoint | Source |
|---|---|---|
| List your workspaces → `team_id` | `GET /team` | https://developer.clickup.com/reference/getauthorizedteams |
| List spaces in a workspace | `GET /team/{team_id}/space` | https://developer.clickup.com/reference/getspaces |
| Create a Space | `POST /team/{team_id}/space` | https://developer.clickup.com/reference/createspace |
| List folders in a space | `GET /space/{space_id}/folder` | https://developer.clickup.com/reference/getfolders |
| Create a Folder | `POST /space/{space_id}/folder` | https://developer.clickup.com/reference/createfolder |
| List lists in a folder | `GET /folder/{folder_id}/list` | https://developer.clickup.com/reference/getlists |
| Create a List (in a Folder) | `POST /folder/{folder_id}/list` | https://developer.clickup.com/reference/createlist |
| List folderless lists (no folder in use) | `GET /space/{space_id}/list` | https://developer.clickup.com/reference/getfolderlesslists |
| Create a Folderless List (directly in a Space) | `POST /space/{space_id}/list` | https://developer.clickup.com/reference/createfolderlesslist |
| Update a List | `PUT /list/{list_id}` | https://developer.clickup.com/reference/updatelist |

**List color:** both create endpoints accept a `status` field — despite the name, on a
List this means its **sidebar color**, not a task status (`updatelist`'s docs literally
say "Status refers to the List color rather than the task Statuses available in the
List"). Verified live: it only accepts a small set of named colors (`"yellow"` confirmed
working, returns `{"status":"yellow","color":"#f8ae00","hide_label":true}`) — an arbitrary
hex string (`"#f9d900"`) fails with `{"err":"Invalid status","ECODE":"SUBCAT_104"}`. No
equivalent field exists on Folders (see below).

Verified live 2026-07-23: `GET /team` → returns `team_id: 90141451608`.
`GET /team/90141451608/space` → `{"spaces":[]}` (workspace was empty at the time).

Verified live 2026-07-24: full create chain against the real workspace —
`POST /team/{team_id}/space` with body `{"name": "...", "multiple_assignees":
true, "features": {}}` — **an empty `features: {}` object works**, ClickUp
fills in sensible defaults for every feature toggle rather than rejecting the
call. `POST /space/{space_id}/folder` and `POST /folder/{folder_id}/list`
both only need `{"name": "..."}`. Pushed a real 139-item, 16-phase project
plan as 16 Lists (one per phase) inside one Folder, with a plain
`POST /list/{list_id}/task` per step — all succeeded once the UTF-8 encoding
gotcha below was fixed.

**Also verified but NOT used in the final design:** ClickUp Checklists
(`POST /task/{task_id}/checklist` → `{"name": "..."}` returns a checklist
`id`; `POST /checklist/{checklist_id}/checklist_item` → `{"name": "..."}`
adds an item to it) — both work fine. Considered as a way to group phase
items under one Task, but the List-per-phase model above does the same job
using endpoints already needed elsewhere, so Checklists were dropped rather
than maintaining two hierarchy mechanisms. Worth knowing they work if a
future need (e.g. sub-items *within* one Task) actually calls for them.

## Core endpoints for the daily-planning system

### Get tasks in a list
```
GET /list/{list_id}/task
```
Query params:
- `page` (int, starts at 0) — pagination, 100 tasks/page max
- `order_by` — `id` | `created` | `updated` | `due_date`
- `reverse` (bool)
- `statuses[]`, `include_closed` (bool), `archived` (bool)
- `assignees[]`, `watchers[]`, `tags[]`
- `due_date_gt` / `due_date_lt` — unix ms
- `date_created_gt` / `date_created_lt`, `date_updated_gt` / `date_updated_lt`
- `custom_fields`, `custom_field`
- `subtasks` (bool), `include_markdown_description` (bool)

Source: https://developer.clickup.com/reference/gettasks

### Get tasks across the whole workspace (cross-list — useful for "what's my one priority today" across all lists)
```
GET /team/{team_id}/task
```
Query params: `space_ids[]`, `project_ids[]` (folders), `list_ids[]`,
`statuses[]`, `assignees[]`, `tags[]`, `include_closed`, `order_by`, `page`.

Source: https://developer.clickup.com/reference/getfilteredteamtasks

### Create a task
```
POST /list/{list_id}/task
```
Body fields: `name` (required), `description`, `markdown_content`,
`assignees[]`, `status`, `priority` (1=urgent..4=low), `due_date` (unix ms),
`due_date_time` (bool), `start_date`, `time_estimate` (ms), `tags[]`,
`parent` (subtask), `custom_fields[]`.

Source: https://developer.clickup.com/reference/createtask

### Update a task
```
PUT /task/{task_id}
```
Same body shape as create — send only fields to change.

Source: https://developer.clickup.com/reference/updatetask

### Get single task
```
GET /task/{task_id}
```

Source: https://developer.clickup.com/reference/gettask

### Delete a task
```
DELETE /task/{task_id}
```

Source: https://developer.clickup.com/reference/deletetask

### Create a comment on a task
```
POST /task/{task_id}/comment
```
Body: `comment_text` (required, string). Docs also list `notify_all` (bool) as required,
but it works fine omitted — only `comment_text` was sent in practice. Used by
`clickup_push.ps1`'s `add-comment` action and inline by `push-plan` (see the ` :: `
task-line syntax in `clickup-export.md`) so Discovery answers land as comments instead
of being baked into task titles.

Source: https://developer.clickup.com/reference/createtaskcomment

## Custom task statuses (e.g. adding "in progress")

**Not settable via the API — confirmed unsupported, not just undocumented.** Tested
`PUT /space/{id}` with a `statuses` array (`to do` / `in progress` / `complete`): the
call succeeds with no error, but the response's `statuses` come back unchanged — the
field is silently ignored, same pattern as Folder color above. A Space starts with only
`to do` (open) and `complete` (closed) by default. Adding a custom status like "in
progress" has to be done by Tyler in the ClickUp app itself (Space Settings → ClickApps
→ Statuses, or per-List "Edit statuses") — once he does, it applies automatically to
every task created afterward by this pipeline; no script change needed on this end.
`create-task`/`push-plan` can still set a task straight to `"complete"` today (see
`status` on Create a task, above) since that status already exists.

## Other endpoint groups (not yet used — landing page only, unverified)

Not fetched/tested yet. Links point to the group's first endpoint page as a
fast entry point; open the full nav on that page to find the specific one
needed when the time comes.

| Group | Base path | Entry-point source |
|---|---|---|
| Checklists | `/task/{id}/checklist` | https://developer.clickup.com/reference/createchecklist |
| Tags | `/space/{id}/tag`, `/task/{id}/tag/{tag}` | https://developer.clickup.com/reference/getspacetags |
| Time tracking | `/team/{id}/time_entries` | https://developer.clickup.com/reference/gettimeentrieswithinadaterange |
| Webhooks | `/team/{id}/webhook` | https://developer.clickup.com/reference/getwebhooks |
| Views | `/team\|space\|folder\|list/{id}/view` | https://developer.clickup.com/reference/getteamviews |
| Goals | `/team/{id}/goal` | https://developer.clickup.com/reference/getgoals |
| Custom Fields | `/list/{id}/field` | https://developer.clickup.com/reference/getaccessiblecustomfields |

## Common gotchas

- Dates are **unix milliseconds**, not seconds.
- `priority` is an int: 1 = Urgent, 2 = High, 3 = Normal, 4 = Low.
- List/folder/space/task IDs are strings even though some look numeric.
- Pagination caps at 100 items/page — loop `page` until a short page returns.
- No official webhook signature docs surfaced yet — verify HMAC header name
  before trusting incoming payloads if we wire webhooks later.
- On Windows/PowerShell: strip whitespace (`.Trim()`) when reading the token
  out of `.env` — a stray trailing character caused one 400 error here that
  had nothing to do with the API itself.
- **Windows PowerShell 5.1's `Get-Content` mangles non-ASCII characters** (em
  dashes, curly quotes) in any file that doesn't have a UTF-8 BOM — it silently
  falls back to the system codepage instead of UTF-8, corrupting the bytes
  before they ever reach the API. This caused real `400 Bad Request` errors
  pushing a checklist with em-dash phase headers. Fix: always read with
  `Get-Content -Encoding UTF8` explicitly (`scripts/clickup_push.ps1` does
  this everywhere it reads a file). `ConvertTo-Json`'s own output is pure
  ASCII (`\uXXXX`-escaped), so this is purely a *read-side* issue, not
  something `Invoke-RestMethod`'s request encoding can mask.
- **Bulk creates need throttling.** Rate limit is 100 req/min (see above) —
  pushing many subtasks back-to-back (e.g. a 139-item checklist) will hit it
  without a small delay between calls. `clickup_push.ps1` sleeps 650ms
  between task-create calls in its bulk-push actions.
- `Invoke-RestMethod`'s terminating-error object often has the real API
  error body in `$_.ErrorDetails.Message` — check that before falling back
  to manually reading `$_.Exception.Response`'s stream.
- **List `status` (color) only accepts specific named colors, not arbitrary hex.**
  `"yellow"` is confirmed working; an arbitrary hex string like `"#f9d900"` returns
  `{"err":"Invalid status","ECODE":"SUBCAT_104"}`. If a future need calls for a different
  color, test the name empirically the same way rather than guessing a hex value.
- **Folders have no color field in the API, full stop.** Neither `color` nor `status`
  (the field name that works for Lists) does anything on `create-folder` — both are
  silently swallowed, no error and no effect. Don't spend more time guessing field names
  for this; it's been tested and confirmed unsupported.

## All sources referenced in this file

- https://developer.clickup.com/reference (docs root)
- https://developer.clickup.com/docs/authentication
- https://developer.clickup.com/docs/rate-limits
- https://developer.clickup.com/reference/getauthorizedteams
- https://developer.clickup.com/reference/getspaces
- https://developer.clickup.com/reference/createspace
- https://developer.clickup.com/reference/getfolders
- https://developer.clickup.com/reference/createfolder
- https://developer.clickup.com/reference/getlists
- https://developer.clickup.com/reference/createlist
- https://developer.clickup.com/reference/getfolderlesslists
- https://developer.clickup.com/reference/createfolderlesslist
- https://developer.clickup.com/reference/updatelist
- https://developer.clickup.com/reference/gettasks
- https://developer.clickup.com/reference/getfilteredteamtasks
- https://developer.clickup.com/reference/createtask
- https://developer.clickup.com/reference/updatetask
- https://developer.clickup.com/reference/gettask
- https://developer.clickup.com/reference/deletetask
- https://developer.clickup.com/reference/createtaskcomment
