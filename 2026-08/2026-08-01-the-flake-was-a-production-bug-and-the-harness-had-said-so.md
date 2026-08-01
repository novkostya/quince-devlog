# 2026-08-01 — The flake was a production bug, and the harness had already said so in a comment

**`TestFailedBackupReportsTheDeviceReason` was filed as a flake on 2026-07-28 and looked at three
times in four days. It is a real bug that leaves a finished backup telling the user to unlock their
phone, forever.**

The failing diagnostic carried the answer:

```
state=backing_up phase=waiting_for_passcode liveness=active percent=nil files=0 engine_owns=no
```

and forty lines above the assertion, the harness's own comment says what that combination means:

> a terminal row can legitimately still be owned during the single-flight window … and **a
> non-terminal row that is NOT owned is the one combination that cannot be explained by a slow box**

Somebody wrote that down after paying for it once — [quince#59], *"a terminal row overwritten by a
stale progress write"*, which cost *"a load repro and a SIGQUIT dump"*. The message was built to make
the next occurrence cheap. The next occurrence arrived, printed exactly the sentinel it was designed
to print, and three readings in a row went to the harness instead.

---

## The bug

`transition()` and `progress()` both did this:

```go
lj.mu.Lock()
mutate(&lj.row)
row := lj.row          // snapshot
lj.mu.Unlock()         // ← lock released
e.st.UpdateJob(row)    // ← write happens HERE, unordered against any other writer
```

Two writers, each ordered internally, **unordered against each other**. So:

```
sampler  lock; set liveness; copy {backing_up}; unlock ....... descheduled .......
run      lock; set state=failed; copy {failed}; unlock; WRITE {failed}; release
sampler  ... resumes .............................................. WRITE {backing_up}
```

The job is over, the engine has released it, and the stored row says it is still running in
`waiting_for_passcode`. **The red check was the least of it**: in production that row is what the UI
reads, so quince goes on asking for a passcode for a backup that already failed, until a restart
reconciles it.

The fix is that the lock spans the write. Per job, so a job serialises against *itself* — its sampler
against its run goroutine — and never against another job.

---

## Why four days and three passes

**Every wait in that package returns on the FIRST terminal observation.** So a write landing after
that is invisible to all of them: the test sees `failed`, returns, and whatever overwrites the row a
millisecond later is unobserved. The 8% was a coin toss on whether the stale write landed before or
after the wait returned.

That is also why it was reasonable to read it as a harness problem. The symptom only ever *appears*
in the harness. Two earlier passes tuned the harness — a grace-phase budget, a better message — and
both were real improvements to the message that made the mechanism *more* legible without anyone
reading it.

**I got it wrong first too, and in an instructive way.** My initial theory was that a late
`progress()` call resurrected the row by *mutating* it. It cannot: by then `lj.row` is already
terminal in memory, so that write persists the terminal row. The bug is the **snapshot** — taken
before the mutation, written after it. Reasoning about the mutation rather than the snapshot cost two
dead-end experiments, and it is the distinction the next person needs.

---

## What actually settled it

Not a reproduction — 25 iterations with `-race` under 24 CPU-saturating processes stayed green, and
the losing interleaving is nanoseconds wide.

**Widening the window by hand did it.** A 50 ms sleep between the snapshot and the write:

```
before the fix   TERMINAL ROW WAS OVERWRITTEN: state=backing_up phase=waiting_for_passcode
                 liveness=active engine_owns=false (was failed)
after the fix    PASS ×3 under -race, same delay
```

Field for field against what CI printed. **A race you cannot reproduce can still be proven, by making
the window big enough to hit on purpose** — and that is cheaper than a load repro, which is what this
package paid last time.

**The sleep is not committed.** A test that only fails once you first break the code guards nothing.
What is committed asserts the property — a terminal row is still terminal after the dust settles —
and says in its own comment that it is not a deterministic reproduction. The reviewer then checked
exactly that: reverted `engine.go`, widened the window, and ran the committed test until it failed.
*"It can fail. It fails for the right reason."* That is the check I could not perform on myself.

---

## Two things this cost that were nobody's fault

**The reviewer audited the lock discipline and I had not.** I reasoned that `Publish` is non-blocking
and that nothing re-enters — true, and not the same as enumerating every `.mu.Lock()` in the package
looking for an inverted order. Widening a mutex to span I/O is where deadlocks come from, and the
person who widened it is the worst-placed person to certify it.

**And the closing keyword did not fire.** `Closes novkostya/quince#178`, byte-clean on its own line
in the commit that landed on `main`, and the issue stayed open — while the identical form closed two
other issues the same day. Observed, not diagnosed: the timeline bound the keyword to the
**pre-rebase** SHA and never processed the one that merged, but another PR was also rebased and closed
fine, so that explanation does not survive contact with the third data point.

**Two out of three is the worst possible score for an automation**, because nobody checks the ones
that work.
