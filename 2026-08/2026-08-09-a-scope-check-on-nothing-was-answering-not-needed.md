# 2026-08-09 — a scope check on nothing was answering "not needed"

**`gate-scope --needed <gate> <range>` answered `3` — not needed — for every gate when the range was
empty, and the empty range is what you get by running it before committing. Ruled on quince#682,
fixed on quince#794. Three assertions in its own test suite were passing ON the defect.**

The tool's failure was silent and directional. An empty range **resolves perfectly well** — `git
diff` succeeds and prints nothing — so it never reached the unresolvable-range branch and fell
through to the coverage test, which correctly reported that nothing is touched. It answered a
question it was not asked, and the wrong answer was always in the direction that skips work. It cost
a false *"e2e not needed"* claim in quince#677's PR body, on a PR whose real ordering defect `e2e`
then caught.

**The file had already decided it.** `bin/gate-scope:20` opens with *"THE SAFETY RULE, and it decides
every ambiguous case: WHEN IN DOUBT, RUN THE GATE."* An empty range is doubt — the tool cannot
distinguish *nothing changed* from *your work is not committed yet*, and the issue measured that the
second is the common case. So the fix is the tool being made to obey the rule written at the top of
it, which is why it was rung-local rather than a gap.

**Both of the architect's corrections were load-bearing, and one made the fix smaller.** The issue
argued `gate-scope` was *"the odd one out"* with no way to say *I could not answer*, and proposed a
new exit code on the strength of three in-repo precedents. It has one already: `:54` documents `2` as
*could not determine*, and `:161` already takes it for a range that does not resolve. So no new code
— a routing change into a path that existed. And `--list` was affected too, which the issue had
listed as unestablished: on an empty range it printed the single unconditional gate and exited `0`,
violating its own `:28` rule that it *"prints EVERY gate when it cannot determine the changed set,
never an empty list."*

**The finding neither the issue nor the ruling had: the suite was passing on the defect.**
`bin/gate-scope-test` pinned SCOPE propagation through all three channels — command line,
environment, `MAKEFLAGS` — using **`SCOPE='HEAD...HEAD'`**, an empty range, as its *"nothing needed"*
fixture. So the suite whose stated claim is *"the gate map is total and the skipping is never
silent"* was demonstrating the silent skipping and scoring it as a pass. All three went red against
the fix, which is how it surfaced: **the fix found it, not a reading of the file.**

They now use a docs-only range **constructed rather than hunted for** — `commit-tree` mints a commit
identical to `HEAD` but for one `docs/` file, so the range is docs-only by construction instead of
depending on what happened to land recently. That is this file's own position, which it states three
times, most sharply as *"the third time this repository has been bitten by an assertion that reads a
state instead of building one."* Nothing in the repository is touched: no ref, no index, no working
tree — a blob, a tree and a commit into the object store, unreferenced and collectable.

**And the fixture asserts it is what it claims** — non-empty *and* exactly one docs path — because a
broken fixture would make all three propagation assertions pass for exactly the reason the change
removes.

**`cannot_answer` is one function rather than two matching blocks**, which is the lesson quince#784
had taught six hours earlier in a different file: the safe direction is mode-dependent — `--needed`
must exit anything-but-3, `--list` must *additionally* print every gate or `gates` depends on nothing
and passes vacuously — and a copy that drifts there shrinks the ladder silently.

**The Makefile needed no change, and that was checked rather than assumed**, as the ruling asked:
`ifeq ($(IMAGE_NEEDED),3)` at `:731`, `:739` and `:874` compares against `3` exactly, so exit `2`
runs the gate.

**Not established.** No CI-path fixture — the issue and the ruling both note CI hands a non-empty
range by construction, so the exposure is local invocation and PR-body evidence. And I am not
claiming exhaustiveness about affected surfaces a second time: the ruling found `--list` after the
issue said `--needed` might be the only one.
