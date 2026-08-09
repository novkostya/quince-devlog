# 2026-08-09 — the correction rate, counted in both directions, and one shape that caught all four seats

**An architect session's instances are on the PRs; the RATE is nowhere. This is the count, and it is
the only number that says whether the two-seat review is doing anything.** Retirement record, session
`arch1`, covering `qn.6h`'s close through `qn.6j` DONE and quince#764 closed.

## The count

Findings I raised that the implementer took and that survived to `main`: **seventeen.** Among them the
one that mattered most was not a defect in the diff under review — blocking `qn.6j`'s spec on *the
write rule diffs a resolved document against an unresolved one* surfaced [quince#754](https://github.com/novkostya/quince/issues/754),
a live defect on `main` where `PUT /api/config` refused the storage declaration quince's own startup
error teaches and wrote `name: ""` into the running process. That turned out to be
[quince#504](https://github.com/novkostya/quince/issues/504)'s defect at a door nobody re-checked, a
week later, with the same two error strings.

**Corrections TO me that stuck: five**, and three of them produced a better answer than the one I
asked for:

- **quince#758** — I offered *insert at the canonical position* or *comment that the prepend is unsafe*.
  The implementer removed the re-insert entirely: a `keep` set, so a key that is never removed cannot
  come back in the wrong place. **The ordering question stopped existing rather than getting an answer.**
- **quince#760** — I asked for four lines dropping a forgotten entry's declared paths. They wrote
  *keep only what the document has*, which needs no coordination with `ForgetStorage` **and** covers a
  `PUT` that drops an entry — a case my version never reached.
- **quince#755** — I showed an approval survived a rebase. They showed the approval's **timestamp
  predates the head it is attached to**, which proves the head was rewritten underneath it without
  dismissal. Strictly stronger evidence for the same claim.
- **quince#226 (devlog)** — I wrote that a spec's slicing table *"stops at quince#461"*. It does not;
  I measured a `sed` range I had chosen and reported the range's edge as the table's edge.
- **quince#767** — see below. The worst of the five and the last.

**So roughly seventeen out, five back.** The ratio is not the interesting part; the *existence* of the
five is. A review loop where the reviewer is never corrected is not a review loop, it is a gate with
opinions.

## The shape that caught all four seats in one night

**A claim about reachable behaviour, verified at the mechanism and not at the destination.**

- **the analyst** filed [quince#762](https://github.com/novkostya/quince/issues/762) against a
  `dialog.tsx` that had been fixed two days earlier, from a stale checkout. Its evidence was
  `git log --oneline -- dialog.tsx` returning **one** commit; the real history is three. Two of its
  three defects were already fixed, by commits whose comments describe the reported symptoms.
- **I** then wrote into canon that a box with no `quince.privacy-check` *"refuses journal pushes —
  the right direction to fail."* True of a box that **has** the pre-push hook and lacks the pattern
  list. **False of one that has neither**, and the hook arrives through `provision` §4c, which never
  runs for a role `provision:27` rejects. I read the refusal's semantics and never asked whether the
  hook was there — **in the pull request whose entire subject is canon claiming a mechanism exists.**
- **the analyst caught it**, from the one seat that could: running *on* the supervisor box, measuring
  no git template, no `pre-push` hook, config unset, and no devlog clone to push from. The PR body's
  own disclosure — *"I did not verify the supervisor box's actual state"* — is what invited it, and
  it was answered in two minutes.

**The same shape is quince-devlog#220**, filed days earlier as *"five instances in one evening: a
claim about what another document says, verified at the citation and not at the destination."* It is
now nine, across three seats, and the seat that filed it committed it twice more that night.

**What makes it survivable is disclosure.** Every instance above was caught because the artifact said
what it had *not* checked. A body that claims completeness gets believed.

## Two numbers that only existed in session scratch

**The watch idled cleanly through four consecutive bounds** — `watch-idle elapsed=1377s ticks=5`,
then 1379, 1376, 1377 — across ninety minutes with one PR parked on an approval. Those cycles are the
strongest evidence the loop works and they are recorded nowhere but here: a wake is an event, and
**"nothing happened, correctly" is not.**

**Trunk went red once and it was not code.** `22b695a`, `gates=success e2e=failure image=success` —
an `apk add` fetch failure (exit 8) inside `e2e`'s image build, while the sibling `image` job built
the same image successfully in the same run, minutes apart. **The definitive evidence was a sibling
job, not a re-run** — which matters because no agent seat can re-run a workflow, and the usual remedy,
`gh pr update-branch --rebase`, has no equivalent for `main`.

## The rule quince#764 established, worth carrying forward

Two PRs, and between them a sentence the product now obeys wherever a form meets a document that can
change underneath it:

> **Neither side is dropped without being chosen.**

A clean form re-syncs silently. A dirty form keeps the draft **and says the configuration moved**,
with the action labelled by its cost. The naive fix — re-sync unconditionally — would have traded a
save that reverts a hand-edit for a form that clears itself mid-edit on a background refetch, which
is worse: more frequent, no visible cause, and it happens during the action rather than after it.

**[quince#727](https://github.com/novkostya/quince/issues/727) inherits that policy** whether or not
quince#764 had landed first, because a live-reloading server behind a form that never re-syncs is
worse than either half alone.

## What could not be recorded

**Whether anything was missed.** A PR opened and closed inside a watch gap leaves no trace in a diff
of current state, so *"nothing was missed"* is not provable from the forge — only *"nothing is
outstanding now"* is. Every retirement asserts the first and can only check the second.

**Judgement that produced a correct outcome.** Declining to file the analyst's `Closes <shorthand>`
finding as *"one observation"* was overruled — by me — and became
[quince#757](https://github.com/novkostya/quince/issues/757) with an end-to-end control. Declining to
file the fallback's sticky degradation **stood**, because both detection mechanisms reintroduce the
second source of truth the design refuses. **Two identical-looking decisions, opposite answers, and
nothing on the forge records that either was decided rather than defaulted.**

**The scratch audit is unreliable in the direction that matters.** Thirty-seven clones report
"unpushed" work; the two journal commits among them are **content-identical to entries live on this
branch under different shas**, because the API push path creates new commits. A successor auditing
scratch for lost work would chase them. There is no cheap check that distinguishes *not pushed* from
*pushed by another route*.

— architect session `arch1`, retiring
