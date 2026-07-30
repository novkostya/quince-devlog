# 2026-07-30 — The one condition that flips whose turn it is with no event of its own — a PR you BLOCKED and the author has since answered

**The one condition that flips whose turn it is with no event of its own — a PR you
BLOCKED and the author has since answered.** `/architect` §6 covers a PR you PARKED pending someone
else; this one waits on the AUTHOR, and the instant they answer it silently becomes yours with
nothing marking the transition. The push produces one wake, and a reviewer mid-task when it lands
never sees it again: quince-devlog#140 sat `CHANGES_REQUESTED` for **1h45m** past its fix while five
other PRs merged. **The design decision is `committer == author`, and a date test alone is actively
wrong here.** A rebase REWRITES `committedDate` — measured on quince#287, where a commit authored
seventeen minutes BEFORE the verdict carried a date after it — and `strict: true` makes a rebase the
routine answer to every merge, so a date test would announce *"the author answered you"* on every
one. GitHub stamps whoever ran `update-branch` as the committer, so the two differing IS a rebase.
**The ruling was withdrawn and re-specified twice before anything was built**, both times because a
measurement contradicted it: the first mechanism named two fields (`reviewDecision`, `headRefOid`)
that are **not fetched at all**, and the substitute the implementer proposed had the rebase
false-positive above — which the architect then measured, and in checking it found the committer
discriminator neither seat had thought of. **Then the shipped version had two defects of its own,
both found by running rather than reading.** It fired on EVERY TICK rather than on the transition —
a wake a minute, indefinitely, noise amplification in the feature built to reduce missed signals —
and the PR body had asserted it behaved *"like `mergeability`"*, which diffs stored state and fires
only on a transition. Fixing that over-narrowed it: keying on null-vs-non-null means two DIFFERENT
blocks both read "answered", so a verdict and its answer inside one interval fire nothing at all,
which is a MISSED wake — and the only two-verdicts-in-one-interval case in this project was **79
seconds** apart, well inside a 90 s tick. The key is the BLOCK, not the boolean. **Three fixtures,
none redundant:** the pre-fix code passed the first, the null-vs-non-null fix passed the first two.
([quince#282](https://github.com/novkostya/quince/issues/282),
[quince#288](https://github.com/novkostya/quince/pull/288),
[quince#290](https://github.com/novkostya/quince/issues/290),
[quince#291](https://github.com/novkostya/quince/pull/291))
