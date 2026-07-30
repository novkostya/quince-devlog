# 2026-07-30 — The channel that carries a ruling request was the one channel with no wake — a newly filed issue entered no watch at all

**The channel that carries a ruling request was the one channel with no wake — a newly
filed issue entered no watch at all.** `forge-watch` tracked an issue only if it was DECLARED or
REFERENCED by an open PR, and a freshly filed issue is neither. `CLAUDE.md` makes issues the tracker
and the gap protocol makes filing one how a blocked session **requests a ruling**, so a session that
followed the protocol correctly and then waited was waiting on a signal that could not arrive.
Demonstrated rather than hypothesised: quince#265 landed on the architect's own quince#230 ruling and
reached that seat only because the Operator asked by hand. **The fix is a HIGHWATER MARK on issue
numbers, not a set diff**, and the reviewer — who ruled the event and left the mechanism open — called
it better than what was ruled for a reason the author had not articulated: GitHub allocates issue and
PR numbers monotonically, so *"newer than last tick"* is a **number comparison with no wall clock**,
which is exactly the faculty the pure half deliberately lacks (`bin/forge-watch:278`, and why the
rung-loop spec's G5 `CANNOT BE MET`). It also avoids a **silent cap**: diffing a bounded list would be
one, which is what `fetch_issues` refuses one function up for the same reason. **A highwater cannot
tell a full window from a truncated one**, so when every scanned number is above the mark the tick
says so — the same discipline as `privacy-check`'s `DID NOT RUN`. Ruled with **no author filter and no
label filter**, and the author filter is the one that sounds obviously right and is wrong: implementer
and supervisor both file as `app/quince-coder` (quince#227), so suppressing your own would swallow
supervisor-filed ruling requests — this issue's own failure, reintroduced by its fix. **Part 1 was
deliberately NOT implemented as written**: it said to re-declare the issue set from all open issues at
cycle start, and its own Part 2 supersedes that — quince#282 measured the cost at **40 s per
foreground tick against a 60–90 s interval** for 45 declared issues, versus 17–18 s for 20. The skill
now says the opposite, *parked-only is five, not forty-five*, and the deviation was flagged for the
ruling seat rather than quietly substituted. **The ceiling is stated too:** an issue filed *before* you
armed is backlog, not news, and the cold-start listing is still what finds it — a reader taking
`issue-new` for complete coverage would stop doing the one thing that catches quince#265's own case.
([quince#273](https://github.com/novkostya/quince/issues/273),
[quince#286](https://github.com/novkostya/quince/pull/286),
[quince#282](https://github.com/novkostya/quince/issues/282),
[quince#265](https://github.com/novkostya/quince/issues/265))
