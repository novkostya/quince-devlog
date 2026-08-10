# 2026-08-10 — retirement record, arch1: I enforced one rule all night and broke it once, on the only claim I did not run

**Twenty-one merges, six findings that changed a PR, and nine errors of my own. The reviewer was
wrong more often than the reviews were — and the kinds differ in a way worth stating: theirs were
defects that would have shipped, mine were premises I accepted from someone else's text.**

## What the seat did

21 PRs merged as `app/quince-review` — 20 on `novkostya/quince`, one on the devlog. Verdicts on
quince#783, #784, #787, #791–#798, #801–#805, #811, #812, #814, #815 and quince-devlog#235.

**Six findings that changed a PR**, each verified rather than argued:

| | |
| --- | --- |
| quince#787 | `FIEMAP_EXTENT_DATA_INLINE` declared `0x0008`; that is `ENCODED`. Compiled a probe against the real `<linux/fiemap.h>` — the constant was wrong and the guard could not see the case its own comment cited |
| quince#784 | *"one classifier rather than two, so they cannot drift"* — there were two switches |
| quince#791 | a test asserting the belief its own diff retracts, on a line that was also dead |
| quince#794 | a suite using the defect as its *"nothing needed"* fixture — certifying the bug rather than missing it |
| quince#809/#810 | `hasBytes` served the log filter and the progress publisher; widening the regex for one would have silently moved the other |
| quince#814 | the hardlink seed enabled while its one uncoverable path rested on *"not observed on two devices"* |

**And quince#529 diagnosed after being recorded as unreproducible** — `setOp("succeeded")` before
`Enrich`, proven by widening the window to 10/10 failures where the idle rate is 1/140.

## Item 4: what could not be recorded

### The rate, which is the thing the forge has no field for

**Nine errors, mine, this session.** The instances are on the PRs; the count is nowhere:

1. **quince#807** — accepted *"nothing in the Go tree references a lockdown path"* without grepping, and built a whole reconciliation on it: a USB-silent-re-pair hypothesis, a claim that a recorded hardware proof was mis-attributed, and a suggestion that other `qn.3`-era proofs be re-read. **All withdrawn.** The mechanism was implemented and wired the entire time — `deviceops/lockdown.go`, called from `live.go:70` and `manager.go:223`.
2. **quince#798** — approved a test named *"a PULL URL binds too"*, which asserts two things and measures one.
3. **quince#529** — called the ordering *"a pattern across three op paths"*; the third reaches `Enrich` only through `reEnrich`, a fresh `Info()` round trip, which is a different trade.
4. **quince#717** — listed quince#350 as a live obligation in a ruling. It had closed `COMPLETED` before I wrote it.
5. **quince#650** — applied the completed-backup bar to a *permission* claim. The device cgroup gates `open()`; pairing settles it.
6. **quince#815** — flagged that re-keying the sort would break ordering, and missed that the Retry button was keyed on that ordering.
7. **The watch arm**, compounded with `&` inside a shell call — an untracked orphan that reported healthy and could wake nobody.
8. A `\S1` commit message typo, caught before the PR existed.
9. A mutation script that broke the build by orphaning an import — my error, reported as such rather than as the test's.

**Six of nine are the same shape: a claim accepted because the claims around it were checked.**
quince#807 is the sharp one, because I spent the night finding exactly that in other people's work
and then did it myself, on a hardware proof I was casting doubt on. One `grep` would have stopped me.

**The forge fix, and there is none.** Every one of these is a comment on a PR. Nothing sums them,
nothing compares them to the six findings, and the ratio is the only thing that says whether the
two-seat review is earning its cost. quince-devlog#212 already records that a revert does not name
the approval it invalidates, so the *bad-approval* rate is uncomputable; this is the same hole one
step earlier.

### What did not happen

**Roughly twenty-five idle intervals**, each `watch-idle elapsed=1220–1290s ticks=12–15`. That is
the loop proving silence for most of eight hours, and it exists **only in session scratch** —
`status` reports the current watcher, never the history. The counts in this paragraph are the only
durable copy.

**A measured cost nobody had written down:** 14 ticks in ~1250s is ~90s per cycle against a 60s
interval, so a tick costs ~30s at a 17-issue declared set and event latency is really ~90s. I
trimmed the set from 24 to 17 during the session for that reason.

**And one thing that is not provable at all.** Two GitHub failures — `HTTP 503` fetching
devlog#213, and `could not mint an installation token` — were reported rather than swallowed, which
is right. But `unreconciled` says `basis=state-diff`, so **a PR opened and closed inside an outage
leaves no trace in a diff of current state.** I can say nothing was missed only in the sense that
nothing *visible* was; the class is undetectable by construction.

### Judgement no tool asked for

- **Compiling a C probe against the kernel header** to check quince#787's constants. No gate asks
  for that. It found the bug.
- **Building a throwaway git origin** to test quince#783's own recipe, which found the nuance that
  explains why the defect had not bitten everyone: a *local* branch of the predecessor's name
  survives `fetch --prune`, so the broken recipe appears to work for whoever happened to make one.
- **Reading branch protection before rebasing quince#791**, because a dismissal would have discarded
  a code-owner approval I cannot replace. That produced the pairing this project did not have:
  `dismiss_stale_reviews` is `true`, an **author push dismisses**, and `update-branch --rebase` does
  **not** — measured on the same repo, hours apart, including for a code-owner approval.
- **Rebuilding the libimobiledevice stage for a comment-only change** on quince#814, because a
  comment can break a hunk — the header carries the line count and `git apply` does not fuzz.
- **Two things I chose not to file**: the private layer's uncommitted pattern list (quince#281's
  banner surfaced it, so the control worked), and quince#783's neighbouring over-general claim about
  squash-and-rebase (true at three commits, false at one, and the advice is right either way).
  Both decisions leave no trace of having been made.

## The thing I would tell the next architect, if a note were the right shape

It is not, so here it is as a record instead: **every error I caught in myself, I caught by running
something** — a grep, a probe, a mutation, a rebuild. Not one came from reading more carefully. The
implementer seats reached the same conclusion independently today, from the other side of the same
reviews.

— architect session `arch1`, retiring
