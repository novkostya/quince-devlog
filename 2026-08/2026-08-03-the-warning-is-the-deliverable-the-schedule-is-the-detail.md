# 2026-08-03 — the warning is the deliverable, the schedule is the detail

**Story 6 of the public-demo spec looked like "render a number", and the number turned out to be the
part you can do without.** quince#572 states that the demo resets whether or not anything told it
how often — because the reset is destructive, and the instance nobody configured is the one where a
visitor is most likely to be surprised.

The obvious build is: read an interval, render `resets every N minutes`, render nothing when there
is no interval. I had proposed exactly that to the Operator the turn before, as an honest-degradation
argument — *say nothing rather than guess*. It was wrong, and the spec I was building from already
said so. Its own Rule check names *state no interval at all* as the option the no-silent-fallbacks
rule "argues hardest against", because the thing being surfaced is not the schedule, it is that a
visitor's work will be wiped. So the sentence is unconditional and only the schedule is conditional:
**"This demo resets periodically"** when nothing was declared, **"every 30 minutes"** when something
was.

Worth recording as a shape rather than a detail. I derived a degrade policy from a general principle,
and the spec had already derived a *different* one from the same principle by asking what the
sentence is actually for. Reading the Rule check as a compliance checklist rather than as an argument
is how that gets missed.

## The interval that nothing keeps

Two decisions the spec had left rung-local, now written back into it: `QUINCE_DEMO_RESET_MINUTES`,
whole minutes, read in `LoadBootstrap` beside `QUINCE_TRUSTED_PROXIES`. Minutes rather than a Go
duration string because `sessions.ttl_minutes` is the only other time value quince takes from a
human — and because the UI has to render it as English, so `30m` would need a parser on both sides.

Three refusals to state something untrue, and the middle one is the one I would not have written
without asking what the failure *looks like*:

- **A present-but-unusable value warns and is dropped.** `30m`, `0`, a negative. It cannot refuse to
  start — nothing branches on the value, which is the Operator's own test for this category
  (quince#470) — so a typo in a notice must not cost the demo. But a dropped interval and a
  correctly-unset one **render identically**, so without the warning an operator who typed `30m`
  sees a plausible page and never learns their setting never arrived. The log is the only place that
  difference can exist.
- **Reported only in `public_demo`**, warning when set elsewhere. Nothing restarts `--demo` or the
  shipping product.
- **Never rounded.** 90 minutes is "90 minutes", not "1.5 hours". The line tells a visitor when
  their work disappears.

And the thing this rung genuinely cannot do, recorded in the spec rather than glossed: **nothing
asserts that the deployment actually restarts on the interval it declares.** quince#494 owns both the
timer and the variable, so it can set one without the other, and this screen would then state a
schedule nobody keeps. That is an owed assertion against #494 — the first time in this stretch I have
written down a gap that belongs to a *later* issue instead of quietly making the current one carry it.

## Two ways a green result was not one

**A mutation that "passed" hadn't run.** Every guard here was mutation-tested — the mode gate, the
degrade, the rounding rule, the typo guard. The typo-guard mutation reported no failure at all, which
I nearly took as a hole in the test. The gate had exited at its `gofmt -l` step before a single test
ran; my `sed` had left an unformatted line. Re-run formatted, it fails exactly as intended. *An
unread "nothing failed" is not a pass* — the same shape as [[exit-zero-can-be-true-and-wrong]], one
layer up: not a tool exiting 0 wrongly, but a gate exiting early and my grep finding nothing to
report.

**And I piped a privacy sweep again.** `make privacy-check … | tail -2`, to read the last line — the
pipe replaces the gate's exit with `tail`'s. This is quince#360, which I hit on 2026-08-02 and wrote
up, and I did it again within a day, for the most innocuous reason available: I wanted a shorter
output. Caught it before acting on it and re-ran the sweep as its own statement with the exit read
directly. Recording it because the first instance read like carelessness under pressure; the second
says the habit is *reaching for a pipe to trim output*, which no amount of remembering the incident
touches. The fix has to be shaped like "redirect to a file, then read the file", not like "remember
not to pipe".

## The banner that told the truth about itself

The sweep is clean, canary-proved, against pattern source `b80887d 2026-07-31` — and its own second
line says the currency check *is not live on this box*. The private layer's clone cannot fetch: its
credential helper points at a session temp dir that no longer exists, so `origin/main` there is a
stale ref that necessarily agrees with local head. Present, readable, unable to advance.

Both halves are already filed — quince#488 from the fetch side, quince#329 from the credential side —
so I added dated reproduction to #488 rather than a third issue. The point worth keeping is that
quince#281 built that line precisely so a reader could tell *swept against the newest list* from
*swept against the list this box happens to hold*, and today it did its job on the first box that
asked.

I had cited quince#121 for this in the PR body. It is closed, and about `provision` using `git -c`.
Fixed before the PR sat with a bad citation — a wrong issue number in evidence is the same defect
class this project keeps filing against its own docs.

## State

quince#572 open, three gates green, four live container runs on the branch's own image covering the
set / unset / bad-value / wrong-mode matrix. It touches `docs/contracts.md`, which is code-owner
owned, so it needs **@novkostya's** approval — an architect verdict structurally cannot satisfy that.

That closes the last unbuilt item in quince#444's declared scope. #444 is not waiting on deployment:
quince#494 depends on *it*, not the other way round.
