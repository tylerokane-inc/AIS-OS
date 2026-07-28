# Experience Mode

Goal: take a story, win, or lesson Tyler just shared out loud and turn it into
something the system actually retains — the same mechanism that makes the
fitness-coach example from the original pitch work: "here's my feedback on
this past week" → next week's answer is sharper because the feedback got
filed, not just heard.

This mode is the fast, explicit trigger for a thing the auto-memory system
otherwise only does ambiently. Use the same classification rules `CLAUDE.md`'s
"auto memory" section already defines — don't invent a second taxonomy.

## Process

1. **Get the raw story**, if it's not already fully in the conversation. Ask
   Tyler to say what happened if he's only gestured at it ("add that as a
   lesson" with no detail yet).
2. **Classify it** using the existing memory types:
   - **user** — reveals something about Tyler's role, knowledge, or goals
   - **feedback** — corrects or confirms an approach for future work
   - **project** — a fact/decision about ongoing work not derivable from code
   - **reference** — a pointer to where info lives in an external system
   - **Not memory-worthy** — code patterns, debugging fixes, project structure
     (see the exclusion list in `CLAUDE.md`'s "What NOT to save in memory") —
     if the story is really just a recap of what got built, it may belong in
     `decisions/log.md` instead of memory, or nowhere new at all.
3. **Check for an existing memory to update** before creating a new one — same
   rule the auto-memory system already follows. Search `MEMORY.md`'s index
   first.
4. **Draft the memory file** (or the update) using the exact frontmatter format
   from `CLAUDE.md`'s "How to save memories" section — `name`, `description`,
   `metadata.type`, then the body with **Why:** / **How to apply:** lines for
   feedback/project types.
5. **Check if it's also decision-shaped.** If the story describes a real
   decision (not just a preference or fact), also draft a `decisions/log.md`
   entry in the same format the log already uses (Decision / Why / Alternatives
   considered / Owner).
6. **Check if it implies a skill-file edit.** If the lesson is specifically
   about how one skill should behave, flag that Skill Review mode might also
   apply — don't silently skip it, but don't run it automatically either; ask.
7. Show everything drafted (memory file + index line, decision entry if any)
   and wait for confirmation before writing.

## Output format

```
## Experience captured

**The story:** [1-2 sentence summary]
**Memory type:** [user/feedback/project/reference] — [new file | update to existing]
**Draft:**
[full frontmatter + body]
**MEMORY.md index line:** [the one-line pointer]
**Also decisions/log.md?** [yes — draft below | no]
**Also a skill edit?** [flag which skill, or no]
```
