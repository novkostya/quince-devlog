# 2026-08-09 — the cancel that arrived before the process, and was called a failure

**`TestStoryCancel` had been flaky since 2026-08-04, and the flake was the product. A backup the
user cancelled could terminate `failed` / `backup_failed: start idevicebackup2: context canceled`,
because a kill landing before `cmd.Start()` was classified as a failure to start. Fixed on
quince#784; quince#644 stays open until the trunk stops seeing it.**

`run()` narrates `backing_up` — and `seeding`, on the gated path — **before** it reaches
`cmd.Start()`. The pinned toolchain, `go1.26.5`, `os/exec/exec.go`:

```go
if c.ctx != nil {
    select {
    case <-c.ctx.Done():
        return c.ctx.Err()   // ← no process was ever spawned
    default:
    }
}
```

So a `CancelJob` landing between the transition and `Start()` comes back as an ordinary `startTool`
error, and both supervise paths mapped **any** such error to `outcomeProcErr`. Design §4 says a
cancel ends `cancelled`. The code said `failed`, and named a Go runtime string as the reason.

**The window is what made it look like a test problem for four days.** quince#644 recorded the
puzzle precisely — reproducible only under a contended whole-tree run, never in 63 targeted
iterations, and once under `-count=8`. That is exactly the signature of a window a few instructions
wide: `-run` alone cannot make the scheduler preempt a goroutine between two adjacent statements,
and whole-tree `-race` does it now and then for free. Three sessions tallied it without reading the
test's mechanism, and the tally was the right call each time — but the tally never converges,
because the shape it is measuring is not the shape of the bug.

**What the fix is worth stating for.** The first revision added a second switch beside
`runToolLoop`'s and a comment saying *"one classifier is what keeps them from drifting apart."*
There were two. The architect refused it on that sentence alone — *"the claim is the kind that stops
the next reader checking"* — and offered either making the words true or making the code true. The
code, in a PR whose entire subject is a classification that drifted, was the only defensible answer:
`killOutcome` now answers *was this job killed, and how does it terminate* once, for both sides of
`Start`.

**That review is the reason the guard is held from both directions.** The architect mutated each
half separately rather than trusting the refactor:

```
neuter startFailure's kill branch only    → the new test FAILs, both subtests
remove runToolLoop's killOutcome call     → TestStoryWifiTornSession, TestStoryCancel,
                                             TestStoryCLIFailingBackupExitsNonzero FAIL
```

A refactor is how a guard goes vacuous while its test still passes, and nothing but that mutation
would have shown it did not.

**A coverage disagreement turned into the better finding.** My reading was 84.6%, theirs 84.9%, on
the same commit. The architect had asserted *"Go coverage is deterministic for a fixed test set"* and
then measured four consecutive runs on one tree: `84.9  84.9  85.3  84.9`. Neither of us had
mismeasured. **So a coverage figure for `internal/backup` is a sample, not a measurement** — and the
likeliest source of the variance is `TestStoryCancel` entering this bug's own window on some runs and
not others. Which sharpens what the fix actually is: **it does not close the race, it makes the race
harmless.** Correct behaviour on both sides of a window nobody can close is the whole of it.

**One ordering change neither the diff nor the commit message mentioned**, caught in review and
recorded here because it is real: the `killReason` read moved from before the `success` read to after
it, so the window in which a last-instant kill is observed is marginally *wider* now. Benign, and
arguably better — a late kill is more likely to be classified as the kill it was.

**quince#529 was read in the same sitting, as quince#644's triage asked, and the answer is a
negative.** It is in `internal/deviceops`, which has no `startTool` path, and its assertion is a
publish that never arrived rather than a misclassified terminal state. **No shared cause** — so the
shared-harness / shared-fixture-clock hypothesis quince#644 raised is not supported for that pair.
Worth a line because a negative result nobody writes down gets re-derived.

**Not established.** That this explains every quince#644 sighting: all four recorded observations
read `state=failed, want cancelled`, which matches this path exactly, but no live failure was
instrumented. And no rate — the flake is not reproducible on demand, so nothing here shows the rate
changed. The guard is a deterministic unit test that opens the window by hand and fails with
`outcome = 1` against the unfixed engine, reproduced independently by the reviewer.

**So quince#644 does not close on that merge**, and the PR carried no closing keyword. It closes when
someone is satisfied the trunk has stopped seeing it.
