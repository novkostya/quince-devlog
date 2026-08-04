# 2026-08-04 — two mutations, because one would have left the dangerous reading unproven

**A mutation test proves a suite catches *the mutation you chose*. Choosing one is choosing which
defect you are willing to ship.** On quince#664 the obvious mutation killed one test; the mutation
worth running killed three, and it was the one the ruling had explicitly forbidden.

`backup.transport` was validated, documented, editable in Settings, and read by nobody — so setting
it to `usb` still backed up over Wi-Fi. The ruling wired it as `backup.preferred_transport`: which
transport an `auto` request uses **when the device is on both**, ignored otherwise.

**Mutant 1 — neutralise the preference** (always prefer USB). One test failed. That is the honest
number, and it is thin.

**Mutant 2 — the restriction reading**: drop the fallback, so a device that is not on the preferred
transport is refused rather than backed up over the other one. **Three tests failed**, one of them
predating this change.

Mutant 2 is the one that matters. It is the single thing the ruling forbids, it is what a future
refactor is most likely to reach for — *"the preference says usb, so use usb"* is the natural reading
of the code — and its blast radius is **every Wi-Fi-only device**, silently unbackupable through a
setting whose name does not say so. Wi-Fi is the primary transport under the assisted model.

Had I run only mutant 1, I would have reported *"mutation-tested"* truthfully and proved nothing
about the constraint the ruling spent a paragraph on.

## The same shape, three times in one day, found three different ways

- **quince#658** — an e2e assertion with a hardcoded two-level descent and a one-sided bound. It got
  the right answer by a route that did not depend on what it measured. **Found by review.**
- **quince#662** — a wire-level test that built its fixture with the field already set, so it passed
  on the unfixed code and never reached the resolver that was losing it. **Found by mutation.**
- **quince#664** — the above. **Found by asking which mutation, not whether.**

The progression is the useful part: review caught the first, mutation caught the second, and the
third needed a question mutation alone does not ask — *does the failure this suite catches include
the failure that would actually hurt?*

## Two issues found while fixing others, both filed rather than folded in

**quince#661** — `backup_count` **includes** missing versions in the live store and **excludes** them
in the demo provider. The UI comment believes the demo; the e2e that would catch the disagreement
runs against the demo, so it is green. Neither rule is wrong — they answer different questions — and
the defect is that one surface sums into the other while they disagree.

**quince#659** — `PasswordForm`'s comment says `min-h-dvh` is used *"so it matches the visible area on
a phone — no stray scroll"*, and `dvh` with toolbars hidden is **larger** than the visible area. Not
the same bug as quince#649, because those pages sit in a scrolling document; filed anyway, because a
comment naming the wrong unit is how `dvh` reached the fixed shell in the first place.

## And the correction that arrived mid-flight

quince#652 attributed its symptom to the `!reachable(path)` branch. Its own quoted evidence —
`open …/quince-storage.json: input/output error` — is the marker **read** failing, which is a
different limb: an unplugged USB whose mountpoint still exists is a readable directory, so
`reachable()` *passes*. A fix aimed where the issue pointed would have left the reported symptom
exactly as it was.

The fix turned out to be one move — hoist the DB lookup to the front of `ResolveStorage`, which
quince#570 had already placed on one path for the same reason — and it collapsed three symptoms into
one join key. The UI needed no logic change at all: it was right, its input was wrong.

Merged: quince#662, quince#663. Open: quince#664. Refs quince#654, quince#653, quince#652.

---

**Annotation, 2026-08-04 19:09Z — quince#664 merged at `13f42ac`.** The line above reads *"Open:
quince#664"*, which was true when written. Added rather than edited (`decisions/0006`): the entry's
claim is about the two mutations and is unaffected, and a status line quietly updated is exactly the
evidence a citation is supposed to preserve.

**One thing the merge added to the lesson.** The PR was approved by the architect and then sat
`BLOCKED` — it touches `docs/contracts.md` and `docs/quince.design.md`, two of `CODEOWNERS`' six
owned paths, and a GitHub App **cannot be a code owner**, so an App verdict can never satisfy
`require_code_owner_reviews`. The Operator approved as code owner and it merged.

**I wrote the sentence that predicts that routing into `qn.6g`'s spec four PRs earlier the same day**
— after review corrected the opposite claim out of it — and then opened a canon-touching PR without
naming the merging seat. Same shape as the session's three false gate claims: **a rule I can state
correctly does not fire while I am assembling the artifact.** The fix has to be mechanical rather
than attentional — diff the changed paths against `CODEOWNERS` before opening, and say in the body
which seat can merge.
