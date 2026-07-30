# 2026-07-27 — A suite written to prove `preflight` refuses things was itself reading the box it ran on — and mutation testing, used three times that evening to earn confidence, could not have…

**A suite written to prove `preflight` refuses things was itself reading the box it ran
on — and mutation testing, used three times that evening to earn confidence, could not have seen
it.** [quince#32](https://github.com/novkostya/quince/issues/32)'s residue, landed as
[quince#76](https://github.com/novkostya/quince/pull/76) (`26194a9`). Two halves: `name="${RC_SVCNAME:-quince-runner}"`,
because one file is installed as **both** `/etc/init.d/quince-runner` and `/etc/init.d/quince-arch`
and a literal name meant `rc-service quince-arch status` answered about a differently-named service
— on a two-box design whose whole point is that the boxes are not interchangeable; and `make
preflight-test`, invoked by `gates-sh`, so the runner spec's **G1** — *"`preflight` against a table
of environments"* — stops being proven by whoever remembers. That is the **third** honour-system
gate closed in one evening, after [quince#41](https://github.com/novkostya/quince/issues/41) and
[#64](https://github.com/novkostya/quince/issues/64); the ladder now runs 27 + 28 + 17 cases that
a day earlier ran on nobody's authority but their author's. The suite asserts the **refusals**,
deliberately: preflight exists to stop a runner coming up unable to do Remote Control, billing
against an API key, or holding the identity of the box it is meant to be separate from, so its
failure paths are its product — and each case asserts the **message** as well as the exit code,
since preflight returns `1` for every refusal and the code alone cannot tell *you set an API key*
from *this box holds the wrong identity*. **The defect the review found was in the harness, not the
code under test.** `env FOO=1 cmd` **adds** to the caller's environment rather than replacing it,
so the one case asserting a variable was *absent* did so by omitting it — asserting a property of
the shell running the suite. The implementer's reported `13 passed, 0 failed` was true only because
that box happened to have `QUINCE_RUNNER_ROLE` unset; the architect box exports it, and there the
suite went red immediately. Worse than a red suite: with `ANTHROPIC_API_KEY` exported four cases
failed, and **that is the variable this gate exists to refuse**, so anyone working with Claude would
have had `make gates` fail on their shell rather than on their change. **A claim the *test* could
not support** — the same shape the evening had been removing, arriving one layer out. Fixed by
unsetting every variable `preflight` reads; the review's suggested list held **four** and the
correct number is **six**, the two omissions both being credentials, established by building the
suggested list and running it rather than by reading it (either missing credential still failed
three cases). Four new cases now pin the isolation itself, and a later tidy collapsed two copies of
the unset list into one `$PF_UNSET`, because the comment said *"must be added here"* while there
were two heres and the isolation suite could not have caught the divergence. **The durable lesson,
and the reason this entry exists rather than a PR thread:** *mutation testing proves a suite reacts
to changes in the **code under test**, and says nothing about what the suite reads from **outside**
it* — ambient environment, filesystem state, clock, network. It is blind to that class **by
construction**, since every mutant runs in the same context as the baseline. Three of four mutation
runs that evening were sound; the fourth was measuring a shell. A sibling failure the same night:
two mutants reported "no failure" because busybox `sed` does not read `\t` as a tab, so the
mutation never applied — **a mutant that silently fails to mutate is a green light nobody earned**,
and a mutation must now be verified to have changed the file before its result is believed.
**quince#32 stays OPEN on purpose.** This is its code half, not its proof: the check the issue
actually asks for — start the service on an arch box from a clean `conf.d` and assert it comes up —
cannot be run from a session hosted by the service `provision` restarts, and `devct` is not
onboarded on the runner, so there is no throwaway CT either. That, plus both boxes still running an
installed file older than `main`, is owed to the Operator's re-provision window and was declared on
the PR so the merge could not imply otherwise.
([quince#76](https://github.com/novkostya/quince/pull/76),
[#32](https://github.com/novkostya/quince/issues/32))
