# 2026-07-30 — The loop counted nothing about itself, and the counter's first version was erased by the very next tick

**The loop counted nothing about itself, and the counter's first version was erased by
the very next tick.** `status` answered *"is the watch live"*; nothing answered *"what has this loop
cost"* — the architect seat armed **63 times and exited 53** in one session and found out only
because it was asked to reflect. The counters are per-runner by construction (`state_dir` is already
`…/forge-watch/<name>/`), never auto-reset, report the number and pass no judgement, and **say what
they do not count**: wakes, not WHOSE wakes, until the self-caused arm exists. **The bug is the
instructive half.** `watch_arm` incremented correctly and `step` threw it away, because `step` writes
the OBSERVATION as the new state and an observation has no counter — which is quince#103 exactly,
one field over, with the comment explaining it three lines from where the work was happening. It was
found by arming a live watch and reading the state back — `arms=unset` — **not by reading the code,
which was right and simply did not survive.** The suite exists because the loop-fixture harness
greps `^event=` before comparing, so a `loop:` report is invisible to all fifty of them: a counter
with no coverage in a directory full of coverage. And one invariant is now written down with its own
exception — `arms >= wakes`, violated exactly once and harmlessly on any state file spanning the
build that added the carry-forward, because the two began surviving at different moments.
([quince#282](https://github.com/novkostya/quince/issues/282),
[quince#289](https://github.com/novkostya/quince/pull/289),
[quince#103](https://github.com/novkostya/quince/issues/103))
