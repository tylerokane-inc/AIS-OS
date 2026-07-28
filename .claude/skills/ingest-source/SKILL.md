---
name: ingest-source
description: Use when Tyler wants to save an outside source (an article, PDF, link, or transcript) into his Obsidian vault as durable, pre-analyzed reference material. Trigger on "ingest this," "save this to my project," "file this as reference," "add this to my knowledge base," or right after a `web-scrape` research call when Tyler wants to keep what was found instead of letting it disappear at the end of the conversation. Takes any source, extracts the real concepts (not a raw dump), and files it as a structured, cross-linked note — the persistence half of the research pipeline `web-scrape` starts but explicitly doesn't finish.
---

# Ingest Source

Closes the loop `web-scrape` leaves open. `web-scrape` finds things and hands back a
synthesized findings brief for the conversation — but by design, it never saves anything
("Persisting research for later is the future ingest-source skill's job, not this one").
Without this skill, everything found in one session is gone the next. This skill reads a
source, pulls out what actually matters (concepts, not a raw copy), and writes it into
Tyler's Obsidian vault (`C:\Users\User\Documents\Obsidian_Vault`) as a real, permanent,
cross-linked note.

**Always invoked directly** — Tyler hands over a specific source and says so. Never
triggered by something merely sitting in `01-Inbox\`; that's `obsidian-organizer`'s job,
and it's a different, shallower job (see "What this skill does NOT do" below).

See `references/vault-map.md` for the full folder-routing decision tree, the two-way
backlinking mechanic, and the duplicate-check procedure — this file is the step-by-step
workflow; that file is the detailed rulebook it points back to.

## Setup this skill depends on

- The vault's `02-Projects/`, `03-Knowledge/`, and `Index.md` already exist — nothing to
  create there.
- Fetching a bare URL reuses `web-scrape`'s existing script directly:
  `python .claude/skills/web-scrape/scripts/firecrawl_fetch.py "<url>"`. Its API key
  (`FIRECRAWL_API_KEY`) already lives in the repo-root `.env` — nothing new to configure.

## The workflow

**1. Identify source type.** Three cases:
- **Already in the conversation** — pasted text, or `web-scrape`'s own output earlier
  this session. Use it as-is, no fetch. If it's specifically `web-scrape`'s synthesized,
  cited findings brief, extract from *that* directly — don't re-fetch the original URL(s)
  or redo synthesis from scratch. Paying for the same analysis twice is waste.
- **Local file path** (PDF/.md/.txt) — read it with the `Read` tool directly.
- **Bare URL** — normalize it first (strip tracking params like `utm_`/`si=`, `www.`,
  scheme, trailing slash — this normalized form is what duplicate-checking compares
  against), then fetch it with `web-scrape`'s `firecrawl_fetch.py` script.

**2. Cheap duplicate check, before spending any effort.** Grep existing notes'
`source:` frontmatter (across `02-Projects/` + `03-Knowledge/`) for the normalized URL. A
hit means: don't fetch, don't create. Report the existing note's path, its
`date_ingested`, and a one-line summary, then ask Tyler: skip (default) / refresh that
note / create a new one anyway.

**3. Fetch or read the content.** If Firecrawl returns an `error` or `warning` field,
stop and report it plainly — never proceed to extraction on a failed or thin fetch.

**4. Boilerplate/thin-content guard.** Before spending effort extracting concepts, read
what actually came back: is this real source material, or page-shell boilerplate (short,
"enable JavaScript," a sign-in wall, cookie-banner/nav-only text, no real sentence
structure)? Give `youtube.com`/`youtu.be` URLs heightened default suspicion — Firecrawl
against YouTube specifically is unproven (only Wikipedia/Vue SPA/arXiv PDF are confirmed
working). If flagged: **stop before creating any note.** Tell Tyler plainly what came
back looks like boilerplate, not the real content, and offer to: have him paste the
content directly, try a different source, or explicitly override.

**5. Extract.** Title, a 2-4 sentence plain-English summary, key concepts (a genuine
breakdown — think "table of contents," not a raw dump), and key people mentioned.

**6. Read `Index.md`, decide routing.** Full decision tree is in `references/vault-map.md`
— short version: genuine match to an existing project or category routes there silently;
no genuine match means a brand-new category/project, and that's never invented silently —
ask Tyler. **Filing always happens** — it never waits on or requires anything to link to.

**7. Subject-level duplicate soft-check.** No URL match in step 2, but after extraction
the routed destination looks like it may already cover this exact source? Soft flag only
— "this looks like it may already be covered by X, continue?" — never a hard block.

**8. Identify genuinely-related existing notes for backlinking.** Same relevance bar
`obsidian-context` uses ("one small tangential correlation is not context") — scoped to
`02-Projects/` + `03-Knowledge/` only (never `00-Daily/`, `01-Inbox/`, `04-Archive/`).
Weak or tangential matches get surfaced to Tyler as unconfirmed, never auto-written.
**This step is optional** — if nothing genuinely matches, skip straight to step 10 with
an empty `## Related` section. No match is never a reason to delay or block filing.

**9. Backlink existing notes first.** For each confirmed match, append a `## Related`
entry to that note (create the heading at the bottom if it doesn't exist — never inline
mid-prose). Full mechanics — idempotent appends, clean-insertion spacing — in
`references/vault-map.md`. Do this *before* creating the new note.

**10. Create the new note** from `templates/source-note.md`, linking only to notes that
were actually, successfully updated in step 9 (edits-first, note-last — avoids a
one-directional link if a step-9 edit had failed).

**11. Update `Index.md`** (and the project's own `00-INDEX.md` if it has one), matching
`obsidian-organizer`'s existing bullet style exactly. If step 9 produced any genuine
backlinks, add a short parenthetical noting the connection — e.g. `(related: Fitness Coach
App)` — so it's visible at the cheap-lookup level, not just inside the notes themselves.

**12. Report back.** File path, routing decision and why, and any flags raised along the
way (new category asked, duplicate skipped, boilerplate warning, which notes got
backlinked).

## What this skill explicitly does NOT do

- Doesn't do the light inbox sweep/file-move-and-link for casual drops — that's
  `obsidian-organizer`'s `01-Inbox` job. This skill is always invoked directly on a
  specific source, never triggered by something merely sitting in the inbox.
- Doesn't touch `01-Inbox/` or today's daily note at all.
- Doesn't answer questions from existing notes or pull prior context into an unrelated
  conversation — that's `obsidian-context`'s job. This skill only writes new notes.
- Doesn't fetch raw web content itself — reuses `web-scrape`'s `firecrawl_fetch.py`
  rather than reinventing fetching.
- Doesn't run on a schedule — manual only, Tyler-invoked every time.
- Doesn't force a link. If nothing genuinely relates to a source, the note still gets
  filed — its `## Related` section just stays empty.
