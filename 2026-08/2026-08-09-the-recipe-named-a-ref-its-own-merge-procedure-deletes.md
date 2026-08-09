# 2026-08-09 — canon told authors to rebase onto a branch the merge procedure had already deleted

**`CLAUDE.md` §1 told an author to `git rebase --onto origin/main <predecessor-branch>` once the
predecessor landed. `delete_branch_on_merge` is `true` repo-wide, so that ref is gone at exactly the
moment the recipe is for. Filed by a retiring architect as
[quince#781](https://github.com/novkostya/quince/issues/781), fixed by its successor as
[quince#783](https://github.com/novkostya/quince/pull/783).**

## The interaction, and why it was nobody's mistake

Two pieces of canon, each correct alone. §1 gained the `--onto` recipe that morning
([quince#773](https://github.com/novkostya/quince/pull/773)), documenting that building locally on an
unmerged predecessor is safe and *recommended* — the thing quince#388's stacked-PR ruling does not
forbid. §6 has long said the merging seat deletes the head branch, and
[quince-devlog#214](https://github.com/novkostya/quince-devlog/issues/214) established that
`delete_branch_on_merge` is repo-wide, so the deletion happens on **every** merge whatever flags are
passed.

So the same change that made the unopened-successor shape *encouraged* also handed it a recipe that
cannot run. The author who follows canon exactly is the one who hits it.

**§6's existing pre-delete guard cannot see this.** It looks for open PRs whose base is this branch;
an unopened successor has no PR, so the query is empty and the guard passes. That is correct for what
it was built for — quince#388's silent PR closure — and blind to this, which is much milder: no
verdict is lost, only a ref.

## What the probe changed

The fix was measured against a throwaway origin rather than argued from git's manual, and two of the
four results were not what the issue or I expected.

| case | result |
| --- | --- |
| `--onto origin/main origin/<predecessor>` — canon verbatim | **`fatal: invalid upstream`** |
| a **local** branch of that name | **survives `fetch --prune`** — only the remote-tracking ref goes |
| `--onto origin/main <full oid>`, 1- and 3-commit predecessors | clean, carries one commit |
| plain `git rebase origin/main` after a **squash** | conflicts at 3 commits, **clean at 1** |

**Row 2 is why this had not been reported before.** An author who happened to create a local branch
sees the recipe work. The recipe is wrong and looks right, for a reason that has nothing to do with
the recipe — which is how it survived a day of use and two hand-worked instances.

**Row 4 stopped the PR growing.** It makes §1's neighbouring justification — that a squash always
breaks a plain rebase because the patch-id no longer matches — read as over-general: a *single*-commit
slice squashes to an identical patch and is dropped cleanly. At three commits it conflicts exactly as
written, and the advice the paragraph gives is right in both cases, so widening the PR would have
changed no instruction. Declared in the PR as a narrowing found and deliberately not acted on.

## The fix is smaller than the issue proposed

quince#781 described the merging seat posting the full 40-character oid after the fact, which is what
happened by hand twice that day. **That coordination is unnecessary.** The predecessor's commits are
the successor branch's own ancestors, so the oid resolves out of the author's object store — no
fetch, no second seat, no window:

```sh
git switch -c <runner>/<slice-2> origin/<predecessor>
PRED=$(git rev-parse HEAD)      # free now; not obtainable from the branch name later
git fetch && git rebase --onto origin/main "$PRED"
```

Of the issue's three candidates, two were taken and the third — widening §6's pre-delete check —
was declined on the issue's own reasoning: expensive, and still unable to see an author's private
clone. Recorded in the PR so the approval ruled on all three rather than silently narrowing to one.

## What this cost, and the seat boundary that held

`CLAUDE.md` is code-owned to `@novkostya`, so an architect verdict cannot clear it and an App cannot
be a code owner. Authored through `bin/gh-review` as `quince-review[bot]`, approved by the Operator
as code owner at `21:06:00Z`, merged at `21:08:43Z` — head oid identical at authorship, at approval
and at merge, so the staleness check had something real to compare.

**The successor did not author the issue it closed**, which is the shape quince#781 asked for in as
many words: *"a successor should not inherit a canon PR with no author."* A retiring session filed
rather than fixed, and the fix cost the next session one turn.

— architect session `arch1`
