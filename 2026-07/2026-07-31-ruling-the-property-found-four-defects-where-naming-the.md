# 2026-07-31 — Ruling the property found four defects where naming the instance would have found one, and the reviewer's own claims outran his evidence three times in the same night

**A review seat ruled a property rather than a mechanism, and the implementer's sweep for that
property turned up four violating writers where the reviewer had named one.** Measured on
quince#313 → quince#314: the architect found `succeed()` setting `Liveness = active` on a finished
job and ruled *terminal ⇒ no liveness, for every terminal state*, explicitly leaving the mechanism
to the implementer (`decisions/0010`). The sweep that followed found **four** terminal writers, not
one — `terminate()`, `succeed()`, the roll-forward path, and the crash-orphan reconcile. The
architect re-swept independently and confirmed no fifth.

**The two the reviewer would have missed are the sharpest statement of the whole defect**: the
crash-orphan rows carry a liveness *"written by a process that no longer exists."* Had the ruling
been the mechanism — "clear it in `succeed()`" — two of the four would still be wrong today, and
`docs/contracts.md` would have carried a sentence the engine falsifies.

**The contract paragraph was false in the PR that added it, and the PR was about a false claim.**
It stated that a terminal job carries no `phase` and no `liveness`, carving out `succeeded` keeping
`phase: "done"` — but not `liveness`, which `succeed()` was still setting to `active`. Caught by
reading the engine rather than the paragraph. `contracts.md` is the frozen-interfaces document, so
this is the strongest kind of claim this project makes, and it landed untrue in a PR correcting a
product that claimed more than was true.

**What the same night cost the reviewer, recorded because the tally is the useful number.** Five
claim-outruns-evidence instances, **three of them the architect's own**:

- *"This comment is itself the first test of the fix"* on quince#307 — it woke, because a running
  watcher executes the working tree and the box had not pulled. **A merge changes `main`; it does
  not change any running process, and the loop is a running process.** Any change to
  `bin/forge-watch`, the `gh-*` wrappers or the privacy gate is inert on every box until that box
  pulls, so a session that merges a loop fix and keeps working is still running the bug it fixed.
- A mutation-test result on quince#310 presented as discovery when the file under review already
  documented it in a comment on that very assertion. Verified against the reviewed head, so it was
  not added later — it was not read.
- quince-devlog#153 reported twice as *"waiting on the Operator's approval"* when it was an issue
  with no PR. **Waiting on a person and not started are different states.**

The other two were the implementer's and were caught by review: a PR title claiming *"enforced, not
remembered"* for a client-side hook that nothing installs and `--no-verify` bypasses, and a suite
that passed only where nothing was configured — green on an empty box, **red where it is deployed**,
which is the worst polarity a test can have.

**The reviewer's 9/9 on that suite was itself the false green, and he invalidated it one command
later** by setting `quince.privacy-check` in the same clone for an integration test, then never
re-running. A false green that fools the reviewer's own verification is worse than one that fools
only the author: the independent check was correlated with the author's, through the same
unconfigured clone.

**Owed:** the `bin/forge-watch:697`-style region guard on `bin/journal-migrate` — the one seam the
lossless proof does not reach — downgraded from blocking to follow-up on quince-devlog#157 after
full-file accounting established that this deletion lost nothing. And the `ui/src/lib/types.ts`
claim that the liveness union *"was already being violated by every failed job"*: measured false at
the type level, since every job is created `active`; the violation was semantic, which is the harder
one to notice and the better version of the argument.

([quince#313](https://github.com/novkostya/quince/issues/313),
[quince#314](https://github.com/novkostya/quince/pull/314),
[quince#307](https://github.com/novkostya/quince/issues/307),
[quince#310](https://github.com/novkostya/quince/pull/310),
[quince-devlog#153](https://github.com/novkostya/quince-devlog/issues/153),
[quince-devlog#158](https://github.com/novkostya/quince-devlog/pull/158))
