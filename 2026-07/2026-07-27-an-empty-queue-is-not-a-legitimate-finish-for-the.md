# 2026-07-27 — An empty queue is not a legitimate finish for the reviewer, and the tool that said otherwise was faithful to the prose that was wrong

**An empty queue is not a legitimate finish for the reviewer, and the tool that said
otherwise was faithful to the prose that was wrong.**
[quince#71](https://github.com/novkostya/quince/issues/71) closed by
[quince#96](https://github.com/novkostya/quince/pull/96) (`6372c8a`). `/architect` §7 named an
empty queue as a finish, and `owed --all` derived its answer from that — the issue's own title is
*"`owed --all` says yes because §7 does"*, which is why the tool moved with the prose rather than
after it. **The asymmetry is the whole of it:** an implementer's set is what it AUTHORED and cannot
change without it; a reviewer's set is what ARRIVES, so its work is done not when the queue is
empty but when nothing further is coming — **and that is not knowable from inside the session.**
So `owed --all` now returns the whole declared set unconditionally, with no queue query at all;
`owed --author` is untouched. **Measured on both sides before it was ruled:** twice an architect
overrode the gate, armed against its *"nothing owed"*, and a PR arrived within ~15 minutes
(quince#69, quince#73); once an architect **obeyed** it, stopped on an empty queue, and went dark
with the gate silent throughout because by its own definition nothing was owed. Two overrides that
were right and one obedience that was wrong is a gate wrong in one direction only. The two halves
now state different REASONS — `declared` versus `open PRs` — and that is not cosmetic: **a true
verdict with a false justification is harder to catch than either error alone**, because the
verdict looks right so nobody re-reads the reason. Review found exactly that surviving in the
hook's headline, the single most-read sentence the tool emits, and a second copy one line further
on in the escalation that reaches the **Operator** — where a reviewer blocked under this ruling may
have no PR at all. Both are now neutral about *why*, and that is structural rather than a
preference: **the defect existed because the reason lived in two places and only one was updated**,
so switching the headline on mode too would have recreated the condition that produced it. A
consequence worth having: `--all` no longer touches the forge, so the hook's reviewer path cannot
be wedged by an unreachable one. **Its first production firing caught its own reviewer ninety
seconds after it landed** — both queues empty, both watches dead, the state the change was written
for, on its first opportunity. Also caught by running rather than by fixture: the new `owed`
fixtures passed while the runtime wiring threaded the wrong mode, so the live answer still read
*"open PRs"* — quince#62 and quince#65's shape, inside the tool built for it.
([quince#96](https://github.com/novkostya/quince/pull/96),
[#71](https://github.com/novkostya/quince/issues/71),
[#69](https://github.com/novkostya/quince/issues/69),
[#73](https://github.com/novkostya/quince/pull/73))
