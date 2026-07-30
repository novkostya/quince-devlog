# 2026-07-26 — The CI flake was the product lying about a failed backup, and reproducing it before fixing it is the only reason anyone knows that

**The CI flake was the product lying about a failed backup, and reproducing it before
fixing it is the only reason anyone knows that.**
[quince#57](https://github.com/novkostya/quince/issues/57) reported
`TestFailedBackupReportsTheDeviceReason` hitting the 2-minute `waitCeiling` on a docs-only PR, and
offered two candidate mechanisms to choose between. It is neither. Under load — 16 CPU busy-loops,
4 concurrent copies of the test binary, `-race`, on a 4-vCPU container host — it reproduced **4/4**,
and three narrowing observations killed the guesswork: during the hang there is **no fake child
process** and the engine's pipe fds are already closed; a SIGQUIT dump shows **no `Engine.run`
goroutine at all**, only the test polling `store.GetJob`; and an `UpdateJob` write trace catches the
terminal write succeeding (`rows=1`, `err=nil`) and then a stale `backing_up` write — which
**entered 22 ms earlier and completed 1.3 ms later** — overwriting it. `Engine.progress` and
`Engine.transition` copy the row under `lj.mu` but **persist outside it**, into a blind full-row
`UPDATE` on a `SetMaxOpenConns(1)` store, so writes serialize in connection-acquisition order
rather than mutation order; nothing joins the sampler goroutine, which `runToolLoop` only asks to
stop. A failed backup then reports `backing_up` **permanently**, in the DB and on the event stream.
Filed as [quince#59](https://github.com/novkostya/quince/issues/59) and **not fixed** — it is
product code, the product is frozen, and there is no honest test-only alternative: every
test-side workaround (poll the in-memory row, watch the bus, relax the assertion) works by making
the test blind to a real durability bug. **quince#37's disputed assertion — "reaching the ceiling
is always a bug, never load" — turns out to be exactly right**, and the grace-phase composition it
was blamed for was never at fault; it only removed the *other* bound, which is why this surfaced
here. A published blast-radius claim was **corrected in place after checking it**: `succeed` is
buffered by the whole of verify+commit, so the damage concentrates on the failure/cancel/timeout
terminals — the backup that fails is the one that lies about it.
**Landed** ([quince#61](https://github.com/novkostya/quince/pull/61)) is the issue's separable
second defect, test-only: a wait now names *which* bound ended it instead of reporting "no progress
for 0s" while failing for a stall, and `describe` carries `engine_owns`, the one field that
separates a stuck run goroutine from one that finished and left a row disagreeing with it — quince#59's
fingerprint, previously obtainable only with a SIGQUIT dump. **The review is why it is worth
anything:** the first version tested the message as a pure *formatter*, with the mechanism string
handed in as a literal, while the code that *decides* which string reaches it was hand-threaded
through two near-identical loops and guarded by nothing — undeclared debt, and therefore a finding.
Discharged by deleting the duplication rather than declaring it: one `waitTracker` owns both bounds
and the mechanism, and `awaitTerminal` takes the ceiling as a **parameter** (not the reviewer's
suggested package `var`, which would be process-global mutable state in a file whose tests share a
process — a correction the architect adopted), so a test drives the real loop to the ceiling in
200 ms instead of two minutes. The reviewer's exact mutation now fails with exactly the text they
predicted **while the formatter test still passes**, which is the finding made executable. 320 runs
under the quince#57-reproducing load: zero failures.
**Found on the way and filed, not folded in:**
[quince#60](https://github.com/novkostya/quince/issues/60) — a cancel arriving during process
startup terminates the job `failed` with Go's `context canceled` as the *user-facing* message,
because `supervise` returns the start error without consulting `killReason` the way `runToolLoop`
does; reproduced **18× on clean `main`**, so it predates this work.
**Process:** [devlog#22](https://github.com/novkostya/quince-devlog/issues/22) — `/kickoff` §1's
`issue view --comments` prints *nothing* and exits 0 on an issue with no comments, because
`--comments` replaces the body rather than appending; a silent success that is indistinguishable
from having read everything, warning about exactly the mistake it causes. And
[devlog#23](https://github.com/novkostya/quince-devlog/issues/23) — `gh pr edit` is unusable for
`quince-bot` (it resolves org-scoped reviewer fields even for a body-only edit); `gh api -X PATCH`
needs only `repo`, and the narrow token scope is the point, not the bug.
**[quince#44](https://github.com/novkostya/quince/issues/44) bit twice in one PR, on both boxes** —
neither the implementer nor the architect can run `make privacy-check`, so the box stayed unticked
and the supervisor swept from the host holding the pattern list, twice, the first claim expiring
when the review fix moved the head.
