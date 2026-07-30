# 2026-07-27 — A safety argument was checked in the one direction that could not fail — and it was checked *before* being ruled, by the seat that ruled it

**A safety argument was checked in the one direction that could not fail — and it was
checked *before* being ruled, by the seat that ruled it.**
[quince#100](https://github.com/novkostya/quince/issues/100) ruled that a watch is armed **last**,
after a foreground catch-up tick, because self-caused events are deliberately not suppressed
([quince#62](https://github.com/novkostya/quince/issues/62)) and a session's last act is almost
always an event on something it watches — so a watch armed any earlier is dead by design by the end
of the turn. Six `Stop`-hook firings in one session, four of them true positives against a
correctly-behaving session, and none a session neglecting to arm. The entire safety case for
inserting a `tick` into the standard turn shape was one sentence: *a hand-run `tick` does not write
the watcher record, so it cannot make a dead watch look alive.* **True, and the direction that does
not matter.** The mirror was broken and load-bearing: `step()` carried `.issues` forward and not
`.watch`, so a hand tick **erased** the record and a **live** watch read as **dead** — which is what
`watch`'s live-refusal reads, so the guard did not fire and the very next arm, the one the new
ordering prescribes, put a second watcher on one state file. That is
[quince#50](https://github.com/novkostya/quince/issues/50)'s race reached **through** the guard
rather than around it, and the new ordering is what made it the standard path rather than a corner.
Fixed in [quince#104](https://github.com/novkostya/quince/pull/104) (`step()` carries the watcher
record forward, two jq clauses) and the ordering PR rebased on top of it, rewritten so all three
documents assert **both** directions and name the second as the one that was broken
([quince#102](https://github.com/novkostya/quince/pull/102), `15716b5`). **The general rule is the
part worth keeping**, and it went into `loop-protocol.md` rather than into a skill: *a safety
argument that checks one direction of a two-directional property has not been checked.*
**Three things this cost, recorded because none of them was the code.** The one-directional claim
was **verified against the source before the ruling** — the verification was of the safe direction,
so rigor produced a false negative rather than preventing one, which is why `/architect` §6 now
carries the sharper version. The defect was **invisible to all 38 fixtures**, every one of which
asserted `event=` lines only: a defect that emits correct events while corrupting state had no
expressible form, so #104 added `compare_state` and the negative control shows the signature —
events `ok` on both ticks, ten state assertions failing. And the first attempt at that negative
control **passed for the wrong reason** (a `sed` producing invalid jq, so the write never ran and
`.watch` survived trivially), rebuilt before it was trusted and recorded rather than quietly
corrected. **Owed and filed rather than absorbed:** the privacy gate declares on every run that its
matcher is *"proven to COMPILE the lists, not to match anything"*
([quince#108](https://github.com/novkostya/quince/issues/108)) and that no case-sensitive list
exists, which leaves [quince#41](https://github.com/novkostya/quince/issues/41)'s requirement 3
**closed and unmet** ([quince#109](https://github.com/novkostya/quince/issues/109)) — every sweep
declared clean to date rests on an assumption never exercised. A fourth copy of the one-directional
wording survives in `docs/specs/rung-loop/rung-loop.md` story 16, correctly left alone: it is still
true, and what changed is that the tool now guarantees more than the story states. This entry covers
both PRs; neither had one.
([quince#102](https://github.com/novkostya/quince/pull/102),
[#104](https://github.com/novkostya/quince/pull/104),
[#100](https://github.com/novkostya/quince/issues/100),
[#103](https://github.com/novkostya/quince/issues/103),
[#50](https://github.com/novkostya/quince/issues/50))
