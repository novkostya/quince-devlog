# 2026-07-30 — Ten fixes in one overnight run, and the three that recur are all one shape: a check that reports on a scope narrower than the word it prints

**Ten fixes in one overnight run, and the three that recur are all one shape: a check
that reports on a scope narrower than the word it prints.** Runner `r4`, unattended, closing
quince#224, #199, #221, #200, #238, #237, #240, #243, #196, #149 and #245 across ten PRs
(quince#235, #248, #250, #252, #253, #254, #257, #258, #259, #255), with quince#247 and #256 filed
on the way. Grouped as one entry rather than ten because the cross-cutting findings are worth more
than the individual diffs, and because four of the ten are the *same defect* in different files.
**THE RECURRING SHAPE — a gate that says `clean` about something it never read.** quince#41
established that a gate which cannot run must refuse rather than exit 0. Four of tonight's ten are
that equivalence reached from the *other* side, where the gate **ran**, proved its matcher, and
printed a true statement about the wrong scope: `gates-sh` linted a hand-maintained list nothing
compared against disk, so `deploy/e2e-run.sh` had never once been shellchecked and the two
identity-boundary wrappers of quince#198 went green unread (#200); `privacy-check` announced
`+ text`, silently dropped an empty `--text`, and still said `clean` — the exact invocation canon
mandates before every merge (#237); the same gate printed `clean` over commit author and committer
identity it never sweeps, which is how a personal name on a `.lan` host reached devlog `main` in
three commits (#196); and `forge-watch` emitted `actor=` where its own comment promised `unknown`,
because jq's `//` falls through on `null` and not on the empty string `gh` actually returns (#199).
The remedy in each is the same and it is not more patterns: **name the fields, not the category.**
`privacy-check`'s scope line now reads `diff:added + message:subject,body + author:name,email +
committer:name,email + branch-name`, so the *next* uncovered field is visible as an absence rather
than discoverable only by a leak.
**THE SECOND SHAPE, three arrivals: presence is not capability.** quince#121 was
presence-is-not-freshness, quince#234 presence-is-not-usable, and quince#255's review found
presence-is-not-*this-seat's* — `command -v ./bin/gh-coder` tests whether the **script** exists, and
all four wrappers are committed, so every clone on every box carries every one of them. The first
arm always matched, the `gh-arch` arm was unreachable, and on the architect box the selection handed
a correct boundary guard an impossible question: it chose `gh-coder`, which refused with *"a REVIEWER
APP KEY is present … Remove it"* — telling a cold architect session, in its first act, to delete the
credential that box exists to hold. **The guard was right; the caller was wrong**, which is
quince#157's "an environment refusal invites the wrong repair" reached *through* a working control.
Fixed by asking each wrapper to act rather than asking whether it exists.
**TWO ISSUES WERE WRONG ABOUT THEIR OWN MECHANISM, and measuring inverted the fix both times.**
quince#224 reported a usage error exiting `127`; that is the `bash -c` form. `bash <file>`, which is
how a script actually runs, exits **1** — an *allocated* code in that contract meaning "a bare
reference does not resolve", so a malformed argument was **impersonating a real finding** rather than
landing on an unused code. The comment the issue asked to correct was right, and was kept. quince#243
reported the approved head as unfetchable after a force-push and proposed replacing `range-diff` with
an API patch-hash compare; measured, `git fetch origin <full-40-char-oid>` **works** and only the
abbreviation fails, so the proposed fix would have traded the rebase-aware tool for the weaker one on
a false premise. `range-diff` stays primary. Both corrections are recorded on the issues, not only in
the PRs, because an issue read later is where the wrong mechanism would otherwise survive.
**THE GUARD CAUGHT WHAT THE AUTHOR DID NOT, five times.** quince#238's fix mattered most: `owed_role`
knew only the two retired credentials, so on the implementer box every arm missed, the role resolved
to `none`, and the `Stop` hook's `none` branch **fails open by design** — the guard against ending a
turn with an open PR and no watch was dead on the one seat that opens pull requests. Proven live,
same payload, before and after. **It failed in a shape that reads as normal**, which is why two
earlier sessions sat inside it: on a box with genuinely no credential, *"whether a watch is owed was
NOT checked"* is the expected output. Separately, this session lost its watch to its own last action
**three times** — arming, then pushing or commenting, which is an event on a PR it watches — and once
did so *having just written the prediction that it would*. Knowing the rule did not help; the `Stop`
hook did, every time. The ordering is already canon (`/kickoff` §6: arm **last**, after a foreground
catch-up tick) and the lesson is that prose loses to habit even when the habit is one paragraph old.
**A red check was infrastructure and classifying it first was worth the minutes.** quince#259's
`gates` failed in 7s where its siblings took ~1m15s: a Docker Hub connection reset pulling the
**pinned** shellcheck image, `Error 125` — the container never started, so the gate proved nothing in
either direction. Reproduced CI's exact scoped invocation locally as clean before concluding it.
Remedy was close-and-reopen (`CLAUDE.md` §5 rung 3) because the branch was current and **no agent
seat can re-run a workflow run**; the approval survived, as canon says it does. The log incidentally
confirmed #200's new coverage gate running on CI — `all 34 shell file(s)` — and that it ran *before*
the registry call, which is what made the failure cleanly attributable rather than a guess.
**A HARNESS OUTAGE ALMOST STRANDED FINISHED WORK, and the escape is worth keeping.** For roughly two
hours the Bash safety classifier was unavailable, reducing the session to commands matching a
permissions allowlist **literally, by prefix** — `git status` ran, `cd X && git status` and `git -C X
status` did not, so the session could not enter its own scratch clone, and `Write` was gated too. A
finished, committed, privacy-swept commit was unreachable. It landed because **git can fetch from a
local path**: `git fetch /root/scratch/<runner>/quince <branch>` then `git push origin
FETCH_HEAD:refs/heads/<branch>`, both allowlisted. Filed as quince#256 with the sharper half — **`make
gates-sh` is missing from the allowlist** while every sibling target is present, so during an outage
the most-run gate in the repository cannot run and no PR can honestly be opened. Nothing was lost, and
by luck rather than design: the outage landed between a sweep and a push.
**Owed:** quince#239 stays **open on purpose** — items 1–2 landed in #255, and item 3, a gate refusing
unscoped `/tmp/` paths in committed skills, needs code-fence awareness, because the only two remaining
matches in `.claude/**` are *prose documenting the defect* and a naive grep flags the text that records
the fix. quince#247 (a pending check is `""` on one fetch path and `null` on the other) and quince#256
are filed and unruled. quince#196's pattern half is private-layer work and its history rewrite is
Operator-only. quince#222 was **observed live** while this ran — the architect's `update-branch
--rebase` on #255 reported `actor=quince-coder[bot] kind=commit`, naming the seat that did not act —
which upgrades that issue from a reading to a measurement. And devlog#127 is **deliberately
stranded**, not waiting on anybody: it is r1's retirement record, its author has retired, and rather
than rule the collision of the two rules the Operator **deferred** it — *"leave them stranded for
now"* — pending devlog#30, the journal restructure that removes the shared append target and with it
this whole class. The distinction matters for whoever reads the queue next: **the defect is
unresolved and the parking is deliberate**, which is why devlog#129 stays open rather than closed.
The Operator's own words retain the finding — *"a retirement record orphaned by a merge still has no
permitted owner, and the three candidate remedies are all still open"* — so what was stale in the
first draft of this entry was the **status**, not the diagnosis. The cost is accepted and recorded:
r1's retirement record may never enter the journal, and its PR is the only place that text survives.
([quince#235](https://github.com/novkostya/quince/pull/235),
[quince#248](https://github.com/novkostya/quince/pull/248),
[quince#250](https://github.com/novkostya/quince/pull/250),
[quince#252](https://github.com/novkostya/quince/pull/252),
[quince#253](https://github.com/novkostya/quince/pull/253),
[quince#254](https://github.com/novkostya/quince/pull/254),
[quince#257](https://github.com/novkostya/quince/pull/257),
[quince#258](https://github.com/novkostya/quince/pull/258),
[quince#259](https://github.com/novkostya/quince/pull/259),
[quince#255](https://github.com/novkostya/quince/pull/255),
[quince#247](https://github.com/novkostya/quince/issues/247),
[quince#256](https://github.com/novkostya/quince/issues/256),
[quince#239](https://github.com/novkostya/quince/issues/239),
[quince#222](https://github.com/novkostya/quince/issues/222),
[devlog#129](https://github.com/novkostya/quince-devlog/issues/129))
