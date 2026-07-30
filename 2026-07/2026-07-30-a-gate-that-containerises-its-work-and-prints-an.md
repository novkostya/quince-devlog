# 2026-07-30 — A gate that containerises its work and prints an accounting line reported `clean` over a suite with fifteen failing assertions — and the accounting line was what swallowed the…

**A gate that containerises its work and prints an accounting line reported `clean` over
a suite with fifteen failing assertions — and the accounting line was what swallowed the failure.**
`make gates-sh` exited **0** while `forge-watch-composition-test` failed 15 of 22. A shell `if` block
exits with the status of the **last command it ran**, and the recipe chained the container run and
its summary `echo` with `;` — so the gate reported the echo. **Only the container arm was affected,
and it is the default: the one CI runs.** The `QUINCE_SH_RUN_HERE` arm was correct *by accident*,
because `$(MAKE) …` happens to sit last in it. Scoped to the nineteen suites — `sh-lint-coverage`,
`allowlist-coverage`, `suite-coverage`, shellcheck, the `curl -k` ban and the title-interpolation
check are separate recipe lines and did still fail correctly — **and the window was not empty:
`gate-scope-test` had been failing three assertions on every CI run since the containerisation
landed**, invisible until the exit code was honest. `fatal: detected dubious ownership in repository
at '/src'` — `actions/checkout` marks the *host* path safe and the container sees `/src` under a uid
its root does not own, so it could never reproduce on a box. Two green `main` runs that day were
green over a real failure. The first run with the fix went red immediately and named them
(quince#277). **A gate whose failure mode is silence does not get the benefit of the doubt about
what it was silent about** — so quince#246 broke two things in one commit and the second hid the
first, which is a sharper lesson than two independent bugs. **The irony is the finding.** Three lines above the bug sits quince#246's own comment saying a gate that containerises
*some* of its work and says `clean` cannot be told from one that containerised all of it, citing
**quince#41 — the three-exit-code contract, where `0` must mean clean**. The same change wrote the
comment and broke the exit code the comment is about. **It was found by reading suite output, not by
a gate**: registering a new suite for quince#265 broke the composition test, and the ladder said
`clean`. Every totality gate this project has built answers *"is the list complete"*; not one asks
*"does a failure still reach the exit code"*. The proof drives the **real** recipe with a stubbed
`RUNTIME` that fails only for the suite image — a hermetic mini-Makefile reproducing "the pattern"
would pass forever while the recipe rotted — and against the unfixed recipe it fails exactly the
three bug-detecting assertions while all three controls hold. **This entry went stale between
drafting and review, and that is the record's own failure mode appearing in the record:** the
paragraph above hedged with *"no evidence a suite actually broke unnoticed"* — and the author had
already published the retraction, in another thread, five minutes after opening the journal PR and
before any reviewer read it. The fourth such entry tonight. A journal written at the end of a unit
of work is written at the moment its author knows least about what the work found.
([quince#274](https://github.com/novkostya/quince/issues/274),
[quince#275](https://github.com/novkostya/quince/pull/275),
[quince#277](https://github.com/novkostya/quince/issues/277),
[quince#246](https://github.com/novkostya/quince/issues/246),
[quince#41](https://github.com/novkostya/quince/issues/41))
