---
name: obsidian-context
description: Use whenever Tyler's Obsidian vault might hold relevant prior context for the current conversation — not just Obsidian-specific chats. Trigger on "use Obsidian to find this," "pull any valid info we have from Obsidian to help with this," "did I already write about this," "check my notes for X," or any moment past context from the vault would genuinely change the answer.
---

# Obsidian Context

Pulls prior context out of Tyler's Obsidian vault (`C:\Users\User\Documents\Obsidian_Vault`)
into whatever conversation needs it. Read-only — this skill never edits or creates a file.
Filing and reorganizing the vault is `obsidian-organizer`'s job, not this one.

## Steps

1. **Check `Index.md` first.** Read `C:\Users\User\Documents\Obsidian_Vault\Index.md` — the
   master map. This is the cheap lookup; never open every note in the vault to go looking.
2. **Judge relevance from the index entries alone.** Compare the current topic against what
   `Index.md` lists under Projects and Notes. Only a genuine match counts — same topic, same
   idea, same system/procedure the current conversation is actually about.
3. **Open only the matching note(s).** If one or more index entries look like a real match,
   read those specific files (in `02-Projects/` or `03-Knowledge/`) — never a broader scan.
4. **Surface it, sourced.** Bring the relevant content into the conversation and name which
   note it came from, so Tyler can tell it's grounded in something real, not invented.
5. **If nothing genuinely matches, say so.** Don't inject a weak or tangential match just to
   have an answer.

## Hard rule

**One small tangential correlation is not context.** (Tyler's words.) If the match is loose —
same general area but not the same actual topic/idea/system — either say the match is weak
or stay quiet, rather than presenting it as solid grounding. When unsure, say so plainly.

## What this skill explicitly does NOT do

- Never writes to any file in the vault — no edits, no new notes, no Index.md updates. That's
  `obsidian-organizer`.
- Never scans the whole vault looking for matches — `Index.md` is the only cheap entry point;
  if it doesn't point anywhere relevant, the answer is "nothing found," not a manual folder walk.
- Never touches `.obsidian/`, `.claude/`, or `.claudian/` inside the vault — pre-existing tooling,
  unrelated to this skill.
