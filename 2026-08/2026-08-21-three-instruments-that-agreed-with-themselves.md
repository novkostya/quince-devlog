# 2026-08-21 — An overnight triage run, and three instruments that agreed with themselves

**Five small PRs landed and a sixth is green and unreviewed. The through-line is not any of them:
three separate times tonight a check reported clean about a thing it was not measuring, and each was
caught by asking the question somewhere other than where it was convenient to ask it.**

Operator instruction: work independently overnight, take clear and actionable issues, close what is
done, close what is not actionable at all, stay away from `qn.8` and `qn.13`.

## What landed

| | | |
| --- | --- | --- |
| quince#1359 | `forge-watch status` asks `owed_role`'s `none` sentinel, not a roster | quince#1312 |
| quince#1360 | note the head oid IN FULL, in `/review-pr` §6 and `/architect` §5 | quince#1093 |
| quince#1362 | `grep` on a session box is ugrep; a committed claim named BusyBox | quince#1338 |
| quince#1358 | the `PairingWritable` stub outlived its interface method | quince#1346 |
| quince#1356 | `gate-scope --list` speaks the whole gate vocabulary | quince#1351 |
| quince#1367 | `docs-link-check` — **open, green, unreviewed** | quince#1313 |

## The three instruments

**One — my own PR body.** quince#1356's first push carried an SC3045 that `gates-sh` had already
caught. I fixed it, re-ran the gate, read `clean`, and pushed — **the second run had measured the
working tree and the push carried the commit.** The privacy sweep quoted in that body is honest and
could not have caught it either: it reads the committed diff. CI went red, correctly, on a claim I
had verified against the wrong object.

**Two — the link gate's own suite.** `bin/docs-link-check` first asked `[ -e path ]`. A file present
only in somebody's working copy would have satisfied a link for them and 404'd for everyone who
clones — **greenest exactly on the machine where the mistake was made.** Caught by an assertion I
wrote for the purpose; the tool now reads `git ls-files`.

**Three — that suite in the container.** It passed 21/21 on this box and **died in `alpine:3.24`**,
where `rm -rf` on a fixture's `.git` answered `Directory not empty`. `set -e` took the non-zero and
the suite stopped after its 18th assertion — reported as a failure **with no failing assertion in the
output**, because the tally never printed. Found only because quince#1356 merged and I re-ran the
ladder at the rebased head to check the interaction, rather than reasoning that the Makefile diff was
clean. It was clean. The failure was elsewhere.

**That third one is this PR's own subject arriving in its own harness.** The branch's other half is
quince#1338's lesson — *prove it where it runs, not where you type it* — applied to the matcher, using
`awk match()/substr()` because `grep` here is ugrep and neither implementation the gate runs under. I
then quoted a host-only suite run as evidence in the body.

## The measurement that unblocked a stuck issue

quince#1263 was parked on a fork its author could not settle: a ledger-plumbing change to the
credential wrapper every seat calls, or a one-line baseline fix. Their comment named the deciding
experiment and said it had not been run.

Ran it. Filed an issue, ticked, armed — and got the **opposite** result: `highwater` was **1355**, the
issue just filed, so the tick baselined it and nothing woke. Reading the code, the repo-wide issue
scan is unconditional and both `step()` write sites advance the highwater **outside** the `$decl`
guard. There is no off-by-one to find.

The difference from the original run is that this seat declared its runner **before any state read**.
And the failure mode that produces their symptom leaves an artefact, which is on this box:

```
/root/.local/state/quince/forge-watch/novkostya-quince.state.json    ← no runner component
{"highwater":1100,"prs":20,"observed":true}                          2026-08-17
```

A fully-observed state file at the **undeclared** path — quince#241. That points the fix at ordering
rather than at either branch of the fork. **It is not a diagnosis of their instance**: that artefact
is on the implementer box and theirs was the architect one. One `stat` there settles it.

## Triage

Closed with evidence: quince#1093, quince#1346, quince#1351, quince#1312, quince#1318 and
quince#1339 (duplicate filings, consolidated so an architect ruling was not stranded on a closed
issue), and quince-devlog#250. Filed quince#1355, split out of a comment where a live breakage was
buried under an unrelated accumulation problem.

**quince-devlog#250 asked for an audit its author did not run** — *"a list that has gone stale once is
a list nobody has audited"* — so it got one. All four remaining live risks check out. One trap worth
keeping: `grep -rn stalled` over `core/internal` returns 10 non-test hits and **every one is the
substring in "installed"**. `grep -rnw` answers it. A one-word check that looks like it found the
feature is worse than finding nothing.

**quince-devlog#19 was narrowed rather than closed, against the standing instruction to close what is
not actionable.** Its own check now returns 2 hits from 50 — but five of its six instances were not
fixed, they were **rotated onto the journal branch**, where `decisions/0006` forbids rewriting. So the
fix as filed is prohibited, not done. What remains is one decidable act: append an annotation to two
2026-07 entries, which `decisions/0006` permits. Against it — this branch has no PR and no reviewer,
and the trade is an unreviewed edit to the evidence record to improve link rendering in a year-old
entry. Left for the Operator.

Its own prediction landed: it warned that `#19` in a journal entry *"will become a wrong link
retroactively when an unrelated number gets minted."* quince-devlog#19 is that number.

## What the forge cost

quince#1356 needed **three hand rebases** before it merged, each invalidated by a different PR landing
inside its CI cycle: `strict: true` puts every open PR `BEHIND` on every merge, auto-merge does not
rebase, and `image`/`e2e` take about six minutes. With three runners active, merges arrived faster
than a CI cycle, so each rescue was stale before its own checks finished. **The arm reads healthy
throughout** — `autoMergeRequest.enabledBy` was the App at every check — which is what makes it
silent. Measured onto quince#1325.

Every rebase was verified a pure replay by byte-comparing the files at the new head, not by reading a
range-diff summary.

## Not established

- **quince#1367 is unreviewed.** Green on `gates`, `image` and `e2e`; no verdict. The review seat went
  quiet at `22:44Z` and seven PRs were open behind it at `00:35Z`.
- **`Fixes quince#N` closed nothing, four times.** Repo-shorthand does not bind — confirmed against
  `closingIssuesReferences`, which came back empty. Every issue above was closed by hand. Recorded on
  quince#1301, which had that as its open question.
- **No hardware, no UI, no API surface** was touched tonight.

---

## Annotation, 2026-08-21 ~02:00Z — the open PR landed

**`Not established` above says quince#1367 is unreviewed and the review seat went quiet at
`22:44Z`. Both were true when written and neither is true now.** Annotated rather than corrected in
place, per `decisions/0006`: a citation is only worth something if the text it points at is the text
that was there.

The Operator resumed at `01:30Z` and the queue drained — quince#1363, #1365, #1366, #1369 and #1370
all took verdicts inside twenty minutes, two of them `CHANGES_REQUESTED`. **quince#1367 was approved
at `b6e4459` and merged `01:55Z`**, so all six PRs from this run are in. quince#1313 is closed by
hand.

**The stall was a gap between seats, not a defect**, and the entry above reads more darkly than it
should. What survives unchanged is the quince#1325 measurement: three hand rebases on one approved
PR, each invalidated inside its own CI cycle. That happened while the queue was *moving*, not while
it was stopped.

**One thing the approval adds that the entry could not.** The reviewer recorded that they **ran
nothing** — not the gate, not its suite, not `gates-sh` — and did not read `bin/docs-link-check-test`,
so *"whether the suite can fail is unverified by me — the property this project has spent the night
learning to check."* The controls in the PR body are the author's own. That is the honest state of
the evidence for quince#1367 and it belongs beside the three instruments above rather than in a
merged PR's thread.
