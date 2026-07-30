# 2026-07-24 — (cw) Finding B CLOSED — the qn.5b `seed_in_progress` guard: a seed killed mid-clone is no longer silently resumed into (branch `claude/qn5b-finding-b-seed-guard`, gates-green)

(cw) **Finding B CLOSED — the qn.5b `seed_in_progress` guard: a seed killed mid-clone
is no longer silently resumed into (branch `claude/qn5b-finding-b-seed-guard`, gates-green).** Per
the (cv) ruling, `workState` gains `seed_in_progress bool` written **true before the seed clone**
and cleared to **false on success**. A non-empty `working/<udid>` whose sentinel still says
in-progress is a partial clone (a seed SIGKILLed by the old (cs) timeout, or any crash mid-seed) —
`WorkDir` now **discards it and re-seeds** instead of resuming (resuming a partial could commit a
version missing blobs, since the encrypted verify only shard-checks a *full*). **Legacy-safe by Go's
zero value (the architect's refinement):** an old-code sentinel — written *post*-seed, so complete —
has no `seed_in_progress` field → decodes to `false` → **resume**, so the first restart after upgrade
never throws away a resumable 34 GB `working/`. Implemented as a **shared `prepareWorkDir`** both
backends now call (the two WorkDirs were duplicate lifecycles) so the guard is provably identical
across models — a small dedup that fell out of "applies to both." CI leg `TestSeedInProgressGuard`
proves the guard **discriminates** on BOTH models: killed seed → re-seed (a planted TAG is gone),
completed seed → resume (TAG survives), legacy sentinel → resume (TAG survives). No hardware; storage
coverage 78.9→79.3%. This closes the last qn.5b-owed item; the remaining routed findings are qn.6a's
((cr)/(cu)) and the multi-storage epic's (constraint #7).
