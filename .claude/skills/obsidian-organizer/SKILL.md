---
name: obsidian-organizer
description: Use when Tyler wants today's raw Obsidian daily note filed and organized, or wants to know his top priority for the day. Trigger on "go file today's notes," "go organize today's notes," "what should I work on today," or "check today's notes." Owns everything that touches today's note in Tyler's Obsidian vault.
---

# Obsidian Organizer

Owns everything that touches *today's* note and the general **`01-Inbox\`** capture zone in
Tyler's Obsidian vault (`C:\Users\User\Documents\Obsidian_Vault`). Two operations: a
**filing pass** that turns raw capture — today's journal note, plus anything dropped in
`01-Inbox\` — into an organized, cross-linked knowledge base, and a **priority check** that
reads today's note to surface one clear top priority. Finding *prior* context for something
else entirely is `obsidian-context`'s job, not this one.

`01-Inbox\` is the general front door — anything new that isn't today's journal writing
(a quick note, a screenshot, a PDF, a random file) gets dropped there any time, and the next
filing pass sorts it into its real home. Nothing needs to wait for end-of-day journaling to
get captured.

**Where today's note lives:** read `.obsidian\daily-notes.json` (inside the vault) for the
current `folder`, `format`, and `template` — don't hardcode a specific date format or folder
name here. Tyler has already changed the format once (2026-07-26) and may again; this skill
should always defer to whatever that config file currently says rather than going stale.
Build today's filename by applying that `format` to today's actual date. If the resulting
file doesn't exist yet, there's nothing to file — say so rather than creating one.

## Operation 1 — Filing pass

Trigger: "go file today's notes" / "go organize today's notes."

**Today's note:**
1. Read today's raw note (path resolved from `daily-notes.json`, see above).
2. Edit it **in place** into a structured, readable version — same words, same voice, just
   organized. Never keep a separate raw copy, and never delete the file itself.
3. Split the note by topic. For each topic, find the right existing `02-Projects\` note (or
   recognize the topic is genuinely new) and merge the content into the **right section** of
   that note. Never blind-append to the end, never duplicate content that's already there.

**`01-Inbox\` (every item currently sitting there):**
4. For each item in `01-Inbox\`:
   - **Text/markdown note:** same treatment as daily-note content — split by topic, merge
     into the right `02-Projects\` or `03-Notes\` section, never blind-appended or duplicated.
   - **Non-text file** (image, PDF, screenshot, etc.): move it into the right destination
     folder next to the note it belongs with, and link to it from that note.
   - Once an item is actually filed, remove it from `01-Inbox\` — the inbox should end up
     holding only what's still unprocessed, not a permanent archive.

**Both:**
5. Add Obsidian backlinks (`[[Note Name]]`) connecting related notes to each other.
6. Update `Index.md` so the master map reflects anything new or changed.

**Hard rule:** if it's not sure where something belongs, flag it for Tyler's review — never
guess and file it wrong. A flagged daily-note item stays in the daily note, clearly marked;
a flagged Inbox item stays in `01-Inbox\` — until Tyler resolves it.

## Operation 2 — Priority check

Trigger: "what should I work on today" / "check today's notes."

1. Read today's file only (path resolved from `daily-notes.json`, see above).
2. May check `Index.md` for related existing context, using `obsidian-context`'s relevance
   rule (see that skill) — a genuine match only, never a loose keyword grab.
3. Surface one clear top priority for the day, plus anything flagged from a prior filing pass
   that still needs Tyler's judgment call.

## Nightly auto-run — deferred

The original spec calls for an 11:00 PM nightly filing pass as a safety net (nothing is ever
*lost* if it's skipped — the raw note just stays unsorted until the next manual run). Tyler
chose **manual-only for now** (2026-07-26) — prove the filing logic by hand first, then wire
the real 11 PM trigger later via the `/schedule` skill once it's trusted. Don't build the
cron/auto-trigger until Tyler asks for it.

## What this skill explicitly does NOT do

- Never touches `.obsidian\`, `.claude\`, or `.claudian\` inside the vault — pre-existing
  tooling, unrelated to this skill.
- Never invents a home for content it isn't sure about — flags instead of guessing (see hard
  rule above).
- Never scans the whole vault for a priority check — today's file plus `Index.md` only.
- Doesn't pull prior context for unrelated conversations — that's `obsidian-context`.
