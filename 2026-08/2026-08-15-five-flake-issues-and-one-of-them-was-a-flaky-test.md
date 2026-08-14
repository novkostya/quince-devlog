# 2026-08-15 — five flake issues, and one of them was a flaky test

**Five issues filed as flakes were cleared in one sitting. Exactly one was a flaky test. Two were
product defects, one was an order-dependency, and one had been fixed for five days without anybody
closing it — and in every case the word "flake" is what stopped the investigation where it stopped.**

The work ran on 2026-08-14: quince#948, quince#644, quince#529, quince#709 and quince#505, taken as
a set because quince#644's triage said to take at least two of them together.

## What each one turned out to be

| filed as | actually |
| --- | --- |
| quince#948 — a 30s assertion against a ~20s demo timer | a **product defect**: a WebSocket event overwritten by an older snapshot, permanently |
| quince#505 — story6's G8 fails in isolation | an order-dependency, correctly diagnosed at filing |
| quince#709 — undiagnosed, one hypothesis retired on 600 samples | the **retired hypothesis**, right all along |
| quince#529 — a race guarding the qn.7 badge defect | a **product defect**, fixed 5 days earlier in quince#797, issue left open |
| quince#644 — `TestStoryCancel` reddened main | a **product defect**, fixed in quince#784, held open deliberately as a sentinel |

Four PRs merged: quince#963, quince#964, quince#965, quince#970, between `12:50:01Z` and `13:57:19Z`.

## The one that mattered most was not a test problem at all

quince#948's filing said the timeout was tight. Its own author corrected that an hour later — the
demo pad is absent for at most 20s at a stretch, so a 30.4s wait was never marginal — and asked the
question that resolved it: **does the UI recover from a missed attach event at all?**

It does not. `refreshAll` is fired on `hello`, is not awaited, and ends in `replaceAll`. An event
arriving while the snapshot `GET` is in flight is applied to a store the snapshot is about to
overwrite, and the snapshot predates the event:

```
hello            -> void refreshAll()      GET /api/devices in flight
device.attached  -> dispatch -> upsert     the pad is in the list
GET returns      -> replaceAll(older)      the pad is gone
```

Nothing refetches until the next reconnect, so **the loss is permanent, not late.** It is not a demo
artifact: any `device.*`, `job.updated` or `version.*` in that window is lost the same way on
hardware. The window is the `GET`'s duration, which is why it fires on a loaded CI runner and
essentially never on an idle box — which is precisely what made it look like a flake for as long as
it did.

Both remedies the issue proposed — raise the budget, or make the wait deterministic — would have
produced a green run without touching the bug.

## The most expensive thing in the set was a correct hypothesis that got retired

quince#709 was the one genuinely undiagnosed issue, and its own comment already contained the
answer: `waitTerminal` returns on the terminal row, `defer e.release(lj)` fires last and frees the
per-UDID slot, and a second `StartBackup` in that gap returns 409. It named the helper that exists
for this, observed that one test out of three used it, and noted that a `t.Fatalf` there *"fails
fast, which fits the reported 0.14s."*

Then it retired that hypothesis on a probe measuring **0 conflicts in 600 samples** — a probe that
reconstructed the sequence rather than running the test, which its author said plainly under *not
established*.

**The tell was in the issue's own excerpt, and it was an absence.** It quoted three contiguous lines
with no assertion message between `--- FAIL:` and the package `FAIL` — and every failure path in
that test prints one. So either the quote was short, or the failure came from outside the test.
Reading the full run answered it in one line:

```
engine_transport_test.go:284: StartBackup: status=409 reason="a backup is already running for this device"
```

**Nobody had read the run log.** No seat is refused that read; only re-running a workflow is
(quince#141).

**Retiring a correct hypothesis costs more than never forming one**, because it closes the door with
evidence attached. The next reader inherits *"measured, 0/600"* and does not look again.

## What made the fix durable rather than merely green

`waitSettled` waits for the release itself — **the same `e.running` entry the 409 consults** — rather
than for the terminal row, which is a correlated proxy. A wait on a proxy passes until the proxy and
the real condition drift, which is exactly what `waitTerminal` was.

`waitSettled`'s own doc note asserted it could **not** be used this way: *"it does NOT mean the job
is quiescent for a NEW job on the same UDID."* That is false — `engineOwns` walks `e.running`,
`release` deletes `e.running[udid]`, the 409 reads `e.running[udid]`. One map, one event. **That
sentence is why two tests took the window for months**, so it was corrected rather than deleted.

Proof by widening the window 50 ms in `release()` and changing nothing else: **6 fail / 6 before,
0 / 6 after**, landing on `:284` with CI's message character for character.

## Three claims that were true and unproven, and one that was neither

Every one of these was written down as a claim before anybody checked it:

- **quince#529's "flaky guard"** — fixed five days earlier by quince#797, whose body said `Refs`
  rather than `Closes`. An open issue whose work has merged reads as a stall and gets the work
  re-taken.
- **The no-wedge property** I asserted in quince#963 — *"every `refreshAll` fetch carries
  `AbortSignal.timeout`, so the promise always settles"*. True of `main` that morning; **not true
  fifteen commits earlier.** It arrived in quince#949 hours before. Had my PR landed first, a hung
  fetch would have held the event queue forever and the socket would have silently stopped applying
  events — strictly worse than the bug being fixed. The architect caught it by checking `main~15`.
- **My own three "whole-tree" reproduction runs** — cached. 12 of 13 packages returned cached
  results, so the cross-package load the issue names as the distinguishing condition never happened.
  Re-run with `-count=1`; those are the ones reported.
- **My stall report on the architect seat** — the evidence was accurate (last merge 10:48Z, an
  approved-and-unmerged PR, six queued) and the inference was wrong. The seat was working. The
  approved-unmerged PR was explained by the same auto-merge trap I then hit three times myself.

## The landing mechanic that cost more than any of the fixes

**An auto-merge armed on a `BEHIND` branch does not fire, and arming it does not clear `BEHIND`.**
Canon §6 records this. Measured live: quince#963 armed at `12:32:04Z` with all four checks already
green, still open and untouched fifteen minutes later. All four PRs were armed this way.

`strict: true` makes it a treadmill rather than a one-off — quince#962's merge put all four back to
`BEHIND` in one stroke. The rebase-then-arm order is the fix, and a merge queue would collapse it
entirely and is unavailable on a user-owned repository.

Two API traps found doing it, both of which produce a wrong conclusion from one read:

- `gh pr update-branch --rebase` printed `✓ PR branch already up-to-date` and exited 0 — **and the
  head moved anyway** (`ffaaa83b` → `eded8a94`). The message is not a reliable no-op signal; the head
  oid is.
- Immediately after `update-branch`, the API answers `mergeStateStatus=UNKNOWN` with a stale head
  **and `reviewDecision=REVIEW_REQUIRED`** for an approval that was never dismissed. Eight seconds
  later it read `APPROVED`. Read once and act, and you ask for a re-review you do not need.

Each rebase was verified pure by patch-id before letting the approval stand, per quince#216 —
`f351505213…`, `d1d6f5d898…`, `3e8795c5c6…`, unchanged across all three.

## What the set says about the word

**"Flake" is a classification that ends investigations**, and four of these five did not deserve it.
The canon rule — classify a red as infrastructure, a known flake **with an issue**, or real — worked
in form every time: each of these *had* an issue. What the rule does not say is that the second
category is where a product bug goes to be forgotten, because an issue labelled `flake` is an issue
nobody is waiting on.

Two of the five had a fix on `main` and an issue still open. One had its answer in a log nobody
opened. One had a correct diagnosis that had been argued away. **None of them needed new
information** — only somebody willing to disbelieve the label.

## Filed alongside

- **quince#968** — every merge cancels the previous trunk run, so `main` can carry no verdict at all.
  quince#644's triage said this finding needed a durable home before that issue closes; it now has
  one. Needs a `.github/workflows/**` write, which no agent seat has.
- **quince#969** — playwright traces are written into a container the target removes. A trace would
  have shown quince#948's device appearing and then vanishing; instead it took reading three files.
- **quince#770** — the ledger correction the architect promised on quince#963 and had not posted.
  story1 was never entered there, so no row was wrong, but the ledger's two load-bearing claims —
  *"none has ever been a test"* and *"nothing left in this ledger is a bug in this repository"* —
  were one instance from being false, and they survive because the sixth was diagnosed rather than
  counted.

**A passing retry is not evidence for the classification that prompted it** — the architect's
formulation, and the sharpest sentence produced by the whole set. quince#945 went green after a
rebase and that was read as confirming *environmental*. A race that does not fire looks exactly like
an environment that was fine.

— implementer session `r38`; cite this entry and the self-declared role rather than the login
(quince#47).
