# Daily Brief — Project Spec

*Made with the Project Planner. This is the single source of truth for the build.*

**Date:** 2026-07-25
**Build type:** Other / script
**Version target:** v1 (smallest useful version)

---

## 1. The Big Picture (from the 10 core questions)

1. **What it is:** A small automated script that checks today's Google Calendar and today's ClickUp tasks each morning and surfaces one clear "today's top priority" as a notification.
2. **Why I'm building it:** Manually sorting/organizing everything by hand is Tyler's top pain (`context/priorities.md`). This is the AIOS structural audit's #1-ranked leverage gap (`decisions/log.md`, 2026-07-23) — the one piece standing between a documented system and one that actually runs itself.
3. **Main goal / job it does:** When it works, it lets Tyler open one notification each morning and immediately know today's single top priority — no manually cross-checking Calendar and ClickUp himself.
4. **Who it's for:** Just Tyler.
5. **#1 problem it solves:** The manual daily triage — deciding "what actually matters today" by hand, every morning.
6. **"Done and working" for v1 looks like:** Every morning, without Tyler doing anything, one phone/desktop notification names today's top priority — pulled from real Calendar events and real ClickUp tasks, using the fixed priority rule below.
7. **Must-haves:** reads today's Calendar (`gws-cli`); reads today's ClickUp tasks + Priority field; applies the fixed priority rule; sends one notification; runs unattended on a daily schedule.
   **Nice-to-haves (later):** a ranked list instead of one single item; a weekly rollup; auto-reschedule of missed tasks; (bigger, parked as Expansion) turning ClickUp due dates into real time-blocks on the Calendar.
8. **Smallest version I'd actually use:** one plain notification naming ONE task or event as "today's priority" — no ranking, no polish.
9. **What could get in the way:** how it fires unattended every day (Windows Task Scheduler vs. Claude Code's own scheduled-agent feature) — open; how the notification actually reaches Tyler on Windows — open; ClickUp tasks need their Priority field actually set for the rule to mean anything.
10. **How I'll know it worked:** it fires on its own for at least a week without Tyler checking on it or fixing it — the "verified-unattended-once" bar the board set on 2026-07-23.

---

## 2. How It's Built (from the branch questions)

- **In:** today's Calendar events (`gws-cli`) + today's ClickUp tasks with their Priority field (ClickUp API)
- **Transform (the priority rule):** a fixed-time Calendar event happening today always wins. Otherwise, the ClickUp task due today with the highest Priority field (Urgent > High > Normal > Low) wins; earliest-due breaks ties.
- **Out:** one short notification (phone/desktop) naming the winner.

---

## 3. Folder Structure

```
scripts/daily-brief/
├── README.md
├── docs/
│   ├── spec.md
│   └── build-checklist.md
├── lib/
└── tests/
```

Lives inside the AI Operating System repo (not a standalone Desktop project) — reuses the repo root `.env` (`CLICKUP_API_TOKEN`) and the already-authenticated `gws-cli` connection, so nothing needs to be set up twice.

---

## 4. The Build Order (high level)

1. Resolve the two open Discovery questions (trigger mechanism, notification mechanism)
2. Build the step that reads today's Calendar
3. Build the step that reads today's ClickUp tasks
4. Build the priority rule logic
5. Build the notification-send step
6. Wire the daily unattended trigger
7. Verify it fires unattended for a real week

---

## 5. Open Questions / Risks

- How it fires unattended daily — Windows Task Scheduler vs. Claude Code's built-in schedule/cron feature.
- Best way to actually deliver a Windows toast / phone notification from a script.
- ClickUp's Priority field has to be set on real tasks going forward for the rule to mean anything — a process change for Tyler, not just a build task.

---

## 6. Notes I Learned

- Renamed from an internal working name ("daily-cadence" / "the cadence fix") used during planning — "Daily Brief" is the real project name going forward.
- Grew directly out of the 2026-07-23 AIOS audit and the 2026-07-24 board-of-advisors session — see `decisions/log.md` for both.
- Doubles as Tyler's first hands-on ClickUp project — learning the Space > Folder > List > Task structure on something small, before touching the much larger existing "Personal Trainer App" project.
- The ClickUp-tasks-as-real-Calendar-time-blocks idea is parked as an Expansion inside this same project, not spun out as a separate one (Tyler's explicit call).
