# 2026-08-02 — arch1 retires: the staleness defect hit eight times in one day, and the eighth was the table about keeping up

**A document describing a state that had moved was found eight separate times in one architect
session. The last one was quince#457 — a spec table whose whole purpose was replacing a stale plan
with what actually happened, and three of its rows went stale during its own review.**

That is not eight lapses. It is one defect with a structural cause, and the eighth instance is the
one that names it: **a status column in a spec cannot be kept true, because the spec lives in git
and the status lives on the forge.** Every merge invalidates it, including merges that happen while
the update is in review — which is exactly what happened, because the merges were mine.

## The eight

| | where | shape |
| --- | --- | --- |
| 1 | `CLAUDE.md` analyst block | `PROPOSED (gap)` heading over a `RULED` body |
| 2 | `contracts.md` gap-1 heading | narrowed twice, wrong for a day after the second |
| 3 | `contracts.md:208` | *"Not built until ruled"* for a question ruled the day before |
| 4 | quince#436 | `PROPOSED (gap)` written for a gap ruled 14 minutes earlier |
| 5 | `contracts.md:181` | heading `PROPOSED (gap)`, own body `RULED 2026-07-31` |
| 6 | quince#445 | three markers surviving the PR that shipped what they forbade |
| 7 | quince#447 | *"becomes the job's slot with 6b"* — in the PR that shipped 6b |
| 8 | quince#457 | three rows `open` for PRs merged during the review |

**Number 5 nearly cost a re-ruling.** I read the heading, concluded the endpoints were undecided,
and was assembling a question to the Operator about a decision taken on 2026-07-31. I caught it
only by reading the block instead of trusting the heading. quince#408's proposed gate — a
`PROPOSED (gap)` heading above a body containing `RULED` — would have caught 1, 4, 5 and 6.

**The best fix came from the implementer, not the gate.** quince#447's write-path note now carries:
*a "becomes X with story N" line is a bug the moment story N is in the same diff. If it cannot be
true when the diff lands, it is not a note — it is an unfinished change wearing one.* Seven
previous fixes corrected an instance; that one names the shape.

## The correction rate, in both directions, because only the instances are on the forge

**Implementers corrected me four times, all substantively:**

- quince#431 — I flagged the per-repo page cap and dismissed the seat-wide one as *"the same class"*.
  Inverted: the per-repo cap over-reports, the seat-wide one **understates**. I waved through the
  dangerous one.
- quince#433 — its `## Scope` section pre-empted a finding I had half-written.
- quince#440 — the marker I asked for came back as a **parameter plus a test**, which is stronger.
- quince#453 — found a bug in code I had approved **and specifically praised** on quince#452: the
  unreachable-storage reason rendered only for a *chosen* storage, and disabled options cannot be
  chosen. The unit test passed because it set that state through props.

**I corrected myself four times:**

- withdrew a `CHANGES_REQUESTED` on quince#423 after finding I had merged five PRs that morning
  carrying the identical defect — the fix was filing devlog#176 against the rule, not enforcing it
  harder on whoever was next through the door;
- claimed a contradiction with r7's `commit_id` measurement without reading the preconditions in
  the table I had quoted — both measurements were right, and the discriminator is whether the pin
  was at head;
- asserted a false claim *"did not reach the Operator"* on the strength of the only channel I can
  see, which was wrong because the implementer's session report is a second channel I cannot;
- recommended self-signed TLS as the onboarding default, which the Operator corrected — it costs a
  browser interstitial and ends in the same place on push.

**Four and four is the number worth keeping.** The instances are on the PRs; the rate is nowhere,
and the rate is what says whether the two-seat review is doing work. It is.

## What landed

**23 PRs merged.** qn.6c is functionally complete through story 10: multi-storage in the Manager
(quince#433), scan-based attribution folding in quince#428 (quince#440), unreachable-as-a-state
(quince#441), the contract surface (quince#445), a job that names its storage (quince#447), the
pre-backup check (quince#449), the selector (quince#452, quince#453), and both acceptance gates —
G2 (quince#450) and G1 (quince#451).

**Six rulings relayed:** unreachable is a listed state (quince#435); the `Storage` object and the
recheck endpoint (quince#378); attribution from the scan (quince#439); `name` and `default` optional
(quince#378); `physical_bytes` nullable (quince#442); the demo's surface review and password
(quince#444). Onboarding step 1 was ruled across four exchanges on quince#446 and grew a TLS
listener in the process.

**Two product bugs went with it:** a terminal job row that could be resurrected into
`waiting_for_passcode` forever (quince#425), and a login that signed out every other device
(quince#423).

## What is owed, and by whom

**G9 is owed and nothing here substitutes for it** — a real device to two real storages, the second
a genuine full transfer. Every gate above is in-process against synthetic slots.

**The Operator holds:** quince#448 (Reset's shape), quince#446 (the TLS listener's four decisions),
quince#442 (build outside qn.6c), quince#454/#455/#458 (unread by instruction).

**Unowned:** quince#408 (the marker gate — this entry is its eighth argument), quince#459 (the
recheck endpoint has no caller), quince#460 (two review leftovers), quince#457 (open,
changes-requested).

## What could not be recorded

**That the loop worked is provable only by silence.** Four `watch-idle` cycles — `elapsed≈1260s
ticks=18` each — are the strongest evidence the wake loop functions, and they exist only in session
scratch. `forge-watch` counts arms and wakes; nothing counts *quiet intervals that were correctly
quiet*.

**A 40-minute blind window is undetectable after the fact.** I armed the watch without `--gh`, so it
ran on an unauthenticated `gh` and emitted only `fetch-failed`. quince#456 was opened and quince#422
was answered during it. I know because I ticked by hand — had I not, nothing in any diff of current
state would show that a watch had been blind rather than a queue quiet. quince#429 proposes the
arm-time probe; it does not make past blindness visible.

**Five reflexive arms on a live watcher, and one orphan.** The tool refused all five (quince#50's
guard) and the orphan was caught by `status`. The *count* is the finding — arming became a
turn-ending ritual rather than a response to a dead watch — and nothing records a refused arm.

— architect session `arch1`, self-declared role, retiring. Cite this entry, not a login
([quince#47](https://github.com/novkostya/quince/issues/47)).

---

**Correction, appended at retirement, minutes after the entry — by addition, not rewrite
(`decisions/0006`).** The line above says **four** `watch-idle` cycles. It was **ten**, one per
watcher run, `elapsed` 1202–1269s and 17–18 ticks each.

I wrote "four" from what I remembered seeing rather than from counting, in an entry whose subject is
documents that describe a state that has moved. The count understates its own evidence, which is the
harmless direction and not the point: the number was checkable in one command and I did not run it
until §3 of the retirement asked me to quote it.

**The ninth instance, and mine.**
