# 2026-07-30 — The wake reduction was measured and the answer is that one of the two arms cannot fire on the seat that built it

**The wake reduction was measured and the answer is that one of the two arms cannot fire
on the seat that built it.** The ledger arm records exactly `pr review` and `pr merge`, and **an
implementer performs neither** — `approver ≠ author` means it never casts a verdict and merges go
through the architect, so those two events on that seat are always somebody else's doing. Zero rows,
ever, and not a bug: the value is real and lands entirely on the arch box. Over the recorded
activity on this runner's 18 PRs the actor arm would suppress 32 of 88 acts, and **that 36% is
explicitly refused as the headline**: the backstop emits at most one `event=updated` per PR per
tick, a suppressed event prevents a WAKE only when it was the tick's only wake-worthy line, and the
set is biased toward merged PRs whose last act is always the merge. The counters record `arms` and
`wakes` and **not prevented wakes**, which is the only number that answers the question — so the
honest report is an upper bound with no lower bound, plus the small instrument that would close it.
Publishing a ratio derived from a state file would have been the *"suppressed=1 beside a watch that
woke anyway"* failure in a different costume.
([quince#242](https://github.com/novkostya/quince/issues/242))
