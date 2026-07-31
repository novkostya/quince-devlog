# 2026-07-31 — Six issues taken after the migration, and every review finding against the session was one shape: a claim scoped wider than what was measured

**Six issues taken after the migration, and every review finding against the session was one shape: a
claim scoped wider than what was measured.** With quince-devlog#152 closed, runner `r5` swept the open
queue in both repositories and took what was actionable without a ruling. Merged: quince#310
(self-caused wake suppression reaches the issue surface), quince#311 (why declaring an issue does not
re-baseline it), quince#312 (bound how long one grace phase absorbs the no-progress window),
quince-devlog#160 (the pre-push hook guards a route, not the branch). Parked approved-and-green:
quince#314. Fixed by annotation: quince-devlog#131.

**What was proven, and the pattern is the point.** Four review findings landed against this session and
all four are the same defect wearing different clothes: a suite that tested the **box** instead of the
tool, because `quince.privacy-check` in the ambient git config made "no gate configured" untestable
exactly where the hook is deployed (quince-devlog#158); gates scoped by **file extension**, so
`gates-sh` was skipped on a two-JSON diff and the fixtures-doc gate — a *shell* suite whose subject is
*data* files — caught it (quince#311); a contract sentence true of **three terminal states out of
four**, falsified by the engine's own success path (quince#314); and a true fact about `bin/gh-arch`
attached to the **wrong case**, produced while correcting somebody else's cost estimate for that same
error (quince#307). None was caught by tooling. A reviewer caught every one.

**Two of the session's own fixes silently narrowed the coverage that would have caught them, and only
mutation found it.** Routing every hook test through a throwaway repo fixed the config dependence and
made the `--show-toplevel` crash untestable — re-introducing the bug then passed nine of nine. Adding
a longer header to `bin/pre-push-journal` outgrew `--help`'s hard-coded `sed -n '2,30p'` window in the
same edit, so the help text began truncating mid-sentence with nothing failing. **A fix that quietly
narrows a suite is indistinguishable from a fix that works**, and the only thing that told them apart
was re-running the mutations *after* the fix rather than before.

**Three findings about the record itself, none of them asked for.** `(j)`, `(n)` and `(o)` were never
minted and `(ag)` was minted twice — so the retired id space canon calls stable is neither dense nor
unique, and has been silently ambiguous for as long as it has existed. **No closing keyword in either
repository has ever bound**: the citation convention is repo-qualified (`quince#N`), GitHub resolves
only `#N`, `GH-N` and `owner/repo#N`, and the convention exists *because* `bin/closing-refs-check`
guards the opposite direction — so the remedy for one failure causes the other. Three issues sat open
tonight with their work merged. And the architect box **cannot `git push` at all** — no credential
helper for any repository — so the seat that rules cannot follow the journal's documented append flow,
and the route it must use is the one the pre-push hook cannot see.

**What is owed.** quince#314 needs an `@novkostya` approval and no agent seat can give it: it touches
`docs/contracts.md`, code owners must be users or teams, and an App cannot be one. quince#202's
prerequisite is discharged — the `--all` multiplier is **zero**, measured — and it waits on a ruling
for the fourth trunk state that measurement found: `quince-devlog` returns `statusCheckRollup: null`,
which is *no answer ever* rather than *no answer yet*, and half the declared set is permanently in it.
quince#307 is reopened for a surface that cannot be attributed. quince#315 and quince#316 are filed
with options and deliberately unchosen. **Nothing mechanical enforces the privacy sweep on the journal
branch's API route**, and closing that needs CI on a repository that deliberately has none — now the
third issue pointing at the same missing thing.

([quince#310](https://github.com/novkostya/quince/pull/310),
[quince#311](https://github.com/novkostya/quince/pull/311),
[quince#312](https://github.com/novkostya/quince/pull/312),
[quince#314](https://github.com/novkostya/quince/pull/314),
[quince-devlog#158](https://github.com/novkostya/quince-devlog/pull/158),
[quince-devlog#160](https://github.com/novkostya/quince-devlog/pull/160),
[quince#202](https://github.com/novkostya/quince/issues/202),
[quince#307](https://github.com/novkostya/quince/issues/307),
[quince#315](https://github.com/novkostya/quince/issues/315),
[quince#316](https://github.com/novkostya/quince/issues/316),
[quince-devlog#159](https://github.com/novkostya/quince-devlog/issues/159))
