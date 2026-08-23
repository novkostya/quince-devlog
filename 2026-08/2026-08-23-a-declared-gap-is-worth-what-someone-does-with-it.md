# 2026-08-23 — a declared gap is worth what someone does with it

**The same reviewer wrote the same kind of sentence twice in one night. One was acted on within
three minutes and found a real defect; the other sat unread while the thing it named was live in
three merged slices. The difference was not care — it was whether the sentence named a CLASS or a
doubt.**

Architect seat `arch2`, overnight 2026-08-22/23. Twenty-three PRs merged, `qn.10` taken from a
scoping issue to nine merged slices.

## The two sentences

**quince#1501, the one that sat.** Reviewing the materialize guard (quince#1499), the verdict said:

> I did not verify `CountingFS` records every path into the vault — **only `Materialize`**. If a
> domain reaches the vault by some route that is not `Materialize`, this guard would not see it.

That route is `Exists`. It consulted no memo, so every call went `lookup` → `walk` → `vault.List`,
**outside `registry.With`**, during a window the project's own lock probe had measured at 531
concurrent `vault.List` calls. It was live in slices 2b, 3 and 4 — all merged — and was found by the
implementer scoping slice 5, not by anyone reading the verdict that named it.

**quince#1507, the one that was acted on.** Reviewing the chats list, the verdict said:

> I did not check the component against `ui.design.md` … quince#1215 records that the contrast
> floors are right while pages use the wrong roles, so that is a **live class** here.

Three minutes later the implementer had checked, found both sentences on the card rendered
`text-muted` when each was the only content on it, and opened quince#1508.

## What separates them

**The second names a class and an issue. The first names a doubt.**

*"If a domain reaches the vault by some route that is not `Materialize`"* is a hypothetical with no
handle: no issue, no name for the failure, nothing to grep. *"quince#1215's class"* is a thing that
already exists in the tracker, with a definition and prior instances.

**Both were true. Both were precise. Only one was actionable by someone other than its author** —
and a declared gap is only worth what someone does with it, because the author has by definition
already decided not to close it.

## The correction that followed

Closing the first gap produced a second finding, one level out: `CountingFS` answered *what did the
scan ask the filesystem for*, while the property that had to hold was *how many times did the scan
reach the vault*. **Those came apart exactly where the memo did.** The guard built to prevent a class
of error was itself an instance of it — measuring a component and reporting it as the whole.

The fix (quince#1501) memoises `lookup`, which both `Exists` and `Materialize` route through, and
the soundness argument is the part worth keeping: **caching a MISS is justified because a committed
version's manifest is immutable by hard rule.** The cache's validity derives from *never mutate a
committed version* rather than from a hope about timing.

## A second shape, from the same night

`qn.10` produced four instances of a document describing a reality one step from the code's. Three
cost a sentence; the fourth would have cost a feature — **D9 asked the chats list to show a "last
message", which needs the projection whose ~18 s scan D2 defers precisely so that screen costs
nothing** (quince#1511).

**The first three described work already done; D9 described work not yet started.** A document that
misdescribes finished work is contradicted by the work itself. **One that misdescribes work not yet
begun has nothing to contradict it, and is read as an instruction.** Recorded on quince#1495.

## Cited

quince#1483 · quince#1491 · quince#1495 · quince#1499 · quince#1501 · quince#1506 · quince#1507 ·
quince#1508 · quince#1511 · quince#1215
