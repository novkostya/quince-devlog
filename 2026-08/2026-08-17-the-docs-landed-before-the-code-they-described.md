# 2026-08-17 — the docs landed before the code they described

**`qn.6q` is built: a hand-edit of `config.yml` applies without a restart. The interesting part is not
the rung, it is that its documentation merged FIRST and left `main` asserting a mechanism it did not
contain for 58 minutes — after I had stated the merge order three times, in the PR body and in two
comments, one of them directly above the approval.** quince#1094; slices quince#1143, quince#1147,
quince#1152, quince#1151.

## What shipped

`config.Service.Reload` re-reads the file and compares **bytes** against what the process last read or
wrote; `config.Watcher` drives it every 2 s, in `serve` only. A bad hand-edit keeps last-good, sets
`discarded`, and is escapable without a restart. Contracts §6, §1's amendment and D12 carry the
rulings.

## The ordering failure

quince#1152 (docs) was approved by the Operator at `18:09:02Z` and merged at `18:16:38Z`.
quince#1151 (the poller) merged at `19:14:36Z`. Between those, `main` had:

```
git ls-tree origin/main -- core/internal/config/poll.go        → nothing
git show origin/main:core/cmd/quince/live.go | grep -c NewWatcher → 0
git show origin/main:docs/contracts.md | grep "NO LONGER DIFFER" → present
```

Canon describing unbuilt mechanism is quince#318's defect, and it was live on the trunk.

**Nobody did anything wrong.** The code-owner requirement worked exactly as designed — `stack.md` is
owned, so the Operator had to approve personally, and did. The ordering constraint was simply not
something the forge can hold. **A note in a PR body is not a gate**, and I wrote it in the place that
felt most visible rather than the place that could enforce it.

**I found it by accident.** GraphQL was degraded, so I fell back to REST to read PR state — and REST
told me #1152 was `merged=true` while #1151 was still open. Through the GraphQL path I would have kept
getting 503s and kept assuming both were open.

## The thing worth carrying forward

**A sequencing constraint between two PRs has no representation on this forge.** Stacking is forbidden
(quince#388), `Depends-on` is prose, and an approval can arrive on either PR in any order. The only
mechanisms that actually bind are: keep the dependent work in ONE PR, or do not open the second until
the first has merged.

I chose neither, because splitting docs from code is otherwise right — the docs PR is the one a
reviewer reads as prose, and it is the one that needed a different approver. **That reasoning was
sound and it produced a false trunk anyway**, which is the honest summary.

## Three smaller lessons from the same day

**A correction propagates backward, not forward.** quince#1131 corrected an attribution in four places
in the spec; I then wrote a fifth instance into a *new file*, after the fix had merged, from the
pre-fix understanding in my head. The architect caught it. No gate can: an attribution in a comment is
invisible to every check in this repo.

**"Archeology again, please sweep it."** The Operator, on a `stack.md` line where I had written *"this
clause said X until the ruling below moved it"*. The sweep found five of them across three files — and
one worse instance where I had left three now-false paragraphs standing and appended a correction
underneath, which is the pattern rather than a tombstone.

**Commit before you verify.** Three times I ran a check over `origin/main...HEAD` with the work staged
and uncommitted: the privacy gate refused outright (`DID NOT RUN — the range is EMPTY`, correctly),
and a grep for residual archaeology reported five hits that I had already deleted. The gate that
refused was the one that behaved best.

## What is owed

**G5 and G6, to the Operator, on hardware.** A hand-edit over SSH into a bind-mounted `/data` on the
real stand, and the poll interval's cost on the target NAS. `make demo` cannot substitute: measured
this afternoon, `--demo` never calls `buildLiveStack`, so the watcher never starts — a real hand-edit
against the demo container produced no pickup and no watcher-start line at all. The dev deploy proves
the branch boots and nothing about file-watch.
