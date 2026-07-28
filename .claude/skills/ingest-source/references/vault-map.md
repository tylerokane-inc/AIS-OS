# Vault Map — folder routing, backlinking, and duplicate rules

The detailed rulebook `SKILL.md`'s workflow steps point back to. Keep this file in sync
by hand with the vault's actual structure — it's not read automatically by Obsidian,
just documentation this skill (and anyone auditing it) can check against.

## The vault, top level

```
Obsidian_Vault/
├── 00-Daily/       one file per day — never touched by this skill
├── 01-Inbox/       general capture, obsidian-organizer's territory — never touched by this skill
├── 02-Projects/    one note/folder per ACTIVE project
├── 03-Knowledge/   flat, stable reference categories (renamed from 03-Notes 2026-07-27)
│   ├── Business/
│   ├── Health/
│   ├── Personal/
│   ├── Build-Ideas/
│   └── Templates/  live infrastructure (daily-note template) — not a routing target
├── 04-Archive/     retired projects — never a routing or backlink target
└── Index.md        master map, read first, updated last
```

## Folder routing decision tree

**Filing and backlinking are separate decisions.** Every source gets filed somewhere,
whether or not anything exists to link it to. Backlinking is a bonus on top, never a
gate on saving.

1. Read `Index.md` first — cheap lookup, same entry point `obsidian-context` uses.
2. Genuine match to an existing `02-Projects/<Name>` → route there, infer silently.
3. Genuine match to an existing `03-Knowledge/<Category>` → route there, infer silently.
4. No genuine match to anything existing → this means inventing a new category or
   project. **Never do that silently — ask Tyler right in the conversation.** (This skill
   always runs with Tyler present, unlike `obsidian-organizer`'s deferred-review pattern
   for things that can wait.)
5. Ambiguous between project-specific and general reference → surface both options, let
   Tyler pick.
6. Filing inside a matched project: `02-Projects/<Name>/sources/<slug>.md` — a `sources/`
   subfolder keeps ingested material distinguishable from the project's own planning docs
   (`00-INDEX.md`, `01-Plan.md`, etc.), no numbering collision. Link it from that
   project's own index if it has one.
7. Filing inside `03-Knowledge/<Category>/`: flat, matching the existing pattern (e.g.
   `Fascia.md`) — no subfolder needed unless a category has already established one.

## Two-way backlinking mechanic

The one rule that makes editing someone else's existing note safe: **reciprocal links
always go into a `## Related` heading, never inline mid-prose.** Most existing notes have
no frontmatter or heading structure to safely anchor an inline "first mention" link to —
appending to a predictable, dedicated heading is the only version of "additive-only" that
holds up against arbitrary unstructured prose.

- **Edits-first, note-last.** Update every confirmed existing note's `## Related` section
  *before* creating the new note. Only link the new note back to notes that were actually,
  successfully updated. Prevents a partial failure from leaving a one-directional/broken
  link.
- **Relevance bar:** identical to `obsidian-context`'s — "one small tangential correlation
  is not context." A weak match gets surfaced to Tyler as unconfirmed, never silently
  written. A bad link permanently written into someone else's note is worse than a missed
  one, because it persists.
- **Idempotent.** Before appending, scan the existing note's `## Related` heading for a
  link to the same target path — skip if already present. Re-running ingest on a
  near-duplicate source never spams the same note twice.
- **Scope: `02-Projects/` + `03-Knowledge/` only.** Never `00-Daily/`, `01-Inbox/`, or
  `04-Archive/` — same scope `obsidian-context` already uses. Keeps dead/archived context
  from getting resurrected by a fresh ingest.
- **Clean insertion.** If a `## Related` heading doesn't exist yet in the target note,
  precede it with two blank lines and a `---` divider — never appended flush against
  existing content, which risks breaking whatever the note currently ends with (a table,
  a list, etc.).
- **Reflected in `Index.md` too.** A genuine backlink connection gets a short
  parenthetical on the new note's `Index.md` bullet — e.g. `(related: Fitness Coach
  App)` — matching the parenthetical-note pattern `Index.md` already uses elsewhere (e.g.
  the existing "Master Context OS (possible overlap with the AIOS repo's own `context/`
  folder, unresolved)" entry). Use judgment on whether the existing note's own bullet also
  needs updating — don't clutter every bullet with every minor connection.

## Duplicate handling

**Pass 1 — cheap, before any fetch.** If the input is a URL, normalize it (strip
`utm_`/`si=`/tracking params, `www.`, scheme, trailing slash). Grep existing notes'
`source:` frontmatter across `02-Projects/` + `03-Knowledge/` for an exact match. Hit →
don't fetch, don't create. Report the existing note's path, `date_ingested`, and a
one-line summary; ask Tyler: skip (default) / refresh that note / create anyway.

**Pass 2 — after extraction, subject-level.** No URL match, but the routed destination
(decided in the folder-routing step) already looks like it covers this exact source, not
just a related topic? Soft flag only — "this looks like it may already be covered by X,
continue?" — never a hard block. Also check for a plain filename collision in the target
folder as a secondary signal.

## Note format

See `templates/source-note.md` for the actual skeleton. Frontmatter fields:

| Field | Required | Notes |
|---|---|---|
| `source` | yes | URL, `"local file: <path>"`, or `"pasted content"` |
| `type` | yes | `article` / `video-transcript` / `pdf` / `paper` / `web-page` |
| `date_ingested` | yes | `YYYY-MM-DD` |
| `project` | no | omit entirely if this is general reference, not project-specific |
| `key_people` | yes | can be an empty list `[]` if none |
| `key_concepts` | yes | the "table of contents" this whole skill exists to produce |
