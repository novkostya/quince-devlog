# 2026-07-29 — A fail-safe that holds is exactly the condition under which a wrong message survives indefinitely — `owed` called an orphaned watch "the watch class could not be read (10)", and…

**A fail-safe that holds is exactly the condition under which a wrong message survives
indefinitely — `owed` called an orphaned watch "the watch class could not be read (10)", and every
automated signal read correct the whole time.**
[quince#195](https://github.com/novkostya/quince/issues/195) closed. `orphaned` has had its own
exit code since quince#111/#167, and `owed_decide`'s message switch was never extended, so it fell
to the catch-all. The **verdict** was right throughout — everything but `live`/`starting` is owed,
so the `Stop` hook blocked correctly and no session was ever told it was watched when it was not —
and that is precisely why nothing caught it. What a session actually read was a sentence describing
a *failure to determine state*, about a state that had been determined perfectly; the natural
response to it is to go and investigate the tool, when the correct response is one documented
command.
**`orphaned` shares `wedged`'s remedy and not its diagnosis**, which is what the new arm carries:
wedged is running and has stopped ticking, orphaned is running and ticking fine while the session
it would wake is gone. Both must be stopped before arming, because a process is still writing to
the state file either way — so folding `10` into the `5` arm is tempting, and
`owed-an-orphaned-watch-names-its-remedy.json` pairs the two classes in one fixture to refuse it.
**The class was closed rather than the instance, and the previous attempt is the argument for it.**
[quince#183](https://github.com/novkostya/quince/pull/183) landed hours earlier for the identical
shape — a class added, an enumeration not updated — and its fix gated *documents* that enumerate
exit **vocabulary**. `owed_decide` enumerates the same classes as a shell `case` over class
numbers, with no such vocabulary anywhere near it, so it was structurally invisible to the fix
aimed at its own defect class. `forge-watch-exits-test` section 4 now derives `watch_report`'s
returns and asserts each has an explicit arm — a code-to-code totality check beside the existing
code-to-document one.
**Both new gates were measured failing against the unfixed code and passing after** — by the author,
then independently by the reviewer, who mutation-tested the assertion by deleting the arm and got
`16 passed, 1 failed` naming class 10. Declared unproven and accepted on both sides: the guard
asserts an arm **exists**, not that its wording is right; and no genuinely orphaned watch was
driven end to end, because manufacturing one against live watch state risks quince#50's race —
the failure the tool exists to prevent.
**Two process defects were found by hitting them, neither related to the fix.**
`/tmp/pr-body.md` is hard-coded in canon in three places and was already occupied by another
runner's in-flight PR body; the documented sweep was one write from destroying it
([devlog#123](https://github.com/novkostya/quince-devlog/issues/123)). And **runner branch
ownership is inert**: `runner set` tells a session it owns `<name>/…` while `/kickoff` §3 instructs
`<qn.N|pr.N>/<short-title>`, so `wake_filter` cannot attribute the majority of branches and
quince#111 face 3 does not hold for anyone following the skill it was told to run — measured as two
wake-ups on other runners' PRs
([devlog#124](https://github.com/novkostya/quince-devlog/issues/124)). Both are the
shared-mutable-path / contradicting-convention class that `$HOME/scratch/<runner>` already fixed
once, one file over.
([quince#215](https://github.com/novkostya/quince/pull/215),
[quince#195](https://github.com/novkostya/quince/issues/195),
[devlog#123](https://github.com/novkostya/quince-devlog/issues/123),
[devlog#124](https://github.com/novkostya/quince-devlog/issues/124))
