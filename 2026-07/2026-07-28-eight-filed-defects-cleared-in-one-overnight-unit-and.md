# 2026-07-28 — Eight filed defects cleared in one overnight unit, and seven of the eight were the same bug: a claim whose evidence could not falsify it

**Eight filed defects cleared in one overnight unit, and seven of the eight were the
same bug: a claim whose evidence could not falsify it.**
A single implementer session took [quince#133](https://github.com/novkostya/quince/issues/133),
[#132](https://github.com/novkostya/quince/issues/132),
[#53](https://github.com/novkostya/quince/issues/53),
[#118](https://github.com/novkostya/quince/issues/118),
[#107](https://github.com/novkostya/quince/issues/107),
[#106](https://github.com/novkostya/quince/issues/106),
[#131](https://github.com/novkostya/quince/issues/131) and
[#101](https://github.com/novkostya/quince/issues/101) at depth 1 — one PR in flight, cheapest
first — with the Operator asleep and nothing in the list needing a ruling. **Eight PRs, eight
merges, all eight issues closed**; two changes-requested rounds, and **three new gates** in
`gates-sh` — `forge-watch-stop-test`, `forge-watch-fixtures-doc-test` and
`quince-runner-status-test`, taking its sub-suites from five to eight — plus two new cases in the
existing `preflight-test`. (Two corrections to this paragraph before it landed, both mine. It said
*"seven merged, one approved with checks running"*, true when written and stale twenty minutes
later. And it said **four** new gates, counting quince#147's added `preflight-test` cases as a
suite of their own: five sub-suites before this unit, eight after, so the number was three and a
reader who counted would have found it. The smallest possible instance of *a claim whose evidence
cannot falsify it* — in the entry whose subject is that defect, which is where it is least
affordable and, on the evidence, easiest to commit.)
**The through-line was not planned and is worth naming**, because it is the class this project
keeps paying for: a tool that reports something it never checked, or reports it about the wrong
moment. `preflight` printed a pattern count it computed *itself* from one of two lists, beside a
floor derived from both ([quince#147](https://github.com/novkostya/quince/pull/147)) — "8 usable
patterns" against a floor of 9, which reads as the one alarm `patterns.floor` exists to raise, on
a healthy box. `rc-service status` decided on a 20-line grep window and displayed a 3-line tail,
so the evidence under the sentence need not be what triggered it — and because
`Session failed: Process exited with error` is *the normal terminal event of every unit*, *every
retirement* left a fit, idle box reporting failure at exit 1 until twenty lines scrolled past
([quince#155](https://github.com/novkostya/quince/pull/155)). `provision` told an arch box to
start `quince-runner`, a unit that box does not have
([quince#153](https://github.com/novkostya/quince/pull/153)). `/retire` §1 prescribed `bin/gh-bot`
to both seats, on a boundary where the architect host must never hold that token
([quince#145](https://github.com/novkostya/quince/pull/145)). `/onboard` §4 hand-listed two repos
while `.claude/forge-set` existed precisely so a third could not go unreported
([quince#148](https://github.com/novkostya/quince/pull/148)).
**The fixture README drift was the inverse of that class, and is the more interesting half.**
`bin/testdata/forge/README.md` indexed 29 of 43 fixtures, so **fourteen tested behaviours read as
untested** ([quince#151](https://github.com/novkostya/quince/pull/151)). Every other coverage
defect filed here runs the other way — declared coverage larger than the truth — so a reader who
has internalised *the docs overstate* would have misread this one too. The table was **not**
deleted: it is a genuine per-round narrative, so it was guarded by a gate asserting both
directions (every fixture named; every name resolving) and the fourteen were backfilled from each
fixture's own `note`, including a seventh round for the quince#80 issue-channel work that had none.
**`stop` gained `--all`, closing a remedy that could half-execute.** `/architect` §0 sends a
session that finds `wedged` to `stop --repo <r>`; under a multi-repo set a watcher can be wedged
on any of them, so a per-repo stop leaves the others live and the session then arms beside one —
quince#50's race reached *through* the remedy. The verify-then-signal moved into a shared
`stop_one` so both paths run one implementation of the pid check, and the fan-out **refuses as a
whole** if any single stop refuses, because a partial stop is the outcome that hurts
([quince#150](https://github.com/novkostya/quince/pull/150)).
**The spec learned a guarantee the tool already had.** `rung-loop` story 16 said a hand-run tick
cannot make a *dead* watcher look alive; quince#104 had shipped the mirror — `step()` carries the
watcher record forward, so it cannot make a *live* one look dead — and the acceptance criteria
never said so. A reader reconstructing the contract from story 16 alone rebuilds quince#103, which
is exactly how quince#103 happened. Story **16b** states the pair as *one property with one safety
argument* ([quince#152](https://github.com/novkostya/quince/pull/152)).
**Two review rounds, both catching real defects, both mine, and both invisible to every gate.**
The `/retire` fix first defined `<gh>` as "your seat's wrapper" — but the architect seat has
**two**, split by whether the call carries attribution, and §2 asks the session to *post*. A
session told at §1 that its wrapper is `gh-arch` would have flushed its parked PRs and rulings
through the one path `/architect` §1 forbids, with no error either time: a **loud** wrong traded
for a **quiet** one, in the skill whose §2 output is a session's unreviewed last act. And the
`preflight` fix captured the gate's stderr through
`mktemp … || echo /tmp/quince-preflight.$$.err` — a predictable path, written by **root**, holding
the gate's *matched* Operator-private lines on exit 1 (CWE-377). `mktemp` is in busybox and
coreutils so it would never have fired; it was blocked anyway, on the ground that the fallback
contradicted the file's own refuse-don't-degrade character. Both were caught by the reviewer, by
reading, and neither by a test.
**What the reviewer did that the record should keep.** Verdicts were checked against the tree and
the box rather than the PR body: the fixture counts re-derived independently (43 / 29 / 43); the
README gate's **real exit codes** tested in both directions, including a dangling reference the
reviewer injected themselves, because a gate that prints `FAILED` and exits 0 is a no-op inside
`gates-sh`; `stop --all` smoke-tested against the *actual* declared set in the one window where
both watches were already dead; and `rc-service quince-arch status` run live on the architect box,
reproducing both of quince#101's defects in one output — the sentence claiming an error, the idle
banner printed beneath it, real exit 1 — which is evidence the implementer box could not produce.
**The last finding landed on its own PR's thesis.** quince#101 argues a status line is a claim
about *now* that must be supported by what it shows; its three *new* lines hardcoded
`quince-runner:` while `name="${RC_SVCNAME:-quince-runner}"` sat 130 lines above, derived for
exactly that reason (quince#32) — so the arch box reported under a service it does not run. The
fourth, pre-existing literal was swept too: leaving one among four in a function the PR rewrites
hands the next reader a mixed convention. The label is now asserted over **every** branch of
`status()`, not the healthy one alone, because the literal appeared three times in one rewrite and
a single-branch check would have caught one and missed two — story 16b's lesson, twice in one night.
**Owed, and recorded where it can be found.**
[quince#154](https://github.com/novkostya/quince/issues/154): `provision`'s layer `chmod` skips
subdirectories (`[ -f ]`), and its comment enumerates only the dotfile exclusion, so it reads as
exhaustive. Nothing is unprotected today — the layer has no subdirectories but `.git` — but a
nested file would be missed by the fixer *and* invisible to `preflight`'s top-level-only note. The
reviewer raised it non-blocking with *"fold it in whenever `provision` next moves"*; it was filed
rather than left in a merged PR's review body, because a deferral recorded only there is the item
successors most often lose.
**Not proven, stated rather than implied.** `provision` has no test — it runs as root, clones
repos and installs services — so its two fixes were verified in isolation and the surrounding
script is untouched by evidence. `quince-runner-status-test` drives `status()` directly with
synthetic logs and stubbed OpenRC functions, so what is proven is the classification, not the
OpenRC integration around it; the marker strings come from quince#101's transcript rather than a
log captured for the purpose, and if the session banner's wording changes the `_up` set needs
revisiting (the failure direction is safe: an unrecognised banner reads as healthy, matching the
old default).
([quince#145](https://github.com/novkostya/quince/pull/145),
[quince#147](https://github.com/novkostya/quince/pull/147),
[quince#148](https://github.com/novkostya/quince/pull/148),
[quince#150](https://github.com/novkostya/quince/pull/150),
[quince#151](https://github.com/novkostya/quince/pull/151),
[quince#152](https://github.com/novkostya/quince/pull/152),
[quince#153](https://github.com/novkostya/quince/pull/153),
[quince#155](https://github.com/novkostya/quince/pull/155),
[quince#154](https://github.com/novkostya/quince/issues/154),
[quince#149](https://github.com/novkostya/quince/issues/149))
