# 2026-07-30 — The first live instance of the prose-drift issue was created by the session that had spent the day fixing prose drift, four hours after a measurement declared the issue dormant

**The first live instance of the prose-drift issue was created by the session that had
spent the day fixing prose drift, four hours after a measurement declared the issue dormant.**
quince#302 narrowed `/architect` §6 — *"`actor=unattributed` means go and look, commonly a checklist
box"* — because that cause was **measured false**: across ten merges the branch-deletion case fired
every time and the checklist case never. `.claude/loop-protocol.md` is the NORMATIVE file and did not
get the narrowing, so canon told a reader to investigate a post-merge non-event once per merge while
the skill said otherwise. **What it settles about quince#54 is more than the fix:** that issue's
2026-07-29 measurement found *"no live drift"* and offered *narrow to commands* or *close as
dormant*, and this recurred inside four hours — but it is **claim-level**, with no shared command
block between the two files, so the gate the issue proposes would have passed it cleanly. Two
recorded instances now, both claim-level, none command-level. **The cause is not memory**: `CLAUDE.md`
requires canon updated in the same PR, and the check is one `grep` that returns both files — run
afterwards, while measuring something else. **Same shape as the proxy qualifier dropped the same
hour**: a claim correct where the session was working and stale where it was not, both times losing
the caveat in the direction that made the claim stronger. Then the forge confirmed the other half
unprompted — a catch-up tick returned `event=updated pr=148 actor=unattributed kind=post-merge`, the
**first live emission**, retiring quince#302's declared *"never observed live; every increment is a
stub"* about 35 minutes after it landed. It proves the three clauses fire together on real data and
**not** the suppression, because a hand-run tick has no wake decision — a distinction worth keeping,
since the label and the not-waking are separate claims and only one of them was observed.
([quince#54](https://github.com/novkostya/quince/issues/54),
[quince#305](https://github.com/novkostya/quince/pull/305))
