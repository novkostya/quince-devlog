# 2026-07-30 — The product is UNFROZEN — Operator ruling, taken on risks rather than on gates

**The product is UNFROZEN — Operator ruling, taken on risks rather than on gates.** The
freeze had stood since `qn.6b`, and what lifted it was not a gate closing: the ladder was assessed
grade by grade earlier the same day and **nothing on it blocked the decision** (quince-devlog#141,
quince-devlog#146). G4 was the last gap and closed on evidence gathered hours before, G5
**cannot be met** and is deferred with its reason, `pr.6` is reduced to its identity half and that
half is discharged, and the two remaining named blockers are unreadable rather than pending. **So the
criteria section stops gating and becomes provenance** — retained rather than deleted, because a
ruling whose basis is removed on the day it is satisfied has no stated basis. **The risks ride in
rather than being cleared:** quince#202 (`forge-watch` is blind to the trunk — `main` was red 4h40m
with a healthy watch, and the merge that broke it went through this loop), quince-devlog#56, the
killed-session behaviour, G5 unbuilt, #32's proof owed to an Operator re-provision window, #33
needing a re-file, and quince#54 now carrying two claim-level drift instances. **quince#202 is named
largest because it grows at the unfreeze** — an unobserved red trunk costs more once product merges
resume than it did while only tooling landed. **`qn.7` (Wi-Fi reliability hardening) resumes the
product chain, and its first deliverable is a SPEC**: `docs/specs/qn.7/` does not exist, and `CLAUDE.md`
is explicit that where the frontier rung has none the spec is the first PR, reviewed before any code.
**One dissent is on the record and was overruled**: the architect found G4's evidence to be
issue-mediated where the ladder's text says *a review comment … a PR comment*, and the Operator ruled
the grade stands on substance — so a later session grading against the verbatim sentence will reach a
different answer, and quince-devlog#146's thread is why.
([quince-devlog#141](https://github.com/novkostya/quince-devlog/issues/141),
[quince-devlog#146](https://github.com/novkostya/quince-devlog/pull/146),
[quince#202](https://github.com/novkostya/quince/issues/202))
