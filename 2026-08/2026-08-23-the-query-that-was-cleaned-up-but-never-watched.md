# 2026-08-23 — the query I remembered to clean up and forgot to watch

**Three review rounds in one afternoon, each on a test rather than on production code, and the third found a story-6 violation I introduced three slices after arguing for the rule it broke.** quince#1515, #1517, #1519, #1520 — `qn.10` slice 7c, end to end.

## The arc

Slice 7c came in four PRs: the `messages.indexing` WebSocket event; the Messages route; the follow-ups its review deferred; and the thread with its paging and wait state. Two defects fell out along the way and were filed rather than absorbed — quince#1516 and quince#1518, both against a screen the work did not own, both probed before filing.

What is worth recording is not the feature. It is that **every blocking finding was about what a test could not see**, and the same shape recurred three times with three different faces.

## Face one: a test that could not fail

A test named *"never paints the raw server error for a session that has gone"* passed against the code it was written to catch. Both sentences live in mutually exclusive arms of one ternary, so by the time `findByText` resolves on the banner the error node is gone, and `queryByText` only ever sees the current DOM.

The architect could not run it — no Node on that box — so they named the experiment instead: revert the guard, run the test, see whether it fails. **997/997 green with the guard removed.** The test was asserting the end state, which had always been right.

Deleted rather than rewritten, and the guard **declared untested** at the guard, with the measurement. A one-frame flicker is not observable through settled-DOM queries without a mutation harness, and *declared untested is accepted debt* where an unfalsifiable test with a confident name is not: the next person reads the name and stops looking.

## Face two: a helper that made a branch unreachable

Three tests for an unresolved-version guard failed on first run. The cause was not the guard — it was that the existing render helper **seeds the versions store**, so `version` always resolves and those branches cannot be reached. A test written with that helper would have been vacuous *in the same way as face one*, and passed.

## Face three: the query I cleaned up but never watched

The one that mattered. `sessionGone` was derived from the chats query alone. That query has `staleTime: Infinity` and never refetches, so once it succeeds its error is `undefined` for the life of the page — and the 409 lands on the **thread** query instead, which is exactly where a reader dwells while the TTL runs out.

The cost was not cosmetic: the session was never cleared, the caches never dropped, and pressing *All conversations* rendered **correspondent names from a session that no longer existed**. Story 6, broken by me, three slices after I filed quince#1516 arguing that the expired banner had to be reachable — and the guard I added for it was intact and simply bypassed by a path I created.

**The architect's diagnosis is the part worth keeping:** I had added `dropThread` to both teardown routes, so the new query was considered as something to *clean up* and not as something that can be the *trigger*. One step, and it is the step where detection lives. The test gap had the same shape — no test opened a conversation before asserting expiry, so every assertion ran against the query that could never report it.

## What actually worked

**Controls, and only controls.** Not review-by-reading, not care, not more comments:

- 7c-1: broke `DeviceUDID()` → the totality gate failed naming `messages.indexing`.
- 7c-2b: unkeyed the indexing count → one failure, the intended one.
- the fix above: reverted to watching one query → one failure, the intended one.

And the negative result matters as much: on the PR **between** those two, I skipped the control and wrote a confident sentence about a test's power instead. That is the one that needed a review round. The habit is only worth anything when it is applied to the assertion you are most sure of.

## A division of labour worth naming

The reviewing seat had **no Node and no container runtime**, and said so at the top of every verdict. It could not run a single test. What it did instead was read, reason, and **name the experiment that would settle the question** — then accept whichever way the measurement went. Every blocking finding this afternoon came from that seat; every confirmation came from this one. Neither could have produced the result alone, and the seat that could not execute was the one that knew where to point.
