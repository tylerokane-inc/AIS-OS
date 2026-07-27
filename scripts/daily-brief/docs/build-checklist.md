# Daily Brief — Build Checklist

*Work top to bottom through the numbered sections — they get you to the first real,
working version. **Expansion** sections are ideas for after — ignore them until the
numbered sections are live.*

## 01: Discovery
Goal: answer every open question below before touching 02.

- [ ] Connectors & APIs
    - [x] What does this need to connect to? :: Google Calendar (via gws-cli) and ClickUp (via the existing API token in this repo's .env)
    - [x] Why does it need that connection? :: Calendar for today's fixed-time events, ClickUp for today's tasks + their Priority field
    - [x] How will the connection work? :: gws-cli CLI tool for Calendar; ClickUp REST API using the existing pk_ token already in .env
    - [ ] What specific endpoints/actions will it use? (ClickUp: GET /team/{team_id}/task filtered to today; gws-cli: confirm the exact "today's events" command)
    - [x] Any limits to respect? :: ClickUp allows 100 requests/min (see references/clickup-api.md); gws-cli auth already verified working 2026-07-23
- [ ] Data & Storage
    - [x] Where does the data live? :: No new storage needed — reads Calendar + ClickUp live each run
    - [ ] What's the shape of it? (exact fields needed: task name, due date, Priority field, calendar event title + start time)
- [ ] Automation & Triggers
    - [ ] How does this run automatically every day without Tyler opening anything? (Windows Task Scheduler vs. Claude Code's built-in schedule/cron feature)
    - [ ] What time of day should it run?
- [ ] Notification & Output
    - [ ] How does the notification actually reach Tyler? (Windows toast notification, phone push, something else)

## 02: Setup
Goal: the project exists and an empty shell runs. Nothing built yet.
- [x] Create the project folder :: scripts/daily-brief/ inside the AI Operating System repo — reuses the existing .env, no separate repo needed
- [x] Add README.md
- [x] Create the folder structure from the spec (empty)
- [x] Put spec.md + this checklist in docs/
- [ ] Confirm the repo's .env has CLICKUP_API_TOKEN available and gws-cli is still authenticated

## 03: Core
Goal: the ONE main action works end to end. This is the reason the project exists.
- [ ] Write the step that pulls today's Calendar events via gws-cli
- [ ] Write the step that pulls today's ClickUp tasks along with their Priority field
- [ ] Write the priority rule: a fixed-time Calendar event wins if one's happening today; otherwise the highest-Priority ClickUp task due today wins, earliest-due breaking ties
- [ ] Write the step that sends a notification naming the winner
- [ ] Test the full chain end to end once, run manually

## 04: Usable
Goal: it works without Tyler standing over it.
- [ ] Wire the daily automatic trigger (from the Discovery answer above)
- [ ] Handle the "nothing due today" case with a clear message instead of an error
- [ ] Let it run unattended for a real week and confirm it actually fires each day

## 05: Ship
Goal: it's live and verified.
- [ ] Fill in the README with how to run or adjust it
- [ ] Double-check no secrets are committed
- [ ] Confirm one full week of correct, unattended firing (the board's "verified-unattended-once" bar)
- [ ] Log the outcome in decisions/log.md

---

## Expansion: ClickUp tasks as real Calendar time-blocks
Goal: instead of just reading due dates, convert ClickUp tasks into scheduled time blocks written onto the real Calendar, so events and tasks both live on one calendar.
- [ ] Research how to write new events to Google Calendar via gws-cli
- [ ] Decide how much time to block per task (a fixed default vs. ClickUp's time_estimate field)
- [ ] Decide what happens if the ideal time slot is already busy
- [ ] Build and test writing one real time-block to the Calendar

## Expansion: Ranked list instead of a single priority
Goal: show more than one item when Tyler wants fuller context, not just the single top pick.
- [ ] Add a "show top 3" mode to the notification

---

*Anything not written as a task yet is still just an idea. Turn it into a task before it
goes on this list, or leave it out until it is one.*
