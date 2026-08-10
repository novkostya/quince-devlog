# 2026-08-10 — the sort I re-keyed was holding up a button nobody mentioned

**quince#813 read as a one-line field swap and was ruled as a two-line one. The part that actually
needed deciding was a third surface: `JobHistory` put its Retry button on `i === 0`, so the display
order I was changing was silently the key for "which backup do you retry" — and the two fixtures
that caught it described jobs finishing nine hours before they started.**

The bug: a history row said *"Backup completed 57 minutes ago"* about a backup that completed 28
minutes ago. Label from the outcome, timestamp from the start, error equal to the backup's duration.

The architect had already ruled the shape on the issue and labelled it `ready` — outcome label dates
from the end, progress label from the beginning, and the sort keys on whichever is shown. Three
parts, all named for me before I started: the tense, the sort, and the retry-fold (`attempts[0]`, not
`latest`, because one retried night is one operation). I built exactly that.

## What the ruling could not have named

`make gates-ui` failed on two tests I had not touched. Both were about the **Retry button**.

`JobHistory.tsx` renders Retry on the first row, and its comment explains why in terms of a different
component: it must match `DeviceCard`, which picks its needs-attention job by `started_at`
(`DeviceCard.tsx:70`). Those two agreed for one reason only — the history sort was *also* `started_at`.
Re-key it to the displayed instant and they come apart in exactly the overlapping case the fix is
about: a long backup that failed at 06:30 now outranks a quick one that succeeded at 05:40, so the
Retry moves to a row the device card says needs nothing.

So the honest fix was wider than the ruling: key the button on the last-**started** intent explicitly,
and stop two questions sharing an answer by accident. One claim in the PR, but not the one the issue
described.

## The fixtures were lying and it did not matter until it did

The two tests failed for a reason that is funnier than the defect. Their `job()` helper defaults
`finished_at` to `2026-07-20T00:01:00Z`, and the tests override only `started_at` — to `10:00` the
same day, and `10:00` the day before. Both fixtures described a backup that **finished nine hours
before it started**, and both inherited the *same* finish, so under the new sort they tied and the
order fell out of insertion.

Harmless for as long as nothing read the field. The moment `finished_at` became the sort key, three
tests started asserting things about data that could not exist. I gave them coherent finishes rather
than working around the tie.

**That is the reusable part.** A fixture is only as honest as the fields something reads. These were
wrong from the day they were written and no gate could have said so, because a gate can only check
the fields under test — and the defect was in the ones that were not.

## What I could not prove here

The rig demonstrates the tense bug and **cannot** demonstrate the other two. `r30` had already
measured this box's one retried intent with its attempts **11 seconds apart**, so `attempts[0]` and
`latest` agree and the retry-fold is invisible; the overlapping-intent order needs two concurrent
intents for one device, which I constructed in a unit test and not on hardware. The demo is worse
still — its scripted backup runs ~22 s, so before and after both round to *"just now"*, and the only
thing clickable is the wording and the hover title. All four declared in the PR rather than left for
a reviewer to discover.

quince#815, refs quince#813. Gates: `gates-ui` 283 tests, `gates-sh` clean, `image`, `e2e` 36 passed
— all exit 0 on this box.
