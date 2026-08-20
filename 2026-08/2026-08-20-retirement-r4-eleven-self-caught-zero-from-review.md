# 2026-08-20 — Retirement record, runner `r4` — eleven self-caught, three gate-caught, zero from review

**The number this session exists to report is the last one: the reviewer went looking for a gap, said
so explicitly, and did not find one. Every correction on the record is one this session or a gate
made.** That is either a clean unit of work or a shallow read, and the evidence points at the first.

## The work

quince#615 and quince#725, both closed. quince#1323 merged (`05e6aac`) — the version is derived at
build time rather than defaulted, so everything built is correctly attributed. quince#725 needed no
code: it had been fixed an hour after its direction landed and said `Refs`, which closes nothing.

Confirmed live by the Operator, which is the only reason quince#615 could close honestly:
`0.1.0-alpha.2-97-gec412f9` on the public demo, against `0.0.0-dev` before.

## §3 — the ephemeral state

Both watches read `dead` / `no_process` and **were stopped deliberately**; `stop --all` found both pids
already gone, so **no orphan was left**. `status` cannot distinguish deliberate from crashed, which is
why this paragraph exists.

```
novkostya/quince          83 arm(s), 60 wake(s), 0 idle bound(s), 0 failing exit(s), 6 prevented
novkostya/quince-devlog   17 arm(s), 11 wake(s), 0 idle bound(s), 0 failing exit(s), 0 prevented
```

**Zero idle bounds across 83 arms.** Every single arm ended on an event; the loop never once reached
`--max-wait`. So this session offers *no* silence-proves-the-loop evidence — the opposite of what
retirements usually report, and worth knowing before anyone cites idle counts as the health signal.

**The declared set is `#615,#1325` and is stale in both directions.** `#615` is now CLOSED; filed
since and undeclared: `#1329`, `#1330`, `#1335`, `#1338`, `#1339`. **Re-declare from the open issues
rather than adopting it.**

**The devlog watch state is from 2026-07-30 — 21 days stale, inherited, never armed by this session.**

**A gap of ~3.8 hours (13:24Z→17:15Z) had no watch armed, correctly**: `owed --author @me` returned
nothing owed, because no `r4/` PR was open. Whether anything was missed in it is **not provable** —
a PR opened and closed inside the window leaves no trace in a diff of current state.

## §4 — what could not be recorded

**1. The correction rate, which is the only number that says whether two-seat review is working.**
The instances are on the PRs; the rate is nowhere.

| caught by | count | examples |
| --- | --- | --- |
| this session, before posting | ~11 | a `grep` claim that returned 1 not 0; quoting another seat's "anonymous pull → 200" when my own returned 401; writing `deploy: not applicable` for a change that *was* runnable; two bad splices into a workflow; reading `tail`'s exit code instead of the gate's |
| a gate | 3 | shellcheck (backticks in an unquoted heredoc), `allowlist-coverage`, `demo-block-check`'s mirrored copy |
| the reviewer | **0** | — |

The reviewer *did* read: they recorded checking whether `version-test`'s third diagnostic was untested,
found it covered at `:141`, and said so **specifically so a later reader would not re-file it**. A
recorded non-finding is worth more than a silent approval and the forge has no field for it.

**2. A near-miss that cost nothing and would have cost a lot.** `git add -A && git stash -q &&
DERIVED=$(deploy/version) && git stash pop -q` — the stash removed the script, the substitution
failed, and `&&` short-circuited **before the pop**. `git status` then printed nothing and the branch
looked empty. Nothing was lost. But the `make image` run immediately after built the *pre-change*
tree and **exited 0**, which is a green build proving nothing about the change it was supposed to
test. No tool would have caught that; the only thing that did was reading `git stash list` instead of
believing `git status`.

**3. Judgement no tool asked for.** Verifying a *cited* measurement rather than repeating it — the
orphaned commit's BusyBox claim, which turned out inverted (quince#1338). Running the previous
demo-deploy run as a **negative control** (12 vs 14 build-arg tokens) when one reading would have
been accepted. Checking that the `#725` fix already existed rather than building it. None of these
was requested and none leaves a trace of having been exercised.

**4. Two structural findings, both filed, both found by doing the procedure rather than by looking.**
quince#1338 — `grep` on a session box is **ugrep**, so portability measurements taken there represent
neither the BusyBox gate container nor GNU CI. quince#1339 — `scratch-reap` can never reap a devlog
journal clone, because its commits are never in `main` by design.

## §7 — the reap

`1 reaped, 2 kept, 0 unjudged, 66 not clones`. Root **reduced** 211.3M → 12.0M, **not cleared** —
the devlog clone is correctly kept, which is quince#1339.

## What is outstanding, and who owns it

**Nothing requires anything this session knows and has not written down.** No `r4/` PR is open, on
either repository; the boundary was asserted three times, before, during and after the flush.

Open and owned by others: quince#1325 (armed auto-merge on a `BEHIND` branch — it bit quince#1323
twice while landing, costing four CI ladders for one byte-identical commit), quince#1338 and
quince#1339 (filed here, unowned). quince#1275 was **declined by the Operator** on cost, and the
reasoning is on the issue so it is not re-proposed.

One stray branch, deliberately not deleted: `r4/closing-keyword-clause`, orphaned 2026-07-30 by an
earlier holder of this prefix, superseded and safe to remove. Not this session's to delete, and
quince#1338 records what was in it.

— implementer seat `r4`, retirement
