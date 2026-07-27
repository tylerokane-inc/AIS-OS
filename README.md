# Tyler's AI Operating System — built on Claude Code

This turns Claude Code into your personal **AI Operating System (AIOS)**. Audience: anyone building automations — solopreneurs, small business operators, managers, creators, AI consultants.

The kit personalizes itself to you via an `/onboard` interview, then gives you two recurring thinking skills (`/audit`, `/level-up`) to keep building leverage week over week.

---

## The litmus test

> **"While you're not at your desk, your AIOS observes one real-world event and produces an output that's faster and more accurate than what you'd produce yourself."**

Every design decision in this kit rolls up to that test. If a layer, skill, or template doesn't contribute to it, it doesn't ship.

---

## How you'll know it's working

Three felt **success indicators** tell you the AIOS is actually changing how you work. Not KPIs — there's no objective metric. These are lived experiences that show up in your week.

**1. Team-reaches-out:**

> *"A teammate messages you with a question. You realize your AIOS would answer it better, faster, and with exact sources — even if you were awake and free. So you ask your AIOS too. That's the moment you stop being a bottleneck for your own knowledge."*

**2. Context-switching reduction:**

> *"You stop opening new tabs. You stop launching the desktop app. When something new lands, your first move is to ask the AIOS, not to open six things. The default surface for thought work shifts. Silent. Compounding."*

**3. Knowledge-leaves-your-head:**

> *"You stop trying to remember business facts. You don't rehearse what you decided last quarter or what your customer said in that meeting. You trust the retrieval. The AIOS holds the truth, you hold the questions."*

**Personal foundation → company AI-readiness.** Once these indicators show up for one person, the same data architecture powers everything else. Custom dashboards on the data you already collect. Automations on top of the connections you already wired. Team rollout where everyone has theirs. *A company where every operator runs a personal AIOS is a company that's actually AI-ready.*

The kit teaches personal AIOS first. Everything scales from there.

---

## Two frameworks

The kit teaches two complementary frameworks. **Operator Loop first, Four Pillars second.** Without the brain rewire, the architecture is just a folder structure.

### The Operator Loop — operator brain (how you think)

| Stage | One-liner |
|---|---|
| **Think** | Default Shift, Function Breakdown, Curiosity Rule. *To what extent can AI be leveraged here?* |
| **Decide** | Find Constraint → EAD (Eliminate, Automate, Delegate) → Map Process → Pick Autonomy Level → Tie to KPI. |
| **Build** | Lego Principle, Validation Chain, Bike Method, Intern Rule, Kill Switch. *Boring is beautiful. Workflows beat agents.* |

Full breakdown in `references/operator-loop.md`. The `/level-up` skill walks you through all three weekly.

### The Four Pillars — architecture (what you build)

| # | Pillar | One-liner | "This pillar is in place" test |
|---|---|---|---|
| 1 | **Grounding** | Knows your business | Fresh Claude session answers "what does this business do and who works here?" without browsing |
| 2 | **Reach** | Reaches your stuff | "What's on my calendar tomorrow and what tasks are due?" → live data, no paste |
| 3 | **Toolkit** | Knows how to do the work | A short phrase triggers a multi-step workflow that produces an artifact |
| 4 | **Rhythm** | Runs without being asked | Laptop closed. A brief lands in the inbox. A teammate messages it and gets a real answer |

**Brand line:** Grounding. Reach. Toolkit. Rhythm.

Dependency graph: Grounding is non-skippable. Reach + Toolkit can build in parallel. Rhythm is last — don't automate workflows that don't work manually.

---

## What ships — 3 skills

The kit is intentionally lean. Skills here are ideation prompts and thinking tools, not heavy automations. You hack on top of the structure.

| Skill | Type | When to run |
|---|---|---|
| `/onboard` | Setup wizard (one-time) | Day 1, immediately after clone. 7-question interview. Generates Day-1 file set + fills `CLAUDE.md`. |
| `/audit` | Recurring thinking skill | Day 7, then weekly. Four Pillars gap report. Read-only. Watch the score climb. |
| `/level-up` | Recurring thinking skill | Day 14, then weekly. Operator Loop interview (Think → Decide → Build). One run = one shipped artifact. |

`/audit` asks *"is the AIOS built right?"* (form). `/level-up` asks *"what business leverage am I missing?"* (function). They work in series — fix structure first, then capability planning becomes meaningful.

---

## Quick start

1. **Clone the repo** to a working folder on your machine.
2. **Open it in Claude Code** and run `/onboard`. Answer the 7 questions honestly. Voice samples must be pasted, not described. Takes ~15 minutes. Day-1 file set drops at the end.
3. **Use it for a week.** Bring real questions. Make real decisions. Log them via `/decision` (or just append to `decisions/log.md`).
4. **Day 7:** run `/audit`. Read the Four Pillars gap report. Pick one gap to close.
5. **Day 14:** run `/level-up`. The Operator Loop interview surfaces one automation worth building. Build it.
6. **Week 3+:** weekly `/level-up` ritual. One shipped artifact per week.

---

## Repo layout

```
AI Operating System/
├── README.md
├── CLAUDE.md                        ← Your operating manual (filled by /onboard)
├── EXPANSIONS.md                    ← What to add as you grow
├── .gitignore
├── aios-intake.md                   ← Source-of-truth for /onboard. Edit + re-run any time.
├── connections.md                   ← Registry of every system your AIOS can reach
├── context/                         ← About you, your business (filled by /onboard)
├── references/
│   └── operator-loop.md             ← The operator brain
├── decisions/
│   └── log.md                       ← Append-only record of what was decided and why
├── archives/                        ← Old stuff. Don't delete. Move here.
└── .claude/
    └── skills/
        ├── onboard/SKILL.md
        ├── audit/SKILL.md
        └── level-up/SKILL.md
```

See `EXPANSIONS.md` for what to add as you grow (`projects/`, `templates/`, `scripts/`, `.claude/agents/`, sub-OS folders, etc.).
