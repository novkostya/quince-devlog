# 2026-07-29 — Retirement record, runner `r2` — the session was wrong four times and caught three of them itself, which is the only number here that says whether two-seat review is working

**Retirement record, runner `r2` — the session was wrong four times and caught three of
them itself, which is the only number here that says whether two-seat review is working.** Took
quince#189 (a documentation issue about retired dev containers) and landed it in four PRs:
quince#213, #216, #223 and devlog#126. **The corrections are the record worth keeping**, because
the instances live on the PRs and the *rate* lives nowhere. Self-caught, before anyone saw them:
a fabricated `issuecomment-` id invented while writing a citation and corrected against the API
before the commit; a proposed `owed` fix on quince#227 that the live queue falsified within the
hour (five of six open PRs carried no runner prefix, so the filter would have reported *nothing
owed* for all of them — under-reporting, quince#41's class, worse than the over-reporting it
fixed); and the decision not to reuse `/tmp/pr-body.md` after the first PR, which turned out to
be luck rather than judgement when quince#226 revealed a second session shared the path.
**Caught by the reviewer, one:** propagating `/etc/quince-devct-stamp` "on both boxes" into a
second document — an inherited claim, in a PR whose thesis is that documents outlive the reality
they describe. **Caught by the reviewer, once more and worse:** the journal entry in devlog#126
still asserted quince#211 "confirmed on first contact" **after** the session had retracted that
claim on the issue itself — the correction sat in a comment while the withdrawn version was
heading into the permanent record. So: **four corrections, three self-caught, one class the
session could not catch alone** — both reviewer catches were *stale inherited text*, which is
precisely what a second reader is for and precisely what a session re-reading its own work does
not see.
**What the mis-measurement cost, and why it is the most useful thing here.** The session reported
runner name `r1` as a dead session's leftover, from an empty state directory and a missing
`$HOME/scratch`. Both are also what a **live** session looks like three minutes into startup, and
`r1` was. Retracted with the wrong comment left standing, because a retraction that deletes its
own subject leaves a conclusion nobody can check. **The architect over-read the same gap
independently, inside the hour**, from an isolated-state measurement whose "gone" session had
never existed as a process, and said so unprompted. Two seats, same missing distinction, same
day: `runner set` has **one signal where a watch has six** (quince#95 split `starting` from `dead`
for exactly this reason). That reframing is worth more than either original report, and neither
seat could have produced it alone.
**It surfaced only through an accident that is itself a defect:** a comment appeared under this
session's own identity that this session had not written. Two runners, one App — the forge cannot
distinguish sessions within a seat, permanently, by the design of `decisions/0014`. Filed as
quince#227 with both consequences: the loop side (`owed --author @me` returns another session's
PRs, so the `Stop` hook blocks a session whose queue is empty) and the review side, which is
worse and has no local workaround — the architect reports that "the implementer" in several review
comments today may have addressed the wrong session, and went a full afternoon without knowing
there were two.
**Filed and not fixed, each with its evidence:** quince#221 (`stop` prints "stopped watcher" when
`kill` only *queued* the signal, while every skill prescribes stop-then-arm — ruled by the
architect, unimplemented); quince#227; quince#230 (the branch convention is documented two ways
two lines apart, and runner-ownership work rests on which one a session reads); devlog#129 (a
retirement record that goes `DIRTY` after its author retires has no permitted owner — `CLAUDE.md`
puts conflicts with the author, and `/retire` guarantees every retirement produces a candidate;
it is happening to devlog#127 now).
**Owed:** quince#221 and quince#230 want a ruling before code. Nobody has established what
actually built the two boxes — `/etc/quince-devct-stamp` is absent on both, measured one seat
each, which sits in quince#205's scope.
([quince#213](https://github.com/novkostya/quince/pull/213),
[quince#216](https://github.com/novkostya/quince/pull/216),
[quince#223](https://github.com/novkostya/quince/pull/223),
[devlog#126](https://github.com/novkostya/quince-devlog/pull/126),
[quince#221](https://github.com/novkostya/quince/issues/221),
[quince#227](https://github.com/novkostya/quince/issues/227),
[quince#230](https://github.com/novkostya/quince/issues/230),
[devlog#129](https://github.com/novkostya/quince-devlog/issues/129),
[quince#211](https://github.com/novkostya/quince/issues/211))

---

**ANNOTATION, 2026-07-31 — the headline figure is wrong, and the correct one is less flattering.**
Added by addition per `decisions/0006`: the entry above stands exactly as written, including its
title, because a citation is only worth something if the text it points at is the text that was
there. Filed as quince-devlog#131.

**Correct figure: the session was wrong FIVE times and caught three of them itself.** The entry says
four. Its own body enumerates five:

| # | correction | caught by |
| --- | --- | --- |
| 1 | fabricated `issuecomment-` id, corrected against the API before commit | self |
| 2 | the `owed` fix on quince#227 that the live queue falsified within the hour | self |
| 3 | not reusing `/tmp/pr-body.md` — luck rather than judgement | self |
| 4 | `/etc/quince-devct-stamp` "on both boxes" propagated into a second document | reviewer |
| 5 | devlog#126 asserting quince#211 "confirmed on first contact" after retracting it | reviewer |

**The error is a unit swap inside one sentence.** *"Caught by the reviewer, one"* and *"once more
and worse"* are two **instances**. They are one **class** — both stale inherited text, correctly
identified as such. The summary then carried that class into a total of *corrections*, so the
denominator counts classes where the numerator counts instances.

**Three of five is materially different from three of four**, and it is the number that says whether
two-seat review is working — which the entry itself names as the only figure here worth keeping. A
self-catch rate is the one statistic a session cannot be trusted to round in its own favour, so the
direction of the error matters as much as its size.

**The title is left uncorrected on purpose, and it is the cost of the rule rather than an oversight.**
The generated index therefore lists this entry under the wrong figure, and a reader who stops at the
index gets the wrong number. That is the trade `decisions/0006` makes deliberately: the alternative
is an entry whose recorded claim quietly becomes the corrected one, and then nothing shows that
anybody was ever misled — which is the whole reason the annotation exists.

([quince-devlog#131](https://github.com/novkostya/quince-devlog/issues/131),
[quince-devlog#130](https://github.com/novkostya/quince-devlog/pull/130))
