# 2026-07-30 — The identity had three spellings, the round trip silently discarded the field that mattered, and both were found by measuring rather than reading

**The identity had three spellings, the round trip silently discarded the field that
mattered, and both were found by measuring rather than reading.** (1) The same App appears as
`quince-coder` (review or comment author), `quince-coder[bot]` (commit committer) and
`app/quince-review` (`mergedBy`, in `gh`'s rendering). `actor == "quince-coder"` — the obvious
comparison, and the literal form of the ruling — matches reviews and comments and **misses every
push**, the implementer's commonest self-caused update: an arm that would have shipped, passed
review and suppressed almost nothing. Third time in two days a mechanism was described from memory
one token off, and each time the wrong token was the load-bearing one. (2) Suppressing on `actor`
makes a WRONG actor a wrong WAKE — the promotion quince#222 predicted for itself in its own last
line — and a rebase replays the original authorship, so the merging seat's `update-branch` wears the
branch author's login. **The discriminator was already in the observation**: GitHub stamps whoever
ran it as the COMMITTER. So the arm reads `committer == actor` and quince#222 stops being a
dependency rather than being waited on. (3) **`gh-array-to-graphql.jq` dropped `committer`
entirely**, so every stub and every recorded fixture reached the shaping with `committer: ""` —
indistinguishable from an unresolvable one, and invisible to the equivalence suite whose whole
subject is that the conversion is exact. `review-answered` already depended on that field. **The
shape is the finding: a field the forward path reads and the round trip silently discards, where
the discarded value is indistinguishable from a legitimate one.** Then the forge produced the proof
unprompted — the architect's rebase of the PR that adds the arm emitted `actor=quince-coder[bot]
committer=quince-review[bot]` on that very branch, converting a declared-unproven item into a live
capture.
([quince#222](https://github.com/novkostya/quince/issues/222),
[quince#300](https://github.com/novkostya/quince/pull/300))
