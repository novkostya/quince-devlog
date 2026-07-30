# 2026-07-26 — The loop's event model was itself the bug — an enumeration is a claim about what can matter, and this one deadlocked two agents on each other for over two hours while both…

**The loop's event model was itself the bug — an enumeration is a claim about what can
matter, and this one deadlocked two agents on each other for over two hours while both watches
reported healthy.** [quince#43](https://github.com/novkostya/quince/issues/43) and
[#16](https://github.com/novkostya/quince-devlog/issues/16), in six PRs. Four blind spots meet on one
transition — *changes requested → fixed → awaiting re-review*: a push is not an event, green checks
were **deliberately** not an event, a comment is not an event, and `reviewDecision` does not move
across a fix. The implementer waited for a re-review, the architect waited for an event, and no event
existed or could exist. **The design note's own reasoning is preserved verbatim next to the fix**,
because it is the transferable part: *"red is what changes who must act"* is true while a PR awaits
its FIRST review and false the moment it awaits a RE-review, and the classifier has no notion of
turns. The fix does not teach it turns — it adds a backstop that does not classify: **any movement of
a PR's `updatedAt` emits `updated`, unconditionally and alongside whatever typed event also fired**,
because a backstop that only fires when the classifier came up empty inherits the blindness it exists
to cover. It names WHO as well as WHEN, attributed only from acts newer than the previous observation,
and says `actor=unattributed` rather than naming a bystander
([quince#48](https://github.com/novkostya/quince/pull/48)).
**A fifth blind spot is not covered by the backstop at all**, and saying so corrected the brief: a PR
made `BEHIND` or `DIRTY` because something **else** merged has had nothing happen *to it*, so its own
`updatedAt` never moves — the architect's own merges silently invalidate every other open PR. That
needed its own typed signal, and review then found the mirror defect in it: `UNKNOWN` was treated as
"no answer" for reporting and then **stored** as though it were a state, so `BEHIND → UNKNOWN →
BEHIND` re-announced a condition that never changed. Pinning it needed a fixture shape that did not
exist — three ticks through one state file — since **a pair whose `before` already holds the
carried-forward value asserts the behaviour it was meant to test.**
**The load-bearing assumption got measured rather than believed.** *A push moves `updatedAt`* is what
carries the green-after-fix transition, and it is unobservable after the fact because a merged PR's
`updatedAt` is pinned to its merge. The first two attempts were confounded by the author commenting
~40 s after pushing — including a watcher armed specifically to measure it independently, which
printed a confident *"updatedAt MOVED with the push"* while its own caveat about checking for a
comment in the window sat on the line below: **corollary (f) committed by the instrument built to
check it.** It is now measured twice, in two repositories, by two methods, by two parties, with the
channel that would have invalidated both — **a body edit moves `updatedAt` and produces no timeline
event at all** — found and closed on both. The silence paid a dividend: three check runs started
during it and `updatedAt` did not move, so the volume argument is an observation, and the commonest
real source of `actor=unattributed` here is **an author ticking a checklist box**.
**Restart safety, and a check that could only pass.** The requirement as first written said *detect a
state file with no watcher and re-arm from it* — and the state lived in the **session scratchpad**,
which the very failure it defends against destroys. It would have reported success by looking in an
empty room. State moved to a session-independent path, and `status` grew from three cases to four:
`live` · `dead` (nothing running — re-arm, do NOT reseed) · `absent` · `wedged` (a process **is**
running and has stopped ticking). The fourth was a review finding against the PR's own stated
principle — `dead` and `wedged` shared an exit code and an identical *"re-arm from this state"* note
while needing opposite remedies, so the duplicate watcher was not an unlucky race but **the designed
path, reached by doing what the tool printed** ([quince#49](https://github.com/novkostya/quince/pull/49)).
Liveness takes two instruments because neither suffices alone: a heartbeat cannot see a watcher that
died a moment ago, a pid cannot see a wedged one — and the first pid check grepped
`/proc/<pid>/cmdline` for `forge-watch` and **reported success for the shell that had just run it**.
**Then the same class produced the only defect that could have hurt something outside the repo.**
`wedged` is *defined* by the heartbeat being stale — and the heartbeat was the only thing tying that
pid to our watcher, so the one state where the tool issued an imperative to signal a process was the
one state where its identity was unproven. Review demonstrated it by writing a foreign pid into the
state: **the tool said "pid 1 IS STILL RUNNING … STOP IT FIRST" — it told the reader to kill init.**
The watcher now records its process start time beside its pid, and `forge-watch stop` re-reads it at
the moment of the signal; every branch that cannot prove the identity refuses and says which. It is a
**verb rather than two steps joined by prose** for this unit's own reason: a session following *"stop
that pid, then re-arm"* literally, on a box where the pid had been recycled, had no defence at all.
And the fix **states its own limit** — verify-then-signal is two syscalls with a gap, the race cannot
be closed from userspace, and what the verb buys is the window shrinking from *however long a session
takes to read a sentence and act* to microseconds behind a refusal
([quince#56](https://github.com/novkostya/quince/pull/56)).
**The watch set stopped being a habit.** *"Both repos, every time"* was right for a day and stale the
moment a third mattered, so it is a versioned file that **hard-fails when missing, empty or
malformed** rather than falling back to one repository — the exact shape of #3. Under `--all` every
event names its repository, because PR numbers collide across repositories by construction. Review
then found what the hard-fail cannot catch: **a stale set fails none of those tests** — it parses, it
is non-empty, and it confidently describes yesterday — measured on a box whose launchpad predated the
file entirely. So pulling the launchpad is part of arming the watch, not housekeeping
([quince#51](https://github.com/novkostya/quince/pull/51), ordering owned by
[quince#33](https://github.com/novkostya/quince/issues/33)).
**The skills were the other half.** `/kickoff` §5 was headed *"Plan, then stop"*; it said "otherwise
start building" in its last line, and the heading is the instruction that landed — three Operator
nudges across two models and two clients, which makes it the skill and not the model. It is now
*"Plan, then proceed"*, with a new §6 for the half that never existed: after opening PRs the session
does not end, and **"I finished a PR" is not a stop**. `/architect` §6 stopped specifying properties
and named the mechanism — a background watcher over `forge-watch tick`, with `ScheduleWakeup` demoted
to a ≥1200 s fallback whose first job on firing is a liveness assertion
([quince#52](https://github.com/novkostya/quince/pull/52), [quince#56](https://github.com/novkostya/quince/pull/56)).
**Canon took three corollaries and a rule** ([#20](https://github.com/novkostya/quince-devlog/pull/20)):
a ruling recorded on the forge is overridden only on the forge, by its owner, and is cited by
**comment URL and self-declared role** rather than by login, since the architect and the Operator are
one identity ([quince#47](https://github.com/novkostya/quince/issues/47)); **(e)** a watcher's event
model is itself a claim about what can matter, so a parked PR is re-examined every tick; **(f)** a
timestamp says WHEN and never WHO; **(g)** *a check whose positive answer can be produced by the act
of asking is not a check*. That PR earned three citation defects of its own before it landed — a quote
no reader could reach, a victim cited as if it were a finding, and an attribution to the wrong role,
all inside the PR installing the rule about citations.
**The tally is the argument, and it is stronger than any single defect: every party to this unit
committed the class it was fixing, inside the instrument or the process they were using to fix it.**
A measurement that named the actor it expected; a pid check that matched the act of asking; a re-arm
check that could only look in an empty room; a reviewer who armed watchers on the two PRs he was
driving and left the parked one unwatched; a queue watcher with an invisible approval; a shell
pipeline read for the wrong command's exit status, **twice, by both parties**; an author who moved a
head out from under a ruling and an approval. That is not carelessness — it is the evidence that this
class is not defended by care, which is the whole thesis.
**Owed, and declared rather than faked:** G2/G3 — a real session killed mid-watch, and the two-box
coroutine end to end — because **both boxes must pull the launchpad and restart before any of this is
live**, and the pull alone flips `bin/forge-watch` while the skills need the restart, so the runbook
must treat those as two moments ([quince#33](https://github.com/novkostya/quince/issues/33)). Nothing
in the unit was argued from either session's own behaviour: both ran the pre-#43 copies throughout.
Filed for later: [quince#50](https://github.com/novkostya/quince/issues/50) (nothing stops two
watchers on one state file; `dead` is a judgement),
[quince#53](https://github.com/novkostya/quince/issues/53) (`/onboard` still enumerates by hand),
[quince#54](https://github.com/novkostya/quince/issues/54) (nothing detects drift between the shared
protocol and the commands inlined in the skills — the named cost of that trade, now tracked),
[quince#55](https://github.com/novkostya/quince/issues/55) (retiring a session flushes to the forge,
not to its successor), [quince#57](https://github.com/novkostya/quince/issues/57) (`waitCeiling`
reached in CI: a job stalled in a grace phase is bounded only by the 2-minute backstop — a
composition defect descended from quince#37, filed by the reviewer who approved it).
*(Corrected 2026-07-26, in the entry immediately below: quince#57 is **not** a composition defect and
quince#37 is not its ancestor — quince#37's grace-phase composition is correct, and its disputed
assertion that reaching the ceiling is always a bug held. The cause is
[quince#59](https://github.com/novkostya/quince/issues/59), a lost update that overwrites the
terminal job row. Annotated rather than rewritten: this entry is citable, and a log that edits
itself breaks the thing citations rest on.)*
