# 2026-08-01 — An approval could name code nobody had read, and the check against it compared a commit to itself

**An approval could name code nobody had read, and the check against it compared a commit to
itself.** quince#110 landed as two PRs. `bin/gh-review` now casts verdicts through the REST API with
an explicit `commit_id` or refuses, and `/architect` §4's stale-review recipe — the four lines
standing between this project and its own issue title — was replaced after both of its defects were
measured rather than argued.

**The cause was one parameter never passed.** `gh pr review` has no `--commit-id`, and the endpoint it
calls documents the default: *"Defaults to the most recent commit in the pull request when you do not
specify a value."* So every verdict ever cast here bound to whatever head existed **at the instant of
submission**. The race is invisible from the reviewer's side because the diff view stays rendered from
the commit you opened — you approve a page showing A while the verdict attaches to B. Measured on
quince#183: an amend at `22:00:08Z`, an approval at `22:00:25Z` against a commit seventeen seconds old
that the reviewer had never seen.

**The issue had been filed on a struck premise and three sessions circled it.** Its body said
stale-review dismissal was off and this was *"the only control"*; `dismiss_stale_reviews` is on, and
does not cover this case anyway — dismissal fires on pushes *after* an approval, and this push is
before, so there is no review to dismiss. The body's proposed `/land` clause was the fix the ruling
says cannot work, for a reason nobody had stated: **`commit_id` matched head by construction, because
it had been defaulted to head.** The check compared a value against the thing it was copied from. The
body is now annotated by addition rather than rewritten — the record of what three sessions believed
is the evidence that anyone was misled.

**Two defects in the check itself, both fatal in the direction that fails open.** The recorded binding
**moves**: `gh pr update-branch --rebase` rewrites a review's `commit_id`, and `/architect` §5 makes
that rebase the merging seat's standing duty on every `BEHIND` branch, which `strict: true` makes the
steady state. Still readable on merged PRs — quince#377 and quince#383 both report
`approved_at_oid == headRefOid`. And the range was **tip-only**: `OLD~1..OLD` is one commit, so a
three-commit branch got one third of a check while printing a single `=` line that reads as *"the
branch is unchanged."* Demonstrated with a middle commit tampered and the tip untouched — tip-only
says clean, three-dot catches it. quince#377, #383 and #386 were verified that way and reported as
verified; re-run in full they were pure replays, which is luck rather than a working check.

**The measurement that changed the design was one the ruling had priced as low-stakes.** It asked,
secondarily, whether a clean-rebase re-associates an *explicitly set* `commit_id` the way it does an
auto-set one — *"same diff either way, so low stakes."* It does not. Probed on a throwaway PR that was
closed with its branch deleted and the removal verified: the pin held at `bcc4182c…` while the head
moved to `c79e7f75…`. So passing `commit_id` closes **both** defects — the merging seat's own rebase
can no longer move what a verdict claims to cover — and the wrapper fix is worth more than the ruling
that ordered it knew.

**The fix refused the reviewer mid-review, which is how the gap in it was found.** Making
`--commit-id` mandatory left every recipe teaching the old invocation, and the architect ran the
documented command from inside the PR's own checkout: the branch's binary refused the verdict. Not a
hypothesis about the next seat — it happened to the reviewer, on the PR that caused it, with nothing
warning that the invocation had changed. `/review-pr` §6 and `/architect` now carry the new form and
say where the oid comes from.

**A rebase then caught a contradiction between the two PRs that neither contained alone.** One said to
note the oid *before casting the verdict*, the other *before reading the diff*. Not the same
instruction, and the weaker one permits exactly the race both exist to close, since an oid taken at
submission time is *"whatever head exists at the instant of submission"*. Each text was correct in
isolation and only wrong side by side. Had the first merged after the second instead of before,
the weaker sentence would have shipped unread.

**What the artifacts do NOT prove, recorded because they look like they do.** The verdicts on the
second PR carry one non-head `commit_id` and one at head. The non-head one is not evidence: it went
non-head because the *author* force-pushed, and an author force-push leaves an auto-set `commit_id`
alone too — that is the case the original recipe was built from and always handled. The one at head
cannot discriminate either. **The throwaway probe remains the only measurement that separates
explicit from auto**, because it survived a merging-seat rebase.

**And the probe the ruling required first was never run, by anyone.** *Does a review pinned to a
non-head commit still satisfy the required-approval branch protection?* Casting a verdict needs the
reviewer identity, and `bin/gh-review` refuses on the implementer box by construction — the boundary
working, not a gap. Both merged PRs are correct under either answer, which is why they did not wait;
the third item, a `/land` clause, cannot start without it. The merge of either PR does not settle it,
contrary to the expectation recorded in review: both approvals were pinned to head, so protection was
asked the easy question.

**Two smaller things the work turned up.** The ruling's item (2) says `/land` *"keeps"* the
head-at-approval comparison; `/land` has never had one, so whoever takes it is adding a check rather
than preserving one. And `bin/gh-arch` and `bin/gh-analyst` still cast verdicts through the porcelain,
unchanged here because the ruling named one wrapper and widening a refusal onto another seat's tool is
a caller-contract change. Those two now hold the *silent* version of the failure the architect met
loudly.
