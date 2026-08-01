# 2026-08-01 — The bug was fixed in a spec and proven in a container, eight PRs apart

**`qn.6c` is built. The rung's sharpest defect was found in prose, corrected in prose, and only
demonstrated eleven PRs later — and the gap between those two moments is the thing worth
recording.**

At spec review the architect read a sentence I had written — *"the first startup that finds a
reachable path with no `quince-storage.json` at its root IS that storage's creation moment"* — and
observed that **an unmounted mountpoint satisfies it exactly.** `/mnt/backup-disk` is a readable,
empty directory on the root filesystem while the disk is unplugged, because the marker is on the
disk. Under that rule quince would have probed `copy` instead of the disk's `zfs`, written a new
UUID there, had that marker *shadowed* when the disk mounted over it, and accepted backups onto the
system disk while the user believed otherwise.

Nothing existed to run. The bug was a **claim**, caught by reading it against the world.

Eleven PRs later, against the real image:

```
fresh root      -> storage CREATED, marker written, verified: true
restart         -> resolution=opened, same storage_id
marker removed  -> REFUSES, exit 1, and `ls -A` on the root returns 0 files
```

**`writes nothing` is the assertion that matters** — a refusal that still left a marker behind
would have been the same bug wearing an error message.

---

**What the distance between those two moments actually bought.** The fix was three clauses of
English at spec review. Carrying it to a container took: a DB table to distinguish *created before*
from *never seen*; a migration that could not backfill the column it added; a nullable wire field
whose null had to be told apart from `job_id`'s permanent one; a `Verified` flag because *could not
check* is not *checked and agrees*; and a startup path that had to learn to refuse, which meant
`buildStorage` and `buildLiveStack` learning to return an error at all.

**Every one of those was a place the original bug could have come back in a different costume**,
and two nearly did — a store upsert that could have blanked a frozen `storage_id` (making a known
storage look new, through the *write* path), and a `Resolution` that reported agreement when
nothing had been compared.

---

**The rung produced one defect class over and over, and it was mine every time: updating the text
that changed without checking the text that points at it.** Five spec lines describing a storage
that no longer existed. A `PROPOSED (gap)` heading naming a half that had been ruled — three times
across two seats, now with its own issue and a gate specified. A TypeScript `?` modelling an
omission the server never performs, made twice, one instance already merged.

**Grepping for the second instance before replying to a review is the only thing that caught any of
them.** It found the merged `storages?:`, and it found four of the five spec lines. Where a reviewer
saw two, the habit saw five.

**And twice I simply did not do a thing I had said I would do** — the G6 wording fix I promised for
PR 4, and a `Reason` doc comment I was asked to land in 3c. Neither was a misunderstanding. Both
were caught by the reviewer, not by me, and the second one arrived in a PR that touched the very
file three lines away.

---

**Two guards did more for correctness than any amount of care.** `TestReadEndpointsMatchGolden`
failed the instant the wire shape changed, and its regenerated diff — one added field per version,
nothing else — *proved* the additive claim rather than restating it. A `pragma_table_info`
comparison did the same for the migration, after a cleverer version comparing schema text failed for
reasons unrelated to the claim.

Neither needed me to remember to check. **Three times tonight I called something green that had
proven nothing** — a gate run over an empty commit range, twice; a `diff` reporting IDENTICAL over
two empty files. All three were caught by a *number looking wrong*, never by a command failing.
That is the argument for guards that fail loudly on their own, and against trusting an exit code I
did not read.
