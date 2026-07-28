---
name: improve-system
description: Use when Tyler wants the AIOS to learn from something instead of just doing it once. Five modes — Audit (find stale/conflicting/duplicate notes in the knowledge base), Skill Review (improve a skill based on recent back-and-forth), Experience (capture a story/win/lesson just shared), Historical Review (mine recent Claude Code sessions for missed learnings), Foundation (fill gaps in context/about-me.md, about-business.md, priorities.md). Trigger on "/improve-system", "add that as a lesson", "capture that", "review my recent sessions for anything I missed", or whenever the same problem has come up twice and it's time to fix the system instead of the symptom.
---

## What this skill is for

Tyler's rule: **never fix the same problem more than twice by hand.** If something
goes wrong twice, or a good approach gets confirmed twice, the AIOS should absorb
that lesson itself — not rely on Tyler noticing and re-explaining it every time.

This skill is the compounding layer. Every mode ends the same way: find something
the system should know, propose the exact edit that teaches it, and write it —
only after Tyler says go.

## The one rule every mode follows

**Always show the proposed change before writing it. Never auto-apply.**

Concretely: read the target file(s), draft the exact edit (a diff-style before/after,
or the full new section if it's a new file), show it to Tyler, and wait for a
go-ahead. Only then use Edit/Write. This applies to every file this skill touches —
`SKILL.md` files, memory files, `context/*.md`, `decisions/log.md`. No exceptions,
regardless of how the mode was triggered.

## Step 1 — Figure out the mode

| If Tyler says... | Mode |
|---|---|
| `/improve-system audit`, "check my knowledge base for stale stuff" | Audit |
| `/improve-system review <skill>`, "make [skill] better based on that" | Skill Review |
| "add that as a lesson", "capture that", "remember that for next time" | Experience |
| `/improve-system history`, "check my recent sessions for anything I missed" | Historical Review |
| `/improve-system foundation`, "fill in what's missing about my business/goals" | Foundation |
| Bare `/improve-system`, or genuinely ambiguous | Ask which mode — see below |

If the mode isn't clear from what Tyler just said, ask directly rather than
guessing — a wrong mode wastes the whole point of this skill (getting it right
without Tyler having to redo it). Use AskUserQuestion with the five modes as
options, one-line description each.

## Step 2 — Load that mode's reference file

Read the matching file — **only that one**, not all five, to keep this skill
token-cheap when only one mode is running:

- Audit → `references/audit.md`
- Skill Review → `references/skill-review.md`
- Experience → `references/experience.md`
- Historical Review → `references/historical-review.md`
- Foundation → `references/foundation.md`

Follow that file's process exactly. Come back to this file for the one rule above
(always confirm before writing) — the mode files don't repeat it.

## Step 3 — Log it, if it's decision-shaped

If the change is a real decision (not just a small factual correction), also
propose a `decisions/log.md` entry in the same confirmation step — don't make
Tyler ask for that separately. Skip this for small edits (a typo fix, a stale
date) that aren't really decisions.

## Notes

- This skill edits real, live files that other skills and Claude Code itself
  depend on (`SKILL.md`s, memory, `context/`). Treat every write as high-stakes —
  that's *why* the confirm-first rule exists, not a formality.
- If a mode's reference file asks for something this file doesn't cover, that's
  a gap in the reference file, not a reason to improvise — flag it to Tyler.
