# 2026-07-20 — (bt) qn.4a BUILT (CI) — the backup engine drives idevicebackup2 end-to-end

(bt) **qn.4a BUILT (CI) — the backup engine drives idevicebackup2 end-to-end.**
*(Letter fix 2026-07-20: this entry was originally mislabeled (bp), colliding with the qn.4b
spec-approval entry below. Every `(bp)` cross-reference in canon + code means that auto-absent
ruling, so THIS build record was renumbered — to (bt), since (bs) was legitimately taken by the
gate-15 hardware entry that landed meanwhile — rather than churn 20 references. Out of strict
alpha order by design; a terminal build record.)*
Cleared the pre-build spec-review gate: spec + Rule check → **architect APPROVED with three
amendments (1 startup job-row reconciliation story + explicit two-reconciler order; 2 the
`waiting_for_device` bound named `const`; 3 the sampler free-space / `disk_low` leg — the
implementer's "A3", ACCEPTED) + two ratifications (the double-`Verify` stands; `transport:auto`
stays deferred to qn.4b) + one correction (no rung numbers in the `auto` 422 API string)**, all
folded in. Shipped: **`internal/backup`** — the `Job` state machine (per-UDID single-flight),
the `idevicebackup2` streaming supervisor (argv/`setpgid`/group-kill), a transcript-grounded
tolerant parser, the activity-sampler liveness (staged, passcode-paused, startup-grace, + A3
free-space `disk_low` warning surfaced via `job.log`/`slog`, never a silent kill), preflight
(presence + pairing + encryption policy + disk headroom + Seed), the Seed→`Verify`→`CommitJob`/
`Discard` handoff, and **startup job-row reconciliation** (crash-orphans → `connection_lost`, a
rolled-forward commit → `succeeded`, run AFTER storage reconciliation); a **`jobs` table +
registry** in `internal/store` (real `JobReader`, cursor pagination); the **job command surface**
(`POST /api/jobs` 202/409/422/404/503, `POST …/cancel`, `JobControl` consumer interface, `job.*`
events) + contracts §1 error codes recorded; the **`quince backup` CLI** (`DriveToCompletion`)
via a shared `cmd/quince` `buildLiveStack` (serve + CLI); and the **six lab transcripts** +
meta + a fake-`idevicebackup2` replayer. `make gates`/image/e2e green. **Two RULINGS that drove
the build (both rung-local, in the qn.4a spec):** (1) *the Wi-Fi torn session is a STALL, not an
error line* — the lab's `Heartbeat(SleepyTime)` freezes output; the sampler's tree-activity
timeout produces `connection_lost` (the discriminator vs a survivable silence is tree churn, not
output); (2) *`idevicebackup2 backup <target>` writes into `<target>/<UDID>/`* while qn.5 expects
the tree at the work dir — bridged by an engine-side **symlink adapter** (`<UDID>` → work dir),
no qn.5 change, no tree copy, no committed-state mutation (verify-live on lab gate 15).
**Coverage:** backup **83.2%**, store 80.8%, httpapi 72.2%, cmd/quince 11.0% (the CLI wiring is
hardware-exercised); known-untested = the real-`idevicebackup2` argv/symlink-follow + `statfsFree`
leaf (fake-covered in CI) + `buildLiveStack`/`backupCmd`. **Handoff review of qn.5: clean** (one
minor — `CommitJob`'s verify-fail branch, now covered by story 6). **Lab gate 15 (real encrypted
USB backup + kill-matrix + the re-homed gate-12 legs) owned by this rung** — the hardware
session; NOT proven yet. **Landed on `main` (CI half); gate-15 findings land later as labeled
commits** (Operator relaxed the usual land-after-hardware order for this rung). Frontier stays
**qn.4a** until lab gate 15, then → **qn.4b**.
