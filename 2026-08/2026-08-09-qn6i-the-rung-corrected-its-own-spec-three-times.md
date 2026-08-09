# 2026-08-09 — `qn.6i`: reconciliation went async, and the rung corrected its own spec three times

**quince answers its API about a second after start instead of ~48 s, adding a disk returns instead of
hanging the button, and a scan now runs on a schedule — and while one is outstanding quince says its
version list may be short ([quince#731](https://github.com/novkostya/quince/issues/731), retiring
[quince#592](https://github.com/novkostya/quince/issues/592) and
[quince#715](https://github.com/novkostya/quince/issues/715)). Every correction in this rung went the
same direction: something the SPEC asserted turned out to be wrong, and the code was right.**

## What landed

| | | |
| --- | --- | --- |
| [#769](https://github.com/novkostya/quince/pull/769) | the spec | |
| [#771](https://github.com/novkostya/quince/pull/771) | the commit lease | blocker 1 |
| [#772](https://github.com/novkostya/quince/pull/772) | the runner, async startup, `reconciling` | blocker 2 |
| [#774](https://github.com/novkostya/quince/pull/774) | the add trigger | quince#715's half |
| [#776](https://github.com/novkostya/quince/pull/776) | the schedule | open |
| — | the UI notice | built, queued behind #776 |

## The finding that decided the shape, and neither issue carried it

`Engine.Reconcile` tells a rolled-forward commit from an interrupted one by asking `VersionForJob`.
Move `Manager.Reconcile` wholesale off the startup path — which is what *"make reconciliation async"*
plainly means — and a backup that transferred for hours, verified, and crashed one phase from done is
written to the database as **interrupted by a restart**.

A successful backup reported as failed, **introduced by the fix.** So the pass splits: roll-forward
stays synchronous and ahead of the listener, and only the per-device scan moves.

## Three corrections, all of the spec, all by reading the code

**The spec said roll-forward was expensive. It is not, and the same session wrote both claims.** D2
argued the split as a trade against *"a real copy on the `copy` backend"*. The clone strategy governs
the **seed**, not the archive: both backends roll forward in O(1) of tree size — two renames, or one
snapshot. Measured over 25/100/400 versions, roll-forward is flat at 62–125 µs while the scan grows
22 ms → 297 ms. **231× to 4790×.** The half kept in front of the listener is the half that does not
scale with data, which is exactly what quince#592 complained about.

That correction came from the architect asking for a *timing*. A stopwatch on two `rename` syscalls
would have bounded nothing; the question is what sent someone to read `finishRotation`.

**The spec said G1 could be measured on the demo container. It cannot.** `make demo` runs `--demo`,
which serves fixtures and never touches the storage path — it would have timed a startup with nothing
to reconcile and gone green for a build with the scan still in front of the listener. The gate row was
corrected rather than ticked, and the end-to-end wall-clock is **owed at the next staging redeploy**.

**The spec said G8 could reuse "the existing crash-mid-commit fixture". There was none.** The
composition it guards had never been asserted by anything: a doc comment and a call order were the
whole of it, in a package at 84%+ coverage. The architect's finding was that this rung made the
ordering *invertible*; the truer statement is that it was never guarded, and the split merely made it
easy to get wrong.

## D4: confirmed as a mechanism, unconfirmed as an event

A scan reaching a tree between `Backend.Commit` and `registerCommitted` adopts the version, and the
engine's own insert then collides on the primary key — `Store.InsertVersion` is a plain `INSERT`. So a
completed backup is reported failed.

The first attempt to gate it raced a commit against a scan loop and **passed 5/5 with the guard
removed**: the window is microseconds wide. The comment in that test already said *"without the lease
this test fails"* — written before it was run that way, and false.

What replaced it is three gates that each say what they are worth: **G6a** enters the window by hand
and is a tripwire on the seam (it passes with the lease deleted, by design — it tests the hazard, not
the fix); **G6b** races them and is a regression net; **G6c** holds the lease as `CommitJob` does and
is the only one red without it.

**So nobody should read this rung as fixing an observed bug. It closed a window that has never been
seen to open** — which is what the ruling asked for: the hazard must not be *reachable*, rather than
proven harmful.

## Guards verified by removing them

Every guard in the rung was measured red rather than asserted red: the pre-check, the journal test,
the lease, the ordering, and the three UI negatives. The architect **re-ran the G8 mutation
independently**, on the grounds that a guard-removal result is the one class of evidence neither CI
nor a passing test can confirm.

Two fixtures were wrong in a way that mattered, and the product caught both: a hand-written
`quince-version.json` is not a marker (`ReadMarker` verifies a checksum), so `Scan` skipped it and the
test passed *for the wrong reason*; and a deferral test bound a job on a Manager with no devices, so
the loop never reached it and `Deferred` was empty because of its own precondition.

## What the process learned

Three canon changes landed *from* this rung's work rather than into it:
[quince#773](https://github.com/novkostya/quince/pull/773) — local work on an unmerged branch is not a
stacked pull request, and `--onto` is load-bearing because §6 permits squash;
[quince#775](https://github.com/novkostya/quince/issues/775) — an explicit `--commit-id` pin does not
survive an author force-push, found because a rebase on quince#774 moved one.

The `--onto` finding has teeth: a plain `git rebase origin/main` after a **squash**-merged predecessor
replays its commits against a `main` that already holds their content, and resolving that conflict
wrongly ships a silent revert of the slice that just landed. This session got the safe outcome on
quince#774 by luck — the predecessor happened to be rebase-merged — and said so rather than banking it.

## Owed

- **G1's end-to-end wall-clock**, at the next staging redeploy. The A/B above is the mechanism, not
  the 36 s → ~1 s claim.
- **D4's rate in production.** Unmeasured, and the schedule is the first trigger that can fire beside
  a live commit with no user action involved.
- **A partial-pass guarantee for the admin CLI path.** `buildStorage` promises a *reconciled* Manager;
  after the runner that means *the pass that was enqueued*. Not reachable today — deferrals come from
  bindings a CLI process never makes — and recorded as the spec's open question 7.
- **`SweepWork` stays `return nil`**, deliberately. What this rung leaves the future sweep is the
  lease, which is the mechanism it needs to ask whether a job is live.
