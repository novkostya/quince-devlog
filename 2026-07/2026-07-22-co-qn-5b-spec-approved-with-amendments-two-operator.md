# 2026-07-22 — (co) qn.5b spec APPROVED with amendments — two Operator-caught issues + the seven gate forks ruled

(co) **qn.5b spec APPROVED with amendments — two Operator-caught issues + the seven
gate forks ruled.** The spec is strong (it found a THIRD non-atomic window — namespace
`finishRotation`, missed by (cg) — and the non-idempotent-exchange marker guard is exactly the
right first-class treatment). **Amendment A — "reflink seed" is loose prose hiding a real hazard
(Operator-caught).** The seed-split *table* is correct (`clonetree.Clone` picks per-backend
strategy, so hardlink seeds by hardlink) but the NARRATIVE (goal line 7, §unified-model line 169,
decision 1) says "seeded as a reflink clone" universally. That is not just wording: **seeding the
hardlink backend means `working/<udid>` shares inodes with `latest/`, so an in-place write by
`idevicebackup2` corrupts the committed `latest/` through the alias — the exact class the deferred
12c matrix governs.** The spec even says "must not rely on hardlink correctness it doesn't prove"
(line 111) while doing precisely that. **Ruling:** the seed clone must use the SAME
hardlink-safety discipline as qn.5's version promotion — i.e. the hardlink tier stays
**disabled-to-copy** for the *seed* too until 12c proves it (a hardlink seed is only safe if every
file `idevicebackup2` may mutate in place is copied-not-linked, which is 12c's whole matrix). So
on the hardlink backend, **seed = copy (surfaced), not hardlink**, until 12c. reflink (independent
clones) and copy are safe; hardlink is not, and the prose must say "clone via the backend's safe
strategy," never "reflink," everywhere. Fix the narrative + gate the hardlink-seed path.
**Amendment B — keep the ULID in the snapshot name; do NOT drop it (Operator floated dropping it).**
The ULID *is* `versionID` (the marker/journal/`Version.id`/`browse_root` key) — embedding it is
what maps a `zfs list` line back to its version/logs; and two same-minute backups (failed→retry, or
rapid gate testing — the Operator's own `zfs list` shows three same-day snapshots) would collide on
a date-only name and **fail `zfs snapshot`**. ULIDs are lexically time-sortable, so
`quince-<date>-<ULID>` already sorts chronologically AND stays collision-free. If time-of-day
readability is wanted, **widen the date to `YYYY-MM-DDTHH-MM`** and keep the ULID tail — never drop
it. **Gate forks (§"decisions for the architect") ruled:** (1) full per-job model — YES; (2)
exchange in-container with a host-hook fallback gated on the in-container `exch` probe — YES; (3)
`mirror`→`seed` hook verb, deployed helper updated — YES (real one-time deploy cost, ship the
migration note); (4) pre-qn.5b snapshots treated as disposable lab data, `Scan` skips gracefully —
YES (pre-v0.1, throwaway; the perf-budget reasoning is sound); (5) 2-action Retry/Reset — YES; (6)
`storage.zfs.mirror`→`seed` config rename — YES (no alias, pre-freeze single-user); (7) unify
`Discard` to keep-dirty-working on all backends incl. cancel — YES (the namespace-deletes-work
asymmetry is the (cj) #4/#5 bug). **The Reset contract proposal** (`POST /api/devices/{udid}/
reset-working` → 202|404|409) is **accepted** — clean, audited, never touches committed state; land
it in contracts §1 during build (the qn.2b/qn.3 pattern). Build on the ruling.
