# [PROJECT NAME] — Build Checklist

*How to use this file: work top to bottom through the numbered sections — they get you
to the first push. **Expansion** sections are ideas for after — ignore them until the
numbered sections are live.*

*Each section is self-contained: paste just that section (goal + tasks) into ChatGPT or
Claude on your phone/at work and it has enough context to help you finish it, without you
re-explaining the whole project.*

**Task wording rule**

Every `- [ ]` line starts with a verb and names ONE concrete thing to produce or
check. If a line reads like a question, a decision, or a vague theme, it's not a
task yet — rewrite it before it goes in. The one exception is **01: Discovery**
below, where the whole point IS the open questions.

- Bad: `pick one short tip for how to do each main exercise correctly`
- Good: `Write a 1-sentence form cue for: squat, bench, deadlift, overhead press`
- Bad: `figure out data storage`
- Good: `Create the workouts table with columns: date, exercise, sets, reps, weight`

If a task genuinely has a few small steps worth checking off separately, indent
them under it — these become sub-checkboxes on that one task in ClickUp, not new
top-level tasks:
```
- [ ] Build the login screen
    - [ ] Add email field
    - [ ] Add password field
    - [ ] Wire up the submit button
```

---

**Ship this first.** Keep the numbered sections to as few as it takes to reach a real,
working first version. Every task inside **01: Discovery** checked off means you have
everything you need to actually start building — that's the marker. Section names stay
short on purpose (`01: Discovery`, not `V1 — Phase 0 — Discovery`) — that's exactly what
each ClickUp List gets called, so keep it simple and skimmable.

## 01: Discovery
Goal: answer every open question below before touching 02. Each line here is a
topic; its indented lines are the real questions. The answer always goes to a
**comment** on the question's ClickUp subtask — never in the task's name, keep that
clean. Open question, still unanswered:
```
- [ ] What does this need to connect to?
```
Question already answered (from planning, or resolved later): check it AND add
` :: ` followed by the answer — `push-plan` posts everything after `::` as a comment
and marks the task Complete, the title stays just the question:
```
- [x] What does this need to connect to? :: Nothing external needed for V1.
```
- [ ] Connectors & APIs
    - [ ] What does this need to connect to? (or: confirm nothing external is needed)
    - [ ] Why does it need that connection?
    - [ ] How will the connection work? (API key, OAuth, local file, CLI tool...)
    - [ ] What specific endpoints/actions will it use?
    - [ ] Any limits to respect? (rate limits, cost, auth quirks)
- [ ] Data & Storage
    - [ ] Where does the data live? (a file, a database, an existing tool)
    - [ ] What's the shape of it? (the fields/columns that matter)
- [ ] Screens & Flow *(drop this task if there's no UI — e.g. a script or connector)*
    - [ ] What's the ONE screen someone opens first?
    - [ ] What's the ONE main action they take there?

## 02: Setup
Goal: the project exists and an empty shell runs. Nothing built yet.
- [ ] Create the root folder (kebab-case name)
- [ ] Add README.md, .gitignore, and .env.example
- [ ] Create the folder structure from the spec (empty)
- [ ] Put spec.md + this checklist in `docs/`
- [ ] Start a Git repo (`git init`) and make the first commit

## 03: Core
Goal: the ONE main action works end to end. This is the reason the project exists.
- [ ] [must-have #1, worded as an action]
- [ ] [must-have #2]
- [ ] [must-have #3]
- [ ] Test that the core works end to end

## 04: Usable
Goal: a stranger could use it without you standing over their shoulder explaining it.
- [ ] Add the basic look/feel so it's not confusing
- [ ] Handle the obvious "what if it breaks" cases
- [ ] Try it yourself as a real user would

## 05: Ship
Goal: it's live, and one real person other than you has used it.
- [ ] Fill in the README (what it is + how to run it)
- [ ] Double-check no secrets are committed
- [ ] Push to GitHub
- [ ] Show one real person and watch them use it

---

**Expansion.** Nothing here gets built until the numbered sections are live. Add a new
`## Expansion: <name>` section any time an idea comes up — this file (and its ClickUp
Lists) keeps growing after that. Each one is its own List, separate from the numbered
sections, and gets pushed the next time Step 6 runs.

## Expansion: [feature name]
Goal: [what this adds, in one sentence]
- [ ] [task]

---

*Anything not written as a task yet is still just an idea. Turn it into a task
before it goes on this list, or leave it out until it is one.*
