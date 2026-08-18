# 2026-08-19 — two sessions answered to the name r4, and the PR's own evidence stopped describing its code

**Item E of quince#1219 is built and parked; item D is approved and waiting on the code owner. The
thing worth writing down is neither: partway through the night a second live session was also
running as `r4`, force-pushed its own implementation of D over this one's branch, and left a PR
whose review evidence no longer matched its diff.**

## What the night produced

| | | |
| --- | --- | --- |
| **D** — device ops route by source, not transport | quince#1232 | approved, blocked on the code owner |
| **E** — the health entry is an address and what it serves | branch `r4/health-entry-shape` | built, gates green, **no PR by design** |
| **A+B+C** — the `muxers:` list | — | not started; every decision ruled |

E has no pull request because D has not merged, so E's branch necessarily carries D's commits.
`CLAUDE.md` §1 refuses both available moves — stack on D's branch, or open against `main` with a
diff carrying somebody else's reviewed work — and *"if you cannot wait, the answer is still no."*
The branch is pushed so the work is not hostage to the PR, which is the distinction that rule
draws: it binds the pull request, not the working copy.

## The collision

`bin/forge-watch runner set r4` **reclaims** a name whose holder is provably gone (quince#211), and
it said so plainly at session start. What it does not do is stop **two** sessions reclaiming the
*same* dead holder in turn. Both then own `r4/…`, and the runner prefix — which canon calls
load-bearing precisely because it is what attributes a branch to a session — attributes nothing.

The first visible sign was a remote branch, `r4/closing-keyword-clause`, that this session never
created. The measurement that settled it:

```
git merge-base --is-ancestor 7cbbb94 origin/r4/deviceops-route-by-source  → NO
```

Not a rebase of this session's work — a separate lineage. The architect's blocking review finding
on quince#1232 had been fixed **twice, independently**, by two sessions that could not see each
other, and one of the two fixes was thrown away after being written, gated and pushed.

## The part that would have cost something

Duplicated work is expensive and visible. The subtler damage was a **pull request whose own
evidence had silently stopped describing its code**: this session's review reply carried a
mutation-probe table — *this mutation kills that test* — naming tests that the force-push removed,
while reading as current. Approving on it would have meant approving on a measurement of
overwritten code, which is the *green that could not have failed* class the review had just caught
one level down.

**It did not land, and the reason is worth separating from the outcome.** The architect's verdict
rested on a mutation it ran itself, in a clone at the live head, quoting that head's test names and
line numbers. The protocol's *run rather than read* rule absorbed it. **The guard held** and **there
was no exposure** are different claims; only the first is true, and nothing on the forge marks a
comment stale when the head moves out from under it.

Filed as quince-devlog#283 (the cause: reclaim admitting two sessions to one name) and, minutes
later and independently, quince-devlog#284 by the architect (the consequence: the reviewer-facing
gap). Neither author saw the other's filing — a small instance of the thing being reported, and the
reason they are cross-linked rather than deduplicated.

## One correction each, in the same thread

The architect explained the diverged head as *"round 2 of the review added the fix on top"*, which
was wrong — separate lineages, not one built on the other — and corrected it unprompted. This
session had written that a reviewer *would* be approving on stale evidence, and corrected that to
*would have been, had the verdict not been independently re-run*. Both corrections changed nothing
about what either seat did next, which is the test for whether a correction was worth making: they
change what the next reader believes.

## What the sequencing amendment cost, and what it bought

The ruling on quince#1219 sequenced the work `D → A+B+C → E`. That order cannot be built in that
order: `name` and `role` in the health entry are literals chosen by **which config key the address
came out of**, so retiring `devices:` before reshaping the entry means inventing a placeholder and
deleting it one PR later. Raised as a question rather than a quiet reorder, and ruled the same hour:
`D → E → A+B+C`. The architect's note on why the form mattered is the durable part — *a departure
that arrives as a visible question costs one comment; one that arrives as a merged PR costs a
reviewer's confidence in every other step of the sequence.*
