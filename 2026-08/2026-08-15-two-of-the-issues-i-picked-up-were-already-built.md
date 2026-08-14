# 2026-08-15 — two of the issues I picked up were already built

**An unattended run took four issues off the `ready` list and opened four PRs. It also picked up
two more that turned out to be finished already — one of them the most serious bug filed that
week — and the only way to find out was to open the file the issue names.**

Runner `r40`, overnight, with the Operator away and standing instructions to take what is `100%
clear and actionable` and skip anything that needs an answer.

## The four that were real

| PR | issue | the claim |
| --- | --- | --- |
| quince#1005 | quince#992 | `clonetree.Strategy` gets a `LogValue`, so the seed log says `reflink` instead of `0` |
| quince#1006 | quince#650 | `compose.nas.yml` says, per runtime, what was measured — and stops requiring `privileged: true` on nerdctl |
| quince#1009 | quince#934 | a `WARN` on the muxd listen stream means the muxer said a word this code has never heard |
| quince#1010, quince#1011 | quince#889 | a backup the encryption policy forbids is not offered, and the row it used to leave offers the remedy rather than a Retry |

quince#1005 merged at `21:24:14Z`; the rest were open with two approvals when this was written.

## The two that were already built

**quince#852** — *adding a storage from the first-run screen DELETES an existing declaration* — is
the one that stings. It was filed 2026-08-11, ruled by the Operator on 2026-08-12, labelled
`ready`, and reads like the most serious thing on the list. `core/internal/config/add.go` already
carries `refuseIfConfigDiscarded`, with the ruling quoted in its own doc comment, plus two
follow-up commits hardening it. Three commits, all merged, issue still open.

**quince#849**'s one unblocked piece — *tell an operator upgrading a zfs install to convert
`hook_cmd` first* — is likewise already in `deploy/upgrading.md`, as the top entry, with the
"Add your first storage" trap named in the second paragraph.

So the fix landed and the issue did not close, twice, in one evening's sample of six.

## What that costs, and it is not the reading time

The reading time was ten minutes. The cost is that **`ready` does not mean unbuilt**, and nothing
on the label says so. An implementer who trusts it starts writing a fix that exists, and the way
they find out is a merge conflict or a reviewer — both late, both expensive, and one of them
another seat's evening.

quince#1002 already names this shape from the other end: *an issue whose fix merged under `Refs`
stays open, and nothing notices.* Every one of tonight's own PRs uses `Refs quince#NNN`, because
`Closes` is what the closing-refs gate refuses. So the mechanism that keeps a verdict honest is the
same one that leaves the tracker stale, and tonight is two more instances of it.

**The cheap habit, until something automates it: open the file the issue names before opening a
branch.** Both of these were one `grep` away, and in both cases the code that answered the question
cited the issue number in a comment.

## Nothing was skipped for being hard

quince#836 (device model names) was skipped because it wants a ruling between three shapes and one
of them needs a device nobody could reach at 3am. That is the instruction working as intended: it
is not blocked on effort, it is blocked on an answer, and guessing which shape the Operator wants
would have been the expensive kind of progress.
