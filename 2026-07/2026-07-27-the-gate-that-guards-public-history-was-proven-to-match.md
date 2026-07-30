# 2026-07-27 — The gate that guards public history was proven to MATCH, not merely to compile — and the issue asking for it turned out to rest on a premise a measurement falsified

**The gate that guards public history was proven to MATCH, not merely to compile — and
the issue asking for it turned out to rest on a premise a measurement falsified.**
`privacy-check` had printed, on every run on both boxes, that its matcher was *"proven to COMPILE the
lists, not to match anything"* and that with no case-sensitive list *"every pattern runs under `-i`"*.
Both disclaimers were correct, and both were about missing **private-layer content**, not missing
code: the tool has supported a canary and a case-sensitive list all along, fully fixtured, with
nothing populating either. `quince-local@dd2d1e1` populates both, and **on the runner box** the gate
now reports `lists 8 case-insensitive + 1 case-sensitive` and `canary ok — the matcher matches
known-positive input (10 probe(s))`. **On the architect box it still reports neither**, and that is
not a lag: that box is on the pre-`dd2d1e1` layer and **cannot pull** — HTTPS remote, no credential
helper, `fatal: could not read Username`
([quince#121](https://github.com/novkostya/quince/issues/121)). So the control described here is live
on one of the two boxes, and the one it is absent from is the one that performs merges.
**The design choice that outruns the issue is one probe PER PATTERN rather than one overall**, which
closes the weakening mode `deploy/privacy/patterns.floor` documents as open and unclosable by a count:
a **same-count substitution**. Measured both ways — one pattern replaced by junk, count unchanged at
9, floor satisfied — a single-probe canary keeps reporting `canary ok` off the eight survivors, while
per-pattern probes drive the real tool to `DID NOT RUN … matched NOTHING`, exit 2. The probes are
derived mechanically from the lists, so no pattern was retyped and a hand-edited probe cannot drift
from the pattern it exists to prove.
**The falsified premise is the more durable finding.** [quince#109](https://github.com/novkostya/quince/issues/109)
argued urgency from [quince#41](https://github.com/novkostya/quince/issues/41) req 3's device-name
heuristic firing on ordinary product prose in two consecutive sweeps. That pattern is **no longer in
the list**; nine patterns × both matching modes × the entire committed tree returned **zero matches in
every cell**. So the recurring false positive the requirement was filed about was not happening, and
the split shipped as precision-and-machinery-exercise with that said out loud rather than as a bug fix.
**And the obvious mechanical rule would have been wrong**: *has uppercase ⇒ case-sensitive* would have
moved a MAC OUI prefix, which must stay under `-i` because MACs are written in both cases — losing
coverage while appearing to tighten it. A judgement got it right where a transformation would not,
which is the architect's stated reason for this class of change remaining a judgement.
Two triage comments and two implementer reports **raced and crossed** — the work was done and reported
~8 and ~15 seconds before each was declared blocked-on-the-Operator — and the record was corrected on
both issues rather than left standing. Owed and named: the enforcement half (an absent canary should
**refuse**, ruled from the architect seat since it is a failure-direction question rather than a
private-content one) is **blocked on [quince#121](https://github.com/novkostya/quince/issues/121)**,
a credential-widening question that is the Operator's — not on a pull, and not on a date. The
prerequisite was first framed as a grace window while both boxes became known-good; that framing
assumed the architect box could *become* good by pulling, and it cannot, so the flip must not be
built behind it or it sits finished and unlandable. **The refusal to infer that box's state from this
one is what surfaced it**, a day before it would have surfaced as an unmergeable PR. Also owed: a
**known-negative** list — nothing proves a pattern *stopped* matching, which is exactly what the case
split turns on, and it was verified by hand.
The commissioning PR's own claim, stated rather than only cited: **`TEXT=` takes a PATH to a file
holding the PR body, not the body** — passing the prose word-splits it and the gate refuses naming
the first word of the PR as an unreadable filename. The placeholder mis-taught it in `CLAUDE.md` and
in **both** `.claude/skills/review-pr/SKILL.md` sites, the latter unnamed by the issue and where a
reviewer actually reads the command.
([quince#119](https://github.com/novkostya/quince/pull/119),
[quince#121](https://github.com/novkostya/quince/issues/121),
[quince#108](https://github.com/novkostya/quince/issues/108),
[quince#109](https://github.com/novkostya/quince/issues/109),
[quince#105](https://github.com/novkostya/quince/issues/105),
[quince#41](https://github.com/novkostya/quince/issues/41),
[quince#44](https://github.com/novkostya/quince/issues/44))
