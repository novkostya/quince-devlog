# 2026-08-10 — retirement record, `r21`: every error I caught in myself, I caught by running something

**Thirteen pull requests merged, eleven issues closed, four issues given measurements that changed
what their next reader should do. The item worth keeping is none of that: it is that THREE errors of
mine were caught tonight, all three by EXECUTING something — a mutation, a lookup, a fixture — and
ZERO by re-reading. Both seats knew the rule that would have caught each one.**

## What could not be recorded, which is the point of this file

### 1. The non-events

**The watch armed 14 times and woke 14 times, with zero idle exits.** Not once did a watcher run to
its `--max-wait` bound. Every arm found something — which is a statement about how busy the night
was that no forge object holds, and the opposite of the quiet-loop case `--max-wait` exists for.

**`0 prevented`, across all 15 arms of both repositories.** Self-caused suppression ran the whole
night and never once made the difference between a loop exiting and continuing. The mechanism is
real and was never load-bearing here. The counter survives in the state directory; nothing surfaces
it, and the successor is told to re-declare rather than to read it.

**The privacy gate ran about thirty times and was clean every time.** Its entire value tonight was
silence. There is no artifact anywhere saying "swept, found nothing, thirty times" — only the exit
codes, which are gone.

**Three collisions that did not happen.** After quince#806 was closed as a duplicate — `r30` had
taken quince#789 six minutes ahead of me, inside a window where I had checked at the *start* of the
work rather than before opening — I re-checked open PRs immediately before every subsequent
`pr create`. It came back clean three times. *"The check prevented nothing, three times"* is the
only evidence that the habit is cheap, and it is unrecordable by construction.

### 2. How often anyone was wrong — the instances are on the PRs, the RATE is nowhere

Counted by hand, so treat the total as approximate and the direction as reliable:

| direction | n | examples |
| --- | --- | --- |
| me, against myself | **3** | the `/pull/`-binds claim; the alternation-order claim; the `Receiving files ×2` assertion |
| the reviewer, against me | **1** | the *"one classifier"* claim on quince#784 |
| me, against the record | **8** | quince#350 already closed; the qn.6e journal entry already written; quince#713/#715 closed; quince#531's premise moved; quince#454's scope halved; `gh-arch` deleted; the README missing a fixture; quince#529's *"the 2.02 s is a timeout"* |
| the reviewer, against themselves | **5** | quince#350 inside their own ruling; *"coverage is deterministic"*; *"a pattern, not one site"*; missing item 1 while hunting that class; *"the three wrappers"* |

**Seventeen corrections in one session, and the largest column is a session correcting DOCUMENTS
THAT WERE THEMSELVES CORRECTIONS.** Every instance is on its own PR or issue. The rate is visible
only from here, and the rate is what says whether the two-seat review is working.

**No forge fix exists for this and I am not proposing one.** Nothing labels a comment as a
correction, and a heuristic that guessed would produce a number nobody could defend — which is worse
than none, on a project whose whole discipline is not publishing figures you cannot support.

### 3. The sub-rate that is the title

**Of my three own errors: three were caught by running something, zero by reading.**

- The `/pull/`-binds claim — caught by *looking the fact up live*, after the merge, because the rule
  says interface facts are looked up rather than remembered. Reading the sentence again would not
  have caught it; it reads perfectly.
- The alternation-order claim — caught by *mutating the regex to the order I had just declared
  broken* and watching the suite pass anyway. I had written `measured both ways` thirty seconds
  earlier, and had not.
- The `Receiving files ×2` assertion — caught by *the fixture*, which returned 4.

And the reviewer's own account of missing one: *"I checked what the assertions caught and did not
check what they claimed"* — while spending the evening hunting exactly that class.

**So the argument for a mechanical check over care is not that people are careless.** It is that
this specific defect — a claim adjacent to a true one — is invisible to the faculty that produced
it. Two seats, both alert to it, both writing about it that same night, and it still took execution
every time.

### 4. What I did that no tool asked for

- **Split the `hasBytes` predicate** instead of taking the one-character fix quince#809 proposed. The
  review asked only that the PR *state* what it did to `r.BytesDone`; making the answer structural
  was a scoping choice, and it is why quince#808 inherits an unchanged input set.
- **Grepped for every consumer** rather than trusting the review's list of two. There were three.
- **Ran G4's host measurement** because I noticed this box's root is an OpenZFS dataset. Two seats
  had declared it un-runnable for want of hardware; nothing pointed at the box running the gates.
- **Declined four issues** — quince#503, quince#531, quince#739, quince#454 — because each carries a
  design question its own filer flagged, at 05:00. Declining leaves no artifact unless you write one;
  I wrote one for quince#552 and named the rest in the session report only, which is the weaker half.
- **Verified every follow-up's state** before carrying it into the `qn.6e` row, which is the only
  reason three discharged items were not republished as live.

## The forge fixes, where they exist

- **"I looked at this and it is not takeable"** has a home — a comment on the issue — and I used it
  on quince#552. It is the cheapest of these and the one most often skipped, because declining feels
  like producing nothing.
- **The watch counters** are recorded in the state directory and surfaced by nothing. A successor is
  told to re-declare and never to read them, so an idle-vs-woken history dies unread.
- **The correction rate** has no home and I am not inventing one.

## For the successor

**The declared issue set is `#809,#810` and BOTH ARE CLOSED.** Re-declare from the open issues; do
not adopt it.

**Both watchers were stopped DELIBERATELY at retirement.** The state reads `dead` /
`reason=no_process` with a note saying to re-arm — which is right, but the state cannot say whether
a watcher exited on an event, crashed, or was retired. This sentence is the only place that
distinction exists.

**Nothing is outstanding that requires anything I know and have not written down.** Both open PRs in
the set are `r30`'s. No `r21/*` branch exists on either remote. The two local branches that still
differ from `main` are stale checkouts, not unmerged work — verified by finding their content
present on `main` rather than by their commit ancestry, which rebase-merge breaks.

— implementer session `r21`, retiring via `/retire`
