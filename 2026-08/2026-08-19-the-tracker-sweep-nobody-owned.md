# 2026-08-19 — The tracker sweep quince-devlog#268 left unowned, and the two mechanisms buried in the records it closed

**27 issues closed, 20 narrowed, and 3 pull requests — two merged. The sweep's real yield was not the
count: it was that eighteen `/retire` item-4 records had been asking for the same three-line mechanism
for three weeks, each of them the only place that asked, and none of them a tracker anybody would
find.**

Operator direction: *"go through open issues on GitHub in both repos and take what you think clear and
actionable. If you see something already done but just not closed — close it. If you see something
that is not actionable at all — close it. Every open issue must be actionable."*

That is the sweep quince-devlog#268 filed and explicitly declined to run — *"the sweep itself is
unowned; whoever takes it should say up front whether it is one pass by one seat or a rule applied
going forward."* **One pass by one seat**, said in every closing comment.

## What closed, and the class that mattered

| | |
| --- | --- |
| **18** devlog `/retire` item-4 records | non-events and rates; most say *"Forge fix: none exists"* in as many words |
| **5** self-declared *"recorded, not proposed"* | quince#782, quince#732, devlog#219, #220, #260 |
| **2** stale-by-time | quince#770 (a named RED trunk run, ten days gone), quince#375 (every slice merged) |
| **2** fixed-and-open | quince#790, quince#1045 — verified in the tree, not from PR titles |

**The retirement records are the interesting class.** A record whose own text says *"forge fix: none
exists"* is the definition of what #268 rules against, and eighteen had accumulated because nothing in
`/retire` says to close one. They stay readable and citable; every URL in canon still resolves.

## The two mechanisms that were buried in them

Reading all eighteen *forge fix* lines before closing any of them is what this sweep was actually for.

**One had been asked for six times.** quince-devlog#121, #132, #173, #198, #204, #253, #287 and #288
each independently wanted `forge-watch` to count its exits by class — *"counting exits by class is
three lines and would make 'how often did nothing happen' answerable for the first time."* None had a
tracker, because **a non-event has no event to file against**. Filed as quince#1265, built as
quince#1266, merged.

**One was a single line in a single record.** quince-devlog#204: `bin/gh-review` refuses a *missing*
`--commit-id` and accepts a malformed one. Still true at `b017762`, three weeks on. Built as
quince#1267, merged.

**Both were invisible for the same reason and it is not neglect.** The forge indexes events; these
were properties of a report nobody re-reads. The record was written, correctly, by a session that then
retired.

## Three things that went wrong, all mine

**The suite caught the defect its own header warns about.** `step()` carries counters forward by an
*explicit key list*, so the new `idle` counter read back as 1 after three idle bounds — the last arm's
bump surviving, the two before it erased. That is quince#103's shape, described in
`forge-watch-counters-test`'s header for `arms`, and I reproduced it in the change that cites it. The
increment is correct in isolation; only its persistence is wrong, which is why review would not have
found it.

**I filed quince#1265 with a false premise.** It said an arm-refusal sits inside `arms − wakes`. It
does not — `watch_preflight` dies before `watch_arm`. I had carried quince-devlog#287's phrasing
instead of checking the dispatcher: a claim about one artifact verified against a second, which is
quince#1148's diagnosis, committed inside the sweep that closes the records diagnosing it. Corrected
on the issue before building on it.

**And quince#1266's body wrote `quince-devlog#121, #132, #173, …`** — first reference qualified, the
rest bare, every one resolving against `quince`. `#173` hit a live issue. `title-refs: SUCCESS` on all
three PRs throughout, which is quince-devlog#223's entire point.

## The finding worth more than the count

`bin/stale-refs-report` — quince#1002's own tool — run against both repositories:

| repo | candidates | real |
| --- | --- | --- |
| `quince` | 17 | **17** |
| `quince-devlog` | 10 | **0** |

Every devlog candidate is a bare cross-repo reference. Eight are attributed to devlog#137, merged
`2026-07-30`, "referencing" issues created **two weeks later** — its body carries 28 bare `#N` meant as
quince numbers, and uses both forms within itself.

**The false-positive rate grows without anybody doing anything.** A bare `#245` written in the devlog
was harmless in July because devlog#245 did not exist; it became a false reference the day that issue
was filed. The devlog is at #288 and quince at #1268, so every historic bare quince reference below 288
in a devlog body is already colliding or will. Measured onto quince-devlog#223.

**And the tool works, which is the other half.** It found two issues sitting fixed-and-open — one for a
day, one for eight — with the detector already built and sitting in `bin/`. Nothing invokes it;
quince#1002 stays open on exactly that, which is quince#823's shape one subsystem over.

## What is owed

**quince#1268 is unlanded and waits on the Operator.** Design §6 booked a `BACKUP_PASSWORD` same-uid
exposure quince has never had — zero Go files reference it and the code says *"never an env var"*
twice, unprompted. `docs/quince.design.md` is code-owned, so an architect verdict structurally cannot
clear it.

**The sweep is not finished.** 93 issues remain open in `quince` and 62 in the devlog. Two tractable
classes were worked — self-declared non-actionable, and fixed-but-open — plus everything the stale-refs
report surfaced. The rest were read and left: closing a hard issue is not what #268 licenses.

**And the launchpad at `/root/quince` is 376 commits behind `origin/main`** — clean tree, current
privacy gate, and it is the checkout every session reads `CLAUDE.md` and its skills from. quince#322,
re-measured.
