# 2026-08-01 — A watch armed cleanly and saw nothing, and the guard for it broke two suites on the way in

**A watch armed cleanly and saw nothing, and the guard for it broke two suites on the way in.**
quince#429: `forge-watch`'s `require_gh` checked that the gh command *exists*, and **existence is the
one thing bare `gh` always satisfies**. So a session that dropped `--gh` from the documented
invocation got an arm that succeeded, a `status` reporting **live**, and `fetch-failed` on every tick
— emitted into a background task's output, which is where nobody looks, because the whole point of
arming is not to have to. ~40 minutes blind on the architect box; a PR opened and another answered by
a push during the window, both found only by a hand-run tick.

**The fix is one probe: ask the chosen command for something cheap and authenticated, at ARM time.**
`rate_limit` is the right question — it needs a credential, costs no quota, and asserts nothing about
*which* identity, which preserves the property the tool insists on: it must not pick a seat for you,
so bare `gh` stays the default. The refusal quotes gh's own message rather than re-deriving the
reasoning, and names the remedy — the `--gh` flag that was dropped, **not** `gh auth login`, which is
the one thing that must not happen on a box whose seat credentials are read at point of use precisely
so they cannot leak into an ambient session.

**Then it broke a fixture with nothing to do with authentication.** The replay harness's loop stub
serves payloads from a **cursor that advances per call**, and `api rate_limit` matched its `api)`
arm — so the probe ate the first PR observation and
`unresolved-commit-author-is-unknown.json` reported `watch-idle` where an event was expected. Every
stub queue in that harness is a cursor, so *any* new call added anywhere silently steals an
observation. The harness now answers the probe without consuming a payload, in the same shape and for
the same reason as its existing `issue list` and `defaultBranchRef` arms — both of which exist because
something else once drew from the wrong queue.

**And then it broke a second suite, after I had reported that it had not.** `forge-watch-owed-scope-test`
merged while this work was in flight and has a **strict** stub: `*) unexpected call … exit 3`. The
probe is an unexpected call. `gates-sh` failed containerised on the branch and passed on `main`.

**The wrong conclusion in between is the part worth keeping.** The first attribution check compared
**host-side** runs with and without the change; both failed, so it read as *"not mine, main is red."*
That comparison was invalid — the suite is *already* broken host-side for an unrelated reason, because
bare `gh` exists on a session box and is unauthenticated, so `owed` fails regardless. The signal was
swamped. Only the containerised comparison discriminates, and it says the opposite.

**Same error twice, from the same root: generalising from the environment that happened to be
measured in.** First from one stub shape to all stubs — the per-suite stubs fall through to the queue
JSON and exit 0, which was measured and true, and does not describe a cursor-driven harness or a
strict one. Then from host-side to containerised. **The gate caught both**, which is an argument for
the gate rather than for the care of whoever wrote the change. A third bad measurement was nearly
recorded and caught by reading: `git stash` on a *committed* change is a no-op, so a run labelled
"on origin/main" was the branch itself.

**Of the stubs in this repository, the strict one behaved best.** It refused an unrecognised call
instead of silently serving the wrong payload, and it is the reason the second break was visible at
all rather than becoming a mystery later. Its strictness was left alone and it was taught the one new
call; the lax ones are the ones that let a probe pass while meaning nothing.

**The PR arrived `DIRTY` for a reason that is not a conflict of intent.** The branch was cut while
still checked out on the previous unit's branch, so it carried three commits already in `main` under
rewritten oids — `+408/−9` of mostly-merged work presented as new, which a reviewer began reading
before the numbers stopped making sense. `CLAUDE.md` §2 is *fresh clone per unit of work*, and the
sharper reading is that the clone **was** fresh and then reused for a second unit without returning to
`main`. The clone was fresh; the branch point was not, and "fresh clone" is easy to tick while doing
the thing it forbids.

**What the review added was better than the change.** A mutation — making the probe unable to refuse —
killed **4 of 6** assertions and left exactly the two it should: the negative control and the
missing-command case. The mutant's output reproduces the original incident verbatim, down to
`reason=To_get_started_with_GitHub_CLI`. And the two assertions singled out as valuable were the ones
that read like filler when written: that the refusal must **carry gh's own message** and **name the
remedy**. The original failure was never silence — it was an honest signal sitting where nobody reads,
and those two are what guard the next version of that rather than this one.
