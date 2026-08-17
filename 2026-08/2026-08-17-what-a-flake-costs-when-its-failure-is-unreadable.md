# 2026-08-17 — what a flake costs when its failure is unreadable

**`Expected: 200 / Received: 948` kept three sessions and thirteen days from telling which of two
assertions had fired — and they are different bugs. The number was never the problem; the silence
around it was.** quince#974 / quince#975, and quince#1096.

`story12`'s in-page-back-link test has two `toBe(OFFSET)` assertions: one that the **setup** scroll
took, one that the **traversal restored** it. A failure in the first means something moved the page
after the test scrolled it. A failure in the second means the browser restored the wrong position.
`expect.poll(() => window.scrollY).toBe(200)` reports neither — no page, no document height, no
history index, and no call site.

**What that ambiguity cost is measurable, and it is not the diagnosis time.** The issue stayed open,
so the thread became the place people filed *anything* that looked like it — and the next three
sightings were a **different test with a different signature** (`Received: 0`), which turned out to be
its own bug with its own mechanism and its own fix (quince#1048, quince#1075). An unreadable failure
does not merely go undiagnosed; it becomes an attractor for unrelated reds, and then the count on it
is wrong too.

**I did not reproduce `948`.** Thirty repeats of the sequence at 20× CPU throttling; thirty more
throttled from the first byte so the page was still filling in; fifteen whole-file runs on `main`; and
— the row that cost the most and was worth it — **fifteen whole-file runs on `4bdd1bf`, the exact
commit that produced it.** Zero. That last arm is the one that rules out the comfortable answer, *some
later commit fixed it incidentally*, which I would otherwise have been free to assume.

**Three mechanisms falsified rather than left hanging.** Home parked at 200 and watched for 100 s did
not move once, across the demo's device churn and a 244 px swing in document height — which kills both
the clamping story and the scroll-anchoring story in one measurement. And `fabd837`, which deleted a
hook literally named `useScrollFocusIntoView` the day after the sighting, looked like the answer until
I read it: it moves the dialog container's own `scrollTop` and never the window, and this test opens
no dialog. **A commit whose name matches your hypothesis is not evidence for it.**

**So the fix is not a fix.** The assertion now carries the page, the height, the path and the history
index, and the failure names its call site. The comparison is still on the offset alone, and nothing
re-issues the scroll — a poll that scrolled again would paper over exactly the *set, then undone*
class quince#1048 turned out to be, which is the one change that must not be made here.

**The general rule, and it is the same one quince#1048 taught from the other end.** That bug was a
height guard that never said *whose* height it had; this is an offset assertion that never said *where*
it was standing. Both passed review, both read as careful, and both produced a number with no referent.
**An assertion should be unable to fail without saying what it was looking at** — and the test of that
is not whether it looks thorough but whether you can mutate it and read the message.

**One thing I would do differently.** I spent a long time on hypotheses before running the cheap
decisive arm, which was simply *build the old tree and run it*. The instinct to explain came before the
instinct to bound, and bounding was faster.

**Also cleared, in the same sitting.** quince#644 — `TestStoryCancel` — has had its mechanism found and
fixed since quince#784, and was kept open deliberately as a sentinel. Both things it was still waiting
on are done: the `tlsx` sibling flake **was** filed (quince#786, closed), and there has been **no
recurrence in at least 400 CI runs** — 283 green, 17 red, five of those in `gates`, none naming the
test. Its sentinel guidance now lives where it is needed, in `killOutcome`'s comment and in a
deterministic guard test, which is canon's own test for what survives. Recommended for closing rather
than closed: two seats kept it open on purpose and that is theirs to reverse.

**And a number worth having: 100 of those ~400 CI runs ended `cancelled`** — a quarter. quince#968 was
filed off a two-run observation; *a quarter of runs finish carrying no verdict* is a different argument
from an anecdote, and it is now on that issue.
