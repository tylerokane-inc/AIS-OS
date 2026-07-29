---
name: project-builder
description: Use when Tyler wants to actually execute a finished spec into real, working output — either a fresh project-planner build-checklist (first build) or a project-evolve change-spec (a scoped change to something already live). Trigger on "let's build [project]," "build the [project] plan," "time to build X," "execute the checklist for X," or "let's make that change to [project]." Never auto-invoked right after project-planner or project-evolve finishes — building is always a separate, explicit decision from planning.
argument-hint: [project name or path to its spec/checklist]
---

# Project Builder

`project-planner` produces the plan — spec + build checklist, "measure twice." This skill
owns actually executing that plan into working code/skills/files, "cut once." It never
fires automatically the moment Planner finishes; Tyler decides separately, maybe same day,
maybe weeks later, when he's ready to build.

Built by observing the real build of `obsidian-organizer` + `obsidian-context` (2026-07-26)
from the spec at `Obsidian_Vault\02-Projects\Obsidian-System.md` — that session is the
reference example for every phase below.

## Phase 0 — Kickoff

Confirm which finished spec/checklist is being built (a path, or infer from what Tyler just
named). If no finished plan exists yet, say so and point to `project-planner` instead —
this skill has nothing to execute without one.

**Determine the build mode from the spec itself — never ask Tyler which mode this is:**
- **Fresh build** — the spec is `project-planner`'s `docs/build-checklist.md` (or
  equivalent first-time spec). Nothing real is live yet; aim straight at a working v1.
- **Evolve build** — the spec is a `project-evolve` entry from that project's
  `docs/change-log.md`. Something is already live, real, and in use — every phase below
  runs with more care because there's existing behavior and possibly existing data that
  must not break.
If it's genuinely unclear which one a given spec is (unlabeled file, ambiguous request),
ask — don't guess.

## Phase 1 — Discovery

1. **Read the whole spec/checklist** before writing anything — every section, not just the
   build order.
2. **Survey the real environment** the build touches: check the *current real state* of
   whatever the build operates on (existing data, existing files, existing config) — don't
   design against the spec's assumptions alone. **Evolve build:** this survey has one extra
   job — establish a baseline of what currently works, including the parts the change-spec
   isn't touching. That baseline is what Phase 6 checks against; without it there's nothing
   to confirm you didn't break. **Don't go looking for another existing
   project to use as a structural template**, and don't offer one either ("want me to
   structure it like X?") — build directly for what this project actually needs. If a
   genuinely relevant naming/structure convention is already obvious from context (not
   something you had to go dig for), it's fine to follow it, but this is never a step where
   you browse other projects for a pattern to copy. (2026-07-27: pulled up an unrelated
   project as a template example unprompted, before being asked — Tyler dislikes that
   project's own structure specifically, and more broadly doesn't want template-hunting as
   a default step until something is deliberately set as a real convention.)
3. **Isolate genuinely open decisions** — things the spec explicitly left unresolved or
   couldn't have anticipated (not questions the spec already answered).
3.4. **New connections default to direct API calls, not MCP** (token-cost decision — an
   MCP server's tool schemas load into every conversation's context whether used or not; a
   direct API call doesn't). Set up: real keys in the repo-root `.env` (or skill-local only
   if the skill is meant to be a standalone/portable export) and a
   `references/<provider>-api.md` file at the repo root matching `clickup-api.md`'s
   structure. Recommend MCP explicitly instead when a service's auth is genuinely
   complex/stateful enough that hand-rolled code would likely be fragile, or when no usable
   REST API/SDK exists at all — see `project-planner`'s matching rule and the 2026-07-23/
   2026-07-27 decision log entries for precedent (`gws-cli`, ClickUp, Exa/Firecrawl).
3.5. **Re-verify any third-party API's free-tier access before wiring code to it**, even if
   the spec already named a provider — pricing pages change, and "free tier" marketing
   often gates the exact endpoint needed behind a paid plan (this bit the gold-trading-
   dashboard project twice: Finnhub, then Financial Modeling Prep, before landing on FRED —
   a genuinely free, no-paid-tier government source). Check the provider's current pricing
   docs for the specific endpoint, or test it directly, before writing integration code.
   Prefer free over cheap, and prefer a service with no paid tier at all over a "free tier"
   of a commercial one when both fit the need.
4. **Ask one minimal, batched round** covering (a) those open decisions and (b) how
   load-bearing this build is:
   - **Crucial / day-to-day infrastructure** (something Tyler will depend on running
     correctly) → every phase from here on pauses for his review.
   - **Simpler / lower-stakes** → plan fully, then build straight through with only
     brief phase-transition updates and a final report.
   Keep this round small — a couple of questions, not a re-run of Planner's interview.

## Phase 2 — Plan

Write the **complete, dependency-ordered** todo list for the entire build, start to finish
— every phase below, not just the next step — before marking anything in progress. Order
by real dependencies (e.g., build the piece other pieces reference first), not necessarily
the order the spec lists things in.

- **Crucial:** show the plan, get a go-ahead before building.
- **Simpler:** proceed straight to Phase 3.

## Phase 3 — Build

Construct each artifact in dependency order. If the artifact is itself a Claude Code skill,
follow `skill-builder`'s Build Phase conventions (frontmatter, structure, `CLAUDE.md` entry).

- **Crucial:** pause after each artifact/component. Report concretely what was just built,
  offer **one or two** specific ideas for making it better — things the plan didn't
  anticipate, spotted while actually building it — and ask only if something needs a real
  decision. Wait for a go-ahead before the next component. Don't flood this with more than
  a couple ideas per phase; Tyler reads them and picks what's worth folding in.
- **Simpler:** build straight through, one brief update per component.
- **Keep the main build thread clean.** If a tangential question or side-research comes up
  mid-build (a random "how does X work" or a research tangent that isn't the next build
  step), spin off a subagent (the `Agent` tool) to chase it down instead of burning the
  main thread's context on it — it works its own blank context window and only its final
  answer comes back to Tyler. Same for condensing/summarizing context. This is something
  the builder does on its own; it's not a step Tyler has to manage. Matches the AIOS's own
  token-efficiency priority.

## Phase 4 — Wire up

1. **Document each new artifact** wherever it needs to be indexed — `CLAUDE.md` for a new
   skill, a README for a new script/app, etc. For a standalone (non-skill) build — an app,
   dashboard, or script living in its own Desktop folder — also write a short, pruned
   `CLAUDE.md` at the project root alongside the README: just what a future Claude Code
   session opened in that folder needs to know (key context, conventions, gotchas). The
   README is for a human/GitHub reader; this is for the next Claude session. Keep it tight —
   nothing useless or overly restrictive.
2. **Package the project's own docs to fit what this project actually needs** — don't
   default to a fixed multi-file shape just because one exists elsewhere in the vault (see
   Phase 1's no-template-hunting rule). For most builds, a short overview/index plus the
   original plan plus a post-build "how it works" note is enough — but size this to the
   project, not to precedent:
   - Overview — short, links to the other files if there are more than one
   - The original spec/checklist from `project-planner`, kept as-is and portable — reusable,
     tweakable, or handoff/sale-ready without needing anything else in the folder
   - A "how it works" note written **after** the build finishes: what actually shipped, how
     to trigger/use it, current status, what's deferred, open questions carried over from
     the plan. For a skill build, include the skill's actual frontmatter (`name` +
     `description`) verbatim — that's the literal trigger mechanism, worth showing plainly
     rather than paraphrasing.
   - If an existing single-file spec is being folded into this structure, verify the new
     plan file's content matches the original (diff it) before removing the old file, and
     only delete it after Tyler confirms — don't delete an Obsidian/vault file unprompted.
3. **Sync ClickUp.** For each checklist step just shipped, hand off to `clickup-push` to
   flip that step's task to Complete — never update ClickUp mechanics directly here.
   - **Known gap (as of 2026-07-26):** `clickup-push`'s `push-plan` doesn't yet persist a
     step → ClickUp-task-ID map anywhere this skill can read it back later. Until that's
     added to `clickup-push`, this sync step can't actually run — say so plainly and skip
     it rather than guessing a task ID.

## Phase 5 — Real-data pass

Run the build against real, current data/state as its actual first use — not a
hypothetical dry run. If migrating or backfilling something (a stale index, an unsorted
folder), do that migration for real here.

## Phase 6 — Test

Invoke the built thing for real, end-to-end — not just a re-read of its own instructions.
Confirm guardrails and hard rules hold against real edge cases (a missing file, a weak
match, an ambiguous case) rather than only the happy path.

**Evolve build:** also re-check the Phase 1 baseline — the parts of the project the
change-spec wasn't touching. "Done" for an evolve build means the change works AND nothing
that worked before got broken, not just the new thing in isolation.

**Whichever mode:** if this test confirms something the project's own docs currently list
as "not yet verified" or a placeholder, update that doc right now to say so — don't let
Phase 7's report be the only record. The project's own docs are what a future
`project-evolve` pass reads in its Phase 1; a stale doc undermines that.

## Phase 7 — Report + reflect

1. Give a concise final summary tied back to the spec's own "done and working" bar — what's
   built, what's tested, what's deliberately deferred and why. **State the actual git/deploy
   status explicitly** — committed? pushed? live at a real URL, or still local-only? Never
   leave Tyler to ask "so is this actually live?" separately; a finished build isn't done
   until this is said plainly, even if the honest answer is "nothing's pushed yet." (Caught
   2026-07-29 on the habit-tracker evolve build — the final report covered what was built
   and tested but never mentioned the code was still sitting uncommitted, and Tyler had to
   ask directly.)
2. Offer one or two ideas for how the finished thing could be even better — same spirit as
   the Phase 3 check-ins, but for the whole build now that it's done.
3. Separately, **only if this build hit something the current Builder process didn't
   already cover** (a new build type, a new kind of guardrail, a new gap like the ClickUp
   one above) — ask whether this skill itself should be upgraded. Routine, repeat-shape
   builds just get the report; no reflection ritual every time.
4. Update any project-status memory so the next session picks up from an accurate state.

## Guardrails

- Never skip Phase 1's real-environment survey — building from the spec's text alone is how
  drift happens (e.g., an index file the spec assumed was current but wasn't).
- Never auto-start right after `project-planner` finishes — Phase 0 always waits for an
  explicit, separate signal from Tyler.
- Simpler builds still get the full ordered plan in Phase 2 — the stakes decision changes
  how often this skill pauses to check in, never whether the plan is complete.
- Don't invent ClickUp update mechanics inline if the ID-mapping gap in Phase 4 isn't
  resolved — flag it, don't fake it.
- Keep improvement ideas at one or two per check-in — this is a chance for Tyler to catch
  things, not a running commentary.
- **Never render a raw exception/error message in anything client-facing** (a web page, a
  log a user might screenshot) if the code touches API keys or secrets — exception text
  often includes the full request URL, which includes the key as a query param. Log the
  real error server-side only; show a short, generic, safe message to the user. (Shipped
  this bug for real during the gold-trading-dashboard build, 2026-07-26 — caught and fixed
  it, but it should never happen in the first place.)
- **An SSL/certificate error from a Bash/PowerShell tool call is usually a real, fixable
  local issue — diagnose it, don't wave it off as "the sandbox isn't the real machine."**
  That was this repo's working assumption until 2026-07-27, and it was wrong: a recurring
  `SSLCertVerificationError` (first seen, unresolved, on the gold-trading-dashboard build)
  turned out to be Norton Antivirus's HTTPS-scanning feature re-signing traffic with its
  own certificate — genuinely diagnosable by checking DNS resolution (rules out routing),
  then inspecting the actual presented certificate's issuer (`openssl s_client -connect
  host:443 | openssl x509 -noout -issuer`). Fixed for real with the `truststore` package
  (see `decisions/log.md` 2026-07-27) — not by disabling verification. Bash/PowerShell
  tool calls DO run on the user's real machine (this is how every file in this repo gets
  created/edited) — treat a network failure as real and diagnosable first. Only fall back
  to "have the user verify directly" if the actual cause genuinely can't be determined
  from here, not as the default first move.
- **`netstat`/process state seen through these tools may not reflect what's running on the
  user's actual machine** in every case — if a PID/port check seems to contradict what the
  user reports seeing, say so and ask them to check directly, rather than trusting the tool
  output as more authoritative than their own eyes.
- **For any installable web app (PWA/`manifest.json`) build, verify `start_url`, `scope`,
  and every icon `src` in the manifest actually resolve to a real file relative to the
  manifest file's own location — not just that each file independently returns 200.** Per
  the Web App Manifest spec, these paths resolve relative to where `manifest.json` itself
  sits, not the page that links to it or the site root. On the habit-tracker build
  (2026-07-27), the manifest lived in `public/`, and `start_url: "./index.html"` silently
  resolved to a nonexistent `public/index.html` — every file still returned 200
  individually, so a plain "does every asset load" smoke test passed clean, and the bug
  only surfaced for real once Tyler tapped "Add to Home Screen" on his phone and it locked
  in the broken launch target. Test this by computing the resolved URL for each manifest
  path (manifest's own location + its relative path) and requesting *that* URL directly —
  not just the files as they already sit.

## What this skill explicitly does NOT do

The 10 core questions, spec-writing, or picking a folder structure — all `project-planner`
territory, upstream of this skill. Talking to the ClickUp API directly — always hands off
to `clickup-push`. Deciding whether something is even a project worth building — that
decision is made before this skill is ever invoked.
