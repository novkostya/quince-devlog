# 2026-07-24 — (cu) DEGRADED UX regression (Operator-caught on hardware): qn.5b made the gap between tapping "Back up now" and the on-device passcode prompt MUCH longer — proportional to device…

(cu) **DEGRADED UX regression (Operator-caught on hardware): qn.5b made the gap between
tapping "Back up now" and the on-device passcode prompt MUCH longer — proportional to device size.**
Cause is structural to qn.5b's per-job `working/`: **pre-qn.5b the zfs `Seed` was a no-op** (a
persistent `working/` was already in place), so `idevicebackup2` launched within the same second and
the phone prompted almost immediately. **Now `WorkDir` reflink-clones `latest/` → `working/<udid>`
synchronously inside preflight, BEFORE `idevicebackup2` starts** — and that seed is ~23 s+ for the
34 GB iPhone (O(files); (cs)). So the passcode prompt (which is triggered by idevicebackup2's device
handshake) can't appear until the seed finishes → ~20+ s of dead air where the UI shows nothing
happening. The *real* complaint is the dead air, not the raw latency. **Mitigation options for the
architect (roughly cheapest → biggest):** **(1)** surface a distinct **"preparing / seeding" job
phase** between `preflight` and `backing_up` (quince already models phases) so the UI shows
"Preparing — cloning from your last backup…" with progress instead of a frozen button; fixes the
PERCEPTION (the actual gripe) without touching latency — **natural fit for qn.6a's soak-UX charter,
recommended first.** **(2)** overlap the device handshake with the seed so the passcode prompt fires
immediately while the seed runs in the background — but idevicebackup2 does handshake+read in one
process, so this needs either a lightweight pre-handshake or a lazily-seeding tool (more complex,
transport-adjacent). **(3)** keep a **warm pre-seeded `working/`** between backups (or pre-seed
proactively right after a commit / on the qn.12 opportunity signal) so "Back up now" finds it ready
→ instant start; cost is it **breaks "between backups the dataset holds only `latest/`"** (snapshot
bloat — rclone still excludes it), a direct trade-off against qn.5b's clean-snapshot invariant, so
architect-only and probably a config toggle. **(4)** faster seed — inherently O(files) (~133 k
reflinks); the (cs) chown fix already trimmed it and there is no big win left short of the REJECTED
zfs-clone-as-dataset approach ((cg)). **Recommendation: (1) now (cheap, soak-path), (2)/(3) only if
the raw latency — not just its visibility — must drop.** Sent to architect for routing.
