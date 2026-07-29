---
name: debug
description: Use when something that used to work is now broken, throwing an error, or behaving unexpectedly — Tyler needs the actual root cause, not a quick patch. Trigger on "this is broken," "I'm getting an error," "why doesn't this work," "it's not working," "help me fix this bug," or pasting an error message/screenshot. Not for planning new work (project-planner) or building something new (project-builder) — this is specifically for diagnosing and fixing something already built that's misbehaving.
argument-hint: [error message, screenshot, or description of what's broken]
---

# Debug

Root-cause-first troubleshooting. The failure mode this skill exists to prevent: patching
the symptom in front of you without knowing why it actually happened — which either doesn't
fix it, or fixes it in a way that breaks again the next time conditions shift slightly.

## Flow

### Phase 1 — Reproduce
Get the failure happening in front of you, for real, before touching any code. If Tyler
pasted an error or screenshot, that's the starting point — but re-run the actual failing
action yourself if possible rather than reasoning from the paste alone. If it won't
reproduce, say so; see "Can't reproduce" below rather than guessing at a fix.

Once it reproduces, **strip it down before diving in** — a stray failure that only shows up
inside a big flow (900 lines, five steps, a large input) hides its own cause. Cut away
whatever isn't required to still trigger it (steps, inputs, config) until what's left is the
smallest case that still fails. The real cause is usually obvious once the noise is gone
(delta debugging / Zeller, *Why Programs Fail*).

### Phase 2 — Isolate
Narrow down *where* the failure lives before deciding *why*. Work outward from the error:
which layer is it actually in — the code just written, an existing dependency, config or
environment, external network/API, or bad/unexpected data?

**Check the boring stuff first.** Most bugs that look mysterious turn out to be one wrong
assumption about something outside the code — a version, a config value, a permission, a
cert, "is it actually plugged in." (Agans' "Check the Plug.") **A network/SSL/cert error
from a Bash/PowerShell call is a real, diagnosable local issue almost every time — never
wave it off as "the sandbox isn't the real machine."** These tools run on Tyler's actual
computer. Check DNS resolution first (rules out routing), then inspect the actual presented
certificate's issuer if it's TLS-shaped (`openssl s_client -connect host:443 | openssl x509
-noout -issuer`) before assuming anything more exotic. (Precedent: a recurring
`SSLCertVerificationError` on the gold-trading-dashboard build turned out to be Norton
Antivirus's HTTPS-scanning feature — see `project-builder`'s Guardrails section.)

**If the search space is large, cut it in half instead of scanning start to end** — which
half of the code/timeline/input still shows the failure? Discard the other half and repeat
(`git bisect` automates exactly this over commit history when "it used to work" is the
starting clue — and when it is, the most recent change is the first thing to suspect, not
the last). Change one variable at a time; don't shotgun several fixes at once and hope one
lands — that teaches you nothing about what was actually wrong.

### Phase 3 — Confirm the root cause before fixing
Build a mental model of what the code is *supposed* to do and find where that model could be
wrong before reaching for logs or a debugger — most wasted debugging time comes from staring
at symptoms without first reasoning about the mechanism (Rob Pike, on Ken Thompson's method).
Then run it as a real experiment: state one hypothesis, predict what a specific check would
show if it's true, run the smallest check that could confirm or kill it, and update — don't
poke around hoping to notice something. If ad-hoc looking hasn't produced an answer in a few
minutes, switch to this loop explicitly rather than continuing to poke (MIT's "10-minute
rule"). Stuck longer than that? Narrate the problem out loud, line by line, as if explaining
it to someone with zero context — the gap between what you assumed and what's actually
there is often the bug (rubber duck debugging).

State the actual mechanism when done — not "it's probably X" but "here's the specific line,
config, or call that produces this specific symptom, and here's how it was confirmed" (a log
line, a reproduced error, a targeted check). If genuinely torn between two causes, say so and
test to disambiguate rather than guessing and fixing both "just in case." On a multi-step
session, keep a short running note of what's been tried and ruled out as you go — not just at
the end — so a dead end doesn't get re-tested twice.

### Phase 4 — Fix
Fix the actual root cause, not the nearest symptom. Keep the fix scoped to the bug — this
isn't the moment for a surrounding refactor or cleanup, even if something adjacent looks
messy. If the real fix turns out bigger than the bug itself (it reveals a structural
problem), say so explicitly and ask before expanding scope.

### Phase 5 — Verify
Re-run the exact original failing case for real — not a re-read of the code, an actual
execution — and confirm it now succeeds. Check the fix didn't break anything adjacent it
plausibly could have touched.

**If the project has its own docs** (`CLAUDE.md`, `docs/status.md`,
`docs/how-it-works.md`, etc.) that describe this as broken or unverified, update that doc
right now, in this same session — don't leave a stale "not verified" note sitting there
for a future session to trip over. (2026-07-29: a habit-tracker doc still said Google
sign-in was "not yet verified" a full session after Tyler had already confirmed it live —
the fix never got written back into the project's own paper trail, only into AIOS-level
memory.)

### Phase 6 — Report
Short report: what broke, what the actual root cause was (not just "fixed it"), what
changed, and whether this points at a deeper pattern worth flagging (e.g. "this is the
second time X has broken this way" is worth an `/improve-system` Skill Review or Experience
entry, not just this one fix).

## Can't reproduce

If the failure won't reproduce, say so plainly rather than guessing at a fix for a bug that
isn't currently visible. Gather what's available (exact error text, timestamps, what
changed recently — `git log`/`git diff` if it's this repo) and narrow the conditions under
which it might occur, but don't apply a speculative fix and call it done — flag it as
unconfirmed and say what would help confirm it next time (e.g. "grab the exact error text
if this happens again").

## What this skill explicitly does NOT do

Plan new work or scope a feature — that's `project-planner`. Execute a fresh build from a
spec — that's `project-builder`. Silently expand a bug fix into a refactor, or add
speculative error handling for scenarios that aren't actually happening (see CLAUDE.md's
core engineering rules) — a debug session fixes the confirmed root cause and stops there.

## Where the technique names above come from

Delta debugging (Zeller), "Check the Plug" and the running-notes habit (Agans, *Debugging:
The 9 Indispensable Rules*), bisection (`git bisect`; Google SRE's troubleshooting guide),
reasoning before touching a debugger (Rob Pike, on Ken Thompson), the 10-minute rule
(MIT 6.031), rubber duck debugging (Hunt & Thomas, *The Pragmatic Programmer*). Researched
2026-07-27 via the `web-scrape` skill — picked for being genuinely distinct from each other
and from the phases above, not restating the same steps in different words.
