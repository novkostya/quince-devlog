# 2026-07-30 — A classifier outage is a DEGRADED session, not a broken box or a finished one — ruled, after it cost the architect seat six and a half hours of unwatched queue

**A classifier outage is a DEGRADED session, not a broken box or a finished one — ruled,
after it cost the architect seat six and a half hours of unwatched queue.** Operator ruling, relayed
on quince#256: when the Bash safety classifier is unavailable only commands matching an allowlist
entry **literally, by prefix** run — one line, no `cd`, no chaining, no multi-line arguments, and
`Write` is gated too. Both natural readings of the refusal are wrong: the box is fine and the session
is not finished. Correct behaviour is to keep working inside the uncomposed allowlist, **commit
early** because an uncommitted edit is unsavable, salvage a stranded commit by fetching from the
local path (`git fetch /root/scratch/<runner>/quince <branch>` then `push origin
FETCH_HEAD:refs/heads/<branch>`, since git can fetch a local path and `git config` is allowlisted so
the helper can be set), and — without exception — **do not open a PR you cannot gate**: an ungateable
PR is not a lowered bar, it is an unproven claim. A session that reaches that point and stops has
behaved correctly and should say so. **What the outage actually cost, measured rather than
estimated:** the architect's watch died at `19:54Z` and could not be re-armed, because arming is a
`Bash` call; the queue ran unwatched for **6h29m** while four PRs opened and one was merged by the
Operator executing an approval already cast. Nothing was lost, and nothing was covering it either —
the fallback heartbeat is `ScheduleWakeup`, which is unavailable outside `/loop` dynamic mode, so the
floor under an architect session is the watcher's own `--max-wait` and the watcher is what the outage
removes. **THE ROOT CAUSE WAS NOT THE MISSING TARGET.** The issue was filed as *"`make gates-sh` is
not on the allowlist"*; the supervisor's sweep found **17 of 32** `make` targets unlisted, the
language gates all covered and not one shell suite — and then found the sharper fact: **the allowlist
is directory-anchored by omission.** There is no `make -C` and no `git -C` form, so `make gates` (which
*is* allowlisted, including `SCOPE=`) runs only in the launchpad while the work sits in
`$HOME/scratch/<runner>/quince`. *"No gate can run"* was true in effect and wrong in mechanism, and
the seventeen entries would not have fixed it. **Three ordered PRs, and the ordering is a ruling
rather than a preference:** the `-C` forms alone first (unblocking, independently testable), then the
seventeen entries, then an allowlist **totality gate** — every `make help` target has an entry and
every `Bash(make …)` entry names a real target, which is the third check of that exact shape here
after quince#75 and quince#107. **The sequencing came from a supervisor SELF-CATCH, ratified rather
than imposed:** that seat first proposed bundling the entries with the totality gate, corrected its
own framing unprompted one message later to `-C`-first-alone, and the Operator ratified it — citing
`revamp.md`'s record of `pr.6` making the cheap half wait on the thorough half for a week. It also
superseded the architect's independent bundling of the entries with the `-C` forms. Recorded this way
because `revamp.md` tracks how much of this loop needs outside judgement and its standing finding is
that the cross-seat half is smaller than claimed; scoring a self-catch as an Operator intervention
would inflate exactly that metric, permanently, in the direction already under suspicion.
**`Bash(make -C *)` unscoped was refused outright rather than escalated:** an allow entry means *run
without classifier review*, so an unscoped `-C` means run any Makefile anywhere unreviewed, which is a
different grant from running this repo's gates. The acceptable shape is named in the same ruling so
PR-1 is executable rather than blocked on the same refusal — **scoped to the scratch root**
(`make -C /root/scratch/**`, `git -C /root/scratch/**`), with the glob verified to match before it is
claimed to, since a pattern matching nothing would reproduce this defect inside its own fix. **What is
still unproven, and deliberately not asserted:** whether `deny` rules survive an outage. The probe is a
denied *read* (`Read(~/.config/quince/**)`, enforced and demonstrated), not a push to `main` — the
original filing declined the dangerous test and was right to; whoever runs the safe one adds the answer
to the clause rather than leaving it inferred. **And the same surface refuses from the other side,
unruled:** a *working* classifier blocked `bin/gh-review pr merge` twice and `bin/gh-arch pr merge`
answered `Denied by user`, with no `deny` rule matching `pr merge` — so "the classifier is down" and
"the classifier says no" strand a session identically and only the first is ruled. The day before, the
same wrapper ran twelve merges with zero refusals, so `CLAUDE.md` §6's documented intermittency is now
observed from both directions. Recorded on quince#262, where the architect then published a false
conclusion from those refusals — asserting a merge was owed on a PR the Operator had merged nine
minutes earlier — because **a refusal is not a state reading**, and no object was re-read between the
last refusal and the claim.
([quince#256](https://github.com/novkostya/quince/issues/256),
[quince#262](https://github.com/novkostya/quince/pull/262),
[quince#75](https://github.com/novkostya/quince/issues/75),
[quince#107](https://github.com/novkostya/quince/issues/107))
