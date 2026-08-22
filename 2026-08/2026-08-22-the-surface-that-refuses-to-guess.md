# 2026-08-22 — The surface that refuses to guess, and four tests that were green about nothing

**`qn.9`'s surface shipped in three slices. Almost every decision in it was about NOT collapsing
two states into one message, which is the rung's own subject — and the tests protecting those
decisions failed at it twice, in the same way, on the same afternoon. Both were found by mutating
the code rather than by reading the tests.**

## What the rung is for, in one remark

The Operator, seeing `qn.8`'s file browser render a real backup: *"this is just test UI, it's not
going to be in the end product."* The answer is a screen that says what a backup **is** rather than
which files it holds. The browser is not deleted — D9 is explicit — it moves one click behind the
overview and stays as the escape hatch for a domain no viewer models.

## Three slices

**Slice 6, the pre-unlock tier.** Three plists in an iOS backup are readable with no password, so a
version can describe itself before it is opened. `GET /api/versions/{id}/overview` — the one
vault-surface route with no session.

**Slice 10a, the surface.** `/versions/:id` becomes the version's page. The row in the version list
now points at it.

**Slice 10b/10c, the unlocked tier.** Per-app sizes with the remainder row that makes them add up,
then the four-state capability report.

## The decisions were all one decision

Nearly every choice in this rung was *do not collapse two states*:

- **`file_count` is an explicit `null`.** The index is encrypted, so no passwordless read can count
  it. A `0` says *quince looked and there is nothing* about a perfectly good backup.
- **A size that is not known yet is `counting…`.** Not a blank, which reads as nothing here; not a
  zero, which reads as a measurement and would be wrong about every app for the length of the walk.
- **An installed app with no data** is a third thing again, distinct from a small app and from a
  pending one.
- **Absent is not empty.** No `Info.plist` means quince cannot know the app list; that is a
  different statement from a backup holding no apps.
- **Corrupt is not absent.** A `Manifest.plist` that will not parse is a broken backup; reporting
  `present: false` says the backup simply has none, which is false about the user's data.
- **The capability report has four states because it has four remedies.** Folding `unreadable` into
  `unsupported_schema` sends somebody to file an issue against a corrupt file; folding `absent` into
  either says quince failed when nobody failed.

## The field the spec asked for, which quince must not show

Story 1, D2(b) and interface fact 2 all specified `Status.plist`'s **`IsFullBackup`**. Quince's own
storage subsystem refuses that field at seven sites as lab finding #9(a): **a first, genuinely full
backup writes `IsFullBackup:false`**. The surface would have read *"Incremental"* on precisely the
backup a user is most likely to be checking, with every rendered word taken faithfully from the file.

`wire.Version.Kind` already carried the honest answer — from the seed sentinel, on a **frozen
contract field already served**. So the correction was *delete a field from the spec*, not *read a
different source*.

The ruling settled the hard case too: **an adopted version renders `unknown` as itself, and
`IsFullBackup` may not be consulted to rescue it.** *"`unknown` means quince does not know;
`IsFullBackup` does not know either, and it is wrong in the specific direction that matters most."*

## Four tests that were green about nothing

This is the part worth keeping.

**1. The spec's slice table said slice 6 was in review; it had merged. It said slice 10 was not
open; it was this work.** The table carries its own instruction — *update it in the diff that
changes what it describes* — and I quoted that instruction in one PR while following it, then opened
the next touching zero doc files. Third instance of that shape in this rung and the first one I
caused, hours after writing a journal entry about exactly it.

**2. A corrupt `Manifest.plist` read as absent, with nothing to catch it.** Found by the architect
mutating the parse failure to report absence: the whole suite stayed green. The root cause is
structural and worth more than the fix — **`internal/vault/preunlock` had no test files at all**, so
its error paths were covered only as far as a `vaultsvc` fixture happened to construct one, and none
wrote a corrupt plist.

**3. The `AppDomainGroup-` test could not reach its own branch.** The fixture used a group id
matching no installed bundle, so the row reached the remainder through the **no-owner** path and the
exclusion it was named for was never exercised. Adding the group prefix as a third recognised one
left the entire suite green.

**What made this one worse than a gap:** the PR body offered *"the tests say exactly what changes"*
to a reviewer considering overruling that rule. True of the neighbouring half; false of this one.
**An invitation to overrule, backed by a test that cannot see the thing being overruled**, actively
misinforms the decision it invites.

**4. Story 6's *held* half had nothing behind it** — and was located from the author's own comment,
which had separated precisely which half was structurally safe (the key carries the session id, so
nothing wrong is ever *displayed*) and which needed the explicit `removeQueries` (retention, because
`staleTime` leaves data held for the default `gcTime`). Both halves were written down. Neither was
tested.

## And a red test that was wrong in the opposite direction

The architect recorded its own vacuous mutation while finding #3: it first mutated by **replacing**
the plugin prefix with the group prefix, saw a test fail, and nearly reported the group rule as
covered. The test that failed was *"folds an app's plugin container into that app"* — which proves
plugins broke and says nothing about groups.

**A red test is not evidence unless it is the red test the claim is about.** That is the general
form, and it is the failure mode of mutation testing itself: a mutation is only as good as the
mapping from mutant to expected victim. The habit that follows is cheap — **name the expected victim
before running the mutation**, not just the mutation. The last slice was done that way and both
mutations landed where predicted.

## What the arithmetic cost

D3 rules that *"apps"* means the 21 user-installed bundles and that the other 1,243 domains are
aggregated into a named row so the numbers reconcile. It does not say **which** domains are an
app's, and that turned out to be the load-bearing detail:

- `AppDomain-<id>` and the app's own `AppDomainPlugin-` are that app's;
- **`AppDomainGroup-` is nobody's** — a group container is shared between apps by design, so
  attributing it to one presents a guess as a measurement and splitting it double-counts;
- longest match wins, because bundle ids nest and first-match puts a plugin's bytes on its parent;
- a match must end on a dot boundary, or one app claims another whose id merely starts the same way.

**Every domain is counted exactly once**, which is what makes the reconciliation assertable at all.
And it is asserted **at render**, not only in a test: what the partition counted must equal what the
server counted before any figure is shown as final, and a disagreement is disclosed rather than
shown as a plausible wrong total.

## What is owed

**G7 — the rung's acceptance gate — is owed to the Operator and is NOT ticked.** Overview against
the real backup, spot-checked against iMazing. The merged work is deployed to the staging stand and
verified there — running binary and served bundle both checked rather than inferred from an image
tag — so the gate is takeable, but nothing in CI can take it.

**The devlog dashboard is stale for `qn.8` as well as `qn.9–10`**, both still reading `outlined`.
That row spans two rungs and `qn.10` has not started, so it is not a one-word fix.
