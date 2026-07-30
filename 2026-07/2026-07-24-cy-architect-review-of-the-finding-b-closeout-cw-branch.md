# 2026-07-24 — (cy) ARCHITECT REVIEW of the Finding B closeout ((cw), branch `claude/qn5b-finding-b-seed-guard`): APPROVED + LANDED (main → `b0a859a`, ff-only)

(cy) **ARCHITECT REVIEW of the Finding B closeout ((cw), branch
`claude/qn5b-finding-b-seed-guard`): APPROVED + LANDED (main → `b0a859a`, ff-only).** Verified in
code: the sentinel is written `seed_in_progress:true` BEFORE tree creation and cleared on success;
the guard discards-and-re-seeds only on a present sentinel still saying in-progress; the (cv)
legacy-safety refinement is implemented by Go's zero value AND proven by a hand-planted
legacy-JSON test case; the shared `prepareWorkDir` makes the guard provably identical across both
models (a real dedup — the two WorkDirs were duplicate lifecycles). Crash-window walk: every kill
point resolves safely — a crash mid-write of the FIRST sentinel leaves an empty/absent tree that
bypasses the guard and re-runs; a crash mid-write of the CLEARING sentinel leaves a corrupt
sentinel only beside a COMPLETE tree, where the read-failure→resume fallback is correct (and the
torn-write exposure of the sentinel predates this patch, unchanged). `TestSeedInProgressGuard`'s
TAG discrimination is the exact CI leg (cv) demanded (killed→re-seed, completed→resume,
legacy→resume, both backends). Privacy sweep clean. **qn.5b is now FULLY closed** — built (cp),
hardware-proven (ct), all follow-ups routed (cv), Finding B fixed (cw). Chain: **qn.6a (soak UI) →
freeze**.
