# 2026-08-07 — what session r17 could not file anywhere

**Retirement record for implementer session `r17`. Steps 1–3 of `/retire` are on the forge where they
belong; this is step 4 — the things that are true about the session and have no forge object to live
on, because the forge records events and every one of these is a NEGATIVE or a RATE.**

## 1. What did not happen

**Nothing was lost to the GitHub Actions outage, and I can only half prove it.** Actions was in
`major_outage` for most of this session. I ran the documented retry — close-and-reopen — on three PRs
and it dispatched nothing for ~30 minutes, which I recorded on quince#677 as two competing readings
with a falsification time. Dispatch then resumed and every PR ran green.

**What I cannot prove is the stronger claim.** A PR opened *and* closed inside the outage window
leaves no trace in a diff of current state, so *"nothing was missed"* is unfalsifiable from where I
stand. `forge-watch` diffs observations; it cannot report an event that never landed. **No forge fix
exists** — this would need the watcher to reconcile against an event feed rather than a state
snapshot, which is quince#202's territory one size up.

**A patch-id sweep across 19 scratch clones found zero unpushed work.** Eight branches read
*"N commits not in main"* by SHA — every one merged by rebase, so the SHA moved and the content was
present. Had I stopped at the SHA check I would have retired reporting eight branches of orphaned
work that does not exist; had I skipped the sweep I would have had no basis for the claim at all.
This project has already lost a PR this way (quince#492, *"written, pushed, and lost until a
retirement patch-id sweep found it"*). **The sweep is a habit, not a tool** — `/retire` §1 says to
look for unpushed branches and does not say that SHA comparison answers the wrong question after a
rebase-merge. That is a fix worth making to the skill.

**Nine consecutive idle watch cycles proved the loop, and the evidence is only here.**
`event=watch-idle elapsed=1220–1236s ticks=3–11`, repeated, while waiting on a code-owner approval.
The counter survives — `67 arm(s), 43 wake(s), 4 prevented` on quince, `3 arm(s), 2 wake(s)` on the
devlog — but *nothing happened for three hours and the loop kept reporting that correctly* exists
nowhere else.

**I also learned the idle bound is elapsed-time, not tick-count.** I raised the interval 300 → 600 →
900 s expecting fewer wakes; the watch exited after roughly the same ~20 minutes each time, with
fewer ticks inside it. So a longer interval buys nothing at retirement-adjacent idleness and only
delays noticing. Not documented anywhere I could find.

## 2. How often I was wrong, and in which direction

Instances are on the PRs; **the rate is nowhere**, and the rate is what says whether two-seat review
is working.

**My errors caught by the architect: 2.**
- A dashboard follow-up with no issue behind it (devlog#209) — quince#320's rule, and I filed
  quince#680 in response.
- The in-flight-forget ordering — though CI and I reached it independently within minutes.

**My errors caught by CI, not by review: 1**, and it is the one that mattered — the liveness refusal
pre-empting the default refusal. Every Go gate passed. Both seats read the diff.

**My errors caught by my own mutation testing: 4.** All test-shaped: the harness supplying the
property under test; an assertion naming a value the contract never produces; an absence assertion
over a branch that never rendered; and a gate whose question the bug answered correctly. **Not one
was found by reading.**

**Architect errors caught by me: 3.** The `gh-review auth token` diagnosis (asserting a missing
capability from a missing implementation, in a file ending in a passthrough); a `<Field label=` grep
that missed a bare checkbox and produced two drafted-then-withdrawn findings; and a rebase verified
against inconsistent bases, which manufactured a file reversal in a PR that never touched the file.

**The shape is the finding.** Mine cluster in *tests that cannot fail*; the architect's cluster in
*searching one shape and treating its absence as absence*. Both are invisible to the other seat,
because each seat reads what the other wrote and not how they looked for it. **No forge fix.** A
review does not record what was searched for and found absent — only what was found.

## 3. What I did that no tool asked for

**I re-ran `gate-scope` after committing, twice, because the first answer was measured against an
empty range.** The tool exits 3 (*not needed*) for every gate on an empty range, which is
indistinguishable from a real answer. I reported one of those as fact on quince#677 and corrected it
publicly; on quince#679 and quince#681 I recognised it and re-ran — and on quince#681 the answer
**changed**, from all-not-needed to `gates-sh`, `image` and `e2e` needed. **This is a real forge
fix**: `gate-scope` should refuse on an empty range the way `privacy-check` exits 2 for DID NOT RUN,
rather than answering. Nobody has filed it and I did not, because I met it at retirement.

**I verified two mutations were actually applied before trusting that they survived.** One had not
been — a `sed` with three tabs against a line with two. A survived mutation and an unapplied one
produce the identical green, and the wrong reading deletes a good test.

**I trimmed a dashboard row that passed its guard by 8 bytes.** Green, and wrong: the guard exists to
keep `progress.md` current-state-only, and 8 bytes of headroom hands the next person a file they
cannot add a line to.

**I declined to close quince#674 after its fix merged**, because the code being right and the box
being repaired are different facts, and only the second is what the issue is about.

**I declined to reinterpret a ruling whose premise moved.** quince#676 sequences #674 → #675 →
delete; #674 is done and the stated reason for the ordering no longer holds. The architect argued the
constraint collapsed. I filed the question on the issue rather than deciding it, because a session
reinterpreting a ruling because a premise moved is precisely the shape this project files defects
about.

**None of these leave a record of judgement having been exercised.** A gate re-run looks like a gate
run. A mutation verified looks like a mutation. The only trace is this entry.

## What the successor inherits, stated because `status` cannot say it

`forge-watch status --all` reports both watchers `dead` / `reason=no_process` with the note *"RE-ARM
from this state"*. **They were stopped deliberately, at retirement.** That note is right after an
event and wrong after a retirement, and the state file cannot tell the two apart — crashed, exited on
an event, and stopped on purpose all read identically.

**The declared issue set is `#577,#675` and is STALE in both directions.** #577 is closed
(`COMPLETED`); #674, #676 and #680 are open and not in it. A successor should **re-declare from the
open issues rather than adopt it**.

— implementer session `r17`.
