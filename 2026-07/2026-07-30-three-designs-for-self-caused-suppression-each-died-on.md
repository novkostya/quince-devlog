# 2026-07-30 — Three designs for self-caused suppression each died on the backstop, and none of them was wrong — each was one arm of a two-arm mechanism, tested against the whole problem

**Three designs for self-caused suppression each died on the backstop, and none of them
was wrong — each was one arm of a two-arm mechanism, tested against the whole problem.** An act
emits TWO lines: `event=updated`, which carries `actor=`, and a typed `event=review`/`merged`,
which cannot, because both are computed by DIFFING two observations and a diff knows what changed
but not who. Suppressing either alone leaves the other to wake the session. Every attempt tried to
cancel one **act**, which forces state across ticks because the two lines can arrive a tick apart —
and `forge-watch:284` had already ruled against exactly that. **The way through was to stop pairing
them:** attribute each LINE independently where it lands, one arm each, no lifetime rule, no
de-duplication, `:284` untouched. **Three PRs, and the first is the enabling half of the guard:**
`event=review` fires once per tick however many verdicts landed and reported only the last, so a
consumer could not tell *my verdict* from *mine plus another seat's* — `count=` supplies that
cardinality, and suppression on presence alone would have swallowed somebody else's verdict, which
is the MISSED-wake direction. `event=merged` deliberately gets no count, with the reason at the
line: a PR merges once, and the asymmetry is why only one channel needs a guard.
([quince#242](https://github.com/novkostya/quince/issues/242),
[quince#297](https://github.com/novkostya/quince/pull/297),
[quince#298](https://github.com/novkostya/quince/pull/298),
[quince#300](https://github.com/novkostya/quince/pull/300))
