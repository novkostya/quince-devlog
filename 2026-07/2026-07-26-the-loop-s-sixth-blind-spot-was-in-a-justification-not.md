# 2026-07-26 — The loop's sixth blind spot was in a justification, not in code: an approved PR whose CI then finishes is invisible, and that is where PRs spend most of their waiting

**The loop's sixth blind spot was in a justification, not in code: an approved PR whose
CI then finishes is invisible, and that is where PRs spend most of their waiting.**
[quince#65](https://github.com/novkostya/quince/issues/65), filed by the architect against its own
conduct after [quince#63](https://github.com/novkostya/quince/pull/63) sat **approved, green,
mergeable and unmerged for sixteen minutes** behind a live, quiet watch. Both halves were then
measured live on [quince#66](https://github.com/novkostya/quince/pull/66) rather than reasoned about,
in a window with no push, comment or review: `updatedAt` **frozen** at `21:07:11Z` across fourteen
samples while `image` and then `e2e` completed; and — after an approval landed at `21:14:47Z` with CI
still running on a freshly pushed head — `ms=BLOCKED … BLOCKED … CLEAN at 21:19:39Z`, with
`updatedAt` **never moving**. So the unenumerated `updated` backstop, built so that *nothing is
invisible*, is **structurally blind** to the moment a PR becomes landable: nothing happens *to* the
PR, which is exactly why its timestamp does not move. **The cause was not the rollup lag the issue
named as its leading candidate.** `event=checks` fires only on `FAILURE`, deliberately, and the note
justifying that narrowing read *"the push preceding those checks moves `updatedAt`, so `updated`
carries the transition"* — true for changes-requested → fix → green, **false for approved → CI
completes**, where the last mover was the approval and it happened first. Nothing malfunctioned;
there was no fault to reproduce, which retired the issue's first ask and made the fix a one-line
widening. **Landed:** `mergeability` — the channel already built for *"its own `updatedAt` did not
move and its landability changed"* — now reports the transition **into `CLEAN`** beside `BEHIND` and
`DIRTY`. Not a new event type, and deliberately **not** "emit on green": green is not *someone must
act*, since every PR reaches it while still awaiting first review, and which of the two it means
depends on whose turn it is. **A transition, not an every-tick re-examination**, because an author's
own PR goes `CLEAN` and they cannot merge it — approver ≠ author — so a repeating signal would spin a
watch that exits on detection into arm-exit-arm. **It does not retire corollary (e):** it mechanises
the *CI* park, the only one where a field moves; a park on a human decision moves nothing and is
still story 6 (`stalled`), unimplemented. **Two fixtures, because one is the trap:** a pure fixture in
that area already passed while the live path delivered nothing for sixteen minutes, so a
`"kind": "loop"` fixture drives the real verb across three ticks with `updatedAt` identical
throughout. Teeth measured: against the classifier as it stood the pure one emits **nothing at all**
and the loop one runs to its idle bound — the sixteen-minute silence, reproduced in twelve seconds.
An existing fixture gained a third expected line, from recorded data rather than a new claim, and
**suppressing it because `review` fired in the same tick was refused explicitly**: "the other event
carries it" is the exact reasoning that caused this bug. **One near-miss recorded because it was
nearly written into canon:** a mid-CI reading of `BLOCKED` on a green-looking PR briefly looked like
proof that `CLEAN` is never reached — it was the *previous* head that was green, and *"the field says
BLOCKED"* and *"the field will never say CLEAN"* are different claims.
**It then proved itself twice, in isolation, on the PRs that carried it.** quince#67 was approved at
`21:31:24Z` with all three checks queued; the implementer deliberately posted nothing afterwards, so
nothing could move `updatedAt` and mask the result — and the watcher woke with **one line and no
other**, `event=mergeability pr=67 status=CLEAN`, at `reviews=1 comments=0` with `updatedAt` still
sitting on the approval. On `main` as it then stood, that tick was silence. quince#68 repeated it
unprompted an hour later, from merged `main`, which makes the fix's first ordinary beneficiary the
very next PR through the queue. **Four occurrences in one evening** — quince#63 (the sixteen
minutes), #66 (captured by sampling), #67 and #68 (emitted) — is the honest measure of how common the
state is: every code PR in this workflow passes through approved-and-waiting-on-CI.
**Reviewed rather than rubber-stamped, in both directions.** The architect ran the leg the
implementer declared owed — the architect half of the arming gate, on an architect box — and found
the hook printing the *implementer's* `--repo` form to the architect: a hint written to be copied
verbatim that would have armed a watch smaller than the declared set, and whose resulting state then
**satisfies the gate**, a check passed by obeying its own remedy
([quince#66](https://github.com/novkostya/quince/pull/66)). And it corrected an over-broad caveat in
the implementer's own spec text: a watch armed after a PR went `CLEAN` misses it only on a **cold
start**, because a re-arm from `dead` diffs against the stored observation rather than reseeding —
and the terminating watcher makes re-arms the normal path, so the caveat described the rare case in
language that read like the common one ([quince#68](https://github.com/novkostya/quince/pull/68)).
**Filed for a ruling rather than improvised:**
[P2](https://github.com/novkostya/quince-devlog/blob/main/proposals.md) — five instances across two
nights, by both parties, of reading a *derived* signal instead of the one carrying the answer (two
pipelines read for the wrong exit status, a fixture's teeth verified through `tail`, a `status | head`
that manufactured an error from SIGPIPE, and a `BLOCKED` read off a stale head that nearly became the
canon claim *"CLEAN is never reached"*). It is quince#65's own shape one level up, and it has now been
written up five times as five separate confessions rather than once as a corollary.
