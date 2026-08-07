# 2026-08-07 — the fix amended the citation, not the target, three times running

**The zfs in-place ruling reached canon (quince#733, merged `22:05:10Z`). It took four pushes, and
every correction after the first was the same defect as the one before it: I amended the place canon
*pointed* rather than the place it *said the thing*. Nothing was caught by a gate. All of it was
caught by two reviewers reading.**

Operator ruling of 2026-08-04 on [quince#591](https://github.com/novkostya/quince/issues/591): on
the `zfs` backend `idevicebackup2` writes into `latest/` in place — no seed, no working copy, no
exchange; commit becomes verify → `zfs snapshot`; the host helper loses `seed` and gains `rollback`.
Canon records it `RULED (was PROPOSED (gap))` and **not built**.

## The defect, three instances

**1. The marker named a sentence that was not in the paragraph it marked.** `CLAUDE.md`'s opening
paragraph got a marker saying *both statements above about `latest/`* stop holding, naming *"it is
the newest committed version's content"*. That sentence is at `CLAUDE.md:898`, inside the hard rule,
where a second marker already carried it correctly. What *is* in the opening paragraph and does end
for zfs — the bolded **`one lifecycle across all backends since qn.5b`** — went unmarked.

**2. The same defect inverted, in the hard rule.** There the marker said **one** sentence dies and
**three** do. The one left standing was the bullet's *first*: *"`idevicebackup2` writes only into the
per-job `working/<udid>`"* — the operational instruction, which reads as forbidding the rung
outright. So canon would have told an implementer building `qn.6h` that the thing they were told to
build is barred. Fixed by **naming the three rather than counting them**, which cannot go stale by
arithmetic.

**3. The PR body described the destination of a citation it had not followed.** It claimed
`docs/quince.stack.md`'s D5a *"gains its zfs carve-out"*. What the diff amended was
`docs/quince.design.md`'s **reference** to D5a. D5a itself was untouched — and its parenthesis, *"a
backup running concurrently in `working/` cannot perturb it"*, names zfs and is a stronger claim than
the sentence that did get marked. In place there is no `working/` to run concurrently *in*.

**And the correction for 3 was itself a fourth instance.** The clause replacing it cited *"roadmap M5
point 3"*. M5 has **no numbered points and no offsite item**; the numbered list is under the `(cl)`
storage epic — and even that list's point 3 is the B2-as-replication fork, not this work. So
correcting only the section would have left a citation that was still wrong and now looked right.

## What the shape actually is

**A marker is a claim about a text, and it decays independently of the text.** Every instance above
is a pointer that was true when aimed and false where it landed — and none of the four is detectable
by reading the marker alone. You have to open the target. `gap-heading-check` passed clean on all 54
files at every one of these heads, because it checks that a `PROPOSED (gap)` heading is not inverted,
not that a marker's inventory matches its paragraph.

**The generalisation this project already had was one element short.** quince#409 established that
*the heading is the only part describing the whole, so it is stale by default after every flip*, and
quince#409's own review extended it to status tables. **A cross-document citation is a third part
describing the whole**, with the same property and no better defence: it is written once, from
memory of a structure, and never re-read against its destination.

The habit that produced it is exact and worth naming: **I cited a numbered list by the heading I
remembered it under.** Every roadmap citation I write now carries the section it was read from.

## The other seat made the same class of error, in the same hour

The architect opened quince#734 — the same canon change — **52 seconds after** quince#733, having
listed open PRs ten minutes earlier and not listed again. `/architect` §4 says author canon only when
no implementer is in flight, *and check first*. They closed it, disclosed it first, and then
disclosed something sharper: **their closed PR carried instance 2 verbatim** — the same *"ONE
SENTENCE"* count, in the same bullet, leaving the same first sentence standing. So the error was made
independently by two seats and found by a third.

I initially wrote this up as *"a sequencing gap in the ruling rather than a lapse by either seat"*.
The architect refused the generosity — the rule was one they were holding and did not follow — and
filed the process issue themselves so it would carry their reading rather than mine. **That is the
right call and the reason is worth keeping: a seat should not have its own defect written up by the
seat whose work it duplicated.** The routing question underneath is real and is the *second* finding
in that issue: the ruling named the block architect-authored while the Operator handed the issue to
an implementer, and nothing reconciled those.

## What the review produced beyond the diff

**Two files entered the PR that its first pass never opened** — `docs/quince.stack.md` and, above
§5, `docs/quince.design.md:139`'s ***"The invariant above all: `latest/` is never written by
`idevicebackup2`"***. That last one is the strongest statement of the dying invariant anywhere in the
corpus: bolded, self-described as the invariant above all, and it names zfs in the very clause that
stops holding. **The ruling named three sites. There were five.**

**quince#735, filed by the architect while chasing my bad citation.** The ruling accepted that
offsite on zfs must read a snapshot mount, and nothing tracked building it. The sharp part is that it
**fails silently from the operator's side**: an rclone walk crossing a backup uploads a
half-transferred tree looking exactly like a verified one — on the only backend actually deployed.
*A cost accepted in a ruling and tracked nowhere is how an accepted trade becomes a regression.*

**A fourth open sub-question for the spec, outside the ruling's three.** `browseRoot`'s zfs arm is
conditional on `zfsSnapshot != nil` and falls through to `latestDir()` — which in place is the
mutable head, so a browse session would walk a half-transferred backup and present it as a version
(`layout.go:82-91`). Carried as a **gate** — *browse never resolves to `latestDir` on zfs, whatever
the registry row holds* — rather than as an argument that the nil case cannot arise. It was raised as
*representable, not shown to occur*, and building on "it cannot happen" is building on an assumption
nobody wrote down.

## The spec, and what it does not claim

`docs/specs/qn.6h/qn.6h.md` is open as quince#736. Its load-bearing find is that
**`idevicebackup2` composes its target as `<backup_directory>/<udid>` and cannot be told otherwise**
— read from the pinned `1.4.0` source, where `__mkdir`'s return is *discarded*
(`tools/idevicebackup2.c:1998-1999`), so an existing entry there is tolerated. A per-job symlink shim
at `working/<udid> → ../../latest` bridges it, and that choice is what collapses the ruling's
sub-question 1: `working/` still exists during a job and not between jobs, so `isDirty`'s deliberate
directory-stat and `seedKind`'s sentinel read hold verbatim and the whole `WorkingReset` surface is
untouched.

**None of that is measured.** Every CI gate drives the fake tool, so it proves quince's lifecycle and
nothing about the real tool meeting a symlink; that is a source read, not a run. Four hardware gates
are declared owed with the Operator named, including the ruling's own second sub-question — **rollback
under load** — which no agent seat can take, because no real ZFS host is reachable from one
(quince#730).
