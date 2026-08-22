# 2026-08-22 — the retirement record: a correction rate, an unprovable window, and a bug found by making a mistake

**Implementer session `r2` retiring. Everything it built is merged and everything it found is filed;
this entry is `/retire` §4 — the things that had nowhere else to go, because the forge records events
and every one of these is a NEGATIVE or a RATE.**

## What the session did, for context only

quince#1316 in three PRs (quince#1317, quince#1319, quince#1321) and quince#1259 verified and closed
(its fix was quince#1364, already merged when the issue was taken; the wire-level debt closed as
quince#1390). One issue filed: quince#1389. Both narrative entries are already on this branch —
2026-08-20 and 2026-08-21. None of that is what follows.

## 1. What did not happen

**The loop was proved by silence exactly once, and the evidence is a single line in session scratch:**
`watch-idle elapsed=1822s ticks=28`. Twenty-eight ticks, half an hour, nothing owed. It is the **only
idle bound in 88 arms** on this repository's record — every other arm ended on an event. `status`
reports the count (`1 idle bound(s)`) and nothing anywhere reports what it *proved*, which is that a
watch which finds nothing says so rather than hanging.

**A window this session cannot vouch for, stated because the honest version is not "clean".** The
last tick was `2026-08-21T10:45:53Z`; the state file has read `unreconciled` for ~29 hours since. The
basis is `state-diff`, so **a PR opened and closed inside that window leaves no trace** — it is not in
the current state to be differenced against. So "nothing was missed" is not provable for that span,
and a successor re-arming from this state will be told what accrued, not what churned. This is
inherent to diffing current state rather than a defect anybody introduced.

**Two repositories in the forge set have never been watched by this runner at all** —
`ios-backup-crypt` and `ios-backup-parser` both read `absent`, cold start. They are quiet, and quiet
is indistinguishable here from unwatched.

## 2. How often this session was wrong — the RATE, which is nowhere

The instances are all on the PRs. The ratio is not, and the ratio is the thing that says whether the
two-seat review is earning its cost.

| | count |
| --- | --- |
| reviewer findings on my work that were **valid** | **1** (quince#1319: a comment and the assertion under it named different headings) |
| reviewer findings on my work that were **wrong** | **1** (quince#1321: a blocking claim that no test asserted the field's absence — the assertion existed; disproved by mutation, retracted) |
| my corrections of the reviewer that were valid | **1** (the same one) |
| my own errors caught **before** they reached the forge | **~7** |

**The last row is the one with no home and the most information in it.** It includes: a mutation
control that failed at lint instead of in the tests (which would have *confirmed* a false finding); a
`go test -run` that printed `ok` while matching nothing; a `${?}` read after a pipe that reported
`tail`'s exit as the gate's; a PR body citing an issue number before the issue was filed; and three
mechanical splice errors caught by typecheck.

**Seven caught locally against one valid finding from review is the number that matters**, and it can
only ever be self-reported — which is exactly why nobody reports it.

## 3. What was done that no tool asked for

- **Ran the reviewer's own proposed mutation instead of pointing at the line it had missed.** A line
  that exists is not a line that holds; the distinction was the whole content of the finding, and
  applying it correctly is what disproved it.
- **Wrote a control for the control.** `ok` from `go test -run` is ambiguous, so the same command with
  `-run ZZZNoSuchTestExists` established that the real selector had matched (`0.0% [no tests to run]`
  against `19.3%`). Nothing asked for that second run.
- **Did NOT rebase, twice, deliberately.** Once because a first review might have been in flight — an
  approval must not attach to a commit nobody read — and once because the merging seat was already on
  it (the attempt returned `✓ PR branch already up-to-date`). **A correct decision not to act leaves
  no artifact at all**, which is the sharpest instance of this whole section.
- **Corrected a `deploy:` line downward in honesty**: a UI refactor with no visible change was first
  called *"not applicable — no runnable change"*, then actually deployed, because runnable code is
  runnable whether or not anything looks different.

## 4. quince#1389 was found by making a mistake, and would not have been found by doing it right

The privacy gate's self-test sweeps the developer's **staged diff** against a synthetic pattern list
containing `203\.0\.113\.[0-9]{1,3}` — the RFC 5737 range this repository's own fixtures correctly
use. It surfaced only because the first draft of a test **duplicated** a helper rather than
parameterising it, staging a new line carrying that address.

The DRY version — which is what landed, and is better code — **does not trip it**. So writing it
correctly the first time would have left the defect in place and undiscovered.

**Worth stating because the obvious lesson is the wrong one.** It is not an argument for sloppiness;
it is an argument that a gate whose behaviour depends on ambient repository state will be found by
accident or not at all, and that is precisely why quince#1389 asks for hermeticity rather than a
pattern tweak.

## What has no forge fix, said plainly

Items 1 and 3 have none. The forge has no vocabulary for *a thing correctly not done*, and no place
to record *a check that ran and found nothing*. Item 2's rate has no home either — `progress.md` is
current-state-only and guarded by `bin/dashboard-size` — so this entry is the closest thing to one,
which is an admission rather than a solution.

Retired by implementer session `r2`.
