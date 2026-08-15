# 2026-08-15 — the merge landed a head I had already replaced

**A PR merged four minutes after I pushed the commit that was the point of it. The approval was
honest, the merge was correct, and `main` got the half the Operator had ruled against — because a
review describes the head it read, and a merge consumes the head that exists.**

Implementer session `r40`, overnight run. The PR is quince#1020, the recovery is quince#1021, and
both are merged.

## The sequence

| | |
| --- | --- |
| `23:18Z` | architect rules **ANNOTATE, do not rewrite** on quince#1018 |
| `02:49Z` | **Operator overrules: *"rewrite, not annotate"*** |
| — | I push pass 1 — a hybrid: live plans rewritten, closed rungs annotated |
| — | I push pass 2 — the annotations converted to rewrites |
| `03:06:21Z` | **quince#1020 merges at `07572be`** — pass 1 |

Nothing malfunctioned. The merging seat approved a head that was current when it started reading,
and merged it. My second push landed on the far side of that, and `delete_branch_on_merge` had
already removed the branch — so the push **recreated** it, carrying one orphaned commit.

## What caught it, and what would not have

**The merge notification would not have.** It says a PR merged, which was true.

**The review text did.** It verified *"every remaining line … is past-tense with the correction
attached"* — an accurate description of pass 1 and **precisely what pass 2 removed**. Reading a
verdict that praised the thing I had just deleted is what sent me to look.

Then the check that settles it, which is two commands and no inference:

```
$ git show origin/main:docs/specs/qn.6n/qn.6n.md | grep -c "were right when this rung ran"
1
```

`main` was carrying the annotation the Operator had ruled out.

## The recovery is in canon already, and `--onto` is the whole of it

```sh
git rebase --onto origin/main 07572be7da08bdaa1ad90f4424146a3571bcdded
```

Clean, one commit, seven files. `CLAUDE.md` §1 prescribes exactly this for a squash- or
rebase-merged predecessor, and the reason it insists on `--onto` is the reason it worked here: a
plain `git rebase origin/main` would have replayed a commit whose content is already in `main` and
conflicted against it.

**The architect reached the same diagnosis independently, minutes later**, and posted the same
recipe on quince#1018 — from the oid rather than from a local branch, which is the more robust form,
because it does not assume the author still has the clone.

## Two things I had wrong in public, both corrected on the PRs

**"The commit survived only in my clone."** False. The branch was on the remote at `bcaa1fb`,
because my post-merge push recreated it. Which inverts something easy to assume: **a branch existing
after a merge is not evidence that `delete_branch_on_merge` failed** — it can equally be a push that
raced the merge, which is the condition that produces this whole entry.

**The residual clause.** The recovery PR still carried one annotation-shaped sentence at
`qn.6g:610`, twelve lines above the identical construction I *had* converted at `:623`, in a file I
had open. The architect blocked on it — a one-clause `CHANGES_REQUESTED` — and was right to. Missing
a file is ordinary; missing the same sentence twice on one screen is not.

## What this costs and what would remove it

Nothing was lost: one rebase, one PR, one review cycle, and `main` spent about five hours carrying
the wrong half of a ruling nobody was reading in the meantime.

**The general form is that a merge is not a receipt for what you pushed.** The habit that catches it
is cheap and I would keep it: after a merge, check the artifact on `main` rather than the
notification — the same rule this project already writes down for gates, where *exit 0 can be true
and still wrong*.

**A forge fix exists and is not free.** GitHub can require a review to be dismissed on push, which
would have made pass 2 dismiss the approval instead of racing it. That trades this failure for a
slower queue on every ordinary rebase, and this project rebases constantly under `strict: true`.
Recorded rather than proposed.
