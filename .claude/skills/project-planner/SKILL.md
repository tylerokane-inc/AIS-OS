---
name: project-planner
description: Use this whenever Tyler wants to plan or start building something new — an app, web app, mobile app, dashboard, plugin, connector, artifact, tool, or script. Trigger on things like "I want to build...", "help me plan...", "I have an idea for...", "let's start a new project," "I want to make an app/dashboard/plugin/connector," or any moment he's turning an idea into a real thing to ship. This runs a guided interview (10 core questions, then type-specific questions), teaches Tyler as it goes, sets up a clean pro folder on his Desktop, and produces a spec doc + build checklist so he starts every build from a bulletproof plan. Prefer this over jumping straight into building — the whole point is to get the idea fully on the table first.
argument-hint: [project idea]
---

# Project Planner

Tyler's launch pad. Any time he wants to build something, this is where he starts.
It takes a raw idea and turns it into a clear, buildable plan: everything on the table,
nothing crucial missing, organized in a folder he'd be proud to show on GitHub.

**The actual code gets built later in Claude Code.** This skill's job is the plan and the
folder setup — the "measure twice" before the "cut once."

**Auto-invocation is intentional here**, even though this skill has real side effects
(new folders, files, and ClickUp objects). Disabling that would break the whole premise —
catching Tyler before he jumps straight into building without a plan. The batched
questions and confirmation checkpoints at each step ARE the safety net; nothing gets
created without Tyler seeing and confirming it first.

## How Tyler wants this to feel

- **Batch the questions.** Ask as many relevant questions as you can in ONE response so Tyler
  answers in one shot. Only slow down and ask fewer, deeper questions on the core/main
  component of the project — the part that has to be right the first time.
- **Visuals only on request.** Do NOT auto-create visualizations — they cost tokens. Build a
  visual only when Tyler asks to see something. When he DOES ask, show a real laid-out example
  with a dummy dataset, not just words (e.g. a fake inbox, sample screen). Never make him
  picture an abstract word like "hybrid."
- **Teach as we go:** short "why" notes by default. When he says "explain deep," switch to
  full 12-year-old-beginner mode. See `references/teaching-guide.md`.
- **Top-down:** start broad (what/why/goal), then work into the details. Never dump everything at once.
- **Ship v1 fast:** always aim at the smallest useful version. Park extras for v2.

## The flow

Work through these in order. Don't skip ahead. Give a short why-note after each step.

### Step 1 — Kick off
If invoked directly with `$ARGUMENTS` (e.g. `/project-planner a workout tracker app`), treat
that as the starting idea and skip straight to confirming a working name and type from it.
Otherwise ask two quick things: a working name for the project, and which type it is
(app / dashboard / plugin / connector / other). A rough answer is fine — it can change.
**If Tyler doesn't know the type, that's normal — help him figure it out.** Read his rough
idea back in plain English, explain which type fits and why, and recommend one. Not knowing
the type is exactly the kind of thing this planner is here to solve.

### Step 2 — The 10 core questions
Open `references/core-questions.md` and ask all 10, in medium batches, with why-notes.
When done, play back a 3-4 sentence "Big Picture" summary and let Tyler confirm or fix it.

### Step 3 — Branch questions
Open `references/branch-questions.md`, pick the set that matches the build type, and ask it.
(If the project is a mix, run more than one set.) Summarize "How It's Built" back to him.

### Step 4 — Folder structure
Open `references/folder-structures.md`. Match the build type to a template, show Tyler the
tree, and explain 2-3 folders in plain English so he learns what "clean" looks like.

### Step 5 — Build the project folder + docs
Create a BRAND-NEW folder for this project, named after the project in kebab-case
(e.g. `workout-tracker`). Put it in the folder Tyler has connected (the working folder), OR
ask him where he wants it if that's unclear — don't bury it inside the planner's own folder.
Build the empty folder structure from Step 4 inside it. Then:
- Fill `templates/spec-doc.md` with all the answers → save as `docs/spec.md`
- Fill `templates/build-checklist.md` for this project → save as `docs/build-checklist.md`.
  **Write every checklist item in plain, beginner-friendly English, as a verb + one
  concrete deliverable** (see the "Task wording rule" at the top of the template) — say
  what to do in everyday words, not a jargon-heavy restatement of the spec, and never leave
  a vague theme or open question as if it were a task. Tyler should be able to read any
  single line and know exactly what to do without decoding it first.
  **Keep the numbered sections to as few as it takes to reach a usable version** — the
  template's `01: Discovery` / `02: Setup` / `03: Core` / `04: Usable` / `05: Ship` skeleton
  is the default; don't add more sections just because the spec has a lot of features.
  Section names stay short and plain — `01: Discovery`, never `V1 — Phase 0 — Discovery` —
  because that exact text becomes the ClickUp List name, and Tyler wants it skimmable at a
  glance, not cluttered with "V1"/"Phase" labels. Anything beyond the must-haves goes under
  `## Expansion: <name>` at the bottom instead, as its own section, so it's clearly parked
  for later, not part of the race to ship. Give every section a one-line Goal (already
  templated) so it can be pasted into a chat AI on its own and still make sense without the
  rest of the project.
  **Filling in 01: Discovery:** its question-subtasks are the one place vague-sounding
  lines are correct on purpose — they're literally open questions, not build tasks. For each
  one, check what the 10 core / branch-question interview already answered: if the interview
  covered it clearly, check the line off now AND append ` :: ` plus the short answer — e.g.
  `- [x] What does this need to connect to? :: ClickUp API, via clickup_push.ps1` —
  `push-plan` posts everything after `::` as a ClickUp **comment** and marks the task
  Complete; **the answer never goes in the task title itself**, only the question does, so
  the list stays clean. If it's a deeper technical unknown the interview didn't reach (exact
  endpoints, schema fields, which screen comes first), leave it as a plain `- [ ]` with no
  `::` — Tyler resolves those later by checking the box in ClickUp and leaving the answer as
  a comment there himself, right before he starts 02: Setup. Adapt the default topic tasks
  (Connectors & APIs, Data & Storage, Screens & Flow) to the project — drop "Screens & Flow"
  for a script/connector with no UI, add a topic if the project has one (e.g. "Automation &
  Triggers" for a plugin).
- Fill `templates/README.md` → save as `README.md` at the root
- Add a starter `.gitignore` and `.env.example` if the type needs them

### Step 6 — Push the plan to ClickUp
Use the **`clickup-push`** skill to turn `docs/build-checklist.md` into a live ClickUp
structure — that skill owns every detail of how (Folder/List/Task shape, naming, status,
comments, retries). This skill's only job here is to hand it the finished file; don't
duplicate its mechanics. If the push fails or the ClickUp home isn't known yet, that
skill's own instructions cover it — the spec and checklist files are already saved on
disk either way, so nothing is lost by a failed or deferred push.

### Step 7 — Hand off
Recap using this shape — short, no padding:
```
Project: <name> — <one-line what it is>
Folder:  <path>
Plan:    docs/spec.md, docs/build-checklist.md
ClickUp: <Folder link, or "skipped — <reason>">
```
Remind Tyler the build itself happens in Claude Code, pointed at `docs/spec.md` and
`docs/build-checklist.md`. Offer to refine any part.

## Rules

- One question theme per bullet — don't blur two questions together.
- Never invent Tyler's answers. If he's unsure, help him think, then capture HIS choice.
- Keep the spec doc as the single source of truth. Everything the build needs lives there.
- Each new project = its own new Desktop folder. Never mix two projects in one folder.
- Default to shipping the smallest useful version; write bigger ideas into the "nice-to-haves" list.
- **Safety for anything automated** (sorting, deleting, moving files/mail): when the tool is
  unsure, it should surface the item for review, never silently hide or delete it. Losing
  something real is far worse than showing one extra. Bake this into any auto-processing plan.

## What this skill explicitly does NOT do

Write actual code (that's Claude Code, later, pointed at the spec). Skip the interview
because Tyler seems eager to start — the whole reason this skill exists is to stop that
impulse and get the idea fully on the table first. Push to ClickUp before the checklist
exists on disk — the file is always the source of truth; ClickUp is a mirror of it.

## Files in this skill

- `references/core-questions.md` — the 10 universal questions + why each matters
- `references/branch-questions.md` — type-specific questions (app, dashboard, plugin, connector, other)
- `references/folder-structures.md` — pro folder templates + the golden rules of clean structure
- `references/teaching-guide.md` — how to teach (short why-notes + deep 12yo mode)
- `templates/spec-doc.md` — the project spec template
- `templates/build-checklist.md` — the step-by-step build checklist template
- `templates/README.md` — a GitHub-ready README template

ClickUp mechanics live entirely in the separate `clickup-push` skill (Step 6 hands off to
it) — this skill has no ClickUp-specific references of its own on purpose.
