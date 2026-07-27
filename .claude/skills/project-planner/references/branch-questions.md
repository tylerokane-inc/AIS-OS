# Branch Questions (by build type)

After the 10 core questions, pick the matching set below.
Same rules: medium batches, short "why" notes, no skipping.
These answers become the "How It's Built" section of the spec doc.

If the project is a mix (e.g. an app WITH a dashboard), run both sets.

---

## A) APP (web / mobile / desktop)

1. **Which platform?** Web, phone, desktop, or more than one? (Start with one for v1.)
   *Why: each platform is a different build. Pick one to ship faster.*
2. **What are the main screens?** List them. (e.g. Home, Login, Profile, Settings.)
   *Why: screens are the rooms of your app. Naming them = your first map.*
3. **What's the ONE main action** a user takes? (The thing they open the app to do.)
   *Why: the whole app should make this action easy. Everything else is support.*
4. **Do users need accounts / login?** Yes or no for v1.
   *Why: login adds real work. Skip it in v1 if you can.*
5. **What data does it store,** and where? (A list, their profile, saved items...)
   *Why: knowing your data now stops messy rebuilds later.*
6. **Does it need the internet / other services?** (Payments, maps, email, AI...)
   *Why: outside services are extra setup. List them before building.*
7. **What does the home screen show first?** (First thing a new user sees.)
   *Why: first screen = first impression. Worth getting right.*

## B) DASHBOARD

1. **Where does the data come from?** (A file, a connector, an app, live API.)
   *Why: no data source, no dashboard. This is step zero.*
   *If it's a live API: prefer free options, and confirm on the provider's current pricing
   page that the SPECIFIC endpoint needed is actually included free — not just that the
   provider "has a free tier." Free tiers routinely gate the exact data you need behind a
   paid plan.*
2. **What are the key numbers (KPIs)** you want to see at a glance? List 3-6.
   *Why: a dashboard is about a few numbers that matter, not all of them.*
3. **Charts, tables, or both?** For each number, how do you want to see it?
   *Why: the right shape makes data readable in 2 seconds.*
4. **How often does it refresh?** Live, daily, on-click?
   *Why: "live" costs more work. Match refresh to how fast the data really changes.*
5. **Do you need filters?** (By date, category, person...)
   *Why: filters turn one view into many. Decide which ones earn their keep.*
6. **Who reads it,** and on what screen? (You on a laptop, a team on phones...)
   *Why: layout changes a lot between phone and desktop.*

## C) PLUGIN (for Claude / Cowork)

1. **What does it bundle?** Skills, tools, connectors, or a mix?
   *Why: a plugin is a package. Knowing the parts defines the whole.*
2. **What trigger phrases** should turn it on? (What will you type/say?)
   *Why: good triggers = it fires when you want, stays quiet when you don't.*
3. **What does each skill do,** in one line each?
   *Why: one clear job per skill keeps the plugin easy to use and fix.*
4. **What does it need access to?** (Files, calendar, a connector, the web...)
   *Why: access = permissions and setup. List it up front.*
5. **What's the output** each time it runs? (A doc, a message, a folder...)
   *Why: knowing the finished result keeps every part pointed at it.*

## D) CONNECTOR (links Claude to an outside service)

1. **Which service / app / API** does it connect to?
   *Why: the whole connector is shaped by the service it talks to.*
2. **Read, write, or both?** (Just pull info, or also change things?)
   *Why: write access is higher-stakes. Be clear and careful.*
3. **What are the main actions** you need? (e.g. "list items," "create item.")
   *Why: a short action list keeps the connector small and solid.*
4. **How does it log in (auth)?** API key, OAuth, token? (Check the service's docs.)
   *Why: auth is usually the hardest part. Sort it early.*
5. **Any limits to respect?** (Rate limits, paid tiers, private data.)
   *Why: hitting a hidden limit mid-build is a classic time-sink. Prefer a genuinely free
   service over a paid one, and confirm on the provider's current pricing page that the
   exact endpoint needed is free — don't assume from a general "free tier" impression.*

## E) CLAUDE CODE SKILL / INTERNAL AUTOMATION (runs inside this repo, not a separate app)

1. **What judgment call does it make each time it runs?** (e.g. "decide which project a note
   belongs to") — name the hard part, not just the mechanical steps around it.
   *Why: this is usually why it needs to be a Claude Code skill instead of a plain script —
   name the judgment so we don't accidentally build a dumb script for a smart problem.*
2. **What triggers it?** Manual only (a phrase Tyler says), scheduled (runs on its own), or
   both? If both, what's manual vs. automatic?
   *Why: automatic triggers are a bigger commitment — get explicit sign-off on what's allowed
   to run without Tyler asking.*
3. **What does it read, and what does it write/change?** Be specific about files/folders.
   *Why: this is where accidental damage happens — know the blast radius before building.*
4. **What's the accuracy/safety bar?** What happens when it's unsure? (Should always be:
   flag for review, never guess-and-act — see the Safety rule below.)
   *Why: for anything editing Tyler's real files/notes, a wrong guess is worse than no action.*
5. **Does it depend on another system being in place first** (e.g. a vault structure, an
   index file)? If that dependency doesn't exist yet, is creating it part of THIS build?
   *Why: catches chicken-and-egg gaps early instead of mid-build.*

## F) OTHER / GENERAL TOOL OR SCRIPT

1. **What goes IN?** (The input: a file, some text, a number...)
2. **What comes OUT?** (The result you want.)
3. **What's the ONE transformation** in the middle? (In → magic → Out.)
   *Why: most tools are just "take this, give back that." Naming all three makes it buildable.*

---

## After the branch set

1. Summarize "How It's Built" back to Tyler in a few sentences.
2. Move on to picking the folder structure (`folder-structures.md`).
3. Then fill the templates (`../templates/spec-doc.md` and `build-checklist.md`).
