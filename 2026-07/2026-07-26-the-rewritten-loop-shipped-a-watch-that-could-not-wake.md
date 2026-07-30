# 2026-07-26 — The rewritten loop shipped a watch that could not wake anybody, and an arming step a session could simply skip — one mechanism defect and one honour-system defect, in the same…

**The rewritten loop shipped a watch that could not wake anybody, and an arming step a
session could simply skip — one mechanism defect and one honour-system defect, in the same hour, on
opposite boxes.** [quince#62](https://github.com/novkostya/quince/issues/62). The architect armed the
loop its own skill printed — `while :; do forge-watch tick --all; sleep 60; done` — and **a session is
woken by a background task COMPLETING**, so a loop with no exit condition detects everything and
delivers nothing. quince#61 opened at `19:07:16Z`; the session's last activity was `18:21:38Z` and a
human ended the stall fifty minutes later. Every instrument was green throughout: fresh heartbeat,
both state files rewritten every 60 s, `status --all` reporting `live`. Corollary (g) inside the
mechanism built to eliminate it — and what it degraded to is the sharp part: **the twenty-minute poll
this rung existed to replace, wearing the new mechanism's clothes.** A first correction claimed the
fallback heartbeat had bounded the stall; the architect's own instruments then disproved that
**three times, and a fourth after the count was published** — `ScheduleWakeup` armed and due at
`18:41`, `19:40`, `20:03` (then `20:31`), session idle each time, invoked none of them — so there was
no floor at all. An hour later the implementer half
produced the complement: checked structurally against its transcript, **no watcher, no state file,
no `ScheduleWakeup` — zero**, ending a turn on *"the ball is back with the reviewer"* four minutes
before its verdict landed. Both stops were named illegitimate **by the skill the session was
following**, the second in a section rewritten to prevent the first. **Landed:**
[quince#63](https://github.com/novkostya/quince/pull/63) makes the loop the tool's own verb —
`forge-watch watch` exits on the first wake-worthy event, treats the baseline (`first-observation`
and the `queue-empty` beside it) and a lone `fetch-failed` as non-waking, prints every tick
regardless (**the filter decides what wakes, never what is seen**), refuses to arm beside a `live` or
`wedged` watch so §4c's four answers are enforced where they are acted on, and carries its own
`--max-wait` floor because termination is now the only thing that wakes anything. Self-caused wakes —
about a third of the architect's — are **not** suppressed, deliberately: a suppression rule would be
a fresh claim about what cannot matter, which is §4b's defect again. **The fixture had to assert
termination, not health**, because every health fixture in the directory passes on the deaf watcher;
its teeth are stated oddly on purpose — against the hand-rolled shape the positive fixture does not
*fail*, it **hangs**, so the harness bounds each loop fixture with `timeout` and says so when
`timeout` is missing. **A defect in that PR was found by arming it for real rather than reading it:**
re-arming from a `dead` watch emits `tick-overdue` *by definition*, so every re-arm woke once for
nothing, reporting as news the gap the arming step had announced one line earlier — the fixtures the
author had just written all passed while it was broken, and the reviewer's own live run had missed it
too (a 35 s gap against a 60 s interval). **Then
[quince#66](https://github.com/novkostya/quince/pull/66)**: a verb that terminates correctly does
nothing for a session that never runs it, so `forge-watch owed` asks whether open PRs here have no
live watch and a **`Stop` hook** runs it when a turn ends — **blocking once** with the exact command,
then, on a second attempt, telling the *human* instead. The two rejected shapes were rejected on
structure: *"opening a PR arms the watch"* **cannot work**, because only a task the session itself
launched can wake it, so a process forked by a `gh` wrapper would be armed, ticking, `live` and deaf —
the same bug one layer down; and *"a channel that needs no arming"* is right and is the **runner
dispatcher already in the spec**, which needs the runner unit and is named rather than built. The
general shape is worth keeping: **a rule that tells a session to do something is satisfied by a
session that does not do it, and nothing observes the difference** — corollary (g) applied to arming
instead of to checking. **What made both PRs trustworthy was running the harness, not reasoning about
it:** the hook was proven by a headless session in a never-trusted workspace that was told *"reply
with the single word PING and do not use any tools"* and **tried to arm a watch instead**; exits 6
and 7 were confirmed to be rendered to a session as *"failed with exit code 6"* when 6 is the
designed heartbeat; and two documented facts turned out wrong under test — the published `Stop` hook
config example omits the nesting the real schema requires (the first probe silently never ran), and
`"hooks": {"Stop": []}` does **not** disable a project hook because hooks merge (`disableAllHooks` is
the switch, and it is all-or-nothing). **Found and filed, not folded in:**
[quince#64](https://github.com/novkostya/quince/issues/64) — `forge-watch replay` is the spec's G1
and is run by **no gate and no CI job**, so every round of this work has proven it by hand and pasted
the output, which is the honour system this repository keeps filing issues about.
