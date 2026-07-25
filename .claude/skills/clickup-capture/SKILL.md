---
name: clickup-capture
description: Use the moment Tyler mentions any task, to-do, or small item in passing — NOT a full new build. Trigger on "add a task for...", "remind me to...", "I need to...", "put this on my list," "someone needs to...", "don't let me forget...", or any casual one-off he'd otherwise have to retype into ClickUp by hand later. This is the fast lane — it does NOT run project-planner's 10-question interview. If Tyler is clearly kicking off a full new build (an app/dashboard/plugin/connector he wants planned), defer to project-planner instead.
argument-hint: [task or reminder]
---

# ClickUp Capture

The fast lane. Tyler mentions something in passing that needs to exist as a real ClickUp
task — this skill's whole job is to extract that in one turn and hand it to the
**`clickup-push`** skill (Mode B — quick-add), not run an interview and not talk to the
ClickUp API itself. If what he's describing is actually a new project/build (not a single
task), say so and hand off to `project-planner` instead of trying to force it through here.

**Auto-invocation is intentional here**, even though this skill has a real side effect
(creating a live ClickUp task). Disabling that would defeat the entire point — catching
casual mentions Tyler would otherwise forget to write down. `clickup-push`'s own
cache-miss confirmation and one-line report are the actual safety net, not a manual-only
gate here.

## Flow

### 1. Extract the task
If invoked directly with `$ARGUMENTS` (e.g. `/clickup-capture renew the domain next week`),
treat that text as the task description instead of pulling from earlier conversation.
Otherwise, pull a one-line task title from what Tyler just said. Only pull out sub-steps if
he already gave concrete ones in the same breath — never invent steps he didn't say. A
single flat task is the correct, default outcome most of the time.

### 2. Which project does this belong to?
Infer from context — an explicit project name, or "this is for X." If it's genuinely
unaffiliated (a bare one-off, e.g. "remind me to renew my domain"), use the reserved
project key `_default_capture` rather than asking "which project?" every time.

### 3. Hand off to `clickup-push`
Use the `clickup-push` skill's **Mode B** with the extracted title, project key, and any
sub-steps. That skill owns resolving the ClickUp home (asking once, then remembering),
pushing the task, and reporting back — this skill doesn't duplicate any of that mechanics.

## What this skill explicitly does NOT do

The 10 core questions, branch questions, folder/spec-doc/README generation, due dates,
priorities, custom fields, comments — all `project-planner` territory. Talking to the
ClickUp API, resolving Spaces/Folders/Lists, or knowing ClickUp's push mechanics —
`clickup-push` territory. If Tyler starts elaborating into something that's clearly a
real project rather than a single task, say so plainly and hand off to `project-planner`.
