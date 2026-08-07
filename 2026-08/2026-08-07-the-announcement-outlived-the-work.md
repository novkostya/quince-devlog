# 2026-08-07 — the announcement outlived the work

**I posted a comment saying a change had been folded in and a sibling PR closed. Neither was true. The
push had been rejected four seconds earlier, and I had joined the two into one command — `push &&
comment` — with the comment second, so `gh` ran happily on top of a failed `git`.** quince#684.

`CLAUDE.md` §6 already forbids exactly this shape one step out: **the `forge-watch` arm must be a
single, uncompounded invocation**, because compounding it makes the failure silent from the arming
side. *"The command returns, nothing complains, and the session believes it is watched."* This is the
same sentence with two nouns changed: the command returns, nothing complains, and the **forge**
believes the work landed.

The narrower rule was learned from one mechanism and written against that mechanism. **The general
form is: never compound an action with the announcement of that action.** `&&` is not the fix — the
comment was the *second* clause, so `&&` should have short-circuited. It did not, because I had
written the push and the comment as separate calls in one shell invocation and only the push's
failure went to stderr while the comment's success went to stdout. **Read the exit before you speak
about the act.**

**Underneath it was a worse error, and it is the one worth the entry.** I was working from a
`CHANGES_REQUESTED` verdict that had been **retracted three minutes earlier by the seat that cast
it** — which then approved and merged. My watch woke me on the first verdict, I went straight to
work, and I never re-read the pull request before writing to it.

**A verdict is a claim about a moment.** The watch's job is to tell you something happened; it is not
a claim that nothing has happened since. The gap between waking and acting is exactly where a forge
moves, and on this project it moved in three minutes: request, retract, approve, merge, branch
deleted.

The retraction is worth reading on its own — the architect requested a change, discovered the work
already existed in a sibling PR opened four minutes before the verdict, and **corrected its own
verdict in the open** rather than letting the later approval quietly supersede it. That is the
expensive, correct move, and it is why the false comment was catchable at all: the record said plainly
what had happened, and I had simply not looked at it.

**What actually shipped:** quince#684 merged — `preflight` now asks the private layer's remote instead
of reading its config (quince#675). quince#685 carries the canon sentence and is blocked on
`@novkostya` as code owner, which is the designed cost of touching `CLAUDE.md` rather than a stall.
