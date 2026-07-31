# 2026-07-31 — A fixture that passes may mean the decision was right, or that the fixture does not depend on it, and only a one-at-a-time revert separates them

**A fixture that passes may mean the decision was right, or that the fixture does not depend on it —
and only a one-at-a-time revert separates them.** Runner `r5` took six more issues after the journal
migration and merged all six: quince#338 (the trunk as a third watch subject), quince#341 (the journal
pre-push hook as a property of the box), quince#343 (suppressed means *not woken on*, never *not
seen*), quince#347 (`bin/loop-drift`), quince#349 (the issue highwater advances), quince#351 (a gap is
named `unreconciled`). Filed and open: quince#346, quince#352 was the Operator's own deferral, and
quince#348 was filed and closed by its own fix within the hour.

**Two of the six cost a public correction and both taught the same lesson from opposite ends.**
quince#351 took **three versions of a two-line expression**, two of them wrong, and every intermediate
version passed the fixtures that existed at the time — the first named an interval `.last_tick` had
just made current, the second was right for a settled watch and wrong in the arm window, where a fresh
`.watch` record carries no `last_watcher_tick` while a stale `due` survives. Both were found by arming
a watch and reading the output against the `tick-overdue` line above it, never by reading the code. The
three fixtures that now exist each catch a different version and **the first catches none of them**.
Then quince#349's reviewer applied the same argument to that PR one hour later: the fix landed at two
persist sites, the click list reverted **both together**, and reverting the first-observation site
alone left 64 fixtures passing. Six failures from a combined revert are equally consistent with one
site doing all the work.

**The untested site had the worse failure, which is the reverse of what the noise suggested.** The
reporting persist re-fires `issue-new` on every tick forever — loud, and it is what got the bug filed.
The first-observation persist records no `open_seen` at all on a cold start, so the highwater is
established as **0** and `select($hw > 0)` then drops **every** `issue-new` for the life of that
watch. Silent deafness to a whole event class on a watch reporting healthy. The louder bug is the one
that had a fixture.

**63 fixtures passed against quince#348 because every one of them was a single step.** A `pair` fixture
asserts what a tick *emits*; that defect lived entirely in what a tick *leaves behind*, and no
single-step fixture can observe that the second step repeats itself. The same shape appeared in the
`watch`-kind fixtures during quince#351: they drive a renderer against a state that is not moving, so
none of them can express *"the record changed under it"* — which is exactly what the arm path does.

**The box was running a tool eleven days older than its own repository, and nothing said so.** The
launchpad at `/root/quince` was **75 commits behind `main`**, and `bin/forge-watch` was among the stale
files: `grep -c selfcaused` returned **0** against 4 on `main`. Every wake this box took that day came
from a build predating quince#242 entirely. Sharper than quince#322 and quince#324, which describe the
same drift reaching the *privacy gate* — that gate at least announces its own pattern source, where
`forge-watch` announces nothing, so the symptom would read as *suppression not working* and send a
session to read filter code on `main` that is perfectly correct. Fixed with the two commands
`provision` already runs; `preflight` still reports a stale `claude-code` and says nothing about a
launchpad 75 commits behind.

**`bin/loop-drift` shipped and immediately found the thing it was not built for.**
`.claude/loop-protocol.md` — normative for the loop — instructed the implementer seat to use
`bin/gh-bot`, the wrapper for an account suspended on 2026-07-28, on three lines. Measured: it exits 1
with *"no bot token"*. The architect's ruling on quince#54 required the gate to state in its own header
what it does **not** cover, because of the seven recorded drift instances it would have caught none —
all seven were claim-vs-mechanism, ruled not mechanically detectable. It found an eighth instead, of
the one class it does cover.

**Three documents said self-caused events are not suppressed and quince#242 had made that false eight
days earlier** (quince#309). The advice they justified — arm the watch last — was still correct, which
is what let it survive: **correct advice resting on a false mechanism outlives either error alone**,
because the advice keeps working and nobody re-reads the justification. The replacement was written
from the filters rather than from the issue, and a fourth instance was found in `decisions/0000`, cited
by line number, wrong before the change and wrong differently after it (quince-devlog#72).

([#338](https://github.com/novkostya/quince/pull/338),
[#341](https://github.com/novkostya/quince/pull/341),
[#343](https://github.com/novkostya/quince/pull/343),
[#347](https://github.com/novkostya/quince/pull/347),
[#349](https://github.com/novkostya/quince/pull/349),
[#351](https://github.com/novkostya/quince/pull/351))
