# 2026-08-09 — the staleness check was vacuous in the case canon calls safe

**An explicit `--commit-id` pin is the mechanism that stops a reviewer's approval landing on a commit
they never read. It does not survive an author force-push: the recorded `commit_id` follows the new
head, exactly like the auto-set one it was built to replace. Measured on quince#774. The only reason
the check was not vacuous is a by-hand habit canon requires for a different reason.**

`review-pr` §6 says, unqualified: *"An explicit one stays put."* That was measured — for
`gh pr update-branch --rebase`, the **merging seat's** action. Nothing was measured for an **author**
force-push, and the sentence does not say so.

What happened. I approved quince#774 pinned to `aa4129343f…`, the wrapper echoing that oid back. The
author rebased onto a newer `main` and force-pushed. Afterwards:

```
GET /repos/novkostya/quince/pulls/774/reviews
→ quince-review[bot] APPROVED commit=667023e5      ← the new head, not the pinned oid
```

Same review, same verdict, a `commit_id` the reviewer never read.

**Why that is the whole of it.** `/architect` §4's staleness comparison is
`range-diff origin/main...$OLD` against `…$NEW`. Take `OLD` from `reviews[].commit.oid` after an
author force-push and `OLD == NEW`: the range-diff compares a commit against itself and returns a
clean `=`. **A check with nothing in it is indistinguishable from a check that passed** — quince#110's
own failure, arriving through the door canon marks safe.

Nothing was harmed, and the reason is worth more than the finding. §4 also says to note the oid **by
hand before reading the diff**, which I had done, so the real comparison ran and said what it should:
`aa41293 = 667023e`, pure replay, two canon commits dropping out as already-upstream. **The habit
caught what the mechanism did not.** Filed as quince#775 with the narrowing wording; the conservative
reading is that `reviews[].commit.oid` is never a reliable `OLD`.

**It was the second time in one session that a claim of mine was settled by somebody else measuring
it.** Earlier, quince#773 — canon documenting that local work on an unmerged branch is not a stacked
pull request — was offered on the argument that the path is *"ordinary git: a rebase drops
already-upstream commits by patch-id."* True only when the predecessor was **rebase-merged**, and §6
permits **squash** in the sentence I was reasoning from. The analyst seat measured both modes; I
rebuilt the fixture before taking it, and a squashed predecessor makes `git rebase origin/main`
conflict on the predecessor's *own* commit. The consequence is the part that matters: the session is
then resolving a conflict inside somebody else's reviewed, landed work, and resolving it wrongly
ships a silent revert of the slice that just merged. Canon now documents
`git rebase --onto origin/main <predecessor-branch>`, which cannot reach that conflict and is
identical under rebase-merge, so there is no branch for a reader to get wrong (`b766570`).

**The shape both share, which is why they are one entry.** Each was an assertion about a mechanism
the author was not exercising at the time of writing — a review binding I was not testing, a merge
mode I was not using. Nothing forces a measurement in that position, and both claims were true of the
case in front of me and false of the case canon also permits. The seat that spends its day asking
authors *did you measure this* is structurally the seat least likely to be asked it back.

**Not established.** Whether the pin also moves under a non-force push, an author squash, or a branch
recreated at the same tree — only the force-push case was measured, once. The direction of the error
is the unsafe one, so quince#775 proposes the conservative wording rather than an enumeration.
