# 2026-07-20 — (bh) (bg)'s discriminator RUN by the Operator on the host — CLONING WORKS; reflink REINSTATED

(bh) **(bg)'s discriminator RUN by the Operator on the host — CLONING WORKS;
reflink REINSTATED.** `bcloneused` 388M→788M (+400M = the test file), `bclonesaved`
695M→1.07G, pool ALLOC flat at 391G; the baseline itself proves prior clones were already
sharing on this pool. (bf)'s demotion reverses per (bg)'s pre-registered branch: the zfs
`latest/` mirror keeps reflink (near-instant, zero extra pool space; the ~34G-per-commit
copy price evaporates). What stands from (bf): the EXDEV-from-snapshot finding + the
clone-from-`working/` fallback (the operative path), and the probe measuring REAL sharing
at the POOL level — rung-local pick for qn.5: the `avail`-delta method needs only the
hook's existing `list` verb, or extend the helper with read-only `zpool get bclone*`.
Dataset-level `used` is documented as the trap (BRT bills like dedup). Option (d) side
quest CLOSED: root cause = accounting semantics, nothing is broken, no upstream issue.
Chain of custody worth recording: the gap protocol caught canon-vs-reality, and Operator
skepticism then caught evidence-vs-instrumentation — without (bg), a dataset-`used` probe
would have silently demoted a working reflink on every pool, forever.
