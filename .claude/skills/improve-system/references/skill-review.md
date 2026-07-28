# Skill Review Mode

Goal: use what just happened in this conversation (or a recent one) to make a
specific skill better, so the same friction doesn't happen again next time it
runs.

This is chat-specific — it's about *this* skill and *this* recent
back-and-forth, not a general quality pass. For a structural quality checklist
(frontmatter, token budget, general best practices) independent of any one
session, that's `skill-builder`'s Mode 2 audit — feel free to run that too if
the review surfaces a structural issue, but don't substitute it for actually
reading what happened.

## Process

1. **Identify the skill.** If Tyler named it, read
   `.claude/skills/<skill-name>/SKILL.md` (and any `references/*.md` it uses).
   If he didn't name it, infer it from the conversation — confirm the guess
   before proceeding if there's any doubt.
2. **Find the friction or the win.** Reread the recent exchange for:
   - A correction Tyler gave ("no, don't do that", "that's not what I meant")
   - A place the skill's instructions were ambiguous and caused a wrong guess
   - A step Tyler had to explain manually that the skill should have already
     known
   - Something that worked well and is worth locking in explicitly, so a
     future edit doesn't accidentally remove it
3. **Translate it into a skill-file edit**, not a vague note. The fix should be
   the kind of concrete instruction a fresh Claude Code session — with zero
   memory of this conversation — could follow correctly. Reference how this
   repo's other skills phrase rules (a rule + a why + when it applies) for
   consistency.
4. **Also check**: does this same lesson belong in a memory file instead of
   (or in addition to) the skill file? Rule of thumb — if it's specific to
   *how this one skill should run*, it goes in the skill file. If it's about
   *Tyler's general preferences* that would apply across skills, it belongs in
   a `feedback_*` memory instead, or both if it's genuinely both.
5. Show the proposed edit (exact before/after) and wait for confirmation.

## Output format

```
## Skill Review — [skill-name]

**What happened:** [1-2 sentences, the friction or the win]
**Proposed change to SKILL.md (or references/*.md):**
[exact edit, before/after or diff-style]
**Also worth a memory entry?** [yes — draft it | no]
```
