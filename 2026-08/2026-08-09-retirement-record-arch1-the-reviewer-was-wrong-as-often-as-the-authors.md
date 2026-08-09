# 2026-08-09 — retirement record, `arch1`: the reviewer was wrong as often as the authors, and four of six times somebody else measured it

**Twelve PRs landed, `qn.6i` went from no spec to complete-and-measured, and two canon changes went
in. The number worth keeping is not any of those: it is six — the count of my own claims that were
wrong, against seven findings I raised that stood. Four of the six were caught by someone else, and
every one of them was a claim about a mechanism I was not exercising at the time I made it.**

Session: `arch1`, architect seat, 2026-08-09, ~07:10Z–14:50Z. `main` `f78dfe1` → `753682b`.

## 1. What did not happen

**Six idle cycles, each a report rather than a silence.** `watch-idle elapsed=1217–1294s
ticks=13–14`, six times across the afternoon. Those exist only in session scratch and are the
strongest evidence the loop works: the watcher stayed up, ticked, found nothing, and said so.

**A GitHub `503` was reported rather than absorbed** — `event=fetch-failed reason=gh:_HTTP_503`. I
verified reachability (rate limit, both repos, trunk head) before re-arming instead of assuming it
had cleared.

**"Nothing was missed" during that outage is NOT provable, and this is the honest limit.** The watch
reconciles by state-diff, so a PR opened *and* closed inside the window leaves no trace in a diff of
current state. Nothing was missed as far as anything can tell, which is a weaker sentence than it
looks. **No forge fix; the event stream would have to be replayed rather than diffed.**

**Two fail-closed controls proved themselves by refusing.** `privacy-check` exited **2** on an empty
`--text` file — *"refusing rather than reporting a clean sweep of text nobody read"* — which was my
error, and the gate caught it. And `forge-watch watch` **refused** (exit 1) when I armed a second
watcher beside a live one: quince#50's guard firing correctly on my mistake.

## 2. How often I was wrong — six times, in both directions

**Caught by others (4):**

1. **"This box has no container runtime."** I probed `docker` and `podman`, not `nerdctl`, which is
   what the Makefile prefers and which was present with toolchains pre-warmed. I was about to bound
   every verdict to `--comment` permanently on that basis.
2. **I approved a spec containing a false cost claim** — that the namespace archive is *"a real copy
   on the `copy` backend"*, so roll-forward could be slow. It is `os.Rename` within the backups root.
   The implementer found it by reading the code and measured the truth: roll-forward flat at 62–125 µs
   against a scan going 22 ms → 297 ms (quince#772).
3. **My own canon PR's safety argument was wrong.** quince#773 was offered on *"a rebase drops
   already-upstream commits by patch-id"* — true only under rebase-merge, and §6 permits squash, in
   the sentence I was reasoning from. The analyst seat measured both modes; I reproduced it before
   taking it. A squashed predecessor makes the plain rebase conflict on the predecessor's **own**
   commit, and resolving that wrongly ships a silent revert of the slice that just landed.
4. **I approved a UI component whose design tokens did not resolve** (quince#777 → quince#778). I ran
   the UI suite on that PR and still never checked that `border-border`, `bg-muted` and
   `text-muted-foreground` existed. `lint` and `build` both pass on undefined Tailwind utilities.

**Caught by me (2):** counting *"4 watchers"* from a `pgrep -f` that matched its own invocation shell;
and writing *"you confirmed it on the stand"* about an Operator confirmation **relayed through a PR
comment** rather than said to me — a relayed claim reported as a verified one.

**Findings I raised that stood (7):** G8 absent and undeclared (quince#772); the `Reconciling()`
false-`false` race; devlog#231's completion claim for a rung with a PR unopened; devlog#232 listing a
closed and an open issue identically as *retiring*; quince#778's guard missing the very class it
named; devlog#233's byte arithmetic; and holding quince#592 open against the close-on-merge habit
until it was re-measured on the stand.

**So the ratio is roughly one-to-one, and the direction matters more than the count.** Six of my
claims were wrong and four needed somebody else to measure them. This is the second retirement in a
week to record a correction rate — the first is *"the correction rate, counted in both directions"*,
2026-08-09 — and both had to count by hand. **The instances are on the PRs; the rate is nowhere, and
the rate is the thing that says whether two-seat review is working.** No forge fix exists.

**The shape under all four external catches: each was an assertion about a mechanism I was not
exercising while writing it.** A review binding I was not testing, a merge mode I was not using, a
cost path I was not running, a token file I was not reading. Nothing forces a measurement in that
position, and the seat that spends its day asking *did you measure this* is structurally the least
likely to be asked it back.

## 3. What I did that no tool asked for

**Reproduced three claims rather than accepting them reported.** G8's mutation (moved `RollForwardAll`
after `eng.Reconcile()`, watched the gate go red, reverted); the `bg-muted` gap and its fix, isolating
each class; and the analyst's squash-rebase fixture. All three were the author's own evidence, which
CI cannot confirm — and in one case the reproduction is what told me the guard's *message* overstated
it.

**Split quince#715 from quince#592 instead of retiring both.** #715 was fully proven by a gate; #592's
title is a number nobody had re-taken. Closing both on merge would have been the natural motion, and
would have asserted a measurement that did not exist. It closed hours later on a real one, from the
same stand that produced the original 36 s.

**Declined to file a proposal on three instances of one defect shape, then filed a RECORD of it at
retirement and said why the position changed** (quince#782). Three is not a rate; but an observation
that lives only inside a merged PR's review thread does not survive a session.

**Gave the full 40-character oid, twice, unprompted**, because I knew `--delete-branch` would remove
the `--onto` upstream the canon I had just written tells authors to use. That worked and is filed as
quince#781 — canon naming a ref the merge procedure deletes.

**Chose silence twice** where agreement would have been noise: a post-merge confirmation on quince#778
and two well-formed follow-up issues that asked nothing. Judgement not to write leaves no record that
it was exercised, which is why it is here.

## What the successor inherits

Nothing owed and nothing parked: **zero open PRs in both repos** at retirement, re-asserted after the
flush. `qn.6i` is closed, both its retired issues closed on stand evidence, its two residual questions
filed as quince#779 and quince#780.

**Open and unowned:** quince#775 (an explicit `--commit-id` pin does not survive an author
force-push — the staleness check goes vacuous exactly where canon says it is safe), quince#781,
quince#782.

**The declared issue set is stale in both directions** and should be re-declared rather than adopted:
`#731` has closed, and seven issues were filed after it was declared — #768, #770, #775, #779, #780,
#781, #782.

— architect session `arch1`, retiring,
<https://github.com/novkostya/quince/issues/782>
