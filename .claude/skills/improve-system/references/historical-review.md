# Historical Review Mode

Goal: mine recent Claude Code sessions for learnings that happened but were
never captured live — the stuff Tyler said in the moment that would have been
an Experience-mode or Skill-Review-mode entry if he'd stopped to flag it, but
didn't.

## Where the data lives

Every Claude Code session in this repo writes a `.jsonl` transcript to:
`~/.claude/projects/c--Users-User-AI-Operating-System/<session-id>.jsonl`

Each line is one JSON event. The ones that matter here have
`"type":"user"` or `"type":"assistant"` with a `message.content` field (plain
string, or an array of content blocks for assistant messages — text blocks
have `"type":"text"`). Every event carries a `timestamp` (ISO 8601) and
`sessionId`. Ignore `"type":"system"`, `"type":"queue-operation"`, and
`isMeta:true` lines — those are tool/system noise, not conversation.

**These files can be large and numerous — never read a full raw transcript
into the main conversation.** That defeats the point of a token-cheap review
mode.

## Step 1 — Figure out what's new

Read (or create, if missing) `state/last-review.json` in this skill's own
folder:

```json
{ "last_reviewed_timestamp": "2026-07-20T00:00:00.000Z", "sessions_seen": ["<id>", "..."] }
```

List the `.jsonl` files in the transcripts folder, and keep only the ones
with a last-modified time after `last_reviewed_timestamp` (or entirely new
session IDs not in `sessions_seen`). If this is the first-ever run (no state
file), default to the last 7 days rather than the full history — ask Tyler if
he wants a deeper first pass.

## Step 2 — Delegate the actual reading

For each new/changed session, spawn a general-purpose Agent (not this main
conversation) with a self-contained prompt like:

> Read the Claude Code session transcript at `<path>`. It's JSONL — one JSON
> event per line, user/assistant messages have `message.content`. Skim for
> moments where Tyler (the user) corrected an approach, pushed back, expressed
> frustration, or explicitly confirmed an unusual choice worked well — the
> same signals a memory system would want to capture. Ignore routine tool
> approvals and small talk. Report each candidate as: what happened (1-2
> sentences), a direct quote if there's a clear one, and which skill/file it's
> about if identifiable. If nothing rises above routine, say so plainly —
> don't invent a finding to have something to report.

Run these in parallel where there are multiple sessions. This keeps the raw
transcript text out of the main context — only the agent's short report comes
back.

## Step 3 — Filter and present

Collect the agents' reports. Drop anything that's already covered by an
existing memory (check `MEMORY.md`'s index) or already logged in
`decisions/log.md`. For what's left, present each candidate the same way
Experience mode would, and ask Tyler which ones to actually capture — don't
auto-file everything an agent flagged, some will be noise.

## Step 4 — Capture confirmed ones, then update state

For each candidate Tyler confirms, follow Experience mode's process (or
Skill Review's, if it's skill-specific) to draft and write the actual memory
/ skill edit / decision entry.

Once done, update `state/last-review.json` — set `last_reviewed_timestamp` to
now, and add the processed session IDs to `sessions_seen`. Do this update
regardless of whether any findings were confirmed, so re-runs don't re-scan
the same sessions.

## Output format

```
## Historical Review — [date range covered]

Sessions checked: [N] ([session-id list or "since <date>"])

### Candidates found
1. [session-id, timestamp] — [what happened]
   Quote: "[...]" (if any)
   Likely destination: [memory type | skill-review target | decisions/log.md | none obvious]

[If none found:] Nothing rose above routine in this window.
```
