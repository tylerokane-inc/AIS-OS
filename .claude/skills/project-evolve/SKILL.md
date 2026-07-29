---
name: project-evolve
description: Use when Tyler wants to figure out what to change or improve about a project that's already built and live — not planning something new (that's project-planner) and not fixing something actively broken/erroring right now (that's debug). Trigger on "I want to change [project]," "let's evolve [project]," "I don't like [X] about this," "let's improve [project]," or similar. Always a separate, explicit ask — never fires automatically after a build finishes. Reads the live project's own docs for already-flagged unresolved items, opens by asking what's actually happened in real use (not a wishlist), filters every candidate through "does this matter to Tyler AND is it currently not working," caps the result at 3-5 real changes, then writes a short change-spec and hands it to project-builder to execute.
argument-hint: [project name or path]
---

# Project Evolve

`project-planner` plans something new. `project-builder` builds it. This skill is the third
leg: once something is already built and live, this is where Tyler figures out what to
change next — and it hands that off to `project-builder` to actually execute, the same way
`project-planner` does for a first build.

This process is grounded in real research (indie-builder + formal product-review practice,
gathered 2026-07-29), not arbitrary: look at what actually happened before guessing, match
review depth to how much real usage exists, only touch things that both matter and are
currently broken/annoying, capture friction as it happens instead of relying on memory, and
keep the output short.

## Phase 0 — Kickoff

Confirm which live project this is about (a name Tyler gives, or infer from context). Find
its real folder. If the folder or project can't be found, ask — never guess at a project
Tyler didn't clearly name.

## Phase 1 — Read the project's own paper trail first

Before asking Tyler anything, read that project's own docs — `CLAUDE.md`, `docs/status.md`,
`docs/how-it-works.md`, `README.md`, whatever it has. Pull out anything already flagged as
**not yet verified, TODO, placeholder, or "adjust if this feels wrong."** These are free
candidates — Tyler already knew about them at build time and shouldn't have to re-remember
them now. Keep this list separate for now; it feeds Phase 3, not Tyler directly yet.

## Phase 2 — Ask about real usage, not wishes

Open the conversation with **"walk me through what's actually happened since this went
live"** — never "what do you want to change." Usage first, wishlist second. While Tyler
answers, also establish how long it's been live and how much he's actually used it — that
sets the depth for this pass:
- **Under a week of real use:** keep this light — just check for anything outright broken.
  There isn't enough real usage yet for a substantive review.
- **A week or more:** a real review is warranted.
- **A month or more:** go deeper — patterns from sustained use are more reliable than a
  first week's impression.
If Tyler doesn't know or hasn't used it much, say so plainly rather than forcing a review
that has nothing real to work from yet.

**Close the loop as you go.** If anything Phase 1 flagged as unresolved turns out, from
what Tyler just said, to actually be confirmed/working now, update the project's own doc
that flagged it — right then, before moving to Phase 3 — rather than quietly dropping it
from the candidate list. (2026-07-29: this is exactly what happened on the first real run,
against Habit Tracker.)

## Phase 3 — Filter every candidate

Combine Phase 1's docs-scan findings with whatever Tyler raised in Phase 2 into one
candidate list. Run every single item through one question: **does this matter to Tyler,
AND is it currently not working or actively annoying him?**
- Matters + broken/annoying → keeps going.
- Matters + already fine → drop it. Working parts don't need touching just because they
  could be touched.
- Doesn't really matter to him, even if technically broken → drop it, or note it in passing
  only if it's cheap and Tyler explicitly wants it swept up.

## Phase 4 — Cap it and confirm

Present the surviving candidates, **capped at 3-5 max** — if more survived the filter, ask
Tyler to help pick the top ones rather than carrying all of them forward. Let Tyler choose
which of these he actually wants to act on right now; not everything that qualifies has to
happen in the same pass.

## Phase 5 — Write the change-spec

Fill `templates/change-spec.md` for the chosen item(s) and **append** it as a new dated
entry to that project's own `docs/change-log.md` (create the file with a one-line header if
it doesn't exist yet — never overwrite prior entries, this file is an append-only running
history). Keep it short: what's changing, why (tie back to the Phase 3 filter answer), and
anything `project-builder` needs to know that isn't obvious from the project's existing
docs. This is a delta, not a rebuild plan — don't re-derive the whole spec.

## Phase 6 — Hand off

Recap short, no padding:
```
Project:  <name>
Change:   <one-line what's changing>
Spec:     <path>/docs/change-log.md (latest entry)
```
Remind Tyler that building the actual change happens in `project-builder`, pointed at that
change-log entry — this skill never executes changes itself, even a small one.

## Guardrails

- **Never skip Phase 1.** Reading the project's own docs first is what makes this useful
  instead of just another chat — skipping it means Tyler re-derives from memory exactly the
  friction research says gets lost.
- **Never open with "what do you want to change."** Usage first, always — that's the whole
  point of Phase 2's ordering.
- **Never let the candidate list exceed 3-5 items going into Phase 4.** If the filter in
  Phase 3 leaves more than that, the filter wasn't applied strictly enough — tighten it,
  don't just truncate the list arbitrarily.
- **Never execute anything.** Writing the change-spec is the end of this skill's job. Even
  a one-line CSS tweak goes to `project-builder`, not straight into an edit here.
- **Never confuse this with `debug`.** If something is actively erroring or broken *right
  now* in a way that needs fixing immediately, that's `debug`'s job, not this skill's. If
  Phase 1 or Phase 2 turns up something that sounds like a live, urgent bug, flag it and
  suggest `debug` — don't fold urgent fixes into a change-spec meant for the next build pass.
- **Never guess which project.** If Tyler's request is ambiguous about which live project
  he means, ask before reading anything.

## What this skill explicitly does NOT do

Plan something new from scratch — that's `project-planner`. Execute the change-spec it
writes — that's always `project-builder`, on a separate explicit ask, same as a fresh build.
Fix something actively broken/erroring right now — that's `debug`. Re-run a full planning
interview — Phase 2 is a short, usage-focused conversation, not the 10 core questions.

## Files in this skill

- `templates/change-spec.md` — the entry format appended to a project's `docs/change-log.md`
