# Pro Folder Structures

Goal: when Tyler pushes a project to GitHub, anyone who sees it thinks
"this person knows what they're doing." Clean, predictable, everything in its place.

## The golden rules (teach these)

1. **One root folder per project**, named in `kebab-case` (lowercase, dashes): `workout-tracker`, not `Workout Tracker`.
   *Why: spaces and capitals break things in code and on servers. Dashes never do.*
2. **README.md at the root.** It's the front door — what the project is, how to run it.
   *Why: it's the first thing GitHub shows. No README = looks abandoned.*
3. **Group by job, not by random.** Code with code, docs with docs, images with images.
   *Why: when you need a file, you know the room it's in without searching.*
4. **`docs/` holds the plan.** Spec doc and build checklist live here.
   *Why: keeps planning separate from code, but shipped together.*
5. **`.gitignore` from day one.** Lists junk Git should ignore (secrets, `node_modules`, build files).
   *Why: keeps secrets and huge auto-made folders out of your public repo.*
6. **Never hard-code secrets.** Keys/passwords go in a `.env` file that `.gitignore` hides.
   *Why: a leaked API key can cost real money. Rule one of looking pro.*

Always create the folder empty first with a matching template below, then fill it during the build.

---

## Web app

```
project-name/
├── README.md              ← what it is + how to run
├── .gitignore             ← files Git should skip
├── .env.example           ← lists needed secrets (no real values)
├── docs/
│   ├── spec.md            ← the plan (from this planner)
│   └── build-checklist.md ← the step-by-step build list
├── public/                ← images, icons, fonts the browser loads
├── src/                   ← all your code lives here
│   ├── pages/             ← one file per screen (Home, Login...)
│   ├── components/        ← reusable pieces (Button, Card, NavBar)
│   ├── lib/               ← helpers + logic (not visual)
│   ├── styles/            ← CSS / design files
│   └── assets/            ← images used inside the code
└── tests/                 ← files that check your code works
```
*Teach: `components` = LEGO bricks you reuse. `pages` = full screens built FROM those bricks. `lib` = the brains behind the scenes.*

## Mobile app (same idea, screens instead of pages)

```
project-name/
├── README.md
├── .gitignore
├── docs/  (spec.md, build-checklist.md)
├── src/
│   ├── screens/           ← full screens
│   ├── components/        ← reusable UI pieces
│   ├── navigation/        ← how screens link together
│   ├── lib/               ← helpers + data logic
│   └── assets/            ← images, icons
└── tests/
```

## Dashboard

```
project-name/
├── README.md
├── .gitignore
├── docs/  (spec.md, build-checklist.md)
├── data/                  ← sample/raw data files
├── src/
│   ├── charts/            ← one file per chart
│   ├── components/        ← cards, filters, layout pieces
│   ├── lib/               ← fetch + clean the data
│   └── styles/
└── tests/
```

## Plugin (Claude / Cowork)

```
plugin-name/
├── README.md
├── .plugin.json           ← plugin's name + settings (the "ID card")
├── skills/
│   └── skill-name/
│       ├── SKILL.md       ← what the skill does + how
│       ├── references/    ← extra info the skill reads
│       └── templates/     ← files it fills in
└── connectors/            ← any bundled connectors (if used)
```

## Connector

```
connector-name/
├── README.md
├── .env.example           ← the API key it needs (no real value)
├── src/
│   ├── client.js          ← talks to the outside service
│   ├── actions/           ← one file per action (list, create...)
│   └── lib/               ← shared helpers
└── tests/
```

## Small tool / script

```
tool-name/
├── README.md
├── main.py (or main.js)   ← the one file that runs it
├── lib/                   ← helpers if it grows
└── tests/
```

---

## How to use this in the planner

1. Match the build type to a template above.
2. Show Tyler the tree and explain 2-3 folders in plain English (short why-notes).
3. Create the real folder + subfolders on the Desktop (empty), then drop `spec.md`
   and `build-checklist.md` into `docs/`.
4. Remind him: the actual CODE gets built later in Claude Code — this planner sets the stage.
