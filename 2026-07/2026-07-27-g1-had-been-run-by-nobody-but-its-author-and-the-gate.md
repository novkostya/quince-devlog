# 2026-07-27 — G1 had been run by nobody but its author, and the gate that fixed that shipped unable to see the suite shrink

**G1 had been run by nobody but its author, and the gate that fixed that shipped
unable to see the suite shrink.** [quince#64](https://github.com/novkostya/quince/issues/64),
landed as [quince#74](https://github.com/novkostya/quince/pull/74) (`250cbd0`).
`bin/forge-watch replay bin/testdata/forge/*.json` is the rung-loop spec's **G1**, and neither
`gates-sh` nor CI ran it: every round of `forge-watch` work proved it by hand and pasted the
output into the PR. Honest exactly as long as somebody keeps doing it, and three of the loop
fixtures spend real seconds in sleeps, which is the kind of cost that quietly stops being paid.
**Now `make forge-watch-test`, invoked by `gates-sh`**, so all 28 fixtures run on every PR —
and the issue's open question (*where do the loop fixtures belong, since they need a subprocess
and a clock and cannot run inside the shellcheck container*) is answered by measurement rather
than preference: **host-side, beside the containerised shellcheck**, 23.4 s locally and 22 s in
CI, the same placement `privacy-check-test` took in [#73](https://github.com/novkostya/quince/pull/73).
**The review found the interesting defect, and it was in the fix rather than the thing being
fixed:** `forge-watch: fixtures pass` is not countable, so a suite that has silently shrunk
passes — the architect removed the ten `watch-*.json` loop fixtures and the remaining eighteen
still printed `pass`, while this same PR was writing *"all 28 fixtures"* into the spec, asserted
by nothing. That is quince#73's third finding one level down (a canary that tested zero probes
printing `canary ok`), and the sharpest part is **which** fixtures demonstrate it: the loop ones,
whose cost the PR's own body had just named as the thing that stops being paid. So the fixtures
likeliest to be dropped were exactly the ones the new gate could not see leave. Fixed by a counter
and a `%d` — `forge-watch: 28 fixtures pass` — and **the fix makes a shrink visible, not fatal**:
18 of 28 still exits 0, stated plainly on the PR so the approval could not be over-read. A
hardcoded floor was considered and **refused**: a second number that must be bumped with every
fixture added drifts stale, and a stale floor reads as protection while permitting the very shrink
it names — this unit's defect class wearing a different hat, installed by the PR closing it. A
second finding retired an overstatement rather than a bug: the `jq` guard had been offered as
*"quince#41's lesson applied"*, but `make` returns its generic recipe-failure code for **any**
failed target, so *did not run* and *ran and failed* are indistinguishable through it — measured
both ways, both `2`. The distinction lives in the message, and the recipe now says so where the
code is rather than only in a PR body. **A third thing was deleted rather than shipped:** a
`[ "$_ran" -gt 0 ]` guard written while fixing the count, then removed on discovering it is
**unreachable** — the dispatcher refuses an empty argument list (exit 1) and a glob matching
nothing arrives as its own literal and dies in jq (exit 2), both measured. A guard that cannot
fire reads as a safety net in review while asserting nothing. **Scope was flagged, not assumed:**
the fix touches `bin/forge-watch`, which the unit's kickoff had fenced off; ruled in scope because
the whole non-comment delta is four lines inside `replay()` — a counter, an increment and a
`printf` format — with no event, classifier, tick or watch path touched, and because the offered
alternative (counting the glob in the Makefile) would have counted *files handed over, not
fixtures executed*. Both merges tonight landed on **`event=mergeability status=CLEAN`** rather
than on anyone noticing, which is [quince#65](https://github.com/novkostya/quince/issues/65)'s fix
earning its keep twice in one evening. G1 was afterwards re-run **from `main`, on a box that did
not build it**, because *"it worked on the branch"* and *"it works from main"* are different
claims and only the second is what the next session inherits.
([quince#74](https://github.com/novkostya/quince/pull/74),
[#64](https://github.com/novkostya/quince/issues/64))
