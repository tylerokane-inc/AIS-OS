# Decisions Log

Append-only record of meaningful decisions and why they were made. `/level-up` Phase 2 (Method interview) writes scoped automation specs here. You can also append manually whenever you decide something worth remembering.

**Format per entry:**

```
## YYYY-MM-DD — Short title

**Decision:** what was decided.

**Why:** the reasoning, constraints, and what would change your mind.

**Alternatives considered:** what else was on the table.

**Owner:** who's accountable.
```

Keep it terse. Future-you will thank present-you for capturing the *why*, not just the *what*.

---

## 2026-07-23 — ClickUp API docs: grow on-demand, not upfront

**Decision:** `references/clickup-api.md` documents ClickUp endpoints only as
they get used in a real build, not the full ~150-endpoint API surface up
front.

**Why:** ClickUp API was chosen over its MCP server specifically for token
efficiency. Pre-documenting every endpoint group (Chat, Docs, Goals, Guests,
Time Tracking, Templates, etc.) would bloat the reference file with things
none of the 90-day priorities touch — the same token-bloat problem the
Obsidian pipeline priority is trying to avoid, just moved to this file.
Verified the fallback works: on a failed call, read the error body first (often
the real bug, as it was here — a whitespace issue reading `.env` in
PowerShell, not a docs gap); if it is a docs gap, fetch just that one
endpoint's page from developer.clickup.com and fix it. Converges to full
coverage of what's actually used, never a stale copy of what isn't.

**Alternatives considered:** Fetch and document every ClickUp endpoint group
up front for zero future research trips — rejected as premature completeness
that directly works against the stated goal of a token-efficient reference.

**Owner:** Tyler

---

## 2026-07-23 — Google Workspace: unified `gws` CLI over a dedicated Calendar MCP

**Decision:** Connected Calendar, Gmail, Drive, Sheets, and Docs through the
`gws` CLI (googleworkspace/cli) with one OAuth consent, instead of setting
up a dedicated Google Calendar MCP server.

**Why:** Google Calendar has no simple static personal token like ClickUp's
— it always requires full OAuth2, so the earlier MCP-vs-raw-API tradeoff
didn't map cleanly. `gws` solves it better than either original option: it's
a CLI (so zero tool-schema token cost, called directly via Bash/PowerShell,
same efficiency profile as the ClickUp raw-API approach) while also handling
OAuth token refresh and encrypted credential storage itself (the thing that
made hand-rolling raw API genuinely risky for Calendar specifically). One
consent screen granted Calendar + Gmail + Drive + Sheets + Docs scopes at
once — free to grant broadly since OAuth consent has no ongoing token cost,
unlike documentation bloat. Installed via manual binary download + SHA256
verification (not `npm install -g`) because the npm package's postinstall
script was blocked by this system's script-approval gate; verified the
script's actual contents first (checksummed download from the exact GitHub
Release, nothing else) before replicating it manually.

**Alternatives considered:** Dedicated `nspady/google-calendar-mcp` MCP
server (Calendar-only, would still need separate connectors for Gmail/Drive/
Sheets/Docs later) — rejected once a unified CLI covering all of them at
once was found. Official Google Workspace MCP — rejected, requires an
Enterprise/Pro/Max/Team Claude plan for the custom connector.

**Owner:** Tyler

---

## 2026-07-23 — ClickUp intake pipeline: project-planner moved in-repo, shared script, native subtasks

**Decision:** Moved the `project-planner` skill from an unregistered Desktop
folder into this repo at `.claude/skills/project-planner/` (local, not
global). Rewrote its Step 6 (ClickUp push) off the old MCP/connector-tool
stub onto a new shared PowerShell script, `scripts/clickup_push.ps1`, which
both `project-planner` (full build-checklist push) and a new lightweight
`clickup-capture` skill (casual one-off task mentions) call for every
ClickUp write. Step-by-step plan items are pushed as native ClickUp
subtasks (the `parent` field on task-create), not ClickUp Checklists.
Hierarchy (Space/Folder/List) has no fixed default — the pipeline asks
Tyler where a new project belongs the first time only, then caches the
answer in `scripts/clickup_project_map.json` and never asks again for that
project.

**Why:** `project-planner` wasn't actually discoverable by Claude Code at
all before this (a loose Desktop folder, not wired into any skills
directory), so despite Tyler thinking he "had" this skill, it couldn't
trigger. Its ClickUp step also assumed an MCP-style connector with vague
tool-name discovery and no real auth handling — inconsistent with the
direct-API-via-token pattern already proven working elsewhere in this repo
(`references/clickup-api.md`). Splitting the ClickUp-push logic into one
shared script (instead of duplicating it inside project-planner alone)
means casual task mentions in normal conversation get captured as easily as
full project builds, matching Tyler's stated pain point: "taking in any
information that I give to you that has anything to do with doing a task or
a project" and pushing it into ClickUp, not just formal new-build planning
sessions. Native subtasks were chosen over Checklists because the
create-task endpoint (with its `parent` field) was already documented and
verified in this repo — no new endpoint research needed, ships faster,
which matched Tyler's explicit priority: "push it as fast as possible" and
iterate from there rather than build the deepest possible version up front.
The script is PowerShell, not Python, because Python isn't installed on
this machine (Windows Store stub only) while Windows PowerShell 5.1 is
already the repo's primary shell and already proved out the working ClickUp
auth calls documented in `clickup-api.md` — `EXPANSIONS.md`'s "Python or
Bash" guidance for `scripts/` is satisfied by PowerShell as this machine's
native equivalent, at zero install cost.

**Alternatives considered:** Installing `project-planner` as a global skill
(usable from any repo) — rejected per Tyler's explicit call, kept local
since ClickUp task tracking is tied to this repo's connections. Installing
Python to match `EXPANSIONS.md`'s literal wording — rejected for v1 given
the setup detour it would add before any real ClickUp work could start;
Tyler can revisit if `scripts/` grows Python-heavy later. ClickUp Checklists
API for step-by-step items — rejected for v1, explicitly parked as
possible v2 since it needs new, currently-undocumented endpoint research.
A fixed default Space/Folder/List hierarchy decided up front — rejected
since the workspace was completely empty with nothing to base a default on;
ask-once-and-remember was judged more honest than guessing a structure
Tyler would just have to undo.

**Owner:** Tyler

---

## 2026-07-24 — ClickUp structure reversed: Folder-per-project + List-per-phase, not parent-Task/subtasks

**Decision:** Reversed this pipeline's core ClickUp shape after a real test run.
The 2026-07-23 design (one parent Task per project, one native ClickUp subtask
per checklist item) is replaced with: one **Folder per project** (created
directly in the Space, not inside a shared "Builds" bucket), one **List per
phase** inside that Folder, one plain **Task per step** inside its phase's
List. `scripts/clickup_push.ps1`'s `push-checklist` action (parent
Task + subtasks) was deleted and replaced with `push-plan` (Folder/List/Task).
Checklist item wording was also rewritten from technical spec-language into
plain, beginner-friendly English.

**Why:** Tested the pipeline for real against Tyler's actual, very deep
Personal Trainer App plan — 139 real action items across 16 phases, pulled
from `C:\Users\User\Desktop\Fitness App Build` (read-only, nothing there was
touched). The subtask design worked mechanically (all 139 pushed
successfully) but Tyler's direct feedback after seeing it live: "that's way
too much clutter in subtasks... all of content readiness should be together.
Every phase should be together... instead of clicking into a new task every
time." A single parent Task with 139 subtasks required opening that one task
and scrolling a subtask panel to see anything — it didn't let him see a whole
phase at a glance. He also wants each item in plain English he can act on
without decoding jargon, and specified the fix himself: "in personal
projects, each folder would be the build... all the phases would go inside
of the folder all grouped together by their phase." A List's normal ClickUp
view already shows every Task in it together, in order, with inline status
— so List-per-phase solves "grouped together, step-by-step, no extra clicks"
using endpoints already needed elsewhere, with no new API surface. This is
now the standing default for every future `project-planner` push, not a
one-off fix for this project.

**Alternatives considered:** ClickUp Checklists (one checklist per phase,
attached to a single parent Task) — verified live and confirmed working
(`POST /task/{id}/checklist`, `POST /checklist/{id}/checklist_item`), and
briefly considered as the fix mid-session before Tyler's own hierarchy
description made List-per-phase the clearer answer. Checklists remain a
documented, working option in `references/clickup-api.md` if a future need
(sub-items *within* one Task, rather than a whole phase) calls for them, but
were dropped here to avoid maintaining two parallel hierarchy mechanisms.
Keeping the old parent-Task/subtask model and just improving its labeling —
rejected; the core complaint was structural (too many clicks to see a
phase), not cosmetic.

**Owner:** Tyler

---

## 2026-07-24 — Claude's default communication style: plain English, skimmable, and repo-aware

**Decision:** Added three standing rules to `CLAUDE.md`'s "How you work with
me" section: (1) explain technical terms in plain English by default, as if
to a beginner with zero background — not just when Tyler flags confusion;
(2) structure any response with more than one idea into headers/bullets
instead of dense paragraphs, reserving visuals/diagrams for when Tyler
explicitly asks to "see it visually"; (3) whenever a new file or folder gets
created in this repo, explain in plain English what it is and why it's
going there. Also created `references/repo-map.md`, a beginner-friendly
companion to the more technical `EXPANSIONS.md`, explaining every folder in
plain language with real examples from this repo.

**Why:** Tyler said he was struggling to read and follow Claude's output —
technical terms went unexplained, responses felt jumbled instead of
skimmable, and he didn't understand why files/folders landed where they did
(risking future clutter he wouldn't know how to fix). He wants to actually
learn the system over time, not just have Claude remember it for him.

**Alternatives considered:** Plain-English mode only on request (Tyler
flags confusion, Claude switches) — rejected; he wants it as the default,
not opt-in per message. Folding the beginner folder explanations into
`EXPANSIONS.md` directly instead of a new file — rejected; Tyler asked for
a separate standalone beginner file, keeping `EXPANSIONS.md` as the more
technical reference to graduate to later.

**Owner:** Tyler

---

## 2026-07-24 — ClickUp checklist rewording, V1/Expansion split, and incremental push-plan

**Decision:** Rewrote `templates/build-checklist.md` and the `project-planner` skill
around three rules: (1) every checklist line must be a verb + one concrete deliverable —
a "Task wording rule" with a bad/good example now sits at the top of the template so the
pattern transfers to every project; (2) phases split into two explicit tiers, `## V1 —
Phase N — <name>` (kept to the smallest set that reaches a usable version) and `##
Expansion — <name>` (parked features, added anytime later) — the prefix becomes the
ClickUp List name, so the two tiers stay visually separated inside one Folder without a
second Folder; (3) a task can carry indented sub-steps that push as native ClickUp
**subtasks of that one task** (not of a phase) via `New-ClickUpTask -Parent`.
`scripts/clickup_push.ps1`'s `push-plan` action was rewritten to be incremental: a phase
already in the cached `phases` map is skipped entirely on re-run (no re-created lists, no
duplicate tasks), so a new `## Expansion —` phase can be appended to
`docs/build-checklist.md` weeks after V1 ships and pushed with the same command, touching
only what's new. The old `plan_pushed` all-or-nothing guard (added 2026-07-23) was removed
since per-phase skip logic supersedes it. Verified live against a disposable
`skill-test-dummy` Folder in the "Projects" Space: first push created 2 Lists / 5 Tasks
(with a real subtask pair under one parent Task); an unchanged re-run skipped all 5 with 0
duplicates; appending a third `## Expansion —` phase and re-running created only that
phase's 1 List / 1 Task, leaving the first 5 untouched.

**Why:** Direct feedback reviewing the live Personal Trainer App push (16 phases, several
of them pre-build planning phases like "Planning How to Test It" before any building
started, and item wording like "pick one short tip for how to do each main exercise
correctly" that reads as a question, not a task): "there's no way that I would... that's
not really a task," plus "everything should be focused on pushing as fast as possible at
the start" with "a minimal amount of phases to get to that version one," and an
"expansion type thing where it's like it gets more detailed over time." He also wants to
paste one phase into a chat AI (ChatGPT/Claude) while away from this repo and get it
detailed enough to build from when he's back — hence each phase now carries a one-line
Goal so it's self-contained enough to hand off alone. The subtask question ("we can use
subtasks for... not for each phase, but—") was resolved narrowly: subtasks stayed banned
for whole phases (that was the explicit, tested reason the original parent-Task/subtask
design got reversed on 2026-07-24 above), but are now allowed under one specific task for
its own small steps, which doesn't reintroduce the "139 clickable tasks, can't see a phase
at a glance" problem that caused the original reversal.

**Alternatives considered:** A second Folder per tier (`project-name` / `project-name —
expansion`) instead of a List-name prefix inside one Folder — rejected, adds a second
cached `folder_id` per project for no real gain over a naming convention the push script
already supports for free. Keeping the `plan_pushed` hard guard and adding a separate
"push just this new phase" action — rejected as more surface area than needed once
per-phase skip logic makes the whole file re-runnable safely by default.

**Owner:** Tyler

---

## 2026-07-24 — Discovery phase added; two parsing bugs found and fixed; Folder color confirmed unsupported; Personal Trainer App migrated live

**Decision:** Four follow-ups to the same-day ClickUp redesign above, found while building
and testing it for real:

1. **Added `V1 — Phase 0 — Discovery`** to the build-checklist template: a fixed phase
   whose Tasks are topics (Connectors & APIs, Data & Storage, Screens & Flow — adapt per
   project) and whose subtasks are literal open questions, checked off with the answer left
   as a ClickUp **comment**. Every Discovery task checked = the one clear "ready to build"
   marker Tyler asked for. Project-planner's interview answers get pre-filled inline
   (checked, answer in the line) rather than re-asked.
2. **Two push-plan parsing bugs found via live testing, both fixed:** (a) the template used
   `###` for individual phases and `##` for the "V1"/"Expansion" umbrella dividers, but the
   script only ever recognized `##` — so real phases were silently invisible and the umbrella
   dividers became the actual (wrong) Lists. Fixed by making every real phase a `##` line and
   demoting all divider/prose headings (including the template's own "Task wording rule") to
   bold text, never `##`. (b) fenced code blocks (the template's own subtask-syntax example)
   were scanned like any other line, so the example itself got pushed as a fake phase/tasks.
   Fixed by making `push-plan` skip everything between a pair of `` ``` `` lines. Both bugs
   were caught by pushing to a disposable `skill-test-dummy` Folder before touching anything
   real, confirmed clean on a final rerun (6 Lists, 29 tasks, 0 stray Lists), and confirmed
   again on the real migration in point 4 below.
3. **Folder color: tried, confirmed unsupported by the API.** Tyler's actual ask was the
   project **Folder** icon turning yellow (not the phase Lists — an earlier misread). Tested
   live: POSTing both a `color` and a `status` field to `create-folder` returns success with
   neither field ever applied — ClickUp's v2 API has no Folder color field at all. Lists *do*
   support color via `status` (confirmed: `"yellow"` works, returns `#f8ae00`; arbitrary hex
   fails), but nothing sets it automatically now — Tyler said leave Lists gray for now, floated
   green/red per phase as a future idea, not built.
4. **Migrated the real Personal Trainer App** (139 tasks, the original 16-phase project this
   whole redesign was tested against) into the new shape. Read all of Tyler's existing planning
   docs at `Desktop/Fitness App Build/docs/` (product-spec, decision-register, v1-scope,
   database-schema, ui-screen-outline, technical-architecture, build-readiness,
   content-readiness) to fill Discovery with real answers instead of placeholders — most of
   Connectors/Data/Screens was already decided (this app is local-first, zero external
   connections by design), what's genuinely still open (framework/hosting/PWA pick, a few
   content items) came straight from Tyler's own build-readiness.md checklist. Deleted the old
   16 Lists and pushed 8 new ones (Discovery + 4 V1 phases + 3 Expansion phases) with all 139
   original tasks preserved and regrouped, plus 2 tasks moved (Boxing/Posture library-sorting,
   out of the old "Exercise Library" phase into their own Expansion phases, since Boxing/Posture
   are Expansion per Tyler's own v1-scope.md). Verified zero tasks were started/completed before
   the delete (safe rewrite, nothing lost). A full reviewable draft was written to
   `Desktop/Fitness App Build/docs/00-overview/clickup-build-checklist.md` and Tyler reviewed it
   before the live push happened.

**Why:** All four came from direct testing/feedback in the same working session as the
decision above. Discovery: Tyler's explicit ask, described as "if I answer all these
questions... I'd know I have all the info needed for the first push." The two parsing bugs
were not requested — they were caught only because the new template was tested against a live
disposable Folder before being trusted with real data, which is exactly why that step exists.
Folder color: don't guess API capabilities from docs alone — verify empirically, this repo's
standing policy in `references/clickup-api.md`. Personal Trainer App migration: Tyler asked
directly, "take all the information from the Personal Trainer app and set it up... show me
exactly what we have, what direction we can go after version one" — the whole point of today's
redesign was to fix the exact project that had prompted the complaint in the first place.

**Alternatives considered:** Rewording the Personal Trainer App's existing 139 task titles
while regrouping them — rejected after sampling several; the wording was already plain-English
verb+deliverable (the "pick one short tip" complaint that started this session turned out to be
a Discovery-shaped item, not representative of the other 138). Keeping the 24
"write a test for X" items as their own pre-build phase — rejected, moved into Ship instead,
since writing tests before any code exists worked against "push fast, minimal phases."

**Owner:** Tyler

---

## 2026-07-24 — Own GitHub repo created; Nate Herk IP inventoried for future de-branding

**Decision:** Repo's `origin` remote moved off `nateherkai/AIS-OS` (the template
creator's repo) to a new private repo, `tylerokane-inc/AIS-OS` on GitHub, and
existing commit history pushed there. This is treated as a learning-phase
workspace, not a resale-ready product — a full inventory of every file
carrying Nate Herk's specific IP (trademarked framework names, copyright
notices, or his brand/community references) was taken so a future
de-branding pass has a concrete checklist instead of a memory-based guess.

**Why:** Tyler's stated plan: use this repo to learn how Nate Herk structured
an AIOS (decision logging, CLAUDE.md conventions, skill architecture), then
build his own original, sellable spinoff later — stripping Nate Herk's
specific IP out first. Disconnecting the GitHub remote only changes hosting,
not IP status, so the actual content was audited. Two separate legal layers
found:
- **Copyright (code/content):** repo is MIT-licensed (`LICENSE`, Nate Herk
  copyright 2026) — permissive, allows use/modify/distribute/**sell**,
  provided the copyright + permission notice ships with any copy that uses
  "substantial portions" of the original.
- **Trademark (names):** "The Three Ms of AI™" and "The Four Cs of an
  AIOS™" are explicitly carved out of the MIT grant as Nate Herk's
  trademarks — `README.md` says outright: "Use freely; don't repackage as
  your own." These can't be used to brand/market a competing product
  regardless of the MIT license.

**Files carrying Nate Herk's specific IP** (trademark names, copyright
lines, or brand/community references — found via repo-wide search for
"Nate Herk," "trademark," "©," "Three Ms," "Four Cs," "™"):

1. `LICENSE` — copyright holder (Nate Herk, 2026); explicit trademark
   carve-out for "The Three Ms of AI™"
2. `README.md` — both trademark notices (Three Ms + Four Cs), the AIS-OS
   acronym tied to his specific community ("AI Automation Society"), and
   the explicit "don't repackage as your own" instruction
3. `CLAUDE.md` — Three Ms trademark line
4. `references/3ms-framework.md` — the Three Ms methodology content itself
5. `.claude/skills/onboard/SKILL.md` — "Adapted from The Three Ms of AI™"
   attribution line
6. `.claude/skills/level-up/SKILL.md` — Three Ms trademark lines *and* an
   "All rights reserved" line that reads stricter than the repo's MIT
   license — worth clarifying before reuse, not just assuming MIT covers
   it; the skill's whole Mindset→Method→Machine structure **is** the Three
   Ms framework
7. `.claude/skills/audit/SKILL.md` — no explicit trademark line in the
   file, but the entire scoring mechanic (25 pts × 4 = 100) **is** his Four
   Cs framework — flagged structurally, not just textually

**Checklist for the future de-branding pass (before anything is sold):**

- [ ] Rename "AIS-OS" to Tyler's own product name (not a trademark, but
  tied directly to Nate Herk's community — "AI Automation Society OS")
- [ ] Replace/rewrite `references/3ms-framework.md` content with Tyler's
  own operator framework, or drop it
- [ ] Rewrite `.claude/skills/level-up/SKILL.md`'s Mindset→Method→Machine
  structure into Tyler's own naming/flow
- [ ] Rewrite `.claude/skills/audit/SKILL.md`'s Four Cs scoring into
  Tyler's own audit categories
- [ ] Remove all trademark/copyright lines referencing Nate Herk from
  `README.md`, `CLAUDE.md`, `LICENSE`, `onboard/SKILL.md`,
  `level-up/SKILL.md`
- [ ] Replace `LICENSE` with Tyler's own license once no MIT-covered
  "substantial portions" of the original remain
- [ ] Re-run this same repo-wide search (`Nate Herk|trademark|©|Three
  Ms|Four Cs|™`) as a final check — confirm zero matches before calling it
  clean
- [ ] If any doubt remains on the "All rights reserved" line in
  `level-up/SKILL.md` vs. the repo's MIT license, get real legal advice
  before selling — this log is not that

**Alternatives considered:** Skipping the audit and just deleting the
trademark lines when the time comes — rejected; Tyler asked for the
checklist now, while the files are freshly identified, rather than
re-discovering them cold in the future. Treating the MIT license as
blanket permission to sell as-is — rejected; the trademark carve-out and
the README's explicit "don't repackage" instruction override that for the
two named frameworks specifically.

**Owner:** Tyler

---

## 2026-07-24 — Comments for answers, checkbox-driven status, short List names, and a dedicated `clickup-push` skill

**Decision:** Four more same-day follow-ups after seeing the live migration above:

1. **Discovery answers moved from inline task-title text into ClickUp comments.** Added a
   ` :: ` line syntax to `push-plan`: `- [x] Question? :: Answer text` creates a task
   titled just `Question?`, marks it Complete, and posts `Answer text` as that task's
   first comment (`POST /task/{id}/comment`). Retrofitted the 8 already-pushed Personal
   Trainer App Discovery subtasks that had inline `(...)` answers baked into their titles
   — stripped the titles, posted the same text as comments, marked them and their 2 fully-
   resolved parent topics Complete.
2. **Checkbox state now sets ClickUp status on create.** `- [ ]` → "to do" (unchanged);
   `- [x]`/`- [X]` → "complete". Previously the checkbox in the markdown file was purely
   cosmetic and never reached ClickUp at all.
3. **Custom status ("In Progress") tested and confirmed not settable via the API.**
   `PUT /space/{id}` with a `statuses` array containing "in progress" returns success with
   the array silently unchanged — same silent-ignore pattern as Folder color. A Space
   starts with only "to do"/"complete". Tyler needs to add "In Progress" himself once in
   the ClickUp app (Space Settings → ClickApps → Statuses); every task pushed afterward
   picks up whatever workflow is active automatically.
4. **List names simplified.** Tyler manually renamed a few Lists in the ClickUp UI as a
   live example (`01: Discovery`, `02: Setup`, `03: Core`) and said the old
   `V1 — Phase 0 — Discovery` style was "too much." Template and script both switched to
   plain `NN: Name` for the numbered build sections and `Expansion: Name` for parked
   features — this exact text is the literal `##` line the script turns into a List name,
   so the fix was content-only, no script logic change. Renamed all 8 live Lists in the
   Personal Trainer App Folder to match.
5. **Split ClickUp mechanics out of `project-planner` into a new standalone `clickup-push`
   skill.** Tyler: `project-planner` should be "the higher layer" that only plans, and
   should hand off to a dedicated ClickUp skill with one line rather than embedding push
   mechanics itself. Created `.claude/skills/clickup-push/` (Mode A: full structured plan,
   what `project-planner` calls; Mode B: single task/quick-add, what `clickup-capture`
   calls) holding everything that used to live in `project-planner/references/
  clickup-export.md` (now deleted) plus `clickup-capture`'s inline resolve/quick-add flow
  (now trimmed to a hand-off). `project-planner`'s Step 6 and `clickup-capture`'s flow are
  now one paragraph each pointing at `clickup-push`; neither talks to the ClickUp API or
  `scripts/clickup_push.ps1` directly anymore. The shared script and cache
  (`scripts/clickup_push.ps1`, `scripts/clickup_project_map.json`) didn't move — this was
  a skill/instruction-layer reorg, not a file reorg.

**Why:** All five are direct, same-session feedback. Comments-not-titles and
checkbox-status: "I don't know how it's gonna work, but I'd like them to go on comments...
keep everything clean" plus wanting real to-do/in-progress/completed tracking so tasks can
eventually feed a daily-planning/calendar view (Tyler's stated end goal, tied to this
AIOS's Priority 1 — not built yet, flagged as a follow-up rather than guessed at). List
naming: direct example shown via a live screenshot of his own manual rename. Skill split:
Tyler wants any future project pushed to ClickUp to go through one consistent, reusable
skill rather than re-deriving push logic inside whichever skill happens to be planning
that day — "we're not just gonna have it listed inside of the project planner skill...
it's gonna refer to or run" the ClickUp skill.

**Alternatives considered:** Assigning due dates to the Personal Trainer App's 150 tasks
today — deferred; picking real dates for 150 tasks is a scheduling decision, not a
formatting one, and belongs with the not-yet-built daily-planning/Calendar↔ClickUp
priority rather than being invented here. Keeping `clickup-export.md` alongside the new
`clickup-push` skill for backward reference — rejected, two files describing the same
mechanics is exactly the duplication Tyler asked to remove; the skill is now the single
source of truth.

**Owner:** Tyler

---

## 2026-07-24 — Language default for future builds: Python for automation, TypeScript for interfaces

**Decision:** No language is chosen for this repo itself (it's Markdown + Claude Code
skills, not compiled code — see the 07-23 `scripts/` entry above for why PowerShell
handles the one script that exists today). As a standing default for *future* builds
kicked off via `/project-planner`: background automation/backend logic (e.g. an Obsidian
auto-sorter, an API glue-script) defaults to Python; anything with a visible interface
(e.g. the trading dashboard) defaults to TypeScript. The actual pick still happens per-
project inside `/project-planner`, not here — this just sets the default lean.

**Why:** Tyler asked to log this after a plain-English explainer on why Python tends to
win for AI/automation work (simpler syntax, dominant AI/scripting ecosystem) while
TypeScript tends to win for web interfaces — so the reasoning doesn't get re-explained
from scratch next time a project's language comes up.

**Alternatives considered:** None — this is a default lean to speed up future
`/project-planner` runs, not a binding rule; a project's actual constraints (e.g. no
Python installed on this machine yet, per the 07-23 entry) can still override it.

**Owner:** Tyler

---

## 2026-07-26 — Obsidian knowledge system shipped; Project Builder skill created; `03-Notes` reorganized

**Decision:** Built the Obsidian knowledge-system project (spec at `Obsidian_Vault\
02-Projects\Obsidian Operating System\01-Plan.md`) live, then used that same build as the
worked example to design a new skill, `project-builder` — the execution phase that picks up
a finished `project-planner` spec and actually ships it, distinct from planning itself.
Several sub-decisions came out of the same session:

1. **Two new skills built and tested:** `obsidian-organizer` (filing pass + priority check,
   now also owns `01-Inbox\` as a general capture front-door) and `obsidian-context`
   (read-only, strict no-weak-match rule). Both read/write the vault directly — no API.
   The 11pm nightly auto-filing trigger from the original spec was deliberately deferred —
   manual-only until proven, to be wired via `/schedule` later.
2. **`project-builder` created** with three explicit rules from Tyler: (a) never
   auto-continues right after `project-planner` finishes — building is always a separate,
   deliberate decision; (b) asks up front whether a build is crucial/day-to-day
   infrastructure (phase-by-phase pause + review + 1-2 improvement ideas each phase) or
   simpler (straight through to one final report); (c) every project's docs ship as a
   folder (`00-INDEX.md` + a portable, unedited `01-Plan.md` + a `02-How-It-Works.md`
   written after the build, including a skill's real frontmatter verbatim) — matches the
   existing `Swimming Pool App` convention, first applied to the Obsidian project itself.
   ClickUp-sync-on-ship was designed but is **blocked**: `clickup-push`'s `push-plan` has no
   way yet to persist a step→task-ID map for later lookup — flagged in the skill file, not
   built.
3. **`03-Notes` reorganized.** Tyler didn't like the `Life/`/`AI-Builds/` umbrella split —
   too nested, not specific enough. Replaced with direct top-level categories:
   `Business/`, `Health/`, `Personal/`, `Build-Ideas/` (renamed from `AI-Builds`), and
   `Templates/` pulled out on its own since it's live infrastructure (the actual daily-note
   template), not personal reference. New categories get added directly under `03-Notes/`
   going forward, no umbrella reintroduced. Fixed three files that had picked up an
   accidental doubled `.md.md` extension along the way.
4. **Two live Obsidian config bugs found and fixed** while working: `.obsidian/
   daily-notes.json` still pointed at pre-rename folder/template paths from before the
   vault restructure, and the daily-note template had a redundant `# {{date}}` heading
   duplicating Obsidian's automatic filename-based title. `obsidian-organizer` now reads
   that config live at runtime instead of hardcoding a date format, since Tyler already
   changed the format once mid-session (`YYYY-MM-DD` → `MM-DD-YYYY`).

**Why:** Same instinct as the `project-planner` skill upgrades earlier — Tyler wanted to
run a real build, then extract a reusable process from it rather than just shipping one
artifact. The phase-by-phase pacing came from his own framing directly: "it's not about
being quick, it's about building things right the first time." The `03-Notes` reorg and
config fixes surfaced naturally while actually using the finished system, not from a review
pass — exactly the kind of thing a real dry-run catches that planning alone wouldn't.

**Alternatives considered:** Auto-continuing from `project-planner` straight into
`project-builder` in one flow — rejected, Tyler wants planning and building kept as two
separate, deliberate decisions. A single flat pacing mode (always paused or always
straight-through) — rejected in favor of a stakes-scaled toggle, since Tyler explicitly
distinguished "crucial" builds from routine ones. Keeping `Life`/`AI-Builds` as umbrella
folders and just renaming them — rejected; the core complaint was structural nesting depth,
not naming.

**Owner:** Tyler

---

## 2026-07-25 — BillTrack `wrangler.jsonc` renamed to match Cloudflare Worker

**Decision:** Updated `wrangler.jsonc` in the separate `BillTrack` project
(`C:\Users\User\Desktop\BillTrack`, its own repo at
`github.com/tylerokane-inc/BillTrack`, not part of this AIOS repo) — changed
`"name": "subtracker"` to `"name": "billtrack"` to match the Worker's new
name on the Cloudflare dashboard, then committed and pushed directly to
`master`.

**Why:** Tyler renamed the Worker in Cloudflare's UI, which doesn't sync
back into the repo's config automatically — Cloudflare flagged the mismatch
with a banner suggesting the config update. Tyler tried to do this push
himself first but a Git tool prompted him to create a new branch, which
looked wrong, so he backed out and asked Claude to do it instead. The repo
was already clean and in sync with `origin/master`, so no branch was
actually needed — just edit, commit, push to the existing branch.

**Alternatives considered:** None — single-line config fix, direct push to
`master` was correct since there was no divergence to reconcile.

**Owner:** Tyler
