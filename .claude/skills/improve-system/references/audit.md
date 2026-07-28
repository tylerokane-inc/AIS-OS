# Audit Mode

Goal: scan the AIOS's living knowledge for stale, conflicting, or duplicate
content, and propose fixes. This is a knowledge-quality pass, not a code audit
(that's the separate `/audit` skill, which scores the Four Pillars structurally).

## Scope — what to read

- `CLAUDE.md` (root) — the skill list, working-style rules, and the same
  shared-list entries context/*.md files sometimes duplicate
- `context/about-me.md`, `context/about-business.md`, `context/priorities.md`
- `references/*.md` (frameworks, API docs, glossaries)
- Memory files at `~/.claude/projects/<this-project-id>/memory/*.md` (read
  `MEMORY.md` first for the index, then open files as needed — don't blind-read
  every memory file if the index already tells you which ones are relevant)

**Do not audit `decisions/log.md`.** It's an append-only historical record by
design — old entries are supposed to describe what was true at the time, not
stay current. Flagging it as "stale" would be treating a feature as a bug.

## What counts as each problem

**Stale** — describes something that's demonstrably no longer true. Check
against the real current state (read the actual file/folder/skill it refers
to) before flagging — don't assume a memory is wrong just because it's old.
Example: a memory says "ClickUp push has no way to persist task IDs" but the
skill file now shows that was built.

**Conflicting** — two pieces of content make incompatible claims. Example: one
memory says "skills ship complete, no v1/nice-to-have split" and another
(older) memory implies the opposite for the same build type.

**Duplicate** — the same fact or instruction is written in more than one place
with a real risk of drifting apart over time. Not every repetition is a
problem — some redundancy across `CLAUDE.md` and a skill file is intentional.
Only flag it if there's no clear "source of truth" designated between the two.

**Tie-breaker for `CLAUDE.md` vs. `context/*.md` duplicates specifically:**
`CLAUDE.md` loads every session, so it gets the bare/minimal version; the
`context/*.md` file gets the fuller detail. Don't default to trimming the
context file and keeping detail in `CLAUDE.md` — for this repo the direction
runs the other way (see the `feedback_claude_md_stays_minimal` memory).

## Process

1. Read the scope above.
2. Build a list of findings, each tagged stale/conflicting/duplicate, with the
   file(s) and the specific lines involved.
3. For each finding, draft the fix: what to edit, delete, or merge, and into
   which file. If it's a duplicate, name which copy becomes the source of truth
   and what happens to the other (trim it to a pointer, or remove it).
4. Present all findings + proposed fixes together, ranked by how load-bearing
   they are (a conflict that could cause a wrong future decision outranks a
   stale date). Wait for Tyler to confirm which fixes to apply — he may not
   want all of them.
5. Apply only the confirmed fixes.

## Output format

```
## Audit findings — [date]

### 1. [STALE|CONFLICTING|DUPLICATE] — [short title]
**Where:** file(s) + line/section
**What's wrong:** [1-2 sentences]
**Proposed fix:** [exact edit]
```
