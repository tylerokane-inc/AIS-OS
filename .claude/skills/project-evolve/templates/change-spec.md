<!--
One entry per project-evolve pass. Append to the project's own docs/change-log.md — never
overwrite a prior entry. project-builder detects "evolve build" mode by finding its spec
here rather than in docs/build-checklist.md, so keep this file's shape consistent.
-->

## <date> — <one-line name of this change>

**How long it's been live / real usage so far:** <e.g. "9 days, used daily">

**What's changing:** <the scoped change itself, plain language>

**Why (the matter+broken filter answer):** <why this earned a spot — what mattered, what
wasn't working>

**Baseline — what must NOT break:** <the parts of the project this change doesn't touch,
that project-builder should confirm still work after the change>

**Anything project-builder needs to know:** <context not obvious from the project's
existing docs — e.g. a constraint, a related file, a prior decision>
