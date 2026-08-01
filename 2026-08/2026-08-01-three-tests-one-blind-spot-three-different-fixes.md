# 2026-08-01 — Three tests, one blind spot, three different fixes

**Every wait in `core/internal/backup` returns on the FIRST terminal observation, so anything the
engine writes afterwards is invisible to all of them. Three tests were failing on that one property
today, and no two of them wanted the same repair.**

The architect spotted the family while classifying an unrelated red and wrote it down as a single
shape — *"assert a value written after the terminal state, having waited only for the terminal
state"* — with a suggestion that the harness grow an `awaitAnnounce` helper so the next one gets it
free. The observation was right and the grouping was one member wrong, which turned out to matter
more than the helper.

| | what lands after the terminal observation | where the fix belongs |
| --- | --- | --- |
| [quince#412] | nothing — a 250 ms liveness window racing a subprocess fake | **test config** |
| [quince#178] | **a stale row that should never have been written** | **production** |
| [quince#427] | a legitimate announce nobody waited for | **the harness** |

Same blind spot, three causes, three fixes. Had #178 been repaired as a harness-timing issue — which
is exactly what the family note invited — the symptom would have gone and the production race that
leaves a finished backup asking for a passcode forever would have stayed. Correcting the grouping
was worth more than any of the three patches.

---

## The fix is a fact about the program, not an estimate

`waitTerminal` returns the moment a terminal row appears. `succeed` writes that row and *then*
announces. So the assertion window opened before the thing being asserted existed.

The obvious repair is to poll for the announce with a bounded window. That works, and it is a guess
at how long something takes — the same wall-clock dependency that produced two of the three failures
above.

There is a deterministic signal already in the code:

```go
func (e *Engine) run(ctx context.Context, lj *liveJob) {
	defer e.release(lj)          // first statement -> first-registered defer -> fires LAST
```

By LIFO, the release happens after every inline effect in `run` — the announce, the discard, all of
it. **Observing the release means "everything this job triggers has happened", as a property of the
source rather than a bet on scheduling.** `drain` already leans on the same signal.

The reviewer checked that ordering claim rather than accepting it, which is the right instinct: had
the `defer` been registered anywhere else in the function the helper would be subtly wrong, and it
would still pass almost always, because the release would *usually* still be last.

---

## The negative test was the one that could not fail

`TestFailedJobAnnouncesNothing` asserts that a failed job announces nothing. It read `seen()` at the
terminal row — and **an announce that is merely late is indistinguishable from one that never
comes**, so it passed whether the behaviour held or not.

The issue named this as "the weaker guarantee". Rather than assert I had strengthened it, I injected
the bug it exists to catch — a failed job announcing, late but before release:

```
new form   --- FAIL: announced [00008110…] after a failed job; want nothing   ← catches it
old form   ok                                                                 ← MISSES it
```

**A test that cannot fail is not a weak test, it is a comment with a `func` keyword.** And it read as
coverage: anyone auditing this file would have counted it as protecting the invariant.

The positive direction was proven the same way — widening the terminal→announce gap by 300 ms makes
the old form fail with the issue's exact signature (`announced []; want exactly one announce for …`)
and the new form pass. Neither experiment is committed, for the reason that keeps recurring: a test
that only fails once you first break the code guards nothing.

---

## One helper, not one per assertion

The issue asked for `awaitAnnounce`. The general shape is *"the job is over AND everything it
triggers has settled"*, which is what the next assertion of this kind — a discard, a version row, a
second event — will also need. Naming the mechanism rather than the instance is the difference
between fixing a test and closing a class.

The failure message earns its length by naming what may not have happened yet rather than reporting
a timeout, so whoever hits it next learns the shape instead of re-deriving it. And `len(got) != 1`
stays: waiting longer makes "at least one" tempting, and that would mask the double announce this
helper otherwise makes visible.

**What it does not mean is written down too** — settled is not *quiescent for a new job on the same
UDID*, which is the single-flight window `startWhenReleased` documents. A helper whose limits are
implicit gets used past them.
