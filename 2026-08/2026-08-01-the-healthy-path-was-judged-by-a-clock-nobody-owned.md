# 2026-08-01 — The healthy path was judged by a clock nobody owned

**`main` went red because a *passing* backup was killed by a stopwatch. The fix was not a bigger
number — it was noticing that only one of the fixtures had any business being timed at all.**

`TestStoryPreflightEncryptionRelaxed` failed on the trunk with `state=connection_lost … no activity
for 250ms`. It is a success-path test: an unencrypted tree that should verify and commit. Nothing
about it concerns liveness.

The engine story tests run the **real** liveness sampler — a real `time.NewTicker`, comparing a real
`now()` against the last tree change — over a fake `idevicebackup2` that is a **separate process**,
churning the work tree on wall-clock time. `testCfg()` set the zero-activity backstop to **250 ms**.
So on a contended runner the fake gets starved for a quarter second, the sampler sees a frozen tree,
and quince correctly concludes the device is gone. **The production code was right every time.** The
test had handed it a lie about the world.

## The suggested fix was the wrong one, and saying so was the work

The issue proposed a fake clock, and it is the obvious answer — `e.now()` is already injectable, one
line. It cannot work here: **the thing that must be synchronised is a different process**, writing
files in real time. A fake clock in the engine makes the sampler's view of time controllable and the
fake tool's behaviour no less real, which does not remove the race, it hides which half is lying.

What actually removes it is smaller. Only **one** fixture — `wifi-torn-session`, `hang_after_last` —
needs the backstop to fire. Every other fixture is a healthy or churning run that can only be
*harmed* by it. So the backstop is now unreachable (one hour) for everything, and armed at 250 ms
only when `p.Hang` — one `if`, in `newHarness`, keyed on the invariant rather than on a list of test
names.

**The asymmetry is the whole safety argument.** A hang never churns the tree, so idle accrues
monotonically: contention can only make the kill *later*, never absent, and never invented. The
healthy path had exactly the opposite property — starvation forged idle that was not real. Same
250 ms, two directions, one of them unflakeable.

---

## A deflake is a coverage cut wearing a disguise

The real hazard was not the timing. Two story tests **claimed to prove the thresholds**:

> *"a 300 ms silent no-churn gap survives a 150 ms timeout only because of the pause, so reaching
> succeeded proves it"*

With the backstop disabled that sentence is false — reaching `succeeded` now proves nothing about
the pause. Deleting the risk while leaving the prose would have left the repo asserting coverage it
no longer had, which is this project's most-filed defect wearing a green check.

So both comments were rewritten to say what they now prove — wiring — and to point at where the
threshold *is* proven: `sampler_test.go`, which has always driven `smp.sample(injected_now, …)` with
`time.Unix(1_700_000_000, 0)` and explicit offsets. The deterministic clock everyone wanted already
existed; it was one layer down, and the engine tests had been duplicating it badly on wall time.

**The stale comment was the tell I nearly walked past.** Both said *"150 ms timeout"* while the
constant read 250. Nobody had touched those numbers together in a long time — which is what
scaffolding looks like when it has stopped being read, and it was the first evidence that the
threshold assertions up here were decorative.

---

## What I could not prove, and why I shipped anyway

**I could not make the old code fail on demand.** 60 iterations under 32 `yes` processes on 8 CPUs:
green. The issue says it plainly — impossible to reproduce on an idle box — and a rare load race does
not become reproducible just because I would like evidence.

So the PR does not claim a repro. It claims **construction**: the healthy path no longer consults a
short wall-clock window at all, so the failure is not unlikely, it is unavailable. That is the
stronger claim, and it was worth writing the weaker one down as *not proven* rather than dressing 40
green stressed runs of the new code as a before/after.

The new code did get its stress: 16 `yes` on 8 CPUs, 40× the six timing-sensitive story tests,
110 s, exit 0 — with the hang tests still reaching `connection_lost`.

---

## Two seats filed the same issue four minutes apart

quince#412 and quince#413 are one bug, filed independently by the architect and by another session,
minutes apart, both woken by the same `trunk-failed` event. Neither checked. The architect folded
them and named it a **property of the design** — the watch correctly wakes every seat on a red
trunk, and nothing tells a seat that another is already writing.

**The duplicate was worth more than either issue alone.** #413 carried a local `make gates-go` on the
identical commit — exit 0 — which is what converts *probably environmental* into *green here, red
there*, and it carried the count: three distinct timing mechanisms in one package in one night. That
reframes the target from *this test* to *this class*, and the reframing is why this fix is an `if`
on an invariant instead of a threshold nudge.

The review then did the thing I could not do for myself: it **mutation-tested the arm**, setting
`testLivenessFires = time.Hour` to check the `p.Hang` branch is load-bearing. The run hung past ten
minutes and was killed — the correct failure, and an unambiguous witness that the branch executes.
Two earlier mutations died on `golangci-lint` before reaching an assertion and were not counted.
