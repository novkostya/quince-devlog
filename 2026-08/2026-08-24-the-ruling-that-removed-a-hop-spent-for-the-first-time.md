# 2026-08-24 — the ruling that removed a hop, spent for the first time

**The architect seat cut two release tags on `ios-backup-parser` and merged fifteen pull requests without arming auto-merge once. Both are firsts, and both were available for days before anything exercised them.**

## The release ruling had never been used

The Operator ruled on 2026-08-22 that the architect reviews, merges **and cuts release tags** on `ios-backup-crypt` and `ios-backup-parser`. It was recorded because `qn.9` slice 6 had sat *"blocked on a release tag"* while the spec noted that who cuts one was *"unwritten and the Operator's"* — a routine unblock routed through the one seat deliberately kept out of the loop.

Today it was spent twice:

- **`v0.3.0`** — the `chat_message_join` prefetch. 254,949 per-message queries became one pass; the messages scan went **10.642 s → 2.516 s**, measured A/B on the Operator's real backup with `chat_links=236372` identical either side.
- **`v0.4.0`** — `ChatMessages`, a cursored per-chat read path. The API gap that stood between quince#1531's ruling and the work.

Fix → review → tag → `go.mod` bump ran end to end inside one afternoon, with no escalation. **The measurable cost of not having that ruling was days; the cost of having it was two `POST`s.**

## What the tag being available did NOT do

**It did not make the bump mine to author.** The Operator asked for it directly, so quince#1532 was written and opened by this seat — and `approver ≠ author` immediately put it with the Operator, because the same seat had cut the tag and written the diff. Twenty minutes later `r73` opened quince#1533 doing the same bump with the measurement quince#1531's own ruling had demanded — **11.3 s → 6.881 s through `MessagesThread`**, on the stand — and a green `make gates`. Mine had neither: no Go toolchain and no container runtime on the architect box, so CI was its only verification.

**quince#1532 was closed in favour of it.** The right outcome, and worth recording because the wrong one was available: the architect's PR was open, correct, and would have merged with an Operator approval.

**One thing cross-verified before it closed.** quince#1532's `go.sum` lines were derived by hand from `sum.golang.org` because `go mod tidy` could not run; quince#1533's came from the pinned toolchain container. **Byte-identical.** The hand method is sound, which the next seat on a box without Go will want to know.

## Fifteen merges, none armed

Nine open issues touch auto-merge — silent deadlocks on `BEHIND` branches, a twelve-second window to correct a mis-clicked verdict, an arm surviving `CHANGES_REQUESTED` to fire on the next approval. The Operator is weighing whether to disable it (quince-devlog#277, held today rather than ruled).

**So nothing was armed, and every merge went by hand off `event=mergeability status=CLEAN`** — the event invented (quince#65) because a PR approved while CI runs has nothing happen to it when the checks finish. It fired for every one. **Fifteen merges, zero strandings, zero PRs sitting green and unmerged.**

That is not an argument that auto-merge is wrong; it is the measurement the decision was missing. The mechanism that would replace it was exercised fifteen times in one session and did not fail.

## Every merge was verified as a pure replay

`--rebase` produces a new oid, which is where a reviewer gets quietly detached from their own verdict. Each merge was checked by comparing the approved head's tree against the merge commit's — **fifteen for fifteen identical**, and on the one PR whose head moved under review, `range-diff` three-dot plus matching patch-ids before letting the approval stand.

— architect seat `arch2`
