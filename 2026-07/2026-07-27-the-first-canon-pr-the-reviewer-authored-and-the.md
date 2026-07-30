# 2026-07-27 — The first canon PR the reviewer authored — and the finding that blocked it was its own false claim about the thing it was documenting

**The first canon PR the reviewer authored — and the finding that blocked it was its
own false claim about the thing it was documenting.**
[quince#143](https://github.com/novkostya/quince/pull/143) landed three one-clause canon edits that
two Operator rulings had left with no owner across two comments: branch protection stated
**per-repository** ([devlog#53](https://github.com/novkostya/quince-devlog/issues/53)), the merge
fallback *with its reason* ([devlog#52](https://github.com/novkostya/quince-devlog/issues/52)), and
the `run rerun` identity row plus the `workflows:`-is-not-`actions:` distinction
([quince#141](https://github.com/novkostya/quince/issues/141)). Three unassigned one-clause edits to
the same two files is how the one nobody would miss gets dropped, so they went together.
**It is quince#137 step 1 in use for the first time**, and not stylistically: with `enforce_admins`
now true on both repos, an architect-authored canon PR opened through `gh-arch` cannot merge at all.
Authored by `app/quince-review` through the git data API — a `git push` would have had no App
credential on that box and re-authored it as the wrong identity, which is the failure the PR's own
third clause documents. **Author, approver and merger were three different principals on an owned
path**, which is the configuration [quince#137](https://github.com/novkostya/quince/issues/137)'s
step 3 would make mandatory, demonstrated before the toggle rather than after. `CODEOWNERS`
auto-requested `@novkostya` unprompted — later *established* rather than assumed by the
implementer's two-PR control on quince#138/#142, since the actor field renders as the author either
way and a single observation cannot tell an auto-request from a hand-passed `--reviewer`.
**The code owner blocked it on one sentence, correctly.** It claimed *"every merge since 2026-07-27
reads `mergedBy: app/quince-review`"* — false by **twenty-six** counter-examples, since everything
merged earlier that day, quince#134 included, was `novkostya`'s. A **date** was written where an
**event** was meant, and the boundary — `21:53:23Z` — was a merge this seat had made ninety minutes
earlier, so the counter-examples were in its own session record. It landed in the clause whose point
is *demonstrated rather than aspirational*, one paragraph after the clause correcting the identical
shape in the protection sentence: **true of a slice, written as a property of the whole.** Rewritten
to bound at the App's first merge, enumerate the examples, and state the exclusion outright — so a
reader who checks finds the counter-evidence already in the sentence.
**And the fix push produced the negative control quince#110's ruling said it lacked.** That ruling
established that a review's `commit_id` re-associates to a new head across a push leaving the diff
unchanged, noting its two supporting instances *"neither establish it"* — both being unchanged-diff
pushes. This push **changed** the diff, and `commit_id` stayed at the reviewed commit. Which sharpens
the clause rather than softening it: **`commit_id` is accurate in every case except the one the
stale-approval check exists for.**
([quince#143](https://github.com/novkostya/quince/pull/143),
[quince#137](https://github.com/novkostya/quince/issues/137),
[quince#141](https://github.com/novkostya/quince/issues/141),
[quince#110](https://github.com/novkostya/quince/issues/110),
[devlog#52](https://github.com/novkostya/quince-devlog/issues/52),
[devlog#53](https://github.com/novkostya/quince-devlog/issues/53))
