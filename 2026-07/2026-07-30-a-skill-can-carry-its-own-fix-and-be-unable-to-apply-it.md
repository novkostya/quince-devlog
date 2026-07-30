# 2026-07-30 — A skill can carry its own fix and be unable to apply it: `/architect` §1 said "declare first, before anything reads or writes state", and §0 ran first and read state

**A skill can carry its own fix and be unable to apply it: `/architect` §1 said "declare
first, before anything reads or writes state", and §0 ran first and read state.** Declaring a runner
name **relocates** the state directory, so `status` read before it answers about the undeclared
top-level path — and for a session resuming a name that has state, that reports **`absent`** where the
truth is **`dead`**. Those are the two answers §0 spends twenty lines insisting must never be confused:
`dead` carries an accrued observation to re-arm from, `absent` says nothing was ever armed. Measured
2026-07-29 on the architect box: `absent (exit 4) … Cold start; nothing inherited` at 15:03:58Z, and at
15:08:24Z the session found that declaring had moved the directory out from under that answer. It was a
genuine cold start, so nothing was lost — **the defect is that the report could not have told the two
apart.** **And the instance that FILED quince#241 was worse: both answers were `dead`** —
`no_watcher_record` at the undeclared path against `no_process` at `arch1/`, whose observations were
**2h43m apart** (measured by the architect seat, whose state directory still holds the orphaned file;
corroborated here only in structure — this box has per-runner directories and no top-level state,
because every session on it declared first). Where `absent`/`dead` differ in the WORD and mislead by
reasoning, `dead`/`dead` differs only in CONTENT — so a session that reports the right answer, exactly
as §0 instructs, still re-arms against the wrong observation, and no amount of careful reading
recovers it. Only declaring first makes the two distinguishable at all, which is the stronger argument
for the fix and the one the issue came from. `/kickoff` had the same split across §0 and §3. Same shape as quince#100: a rule that says
*what* and not *when*, where the natural order is the broken one. **The declaration moved INTO §0
rather than the sections being swapped**, because renumbering would ripple into `loop-protocol.md`,
which both skills share — and drift between those two files is what quince#54 is about. **One claim was
measured rather than asserted on the way**: re-declaring a runner name is a clean no-op from the SAME
session, but from a different session a name whose holder is provably gone is **reclaimed** rather than
refused (quince#211) — so "a taken name is refused" holds only while the holder is live, and reclaim is
the path a resuming session actually takes.
([quince#241](https://github.com/novkostya/quince/issues/241),
[quince#278](https://github.com/novkostya/quince/pull/278),
[quince#100](https://github.com/novkostya/quince/issues/100))
