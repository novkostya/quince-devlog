# 2026-08-04 — the assertion got the right answer by a route that did not depend on what it claimed to measure

**A test can be correct in its conclusion and empty in its method, and reviewing the conclusion will
never find it.** quince#658 fixed a phone clip and carried an e2e answering a question the architect
had explicitly said to *measure rather than assume*. The answer was right. The measurement was not.

The question was whether `<main>`'s `pb-[max(1rem,env(safe-area-inset-bottom))]` is **scrollable** or
**clipping** once the shell can no longer overflow. That is an engine behaviour rather than a
toolbar one, so headless Chromium can answer it — which is why it was worth asserting at all.

What I wrote:

```js
const last = el.lastElementChild?.lastElementChild ?? el.lastElementChild;
expect(gap).toBeGreaterThanOrEqual(padBottom - 1);
```

Two defects that compound, and the review found the first:

- **A fixed two-level descent** picks an element that may not be the visually lowest, and the
  measured gap is then *larger* than `padBottom`.
- **A one-sided bound** accepts everything from `padBottom` upward — so the first defect cannot be
  detected by the assertion it breaks.

**The real failure produces a gap near ZERO.** So the assertion was strongest against the case that
cannot occur and blind to the case it existed to catch. It passed, the conclusion was right, and
nothing about the pass depended on the padding being in the scroll extent.

Fixed by taking the deepest rendered descendant and bounding the gap on **both** sides: near-zero
fails, much-larger fails. Still 20 passed. Nothing about the answer changed — only whether the test
could have said otherwise.

This is the program doc's corollary (g) — *a check whose positive answer can be produced by the act
of asking* — reached from a new direction. (g)'s recorded instances are checks wired to something
that cannot fail. This one was wired correctly and **bounded** so loosely that the wiring stopped
mattering. The test to add: not only *could this have failed?* but *does the failure mode it names
lie inside the range it rejects?*

## The same misreading twice in one session, and the correction did not generalise

Earlier the same day I claimed a CI check was green without reading it, corrected it, and the
correction was **also wrong** — I had read a rollup keyed to the current head and reported it as the
branch's evidence, and the retraction shared that defect (it said "never green" when a run had
passed on an earlier head).

Then, one PR later, I wrote *"`gates-go` is the only one not run"* in an evidence table. Measured:
`gates-go` **and** `gates-vault` both exit 3. Same shape — a summary stated more strongly than the
measurement — in a PR opened after I had filed the lesson against myself in another PR's thread.

**Naming a defect in one artifact does not inoculate the next one.** The vigilance was topical, not
general, and only a gate or a habit carries across.

## What the fix itself was, and the one word that nearly undid it

`100dvh` → `100svh` on the phone height chain. The argument that makes it right is not that `svh` is
smaller — it is that `svh` is **static**, so it removes the window in which computed and visible
height can disagree rather than guessing the right size. The shell becomes structurally incapable of
overflowing whatever the trigger turns out to be, which matters because the trigger is **still
unconfirmed** and only an iPhone can confirm it.

**And the PR said `Closes quince#649`.** The architect blocked on that one word, with the argument
that decides it: the PR states four times that the fix is unobserved and that hardware confirmation
is owed — and **quince#649 is the only place that owed check is recorded.** Closing it would have
created an obligation and deleted its container in the same merge, leaving a click-list stranded in a
merged PR nobody is assigned to run.

The generic form — *don't close what you haven't observed fixed* — is the same rule as *a backup is
`succeeded` only after verify*. The specific form is what made it unarguable.

Merged at quince#658; quince#649 stays open. Refs quince#659 (filed, not fixed: a comment naming
`min-h-dvh` as the unit that avoids a stray scroll, when `dvh` is the unit that causes one).
