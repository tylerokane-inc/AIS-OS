# AIS-OS Intake

This is the source-of-truth file for your AIOS. Fill it in by typing, voice-pasting (Wispr Flow / OS dictation), or running `/onboard` for a guided conversation. Whichever mode, this file is what `/onboard` reads to scaffold your Day-1 setup.

**Hard cap: 7 questions.** Each answerable in under 60 seconds. Don't overthink — you can edit and re-run `/onboard` any time.

---

## Q1 — Who are you, what do you sell, who do you sell it to?

Identity, offer, ICP. One paragraph each is fine.

```
Tyler. Learning AI with the goal of becoming an AI consultant who helps
businesses implement AI to save time. Not selling anything yet — no clients
right now. Current focus is building a personal AI operating system to
automate his own day-to-day (calendar, email, notes, projects) so the skill
of "saving time with AI" becomes provable on himself first, then sellable to
businesses. ICP (future): businesses that need help implementing AI to save
time.
```

---

## Q2 — Paste 1-2 things you've written recently. Don't edit them.

An email, a LinkedIn post, a DM, a doc — anything that sounds like you when you're not trying. **Paste verbatim.** Do not type these mid-conversation with Claude — chat-shaped samples are worse than no samples (voice contamination).

```
DEFERRED — no clean written samples exist yet (emails are Claude-drafted;
only raw notes on hand). Revisit once Tyler has organic written
communication (a Discord/Skool message, a real self-written email, etc.)
to paste. Do not infer voice from dictated/chat speech in the meantime.
```

---

## Q3 — What are your 2-3 biggest priorities for the next 90 days?

Quarterly priorities. Not yearly aspirations. Things that, if not done by July, would make you say "I wasted Q2."

```
1. Daily planning system: Google Calendar <-> ClickUp connected so ClickUp
   is the to-do hub and the calendar stays complete (no manual re-entry,
   no drift). One clear top priority surfaced each day.
2. Auto-organizing Obsidian pipeline: raw notes land in an inbox, get sorted
   into categorized/linked folders on a schedule. Evolving context system
   that's token-efficient (only relevant context per project, no bloat).
3. Day-off resilience test: the system runs well enough that a full day off
   the phone doesn't break anything. On return, missed tasks are tracked,
   rescheduled, and rolled forward automatically. Pick back up, no dropped
   threads.
```

---

## Q4 — Where does revenue actually land, and where is it tracked?

Multiple answers OK. Stripe? Skool? GoHighLevel? QuickBooks? A spreadsheet?

```
Pre-revenue, pre-client. No income source tracked yet.
```

---

## Q5 — Where do you talk to customers, your team, and the outside world day-to-day?

Email (which one — Gmail / Outlook)? Slack? Teams? DMs (Skool / Discord / iMessage)? Phone?

```
Three email accounts:
- Gmail (main) — banks, primary personal/business use. This is the one the
  AIOS should focus on.
- Gmail (junk) — subscriptions, throwaway signups. Not a priority.
- Yahoo — tied to an eBay side-hustle (has its own SOP already). Explicitly
  OUT OF SCOPE for now — low volume, not worth automating yet.

No Slack/Teams/Discord in active use day-to-day (pre-client, solo).
```

---

## Q6 — Where do meeting recordings, notes, and important docs live?

Granola? Otter? Fireflies? Google Drive? Notion? Dropbox? A folder on your desktop you keep meaning to organize?

```
Primary: Obsidian (notes — see Q3 priority #2 for the auto-organizing pipeline).

Minimal/future: Google Drive, Google Docs, Google Sheets — not in heavy use
yet, low priority.

New project idea surfaced here: nightly self-recorded speaking-practice
videos (goal: sound more fluent, commanding, professional). Plan is to
record on computer, auto-save, run through a free transcriber (Fireflies or
similar) as soon as the video finishes, then review the transcript + video
the next day. Wants a simple daily review dashboard to track improvement
over time by comparing transcripts + video across days. Not built yet —
candidate for a future /level-up build.
```

---

## Q7 — What's the one task that eats your week, and where do you currently track work?

The single biggest time-suck or recurring drudgery. Plus where tasks/projects live (ClickUp / Asana / Linear / Notion / a notebook).

```
Top pain: manually sorting/organizing everything himself — email, calendar,
to-do lists, notes. It's a recurring meta-task that eats time that should go
to building/shipping instead. Wants a system where, once something is
created, it auto-funnels to its correct location — no more re-sorting the
same categories every week.

Task/project tracking: ClickUp (primary), some Notion use (straying away
from it, but still has things stored there).
```

---

When this file is filled, run `/onboard` (or re-run it) and the wizard will scaffold your Day-1 file set: `context/`, `references/voice.md`, populated `connections.md`, and a filled `CLAUDE.md`.
