# 2026-07-30 — The privacy banner said how MANY patterns and never WHICH list, so two boxes swept with materially different matchers for hours and both printed `clean`

**The privacy banner said how MANY patterns and never WHICH list, so two boxes swept with
materially different matchers for hours and both printed `clean`.** Both banners were internally
consistent and both canaries passed — a canary proves *a* matcher, never the **same** one. It was
caught by a human comparing two banners quoted in two PR bodies, which is not a control. The gate now
names the list's commit and whether it is behind its tracking ref. **Local-only, and the wording is the
careful part:** `@{upstream}` is the LAST-FETCHED ref, so the claim is *"as of this box's last fetch"*
and says so, while `no upstream` and `not a git worktree` report **cannot tell** rather than collapsing
to a reassuring `0 behind` — because a freshness claim that overstates what it knows converts *unknown*
into *verified current*, which is this defect wearing a fix's clothes. **Option 1 —
`preflight` asserting a LIVE fetch — was deliberately NOT taken**: it makes whether a box may *start*
depend on network reachability, on a pair of hosts whose only recovery seat is the Operator's Mac, and
that is a ruling rather than an implementer's call. **This was also the first thing quince#275's fixed
exit code caught in anger**: `gates-sh` returned 2 and named `preflight-test` at 43→41, because the new
line was first called `lists provenance …` and `preflight` quotes the first line beginning `lists` — so
it reported provenance where a count belongs. Before that morning the ladder would have said `clean`.
**And the assertion written to pin the anchoring does not pin it**, checked rather than assumed: after
the rename no banner line begins with `lists` except the count, so reverting the anchor leaves the
suite green either way. Recorded as untested, with the reason, rather than left to read as coverage.
([quince#220](https://github.com/novkostya/quince/issues/220),
[quince#281](https://github.com/novkostya/quince/pull/281),
[quince#275](https://github.com/novkostya/quince/pull/275))
