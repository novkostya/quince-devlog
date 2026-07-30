# 2026-07-20 — (bk) (bj) corrected on the fifth Operator challenge ("hardlink seems better"): the measurement DOES inform selection — in exactly one direction

(bk) **(bj) corrected on the fifth Operator challenge ("hardlink seems
better"): the measurement DOES inform selection — in exactly one direction.** (bj)'s
"never worse than the fallback" compared only against copy and forgot hardlink sits above
it. Corrected rule: the ladder orders by RISK dominance (reflink clones are independent;
hardlinks alias — in-place mutation of `working/` would silently corrupt a hardlinked
`latest/`, which is why hardlink is matrix-gated and why reflink outranks it wherever both
share); the one selection edge is **measured-not-sharing reflink → fall through to
hardlink-under-matrix** (downgrade-for-space allowed; blind upgrade into aliasing risk
never). Channel-less deployments still prefer reflink on the risk asymmetry: worst case =
copy COST reported "unverified" vs hardlink's worst case = silent latest/ corruption.
Stack D5 amended. Investigation tally: five Operator challenges, five outcome changes.
