---
name: project-planner
description: Use this whenever Tyler wants to plan or start building something new — an app, web app, mobile app, dashboard, plugin, connector, internal Claude Code skill/automation, artifact, tool, or script. Trigger on things like "I want to build...", "help me plan...", "I have an idea for...", "let's start a new project," "I want to make an app/dashboard/plugin/connector/skill," or any moment he's turning an idea into a real thing to ship. This runs a guided interview (10 core questions, type-specific questions, plus feature questions grounded in research on comparable existing products) that keeps going until Tyler says it's enough, teaches him as it goes, works out where the finished plan should actually live, and produces a spec doc + build checklist so he starts every build from a bulletproof plan. Never proceeds into an actual build itself — that's a separate, explicit ask. Prefer this over jumping straight into building — the whole point is to get the idea fully on the table first.
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
  **Exception — Claude Code skill / internal automation builds:** these ship fully
  functional from the start, not staged. Tyler's own words (2026-07-27, building
  `web-scrape`): "For skills, we don't want the smallest thing that we can use. We want
  a fully functioning working skill. v1's only apply to projects like apps, connectors,
  plugins... Skills, we want to work straight from the start." Don't split a skill's
  must-haves into a v1 + parked "nice-to-haves" — everything genuinely part of the skill's
  job ships together. The must/nice-to-have split in the 10 core questions still surfaces
  real scope questions during planning, but for this build type the answer folds
  differently: things that turn out to be must-haves for the skill to actually do its job
  well all ship in the one build, not staged into a v2.

## The flow

Work through these in order. Don't skip ahead. Give a short why-note after each step.

### Step 1 — Kick off
If invoked directly with `$ARGUMENTS` (e.g. `/project-planner a workout tracker app`), treat
that as the starting idea and skip straight to confirming a working name and type from it.
Otherwise ask two quick things: a working name for the project, and which type it is
(app / dashboard / plugin / connector / Claude Code skill / other). A rough answer is fine —
it can change.
**If Tyler doesn't know the type, that's normal — help him figure it out.** Read his rough
idea back in plain English, explain which type fits and why, and recommend one. Not knowing
the type is exactly the kind of thing this planner is here to solve.

### Step 2 — The 10 core questions
Open `references/core-questions.md` and ask all 10, in medium batches, with why-notes.
When done, play back a 3-4 sentence "Big Picture" summary and let Tyler confirm or fix it.

### Step 2.5 — Competitive research (when it applies)
Check whether this project has real-world comparables — existing apps, tools, or websites
people already use for roughly this job. True for most apps, dashboards, plugins, and
connectors. Not true for an internal Claude Code skill/automation, a personal
information-structure/organization system, or anything Tyler describes as genuinely novel.
When unsure, ask him in one line rather than guessing.

When it applies:
1. Tell Tyler what's about to happen and why, briefly: research the popular existing
   options in this space first, so the feature questions in Step 3 are grounded in real
   precedent instead of a blank "what features do you want."
2. Spin up a subagent (`Agent` tool) that uses the **`web-scrape`** skill to research the
   3-5 most popular/well-known existing products for this specific job (use Step 2's Big
   Picture — the what/who/problem answers, not just the project's working name — to target
   the research). Have it identify, for each: the core features every one of them has
   (table stakes), the features that genuinely differ between them (real choices worth
   asking Tyler about), and any options/settings they expose he might not have thought to
   ask for. Use Firecrawl on a specific feature/pricing page only if Exa's own highlights
   don't already answer it.
3. Per `web-scrape`'s own rule, the subagent returns a synthesized brief with sources —
   never a raw dump. Read it back to Tyler in 3-5 sentences (not the full brief unless he
   asks to see it): what's standard, what's optional, and anything genuinely surprising.
4. Carry it into Step 3: where a branch question touches a feature the research covered,
   present the real options surfaced ("most apps handle onboarding with A or B — which
   fits how you'd use this?") instead of a blank open question.

If the research comes back thin or ambiguous, say so plainly (per `web-scrape`'s own safety
bar) and fall back to Tyler's own instincts rather than presenting weak findings as settled.
Skip this step entirely, with a one-line reason, for skill/automation and
information-structure projects, or any time Tyler says he already knows what he wants and
doesn't want the detour.

### Step 3 — Branch questions
Open `references/branch-questions.md`, pick the set that matches the build type, and ask it
— folding in Step 2.5's research where relevant. (If the project is a mix, run more than one
set.) Summarize "How It's Built" back to him.

### Step 3.5 — Keep going, or call it enough?
Don't assume the interview is done just because the fixed lists ran out. The 10 core +
branch questions are a floor, not a ceiling. Ask Tyler directly whether this feels complete
or there's more worth digging into. This resolves one of three ways:
- **Tyler says something like "that's enough" / "I think we've got enough" / "let's
  move on"** → proceed to Step 4.
- **Tyler asks for "N more questions"** (e.g. "give me five more, only five") → identify
  exactly the N biggest remaining gaps — the open questions most likely to bite mid-build,
  not just whatever's left on a checklist — ask exactly that many, no more, then proceed to
  Step 4 regardless of how complete it feels afterward. Never quietly slip in one extra past
  the number he set.
- **Tyler keeps raising things, or doesn't say to stop** → keep going. Surface the
  next-most-valuable open question(s) yourself rather than treating the fixed lists as a
  hard ceiling. This can run multiple rounds.
This is Tyler's call every time — never silently decide "that's enough" and jump to Step 4
on the planner's own initiative.

### Step 4 — Folder structure
Open `references/folder-structures.md`. If the deliverable is CODE (app, dashboard, plugin,
connector, script), match the build type to a template, show Tyler the tree, and explain 2-3
folders in plain English so he learns what "clean" looks like.

If the deliverable is an INFORMATION STRUCTURE instead — the project's main output is an
organization system (a vault, a notes system, an archive) rather than code — do NOT reach for
a code template and do NOT default to reusing a structure built for a past project (e.g.
Obsidian's `Daily/Inbox/Projects/Notes/Archive` shape is specific to that project's job, not a
universal default). Design it fresh each time with Tyler: what are the natural categories this
information falls into, how does new stuff enter, and how does he find it again later. Show
the resulting tree and explain the reasoning the same way.

### Step 4.5 — Where does this actually live?
Ask Tyler directly, don't assume: does this project get its own **new Desktop folder**
(default for a standalone app/dashboard/tool), or does it belong **inside something that
already exists** — e.g. as a new skill under this repo's `.claude/skills/` (for a Claude Code
skill/internal automation type), with its spec/checklist docs filed into Obsidian's
`02-Projects/` instead of living in this repo or on the Desktop, once Obsidian is set up.
This repo (the AIOS itself) stays the operating system — skills and how-to-work info only.
It does not hold per-project spec docs, build checklists, or deep project content — that's
what Obsidian is for. Confirm the answer before Step 5.

### Step 5 — Build the project folder + docs
Based on Step 4.5's answer, either:
- Create a BRAND-NEW folder for this project, named after the project in kebab-case
  (e.g. `workout-tracker`), in the folder Tyler has connected (the working folder), OR
- Create the new skill folder under `.claude/skills/<skill-name>/` in this repo (code/logic
  only) AND place the docs at the Obsidian location Tyler confirmed (e.g.
  `02-Projects/<name>.md`) instead of a `docs/` folder in this repo.
Don't bury either one inside the planner's own folder. Build the empty folder structure from
Step 4 inside it. Then:
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

- **Never hand off into an actual build.** This skill's job ends at a finished spec +
  checklist on disk (and optionally pushed to ClickUp) — it never proceeds to
  `project-builder` or writes real project code on its own initiative, even if Tyler seems
  eager to start building right after the plan is done. Building only happens when Tyler
  separately, explicitly says so in a new request — "let's build it," not just silence
  after the plan lands.
- One question theme per bullet — don't blur two questions together.
- Never invent Tyler's answers. If he's unsure, help him think, then capture HIS choice.
- Keep the spec doc as the single source of truth. Everything the build needs lives there.
- Each new project gets its own home — its own new Desktop folder, or its own Obsidian
  project note/folder once that's where docs are routing. Never mix two projects in one
  folder or note. This repo holds skills and operating info, not project docs.
- Default to shipping the smallest useful version; write bigger ideas into the "nice-to-haves" list. **Except Claude Code skill/internal automation builds — those ship complete, see the "Ship v1 fast" exception above.**
- **First build caps out at 3 core features, max** (apps/dashboards/plugins/connectors — same skill exception as above). A hard ceiling on the must-have list, not a target to hit. See `references/core-questions.md` Q7.
- **Prioritize free APIs/connections; verify before locking one in.** When a project needs
  an outside service, default to genuinely free options over paid ones — cheap only if
  nothing free covers the need. Never take a provider's "free tier" claim at face value:
  check their *current* pricing page for the *specific endpoint* the project needs (not a
  general "has a free tier" impression) before writing it into the spec or checklist.
  "Free tier" marketing routinely gates the exact endpoint a project needs behind a paid
  plan — the gold-trading-dashboard project hit this twice (Finnhub, then Financial
  Modeling Prep) before landing on a truly free source. A service with no paid tier at all
  (e.g. a government/public-data API) is a stronger guarantee than any commercial "free
  tier" and should be preferred when one exists and fits the need.
- **Default new connections to direct API calls, not MCP — it's a token-cost decision.**
  An MCP server's tool schemas load into context at the start of every conversation
  whether used or not; a direct API call (Python/PowerShell/etc. hitting the REST
  endpoint) has zero standing cost. Set up every new connection the same way: real keys
  in the repo-root `.env` (shared across skills, or skill-local only if the skill is
  meant to be a genuinely standalone/portable export), and a `references/<provider>-api.md`
  file (repo root, matching `clickup-api.md`'s structure — growth policy, auth, endpoints
  with source links, gotchas) documenting what's actually used, plus whatever's already in
  front of Claude for free even if unused yet. **Recommend MCP instead, explicitly, when**
  a service's auth is genuinely complex/stateful (rotating tokens, not a static key) in a
  way likely to produce fragile hand-rolled code, or when a service only offers MCP with
  no usable REST API/SDK at all — say so plainly rather than defaulting silently either
  way. Precedent: `gws-cli` over a dedicated Calendar MCP, ClickUp raw REST over its MCP
  server, Exa/Firecrawl direct API (2026-07-23 and 2026-07-27 decision log entries).
- **Safety for anything automated** (sorting, deleting, moving files/mail): when the tool is
  unsure, it should surface the item for review, never silently hide or delete it. Losing
  something real is far worse than showing one extra. Bake this into any auto-processing plan.

## What this skill explicitly does NOT do

Write actual code (that's Claude Code, later, pointed at the spec). Skip the interview
because Tyler seems eager to start — the whole reason this skill exists is to stop that
impulse and get the idea fully on the table first. Cut the interview short on its own
initiative — Step 3.5 makes stopping Tyler's call, not a fixed-length form. Push to ClickUp
before the checklist exists on disk — the file is always the source of truth; ClickUp is a
mirror of it. Hand off to `project-builder` or write real project code — that only happens
on a separate, explicit ask, never automatically once the plan is done.

## Files in this skill

- `references/core-questions.md` — the 10 universal questions + why each matters
- `references/branch-questions.md` — type-specific questions (app, dashboard, plugin, connector, Claude Code skill/automation, other)
- `references/folder-structures.md` — pro folder templates + the golden rules of clean structure
- `references/teaching-guide.md` — how to teach (short why-notes + deep 12yo mode)
- `templates/spec-doc.md` — the project spec template
- `templates/build-checklist.md` — the step-by-step build checklist template
- `templates/README.md` — a GitHub-ready README template

ClickUp mechanics live entirely in the separate `clickup-push` skill (Step 6 hands off to
it) — this skill has no ClickUp-specific references of its own on purpose. Competitive
research (Step 2.5) leans on the separate `web-scrape` skill via a subagent — no research
mechanics of its own live here either.
