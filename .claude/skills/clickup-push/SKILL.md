---
name: clickup-push
description: Use whenever something needs to become real ClickUp Tasks, Lists, or Folders — a full project build checklist, a single task, or a small batch of steps. Other skills (project-planner, clickup-capture, and anything built later) hand off to this skill instead of talking to the ClickUp API themselves. Trigger on "push to ClickUp," "push this to ClickUp," "add this to ClickUp," or when another skill's own instructions say to use the ClickUp push skill.
argument-hint: [a checklist file path, or a task/step description]
---

# ClickUp Push

The one skill that knows ClickUp — hierarchy, naming, status, comments, all of it. Every
other skill that needs something to land in ClickUp calls this one instead of duplicating
that knowledge. `project-planner` plans a whole project and hands the finished checklist
here to go live. `clickup-capture` catches a casual one-off task and hands it here too.
Neither of them talks to the ClickUp API directly, and neither should — if a future skill
needs a ClickUp side effect, it hands off here too rather than growing its own copy of
this logic.

All actual API calls go through one shared script, `scripts/clickup_push.ps1` at the repo
root (auth + endpoint reference: `references/clickup-api.md`), and one shared cache,
`scripts/clickup_project_map.json`, so a project pushed by either caller is recognized by
the other.

## Which mode

- **A full structured plan** (a `docs/build-checklist.md`-shaped file, multiple sections
  each with their own tasks) → Mode A below. This is what `project-planner` calls after
  its Step 5.
- **One task, or a short flat list of steps someone just mentioned** → Mode B below. This
  is what `clickup-capture` calls.

## The structure this skill produces (both modes)

- One **Folder** per project, named after it, created directly in the resolved Space —
  never a shared bucket for multiple projects. Folders can't be colored via the ClickUp
  API — confirmed live, `create-folder`/`update-folder` silently ignore both `color` and
  `status` fields (no error, no effect). If Tyler wants a Folder's sidebar icon a specific
  color, that's a manual step in the ClickUp app; this skill can't automate it.
- One **List** per section, named **exactly** what the section is called in the source —
  short and plain (`01: Discovery`, `Expansion: Boxing`), never decorated with extra
  labels like "V1" or "Phase." Lists default to no forced color (ClickUp's gray/none) — a
  `status` field on Lists does control color and works (`"yellow"` confirmed live, returns
  `#f8ae00`), available if a per-section color scheme is wanted later, unused today.
- One plain **Task** per top-level step, inside its section's List. A step indented under
  another becomes a native ClickUp **subtask** of that one task — only for one task's own
  small sub-steps, never for a whole section. (An early version of this pipeline made
  every step a subtask of one giant parent Task and it was unusable — 139 tasks with no
  way to see a whole section at once. Never go back to that shape.)
- **Checkbox state controls the task's ClickUp status.** An open `- [ ]` item creates a
  task at the default "to do" status; a checked `- [x]` item creates it already marked
  **Complete**. Custom statuses (e.g. adding "In Progress") are **not settable via the
  API at all** — confirmed live, `PUT /space/{id}` with a `statuses` array is accepted
  with no error but silently has no effect. Tyler adds custom statuses himself, once, in
  the ClickUp app (Space Settings → ClickApps → Statuses, or per-List "Edit statuses");
  every task pushed afterward uses whatever workflow is active automatically — no script
  change needed on this end once he does.
- **A ` :: ` suffix on a step becomes a ClickUp comment, not part of the title.** Direct
  Tyler feedback: answers belong in comments, never baked into the task name — "keep
  everything clean." `- [x] What does this need to connect to? :: Nothing external.`
  creates a task titled just `What does this need to connect to?`, marked Complete, with
  `Nothing external.` posted as that task's first comment (`POST /task/{id}/comment`).

## Mode A — Push a full structured plan

### Step 0 — Resolve the project's home (ask once, then remember)
```
powershell.exe -File scripts\clickup_push.ps1 -Action resolve -Project <kebab-case-name>
```
- **Cache hit** with a real `folder_id` → reuse it silently, no questions. Its `phases`
  map (section name → List ID, already pushed) comes back too.
- **Cache miss** → new project. Ask which Space it belongs in (existing, or create one),
  then create the project's own Folder:
  ```
  powershell.exe -File scripts\clickup_push.ps1 -Action create-space -Name "<name>"   # only if a new Space is needed
  powershell.exe -File scripts\clickup_push.ps1 -Action create-folder -SpaceId <id> -Name "<project-name>"
  powershell.exe -File scripts\clickup_push.ps1 -Action remember -Project <kebab-case-name> -SpaceId <id> -FolderId <id>
  ```
  Never invent a default Space — always ask on a cache miss.

### Step 1 — Push it
```
powershell.exe -File scripts\clickup_push.ps1 -Action push-plan -Project <name> -FolderId <id> -ChecklistFile <path>
```
Walks the whole file: every `##` line becomes one section's List (skipping ones already
cached — **safe to re-run**, a section already pushed is left alone entirely, so a freshly
appended `## Expansion: <name>` section can be pushed any time later without touching or
duplicating what's already live); every `- [ ] ...` line under it becomes a Task, with the
checkbox-status and `::`-comment rules above applied automatically. Fenced code blocks
(```` ``` ````) anywhere in the source file are always skipped — they're documentation or
examples, never real content, even if their contents look like a `##` heading or a
`- [ ]` line. Reports `created` / `skipped` / `failed` counts.

### Step 2 — Report back
How many Lists and Tasks were created, and that the whole plan is sitting in one Folder
named after the project — no links needed, the caller (or Tyler) can just open ClickUp
and see it grouped by section.

## Mode B — Quick-add a single task or short step list

### Step 0 — Which project does this belong to?
Infer from context — an explicit project name, or "this is for X." If it's genuinely
unaffiliated (a bare one-off, e.g. "remind me to renew my domain"), use the reserved
project key `_default_capture` rather than asking "which project?" every time.

### Step 1 — Resolve the ClickUp home
```
powershell.exe -File scripts\clickup_push.ps1 -Action resolve -Project <key>
```
- **Has a `list_id`** (a simple flat bucket — `_default_capture` and most one-off keys
  use this shape) → go straight to Step 2 with that List. No questions.
- **Has a `folder_id` + `phases`** (this project already exists as a full Mode-A build) →
  a bare one-off doesn't belong dropped into a specific section without asking. Either ask
  which section it belongs in, or offer to create one small extra List (e.g. "Extra
  Tasks") for things that come up later and don't fit a section — then remember that List
  the same way below so it's not asked again for this project.
- **Cache miss** (true first time for this key) → ask once, briefly: "Where should this
  live in ClickUp?" (an existing Space + List, or offer to create a new folderless List —
  a full Mode-A Folder-with-sections is overkill for one-off captures). Create whatever's
  missing and save it:
  ```
  powershell.exe -File scripts\clickup_push.ps1 -Action create-folderless-list -SpaceId <id> -Name "<name>"
  powershell.exe -File scripts\clickup_push.ps1 -Action remember -Project <key> -SpaceId <id> -ListId <id>
  ```
  After this first time, this key never gets asked about again.

### Step 2 — Push it
```
powershell.exe -File scripts\clickup_push.ps1 -Action quick-add -Project <key> -ListId <id> -Name "<title>" [-Steps "step one;step two"]
```
With `-Steps`, this creates one parent Task + native ClickUp subtasks — fine here since a
one-off's step list is small (a handful of items, not a multi-section build). Without
`-Steps`, a single flat Task.

### Step 3 — Report back — one line
Task title, List name, and the `url` the script returns, e.g.:
`Added "Renew the domain" to Inbox — https://app.clickup.com/t/86bb...`
No recap ceremony — speed is the point of Mode B.

## If something fails partway

Don't leave a half-created plan without saying so. Read the actual error body first —
usually the real bug (auth format, a missing required field), not a docs gap. `push-plan`
reports exactly which Tasks made it in and which failed (with the error for each), so the
caller can retry just what's missing rather than guessing. On a 401 or other auth error,
stop immediately and say so plainly — don't retry silently.

## What this skill explicitly does NOT do

Decide what a project even is, run the 10 core questions, write a spec doc, pick a folder
structure — all `project-planner` territory, upstream of this skill. Decide whether
something is a full project versus a one-off task — that's `clickup-capture`'s or
`project-planner`'s judgment call before they ever hand off here. This skill only takes
already-decided content and gets it into ClickUp correctly.

## Files

- `scripts/clickup_push.ps1` (repo root) — the actual implementation; every action used
  above (`resolve`, `remember`, `remember-phase`, `create-space`, `create-folder`,
  `create-list`, `create-folderless-list`, `create-task`, `update-task`, `add-comment`,
  `push-plan`, `quick-add`)
- `scripts/clickup_project_map.json` (repo root) — the Space/Folder/List cache, shared
  across every project and every caller of this skill
- `references/clickup-api.md` (repo root) — raw ClickUp API reference: auth, endpoints,
  gotchas, everything verified live rather than assumed from docs
