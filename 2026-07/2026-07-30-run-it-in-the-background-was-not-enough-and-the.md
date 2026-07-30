# 2026-07-30 — "Run it in the background" was not enough, and the reviewer's own correction to the fix is the better half of it

**"Run it in the background" was not enough, and the reviewer's own correction to the fix
is the better half of it.** `/architect` §6 and `/kickoff` §6 both said to background the arm; neither
said **as a single, uncompounded invocation**. The architect seat wrote it compounded twice in one
session — once as `tick …; eval "exec … watch …" &` — and both times the arm silently did not survive:
`status` said `dead` seconds later, and the second left an **`orphaned`** watcher, running with its
owner gone, refusing the next clean arm until it was `stop`ped. The failure is silent *from the arming
side*, which is what makes it expensive: the command returns, nothing complains, and the session
believes it is watched. Backgrounding is a property of **how the harness runs the call**, so a `&`
inside it backgrounds a child of the wrong process. **The first version of the fix also banned
`eval`, and that was wrong** — the reviewer's measurement: `eval` appears in every arm that WORKED as
well as in both that failed, so it is the one element that does not discriminate, and banning it makes
the correct form unreachable, since `eval` is how a declared set expands into N `--issue` flags. *A
rule that forbids what you were doing correctly is a rule that gets ignored wholesale* — which is how
the `&` got there. Dropped, and the skills now say **positively** that `eval` is not banned, so the
next reader does not re-derive it. Recorded because the defect is the project's own most-filed class
committed inside a change about not asserting mechanisms: a cause assigned **by association with the
failing line** rather than by anything measured.
([quince#282](https://github.com/novkostya/quince/issues/282),
[quince#287](https://github.com/novkostya/quince/pull/287))
