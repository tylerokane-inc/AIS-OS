# Repo Map — plain English

This file explains every folder and file in this repo like you're brand new
to it. No jargon without a quick explanation first. If you ever feel lost in
here, start with this file.

(There's a second, more technical version of this same map in
`EXPANSIONS.md` — read that once this one feels easy.)

---

## The root files (the ones sitting loose at the top level)

| File | What it actually is |
|---|---|
| `CLAUDE.md` | The instruction manual Claude reads every time it works in this repo. It tells Claude who you are, how you like to work, and where things go. If you want Claude to behave differently long-term, this is the file to change. |
| `EXPANSIONS.md` | A cheat sheet for "what folder do I add next, and when." The technical-detail version of this file. |
| `aios-intake.md` | The questionnaire you filled out when you first set this up. If your role, business, or priorities change, edit this and re-run the `/onboard` skill — it rewrites the other files to match. |
| `connections.md` | A list of every outside tool this system is hooked up to (Google Calendar, ClickUp, etc.) and whether the hookup is working. |
| `README.md` | The public-facing explanation of what this whole kit is, for anyone else who looks at the repo. |
| `.env` | Secret keys and passwords this system needs to talk to other tools (like ClickUp). Never share this file or paste its contents anywhere. |
| `.gitignore` | A list of files Git (the tool that tracks changes to this repo) should ignore and never save/share — mostly used to keep `.env` and secrets out of version history. |

---

## The folders

### `context/`
**What it is:** Facts about *you* — your role, your business, your current priorities.
**Why it's separate:** So Claude always knows who it's talking to without you re-explaining yourself every conversation.
**Example inside:** `context/priorities.md` — your top 3 goals this quarter.

### `references/`
**What it is:** Instruction sheets and know-how — frameworks you use, notes on how outside tools' APIs (the way two pieces of software talk to each other) work, samples of how you write.
**Why it's separate:** So Claude can look something up instead of guessing or re-researching it every time.
**Example inside:** `references/clickup-api.md` — notes on how to talk to ClickUp; this very file.

### `decisions/`
**What it is:** A running diary of real decisions you've made and *why* — one file, `log.md`, that only ever gets added to (never edited or deleted).
**Why it's separate:** Future-you (or future Claude) can see not just what was decided, but the reasoning, so you don't have to re-litigate old choices.
**Example inside:** `decisions/log.md`.

### `archives/`
**What it is:** The attic. Old files that are no longer active but you don't want to throw away.
**Why it's separate:** Keeps the "live" folders clean — if something's not being used anymore, it moves here instead of getting deleted or left cluttering an active folder.

### `scripts/`
**What it is:** Small pieces of code that do one specific job — usually talking to an outside tool (like pushing a task into ClickUp).
**Why it's separate:** So that logic is written once and reused, instead of Claude re-writing the same steps every time.
**Example inside:** `scripts/clickup_push.ps1`.

### `audits/`
**What it is:** Saved reports from the `/audit` skill — a scorecard of how well your system is running.
**Why it's separate:** Lets you look back and see your score improve over time instead of only seeing the latest one.

### `.claude/skills/`
**What it is:** The actual "skills" — like `/audit`, `/level-up`, `/onboard` — that Claude can run for you. Each one is a folder with instructions for a specific repeatable job.
**Why it's separate:** Keeps Claude's internal tooling separate from your actual content and notes.

### `.claude/` (the rest of it)
**What it is:** Configuration for Claude Code itself (settings, permissions). You generally won't need to touch this directly.

---

## How to tell where something new should go

Ask yourself two questions before creating a new folder:

1. **Have I seen something like this before in the list above?** If yes, it probably goes there — don't make a new folder for it.
2. **Will I actually use this folder again in the next month?** If you're not sure, it's too early. Wait until you actually need it a few times.

If both answers point to "yes, this is new and I'll use it a lot" — that's when a new folder is justified. Otherwise, it goes in an existing one, or Claude should ask you first.

---

*Once this feels natural, read `EXPANSIONS.md` — it covers the same ground with more technical detail, plus a list of folders you haven't added yet and when you'll know it's time.*
