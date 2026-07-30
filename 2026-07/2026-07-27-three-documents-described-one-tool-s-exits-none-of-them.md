# 2026-07-27 — Three documents described one tool's exits; none of them matched it, and they disagreed with each other about which parts they had wrong

**Three documents described one tool's exits; none of them matched it, and they
disagreed with each other about which parts they had wrong.**
[quince#75](https://github.com/novkostya/quince/issues/75) closed by
[quince#85](https://github.com/novkostya/quince/pull/85) (`ed88539`), landed **before the
re-provision window** deliberately: skills load at session start, so a skill fix that lands *after*
a re-provision means the box reboots into the old text, runs on it, and owes a second restart to
make the fix live. **A maintenance window is the delivery mechanism for skill fixes**, and the
cheapest moment to land one is just before a restart that is already going to happen. `bin/forge-watch watch` exits **1**
when it REFUSES to arm — *"a watch is ALREADY LIVE … refusing to arm a second one"*, which is
[quince#50](https://github.com/novkostya/quince/issues/50)'s guard working — and `/architect` §6,
`/kickoff` §6 and `loop-protocol.md` all enumerated the exits as *0, 6 and 7* and said **"every exit
is a re-arm"**. Followed literally on a refusal that is refuse → re-arm → refuse → re-arm,
unbounded, **with no watch running throughout**; the architect hit it and escaped by noticing, which
is not a mechanism. **Adding `1` would have fixed the instance and left the class**, so the fix
asserts the relationship instead: `bin/forge-watch-exits-test`, run by `gates-sh`, **DERIVES** the
designed exits from `bin/forge-watch` itself — the two functions whose returns become process exits,
plus `die()` — **MEASURES** each by driving the tool into that state, and requires every one to be
**DOCUMENTED** in every file that enumerates them. Against the pre-fix documents it fails naming
exactly the missing codes: architect `1`, kickoff `1 3 4 5`, loop-protocol `1 3 4 5 7`. **The
hypothesis the addendum was written on turned out to be wrong, which was the finding.**
`loop-protocol.md` was expected to be the correct document the skills had drifted from. It was not:
it is the *only* one that names the refusal in prose — and asserts "Every exit is a re-arm" two
lines later, holding the fact and its contradiction adjacent — never gives the refusal a code, and
omits **more** codes than either skill. There was no correct document. Reported on
[quince#54](https://github.com/novkostya/quince/issues/54) with the table and the reason they are
not three independent typos: the enumeration was copied between the skills and never re-derived
from the tool, so a correction to any one would have left the others. **`/kickoff` was outside the
addendum's scope and carried the defect twice** — the enumeration and a second standalone *"Every
exit is a re-arm."* — and was fixed with the widening flagged rather than buried; the architect
argued to keep it, since splitting would leave a known-false instruction live in the file
implementers read. **The check's own first version passed on the broken documents** — it matched a
bare digit, and every code occurs in these files as an issue number or a count — then went wrong
twice more in the opposite direction; all three wrong matchers are recorded in the suite's comment,
because the shape of the mistake is the reusable part. That was the fourth check-that-could-not-fail
of the evening and **the first caught by its author before review**. **A governance boundary was
drawn and then narrowed, and the narrowing is the durable part.** The architect **recused itself**:
it had filed quince#75 *and* specified the fix, and the PR edits `/architect` SKILL.md — its own
operating instructions — plus shared canon, so `approver ≠ author` read literally was not enough.
The Operator's ruling: *a skill change governing the reviewer's seat needs the Operator when it
alters what the reviewer may or must **decide**; a correction of fact about what a tool returns —
verifiable against the tool, and carrying a test that fails when it drifts — is the architect's to
approve.* **Approve it on the test, not on the filer's word.** The fixture is what moved this out of
the governance path: a factual claim with a mechanical check behind it does not need the slower
route, precisely because it can be verified without trusting either party.
([quince#85](https://github.com/novkostya/quince/pull/85),
[#75](https://github.com/novkostya/quince/issues/75),
[#54](https://github.com/novkostya/quince/issues/54))
